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

;;; Code:

(require 'cl-lib)
(require 'sekka-symspell)

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


;;; ============================================================
;;; SKK辞書ファイルの読み込み
;;; ============================================================

(defun sekka-jisyo--parse-skk-line (line)
  "SKK辞書の1行をパースし (key . value) を返す.
コメント行やパース不能な行は nil."
  (when (and (> (length line) 0)
             (not (= (aref line 0) ?\;)))
    (let ((space-pos (string-search " " line)))
      (when space-pos
        (cons (substring line 0 space-pos)
              (substring line (1+ space-pos)))))))

(defun sekka-jisyo-load-file (file hash)
  "SKK-JISYO形式のファイル FILE を hash-table HASH に読み込む.
既存エントリがあれば候補をマージする."
  (when (file-readable-p file)
    (with-temp-buffer
      (insert-file-contents file)
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

(defun sekka-jisyo-default-file-list ()
  "デフォルトの辞書ファイルリストを返す."
  (let ((data-dir (expand-file-name
                   "data"
                   (file-name-directory
                    (or (locate-library "sekka-jisyo")
                        (file-name-directory
                         (or load-file-name buffer-file-name "")))))))
    (cl-remove-if-not
     #'file-exists-p
     (list
      (expand-file-name "SKK-JISYO.L.201501" data-dir)
      (expand-file-name "SKK-JISYO.L.hira-kata" data-dir)
      (expand-file-name "SKK-JISYO.jinmei" data-dir)
      (expand-file-name "SKK-JISYO.station" data-dir)
      (expand-file-name "SKK-JISYO.fullname" data-dir)))))

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
  ;; SymSpellインデックスの構築
  (message "Sekka: SymSpellインデックスを構築中...")
  (sekka-symspell-build-index sekka-jisyo-hash))


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

(defun sekka-jisyo-approximate-search (query &optional max-results)
  "QUERY に対して曖昧検索(SymSpell, edit distance ≤ 1)を行う.
結果は ((distance key value) ...) のリスト(距離昇順)."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  (let ((matches (sekka-symspell-search query max-results))
        (result nil))
    (dolist (m matches)
      (let* ((dist (car m))
             (key (cdr m))
             (val (sekka-jisyo-get key)))
        (when val
          (push (list dist key val) result))))
    (nreverse result)))


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
ユーザー辞書に保存する."
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
            (puthash key new-val sekka-user-jisyo-hash)
            (sekka-jisyo--save-user-entry key new-val)
            tango))))))

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

(provide 'sekka-jisyo)
;;; sekka-jisyo.el ends here
