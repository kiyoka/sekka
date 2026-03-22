;;; sekka-henkan.el --- Conversion engine for Sekka  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2015-2024 Kiyoka Nishiyama
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
(require 'sekka-roman-lib)
(require 'sekka-alphabet-lib)
(require 'sekka-sharp-number)
(require 'sekka-jisyo)


;;; ============================================================
;;; 厳密検索 (完全一致)
;;; ============================================================

(defun sekka-henkan--exact-search (key)
  "KEY で辞書を厳密検索し、結果リストを返す.
各結果は (score key value) の形式."
  (let ((v (sekka-jisyo-get key)))
    (if v
        (list (list 1.0 key v))
      nil)))


;;; ============================================================
;;; 候補の分割・型付け
;;; ============================================================

(defun sekka-henkan--split-kouho (candidates-str src &optional okuri)
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
        (push (list word annotation src 'j) result)))
    (nreverse result)))


;;; ============================================================
;;; 送り仮名なしの変換
;;; ============================================================

(defun sekka-henkan--resolve-value (v key)
  "辞書の値 V を解決する. \"C\" で始まる間接参照を追跡する."
  (if (and v (> (length v) 0) (= (aref v 0) ?C))
      (let ((indirect (sekka-jisyo-get (substring v 1))))
        (when indirect
          (sekka-henkan--split-kouho indirect key)))
    (when v
      (sekka-henkan--split-kouho v key))))

(defun sekka-henkan--okuri-nashi (keyword limit roman-method)
  "送り仮名なしの変換(完全一致 + 曖昧検索).
KEYWORD はローマ字入力(先頭大文字除去済み)."
  (let* ((hira-list (sekka-roman->hiragana (sekka-downcase keyword) roman-method))
         (exact-result nil)
         (approx-result nil)
         (seen (make-hash-table :test 'equal)))
    ;; 1. 完全一致検索
    (dolist (hira hira-list)
      (let ((entries (sekka-henkan--resolve-value (sekka-jisyo-get hira) hira)))
        (dolist (e entries)
          (unless (gethash (car e) seen)
            (puthash (car e) t seen)
            (push e exact-result)))))
    (setq exact-result (nreverse exact-result))
    ;; 2. 曖昧検索 (各ひらがな変換結果に対して SymSpell)
    (dolist (hira hira-list)
      (let ((approx-matches (sekka-jisyo-approximate-search hira 20)))
        (dolist (m approx-matches)
          (let* ((dist (nth 0 m))
                 (key (nth 1 m))
                 (val (nth 2 m)))
            (when (> dist 0)  ;; distance 0 は完全一致で既に処理済み
              (let ((entries (sekka-henkan--resolve-value val key)))
                (dolist (e entries)
                  (unless (gethash (car e) seen)
                    (puthash (car e) t seen)
                    (push e approx-result)))))))))
    (setq approx-result (nreverse approx-result))
    ;; 完全一致を優先、曖昧検索結果を後ろに
    (let ((result (append exact-result approx-result)))
      (if (and (> limit 0) (> (length result) limit))
          (cl-subseq result 0 limit)
        result))))


;;; ============================================================
;;; 送り仮名なし + 数値の変換
;;; ============================================================

(defun sekka-henkan--okuri-nashi-and-number (keyword limit roman-method)
  "数値を含むキーワードの変換.
KEYWORD 中の数字部分を # に置換して辞書を引き、結果の #N を数値に戻す."
  (let* ((num-list nil)
         (replaced keyword))
    ;; 数字部分を抜き出して # に置換
    (while (string-match "\\([0-9]+\\)" replaced)
      (push (match-string 1 replaced) num-list)
      (setq replaced (replace-match "#" t t replaced)))
    (setq num-list (nreverse num-list))
    ;; 辞書引き
    (let* ((base-result (sekka-henkan--okuri-nashi replaced limit roman-method))
           (result nil))
      (dolist (entry base-result)
        (let* ((word (car entry))
               (type-list nil)
               (w word))
          ;; word 中の #N パターンを収集
          (while (string-match "#\\([0-9]\\)" w)
            (push (match-string 0 w) type-list)
            (setq w (substring w (match-end 0))))
          (setq type-list (nreverse type-list))
          (if (= (length num-list) (length type-list))
              ;; 数字のリストと#の個数が一致
              (let ((converted word))
                (cl-mapc
                 (lambda (type-str num-str)
                   (setq converted
                         (replace-regexp-in-string
                          (regexp-quote type-str)
                          (sekka-henkan-sharp-number type-str num-str)
                          converted t t)))
                 type-list num-list)
                (push (list converted (nth 1 entry) (nth 2 entry) 'n) result))
            ;; 不一致の場合はスキップ
            nil)))
      (nreverse result))))


;;; ============================================================
;;; 送り仮名ありの変換
;;; ============================================================

(defun sekka-henkan--okuri-ari (keyword limit roman-method)
  "送り仮名ありの変換.
KEYWORD は例えば \"okonaU\" (大文字が送り仮名の開始を示す)."
  (let ((k (concat (sekka-henkan--string-downcase-first keyword)))
        (case-fold-search nil))
    ;; パターン: stem + 大文字送り仮名開始
    (when (string-match "\\`\\([a-z]\\)\\([a-z^-]+\\)\\([A-Z`+]\\)\\([a-zA-Z]*\\)\\'" k)
      (let* ((prefix (match-string 1 k))
             (stem-body (match-string 2 k))
             (okuri-start (match-string 3 k))
             (okuri-rest (match-string 4 k))
             ;; 辞書キー用: stem + 送り仮名マーカー(小文字化)
             (dict-roman (concat prefix stem-body (sekka-downcase okuri-start)))
             ;; 送り仮名のローマ字
             (okuri-roman (sekka-downcase (concat okuri-start okuri-rest)))
             ;; ひらがなに変換
             (hira-list (sekka-roman->hiragana dict-roman roman-method))
             ;; 送り仮名をひらがなに
             (okuri-hira-list (sekka-roman->hiragana okuri-roman roman-method))
             (okuri-hira-list (if okuri-hira-list okuri-hira-list '("")))
             (result nil))
        (dolist (hira hira-list)
          ;; 末尾1文字をアルファベットに (SKK辞書の送りあり形式)
          ;; 例: "おこなu" → key="おこなu" は dict-roman の最後の子音
          ;; SKK辞書は "おこなu /行/" のような形式
          (let* ((okuri-char (sekka-downcase okuri-start))
                 (dict-key (concat (substring hira 0 (- (length hira)
                                                        (length (or (car (sekka-roman->hiragana
                                                                          okuri-char roman-method))
                                                                    ""))))
                                   (downcase okuri-start)))
                 (v (sekka-jisyo-get dict-key)))
            (when v
              (dolist (okuri-hira okuri-hira-list)
                (if (and (> (length v) 0) (= (aref v 0) ?C))
                    (let ((indirect (sekka-jisyo-get (substring v 1))))
                      (when indirect
                        (setq result (append result
                                             (sekka-henkan--split-kouho
                                              indirect dict-key okuri-hira)))))
                  (setq result (append result
                                       (sekka-henkan--split-kouho
                                        v dict-key okuri-hira))))))))
        (if (and (> limit 0) (> (length result) limit))
            (cl-subseq result 0 limit)
          result)))))


;;; ============================================================
;;; ひらがなの変換
;;; ============================================================

(defun sekka-henkan--hiragana (keyword roman-method)
  "ひらがな変換.
ローマ字→ひらがな・カタカナの候補を生成する."
  (let* ((str (sekka-downcase keyword))
         (hira-list (sekka-roman->hiragana str roman-method))
         (kata-list (sekka-roman->katakana str roman-method))
         (result nil))
    (if (null hira-list)
        ;; 変換失敗時はそのまま返す
        (list (list keyword nil keyword 'j))
      (cl-mapc
       (lambda (h k)
         (push (list h nil keyword 'h) result)
         (push (list k nil keyword 'k) result))
       hira-list kata-list)
      (nreverse result))))


;;; ============================================================
;;; アルファベットの変換
;;; ============================================================

(defun sekka-henkan--alphabet (keyword)
  "アルファベット変換(半角⇔全角)."
  (let ((zen (sekka-alphabet-han->zen keyword))
        (han (sekka-alphabet-zen->han keyword)))
    (list
     (list zen nil keyword 'z)
     (list han nil keyword 'l))))


;;; ============================================================
;;; 数字だけのキーワードの変換
;;; ============================================================

(defun sekka-henkan--number (keyword)
  "数字のみで構成されるキーワードの変換."
  (list
   (list (sekka-henkan-sharp-number "#1" keyword) nil keyword 'n)
   (list keyword nil keyword 'n)
   (list (sekka-henkan-sharp-number "#2" keyword) nil keyword 'n)
   (list (sekka-henkan-sharp-number "#3" keyword) nil keyword 'n)))


;;; ============================================================
;;; 記号を含むキーワードの変換
;;; ============================================================

(defun sekka-henkan--non-kanji (keyword)
  "記号を含むキーワードの変換(完全一致のみ)."
  (let* ((result (sekka-henkan--exact-search keyword))
         (kouho (mapcar #'cl-third result)))
    (cl-mapcan
     (lambda (value)
       (sekka-henkan--split-kouho value keyword))
     kouho)))


;;; ============================================================
;;; ユーティリティ
;;; ============================================================

(defun sekka-henkan--string-downcase-first (str)
  "文字列の先頭1文字だけを小文字にする."
  (if (> (length str) 0)
      (concat (downcase (substring str 0 1))
              (substring str 1))
    str))


;;; ============================================================
;;; メイン変換関数
;;; ============================================================

(defun sekka-henkan (keyword limit roman-method)
  "KEYWORD(ローマ字)を変換し、候補リストを返す.
LIMIT は最大候補数(0=無制限).
ROMAN-METHOD は :normal または :azik.
各候補は (word annotation source type index) の形式."
  (unless sekka-jisyo-loaded
    (sekka-jisyo-init))
  (unless sekka-roman->kana-hash-short
    (sekka-roman-lib-init))
  (let* ((keyword (string-trim keyword))
         (case-fold-search nil)  ;; 大文字小文字を区別する
         (kouho-list
          (cond
           ;; 大文字を含む → 漢字変換
           ((string-match-p "[A-Z`+]" keyword)
            (let ((k (sekka-henkan--string-downcase-first keyword)))
              (if (string-match-p "[a-z][A-Z`+]" k)
                  ;; 送りあり
                  (append
                   (sekka-henkan--okuri-ari k limit roman-method)
                   (let ((down (sekka-downcase k)))
                     (if (sekka-roman->hiragana down roman-method)
                         (sekka-henkan--hiragana down roman-method)
                       nil))
                   (sekka-henkan--alphabet keyword))
                ;; 送りなし
                (append
                 (sekka-henkan--okuri-nashi k limit roman-method)
                 (let ((down (sekka-downcase k)))
                   (if (sekka-roman->hiragana down roman-method)
                       (sekka-henkan--hiragana down roman-method)
                     nil))
                 (sekka-henkan--alphabet keyword)))))

           ;; 数字のみ
           ((string-match-p "\\`[0-9]+\\'" keyword)
            (sekka-henkan--number keyword))

           ;; 数字で始まるキーワード
           ((string-match-p "\\`[0-9]+[0-9a-zA-Z@;-]+\\'" keyword)
            (append
             (sekka-henkan--okuri-nashi-and-number keyword limit roman-method)
             (sekka-henkan--alphabet keyword)))

           ;; ひらがなに変換可能
           ((sekka-roman->hiragana keyword roman-method)
            (append
             (sekka-henkan--hiragana keyword roman-method)
             (sekka-henkan--alphabet keyword)
             (sekka-henkan--okuri-nashi keyword limit roman-method)))

           ;; その他
           (t
            (append
             (sekka-henkan--non-kanji keyword)
             (sekka-henkan--alphabet keyword))))))

    ;; 候補にindex番号を付加
    (let ((idx 0))
      (mapcar
       (lambda (entry)
         (prog1
             (append entry (list idx))
           (setq idx (1+ idx))))
       kouho-list))))

(provide 'sekka-henkan)
;;; sekka-henkan.el ends here
