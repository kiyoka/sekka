;;; sekka-jarowinkler.el --- Jaro-Winkler fuzzy search for Sekka  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2010-2026 Kiyoka Nishiyama
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

;; Jaro-Winkler similarity based fuzzy search, complementing SymSpell.
;; Used for long-word typo tolerance and prefix-weighted matching that
;; matches typing behavior.  Candidate generation uses a 2-char prefix
;; bucket over canonical Hepburn romaji forms of hiragana dictionary
;; keys.  Query is the raw romaji input from the user.

;;; Code:

(require 'cl-lib)


;;; ============================================================
;;; Jaro-Winkler 距離
;;; ============================================================

(defun sekka-jarowinkler--jaro (s1 s2)
  "S1 と S2 の Jaro 類似度を返す (0.0〜1.0)."
  (let ((len1 (length s1))
        (len2 (length s2)))
    (cond
     ((and (= len1 0) (= len2 0)) 1.0)
     ((or  (= len1 0) (= len2 0)) 0.0)
     (t
      (let* ((match-distance (max 0 (1- (/ (max len1 len2) 2))))
             (s1-matches (make-bool-vector len1 nil))
             (s2-matches (make-bool-vector len2 nil))
             (matches 0)
             (transpositions 0))
        ;; 一致文字を数える
        (dotimes (i len1)
          (let ((start (max 0 (- i match-distance)))
                (end   (min (+ i match-distance 1) len2))
                (found nil)
                (j nil))
            (setq j start)
            (while (and (not found) (< j end))
              (if (and (not (aref s2-matches j))
                       (= (aref s1 i) (aref s2 j)))
                  (progn
                    (aset s1-matches i t)
                    (aset s2-matches j t)
                    (setq matches (1+ matches))
                    (setq found t))
                (setq j (1+ j))))))
        (if (= matches 0)
            0.0
          ;; 転置を数える
          (let ((k 0))
            (dotimes (i len1)
              (when (aref s1-matches i)
                (while (not (aref s2-matches k))
                  (setq k (1+ k)))
                (unless (= (aref s1 i) (aref s2 k))
                  (setq transpositions (1+ transpositions)))
                (setq k (1+ k)))))
          (let ((m (float matches)))
            (/ (+ (/ m len1)
                  (/ m len2)
                  (/ (- m (/ transpositions 2.0)) m))
               3.0))))))))

(defun sekka-jarowinkler-similarity (s1 s2)
  "S1 と S2 の Jaro-Winkler 類似度を返す (0.0〜1.0).
プレフィックス最大4文字、スケーリング係数 0.1."
  (let ((jaro (sekka-jarowinkler--jaro s1 s2)))
    (if (= jaro 0.0)
        0.0
      (let* ((max-prefix 4)
             (prefix-len 0)
             (limit (min max-prefix (min (length s1) (length s2))))
             (i 0)
             (done nil))
        (while (and (not done) (< i limit))
          (if (= (aref s1 i) (aref s2 i))
              (progn (setq prefix-len (1+ prefix-len))
                     (setq i (1+ i)))
            (setq done t)))
        (+ jaro (* prefix-len 0.1 (- 1.0 jaro)))))))


;;; ============================================================
;;; ひらがな → 正準 Hepburn ローマ字
;;; ============================================================

(defconst sekka-jarowinkler--kana-to-hepburn-alist
  '(;; 小書き
    ("ぁ" . "a") ("ぃ" . "i") ("ぅ" . "u") ("ぇ" . "e") ("ぉ" . "o")
    ("ゃ" . "ya") ("ゅ" . "yu") ("ょ" . "yo") ("ゎ" . "wa")
    ;; あ行
    ("あ" . "a") ("い" . "i") ("う" . "u") ("え" . "e") ("お" . "o")
    ;; か行
    ("か" . "ka") ("き" . "ki") ("く" . "ku") ("け" . "ke") ("こ" . "ko")
    ("きゃ" . "kya") ("きゅ" . "kyu") ("きょ" . "kyo") ("きぇ" . "kye")
    ;; が行
    ("が" . "ga") ("ぎ" . "gi") ("ぐ" . "gu") ("げ" . "ge") ("ご" . "go")
    ("ぎゃ" . "gya") ("ぎゅ" . "gyu") ("ぎょ" . "gyo") ("ぎぇ" . "gye")
    ;; さ行
    ("さ" . "sa") ("し" . "shi") ("す" . "su") ("せ" . "se") ("そ" . "so")
    ("しゃ" . "sha") ("しゅ" . "shu") ("しょ" . "sho") ("しぇ" . "she")
    ;; ざ行
    ("ざ" . "za") ("じ" . "ji") ("ず" . "zu") ("ぜ" . "ze") ("ぞ" . "zo")
    ("じゃ" . "ja") ("じゅ" . "ju") ("じょ" . "jo") ("じぇ" . "je")
    ;; た行
    ("た" . "ta") ("ち" . "chi") ("つ" . "tsu") ("て" . "te") ("と" . "to")
    ("ちゃ" . "cha") ("ちゅ" . "chu") ("ちょ" . "cho") ("ちぇ" . "che")
    ("てぃ" . "ti") ("とぅ" . "tu")
    ;; だ行
    ("だ" . "da") ("ぢ" . "ji") ("づ" . "zu") ("で" . "de") ("ど" . "do")
    ("でぃ" . "di") ("どぅ" . "du")
    ;; な行
    ("な" . "na") ("に" . "ni") ("ぬ" . "nu") ("ね" . "ne") ("の" . "no")
    ("にゃ" . "nya") ("にゅ" . "nyu") ("にょ" . "nyo") ("にぇ" . "nye")
    ;; は行
    ("は" . "ha") ("ひ" . "hi") ("ふ" . "fu") ("へ" . "he") ("ほ" . "ho")
    ("ひゃ" . "hya") ("ひゅ" . "hyu") ("ひょ" . "hyo") ("ひぇ" . "hye")
    ("ふぁ" . "fa") ("ふぃ" . "fi") ("ふぇ" . "fe") ("ふぉ" . "fo")
    ;; ば行
    ("ば" . "ba") ("び" . "bi") ("ぶ" . "bu") ("べ" . "be") ("ぼ" . "bo")
    ("びゃ" . "bya") ("びゅ" . "byu") ("びょ" . "byo") ("びぇ" . "bye")
    ;; ぱ行
    ("ぱ" . "pa") ("ぴ" . "pi") ("ぷ" . "pu") ("ぺ" . "pe") ("ぽ" . "po")
    ("ぴゃ" . "pya") ("ぴゅ" . "pyu") ("ぴょ" . "pyo") ("ぴぇ" . "pye")
    ;; ま行
    ("ま" . "ma") ("み" . "mi") ("む" . "mu") ("め" . "me") ("も" . "mo")
    ("みゃ" . "mya") ("みゅ" . "myu") ("みょ" . "myo") ("みぇ" . "mye")
    ;; や行
    ("や" . "ya") ("ゆ" . "yu") ("よ" . "yo")
    ;; ら行
    ("ら" . "ra") ("り" . "ri") ("る" . "ru") ("れ" . "re") ("ろ" . "ro")
    ("りゃ" . "rya") ("りゅ" . "ryu") ("りょ" . "ryo") ("りぇ" . "rye")
    ;; わ行
    ("わ" . "wa") ("ゐ" . "wi") ("ゑ" . "we") ("を" . "wo")
    ;; ヴ行
    ("う゛" . "vu") ("う゛ぁ" . "va") ("う゛ぃ" . "vi")
    ("う゛ぇ" . "ve") ("う゛ぉ" . "vo")
    ;; 長音・その他
    ("ー" . "-"))
  "ひらがな → Hepburn ローマ字の正準マッピング (1段階).")

