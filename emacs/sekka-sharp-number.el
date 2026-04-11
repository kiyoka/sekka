;;; sekka-sharp-number.el --- Kanji numeral conversion for Sekka  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2011-2014 Kiyoka Nishiyama
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

;; Kanji numeral conversion (e.g., 123 -> 百二十三) for Sekka.

;;; Code:

(require 'sekka-alphabet-lib)

(defconst sekka-kanji-digits ["〇" "一" "二" "三" "四" "五" "六" "七" "八" "九"])
(defconst sekka-kurai1 ["□" "十" "百" "千"])
(defconst sekka-kurai2 ["" "万" "億" "兆" "京"])

(defun sekka-henkan-kansuuji-sen (num-str)
  "4桁以内の数値文字列を位取り漢数字に変換する."
  (let* ((digits (nreverse (mapcar #'string-to-number
                                   (split-string num-str "" t))))
         (parts nil)
         (i 0))
    (dolist (d digits)
      (let ((kurai (aref sekka-kurai1 i)))
        (push
         (cond
          ((= d 0) "")
          ((= d 1)
           (if (string= kurai "□")
               (aref sekka-kanji-digits d)
             kurai))
          (t
           (if (string= kurai "□")
               (aref sekka-kanji-digits d)
             (concat (aref sekka-kanji-digits d) kurai))))
         parts))
      (setq i (1+ i)))
    (mapconcat #'identity parts "")))

(defun sekka-henkan-kansuuji (num-str)
  "任意桁の数値文字列を位取り漢数字(万億兆京)に変換する."
  (let* ((reversed (reverse (string-to-list num-str)))
         (groups nil)
         (current nil))
    ;; 4桁ずつグループ化(下位から)
    (let ((i 0))
      (dolist (c reversed)
        (push c current)
        (setq i (1+ i))
        (when (= (mod i 4) 0)
          (push (apply #'string current) groups)
          (setq current nil)))
      (when current
        (push (apply #'string current) groups)))
    ;; groups は下位→上位の順(pushしたので逆順=上位→下位になっているのでnreverse)
    ;; nreverse で 下位→上位 の順に戻す
    (setq groups (nreverse groups))
    ;; groups[0] = 下位4桁(一の位), groups[1] = 万の位, ...
    ;; kurai2[0] = "", kurai2[1] = "万", ...
    (let ((parts nil)
          (gi 0))
      (dolist (g groups)
        (if (string-match-p "\\`0+\\'" g)
            nil
          (push (concat (sekka-henkan-kansuuji-sen g)
                        (aref sekka-kurai2 gi))
                parts))
        (setq gi (1+ gi)))
      (mapconcat #'identity parts ""))))

(defun sekka-henkan-sharp-number (type-str num-str)
  "#1〜#3のタイプに応じて数値文字列を変換する.
#1: 半角→全角数字
#2: 各桁を漢数字に置換(位なし)
#3: 位取り漢数字"
  (cond
   ((string= type-str "#1")
    (sekka-alphabet-han->zen num-str))
   ((string= type-str "#2")
    (let ((result "")
          (i 0))
      (while (< i (length num-str))
        (let ((d (- (aref num-str i) ?0)))
          (setq result (concat result (aref sekka-kanji-digits d))))
        (setq i (1+ i)))
      result))
   ((string= type-str "#3")
    (sekka-henkan-kansuuji num-str))
   (t num-str)))

(provide 'sekka-sharp-number)
;;; sekka-sharp-number.el ends here
