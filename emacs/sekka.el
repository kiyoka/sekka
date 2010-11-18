;; -*- coding: utf-8 -*-
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
;; Sekka is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with Sekka; see the file COPYING.
;;

;;; Code:
(require 'cl)
(require 'http-get)

;;; 
;;;
;;; customize variables
;;;
(defgroup sekka nil
  "Sekka client."
  :group 'input-method
  :group 'Japanese)

(defcustom sekka-server-url "http://localhost:12929/"
  "SekkaサーバーのURLを指定する。"
  :type  'string
  :group 'sekka)

(defcustom sekka-server-timeout 10
  "Sekkaサーバーと通信する時のタイムアウトを指定する。(秒数)"
  :type  'integer
  :group 'sekka)
 
(defcustom sekka-stop-chars "(){}<> "
  "*漢字変換文字列を取り込む時に変換範囲に含めない文字を設定する"
  :type  'string
  :group 'sekka)

(defcustom sekka-curl "curl"
  "curlコマンドの絶対パスを設定する"
  :type  'string
  :group 'sekka)

(defcustom sekka-use-viper nil
  "*Non-nil であれば、VIPER に対応する"
  :type 'boolean
  :group 'sekka)

(defcustom sekka-realtime-guide-running-seconds 30
  "リアルタイムガイド表示の継続時間(秒数)・ゼロでガイド表示機能が無効になる"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-limit-lines 5
  "最後に変換した行から N 行離れたらリアルタイムガイド表示が止まる"
  :type  'integer
  :group 'sekka)

(defcustom sekka-realtime-guide-interval  0.2
  "リアルタイムガイド表示を更新する時間間隔"
  :type  'integer
  :group 'sekka)

(defcustom sekka-roman-method "normal"
  "ローマ字入力方式として，normal(通常ローマ字)か、AZIK(拡張ローマ字)のどちらの解釈を優先するか"
  :type '(choice (const :tag "normal" "normal")
		 (const :tag "AZIK"   "azik"  ))
  :group 'sekka)


(defface sekka-guide-face
  '((((class color) (background light)) (:background "#E0E0E0" :foreground "#F03030")))
  "リアルタイムガイドのフェイス(装飾、色などの指定)"
  :group 'sekka)


(defvar sekka-sticky-shift nil     "*Non-nil であれば、Sticky-Shiftを有効にする")
(defvar sekka-mode nil             "漢字変換トグル変数")
(defvar sekka-mode-line-string     " Sekka")
(defvar sekka-select-mode nil      "候補選択モード変数")
(or (assq 'sekka-mode minor-mode-alist)
    (setq minor-mode-alist (cons
			    '(sekka-mode        sekka-mode-line-string)
			    minor-mode-alist)))


;; ローマ字漢字変換時、対象とするローマ字を設定するための変数
(defvar sekka-skip-chars "a-zA-Z0-9.,@:`\\-+!\\[\\]?;")
(defvar sekka-mode-map        (make-sparse-keymap)         "漢字変換トグルマップ")
(defvar sekka-select-mode-map (make-sparse-keymap)         "候補選択モードマップ")
(defvar sekka-rK-trans-key "\C-j"
  "*漢字変換キーを設定する")
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

(defconst sekka-login-name   (user-login-name))

(defconst sekka-kind-index   3)
(defconst sekka-id-index     4)

;;--- デバッグメッセージ出力
(defvar sekka-psudo-server nil)         ; クライアント単体で仮想的にサーバーに接続しているようにしてテストするモード

;;--- デバッグメッセージ出力
(defvar sekka-debug nil)		; デバッグフラグ
(defun sekka-debug-print (string)
  (if sekka-debug
      (let
	  ((buffer (get-buffer-create "*sekka-debug*")))
	(with-current-buffer buffer
	  (goto-char (point-max))
	  (insert string)))))


;;; sekka basic output
(defvar sekka-fence-start nil)          ; fence 始端位置
(defvar sekka-fence-end nil)            ; fence 終端位置
(defvar sekka-henkan-separeter " ")     ; fence mode separeter
(defvar sekka-henkan-buffer nil)        ; 表示用バッファ
(defvar sekka-henkan-length nil)        ; 表示用バッファ長
(defvar sekka-henkan-revpos nil)        ; 文節始端位置
(defvar sekka-henkan-revlen nil)        ; 文節長

;;; sekka basic local
(defvar sekka-cand-cur 0)               ; カレント候補番号
(defvar sekka-cand-cur-backup 0)        ; カレント候補番号(UNDO用に退避する変数)
(defvar sekka-cand-len nil)             ; 候補数
(defvar sekka-last-fix "")              ; 最後に確定した文字列
(defvar sekka-henkan-kouho-list nil)    ; 変換結果リスト(サーバから帰ってきたデータそのもの)
(defvar sekka-markers '())              ; 文節開始、終了位置のpair: 次のような形式 ( 1 . 2 )
(defvar sekka-timer    nil)             ; インターバルタイマー型変数
(defvar sekka-timer-rest  0)            ; あと何回呼出されたら、インターバルタイマの呼出を止めるか
(defvar sekka-last-lineno 0)            ; 最後に変換を実行した行番号
(defvar sekka-guide-overlay   nil)      ; リアルタイムガイドに使用するオーバーレイ
(defvar sekka-last-request-time 0)      ; Sekkaサーバーにリクエストした最後の時刻(単位は秒)
(defvar sekka-guide-lastquery  "")      ; Sekkaサーバーにリクエストした最後のクエリ文字列
(defvar sekka-guide-lastresult '())     ; Sekkaサーバーにリクエストした最後のクエリ文字列


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Skicky-shift
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar sticky-key ";")
(defvar sticky-list
  '(("a" . "A")("b" . "B")("c" . "C")("d" . "D")("e" . "E")("f" . "F")("g" . "G")
    ("h" . "H")("i" . "I")("j" . "J")("k" . "K")("l" . "L")("m" . "M")("n" . "N")
    ("o" . "O")("p" . "P")("q" . "Q")("r" . "R")("s" . "S")("t" . "T")("u" . "U")
    ("v" . "V")("w" . "W")("x" . "X")("y" . "Y")("z" . "Z")
    ("1" . "!")("2" . "\"")("3" . "#")("4" . "$")("5" . "%")("6" . "&")("7" . "'")
    ("8" . "(")("9" . ")")
    ("`" . "@")("[" . "{")("]" . "}")("-" . "=")("^" . "~")("\\" . "|")("." . ">")
    ("/" . "?")(";" . ";")(":" . "*")("@" . "`")
    ("\C-h" . "")
    ))
(defvar sticky-map (make-sparse-keymap))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 表示系関数群
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar sekka-use-fence t)
(defvar sekka-use-color nil)

(defvar sekka-init nil)

;;
;; 初期化
;;
(defun sekka-init ()
  ;; 最初の n 件のリストを取得する
  (defun sekka-take (arg-list n)
    (let ((lst '()))
      (dotimes (i n (reverse lst))
        (let ((item (nth i arg-list)))
	  (when item
	    (push item lst))))))
  
  (when (not sekka-init)
    ;; ユーザー語彙のロード + サーバーへの登録
    (sekka-register-userdict-internal)

    ;; Emacs終了時の処理
    (add-hook 'kill-emacs-hook
	      (lambda ()
		;; 何もすることは無い
		t))
    ;; 初期化完了
    (setq sekka-init t)))


(defun sekka-construct-curl-argstr (arg-alist)
  (apply 'concat
	 (mapcar
	  (lambda (x)
	    (format "--data '%s=%s' " (car x)
		    (if (stringp (cdr x))
			(http-url-encode (cdr x) 'utf-8)
		      (cdr x))))
	  arg-alist)))

;; test-code
(when nil
  (sekka-construct-curl-argstr
   '(
     ("yomi"   .  "kanji")
     ("limit"  .  2)
     ("method" .  "normal")
     )))

;;
;; ローマ字で書かれた文章をSekkaサーバーを使って変換する
;;
;; arg-alistの引数の形式
;;  例:
;;   '(
;;     ("yomi"   .  "kanji")
;;     ("limit"  .  2)
;;     ("method" .  "normal")
;;    )
(defun sekka-rest-request (func-name arg-alist)
  (if sekka-psudo-server
      ;; クライアント単体で仮想的にサーバーに接続しているようにしてテストするモード
      "((\"変換\" nil \"へんかん\" j 0) (\"変化\" nil \"へんか\" j 1) (\"ヘンカン\" nil \"へんかん\" k 2) (\"へんかん\" nil \"へんかん\" h 3))"
      ;;"((\"変換\" nil \"へんかん\" j 0) (\"変化\" nil \"へんか\" j 1))"
    ;; 実際のサーバに接続する
    (let ((command
	   (concat
	    sekka-curl " --silent --show-error "
	    (format " --max-time %d " sekka-server-timeout)
	    " --insecure "
	    " --header 'Content-Type: application/x-www-form-urlencoded' "
	    (format "%s%s " sekka-server-url func-name)
	    (sekka-construct-curl-argstr (cons
					  '("format" . "sexp")
					  arg-alist))
	    (format "--data 'userid=%s' " sekka-login-name))))

      (sekka-debug-print (format "curl-command :%s\n" command))
      
      (let (
	    (result
	     (shell-command-to-string
	      command)))
	
	(sekka-debug-print (format "curl-result-sexp :%s\n" result))
	result))))
      
;;
;; 現在時刻をUNIXタイムを返す(単位は秒)
;;
(defun sekka-current-unixtime ()
  (let (
	(_ (current-time)))
    (+
     (* (car _)
	65536)
     (cadr _))))


;;
;; ローマ字で書かれた文章をSekkaサーバーを使って変換する
;;
(defun sekka-henkan-request (yomi limit)
  (sekka-debug-print (format "henkan-input :[%s]\n"  yomi))

  ;;(message "Requesting to sekka server...")
  
  (let (
	(result (sekka-rest-request "henkan" `((yomi   . ,yomi)
					       (limit  . ,limit)
					       (method . ,sekka-roman-method)))))
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

;;
;; 確定した単語をサーバーに伝達する
;;
(defun sekka-kakutei-request (key tango)
  (sekka-debug-print (format "henkan-kakutei key=[%s] tango=[%s]\n" key tango))
  
  (message "Requesting to sekka server...")
  
  (let ((result (sekka-rest-request "kakutei" `(
						(key   . ,key)
						(tango . ,tango)))))
    (sekka-debug-print (format "kakutei-result:%S\n" result))
    (message result)
    t))

;;
;; ユーザー語彙をサーバーに再度登録する。
;;
(defun sekka-register-userdict (&optional arg)
  "ユーザー辞書をサーバーに再度アップロードする"
  (interactive "P")
  (sekka-register-userdict-internal))

  
;;
;; ユーザー語彙をサーバーに登録する。
;;
(defun sekka-register-userdict-internal ()
  (let ((str (sekka-get-jisyo-str "~/.sekka-jisyo")))
    (when str
      (message "Requesting to sekka server...")
      (sekka-debug-print (format "register [%s]\n" str))
      (let ((result (sekka-rest-request "register" `((dict . ,str)))))
	(sekka-debug-print (format "register-result:%S\n" result))
	(message result)
	t))))


;;
;; ユーザー語彙をサーバーから全て削除する
;;
(defun sekka-flush-userdict (&optional arg)
  "ユーザー辞書をサーバーに再度アップロードする"
  (interactive "P")
  (message "Requesting to sekka server...")
  (let ((result (sekka-rest-request "flush" `())))
    (sekka-debug-print (format "register-result:%S\n" result))
    (message result)
    t))


(defun sekka-get-jisyo-str (file &optional nomsg)
  "FILE を開いて SKK 辞書バッファを作り、バッファを返す。
オプション引数の NOMSG を指定するとファイル読み込みの際のメッセージを表示しな
い。"
  (when file
    (let* ((file (or (car-safe file)
		     file))
	   (file (expand-file-name file)))
      (if (not (file-exists-p file))
	  (progn
	    (message (format "SKK 辞書 %s が存在しません..." file))
	    nil)
	(let ((str "")
	      (buf-name (file-name-nondirectory file)))
	  (save-excursion
	    (find-file-read-only file)
	    (setq str (with-current-buffer (get-buffer buf-name)
			(buffer-substring-no-properties (point-min) (point-max))))
	    (message (format "SKK 辞書 %s を開いています...完了！" (file-name-nondirectory file)))
	    (kill-buffer-if-not-modified (get-buffer buf-name)))
	  str)))))

;;(sekka-get-jisyo-str "~/.sekka-jisyo")


;; ポータブル文字列置換( EmacsとXEmacsの両方で動く )
(defun sekka-replace-regexp-in-string (regexp replace str)
  (cond ((featurep 'xemacs)
	 (replace-in-string str regexp replace))
	(t
	 (replace-regexp-in-string regexp replace str))))
	

;; リージョンをローマ字漢字変換する関数
(defun sekka-henkan-region (b e)
  "指定された region を漢字変換する"
  (sekka-init)
  (when (/= b e)
    (let* (
	   (yomi (buffer-substring-no-properties b e))
	   (henkan-list (sekka-henkan-request yomi 0)))
      
      (if henkan-list
	  (condition-case err
	      (progn
		(setq
		 ;; 変換結果の保持
		 sekka-henkan-kouho-list henkan-list
		 ;; 文節選択初期化
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


;; カーソル前の文字種を返却する関数
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
;; undo 情報の制御
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo buffer 退避用変数
(defvar sekka-buffer-undo-list nil)
(make-variable-buffer-local 'sekka-buffer-undo-list)
(defvar sekka-buffer-modified-p nil)
(make-variable-buffer-local 'sekka-buffer-modified-p)

(defvar sekka-blink-cursor nil)
(defvar sekka-cursor-type nil)
;; undo buffer を退避し、undo 情報の蓄積を停止する関数
(defun sekka-disable-undo ()
  (when (not (eq buffer-undo-list t))
    (setq sekka-buffer-undo-list buffer-undo-list)
    (setq sekka-buffer-modified-p (buffer-modified-p))
    (setq buffer-undo-list t)))

;; 退避した undo buffer を復帰し、undo 情報の蓄積を再開する関数
(defun sekka-enable-undo ()
  (when (not sekka-buffer-modified-p) (set-buffer-modified-p nil))
  (when sekka-buffer-undo-list
    (setq buffer-undo-list sekka-buffer-undo-list)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 現在の変換エリアの表示を行う
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-get-display-string ()
  ;; 変換結果文字列を返す。
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
    ;; UNDO抑制開始
    (sekka-disable-undo)
    
    (delete-region b e)

    ;; リスト初期化
    (setq sekka-markers '())

    (setq sekka-last-fix "")

    ;; 変換したpointの保持
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
	    
	  ;; 確定文字列の作成
	  (setq sekka-last-fix insert-word)
	   
	  ;; 選択中の場所を装飾する。
	  (overlay-put ov 'face 'default)
	  (when select-mode
	    (overlay-put ov 'face 'highlight))
	  (setq sekka-markers (cons start end))
	  (sekka-debug-print (format "insert:[%s] point:%d-%d\n" insert-word (marker-position start) (marker-position end))))))

    ;; fenceの範囲を設定する
    (when select-mode (insert "|"))
    (setq sekka-fence-end   (point-marker))
    
    (sekka-debug-print (format "total-point:%d-%d\n"
			       (marker-position sekka-fence-start)
			       (marker-position sekka-fence-end)))
    ;; UNDO再開
    (sekka-enable-undo)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 変換候補選択モード
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((i 0))
  (while (<= i ?\177)
    (define-key sekka-select-mode-map (char-to-string i)
      'sekka-kakutei-and-self-insert)
    (setq i (1+ i))))
(define-key sekka-select-mode-map "\C-m"                   'sekka-select-kakutei)
(define-key sekka-select-mode-map "\C-g"                   'sekka-select-cancel)
(define-key sekka-select-mode-map "q"                      'sekka-select-cancel)
(define-key sekka-select-mode-map "\C-a"                   'sekka-select-kanji)
(define-key sekka-select-mode-map "\C-p"                   'sekka-select-prev)
(define-key sekka-select-mode-map "\C-n"                   'sekka-select-next)
(define-key sekka-select-mode-map sekka-rK-trans-key       'sekka-select-next)
(define-key sekka-select-mode-map " "                      'sekka-select-next)
(define-key sekka-select-mode-map "\C-u"                   'sekka-select-hiragana)
(define-key sekka-select-mode-map "\C-i"                   'sekka-select-katakana)
(define-key sekka-select-mode-map "\C-k"                   'sekka-select-katakana)
(define-key sekka-select-mode-map "\C-l"                   'sekka-select-hankaku)
(define-key sekka-select-mode-map "\C-e"                   'sekka-select-zenkaku)



;; 変換を確定し入力されたキーを再入力する関数
(defun sekka-kakutei-and-self-insert (arg)
  "候補選択を確定し、入力された文字を入力する"
  (interactive "P")
  (sekka-select-kakutei)
  (setq unread-command-events (list last-command-event)))

;; 候補選択状態での表示更新
(defun sekka-select-update-display ()
  (sekka-display-function
   (marker-position sekka-fence-start)
   (marker-position sekka-fence-end)
   sekka-select-mode))


;; 候補選択を確定する
(defun sekka-select-kakutei ()
  "候補選択を確定する"
  (interactive)
  ;; 候補番号リストをバックアップする。
  (setq sekka-cand-cur-backup sekka-cand-cur)
  ;; サーバーに確定した単語を伝える(辞書学習)
  (let* ((kouho      (nth sekka-cand-cur sekka-henkan-kouho-list))
	 (_          (sekka-debug-print (format "2:sekka-cand-cur=%s\n" sekka-cand-cur)))
	 (_          (sekka-debug-print (format "2:kouho=%s\n" kouho)))
	 (tango      (car kouho))
	 (key        (caddr kouho))
	 (kind (nth sekka-kind-index kouho)))
    (when (eq 'j kind)
      (sekka-kakutei-request key tango)))
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))


;; 候補選択をキャンセルする
(defun sekka-select-cancel ()
  "候補選択をキャンセルする"
  (interactive)
  ;; カレント候補番号をバックアップしていた候補番号で復元する。
  (setq sekka-cand-cur sekka-cand-cur-backup)
  (setq sekka-select-mode nil)
  (run-hooks 'sekka-select-mode-end-hook)
  (sekka-select-update-display))

;; 前の候補に進める
(defun sekka-select-prev ()
  "前の候補に進める"
  (interactive)
  ;; 前の候補に切りかえる
  (decf sekka-cand-cur)
  (when (> 0 sekka-cand-cur)
    (setq sekka-cand-cur (- sekka-cand-len 1)))
  (sekka-select-update-display))

;; 次の候補に進める
(defun sekka-select-next ()
  "次の候補に進める"
  (interactive)
  ;; 次の候補に切りかえる
  (setq sekka-cand-cur
	(if (< sekka-cand-cur (- sekka-cand-len 1))
	    (+ sekka-cand-cur 1)
	  0))
  (sekka-select-update-display))

;; 指定された type の候補を抜き出す
(defun sekka-select-by-type-filter ( _type )
  (let ((lst '()))
    (mapcar
     (lambda (x)
       (let ((sym (nth sekka-kind-index x)))
	 (when (eq sym _type)
	   (push x lst))))
     sekka-henkan-kouho-list)
    (sekka-debug-print (format "filterd-lst = %S" (reverse lst)))
    (car (reverse lst))))
    
;; 指定された type の候補に強制的に切りかえる
(defun sekka-select-by-type ( _type )
  (let ((kouho (sekka-select-by-type-filter _type)))
    (if (null kouho)
	(cond
	 ((eq _type 'j)
	  (message "Sekka: 漢字の候補はありません。"))
	 ((eq _type 'h)
	  (message "Sekka: ひらがなの候補はありません。"))
	 ((eq _type 'k)
	  (message "Sekka: カタカナの候補はありません。"))
	 ((eq _type 'l)
	  (message "Sekka: 半角の候補はありません。"))
	 ((eq _type 'z)
	  (message "Sekka: 全角の候補はありません。")))
      (let ((num   (nth sekka-id-index kouho)))
	(setq sekka-cand-cur num)
	(sekka-select-update-display)))))

(defun sekka-select-kanji ()
  "漢字候補に強制的に切りかえる"
  (interactive)
  (sekka-select-by-type 'j))

(defun sekka-select-hiragana ()
  "ひらがな候補に強制的に切りかえる"
  (interactive)
  (sekka-select-by-type 'h))

(defun sekka-select-katakana ()
  "カタカナ候補に強制的に切りかえる"
  (interactive)
  (sekka-select-by-type 'k))

(defun sekka-select-hankaku ()
  "半角候補に強制的に切りかえる"
  (interactive)
  (sekka-select-by-type 'l))

(defun sekka-select-zenkaku ()
  "半角候補に強制的に切りかえる"
  (interactive)
  (sekka-select-by-type 'z))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ローマ字漢字変換関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-rK-trans ()
  "ローマ字漢字変換をする。
・カーソルから行頭方向にローマ字列が続く範囲でローマ字漢字変換を行う。"
  (interactive)
;  (print last-command)			; DEBUG

  (cond 
   ;; タイマーイベントを設定しない条件
   ((or
     sekka-timer
     (> 1 sekka-realtime-guide-running-seconds)
     ))
   (t
    ;; タイマーイベント関数の登録
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

  ;; ガイド表示継続回数の更新
  (when (< 0 sekka-realtime-guide-running-seconds)
    (setq sekka-timer-rest  
	  (/ sekka-realtime-guide-running-seconds
	     sekka-realtime-guide-interval)))

  ;; 最後に変換した行番号の更新
  (setq sekka-last-lineno (line-number-at-pos (point)))

  (cond
   (sekka-select-mode
    ;; 変換中に呼出されたら、候補選択モードに移行する。
    (funcall (lookup-key sekka-select-mode-map sekka-rK-trans-key)))


   (t
    (cond

     ((eq (sekka-char-charset (preceding-char)) 'ascii)
      ;; カーソル直前が alphabet だったら
      (let ((end (point))
	    (gap (sekka-skip-chars-backward)))
	(when (/= gap 0)
	  ;; 意味のある入力が見つかったので変換する
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
    
      ;; カーソル直前が 全角で漢字以外 だったら候補選択モードに移行する。
      ;; また、最後に確定した文字列と同じかどうかも確認する。
      (when (and
	     (<= (marker-position sekka-fence-start) (point))
	     (<= (point) (marker-position sekka-fence-end))
	     (string-equal sekka-last-fix (buffer-substring 
					   (marker-position sekka-fence-start)
					   (marker-position sekka-fence-end))))
	;; 直前に変換したfenceの範囲に入っていたら、変換モードに移行する。
	(setq sekka-select-mode t)
	(sekka-debug-print "henkan mode ON\n")

	;; 表示状態を候補選択モードに切替える。
	(sekka-display-function
	 (marker-position sekka-fence-start)
	 (marker-position sekka-fence-end)
	 t))))
     )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; キャピタライズ/アンキャピタライズ変換
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sekka-capitalize-trans ()
  "キャピタライズ変換を行う
・カーソルから行頭方向にローマ字列を見つけ、先頭文字の大文字小文字を反転する"
  (interactive)

  (cond
   (sekka-select-mode
    ;; 候補選択モードでは反応しない。
    ;; do nothing
    )
   ((eq (sekka-char-charset (preceding-char)) 'ascii)
    ;; カーソル直前が alphabet だったら
    (sekka-debug-print "capitalize(2)!\n")

    (let ((end (point))
	  (gap (sekka-skip-chars-backward)))
      (when (/= gap 0)
	;; 意味のある入力が見つかったので変換する
	(let* (
	       (b (+ end gap))
	       (e end)
	       (roman-str (buffer-substring-no-properties b e)))
	  (sekka-debug-print (format "capitalize %d %d [%s]" b e roman-str))
	  (setq case-fold-search nil)
	  (cond
	   ((string-match-p "^[A-Z]" roman-str)
	    (downcase-region b (+ b 1)))
	   ((string-match-p "^[a-z]" roman-str)
	    (upcase-region   b (+ b 1))))))))
   ))


;; 全角で漢字以外の判定関数
(defun sekka-nkanji (ch)
  (and (eq (sekka-char-charset ch) 'japanese-jisx0208)
       (not (string-match "[亜-瑤]" (char-to-string ch)))))

(defun sekka-kanji (ch)
  (eq (sekka-char-charset ch) 'japanese-jisx0208))


;; ローマ字漢字変換時、変換対象とするローマ字を読み飛ばす関数
(defun sekka-skip-chars-backward ()
  (let* (
	 (skip-chars
	  (if auto-fill-function
	      ;; auto-fill-mode が有効になっている場合改行があってもskipを続ける
	      (concat sekka-skip-chars "\n")
	    ;; auto-fill-modeが無効の場合はそのまま
	    sekka-skip-chars))
	    
	 ;; マークされている位置を求める。
	 (pos (or (and (markerp (mark-marker)) (marker-position (mark-marker)))
		  1))

	 ;; 条件にマッチする間、前方方向にスキップする。
	 (result (save-excursion
		   (skip-chars-backward skip-chars (and (< pos (point)) pos))))
	 (limit-point 0))

    (if auto-fill-function
	;; auto-fill-modeが有効の時
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

	  ;; パラグラフ位置でストップする
	  (if (< (+ (point) result) limit-point)
	      (- 
	       limit-point
	       (point))
	    result))

      ;; auto-fill-modeが無効の時
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
	    ;; インデント位置でストップする。
	    (- 
	     limit-point
	     (point))
	  result)))))

  
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

(defun sekka-sticky-shift-init-function ()
  ;; sticky-shift
  (define-key global-map sticky-key sticky-map)
  (mapcar (lambda (pair)
	    (define-key sticky-map (car pair)
	      `(lambda()(interactive)
		 (if ,(< 0 (length (cdr pair)))
		     (setq unread-command-events
			   (cons ,(string-to-char (cdr pair)) unread-command-events))
		   nil))))
	  sticky-list)
  (define-key sticky-map sticky-key '(lambda ()(interactive)(insert sticky-key))))

(defun sekka-realtime-guide ()
  "リアルタイムで変換中のガイドを出す
sekka-modeがONの間中呼び出される可能性がある。"
  (cond
   ((or (null sekka-mode)
	(> 1 sekka-timer-rest))
    (cancel-timer sekka-timer)
    (setq sekka-timer nil)
    (delete-overlay sekka-guide-overlay))
   (sekka-guide-overlay
    ;; 残り回数のデクリメント
    (setq sekka-timer-rest (- sekka-timer-rest 1))

    ;; カーソルがsekka-realtime-guide-limit-lines をはみ出していないかチェック
    (sekka-debug-print (format "sekka-last-lineno [%d] : current-line" sekka-last-lineno (line-number-at-pos (point))))
    (when (< 0 sekka-realtime-guide-limit-lines)
      (let ((diff-lines (abs (- (line-number-at-pos (point)) sekka-last-lineno))))
	(when (<= sekka-realtime-guide-limit-lines diff-lines)
	  (setq sekka-timer-rest 0))))

    (let* (
	   (end (point))
	   (gap (sekka-skip-chars-backward)))
      (if 
	  (or 
	   (when (fboundp 'minibufferp)
	     (minibufferp))
	   (= gap 0))
	  ;; 上下スペースが無い または 変換対象が無しならガイドは表示しない。
	  (overlay-put sekka-guide-overlay 'before-string "")
	;; 意味のある入力が見つかったのでガイドを表示する。
	(let* (
	       (b (+ end gap))
	       (e end)
	       (str (buffer-substring-no-properties b e))
	       (lst (if (string-match "^[\s\t]+$" str)
			'()
		      (if (string= str sekka-guide-lastquery)
			  sekka-guide-lastresult
			(progn
			  (setq sekka-guide-lastquery str)
			  (setq sekka-guide-lastresult (sekka-henkan-request str 1))
			  sekka-guide-lastresult))))
	       (mess
		(if (< 0 (length lst))
		    (concat "[" (caar lst) "]")
		  "")))
	  (sekka-debug-print (format "realtime guide [%s]" str))
	  (move-overlay sekka-guide-overlay 
			;; disp-point (min (point-max) (+ disp-point 1))
			b e
			(current-buffer))
	  (overlay-put sekka-guide-overlay 'before-string mess))))
    (overlay-put sekka-guide-overlay 'face 'sekka-guide-face))))


;;;
;;; human interface
;;;
(define-key sekka-mode-map sekka-rK-trans-key 'sekka-rK-trans)
(define-key sekka-mode-map "\M-j" 'sekka-capitalize-trans)
(or (assq 'sekka-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list 
		   (cons 'sekka-mode         sekka-mode-map))
		  minor-mode-map-alist)))



;; sekka-mode の状態変更関数
;;  正の引数の場合、常に sekka-mode を開始する
;;  {負,0}の引数の場合、常に sekka-mode を終了する
;;  引数無しの場合、sekka-mode をトグルする

;; buffer 毎に sekka-mode を変更する
(defun sekka-mode (&optional arg)
  "Sekka mode は ローマ字から直接漢字変換するための minor mode です。
引数に正数を指定した場合は、Sekka mode を有効にします。

Sekka モードが有効になっている場合 \\<sekka-mode-map>\\[sekka-rK-trans] で
point から行頭方向に同種の文字列が続く間を漢字変換します。

同種の文字列とは以下のものを指します。
・半角カタカナとsekka-stop-chars に指定した文字を除く半角文字
・漢字を除く全角文字"
  (interactive "P")
  (sekka-mode-internal arg nil))

;; 全バッファで sekka-mode を変更する
(defun global-sekka-mode (&optional arg)
  "Sekka mode は ローマ字から直接漢字変換するための minor mode です。
引数に正数を指定した場合は、Sekka mode を有効にします。

Sekka モードが有効になっている場合 \\<sekka-mode-map>\\[sekka-rK-trans] で
point から行頭方向に同種の文字列が続く間を漢字変換します。

同種の文字列とは以下のものを指します。
・半角カタカナとsekka-stop-chars に指定した文字を除く半角文字
・漢字を除く全角文字"
  (interactive "P")
  (sekka-mode-internal arg t))


;; sekka-mode を変更する共通関数
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
  (when sekka-sticky-shift
    (add-hook 'sekka-mode-hook 'sekka-sticky-shift-init-function))
  (when sekka-mode (run-hooks 'sekka-mode-hook)))


;; buffer local な sekka-mode を削除する関数
(defun sekka-kill-sekka-mode ()
  (let ((buf (buffer-list)))
    (while buf
      (set-buffer (car buf))
      (kill-local-variable 'sekka-mode)
      (setq buf (cdr buf)))))


;; 全バッファで sekka-input-mode を変更する
(defun sekka-input-mode (&optional arg)
  "入力モード変更"
  (interactive "P")
  (if (< 0 arg)
      (progn
	(setq inactivate-current-input-method-function 'sekka-inactivate)
	(setq sekka-mode t))
    (setq inactivate-current-input-method-function nil)
    (setq sekka-mode nil)))


;; input method 対応
(defun sekka-activate (&rest arg)
  (sekka-input-mode 1))
(defun sekka-inactivate (&rest arg)
  (sekka-input-mode -1))
(register-input-method
 "japanese-sekka" "Japanese" 'sekka-activate
 "" "Roman -> Kanji&Kana"
 nil)

;; input-method として登録する。
(set-language-info "Japanese" 'input-method "japanese-sekka")
(setq default-input-method "japanese-sekka")

(defconst sekka-version
  "0.8.0" ;;SEKKA-VERSION
  )
(defun sekka-version (&optional arg)
  "入力モード変更"
  (interactive "P")
  (message sekka-version))

(provide 'sekka)