(defvar sekka-jarowinkler--kana-hash nil
  "ひらがな → Hepburn 変換用の hash-table.")

(defun sekka-jarowinkler--init-kana-hash ()
  "正準ローマ字変換用の hash-table を初期化する."
  (unless sekka-jarowinkler--kana-hash
    (let ((h (make-hash-table :test 'equal :size 256)))
      (dolist (pair sekka-jarowinkler--kana-to-hepburn-alist)
        (puthash (car pair) (cdr pair) h))
      (setq sekka-jarowinkler--kana-hash h))))

(defun sekka-jarowinkler-hiragana->roman (hiragana)
  "HIRAGANA を正準 Hepburn ローマ字文字列に変換する.
`ん` は `n` 単独、`っ` は次の子音を重ねる.
未知文字はそのまま残す (非ひらがな混入時のフォールバック)."
  (sekka-jarowinkler--init-kana-hash)
  (let ((h sekka-jarowinkler--kana-hash)
        (len (length hiragana))
        (pos 0)
        (result nil)
        (pending-sokuon nil))
    (while (< pos len)
      (let* ((remain (- len pos))
             (c1 (aref hiragana pos))
             ;; ん
             (is-n (= c1 ?ん))
             ;; っ
             (is-sokuon (= c1 ?っ)))
        (cond
         (is-n
          (push "n" result)
          (setq pos (1+ pos)))
         (is-sokuon
          (setq pending-sokuon t)
          (setq pos (1+ pos)))
         (t
          ;; 2文字組合せ (拗音等) を優先して試す
          (let* ((s2 (and (>= remain 2) (substring hiragana pos (+ pos 2))))
                 (m2 (and s2 (gethash s2 h)))
                 (s1 (substring hiragana pos (1+ pos)))
                 (m1 (gethash s1 h)))
            (cond
             (m2
              (when pending-sokuon
                ;; Hepburn: sokuon + ch* → t
                (push (if (string-prefix-p "ch" m2) "t" (substring m2 0 1))
                      result)
                (setq pending-sokuon nil))
              (push m2 result)
              (setq pos (+ pos 2)))
             (m1
              (when pending-sokuon
                (push (substring m1 0 1) result)
                (setq pending-sokuon nil))
              (push m1 result)
              (setq pos (1+ pos)))
             (t
              ;; 未知文字はそのまま残す
              (push (string c1) result)
              (setq pos (1+ pos))
              (setq pending-sokuon nil))))))))
    (when pending-sokuon
      (push "t" result))
    (apply #'concat (nreverse result))))


;;; ============================================================
;;; プレフィックスブロッキング・インデックス
;;; ============================================================

(defvar sekka-jarowinkler-index nil
  "プレフィックス (長さ 2/3/4) → (roman ...) のリスト hash-table.
短い query 用のフォールバック互換で、全プレフィックス長のエントリを同居させる.")

(defvar sekka-jarowinkler-roman-to-hira nil
  "正準ローマ字 → ひらがなキー の hash-table (重複排除のついでに).")

(defconst sekka-jarowinkler-prefix-lengths '(2 3 4)
  "ブロッキングに使う先頭文字数の一覧 (小→大).")

(defconst sekka-jarowinkler-prefix-length 2
  "従来互換: 最小プレフィックス長 (テスト・外部参照用).")

(defun sekka-jarowinkler--add-to-index (roman index)
  "ROMAN を全プレフィックス長 (2/3/4) で INDEX に登録する."
  (dolist (plen sekka-jarowinkler-prefix-lengths)
    (when (>= (length roman) plen)
      (let ((prefix (substring roman 0 plen)))
        (puthash prefix (cons roman (gethash prefix index)) index)))))

(defun sekka-jarowinkler-build-index (hira-keys)
  "HIRA-KEYS (ひらがなキーのリストまたは hash-table) から
Jaro-Winkler 用のプレフィックスインデックスを構築する.
プレフィックス長 2/3/4 の全ての長さでインデックスを作成する."
  (sekka-jarowinkler--init-kana-hash)
  (let ((index (make-hash-table :test 'equal :size 16384))
        (roman-map (make-hash-table :test 'equal :size 200000))
        (count 0))
    (cl-labels
        ((process (hkey)
           (when (and (stringp hkey) (> (length hkey) 0))
             (let ((roman (sekka-jarowinkler-hiragana->roman hkey)))
               (when (>= (length roman) (car sekka-jarowinkler-prefix-lengths))
                 (puthash roman hkey roman-map)
                 (sekka-jarowinkler--add-to-index roman index)
                 (setq count (1+ count)))))))
      (cond
       ((hash-table-p hira-keys)
        (maphash (lambda (k _v) (process k)) hira-keys))
       ((listp hira-keys)
        (dolist (k hira-keys) (process k)))))
    (setq sekka-jarowinkler-index index)
    (setq sekka-jarowinkler-roman-to-hira roman-map)
    (message "Sekka JW: index built (%d romaji keys, %d prefix buckets)"
             count (hash-table-count index))
    index))


;;; ============================================================
;;; 検索
;;; ============================================================

(defconst sekka-jarowinkler-default-threshold 0.94
  "Jaro-Winkler 類似度のデフォルト閾値.")

(defun sekka-jarowinkler--length-ok-p (qlen clen)
  "長さ差で高速に候補を足切りする.
Jaro-Winkler ≥ 0.94 を満たす可能性がない組合せは除外する.
JW の上界はおおよそ Jaro に近く、Jaro ≤ (m/qlen + m/clen + 1)/3 ≤
(min/qlen + min/clen + 1)/3.  これが 0.94 を超えるには
min/max ≥ 0.72 程度が必要 (=長さ差 28% 以内)."
  (let ((mn (min qlen clen))
        (mx (max qlen clen)))
    (and (> mn 0)
         (>= (* 100 mn) (* 70 mx)))))

(defun sekka-jarowinkler--pick-prefix-length (qlen)
  "クエリ長 QLEN に応じた適応型プレフィックス長を返す.
長いクエリほど厳しいプレフィックス一致を要求してバケットサイズを抑える."
  (cond
   ((>= qlen 11) 4)
   ((>= qlen 7) 3)
   (t 2)))

(defun sekka-jarowinkler-search (query &optional threshold max-results)
  "QUERY (ローマ字文字列) に対して Jaro-Winkler 曖昧検索を行う.
結果は ((score . hira-key) ...) のスコア降順リスト.
THRESHOLD のデフォルトは `sekka-jarowinkler-default-threshold`.
MAX-RESULTS は最大件数制限 (省略時は無制限)."
  (when (and sekka-jarowinkler-index
             (stringp query)
             (>= (length query) sekka-jarowinkler-prefix-length))
    (let* ((th (or threshold sekka-jarowinkler-default-threshold))
           (q (downcase query))
           (qlen (length q))
           (plen (sekka-jarowinkler--pick-prefix-length qlen))
           (prefix (substring q 0 plen))
           (candidates (gethash prefix sekka-jarowinkler-index))
           (result nil))
      (dolist (roman candidates)
        (when (sekka-jarowinkler--length-ok-p qlen (length roman))
          (let ((score (sekka-jarowinkler-similarity q roman)))
            (when (>= score th)
              (let ((hkey (gethash roman sekka-jarowinkler-roman-to-hira)))
                (when hkey
                  (push (cons score hkey) result)))))))
      (setq result (sort result (lambda (a b) (> (car a) (car b)))))
      ;; 同じひらがなキーの重複を排除 (異なるローマ字でスコアが出ることがある)
      (let ((seen (make-hash-table :test 'equal))
            (uniq nil))
        (dolist (item result)
          (unless (gethash (cdr item) seen)
            (puthash (cdr item) t seen)
            (push item uniq)))
        (setq result (nreverse uniq)))
      (if (and max-results (> (length result) max-results))
          (cl-subseq result 0 max-results)
        result))))


(provide 'sekka-jarowinkler)
;;; sekka-jarowinkler.el ends here
