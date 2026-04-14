;;; sekka-jisyo.el --- Dictionary loading and lookup for Sekka  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2010-2014 Kiyoka Nishiyama
;;
;; This file is part of Sekka
;;
;; Sekka is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; Sekka is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;

;;; Commentary:

;; Dictionary loading, lookup, and user dictionary management for Sekka.

;;; Code:

(require 'cl-lib)
(require 'sekka-symspell)
(require 'sekka-jarowinkler)
(require 'url)

;; メイン辞書 (ひらがなキー → "/候補1/候補2/..." 文字列)
(defvar sekka-jisyo-hash nil
  "Master dictionary hash-table.")

;; ユーザー辞書 (学習結果を保持、メイン辞書より優先)
(defvar sekka-user-jisyo-hash nil
  "User dictionary hash-table (overrides master).")

(defvar sekka-user-jisyo-file (expand-file-name "~/.sekka-jisyo")
  "Path to user dictionary file.")

(defvar sekka-jisyo-loaded nil
  "Non-nil if dictionary has been loaded.")

(defvar sekka-symspell-ready nil
  "Non-nil if SymSpell index has been built.")

(defvar sekka-symspell-building nil
  "Non-nil if SymSpell index is currently being built.")

(defvar sekka-jarowinkler-ready nil
  "Non-nil if Jaro-Winkler index has been built.")

(defvar sekka-dictionary-base-url
  "https://raw.githubusercontent.com/kiyoka/sekka/master/data/"
  "Base URL for downloading dictionary files from GitHub.")

(defvar sekka-dictionary-cache-dir
  (expand-file-name "sekka" user-emacs-directory)
  "Directory to cache downloaded dictionary files.")


;;; ============================================================
;;; SKK辞書ファイルの読み込み
;;; ============================================================

(defun sekka-jisyo--parse-skk-line (line)
  "SKK辞書の1行をパースし (key . value) を返す.
コメント行やパース不能な行は nil."
  (when (and (> (length line) 0)
             (not (= (aref line 0) ?\;)))
    (let ((space-pos (string-match " " line)))
      (when space-pos
        (cons (substring line 0 space-pos)
              (substring line (1+ space-pos)))))))

(defun sekka-jisyo-load-file (file hash)
  "SKK-JISYO形式のファイル FILE を hash-table HASH に読み込む.
既存エントリがあれば候補をマージする."
  (when (file-readable-p file)
    (with-temp-buffer
      (let ((coding-system-for-read 'utf-8))
        (insert-file-contents file))
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((line (buffer-substring-no-properties
                      (line-beginning-position) (line-end-position)))
               (parsed (sekka-jisyo--parse-skk-line line)))
          (when parsed
            (let* ((key (car parsed))
                   (val (cdr parsed))
                   (existing (gethash key hash)))
              (if existing
                  ;; 候補をマージ (既存の末尾の / と新規の先頭の / が重なる)
                  (let ((merged (sekka-jisyo--merge-candidates existing val)))
                    (puthash key merged hash))
                (puthash key val hash)))))
        (forward-line 1)))
    hash))

(defun sekka-jisyo--merge-candidates (existing new)
  "2つの候補文字列をマージ(重複排除)する.
EXISTING, NEW はそれぞれ \"/候補1/候補2/\" 形式."
  (let* ((e-list (sekka-jisyo--split-candidates existing))
         (n-list (sekka-jisyo--split-candidates new))
         (merged (cl-remove-duplicates (append e-list n-list) :test #'equal)))
    (concat "/" (mapconcat #'identity merged "/") "/")))

(defun sekka-jisyo--split-candidates (str)
  "候補文字列 \"/a/b/c/\" をリスト (\"a\" \"b\" \"c\") に分割する."
  (cl-remove-if (lambda (s) (string= s ""))
                (split-string str "/")))


;;; ============================================================
;;; 辞書の初期化
;;; ============================================================

(defvar sekka-jisyo-file-list nil
  "List of dictionary files to load.
Set this before calling `sekka-jisyo-init'.")

(defvar sekka-jisyo-dictionary-names
  '("SKK-JISYO.L.201501"
    "SKK-JISYO.L.hira-kata"
    "SKK-JISYO.jinmei"
    "SKK-JISYO.station"
    "SKK-JISYO.fullname")
  "List of dictionary file names to load.")

(defun sekka-jisyo--download-file (url dest)
  "URL からファイルをダウンロードし DEST に保存する.
成功時は DEST を返し、失敗時は nil を返す."
  (let ((url-show-status nil)
        (buf nil))
    (condition-case err
        (progn
          (setq buf (url-retrieve-synchronously url t))
          (when buf
            (with-current-buffer buf
              (goto-char (point-min))
              (if (not (re-search-forward "^HTTP/[0-9.]+ 200" nil t))
                  (progn
                    (message "Sekka: download failed (non-200): %s" url)
                    nil)
                (re-search-forward "\r?\n\r?\n" nil t)
                (let ((coding-system-for-write 'binary))
                  (write-region (point) (point-max) dest nil 'silent))
                dest))))
      (error
       (message "Sekka: download error: %s" (error-message-string err))
       nil))
    ;; バッファのクリーンアップ (condition-caseの外で確実に実行)
    (when (and buf (buffer-live-p buf))
      (kill-buffer buf))
    ;; dest が存在すれば成功
    (when (file-exists-p dest) dest)))

(defun sekka-jisyo--ensure-dictionaries ()
  "辞書ファイルがキャッシュディレクトリに存在することを確認する.
存在しなければ GitHub からダウンロードする.
ダウンロードした(または既存の)ファイルのリストを返す."
  (unless (file-directory-p sekka-dictionary-cache-dir)
    (make-directory sekka-dictionary-cache-dir t))
  (let ((files nil))
    (dolist (name sekka-jisyo-dictionary-names)
      (let ((local-path (expand-file-name name sekka-dictionary-cache-dir)))
        (if (file-exists-p local-path)
            (push local-path files)
          (message "Sekka: downloading %s ..." name)
          (let ((url (concat sekka-dictionary-base-url name)))
            (when (sekka-jisyo--download-file url local-path)
              (message "Sekka: downloaded %s" name)
              (push local-path files))))))
    (nreverse files)))

(defun sekka-jisyo-default-file-list ()
  "デフォルトの辞書ファイルリストを返す.
まず emacs/ ディレクトリの親にある data/ を探し、
見つからなければキャッシュディレクトリから取得(必要ならダウンロード)する."
  (let* ((elisp-dir (file-name-directory
                     (or (locate-library "sekka-jisyo")
                         load-file-name buffer-file-name "")))
         (data-dir (expand-file-name
                    "data"
                    (file-name-directory
                     (directory-file-name elisp-dir))))
         (local-files
          (cl-remove-if-not
           #'file-exists-p
           (mapcar (lambda (name) (expand-file-name name data-dir))
                   sekka-jisyo-dictionary-names))))
    (if local-files
        local-files
      (sekka-jisyo--ensure-dictionaries))))

(defun sekka-jisyo-download-dictionaries ()
  "辞書ファイルをキャッシュディレクトリにダウンロードする.
既にキャッシュ済みのファイルは再ダウンロードしない.
動作確認やキャッシュの事前構築に使用する."
  (interactive)
  (let ((files (sekka-jisyo--ensure-dictionaries)))
    (message "Sekka: %d dictionary files ready in %s"
             (length files) sekka-dictionary-cache-dir)
    files))

(defun sekka-jisyo-init ()
  "辞書を初期化してhash-tableにロードする."
  (interactive)
  (message "Sekka: 辞書を読み込み中...")
  (setq sekka-jisyo-hash (make-hash-table :test 'equal :size 200000))
  (setq sekka-user-jisyo-hash (make-hash-table :test 'equal :size 1000))
  (let ((files (or sekka-jisyo-file-list
                   (sekka-jisyo-default-file-list))))
    (dolist (f files)
      (message "Sekka: loading %s ..." (file-name-nondirectory f))
      (sekka-jisyo-load-file f sekka-jisyo-hash)))
  ;; ユーザー辞書の読み込み
  (when (file-readable-p sekka-user-jisyo-file)
    (sekka-jisyo-load-file sekka-user-jisyo-file sekka-user-jisyo-hash))
  (setq sekka-jisyo-loaded t)
  (message "Sekka: 辞書の読み込み完了 (entries: %d)"
           (hash-table-count sekka-jisyo-hash))
  ;; SymSpellインデックスの構築をアイドル時に遅延実行
  (setq sekka-symspell-ready nil)
  (setq sekka-symspell-building nil)
  (setq sekka-jarowinkler-ready nil)
  (sekka-jisyo--schedule-symspell-build))

(defun sekka-jisyo--build-jarowinkler-index ()
  "メイン辞書とユーザー辞書から Jaro-Winkler インデックスを構築する."
  (sekka-jarowinkler-build-index sekka-jisyo-hash)
  (when (> (hash-table-count sekka-user-jisyo-hash) 0)
    ;; ユーザー辞書のキーを追加 (単純に再構築でもよいが、軽いのでマージ)
    (maphash
     (lambda (key _val)
       (when (and (stringp key) (> (length key) 0))
         (let ((roman (sekka-jarowinkler-hiragana->roman key)))
           (when (>= (length roman) (car sekka-jarowinkler-prefix-lengths))
             (unless (gethash roman sekka-jarowinkler-roman-to-hira)
               (puthash roman key sekka-jarowinkler-roman-to-hira)
               (sekka-jarowinkler--add-to-index
                roman sekka-jarowinkler-index))))))
     sekka-user-jisyo-hash))
  (setq sekka-jarowinkler-ready t))

(defun sekka-jisyo-build-symspell-now ()
  "SymSpellインデックスを即座に構築する.
テスト環境やバッチ処理で使用."
  (when (and sekka-jisyo-loaded (not sekka-symspell-ready))
    (setq sekka-symspell-building t)
    (message "Sekka: SymSpellインデックスを構築中...")
    (sekka-symspell-build-index sekka-jisyo-hash)
    ;; ユーザー辞書のキーもSymSpellインデックスに追加
    (when (> (hash-table-count sekka-user-jisyo-hash) 0)
      (maphash
       (lambda (key _val)
         (unless (gethash key sekka-symspell-dict-set)
           (sekka-symspell--index-key key sekka-symspell-index sekka-symspell-dict-set)))
       sekka-user-jisyo-hash))
    (setq sekka-symspell-building nil)
    (setq sekka-symspell-ready t)
    (sekka-jisyo--build-jarowinkler-index)
    (message "Sekka: SymSpell/Jaro-Winklerインデックス構築完了")))

(defun sekka-jisyo--schedule-symspell-build ()
  "SymSpellインデックス構築をアイドル時にインクリメンタルに実行する.
チャンク分割でEmacsの操作をブロックしない."
  (message "Sekka: SymSpellインデックスはアイドル時に構築します (完全一致検索は即座に利用可能)")
  (run-with-idle-timer
   2 nil
   (lambda ()
     (when (and sekka-jisyo-loaded (not sekka-symspell-ready) (not sekka-symspell-building))
       (setq sekka-symspell-building t)
       (sekka-symspell-build-index-incremental
        sekka-jisyo-hash
        (lambda ()
          ;; ユーザー辞書のキーもSymSpellインデックスに追加
          (when (> (hash-table-count sekka-user-jisyo-hash) 0)
            (maphash
             (lambda (key _val)
               (unless (gethash key sekka-symspell-dict-set)
                 (sekka-symspell--index-key key sekka-symspell-index sekka-symspell-dict-set)))
             sekka-user-jisyo-hash))
          (setq sekka-symspell-building nil)
          (setq sekka-symspell-ready t)
          (sekka-jisyo--build-jarowinkler-index)
          (message "Sekka: SymSpell/Jaro-Winklerインデックス構築完了")))))))


;;; ============================================================
;;; 辞書検索
;;; ============================================================

(defun sekka-jisyo-get (key)
  "KEY で辞書を検索し、候補文字列を返す.
ユーザー辞書を優先、なければメイン辞書を参照. 見つからなければ nil."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  (or (gethash key sekka-user-jisyo-hash)
      (gethash key sekka-jisyo-hash)))

(defun sekka-jisyo-get-list (key)
  "KEY で辞書を検索し、候補をリストで返す.
見つからなければ nil."
  (let ((val (sekka-jisyo-get key)))
    (when val
      (sekka-jisyo--split-candidates val))))

(defun sekka-jisyo--okuri-key-score (key query-is-kana)
  "送りあり辞書キーのソートスコアを返す.
QUERY-IS-KANA が non-nil の場合、送りありキーを後回しにする(スコア1)."
  (if (and query-is-kana
           (sekka-jisyo--okuri-key-p key))
      1
    0))

(defun sekka-jisyo-approximate-search (query &optional max-results)
  "QUERY に対して曖昧検索(SymSpell, edit distance ≤ 1)を行う.
結果は ((distance key value) ...) のリスト(距離昇順).
MAX-RESULTS は辞書値を持つ候補の件数制限(SymSpell検索自体は全件取得).
クエリがひらがなの場合、送りありキーを後回しにする."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  ;; SymSpell検索は全件取得し、辞書値を持つ候補に絞ってから件数制限する
  (let ((matches (sekka-symspell-search query nil))
        (query-is-kana (string-match-p "\\`[ぁ-んっー]+\\'" query))
        (result nil))
    (dolist (m matches)
      (let* ((dist (car m))
             (key (cdr m))
             (val (sekka-jisyo-get key)))
        (when val
          (push (list dist key val) result))))
    (setq result (nreverse result))
    ;; クエリがひらがなの場合、送りありキーを後回しにソート
    (when query-is-kana
      (setq result
            (sort result
                  (lambda (a b)
                    (let ((da (nth 0 a)) (db (nth 0 b))
                          (oa (sekka-jisyo--okuri-key-score (nth 1 a) t))
                          (ob (sekka-jisyo--okuri-key-score (nth 1 b) t)))
                      (or (< da db)
                          (and (= da db) (< oa ob))))))))
    (if (and max-results (> (length result) max-results))
        (cl-subseq result 0 max-results)
      result)))

(defun sekka-jisyo-jarowinkler-search (roman-query &optional threshold max-results)
  "ローマ字 ROMAN-QUERY に対して Jaro-Winkler 曖昧検索を行う.
長い単語の後方欠落 (例: \"shizengengos\" → 自然言語処理) に強い.
結果は ((score key value) ...) のスコア降順リスト."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  (when sekka-jarowinkler-ready
    (let ((hits (sekka-jarowinkler-search roman-query threshold nil))
          (result nil))
      (dolist (h hits)
        (let* ((score (car h))
               (key (cdr h))
               (val (sekka-jisyo-get key)))
          (when val
            (push (list score key val) result))))
      (setq result (nreverse result))
      (if (and max-results (> (length result) max-results))
          (cl-subseq result 0 max-results)
        result))))


;;; ============================================================
;;; 候補のパース (アノテーション対応)
;;; ============================================================

(defun sekka-jisyo-parse-kouho (candidates-str key &optional okuri)
  "候補文字列をパースし、変換候補リストを返す.
各候補は (word annotation source type) の形式.
OKURI が指定された場合、各候補に送り仮名を付加する."
  (let ((okuri (or okuri ""))
        (entries (sekka-jisyo--split-candidates candidates-str))
        (result nil))
    (dolist (entry entries)
      (let* ((parts (split-string entry ";"))
             (word (concat (car parts) okuri))
             (annotation (when (cdr parts) (cadr parts))))
        (push (list word annotation key 'j) result)))
    (nreverse result)))


;;; ============================================================
;;; 学習 (確定順序の変更)
;;; ============================================================

(defun sekka-jisyo-kakutei (key tango)
  "確定した TANGO を KEY の候補の先頭に移動する.
ユーザー辞書に保存する.
候補順序が変更された場合は TANGO を返し、変更不要な場合は nil を返す."
  (let* ((val (sekka-jisyo-get key)))
    (when val
      (let* ((candidates (sekka-jisyo--split-candidates val))
             (tango-bare (if (and (sekka-jisyo--okuri-key-p key)
                                  (> (length tango) 0))
                             ;; 送りあり: 送り仮名を除去して比較
                             (sekka-jisyo--drop-okuri-from-tango tango)
                           tango))
             (matched (cl-remove-if-not
                       (lambda (c)
                         (let ((c-base (car (split-string c ";"))))
                           (string= c-base tango-bare)))
                       candidates))
             (others (cl-remove-if
                      (lambda (c)
                        (let ((c-base (car (split-string c ";"))))
                          (string= c-base tango-bare)))
                      candidates)))
        (when matched
          (let ((new-val (concat "/" (mapconcat #'identity
                                               (append matched others) "/")
                                 "/")))
            ;; 順序が変わった場合のみ保存する
            (unless (string= val new-val)
              (puthash key new-val sekka-user-jisyo-hash)
              (sekka-jisyo--save-user-entry key new-val)
              tango)))))))

(defun sekka-jisyo--okuri-key-p (key)
  "KEY が送りあり辞書キー(末尾がアルファベット)かどうか."
  (and (> (length key) 0)
       (let ((last-char (aref key (1- (length key)))))
         (and (>= last-char ?a) (<= last-char ?z)))))

(defun sekka-jisyo--drop-okuri-from-tango (tango)
  "送り仮名を含む単語から送り仮名を除去する.
例: \"行う\" → \"行\""
  (if (string-match "\\`\\([^ぁ-んっー]+\\)[ぁ-んっー]+\\'" tango)
      (match-string 1 tango)
    tango))

(defun sekka-jisyo--save-user-entry (key value)
  "ユーザー辞書ファイルにエントリを追記/更新する."
  (let ((entries (make-hash-table :test 'equal)))
    ;; 既存ファイルを読み込み
    (when (file-readable-p sekka-user-jisyo-file)
      (with-temp-buffer
        (insert-file-contents sekka-user-jisyo-file)
        (goto-char (point-min))
        (while (not (eobp))
          (let* ((line (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))
                 (parsed (sekka-jisyo--parse-skk-line line)))
            (when parsed
              (puthash (car parsed) (cdr parsed) entries)))
          (forward-line 1))))
    ;; エントリを更新
    (puthash key value entries)
    ;; ファイルに書き戻し
    (with-temp-file sekka-user-jisyo-file
      (maphash (lambda (k v)
                 (insert k " " v "\n"))
               entries))))

;;; ============================================================
;;; 新規単語登録
;;; ============================================================

(defun sekka-jisyo--register-jarowinkler-key (key)
  "KEY (ひらがな) を Jaro-Winkler インデックスに新規登録する.
既登録なら何もしない."
  (when sekka-jarowinkler-index
    (let ((roman (sekka-jarowinkler-hiragana->roman key)))
      (when (and (>= (length roman) (car sekka-jarowinkler-prefix-lengths))
                 (not (gethash roman sekka-jarowinkler-roman-to-hira)))
        (puthash roman key sekka-jarowinkler-roman-to-hira)
        (sekka-jarowinkler--add-to-index roman sekka-jarowinkler-index)))))

(defun sekka-jisyo-register-word (key tango)
  "KEY に TANGO を新規登録する (ユーザー辞書).
既に登録済みなら nil を返す。登録したら t を返す.
新規キーの場合は SymSpell / Jaro-Winkler インデックスも更新する."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  (let* ((existing (gethash key sekka-user-jisyo-hash))
         (candidates (if existing
                        (sekka-jisyo--split-candidates existing)
                      nil)))
    (if (member tango candidates)
        nil  ;; 既に登録済み
      (let ((new-val (concat "/" tango
                             (if candidates
                                 (concat "/" (mapconcat #'identity candidates "/"))
                               "")
                             "/")))
        (puthash key new-val sekka-user-jisyo-hash)
        (sekka-jisyo--save-user-entry key new-val)
        ;; 新規キーの場合、SymSpell/JW インデックスに追加する
        (when (not existing)
          (when sekka-symspell-index
            (sekka-symspell--index-key key sekka-symspell-index sekka-symspell-dict-set))
          (sekka-jisyo--register-jarowinkler-key key))
        t))))

(provide 'sekka-jisyo)
;;; sekka-jisyo.el ends here
