;;;-*- mode: lisp-interaction; syntax: elisp ; coding: iso-2022-jp -*-"
;;
;; "sumibi.el" is a client for Sumibi server.
;;
;;   Copyright (C) 2002,2003,2004,2005 Kiyoka Nishiyama
;;   This program was derived from yc.el-4.0.13(auther: knak)
;;
;;     $Date: 2007/07/23 15:40:49 $
;;
;; This file is part of Sumibi
;;
;; Sumibi is free software; you can redistribute it and/or modify
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

;;;     配布条件: GPL
;;; 最新版配布元: http://sourceforge.jp/projects/sumibi/
;;; 
;;; 不明な点や改善したい点があればSumibiのメーリングリストに参加してフィードバックをおねがいします。
;;;
;;; また、Sumibiに興味を持っていただいた方はどなたでも
;;; 気軽にプロジェクトにご参加ください。
;;;
;;; インストール方法、使いかたは以下のWebサイトにありますのであわせて参照してください。
;;;   http://www.sumibi.org/
;;;

;;; Code:

(require 'cl)

;;; 
;;;
;;; customize variables
;;;
(defgroup sumibi nil
  "Sumibi client."
  :group 'input-method
  :group 'Japanese)

(defcustom sumibi-server-url "https://sumibi.org/cgi-bin/sumibi/testing/sumibi.cgi"
  "SumibiサーバーのURLを指定する。"
  :type  'string
  :group 'sumibi)

(defcustom sumibi-server-cert-data
  "-----BEGIN CERTIFICATE-----
MIIE3jCCA8agAwIBAgICAwEwDQYJKoZIhvcNAQEFBQAwYzELMAkGA1UEBhMCVVMx
ITAfBgNVBAoTGFRoZSBHbyBEYWRkeSBHcm91cCwgSW5jLjExMC8GA1UECxMoR28g
RGFkZHkgQ2xhc3MgMiBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0wNjExMTYw
MTU0MzdaFw0yNjExMTYwMTU0MzdaMIHKMQswCQYDVQQGEwJVUzEQMA4GA1UECBMH
QXJpem9uYTETMBEGA1UEBxMKU2NvdHRzZGFsZTEaMBgGA1UEChMRR29EYWRkeS5j
b20sIEluYy4xMzAxBgNVBAsTKmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5j
b20vcmVwb3NpdG9yeTEwMC4GA1UEAxMnR28gRGFkZHkgU2VjdXJlIENlcnRpZmlj
YXRpb24gQXV0aG9yaXR5MREwDwYDVQQFEwgwNzk2OTI4NzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMQt1RWMnCZM7DI161+4WQFapmGBWTtwY6vj3D3H
KrjJM9N55DrtPDAjhI6zMBS2sofDPZVUBJ7fmd0LJR4h3mUpfjWoqVTr9vcyOdQm
VZWt7/v+WIbXnvQAjYwqDL1CBM6nPwT27oDyqu9SoWlm2r4arV3aLGbqGmu75RpR
SgAvSMeYddi5Kcju+GZtCpyz8/x4fKL4o/K1w/O5epHBp+YlLpyo7RJlbmr2EkRT
cDCVw5wrWCs9CHRK8r5RsL+H0EwnWGu1NcWdrxcx+AuP7q2BNgWJCJjPOq8lh8BJ
6qf9Z/dFjpfMFDniNoW1fho3/Rb2cRGadDAW/hOUoz+EDU8CAwEAAaOCATIwggEu
MB0GA1UdDgQWBBT9rGEyk2xF1uLuhV+auud2mWjM5zAfBgNVHSMEGDAWgBTSxLDS
kdRMEXGzYcs9of7dqGrU4zASBgNVHRMBAf8ECDAGAQH/AgEAMDMGCCsGAQUFBwEB
BCcwJTAjBggrBgEFBQcwAYYXaHR0cDovL29jc3AuZ29kYWRkeS5jb20wRgYDVR0f
BD8wPTA7oDmgN4Y1aHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNvbS9yZXBv
c2l0b3J5L2dkcm9vdC5jcmwwSwYDVR0gBEQwQjBABgRVHSAAMDgwNgYIKwYBBQUH
AgEWKmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5jb20vcmVwb3NpdG9yeTAO
BgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQEFBQADggEBANKGwOy9+aG2Z+5mC6IG
OgRQjhVyrEp0lVPLN8tESe8HkGsz2ZbwlFalEzAFPIUyIXvJxwqoJKSQ3kbTJSMU
A2fCENZvD117esyfxVgqwcSeIaha86ykRvOe5GPLL5CkKSkB2XIsKd83ASe8T+5o
0yGPwLPk9Qnt0hCqU7S+8MxZC9Y7lhyVJEnfzuz9p0iRFEUOOjZv2kWzRaJBydTX
RE4+uXR21aITVSzGh6O1mawGhId/dQb8vxRMDsxuxN89txJx9OjxUUAiKEngHUuH
qDTMBqLdElrRhjZkAzVvb3du6/KFUJheqwNTrZEjYx8WnM25sgVjOuH0aBsXBTWV
U+4=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIE+zCCBGSgAwIBAgICAQ0wDQYJKoZIhvcNAQEFBQAwgbsxJDAiBgNVBAcTG1Zh
bGlDZXJ0IFZhbGlkYXRpb24gTmV0d29yazEXMBUGA1UEChMOVmFsaUNlcnQsIElu
Yy4xNTAzBgNVBAsTLFZhbGlDZXJ0IENsYXNzIDIgUG9saWN5IFZhbGlkYXRpb24g
QXV0aG9yaXR5MSEwHwYDVQQDExhodHRwOi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAe
BgkqhkiG9w0BCQEWEWluZm9AdmFsaWNlcnQuY29tMB4XDTA0MDYyOTE3MDYyMFoX
DTI0MDYyOTE3MDYyMFowYzELMAkGA1UEBhMCVVMxITAfBgNVBAoTGFRoZSBHbyBE
YWRkeSBHcm91cCwgSW5jLjExMC8GA1UECxMoR28gRGFkZHkgQ2xhc3MgMiBDZXJ0
aWZpY2F0aW9uIEF1dGhvcml0eTCCASAwDQYJKoZIhvcNAQEBBQADggENADCCAQgC
ggEBAN6d1+pXGEmhW+vXX0iG6r7d/+TvZxz0ZWizV3GgXne77ZtJ6XCAPVYYYwhv
2vLM0D9/AlQiVBDYsoHUwHU9S3/Hd8M+eKsaA7Ugay9qK7HFiH7Eux6wwdhFJ2+q
N1j3hybX2C32qRe3H3I2TqYXP2WYktsqbl2i/ojgC95/5Y0V4evLOtXiEqITLdiO
r18SPaAIBQi2XKVlOARFmR6jYGB0xUGlcmIbYsUfb18aQr4CUWWoriMYavx4A6lN
f4DD+qta/KFApMoZFv6yyO9ecw3ud72a9nmYvLEHZ6IVDd2gWMZEewo+YihfukEH
U1jPEX44dMX4/7VpkI+EdOqXG68CAQOjggHhMIIB3TAdBgNVHQ4EFgQU0sSw0pHU
TBFxs2HLPaH+3ahq1OMwgdIGA1UdIwSByjCBx6GBwaSBvjCBuzEkMCIGA1UEBxMb
VmFsaUNlcnQgVmFsaWRhdGlvbiBOZXR3b3JrMRcwFQYDVQQKEw5WYWxpQ2VydCwg
SW5jLjE1MDMGA1UECxMsVmFsaUNlcnQgQ2xhc3MgMiBQb2xpY3kgVmFsaWRhdGlv
biBBdXRob3JpdHkxITAfBgNVBAMTGGh0dHA6Ly93d3cudmFsaWNlcnQuY29tLzEg
MB4GCSqGSIb3DQEJARYRaW5mb0B2YWxpY2VydC5jb22CAQEwDwYDVR0TAQH/BAUw
AwEB/zAzBggrBgEFBQcBAQQnMCUwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLmdv
ZGFkZHkuY29tMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jZXJ0aWZpY2F0ZXMu
Z29kYWRkeS5jb20vcmVwb3NpdG9yeS9yb290LmNybDBLBgNVHSAERDBCMEAGBFUd
IAAwODA2BggrBgEFBQcCARYqaHR0cDovL2NlcnRpZmljYXRlcy5nb2RhZGR5LmNv
bS9yZXBvc2l0b3J5MA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQUFAAOBgQC1
QPmnHfbq/qQaQlpE9xXUhUaJwL6e4+PrxeNYiY+Sn1eocSxI0YGyeR+sBjUZsE4O
WBsUs5iB0QQeyAfJg594RAoYC5jcdnplDQ1tgMQLARzLrUc+cb53S8wGd9D0Vmsf
SxOaFIqII6hR8INMqzW/Rn453HWkrugp++85j09VZw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIC5zCCAlACAQEwDQYJKoZIhvcNAQEFBQAwgbsxJDAiBgNVBAcTG1ZhbGlDZXJ0
IFZhbGlkYXRpb24gTmV0d29yazEXMBUGA1UEChMOVmFsaUNlcnQsIEluYy4xNTAz
BgNVBAsTLFZhbGlDZXJ0IENsYXNzIDIgUG9saWN5IFZhbGlkYXRpb24gQXV0aG9y
aXR5MSEwHwYDVQQDExhodHRwOi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAeBgkqhkiG
9w0BCQEWEWluZm9AdmFsaWNlcnQuY29tMB4XDTk5MDYyNjAwMTk1NFoXDTE5MDYy
NjAwMTk1NFowgbsxJDAiBgNVBAcTG1ZhbGlDZXJ0IFZhbGlkYXRpb24gTmV0d29y
azEXMBUGA1UEChMOVmFsaUNlcnQsIEluYy4xNTAzBgNVBAsTLFZhbGlDZXJ0IENs
YXNzIDIgUG9saWN5IFZhbGlkYXRpb24gQXV0aG9yaXR5MSEwHwYDVQQDExhodHRw
Oi8vd3d3LnZhbGljZXJ0LmNvbS8xIDAeBgkqhkiG9w0BCQEWEWluZm9AdmFsaWNl
cnQuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDOOnHK5avIWZJV16vY
dA757tn2VUdZZUcOBVXc65g2PFxTXdMwzzjsvUGJ7SVCCSRrCl6zfN1SLUzm1NZ9
WlmpZdRJEy0kTRxQb7XBhVQ7/nHk01xC+YDgkRoKWzk2Z/M/VXwbP7RfZHM047QS
v4dk+NoS/zcnwbNDu+97bi5p9wIDAQABMA0GCSqGSIb3DQEBBQUAA4GBADt/UG9v
UJSZSWI4OB9L+KXIPqeCgfYrx+jFzug6EILLGACOTb2oWH+heQC1u+mNr0HZDzTu
IYEZoDJJKPTEjlbVUjP9UNV+mWwD5MlM/Mtsq2azSiGM5bUMMj4QssxsodyamEwC
W/POuZ6lcg5Ktz885hZo+L7tdEy8W9ViH0Pd
-----END CERTIFICATE-----
"
  "Sumibiサーバーと通信する時のSSL証明書データ。"
  :type  'string
  :group 'sumibi)

(defcustom sumibi-server-use-cert t
  "Sumibiサーバーと通信する時のSSL証明書を使うかどうか。"
  :type  'symbol
  :group 'sumibi)

(defcustom sumibi-server-timeout 10
  "Sumibiサーバーと通信する時のタイムアウトを指定する。(秒数)"
  :type  'integer
  :group 'sumibi)
 
(defcustom sumibi-stop-chars ";:(){}<>"
  "*漢字変換文字列を取り込む時に変換範囲に含めない文字を設定する"
  :type  'string
  :group 'sumibi)

(defcustom sumibi-replace-keyword-list '(
					 ("no" . "no.h")
					 ("ha" . "ha.h")
					 ("ga" . "ga.h")
					 ("wo" . "wo.h")
					 ("ni" . "ni.h")
					 ("de" . "de.h"))

  "Sumibiサーバーに文字列を送る前に置換するキーワードを設定する"
  :type  'sexp
  :group 'sumibi)

(defcustom sumibi-curl "curl"
  "curlコマンドの絶対パスを設定する"
  :type  'string
  :group 'sumibi)

(defcustom sumibi-use-viper nil
  "*Non-nil であれば、VIPER に対応する"
  :type 'boolean
  :group 'sumibi)

(defcustom sumibi-realtime-guide-running-seconds 60
  "リアルタイムガイド表示の継続時間(秒数)・ゼロでガイド表示機能が無効になる"
  :type  'integer
  :group 'sumibi)

(defcustom sumibi-realtime-guide-interval  0.5
  "リアルタイムガイド表示を更新する時間間隔"
  :type  'integer
  :group 'sumibi)

(defcustom sumibi-history-filename  "~/.sumibi_history"
  "ユーザー固有の変換履歴を保存するファイル名"
  :type  'string
  :group 'sumibi)

(defcustom sumibi-history-feature  t
  "Non-nilであれば、ユーザー固有の変換履歴を有効にする"
  :type  'boolean
  :group 'sumibi)

(defcustom sumibi-history-max  100
  "ユーザー固有の変換履歴の最大保存件数を指定する(最新から指定件数のみが保存される)"
  :type  'integer
  :group 'sumibi)


(defface sumibi-guide-face
  '((((class color) (background light)) (:background "#E0E0E0" :foreground "#F03030")))
  "リアルタイムガイドのフェイス(装飾、色などの指定)"
  :group 'sumibi)


(defvar sumibi-mode nil             "漢字変換トグル変数")
(defvar sumibi-mode-line-string     " Sumibi")
(defvar sumibi-select-mode nil      "候補選択モード変数")
(or (assq 'sumibi-mode minor-mode-alist)
    (setq minor-mode-alist (cons
			    '(sumibi-mode        sumibi-mode-line-string)
			    minor-mode-alist)))


;; ローマ字漢字変換時、対象とするローマ字を設定するための変数
(defvar sumibi-skip-chars "a-zA-Z0-9 .,\\-+!\\[\\]?")
(defvar sumibi-mode-map        (make-sparse-keymap)         "漢字変換トグルマップ")
(defvar sumibi-select-mode-map (make-sparse-keymap)         "候補選択モードマップ")
(defvar sumibi-rK-trans-key "\C-j"
  "*漢字変換キーを設定する")
(or (assq 'sumibi-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list (cons 'sumibi-mode         sumibi-mode-map)
			(cons 'sumibi-select-mode  sumibi-select-mode-map))
		  minor-mode-map-alist)))

;; ユーザー学習辞書
(defvar sumibi-kakutei-history          '())    ;; ( ( unix時間 単語IDのリスト ) ( unix時間 9412 1028 ) )
(defvar sumibi-kakutei-history-saved    '())    ;; ファイルに保存されたほうのヒストリデータ)

;;;
;;; hooks
;;;
(defvar sumibi-mode-hook nil)
(defvar sumibi-select-mode-hook nil)
(defvar sumibi-select-mode-end-hook nil)

(defconst sumibi-kind-index   0)
(defconst sumibi-tango-index  1)
(defconst sumibi-id-index     2)
(defconst sumibi-wordno-index 3)
(defconst sumibi-candno-index 4)
(defconst sumibi-spaces-index 5)

(defconst sumibi-hiragana->katakana-table
  (mapcar
   (lambda (c)
     (cons
      (char-to-string c)
      (char-to-string
       (+ c
	  (- 
	   (string-to-char "ア")
	   (string-to-char "あ"))))))
   (string-to-list
    (concat 
     "あいうえお"
     "ぁぃぅぇぉ"
     "かきくけこ"
     "がぎぐげご"
     "さしすせそ"
     "ざじずぜぞ"
     "たちつてと"
     "だづづでど"
     "なにぬねの"
     "はひふへほ"
     "ばびぶべぼ"
     "ぱぴぷぺぽ"
     "まみむめも"
     "やゆよ"
     "ゃゅょ"
     "らりるれろ"
     "わを"
     "っん"))))


(defconst sumibi-roman->kana-table
  '(("kkya" . "っきゃ")
    ("kkyu" . "っきゅ")
    ("kkyo" . "っきょ")
    ("ggya" . "っぎゃ")
    ("ggyu" . "っぎゅ")
    ("ggyo" . "っぎょ")
    ("sshi" . "っし")
    ("ssha" . "っしゃ")
    ("sshu" . "っしゅ")
    ("sshe" . "っしぇ")
    ("ssho" . "っしょ")
    ("cchi" . "っち")
    ("ccha" . "っちゃ")
    ("cchu" . "っちゅ")
    ("cche" . "っちぇ")
    ("ccho" . "っちょ")
    ("ddya" . "っぢゃ")
    ("ddyu" . "っぢゅ")
    ("ddye" . "っぢぇ")
    ("ddyo" . "っぢょ")
    ("ttsu" . "っつ")
    ("hhya" . "っひゃ")
    ("hhyu" . "っひゅ")
    ("hhyo" . "っひょ")
    ("bbya" . "っびゃ")
    ("bbyu" . "っびゅ")
    ("bbyo" . "っびょ")
    ("ppya" . "っぴゃ")
    ("ppyu" . "っぴゅ")
    ("ppyo" . "っぴょ")
    ("rrya" . "っりゃ")
    ("rryu" . "っりゅ")
    ("rryo" . "っりょ")
    ("ddyi" . "っでぃ")
    ("ddhi" . "っでぃ")
    ("xtsu" . "っ")
    ("ttya" . "っちゃ")
    ("ttyi" . "っち")
    ("ttyu" . "っちゅ")
    ("ttye" . "っちぇ")
    ("ttyo" . "っちょ")
    ("kya" . "きゃ")
    ("kyu" . "きゅ")
    ("kyo" . "きょ")
    ("gya" . "ぎゃ")
    ("gyu" . "ぎゅ")
    ("gyo" . "ぎょ")
    ("shi" . "し")
    ("sha" . "しゃ")
    ("shu" . "しゅ")
    ("she" . "しぇ")
    ("sho" . "しょ")
    ("chi" . "ち")
    ("cha" . "ちゃ")
    ("chu" . "ちゅ")
    ("che" . "ちぇ")
    ("cho" . "ちょ")
    ("dya" . "ぢゃ")
    ("dyu" . "ぢゅ")
    ("dye" . "ぢぇ")
    ("dyo" . "ぢょ")
    ("vvu" . "っう゛")
    ("vva" . "っう゛ぁ")
    ("vvi" . "っう゛ぃ")
    ("vve" . "っう゛ぇ")
    ("vvo" . "っう゛ぉ")
    ("kka" . "っか")
    ("gga" . "っが")
    ("kki" . "っき")
    ("ggi" . "っぎ")
    ("kku" . "っく")
    ("ggu" . "っぐ")
    ("kke" . "っけ")
    ("gge" . "っげ")
    ("kko" . "っこ")
    ("ggo" . "っご")
    ("ssa" . "っさ")
    ("zza" . "っざ")
    ("jji" . "っじ")
    ("jja" . "っじゃ")
    ("jju" . "っじゅ")
    ("jje" . "っじぇ")
    ("jjo" . "っじょ")
    ("ssu" . "っす")
    ("zzu" . "っず")
    ("sse" . "っせ")
    ("zze" . "っぜ")
    ("sso" . "っそ")
    ("zzo" . "っぞ")
    ("tta" . "った")
    ("dda" . "っだ")
    ("ddi" . "っぢ")
    ("ddu" . "っづ")
    ("tte" . "って")
    ("dde" . "っで")
    ("tto" . "っと")
    ("ddo" . "っど")
    ("hha" . "っは")
    ("bba" . "っば")
    ("ppa" . "っぱ")
    ("hhi" . "っひ")
    ("bbi" . "っび")
    ("ppi" . "っぴ")
    ("ffu" . "っふ")
    ("ffa" . "っふぁ")
    ("ffi" . "っふぃ")
    ("ffe" . "っふぇ")
    ("ffo" . "っふぉ")
    ("bbu" . "っぶ")
    ("ppu" . "っぷ")
    ("hhe" . "っへ")
    ("bbe" . "っべ")
    ("ppe" . "っぺ")
    ("hho" . "っほ")
    ("bbo" . "っぼ")
    ("ppo" . "っぽ")
    ("yya" . "っや")
    ("yyu" . "っゆ")
    ("yyo" . "っよ")
    ("rra" . "っら")
    ("rri" . "っり")
    ("rru" . "っる")
    ("rre" . "っれ")
    ("rro" . "っろ")
    ("tsu" . "つ")
    ("nya" . "にゃ")
    ("nyu" . "にゅ")
    ("nyo" . "にょ")
    ("hya" . "ひゃ")
    ("hyu" . "ひゅ")
    ("hyo" . "ひょ")
    ("bya" . "びゃ")
    ("byu" . "びゅ")
    ("byo" . "びょ")
    ("pya" . "ぴゃ")
    ("pyu" . "ぴゅ")
    ("pyo" . "ぴょ")
    ("mya" . "みゃ")
    ("myu" . "みゅ")
    ("myo" . "みょ")
    ("xya" . "ゃ")
    ("xyu" . "ゅ")
    ("xyo" . "ょ")
    ("rya" . "りゃ")
    ("ryu" . "りゅ")
    ("ryo" . "りょ")
    ("xwa" . "ゎ")
    ("dyi" . "でぃ")
    ("thi" . "てぃ")
    ("hhu" . "っふ")
    ("shu" . "しゅ")
    ("chu" . "ちゅ")
    ("sya" . "しゃ")
    ("syu" . "しゅ")
    ("sye" . "しぇ")
    ("syo" . "しょ")
    ("jya" . "じゃ")
    ("jyu" . "じゅ")
    ("jye" . "じぇ")
    ("jyo" . "じょ")
    ("zya" . "じゃ")
    ("zyu" . "じゅ")
    ("zye" . "じぇ")
    ("zyo" . "じょ")
    ("tya" . "ちゃ")
    ("tyi" . "ち")
    ("tyu" . "ちゅ")
    ("tye" . "ちぇ")
    ("tyo" . "ちょ")
    ("dhi" . "でぃ")
    ("xtu" . "っ")
    ("xa" . "ぁ")
    ("xi" . "ぃ")
    ("xu" . "ぅ")
    ("vu" . "う゛")
    ("va" . "う゛ぁ")
    ("vi" . "う゛ぃ")
    ("ve" . "う゛ぇ")
    ("vo" . "う゛ぉ")
    ("xe" . "ぇ")
    ("xo" . "ぉ")
    ("ka" . "か")
    ("ga" . "が")
    ("ki" . "き")
    ("gi" . "ぎ")
    ("ku" . "く")
    ("gu" . "ぐ")
    ("ke" . "け")
    ("ge" . "げ")
    ("ko" . "こ")
    ("go" . "ご")
    ("sa" . "さ")
    ("za" . "ざ")
    ("ji" . "じ")
    ("ja" . "じゃ")
    ("ju" . "じゅ")
    ("je" . "じぇ")
    ("jo" . "じょ")
    ("su" . "す")
    ("zu" . "ず")
    ("se" . "せ")
    ("ze" . "ぜ")
    ("so" . "そ")
    ("zo" . "ぞ")
    ("ta" . "た")
    ("da" . "だ")
    ("di" . "ぢ")
    ("tt" . "っ")
    ("du" . "づ")
    ("te" . "て")
    ("de" . "で")
    ("to" . "と")
    ("do" . "ど")
    ("na" . "な")
    ("ni" . "に")
    ("nu" . "ぬ")
    ("ne" . "ね")
    ("no" . "の")
    ("ha" . "は")
    ("ba" . "ば")
    ("pa" . "ぱ")
    ("hi" . "ひ")
    ("bi" . "び")
    ("pi" . "ぴ")
    ("fu" . "ふ")
    ("fa" . "ふぁ")
    ("fi" . "ふぃ")
    ("fe" . "ふぇ")
    ("fo" . "ふぉ")
    ("bu" . "ぶ")
    ("pu" . "ぷ")
    ("he" . "へ")
    ("be" . "べ")
    ("pe" . "ぺ")
    ("ho" . "ほ")
    ("bo" . "ぼ")
    ("po" . "ぽ")
    ("ma" . "ま")
    ("mi" . "み")
    ("mu" . "む")
    ("me" . "め")
    ("mo" . "も")
    ("ya" . "や")
    ("yu" . "ゆ")
    ("yo" . "よ")
    ("ra" . "ら")
    ("ri" . "り")
    ("ru" . "る")
    ("re" . "れ")
    ("ro" . "ろ")
    ("wa" . "わ")
    ("wi" . "ゐ")
    ("we" . "ゑ")
    ("wo" . "を")
    ("n'" . "ん")
    ("nn" . "ん")
    ("ca" . "か")
    ("ci" . "き")
    ("cu" . "く")
    ("ce" . "け")
    ("co" . "こ")
    ("si" . "し")
    ("ti" . "ち")
    ("hu" . "ふ")
    ("tu" . "つ")
    ("zi" . "じ")
    ("la" . "ぁ")
    ("li" . "ぃ")
    ("lu" . "ぅ")
    ("le" . "ぇ")
    ("lo" . "ぉ")
    ("a" . "あ")
    ("i" . "い")
    ("u" . "う")
    ("e" . "え")
    ("o" . "お")
    ("n" . "ん")
    ("-" . "ー")
    ("^" . "ー")))


;;--- デバッグメッセージ出力
(defvar sumibi-debug nil)		; デバッグフラグ
(defun sumibi-debug-print (string)
  (if sumibi-debug
      (let
	  ((buffer (get-buffer-create "*sumibi-debug*")))
	(with-current-buffer buffer
	  (goto-char (point-max))
	  (insert string)))))


;;; sumibi basic output
(defvar sumibi-fence-start nil)		; fence 始端位置
(defvar sumibi-fence-end nil)		; fence 終端位置
(defvar sumibi-henkan-separeter " ")	; fence mode separeter
(defvar sumibi-henkan-buffer nil)	; 表示用バッファ
(defvar sumibi-henkan-length nil)	; 表示用バッファ長
(defvar sumibi-henkan-revpos nil)	; 文節始端位置
(defvar sumibi-henkan-revlen nil)	; 文節長

;;; sumibi basic local
(defvar sumibi-cand     nil)		; カレント文節番号
(defvar sumibi-cand-n   nil)		; 文節候補番号
(defvar sumibi-cand-n-backup   nil)	; 文節候補番号 ( 候補選択キャンセル用 )
(defvar sumibi-cand-max nil)		; 文節候補数
(defvar sumibi-last-fix "")		; 最後に確定した文字列
(defvar sumibi-henkan-list nil)		; 文節リスト
(defvar sumibi-repeat 0)		; 繰り返し回数
(defvar sumibi-marker-list '())		; 文節開始、終了位置リスト: 次のような形式 ( ( 1 . 2 ) ( 5 . 7 ) ... ) 
(defvar sumibi-timer    nil)            ; インターバルタイマー型変数
(defvar sumibi-timer-rest  0)           ; あと何回呼出されたら、インターバルタイマの呼出を止めるか
(defvar sumibi-guide-overlay   nil)     ; リアルタイムガイドに使用するオーバーレイ
(defvar sumibi-last-request-time 0)     ; Sumibiサーバーにリクエストした最後の時刻(単位は秒)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 表示系関数群
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar sumibi-use-fence t)
(defvar sumibi-use-color nil)

(defvar sumibi-init nil)
(defvar sumibi-server-cert-file nil)

;;
;; 初期化
;;
(defun sumibi-init ()
  ;; 最初の n 件のリストを取得する
  (defun sumibi-take (arg-list n)
    (let ((lst '()))
      (dotimes (i n (reverse lst))
	(let ((item (nth i arg-list)))
	  (when item
	    (push item lst))))))

  ;; ヒストリファイルとメモリ中のヒストリデータをマージする
  (defun sumibi-merge-kakutei-history (base-list new-list)
    (let ((merged-num  '())
	  (merged-list '()))
      (mapcar
       (lambda (x)
	 (when (not (member (car x) merged-num))
	   (progn
	     (push (car x) merged-num)
	     (push      x  merged-list))))
       (append
	base-list
	new-list))
      merged-list))

  ;; テンポラリファイルを作成する。
  (defun sumibi-make-temp-file (base)
    (if	(functionp 'make-temp-file)
	(make-temp-file base)
      (concat "/tmp/" (make-temp-name base))))

  (when (not sumibi-init)
    ;; SSL証明書ファイルをテンポラリファイルとして作成する。
    (setq sumibi-server-cert-file 
	  (sumibi-make-temp-file
	   "sumibi.certfile"))
    (sumibi-debug-print (format "cert-file :[%s]\n" sumibi-server-cert-file))
    (with-temp-buffer
      (insert sumibi-server-cert-data)
      (write-region (point-min) (point-max) sumibi-server-cert-file  nil nil))

    (when (and
	   sumibi-history-feature
	   (file-exists-p sumibi-history-filename))
      (progn
	(load-file sumibi-history-filename)
	(setq sumibi-kakutei-history sumibi-kakutei-history-saved)))

    ;; Emacs終了時SSL証明書ファイルを削除する。
    (add-hook 'kill-emacs-hook
	      (lambda ()
		;; ユーザー変換履歴をマージして保存する
		(when sumibi-history-feature
		  (progn
		    ;; 現在のファイルを再度読みこむ(別のEmacsプロセスが更新しているかも知れない為)
		    (when (file-exists-p sumibi-history-filename)
		      (load-file sumibi-history-filename))
		    (with-temp-file
			sumibi-history-filename
		      (insert (format "(setq sumibi-kakutei-history-saved '%s)" 
				      (let ((lst
					     (sumibi-take 
					      (sumibi-merge-kakutei-history
					       sumibi-kakutei-history-saved
					       sumibi-kakutei-history)
					      sumibi-history-max)))
					(if (functionp 'pp-to-string)
					    (pp-to-string lst)
					  (prin1-to-string lst))))))))
		;; SSL証明書のテンポラリファイルを削除する
		(when (file-exists-p sumibi-server-cert-file)
		  (delete-file sumibi-server-cert-file))))
    
    ;; 初期化完了
    (setq sumibi-init t)))


;;
;; ローマ字で書かれた文章をSumibiサーバーを使って変換する
;;
(defun sumibi-soap-request (func-name arg-list)
  (let (
	(command
	 (concat
	  sumibi-curl " --silent --show-error "
	  (format " --max-time %d " sumibi-server-timeout)
	  (if sumibi-server-use-cert
	    (if (not sumibi-server-cert-file)
		(error "Error : cert file create miss!")
	      (format "--cacert '%s' " sumibi-server-cert-file))
	    " --insecure ")
	  (format " --header 'Content-Type: text/xml' ")
	  (format " --header 'SOAPAction:urn:SumibiConvert#%s' " func-name)
	  sumibi-server-url " "
	  (format (concat "--data '"
			  "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
			  "  <SOAP-ENV:Envelope xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\""
			  "   SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\""
			  "   xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\""
			  "   xmlns:xsi=\"http://www.w3.org/1999/XMLSchema-instance\""
			  "   xmlns:xsd=\"http://www.w3.org/1999/XMLSchema\">"
			  "  <SOAP-ENV:Body>"
			  "    <namesp1:%s xmlns:namesp1=\"urn:SumibiConvert\">"
			  (mapconcat
			   (lambda (x)
			     (format "    <in xsi:type=\"xsd:string\">%s</in>" x))
			   arg-list
			   " ")
			  "    </namesp1:%s>"
			  "  </SOAP-ENV:Body>"
			  "</SOAP-ENV:Envelope>"
			  "' ")
		  func-name
		  func-name
		  func-name
		  func-name
		  ))))

    (sumibi-debug-print (format "curl-command :%s\n" command))

    (let* (
	   (_xml
	    (shell-command-to-string
	     command))
	   (_match
	    (string-match "<s-gensym3[^>]+>\\(.+\\)</s-gensym3>" _xml)))
	   
      (sumibi-debug-print (format "curl-result-xml :%s\n" _xml))

      (if _match 
	  (decode-coding-string
	   (base64-decode-string 
	    (match-string 1 _xml))
	   'euc-jp)
	_xml))))

      
;;
;; 現在時刻をUNIXタイムを返す(単位は秒)
;;
(defun sumibi-current-unixtime ()
  (let (
	(_ (current-time)))
    (+
     (* (car _)
	65536)
     (cadr _))))


;;
;; ローマ字で書かれた文章をSumibiサーバーを使って変換する
;;
(defun sumibi-henkan-request (yomi)
  (sumibi-debug-print (format "henkan-input :[%s]\n"  yomi))

  (message "Requesting to sumibi server...")
  
  (let* (
	 (result (sumibi-soap-request "doSumibiConvertSexp" (list yomi
								  ""
								  (sumibi-get-history-string
								   sumibi-kakutei-history)))))
    (sumibi-debug-print (format "henkan-result:%S\n" result))
    (if (eq (string-to-char result) ?\( )
	(progn
	  (sumibi-next-history)
	  (message nil)
	  (condition-case err
	      (read result)
	    (end-of-file
	     (progn
	       (message "Parse error for parsing result of Sumibi Server.")
	       nil))))
      (progn
	(message result)
	nil))))


;; ポータブル文字列置換( EmacsとXEmacsの両方で動く )
(defun sumibi-replace-regexp-in-string (regexp replace str)
  (cond ((featurep 'xemacs)
	 (replace-in-string str regexp replace))
	(t
	 (replace-regexp-in-string regexp replace str))))
	

;; 置換キーワードを解決する
(defun sumibi-replace-keyword (str)
  (let (
	;; 改行を一つのスペースに置換して、
	;; キーワード置換処理の前処理として行頭と行末にスペースを追加する。
	(replaced 
	 (concat " " 
		 (sumibi-replace-regexp-in-string 
		  "[\n]"
		  " "
		  str)
		 " ")))

    (mapcar
     (lambda (x)
       (setq replaced 
	     (sumibi-replace-regexp-in-string 
	      (concat " " (car x) " ")
	      (concat " " (cdr x) " ")
	      replaced)))
     sumibi-replace-keyword-list)
    replaced))

;; リージョンをローマ字漢字変換する関数
(defun sumibi-henkan-region (b e)
  "指定された region を漢字変換する"
  (sumibi-init)
  (when (/= b e)
    (let* (
	   (yomi (buffer-substring-no-properties b e))
	   (henkan-list (sumibi-henkan-request (sumibi-replace-keyword yomi))))
      
      (if henkan-list
	  (condition-case err
	      (progn
		(setq
		 ;; 変換結果の保持
		 sumibi-henkan-list henkan-list
		 ;; 文節選択初期化
		 sumibi-cand-n   (make-list (length henkan-list) 0)
		 ;; 
		 sumibi-cand-max (mapcar
				  (lambda (x)
				    (length x))
				  henkan-list))
		
		(sumibi-debug-print (format "sumibi-henkan-list:%s \n" sumibi-henkan-list))
		(sumibi-debug-print (format "sumibi-cand-n:%s \n" sumibi-cand-n))
		(sumibi-debug-print (format "sumibi-cand-max:%s \n" sumibi-cand-max))
		;;
		t)
	    (sumibi-trap-server-down
	     (beep)
	     (message (error-message-string err))
	     (setq sumibi-select-mode nil))
	    (run-hooks 'sumibi-select-mode-end-hook))
	nil))))


;; カーソル前の文字種を返却する関数
(eval-and-compile
  (if (>= emacs-major-version 20)
      (progn
	(defalias 'sumibi-char-charset (symbol-function 'char-charset))
	(when (and (boundp 'byte-compile-depth)
		   (not (fboundp 'char-category)))
	  (defalias 'char-category nil))) ; for byte compiler
    (defun sumibi-char-charset (ch)
      (cond ((equal (char-category ch) "a") 'ascii)
	    ((equal (char-category ch) "k") 'katakana-jisx0201)
	    ((string-match "[SAHK]j" (char-category ch)) 'japanese-jisx0208)
	    (t nil) )) ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo 情報の制御
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; undo buffer 退避用変数
(defvar sumibi-buffer-undo-list nil)
(make-variable-buffer-local 'sumibi-buffer-undo-list)
(defvar sumibi-buffer-modified-p nil)
(make-variable-buffer-local 'sumibi-buffer-modified-p)

(defvar sumibi-blink-cursor nil)
(defvar sumibi-cursor-type nil)
;; undo buffer を退避し、undo 情報の蓄積を停止する関数
(defun sumibi-disable-undo ()
  (when (not (eq buffer-undo-list t))
    (setq sumibi-buffer-undo-list buffer-undo-list)
    (setq sumibi-buffer-modified-p (buffer-modified-p))
    (setq buffer-undo-list t)))

;; 退避した undo buffer を復帰し、undo 情報の蓄積を再開する関数
(defun sumibi-enable-undo ()
  (when (not sumibi-buffer-modified-p) (set-buffer-modified-p nil))
  (when sumibi-buffer-undo-list
    (setq buffer-undo-list sumibi-buffer-undo-list)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 現在の変換エリアの表示を行う
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sumibi-get-display-string ()
  (let ((cnt 0))
    (mapconcat
     (lambda (x)
       ;; 変換結果文字列を返す。
       (let ((word (nth (nth cnt sumibi-cand-n) x)))
	 (sumibi-debug-print (format "word:[%d] %s\n" cnt word))
	 (setq cnt (+ 1 cnt))
	 (nth sumibi-tango-index word)))
     sumibi-henkan-list
     "")))


(defun sumibi-display-function (b e select-mode)
  (setq sumibi-henkan-separeter (if sumibi-use-fence " " ""))
  (when sumibi-henkan-list
    ;; UNDO抑制開始
    (sumibi-disable-undo)

    (delete-region b e)

    ;; リスト初期化
    (setq sumibi-marker-list '())

    (let (
	   (cnt 0))

      (setq sumibi-last-fix "")

      ;; 変換したpointの保持
      (setq sumibi-fence-start (point-marker))
      (when select-mode (insert "|"))

      (mapcar
       (lambda (x)
	 (if (and
	      (not (eq (preceding-char) ?\ ))
	      (not (eq (point-at-bol) (point)))
	      (eq (sumibi-char-charset (preceding-char)) 'ascii)
	      (and
	       (< 0 (length (cadar x)))
	       (eq (sumibi-char-charset (string-to-char (cadar x))) 'ascii)))
	     (insert " "))

	 (let* (
		(start       (point-marker))
		(_n          (nth cnt sumibi-cand-n))
		(_max        (nth cnt sumibi-cand-max))
		(spaces      (nth sumibi-spaces-index (nth _n x)))
		(insert-word (nth sumibi-tango-index  (nth _n x)))
		(_insert-word
		 ;; スペースが2個以上入れられたら、1個のスペースを入れる。(但し、auto-fill-modeが無効の場合のみ)
		 (if (and (< 1 spaces) (not auto-fill-function))
		     (concat " " insert-word)
		   insert-word))
		(ank-word    (cadr (assoc 'l x)))
		(_     
		 (if (eq cnt sumibi-cand)
		     (progn
		       (insert _insert-word)
		       (message (format "[%s] candidate (%d/%d)" insert-word (+ _n 1) _max)))
		   (insert _insert-word)))
		(end         (point-marker))
		(ov          (make-overlay start end)))

	   ;; 確定文字列の作成
	   (setq sumibi-last-fix (concat sumibi-last-fix _insert-word))
	   
	   ;; 選択中の場所を装飾する。
	   (overlay-put ov 'face 'default)
	   (when (and select-mode
		      (eq cnt sumibi-cand))
	     (overlay-put ov 'face 'highlight))

	   (push `(,start . ,end) sumibi-marker-list)
	   (sumibi-debug-print (format "insert:[%s] point:%d-%d\n" insert-word (marker-position start) (marker-position end))))
	 (setq cnt (+ cnt 1)))

       sumibi-henkan-list))

    ;; リストを逆順にする。
    (setq sumibi-marker-list (reverse sumibi-marker-list))

    ;; fenceの範囲を設定する
    (when select-mode (insert "|"))
    (setq sumibi-fence-end   (point-marker))

    (sumibi-debug-print (format "total-point:%d-%d\n"
				(marker-position sumibi-fence-start)
				(marker-position sumibi-fence-end)))
    ;; UNDO再開
    (sumibi-enable-undo)
    ))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 変換候補選択モード
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((i 0))
  (while (<= i ?\177)
    (define-key sumibi-select-mode-map (char-to-string i)
      'sumibi-kakutei-and-self-insert)
    (setq i (1+ i))))
(define-key sumibi-select-mode-map "\C-m"                   'sumibi-select-kakutei)
(define-key sumibi-select-mode-map "\C-g"                   'sumibi-select-cancel)
(define-key sumibi-select-mode-map "q"                      'sumibi-select-cancel)
(define-key sumibi-select-mode-map "\C-b"                   'sumibi-select-prev-word)
(define-key sumibi-select-mode-map "\C-f"                   'sumibi-select-next-word)
(define-key sumibi-select-mode-map "\C-a"                   'sumibi-select-first-word)
(define-key sumibi-select-mode-map "\C-e"                   'sumibi-select-last-word)
(define-key sumibi-select-mode-map "\C-p"                   'sumibi-select-prev)
(define-key sumibi-select-mode-map "\C-n"                   'sumibi-select-next)
(define-key sumibi-select-mode-map "b"                      'sumibi-select-prev-word)
(define-key sumibi-select-mode-map "f"                      'sumibi-select-next-word)
(define-key sumibi-select-mode-map "a"                      'sumibi-select-first-word)
(define-key sumibi-select-mode-map "e"                      'sumibi-select-last-word)
(define-key sumibi-select-mode-map "p"                      'sumibi-select-prev)
(define-key sumibi-select-mode-map "n"                      'sumibi-select-next)
(define-key sumibi-select-mode-map sumibi-rK-trans-key      'sumibi-select-next)
(define-key sumibi-select-mode-map " "                      'sumibi-select-next)
(define-key sumibi-select-mode-map "j"                      'sumibi-select-kanji)
(define-key sumibi-select-mode-map "h"                      'sumibi-select-hiragana)
(define-key sumibi-select-mode-map "k"                      'sumibi-select-katakana)
(define-key sumibi-select-mode-map "u"                      'sumibi-select-hiragana)
(define-key sumibi-select-mode-map "i"                      'sumibi-select-katakana)
(define-key sumibi-select-mode-map "\C-u"                   'sumibi-select-hiragana)
(define-key sumibi-select-mode-map "\C-i"                   'sumibi-select-katakana)
(define-key sumibi-select-mode-map "l"                      'sumibi-select-alphabet)


;; 変換を確定し入力されたキーを再入力する関数
(defun sumibi-kakutei-and-self-insert (arg)
  "候補選択を確定し、入力された文字を入力する"
  (interactive "P")
  (sumibi-select-kakutei)
  (setq unread-command-events (list last-command-event)))

;; 候補選択状態での表示更新
(defun sumibi-select-update-display ()
  (sumibi-display-function
   (marker-position sumibi-fence-start)
   (marker-position sumibi-fence-end)
   sumibi-select-mode))


;; 確定したIDリストを変換履歴に追加する
(defun sumibi-next-history ( )
  (if sumibi-history-feature
      (progn
	(push
	 (cons 
	  (sumibi-current-unixtime)
	  '())
	 sumibi-kakutei-history)
	(sumibi-debug-print (format "init:kakutei-history:%S\n" sumibi-kakutei-history))
	sumibi-kakutei-history)
    '()))


;; Sumibiサーバーに 送るヒストリリストを出す
(defun sumibi-get-history-string (kakutei-history)
  (mapconcat
   (lambda (entry)
     (mapconcat
      (lambda (x) (number-to-string x))
      (cdr entry)
      " "))
   kakutei-history
   ";"))

;;(sumibi-get-history-string
;; '(
;;   (1 2 3 4 5 6)
;;   (10 20 30 40 50 60)))

;; 確定したIDリストを更新する
(defun sumibi-update-history( cand-n )
  (let* ((cnt 0)
	 (result 
	  (mapcar
	   (lambda (x)
	     ;; 変換結果文字列を返す。
	     (let ((word (nth (nth cnt cand-n) x)))
	       (sumibi-debug-print (format "history-word:[%d] %s\n" cnt word))
	       (setq cnt (+ 1 cnt))
	       (nth sumibi-id-index word)))
	   sumibi-henkan-list)))
    ;; ヒストリデータを作り直す
    (when sumibi-history-feature
      (setq sumibi-kakutei-history
	    (cons
	     (cons
	      (caar sumibi-kakutei-history)
	      result)
	     (if (< 1 (length sumibi-kakutei-history))
		 (cdr sumibi-kakutei-history)
	       '())))
      (sumibi-debug-print (format "kakutei-history:%S\n" sumibi-kakutei-history)))))
  


;; 候補選択を確定する
(defun sumibi-select-kakutei ()
  "候補選択を確定する"
  (interactive)
  ;; 候補番号リストをバックアップする。
  (setq sumibi-cand-n-backup (copy-list sumibi-cand-n))
  (setq sumibi-select-mode nil)
  (run-hooks 'sumibi-select-mode-end-hook)
  (sumibi-select-update-display)
  (sumibi-update-history sumibi-cand-n))


;; 候補選択をキャンセルする
(defun sumibi-select-cancel ()
  "候補選択をキャンセルする"
  (interactive)
  ;; カレント候補番号をバックアップしていた候補番号で復元する。
  (setq sumibi-cand-n (copy-list sumibi-cand-n-backup))
  (setq sumibi-select-mode nil)
  (run-hooks 'sumibi-select-mode-end-hook)
  (sumibi-select-update-display))

;; 前の候補に進める
(defun sumibi-select-prev ()
  "前の候補に進める"
  (interactive)
  (let (
	(n sumibi-cand))

    ;; 前の候補に切りかえる
    (setcar (nthcdr n sumibi-cand-n) (- (nth n sumibi-cand-n) 1))
    (when (> 0 (nth n sumibi-cand-n))
      (setcar (nthcdr n sumibi-cand-n) (- (nth n sumibi-cand-max) 1)))
    (sumibi-select-update-display)))

;; 次の候補に進める
(defun sumibi-select-next ()
  "次の候補に進める"
  (interactive)
  (let (
	(n sumibi-cand))

    ;; 次の候補に切りかえる
    (setcar (nthcdr n sumibi-cand-n) (+ 1 (nth n sumibi-cand-n)))
    (when (>= (nth n sumibi-cand-n) (nth n sumibi-cand-max))
      (setcar (nthcdr n sumibi-cand-n) 0))

    (sumibi-select-update-display)))

;; 前の文節に移動する
(defun sumibi-select-prev-word ()
  "前の文節に移動する"
  (interactive)
  (when (< 0 sumibi-cand)
    (setq sumibi-cand (- sumibi-cand 1)))
  (sumibi-select-update-display))

;; 次の文節に移動する
(defun sumibi-select-next-word ()
  "次の文節に移動する"
  (interactive)
  (when (< sumibi-cand (- (length sumibi-cand-n) 1))
    (setq sumibi-cand (+ 1 sumibi-cand)))
  (sumibi-select-update-display))

;; 最初の文節に移動する
(defun sumibi-select-first-word ()
  "最初の文節に移動する"
  (interactive)
  (setq sumibi-cand 0)
  (sumibi-select-update-display))

;; 最後の文節に移動する
(defun sumibi-select-last-word ()
  "最後の文節に移動する"
  (interactive)
  (setq sumibi-cand (- (length sumibi-cand-n) 1))
  (sumibi-select-update-display))


;; 指定された type の候補に強制的に切りかえる
(defun sumibi-select-by-type ( _type )
  (let* (
	 (n sumibi-cand)
	 (kouho (nth n sumibi-henkan-list))
	 (_element (assoc _type kouho)))

    ;; 連想リストから _type で引いた index 番号を設定するだけで良い。
    (when _element
      (setcar (nthcdr n sumibi-cand-n) (nth sumibi-candno-index _element))
      (sumibi-select-update-display))))

(defun sumibi-select-kanji ()
  "漢字候補に強制的に切りかえる"
  (interactive)
  (sumibi-select-by-type 'j))

(defun sumibi-select-hiragana ()
  "ひらがな候補に強制的に切りかえる"
  (interactive)
  (sumibi-select-by-type 'h))

(defun sumibi-select-katakana ()
  "カタカナ候補に強制的に切りかえる"
  (interactive)
  (sumibi-select-by-type 'k))

(defun sumibi-select-alphabet ()
  "アルファベット候補に強制的に切りかえる"
  (interactive)
  (sumibi-select-by-type 'l))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ローマ字漢字変換関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sumibi-rK-trans ()
  "ローマ字漢字変換をする。
・カーソルから行頭方向にローマ字列が続く範囲でローマ字漢字変換を行う。"
  (interactive)
;  (print last-command)			; DEBUG

  ;; 非SSLの警告を出す
  (when (and (string-match "^[ ]*http:" sumibi-server-url)
	     (> 1 sumibi-timer-rest))
    (progn
      ;; 警告を出してポーズする
      (message "sumibi.el: !! 非SSLで通信する設定になっています。 !!")
      (sleep-for 2)))

  (cond 
   ;; タイマーイベントを設定しない条件
   ((or
     sumibi-timer
     (> 1 sumibi-realtime-guide-running-seconds)
     ))
   (t
    ;; タイマーイベント関数の登録
    (progn
      (let 
	  ((ov-point
	    (save-excursion
	      (forward-line 1)
	      (point))))
	  (setq sumibi-guide-overlay
			(make-overlay ov-point ov-point (current-buffer))))
      (setq sumibi-timer
			(run-at-time 0.1 sumibi-realtime-guide-interval
						 'sumibi-realtime-guide)))))

  ;; ガイド表示継続回数の更新
  (when (< 0 sumibi-realtime-guide-running-seconds)
    (setq sumibi-timer-rest  
	  (/ sumibi-realtime-guide-running-seconds
	     sumibi-realtime-guide-interval)))

  (cond
   (sumibi-select-mode
    ;; 変換中に呼出されたら、候補選択モードに移行する。
    (funcall (lookup-key sumibi-select-mode-map sumibi-rK-trans-key)))


   (t
    (cond

     ((eq (sumibi-char-charset (preceding-char)) 'ascii)
      ;; カーソル直前が alphabet だったら
      (let ((end (point))
	    (gap (sumibi-skip-chars-backward)))
	(when (/= gap 0)
	  ;; 意味のある入力が見つかったので変換する
	  (let (
		(b (+ end gap))
		(e end))
	    (when (sumibi-henkan-region b e)
	      (if (eq (char-before b) ?/)
		  (setq b (- b 1)))
	      (delete-region b e)
	      (goto-char b)
	      (insert (sumibi-get-display-string))
	      (setq e (point))
	      (sumibi-display-function b e nil)
	      (sumibi-select-kakutei))))))

     
     ((sumibi-kanji (preceding-char))
    
      ;; カーソル直前が 全角で漢字以外 だったら候補選択モードに移行する。
      ;; また、最後に確定した文字列と同じかどうかも確認する。
      (when (and
	     (<= (marker-position sumibi-fence-start) (point))
	     (<= (point) (marker-position sumibi-fence-end))
	     (string-equal sumibi-last-fix (buffer-substring 
					    (marker-position sumibi-fence-start)
					    (marker-position sumibi-fence-end))))
					    
	;; 直前に変換したfenceの範囲に入っていたら、変換モードに移行する。
	(let
	    ((cnt 0))
	  (setq sumibi-select-mode t)
	  (run-hooks 'sumibi-select-mode-hook)
	  (setq sumibi-cand 0)		; 文節番号初期化
	  
	  (sumibi-debug-print "henkan mode ON\n")
	  
	  ;; カーソル位置がどの文節に乗っているかを調べる。
	  (mapcar
	   (lambda (x)
	     (let (
		   (start (marker-position (car x)))
		   (end   (marker-position (cdr x))))
	       
	       (when (and
		      (< start (point))
		      (<= (point) end))
		 (setq sumibi-cand cnt))
	       (setq cnt (+ cnt 1))))
	   sumibi-marker-list)

	  (sumibi-debug-print (format "sumibi-cand = %d\n" sumibi-cand))

	  ;; 表示状態を候補選択モードに切替える。
	  (sumibi-display-function
	   (marker-position sumibi-fence-start)
	   (marker-position sumibi-fence-end)
	   t))))
     ))))



;; 全角で漢字以外の判定関数
(defun sumibi-nkanji (ch)
  (and (eq (sumibi-char-charset ch) 'japanese-jisx0208)
       (not (string-match "[亜-瑤]" (char-to-string ch)))))

(defun sumibi-kanji (ch)
  (eq (sumibi-char-charset ch) 'japanese-jisx0208))


;; ローマ字漢字変換時、変換対象とするローマ字を読み飛ばす関数
(defun sumibi-skip-chars-backward ()
  (let* (
	 (skip-chars
	  (if auto-fill-function
	      ;; auto-fill-mode が有効になっている場合改行があってもskipを続ける
	      (concat sumibi-skip-chars "\n")
	    ;; auto-fill-modeが無効の場合はそのまま
	    sumibi-skip-chars))
	    
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
		     (skip-chars-forward (concat "\t " sumibi-stop-chars) (point-at-eol))))))

	  ;; (sumibi-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	  ;; (sumibi-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

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
		   (skip-chars-forward (concat "\t " sumibi-stop-chars) (point-at-eol))))))

	;; (sumibi-debug-print (format "(point) = %d  result = %d  limit-point = %d\n" (point) result limit-point))
	;; (sumibi-debug-print (format "a = %d b = %d \n" (+ (point) result) limit-point))

	(if (< (+ (point) result) limit-point)
	    ;; インデント位置でストップする。
	    (- 
	     limit-point
	     (point))
	  result)))))

;;;
;;; ローカルのEmacsLispだけで変換する処理
;;;
;; a-list を使って str の先頭に該当する文字列があるか調べる
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


;; かな<->ローマ字変換する
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
(defun sumibi-viper-normalize-map ()
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
	  (unless (assq 'sumibi-mode minor-mode-map-alist)
	    (setq minor-mode-map-alist
		  (append (list (cons 'sumibi-mode sumibi-mode-map)
				(cons 'sumibi-select-mode
				      sumibi-select-mode-map))
			  minor-mode-map-alist)))
	  (viper-normalize-minor-mode-map-alist))))))

(defun sumibi-viper-init-function ()
  (sumibi-viper-normalize-map)
  (remove-hook 'sumibi-mode-hook 'sumibi-viper-init-function))



(defun sumibi-realtime-guide ()
  "リアルタイムで変換中のガイドを出す
sumibi-modeがONの間中呼び出される可能性がある・"
  (cond
   ((or (null sumibi-mode)
	(> 1 sumibi-timer-rest))
    (cancel-timer sumibi-timer)
    (setq sumibi-timer nil)
    (delete-overlay sumibi-guide-overlay))
   (sumibi-guide-overlay
    ;; 残り回数のデクリメント
    (setq sumibi-timer-rest (- sumibi-timer-rest 1))

    (let* (
	   (end (point))
	   (gap (sumibi-skip-chars-backward))
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
	  ;; 上下スペースが無い または 変換対象が無しならガイドは表示しない。
	  (overlay-put sumibi-guide-overlay 'before-string "")
	;; 意味のある入力が見つかったのでガイドを表示する。
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
			   (romkan-convert sumibi-roman->kana-table
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
		       (romkan-convert sumibi-hiragana->katakana-table
				       hira))
		      (t
		       x))))
		 l
		 " ")))
	  (move-overlay sumibi-guide-overlay 
			disp-point (min (point-max) (+ disp-point 1)) (current-buffer))
	  (overlay-put sumibi-guide-overlay 'before-string mess))))
    (overlay-put sumibi-guide-overlay 'face 'sumibi-guide-face))))


;;;
;;; human interface
;;;
(define-key sumibi-mode-map sumibi-rK-trans-key 'sumibi-rK-trans)
(define-key sumibi-mode-map "\M-j" 'sumibi-rHkA-trans)
(or (assq 'sumibi-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
	  (append (list 
		   (cons 'sumibi-mode         sumibi-mode-map))
		  minor-mode-map-alist)))



;; sumibi-mode の状態変更関数
;;  正の引数の場合、常に sumibi-mode を開始する
;;  {負,0}の引数の場合、常に sumibi-mode を終了する
;;  引数無しの場合、sumibi-mode をトグルする

;; buffer 毎に sumibi-mode を変更する
(defun sumibi-mode (&optional arg)
  "Sumibi mode は ローマ字から直接漢字変換するための minor mode です。
引数に正数を指定した場合は、Sumibi mode を有効にします。

Sumibi モードが有効になっている場合 \\<sumibi-mode-map>\\[sumibi-rK-trans] で
point から行頭方向に同種の文字列が続く間を漢字変換します。

同種の文字列とは以下のものを指します。
・半角カタカナとsumibi-stop-chars に指定した文字を除く半角文字
・漢字を除く全角文字"
  (interactive "P")
  (sumibi-mode-internal arg nil))

;; 全バッファで sumibi-mode を変更する
(defun global-sumibi-mode (&optional arg)
  "Sumibi mode は ローマ字から直接漢字変換するための minor mode です。
引数に正数を指定した場合は、Sumibi mode を有効にします。

Sumibi モードが有効になっている場合 \\<sumibi-mode-map>\\[sumibi-rK-trans] で
point から行頭方向に同種の文字列が続く間を漢字変換します。

同種の文字列とは以下のものを指します。
・半角カタカナとsumibi-stop-chars に指定した文字を除く半角文字
・漢字を除く全角文字"
  (interactive "P")
  (sumibi-mode-internal arg t))


;; sumibi-mode を変更する共通関数
(defun sumibi-mode-internal (arg global)
  (or (local-variable-p 'sumibi-mode (current-buffer))
      (make-local-variable 'sumibi-mode))
  (if global
      (progn
	(setq-default sumibi-mode (if (null arg) (not sumibi-mode)
				    (> (prefix-numeric-value arg) 0)))
	(sumibi-kill-sumibi-mode))
    (setq sumibi-mode (if (null arg) (not sumibi-mode)
			(> (prefix-numeric-value arg) 0))))
  (when sumibi-use-viper
    (add-hook 'sumibi-mode-hook 'sumibi-viper-init-function))
  (when sumibi-mode (run-hooks 'sumibi-mode-hook)))


;; buffer local な sumibi-mode を削除する関数
(defun sumibi-kill-sumibi-mode ()
  (let ((buf (buffer-list)))
    (while buf
      (set-buffer (car buf))
      (kill-local-variable 'sumibi-mode)
      (setq buf (cdr buf)))))


;; 全バッファで sumibi-input-mode を変更する
(defun sumibi-input-mode (&optional arg)
  "入力モード変更"
  (interactive "P")
  (if (< 0 arg)
      (progn
	(setq inactivate-current-input-method-function 'sumibi-inactivate)
	(setq sumibi-mode t))
    (setq inactivate-current-input-method-function nil)
    (setq sumibi-mode nil)))


;; input method 対応
(defun sumibi-activate (&rest arg)
  (sumibi-input-mode 1))
(defun sumibi-inactivate (&rest arg)
  (sumibi-input-mode -1))
(register-input-method
 "japanese-sumibi" "Japanese" 'sumibi-activate
 "" "Roman -> Kanji&Kana"
 nil)

;; input-method として登録する。
(set-language-info "Japanese" 'input-method "japanese-sumibi")
(setq default-input-method "japanese-sumibi")

(defconst sumibi-version
  " $Date: 2007/07/23 15:40:49 $ on CVS " ;;VERSION;;
  )
(defun sumibi-version (&optional arg)
  "入力モード変更"
  (interactive "P")
  (message sumibi-version))

(provide 'sumibi)
