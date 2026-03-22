;;; sekka-symspell.el --- SymSpell fuzzy search for Sekka  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 Kiyoka Nishiyama
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

;; SymSpell algorithm for approximate string matching.
;; Pre-computes delete variants of dictionary keys at load time,
;; and uses hash-table lookup for O(1)-like search at query time.
;; Max edit distance = 1.

;;; Code:

(require 'cl-lib)


;;; ============================================================
;;; Levenshtein距離
;;; ============================================================

(defun sekka-symspell-levenshtein (s1 s2)
  "S1 と S2 の Levenshtein 編集距離を返す."
  (let* ((len1 (length s1))
         (len2 (length s2))
         ;; 早期リターン
         (diff (abs (- len1 len2))))
    (cond
     ((string= s1 s2) 0)
     ((= len1 0) len2)
     ((= len2 0) len1)
     ;; 長さの差が2以上なら距離も2以上 (d=1フィルタ用に高速化)
     ((> diff 1) diff)
     (t
      ;; 2行分のDPで計算
      (let ((prev (make-vector (1+ len2) 0))
            (curr (make-vector (1+ len2) 0)))
        (dotimes (j (1+ len2))
          (aset prev j j))
        (dotimes (i len1)
          (aset curr 0 (1+ i))
          (dotimes (j len2)
            (let ((cost (if (= (aref s1 i) (aref s2 j)) 0 1)))
              (aset curr (1+ j)
                    (min (1+ (aref curr j))           ;; insertion
                         (1+ (aref prev (1+ j)))      ;; deletion
                         (+ (aref prev j) cost)))))    ;; substitution
          ;; swap prev and curr
          (let ((tmp prev))
            (setq prev curr)
            (setq curr tmp)))
        (aref prev len2))))))


;;; ============================================================
;;; 削除文字列の生成
;;; ============================================================

(defun sekka-symspell--delete-variants (word)
  "WORD の全ての1文字削除バリアントのリストを返す.
例: \"abc\" → (\"bc\" \"ac\" \"ab\")"
  (let ((len (length word))
        (result nil))
    (dotimes (i len)
      (push (concat (substring word 0 i)
                    (substring word (1+ i)))
            result))
    (nreverse result)))


;;; ============================================================
;;; SymSpellインデックス
;;; ============================================================

(defvar sekka-symspell-index nil
  "SymSpell delete index.
Hash-table: delete-variant-string → list of original dictionary keys.")

(defvar sekka-symspell-dict-set nil
  "Hash-table of all indexed dictionary keys (for exact match check).")

(defun sekka-symspell-build-index (keys)
  "KEYS (文字列のリストまたはhash-table) から SymSpell インデックスを構築する.
KEYS が hash-table の場合、そのキーを使用する."
  (let ((index (make-hash-table :test 'equal :size 500000))
        (dict-set (make-hash-table :test 'equal :size 150000))
        (count 0))
    ;; キーのイテレーション
    (cond
     ((hash-table-p keys)
      (maphash
       (lambda (key _val)
         (sekka-symspell--index-key key index dict-set)
         (setq count (1+ count))
         (when (= (% count 10000) 0)
           (message "Sekka SymSpell: indexed %d keys..." count)))
       keys))
     ((listp keys)
      (dolist (key keys)
        (sekka-symspell--index-key key index dict-set)
        (setq count (1+ count)))))
    (setq sekka-symspell-index index)
    (setq sekka-symspell-dict-set dict-set)
    (message "Sekka SymSpell: index built (%d keys, %d delete entries)"
             count (hash-table-count index))
    index))

(defun sekka-symspell--index-key (key index dict-set)
  "1つの辞書キー KEY をインデックスに追加する."
  ;; 辞書キーそのものを登録
  (puthash key t dict-set)
  ;; 1文字削除バリアントを生成してインデックスに登録
  (dolist (variant (sekka-symspell--delete-variants key))
    (let ((existing (gethash variant index)))
      (unless (and existing (member key existing))
        (puthash variant (cons key existing) index)))))


;;; ============================================================
;;; 検索
;;; ============================================================

(defun sekka-symspell-search (query &optional max-results)
  "QUERY に対して編集距離1以内の辞書キーを検索する.
結果は (distance . key) のリスト(距離昇順).
MAX-RESULTS で最大件数を制限(デフォルト無制限)."
  (unless sekka-symspell-index
    (error "SymSpell index not built. Call sekka-symspell-build-index first."))
  (let ((candidates (make-hash-table :test 'equal))
        (result nil))

    ;; 1. 完全一致チェック (distance=0)
    (when (gethash query sekka-symspell-dict-set)
      (puthash query 0 candidates))

    ;; 2. query の削除バリアントが辞書キーに一致するか (distance=1, queryから1文字削除=辞書に1文字多い)
    ;;    → これは「辞書キーが query より1文字短い」ケースではなく
    ;;      「query の削除結果が辞書キーそのもの」のケース
    (dolist (variant (sekka-symspell--delete-variants query))
      (when (gethash variant sekka-symspell-dict-set)
        (unless (gethash variant candidates)
          (puthash variant 1 candidates))))

    ;; 3. query そのものがインデックス(辞書キーの削除バリアント)に一致するか
    ;;    → 辞書キーがqueryより1文字長いケース
    (let ((indexed (gethash query sekka-symspell-index)))
      (dolist (key indexed)
        (unless (gethash key candidates)
          (let ((dist (sekka-symspell-levenshtein query key)))
            (when (<= dist 1)
              (puthash key dist candidates))))))

    ;; 4. query の削除バリアントがインデックスに一致するか
    ;;    → 置換(substitution)のケース: 両者から1文字削除すると同じになる
    (dolist (variant (sekka-symspell--delete-variants query))
      (let ((indexed (gethash variant sekka-symspell-index)))
        (dolist (key indexed)
          (unless (gethash key candidates)
            (let ((dist (sekka-symspell-levenshtein query key)))
              (when (<= dist 1)
                (puthash key dist candidates)))))))

    ;; 結果をリストに変換してソート
    (maphash (lambda (key dist)
               (push (cons dist key) result))
             candidates)
    (setq result (sort result (lambda (a b) (< (car a) (car b)))))

    ;; 件数制限
    (if (and max-results (> (length result) max-results))
        (cl-subseq result 0 max-results)
      result)))

(provide 'sekka-symspell)
;;; sekka-symspell.el ends here
