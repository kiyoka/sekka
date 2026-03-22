;;; sekka-alphabet-lib.el --- Half-width/Full-width alphabet conversion for Sekka  -*- lexical-binding: t; -*-
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

(defun sekka-alphabet-han->zen (str)
  "半角ASCII(! - })を全角(！ - ｝)に変換する."
  (let ((result (make-string (length str) ?\ ))
        (i 0))
    (while (< i (length str))
      (let* ((c (aref str i))
             (zen (if (and (>= c ?!) (<= c ?}))
                      (+ c (- ?！ ?!))
                    c)))
        (aset result i zen))
      (setq i (1+ i)))
    result))

(defun sekka-alphabet-zen->han (str)
  "全角(！ - ｝)を半角ASCII(! - })に変換する."
  (let ((result (make-string (length str) ?\ ))
        (i 0))
    (while (< i (length str))
      (let* ((c (aref str i))
             (han (if (and (>= c ?！) (<= c ?｝))
                      (+ c (- ?! ?！))
                    c)))
        (aset result i han))
      (setq i (1+ i)))
    result))

(defun sekka-alphabet-zenkaku-p (str)
  "文字列が全て全角アルファベットかどうか."
  (string-match-p "\\`[！-｝]+\\'" str))

(defun sekka-alphabet-hankaku-p (str)
  "文字列が全て半角アルファベットかどうか."
  (string-match-p "\\`[!-}]+\\'" str))

(defun sekka-alphabet-include-zenkaku-p (str)
  "文字列に全角アルファベットが含まれているか."
  (string-match-p "[！-｝]+" str))

(defun sekka-alphabet-include-hankaku-p (str)
  "文字列に半角アルファベットが含まれているか."
  (string-match-p "[!-}]+" str))

(provide 'sekka-alphabet-lib)
;;; sekka-alphabet-lib.el ends here
