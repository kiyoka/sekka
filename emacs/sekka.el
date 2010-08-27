;;;-*- mode: lisp-interaction; syntax: elisp ; coding: iso-2022-jp -*-"
;;
;; "sekka.el" is a client for Sekka server
;;
;;   Copyright (C) 2010 Kiyoka Nishiyama
;;   This program was derived from sumibi.el and yc.el-4.0.13(auther: knak)
;;
;;
;; This file is part of Sekka
;;
;; Sekka is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; Sumibi is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with Sumibi; see the file COPYING.
;;
;;

;;;     $BG[I[>r7o(B: GPL
;;; $B:G?7HGG[I[85(B: 
;;; 
;;; $BITL@$JE@$d2~A1$7$?$$E@$,$"$l$P(BSumibi$B$N%a!<%j%s%0%j%9%H$K;22C$7$F%U%#!<%I%P%C%/$r$*$M$,$$$7$^$9!#(B
;;;
;;; $B$^$?!"(BSekka$B$K6=L#$r;}$C$F$$$?$@$$$?J}$O$I$J$?$G$b(B
;;; $B5$7Z$K%W%m%8%'%/%H$K$4;22C$/$@$5$$!#(B
;;;
;;;

;;; Code:

(require 'cl)

;;; 
;;;
;;; customize variables
;;;
(defgroup sekka nil
  "Sekka client."
  :group 'input-method
  :group 'Japanese)

(defcustom sekka-server-url "http://localhost:9292/henkan/"
  "Sekka$B%5!<%P!<$N(BURL$B$r;XDj$9$k!#(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-server-use-cert nil
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N(BSSL$B>ZL@=q$r;H$&$+$I$&$+!#(B"
  :type  'symbol
  :group 'sekka)

(defcustom sekka-server-timeout 10
  "Sekka$B%5!<%P!<$HDL?.$9$k;~$N%?%$%`%"%&%H$r;XDj$9$k!#(B($BIC?t(B)"
  :type  'integer
  :group 'sekka)
 
(defcustom sekka-stop-chars ";:(){}<> "
  "*$B4A;zJQ49J8;zNs$r<h$j9~$`;~$KJQ49HO0O$K4^$a$J$$J8;z$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-curl "curl"
  "curl$B%3%^%s%I$N@dBP%Q%9$r@_Dj$9$k(B"
  :type  'string
  :group 'sekka)

(defcustom sekka-use-viper nil
  "*Non-nil $B$G$"$l$P!"(BVIPER $B$KBP1~$9$k(B"
  :type 'boolean
  :group 'sekka)

(defcustom sekka-realtime-guide-running-seconds 60
  "$B%j%"%k%?%$%`%,%$%II=<($N7QB3;~4V(B($BIC?t(B)$B!&%<%m$G%,%$%II=<(5!G=$,L58z$K$J$k(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-interval  0.5
  "$B%j%"%k%?%$%`%,%$%II=<($r99?7$9$k;~4V4V3V(B"
  :type  'integer
  :group 'sekka)

(defcustom sekka-history-filename  "~/.sekka_history"
  "$B%f!<%6!<8GM-$NJQ49MzNr$rJ]B8$9$k%U%!%$%kL>(B"
  :type  'string
  :group 'sekka)


(defface sekka-guide-face
  '((((class color) (background light)) (:background "#E0E0E0" :foreground "#F03030")))
  "$B%j%"%k%?%$%`%,%$%I$N%U%'%$%9(B($BAu>~!"?'$J$I$N;XDj(B)"
  :group 'sekka)


(defvar sekka-mode nil             "$B4A;zJQ49%H%0%kJQ?t(B")
(defvar sekka-mode-line-string     " Sekka")
(defvar sekka-select-mode nil      "$B8uJdA*Br%b!<%IJQ?t(B")
(or (assq 'sekka-mode minor-mode-alist)
    (setq minor-mode-alist (cons
			    '(sekka-mode        sekka-mode-line-string)
			    minor-mode-alist)))


;; $B%m!<%^;z4A;zJQ49;~!"BP>]$H$9$k%m!<%^;z$r@_Dj$9$k$?$a$NJQ?t(B
(defvar sekka-skip-chars "a-zA-Z0-9.,\\-+!\\[\\]?")
(defvar sekka-mode-map        (make-sparse-keymap)         "$B4A;zJQ49%H%0%k%^%C%W(B")
(defvar sekka-select-mode-map (make-sparse-keymap)         "$B8uJdA*Br%b!<%I%^%C%W(B")
(defvar sekka-rK-trans-key "\C-j"
  "*$B4A;zJQ49%-!<$r@_Dj$9$k(B")
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list (cons 'sekka-mode         sekka-mode-map)
			(cons 'sekka-select-mode  sekka-select-mode-map))
		  minor-mode-map-alist)))

;;;
;;; hooks
;;;
(defvar sekka-mode-hook nil)
(defvar sekka-select-mode-hook nil)
(defvar sekka-select-mode-end-hook nil)

(defconst sekka-kind-index   0)
(defconst sekka-tango-index  1)
(defconst sekka-id-index     2)
(defconst sekka-wordno-index 3)
(defconst sekka-candno-index 4)
(defconst sekka-spaces-index 5)


;;--- $B%G%P%C%0%a%C%;!<%8=PNO(B
(defvar sekka-psudo-server nil)         ; $B%/%i%$%"%s%HC1BN$G2>A[E*$K%5!<%P!<$K@\B3$7$F$$$k$h$&$K$7$F%F%9%H$9$k%b!<%I(B

;;--- $B%G%P%C%0%a%C%;!<%8=PNO(B
(defvar sekka-debug nil)		; $B%G%P%C%0%U%i%0(B
(defun sekka-debug-print (string)
  (if sekka-debug
      (let
	  ((buffer (get-buffer-create "*sekka-debug*")))
	(with-current-buffer buffer
	  (goto-char (point-max))
	  (insert string)))))


;;; sekka basic output
(defvar sekka-fence-start nil)          ; fence $B;OC<0LCV(B
(defvar sekka-fence-end nil)            ; fence $B=*C<0LCV(B
(defvar sekka-henkan-separeter " ")     ; fence mode separeter
(defvar sekka-henkan-buffer nil)        ; $BI=<(MQ%P%C%U%!(B
(defvar sekka-henkan-length nil)        ; $BI=<(MQ%P%C%U%!D9(B
(defvar sekka-henkan-revpos nil)        ; $BJ8@a;OC<0LCV(B
(defvar sekka-henkan-revlen nil)        ; $BJ8@aD9(B

;;; sekka basic local
(defvar sekka-cand-cur 0)               ; $B%+%l%s%H8uJdHV9f(B
(defvar sekka-cand-cur-backup 0)        ; $B%+%l%s%H8uJdHV9f(B(UNDO$BMQ$KB`Hr$9$kJQ?t(B)
(defvar sekka-cand-len nil)             ; $B8uJd?t(B
(defvar sekka-last-fix "")              ; $B:G8e$K3NDj$7$?J8;zNs(B
(defvar sekka-henkan-kouho-list nil)    ; $BJQ497k2L%j%9%H(B($B%5!<%P$+$i5"$C$F$-$?%G!<%?$=$N$b$N(B)
(defvar sekka-markers '())              ; $BJ8@a3+;O!"=*N;0LCV$N(Bpair: $B<!$N$h$&$J7A<0(B ( 1 . 2 )
(defvar sekka-timer    nil)             ; $B%$%s%?!<%P%k%?%$%^!<7?JQ?t(B
(defvar sekka-timer-rest  0)            ; $B$"$H2?2s8F=P$5$l$?$i!"%$%s%?!<%P%k%?%$%^$N8F=P$r;_$a$k$+(B
(defvar sekka-guide-overlay   nil)      ; $B%j%"%k%?%$%`%,%$%I$K;HMQ$9$k%*!<%P!<%l%$(B
(defvar sekka-last-request-time 0)      ; Sekka$B%5!<%P!<$K%j%/%(%9%H$7$?:G8e$N;~9o(B($BC10L$OIC(B)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $BI=<(7O4X?t72(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar sekka-use-fence t)
(defvar sekka-use-color nil)

(defvar sekka-init nil)
(defvar sekka-server-cert-file nil)

;;
;; $B=i4|2=(B
;;
(defun sekka-init ()
  ;; $B:G=i$N(B n $B7o$N%j%9%H$r<hF@$9$k(B
  (defun sekka-take (arg-list n)
    (let ((lst '()))
      (dotimes (i n (reverse lst))
        (let ((item (nth i arg-list)))
	  (when item
	    (push item lst))))))
  
  (when (not sekka-init)
    ;; Emacs$B=*N;;~$N=hM}(B
    (add-hook 'kill-emacs-hook
	      (lambda ()
		;; $B2?$b$9$k$3$H$OL5$$(B
		t))
    ;; $B=i4|2=40N;(B
    (setq sekka-init t)))

;;
;; $B%m!<%^;z$G=q$+$l$?J8>O$r(BSekka$B%5!<%P!<$r;H$C$FJQ49$9$k(B
;;


(defun sekka-rest-request (func-name query)
  (if sekka-psudo-server
      ;; $B%/%i%$%"%s%HC1BN$G2>A[E*$K%5!<%P!<$K@\B3$7$F$$$k$h$&$K$7$F%F%9%H$9$k%b!<%I(B
      ;;"((\"$B%Q%$%J%C%W%k(B\" nil \"$B$Q$$$J$C$W$k(B\") (\"$B$Q$$$J$C$W$k(B\" nil \"$B$Q$$$J$C$W$k(B\"))"
      "((\"$BJQ49(B\" nil \"$B$X$s$+$s(B\") (\"$BJQ2=(B\" nil \"$B$X$s$+(B\"))"
    ;; $B<B:]$N%5!<%P$K@\B3$9$k(B
    (let ((command
	   (concat
	    sekka-curl " --silent --show-error "
	    (format " --max-time %d " sekka-server-timeout)
	    " --insecure "
	    " --header 'Content-Type: application/x-www-form-urlencoded' "
	    (format "%s " sekka-server-url)
	    (format "--data '%s=%s' " func-name query))))

      (sekka-debug-print (format "curl-command :%s\n" command))
      
      (let (
	    (result
	     (shell-command-to-string
	      command)))
	
	(sekka-debug-print (format "curl-result-sexp :%s\n" result))
	result))))
      
;;
;; $B8=:_;~9o$r(BUNIX$B%?%$%`$rJV$9(B($BC10L$OIC(B)
;;
(defun sekka-current-unixtime ()
  (let (
	(_ (current-time)))
    (+
     (* (car _)
	65536)
     (cadr _))))


;;
;; $B%m!<%^;z$G=q$+$l$?J8>O$r(BSekka$B%5!<%P!<$r;H$C$FJQ49$9$k(B
;;
(defun sekka-henkan-request (yomi)
  (sekka-debug-print (format "henkan-input :[%s]\n"  yomi))

  (message "Requesting to sekka server...")
  
  (let (
	(result (sekka-rest-request "query" yomi)))
    (sekka-debug-print (format "henkan-result:%S\n" result))
    (if (eq (string-to-char result) ?\( )
	(progn
	  (message nil)
	  (condition-case err
	      (read result)
	    (end-of-file
	     (progn
	       (message "Parse error for parsing result of Sekka Server.")
	       nil))))
      (progn
	(message result)
	nil))))


;; $B%]!<%?%V%kJ8;zNsCV49(B( Emacs$B$H(BXEmacs$B$NN>J}$GF0$/(B )
(defun sekka-replace-regexp-in-string (regexp replace str)
  (cond ((featurep 'xemacs)
	 (replace-in-string str regexp replace))
	(t
	 (replace-regexp-in-string regexp replace str))))
	

;; $B%j!<%8%g%s$r%m!<%^;z4A;zJQ49$9$k4X?t(B
(defun sekka-henkan-region (b e)
  "$B;XDj$5$l$?(B region $B$r4A;zJQ49$9$k(B"
  (sekka-init)
  (when (/= b e)
    (let* (
	   (yomi (buffer-substring-no-properties b e))
	   (henkan-list (sekka-henkan-request yomi)))
      
      (if henkan-list
	  (condition-case err
	      (progn
		(setq
		 ;; $BJQ497k2L$NJ];}(B
		 sekka-henkan-kouho-list henkan-list
		 ;; $BJ8@aA*Br=i4|2=(B
		 sekka-cand-cur 0
		 ;; 
		 sekka-cand-len (length henkan-list))
		
		(sekka-debug-print (format "sekka-henkan-kouho-list:%s \n" sekka-henkan-kouho-list))
		(sekka-debug-print (format "sekka-cand-cur:%s \n" sekka-cand-cur))
		(sekka-debug-print (format "sekka-cand-len:%s \n" sekka-cand-len))
		;;
		t)
	    (sekka-trap-server-down
	     (beep)
	     (message (error-message-string err))
	     (setq sekka-select-mode nil))
	    (run-hooks 'sekka-select-mode-end-hook))
	nil))))


;; $B%+!<%=%kA0$NJ8;z<o$rJV5Q$9$k4X?t(B
(eval-and-compile
  (if (>= emacs-major-version 20)
      (progn
	(defalias 'sekka-char-charset (symbol-function 'char-charset))
	(when (and (boundp 'byte-compile-depth)
		   (not (fboundp 'char-category)))
	  (defalias 'char-category nil))) ; for byte compiler
    (defun sekka-char-charset (ch)
      (cond ((equal (char-category ch) "a") 'ascii)
	    ((equal (char-category ch) "k") 'katakana-jisx0201)
	    ((string-match "[SAHK]j" (char-category ch)) 'japanese-jisx0208)
	    (t nil) )) ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo $B>pJs$N@)8f(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo buffer $BB`HrMQJQ?t(B
(defvar sekka-buffer-undo-list nil)
(make-variable-buffer-local 'sekka-buffer-undo-list)
(defvar sekka-buffer-modified-p nil)
(make-variable-buffer-local 'sekka-buffer-modified-p)

(defvar sekka-blink-cursor nil)
(defvar sekka-cursor-type nil)
;; undo buffer $B$rB`Hr$7!"(Bundo $B>pJs$NC_@Q$rDd;_$9$k4X?t(B
(defun sekka-disable-undo ()
  (when (not (eq buffer-undo-list t))
    (setq sekka-buffer-undo-list buffer-undo-list)
    (setq sekka-buffer-modified-p (buffer-modified-p))
    (setq buffer-undo-list t)))

;; $BB`Hr$7$?(B undo buffer $B$rI|5"$7!"(Bundo $B>pJs$NC_@Q$r:F3+$9$k4X?t(B
(defun sekka-enable-undo ()
  (when (not sekka-buffer-modified-p) (set-buffer-modified-p nil))
  (when sekka-buffer-undo-list
    (setq buffer-undo-list sekka-buffer-undo-list)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B8=:_$NJQ49%(%j%"$NI=<($r9T$&(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-get-display-string ()
  ;; $BJQ497k2LJ8;zNs$rJV$9!#(B
  (let* ((kouho      (nth sekka-cand-cur sekka-henkan-kouho-list))
	 (_          (sekka-debug-print (format "sekka-cand-cur=%s\n" sekka-cand-cur)))
	 (_          (sekka-debug-print (format "kouho=%s\n" kouho)))
	 (word       (car kouho))
	 (annotation (cadr kouho)))
    (sekka-debug-print (format "word:[%d] %s(%s)\n" sekka-cand-cur word annotation))
    word))

(defun sekka-display-function (b e select-mode)
  (setq sekka-henkan-separeter (if sekka-use-fence " " ""))
  (when sekka-henkan-kouho-list
    ;; UNDO$BM^@)3+;O(B
    (sekka-disable-undo)
    
    (delete-region b e)

    ;; $B%j%9%H=i4|2=(B
    (setq sekka-markers '())

    (setq sekka-last-fix "")

    ;; $BJQ49$7$?(Bpoint$B$NJ];}(B
    (setq sekka-fence-start (point-marker))
    (when select-mode (insert "|"))
    
    (let* (
	   (start       (point-marker))
	   (_cur        sekka-cand-cur)
	   (_len        sekka-cand-len)
	   (insert-word (sekka-get-display-string)))
      (progn
	(insert insert-word)
	(message (format "[%s] candidate (%d/%d)" insert-word (+ _cur 1) _len))
	(let* ((end         (point-marker))
	       (ov          (make-overlay start end)))
	    
	  ;; $B3NDjJ8;zNs$N:n@.(B
	  (setq sekka-last-fix insert-word)
	   
	  ;; $BA*BrCf$N>l=j$rAu>~$9$k!#(B
	  (overlay-put ov 'face 'default)
	  (when select-mode
	    (overlay-put ov 'face 'highlight))
	  (setq sekka-markers (cons start end))
	  (sekka-debug-print (format "insert:[%s] point:%d-%d\n" insert-word (marker-position start) (marker-position end))))))

    ;; fence$B$NHO0O$r@_Dj$9$k(B
    (when select-mode (insert "|"))
    (setq sekka-fence-end   (point-marker))
    
    (sekka-debug-print (format "total-point:%d-%d\n"
			       (marker-position sekka-fence-start)
			       (marker-position sekka-fence-end)))
    ;; UNDO$B:F3+(B
    (sekka-enable-undo)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $BJQ498uJdA*Br%b!<%I(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((i 0))
  (while (<= i ?\177)
    (define-key sekka-select-mode-map (char-to-string i)
      'sekka-kakutei-and-self-insert)
    (setq i (1+ i))))
(define-key sekka-select-mode-map "\C-m"                   'sekka-select-kakutei)
(define-key sekka-select-mode-map "\C-g"                   'sekka-select-cancel)
(define-key sekka-select-mode-map "q"                      'sekka-select-cancel)
(define-key sekka-select-mode-map "\C-b"                   'sekka-select-prev-word)
(define-key sekka-select-mode-map "\C-f"                   'sekka-select-next-word)
(define-key sekka-select-mode-map "\C-a"                   'sekka-select-first-word)
(define-key sekka-select-mode-map "\C-e"                   'sekka-select-last-word)
(define-key sekka-select-mode-map "\C-p"                   'sekka-select-prev)
(define-key sekka-select-mode-map "\C-n"                   'sekka-select-next)
(define-key sekka-select-mode-map sekka-rK-trans-key       'sekka-select-next)
(define-key sekka-select-mode-map " "                      'sekka-select-next)
(define-key sekka-select-mode-map "\C-u"                   'sekka-select-hiragana)
(define-key sekka-select-mode-map "\C-i"                   'sekka-select-katakana)


;; $BJQ49$r3NDj$7F~NO$5$l$?%-!<$r:FF~NO$9$k4X?t(B
(defun sekka-kakutei-and-self-insert (arg)
  "$B8uJdA*Br$r3NDj$7!"F~NO$5$l$?J8;z$rF~NO$9$k(B"
  (interactive "P")
  (sekka-select-kakutei)
  (setq unread-command-events (list last-command-event)))

;; $B8uJdA*Br>uBV$G$NI=<(99?7(B
(defun sekka-select-update-display ()
  (sekka-display-function
   (marker-position sekka-fence-start)
   (marker-position sekka-fence-end)
   sekka-select-mode))


;; $B8uJdA*Br$r3NDj$9$k(B
(defun sekka-select-kakutei ()
  "$B8uJdA*Br$r3NDj$9$k(B"
  (interactive)
  ;; $B8uJdHV9f%j%9%H$r%P%C%/%"%C%W$9$k!#(B
  (setq sekka-cand-cur-backup sekka-cand-cur)
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))


;; $B8uJdA*Br$r%-%c%s%;%k$9$k(B
(defun sekka-select-cancel ()
  "$B8uJdA*Br$r%-%c%s%;%k$9$k(B"
  (interactive)
  ;; $B%+%l%s%H8uJdHV9f$r%P%C%/%"%C%W$7$F$$$?8uJdHV9f$GI|85$9$k!#(B
  (setq sekka-cand-cur sekka-cand-cur-backup)
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))

;; $BA0$N8uJd$K?J$a$k(B
(defun sekka-select-prev ()
  "$BA0$N8uJd$K?J$a$k(B"
  (interactive)
  (let (
	(n sekka-cand))

    ;; $BA0$N8uJd$K@Z$j$+$($k(B
    (setcar (nthcdr n sekka-cand-n) (- (nth n sekka-cand-n) 1))
    (when (> 0 (nth n sekka-cand-n))
      (setcar (nthcdr n sekka-cand-n) (- (nth n sekka-cand-max) 1)))
    (sekka-select-update-display)))

;; $B<!$N8uJd$K?J$a$k(B
(defun sekka-select-next ()
  "$B<!$N8uJd$K?J$a$k(B"
  (interactive)
  ;; $B<!$N8uJd$K@Z$j$+$($k(B
  (setq sekka-cand-cur 
	(if (< sekka-cand-cur (- sekka-cand-len 1))
	    (+ sekka-cand-cur 1)
	  0))
  (sekka-debug-print (format "sekka-select-next()  sekka-cand-cur=%d,  sekka-cand-len=%d\n" 
			     sekka-cand-cur sekka-cand-len))
  (sekka-select-update-display))


;; $B;XDj$5$l$?(B type $B$N8uJd$K6/@)E*$K@Z$j$+$($k(B
(defun sekka-select-by-type ( _type )
  (let* (
	 (n sekka-cand)
	 (kouho (nth n sekka-henkan-list))
	 (_element (assoc _type kouho)))

    ;; $BO"A[%j%9%H$+$i(B _type $B$G0z$$$?(B index $BHV9f$r@_Dj$9$k$@$1$GNI$$!#(B
    (when _element
      (setcar (nthcdr n sekka-cand-n) (nth sekka-candno-index _element))
      (sekka-select-update-display))))

(defun sekka-select-kanji ()
  "$B4A;z8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'j))

(defun sekka-select-hiragana ()
  "$B$R$i$,$J8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'h))

(defun sekka-select-katakana ()
  "$B%+%?%+%J8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'k))

(defun sekka-select-alphabet ()
  "$B%"%k%U%!%Y%C%H8uJd$K6/@)E*$K@Z$j$+$($k(B"
  (interactive)
  (sekka-select-by-type 'l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; $B%m!<%^;z4A;zJQ494X?t(B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-rK-trans ()
  "$B%m!<%^;z4A;zJQ49$r$9$k!#(B
$B!&%+!<%=%k$+$i9TF,J}8~$K%m!<%^;zNs$,B3$/HO0O$G%m!<%^;z4A;zJQ49$r9T$&!#(B"
  (interactive)
;  (print last-command)			; DEBUG

  (cond 
   ;; $B%?%$%^!<%$%Y%s%H$r@_Dj$7$J$$>r7o(B
   ((or
     sekka-timer
     (> 1 sekka-realtime-guide-running-seconds)
     ))
   (t
    ;; $B%?%$%^!<%$%Y%s%H4X?t$NEPO?(B
    (progn
      (let 
	  ((ov-point
	    (save-excursion
	      (forward-line 1)
	      (point))))
	  (setq sekka-guide-overlay
			(make-overlay ov-point ov-point (current-buffer))))
      (setq sekka-timer
			(run-at-time 0.1 sekka-realtime-guide-interval
						 'sekka-realtime-guide)))))

  ;; $B%,%$%II=<(7QB32s?t$N99?7(B
  (when (< 0 sekka-realtime-guide-running-seconds)
    (setq sekka-timer-rest  
	  (/ sekka-realtime-guide-running-seconds
	     sekka-realtime-guide-interval)))

  (cond
   (sekka-select-mode
    ;; $BJQ49Cf$K8F=P$5$l$?$i!"8uJdA*Br%b!<%I$K0\9T$9$k!#(B
    (funcall (lookup-key sekka-select-mode-map sekka-rK-trans-key)))


   (t
    (cond

     ((eq (sekka-char-charset (preceding-char)) 'ascii)
      ;; $B%+!<%=%kD>A0$,(B alphabet $B$@$C$?$i(B
      (let ((end (point))
	    (gap (sekka-skip-chars-backward)))
	(when (/= gap 0)
	  ;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$GJQ49$9$k(B
	  (let (
		(b (+ end gap))
		(e end))
	    (when (sekka-henkan-region b e)
	      (if (eq (char-before b) ?/)
		  (setq b (- b 1)))
	      (delete-region b e)
	      (goto-char b)
	      (insert (sekka-get-display-string))
	      (setq e (point))
	      (sekka-display-function b e nil)
	      (sekka-select-kakutei)
	      )))))

     
     ((sekka-kanji (preceding-char))
    
      ;; $B%+!<%=%kD>A0$,(B $BA43Q$G4A;z0J30(B $B$@$C$?$i8uJdA*Br%b!<%I$K0\9T$9$k!#(B
      ;; $B$^$?!":G8e$K3NDj$7$?J8;zNs$HF1$8$+$I$&$+$b3NG'$9$k!#(B
      (when (and
	     (<= (marker-position sekka-fence-start) (point))
	     (<= (point) (marker-position sekka-fence-end))
	     (string-equal sekka-last-fix (buffer-substring 
					   (marker-position sekka-fence-start)
					   (marker-position sekka-fence-end))))
	;; $BD>A0$KJQ49$7$?(Bfence$B$NHO0O$KF~$C$F$$$?$i!"JQ49%b!<%I$K0\9T$9$k!#(B
	(setq sekka-select-mode t)
	(sekka-debug-print "henkan mode ON\n")

	;; $BI=<(>uBV$r8uJdA*Br%b!<%I$K@ZBX$($k!#(B
	(sekka-display-function
	 (marker-position sekka-fence-start)
	 (marker-position sekka-fence-end)
	 t))))
     )))



;; $BA43Q$G4A;z0J30$NH=Dj4X?t(B
(defun sekka-nkanji (ch)
  (and (eq (sekka-char-charset ch) 'japanese-jisx0208)
       (not (string-match "[$B0!(B-$Bt$(B]" (char-to-string ch)))))

(defun sekka-kanji (ch)
  (eq (sekka-char-charset ch) 'japanese-jisx0208))


;; $B%m!<%^;z4A;zJQ49;~!"JQ49BP>]$H$9$k%m!<%^;z$rFI$_Ht$P$94X?t(B
(defun sekka-skip-chars-backward ()
  (let* (
	 (skip-chars
	  (if auto-fill-function
	      ;; auto-fill-mode $B$,M-8z$K$J$C$F$$$k>l9g2~9T$,$"$C$F$b(Bskip$B$rB3$1$k(B
	      (concat sekka-skip-chars "\n")
	    ;; auto-fill-mode$B$,L58z$N>l9g$O$=$N$^$^(B
	    sekka-skip-chars))
	    
	 ;; $B%^!<%/$5$l$F$$$k0LCV$r5a$a$k!#(B
	 (pos (or (and (markerp (mark-marker)) (marker-position (mark-marker)))
		  1))

	 ;; $B>r7o$K%^%C%A$9$k4V!"A0J}J}8~$K%9%-%C%W$9$k!#(B
	 (result (save-excursion
		   (skip-chars-backward skip-chars (and (< pos (point)) pos))))
	 (limit-point 0))

    (if auto-fill-function
	;; auto-fill-mode$B$,M-8z$N;~(B
	(progn
	  (save-excursion
	    (backward-paragraph)
	    (when (< 1 (point))
	      (forward-line 1))
	    (goto-char (point-at-bol))
	    (let (
		  (start-point (point)))
	      (setq limit-point
		    (+
		     start-point
		     (skip-chars-forward (concat "\t " sekka-stop-chars) (point-at-eol))))))

	  ;; (sekka-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	  ;; (sekka-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

	  ;; $B%Q%i%0%i%U0LCV$G%9%H%C%W$9$k(B
	  (if (< (+ (point) result) limit-point)
	      (- 
	       limit-point
	       (point))
	    result))

      ;; auto-fill-mode$B$,L58z$N;~(B
      (progn
	(save-excursion
	  (goto-char (point-at-bol))
	  (let (
		(start-point (point)))
	    (setq limit-point
		  (+ 
		   start-point
		   (skip-chars-forward (concat "\t " sekka-stop-chars) (point-at-eol))))))

	;; (sekka-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	;; (sekka-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

	(if (< (+ (point) result) limit-point)
	    ;; $B%$%s%G%s%H0LCV$G%9%H%C%W$9$k!#(B
	    (- 
	     limit-point
	     (point))
	  result)))))

;;;
;;; $B%m!<%+%k$N(BEmacsLisp$B$@$1$GJQ49$9$k=hM}(B
;;;
;; a-list $B$r;H$C$F(B str $B$N@hF,$K3:Ev$9$kJ8;zNs$,$"$k$+D4$Y$k(B
(defun romkan-scan-token (a-list str)
  (let 
      ((result     (substring str 0 1))
       (rest       (substring str 1 (length str)))
       (done       nil))

    (mapcar
     (lambda (x)
       (if (and 
	    (string-match (concat "^" (car x)) str)
	    (not done))
	   (progn
	     (setq done t)
	     (setq result (cdr x))
	     (setq rest   (substring str (length (car x)))))))
     a-list)
    (cons result rest)))


;; $B$+$J(B<->$B%m!<%^;zJQ49$9$k(B
(defun romkan-convert (a-list str)
  (cond ((= 0 (length str))
	 "")
	(t
	 (let ((ret (romkan-scan-token a-list str)))
	   (concat
	    (car ret)
	    (romkan-convert a-list (cdr ret)))))))


  
;;;
;;; with viper
;;;
;; code from skk-viper.el
(defun sekka-viper-normalize-map ()
  (let ((other-buffer
	 (if (featurep 'xemacs)
	     (local-variable-p 'minor-mode-map-alist nil t)
	   (local-variable-if-set-p 'minor-mode-map-alist))))
    ;; for current buffer and buffers to be created in the future.
    ;; substantially the same job as viper-harness-minor-mode does.
    (viper-normalize-minor-mode-map-alist)
    (setq-default minor-mode-map-alist minor-mode-map-alist)
    (when other-buffer
      ;; for buffers which are already created and have
      ;; the minor-mode-map-alist localized by Viper.
      (dolist (buf (buffer-list))
	(with-current-buffer buf
	  (unless (assq 'sekka-mode minor-mode-map-alist)
	    (setq minor-mode-map-alist
		  (append (list (cons 'sekka-mode sekka-mode-map)
				(cons 'sekka-select-mode
				      sekka-select-mode-map))
			  minor-mode-map-alist)))
	  (viper-normalize-minor-mode-map-alist))))))

(defun sekka-viper-init-function ()
  (sekka-viper-normalize-map)
  (remove-hook 'sekka-mode-hook 'sekka-viper-init-function))



(defun sekka-realtime-guide ()
  "$B%j%"%k%?%$%`$GJQ49Cf$N%,%$%I$r=P$9(B
sekka-mode$B$,(BON$B$N4VCf8F$S=P$5$l$k2DG=@-$,$"$k!&(B"
  (cond
   ((or (null sekka-mode)
	(> 1 sekka-timer-rest))
    (cancel-timer sekka-timer)
    (setq sekka-timer nil)
    (delete-overlay sekka-guide-overlay))
   (sekka-guide-overlay
    ;; $B;D$j2s?t$N%G%/%j%a%s%H(B
    (setq sekka-timer-rest (- sekka-timer-rest 1))

    (let* (
	   (end (point))
	   (gap (sekka-skip-chars-backward))
	   (prev-line-existp
	    (not (= (point-at-bol) (point-min))))
	   (next-line-existp
	    (not (= (point-at-eol) (point-max))))
	   (prev-line-point
	    (when prev-line-existp
	      (save-excursion
		(forward-line -1)
		(point))))
	   (next-line-point
	    (when next-line-existp
	      (save-excursion
		(forward-line 1)
		(point))))
	   (disp-point
	    (or next-line-point prev-line-point)))

      (if 
	  (or 
	   (when (fboundp 'minibufferp)
	     (minibufferp))
	   (and
	    (not next-line-point)
	    (not prev-line-point))
	   (= gap 0))
	  ;; $B>e2<%9%Z!<%9$,L5$$(B $B$^$?$O(B $BJQ49BP>]$,L5$7$J$i%,%$%I$OI=<($7$J$$!#(B
	  (overlay-put sekka-guide-overlay 'before-string "")
	;; $B0UL#$N$"$kF~NO$,8+$D$+$C$?$N$G%,%$%I$rI=<($9$k!#(B
	(let* (
	       (b (+ end gap))
	       (e end)
	       (str (buffer-substring b e))
	       (l (split-string str))
	       (mess
		(mapconcat
		 (lambda (x)
		   (let* ((l (split-string x "\\."))
			  (method
			   (when (< 1 (length l))
			     (cadr l)))
			  (hira
			   (romkan-convert sekka-roman->kana-table
					   (car l))))
		     (cond
		      ((string-match "[a-z]+" hira)
		       x)
		      ((not method)
		       hira)
		      ((or (string-equal "j" method) (string-equal "h" method))
		       hira)
		      ((or (string-equal "e" method) (string-equal "l" method))
		       (car l))
		      ((string-equal "k" method)
		       (romkan-convert sekka-hiragana->katakana-table
				       hira))
		      (t
		       x))))
		 l
		 " ")))
	  (move-overlay sekka-guide-overlay 
			disp-point (min (point-max) (+ disp-point 1)) (current-buffer))
	  (overlay-put sekka-guide-overlay 'before-string mess))))
    (overlay-put sekka-guide-overlay 'face 'sekka-guide-face))))


;;;
;;; human interface
;;;
(define-key sekka-mode-map sekka-rK-trans-key 'sekka-rK-trans)
(define-key sekka-mode-map "\M-j" 'sekka-rHkA-trans)
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list 
		   (cons 'sekka-mode         sekka-mode-map))
		  minor-mode-map-alist)))



;; sekka-mode $B$N>uBVJQ994X?t(B
;;  $B@5$N0z?t$N>l9g!">o$K(B sekka-mode $B$r3+;O$9$k(B
;;  {$BIi(B,0}$B$N0z?t$N>l9g!">o$K(B sekka-mode $B$r=*N;$9$k(B
;;  $B0z?tL5$7$N>l9g!"(Bsekka-mode $B$r%H%0%k$9$k(B

;; buffer $BKh$K(B sekka-mode $B$rJQ99$9$k(B
(defun sekka-mode (&optional arg)
  "Sekka mode $B$O(B $B%m!<%^;z$+$iD>@\4A;zJQ49$9$k$?$a$N(B minor mode $B$G$9!#(B
$B0z?t$K@5?t$r;XDj$7$?>l9g$O!"(BSekka mode $B$rM-8z$K$7$^$9!#(B

Sekka $B%b!<%I$,M-8z$K$J$C$F$$$k>l9g(B \\<sekka-mode-map>\\[sekka-rK-trans] $B$G(B
point $B$+$i9TF,J}8~$KF1<o$NJ8;zNs$,B3$/4V$r4A;zJQ49$7$^$9!#(B

$BF1<o$NJ8;zNs$H$O0J2<$N$b$N$r;X$7$^$9!#(B
$B!&H>3Q%+%?%+%J$H(Bsekka-stop-chars $B$K;XDj$7$?J8;z$r=|$/H>3QJ8;z(B
$B!&4A;z$r=|$/A43QJ8;z(B"
  (interactive "P")
  (sekka-mode-internal arg nil))

;; $BA4%P%C%U%!$G(B sekka-mode $B$rJQ99$9$k(B
(defun global-sekka-mode (&optional arg)
  "Sekka mode $B$O(B $B%m!<%^;z$+$iD>@\4A;zJQ49$9$k$?$a$N(B minor mode $B$G$9!#(B
$B0z?t$K@5?t$r;XDj$7$?>l9g$O!"(BSekka mode $B$rM-8z$K$7$^$9!#(B

Sekka $B%b!<%I$,M-8z$K$J$C$F$$$k>l9g(B \\<sekka-mode-map>\\[sekka-rK-trans] $B$G(B
point $B$+$i9TF,J}8~$KF1<o$NJ8;zNs$,B3$/4V$r4A;zJQ49$7$^$9!#(B

$BF1<o$NJ8;zNs$H$O0J2<$N$b$N$r;X$7$^$9!#(B
$B!&H>3Q%+%?%+%J$H(Bsekka-stop-chars $B$K;XDj$7$?J8;z$r=|$/H>3QJ8;z(B
$B!&4A;z$r=|$/A43QJ8;z(B"
  (interactive "P")
  (sekka-mode-internal arg t))


;; sekka-mode $B$rJQ99$9$k6&DL4X?t(B
(defun sekka-mode-internal (arg global)
  (or (local-variable-p 'sekka-mode (current-buffer))
      (make-local-variable 'sekka-mode))
  (if global
      (progn
	(setq-default sekka-mode (if (null arg) (not sekka-mode)
				    (> (prefix-numeric-value arg) 0)))
	(sekka-kill-sekka-mode))
    (setq sekka-mode (if (null arg) (not sekka-mode)
			(> (prefix-numeric-value arg) 0))))
  (when sekka-use-viper
    (add-hook 'sekka-mode-hook 'sekka-viper-init-function))
  (when sekka-mode (run-hooks 'sekka-mode-hook)))


;; buffer local $B$J(B sekka-mode $B$r:o=|$9$k4X?t(B
(defun sekka-kill-sekka-mode ()
  (let ((buf (buffer-list)))
    (while buf
      (set-buffer (car buf))
      (kill-local-variable 'sekka-mode)
      (setq buf (cdr buf)))))


;; $BA4%P%C%U%!$G(B sekka-input-mode $B$rJQ99$9$k(B
(defun sekka-input-mode (&optional arg)
  "$BF~NO%b!<%IJQ99(B"
  (interactive "P")
  (if (< 0 arg)
      (progn
	(setq inactivate-current-input-method-function 'sekka-inactivate)
	(setq sekka-mode t))
    (setq inactivate-current-input-method-function nil)
    (setq sekka-mode nil)))


;; input method $BBP1~(B
(defun sekka-activate (&rest arg)
  (sekka-input-mode 1))
(defun sekka-inactivate (&rest arg)
  (sekka-input-mode -1))
(register-input-method
 "japanese-sekka" "Japanese" 'sekka-activate
 "" "Roman -> Kanji&Kana"
 nil)

;; input-method $B$H$7$FEPO?$9$k!#(B
(set-language-info "Japanese" 'input-method "japanese-sekka")
(setq default-input-method "japanese-sekka")

(defconst sekka-version
  " $Date: 2007/07/23 15:40:49 $ on CVS " ;;VERSION;;
  )
(defun sekka-version (&optional arg)
  "$BF~NO%b!<%IJQ99(B"
  (interactive "P")
  (message sekka-version))

(provide 'sekka)