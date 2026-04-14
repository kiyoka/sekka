;;; sekka-tests.el --- ERT tests for Sekka  -*- lexical-binding: t; -*-
;;
;; Ported from test/*.nnd (nendo test suites)

;;; Code:

(require 'ert)
(require 'cl-lib)

;; Load path setup
(let ((dir (file-name-directory (or load-file-name buffer-file-name ""))))
  (add-to-list 'load-path dir))

(require 'sekka-alphabet-lib)
(require 'sekka-sharp-number)
(require 'sekka-roman-lib)
(require 'sekka-henkan)
(require 'sekka-jisyo)


;;; ============================================================
;;; alphabet-lib tests (from test/alphabet-lib.nnd)
;;; ============================================================

;; --- 半角 checker ---
(ert-deftest sekka-test-hankaku-p-1 ()
  (should (sekka-alphabet-hankaku-p "abczabcz")))
(ert-deftest sekka-test-hankaku-p-2 ()
  (should (sekka-alphabet-hankaku-p "!}")))
(ert-deftest sekka-test-hankaku-p-3 ()
  (should-not (sekka-alphabet-hankaku-p "!abcdefg}Ａ")))
(ert-deftest sekka-test-hankaku-p-4 ()
  (should-not (sekka-alphabet-hankaku-p "ａｂｃｚＡＢＣＺ")))
(ert-deftest sekka-test-hankaku-p-5 ()
  (should-not (sekka-alphabet-hankaku-p "漢字")))
(ert-deftest sekka-test-hankaku-p-6 ()
  (should-not (sekka-alphabet-hankaku-p "ひらがな")))
(ert-deftest sekka-test-hankaku-p-7 ()
  (should-not (sekka-alphabet-hankaku-p "カタカナ")))

;; --- 全角 checker ---
(ert-deftest sekka-test-zenkaku-p-1 ()
  (should (sekka-alphabet-zenkaku-p "ａｂｃｚＡＢＣＺ")))
(ert-deftest sekka-test-zenkaku-p-2 ()
  (should (sekka-alphabet-zenkaku-p "！｝")))
(ert-deftest sekka-test-zenkaku-p-3 ()
  (should-not (sekka-alphabet-zenkaku-p "！A｝")))
(ert-deftest sekka-test-zenkaku-p-4 ()
  (should-not (sekka-alphabet-zenkaku-p "AＡ")))
(ert-deftest sekka-test-zenkaku-p-5 ()
  (should-not (sekka-alphabet-zenkaku-p "!abcdefg}")))
(ert-deftest sekka-test-zenkaku-p-6 ()
  (should-not (sekka-alphabet-zenkaku-p "漢字")))
(ert-deftest sekka-test-zenkaku-p-7 ()
  (should-not (sekka-alphabet-zenkaku-p "ひらがな")))
(ert-deftest sekka-test-zenkaku-p-8 ()
  (should-not (sekka-alphabet-zenkaku-p "カタカナ")))
(ert-deftest sekka-test-zenkaku-p-9 ()
  (should-not (sekka-alphabet-zenkaku-p "漢Ａ字")))
(ert-deftest sekka-test-zenkaku-p-10 ()
  (should-not (sekka-alphabet-zenkaku-p "ひＡらがな")))
(ert-deftest sekka-test-zenkaku-p-11 ()
  (should-not (sekka-alphabet-zenkaku-p "カＡタカナ")))

;; --- 半角 include checker ---
(ert-deftest sekka-test-include-hankaku-p-1 ()
  (should (sekka-alphabet-include-hankaku-p "abczabcz")))
(ert-deftest sekka-test-include-hankaku-p-2 ()
  (should (sekka-alphabet-include-hankaku-p "!}")))
(ert-deftest sekka-test-include-hankaku-p-3 ()
  (should (sekka-alphabet-include-hankaku-p "!abcdefg}Ａ")))
(ert-deftest sekka-test-include-hankaku-p-4 ()
  (should-not (sekka-alphabet-include-hankaku-p "ａｂｃｚＡＢＣＺ")))
(ert-deftest sekka-test-include-hankaku-p-5 ()
  (should (sekka-alphabet-include-hankaku-p "ａｂｃｚAＡＢＣＺ")))
(ert-deftest sekka-test-include-hankaku-p-6 ()
  (should-not (sekka-alphabet-include-hankaku-p "漢字")))
(ert-deftest sekka-test-include-hankaku-p-7 ()
  (should-not (sekka-alphabet-include-hankaku-p "ひらがな")))
(ert-deftest sekka-test-include-hankaku-p-8 ()
  (should-not (sekka-alphabet-include-hankaku-p "カタカナ")))
(ert-deftest sekka-test-include-hankaku-p-9 ()
  (should (sekka-alphabet-include-hankaku-p "漢A字")))
(ert-deftest sekka-test-include-hankaku-p-10 ()
  (should (sekka-alphabet-include-hankaku-p "ひAらがな")))
(ert-deftest sekka-test-include-hankaku-p-11 ()
  (should (sekka-alphabet-include-hankaku-p "カAタカナ")))
(ert-deftest sekka-test-include-hankaku-p-12 ()
  (should (sekka-alphabet-include-hankaku-p "漢字ひらがなカAタカＡナ")))

;; --- 全角 include checker ---
(ert-deftest sekka-test-include-zenkaku-p-1 ()
  (should (sekka-alphabet-include-zenkaku-p "ａｂｃｚＡＢＣＺ")))
(ert-deftest sekka-test-include-zenkaku-p-2 ()
  (should (sekka-alphabet-include-zenkaku-p "！｝")))
(ert-deftest sekka-test-include-zenkaku-p-3 ()
  (should (sekka-alphabet-include-zenkaku-p "！A｝")))
(ert-deftest sekka-test-include-zenkaku-p-4 ()
  (should (sekka-alphabet-include-zenkaku-p "|Ａ}")))
(ert-deftest sekka-test-include-zenkaku-p-5 ()
  (should (sekka-alphabet-include-zenkaku-p "AＡ")))
(ert-deftest sekka-test-include-zenkaku-p-6 ()
  (should-not (sekka-alphabet-include-zenkaku-p "!abcdefg}")))
(ert-deftest sekka-test-include-zenkaku-p-7 ()
  (should-not (sekka-alphabet-include-zenkaku-p "漢字")))
(ert-deftest sekka-test-include-zenkaku-p-8 ()
  (should-not (sekka-alphabet-include-zenkaku-p "ひらがな")))
(ert-deftest sekka-test-include-zenkaku-p-9 ()
  (should-not (sekka-alphabet-include-zenkaku-p "カタカナ")))
(ert-deftest sekka-test-include-zenkaku-p-10 ()
  (should (sekka-alphabet-include-zenkaku-p "漢Ａ字")))
(ert-deftest sekka-test-include-zenkaku-p-11 ()
  (should (sekka-alphabet-include-zenkaku-p "ひＡらがな")))
(ert-deftest sekka-test-include-zenkaku-p-12 ()
  (should (sekka-alphabet-include-zenkaku-p "カＡタカナ")))
(ert-deftest sekka-test-include-zenkaku-p-13 ()
  (should (sekka-alphabet-include-zenkaku-p "漢字ひらがなカAタカＡナ")))

;; --- 半角->全角 ---
(ert-deftest sekka-test-han->zen-1 ()
  (should (equal "ａｂｃｚＡＢＣＺ" (sekka-alphabet-han->zen "abczABCZ"))))
(ert-deftest sekka-test-han->zen-2 ()
  (should (equal "！｝" (sekka-alphabet-han->zen "!}"))))

;; --- 全角->半角 ---
(ert-deftest sekka-test-zen->han-1 ()
  (should (equal "abczABCZ" (sekka-alphabet-zen->han "ａｂｃｚＡＢＣＺ"))))
(ert-deftest sekka-test-zen->han-2 ()
  (should (equal "!}" (sekka-alphabet-zen->han "！｝"))))
(ert-deftest sekka-test-zen->han-3 ()
  (should (equal "!abcdefg}" (sekka-alphabet-zen->han "!abcdefg}"))))


;;; ============================================================
;;; sharp-number tests (from test/sharp-number.nnd)
;;; ============================================================

;; --- type #1 (半角→全角) ---
(ert-deftest sekka-test-sharp-number-type1-1 ()
  (should (equal "１" (sekka-henkan-sharp-number "#1" "1"))))
(ert-deftest sekka-test-sharp-number-type1-2 ()
  (should (equal "０１２３４５６７８９" (sekka-henkan-sharp-number "#1" "0123456789"))))
(ert-deftest sekka-test-sharp-number-type1-3 ()
  (should (equal "０１２３４５６７８９０１２３４５６７８９"
                 (sekka-henkan-sharp-number "#1" "01234567890123456789"))))

;; --- type #2 (各桁漢数字) ---
(ert-deftest sekka-test-sharp-number-type2-1 ()
  (should (equal "一" (sekka-henkan-sharp-number "#2" "1"))))
(ert-deftest sekka-test-sharp-number-type2-2 ()
  (should (equal "五五〇〇" (sekka-henkan-sharp-number "#2" "5500"))))
(ert-deftest sekka-test-sharp-number-type2-3 ()
  (should (equal "〇一二三四五六七八九" (sekka-henkan-sharp-number "#2" "0123456789"))))

;; --- kansuuji-sen (4桁以内の位取り漢数字) ---
(ert-deftest sekka-test-kansuuji-sen-1 ()
  (should (equal "一" (sekka-henkan-kansuuji-sen "1"))))
(ert-deftest sekka-test-kansuuji-sen-2 ()
  (should (equal "十" (sekka-henkan-kansuuji-sen "10"))))
(ert-deftest sekka-test-kansuuji-sen-3 ()
  (should (equal "百" (sekka-henkan-kansuuji-sen "100"))))
(ert-deftest sekka-test-kansuuji-sen-4 ()
  (should (equal "千" (sekka-henkan-kansuuji-sen "1000"))))
(ert-deftest sekka-test-kansuuji-sen-5 ()
  (should (equal "五千五百" (sekka-henkan-kansuuji-sen "5500"))))
(ert-deftest sekka-test-kansuuji-sen-6 ()
  (should (equal "五千五百五十五" (sekka-henkan-kansuuji-sen "5555"))))
(ert-deftest sekka-test-kansuuji-sen-7 ()
  (should (equal "九千九百九十九" (sekka-henkan-kansuuji-sen "9999"))))

;; --- kansuuji (任意桁の位取り漢数字) ---
(ert-deftest sekka-test-kansuuji-1 ()
  (should (equal "一" (sekka-henkan-kansuuji "1"))))
(ert-deftest sekka-test-kansuuji-2 ()
  (should (equal "十" (sekka-henkan-kansuuji "10"))))
(ert-deftest sekka-test-kansuuji-3 ()
  (should (equal "百" (sekka-henkan-kansuuji "100"))))
(ert-deftest sekka-test-kansuuji-4 ()
  (should (equal "千" (sekka-henkan-kansuuji "1000"))))
(ert-deftest sekka-test-kansuuji-5 ()
  (should (equal "五千五百" (sekka-henkan-kansuuji "5500"))))
(ert-deftest sekka-test-kansuuji-6 ()
  (should (equal "五千五百五十五" (sekka-henkan-kansuuji "5555"))))
(ert-deftest sekka-test-kansuuji-7 ()
  (should (equal "九千九百九十九" (sekka-henkan-kansuuji "9999"))))
(ert-deftest sekka-test-kansuuji-8 ()
  (should (equal "一万" (sekka-henkan-kansuuji "10000"))))
(ert-deftest sekka-test-kansuuji-9 ()
  (should (equal "一億" (sekka-henkan-kansuuji "100000000"))))
(ert-deftest sekka-test-kansuuji-10 ()
  (should (equal "十億" (sekka-henkan-kansuuji "1000000000"))))
(ert-deftest sekka-test-kansuuji-11 ()
  (should (equal "一兆" (sekka-henkan-kansuuji "1000000000000"))))
(ert-deftest sekka-test-kansuuji-12 ()
  (should (equal "一兆二" (sekka-henkan-kansuuji "1000000000002"))))
(ert-deftest sekka-test-kansuuji-13 ()
  (should (equal "一億二千三百四十五万六千七百八十九"
                 (sekka-henkan-kansuuji "0123456789"))))
(ert-deftest sekka-test-kansuuji-14 ()
  (should (equal "九千八百七十六京五千四百三十二兆千九十八億七千六百五十四万三千二百十"
                 (sekka-henkan-kansuuji "98765432109876543210"))))

;; --- type #3 (位取り漢数字) ---
(ert-deftest sekka-test-sharp-number-type3-1 ()
  (should (equal "一" (sekka-henkan-sharp-number "#3" "1"))))
(ert-deftest sekka-test-sharp-number-type3-2 ()
  (should (equal "十" (sekka-henkan-sharp-number "#3" "10"))))
(ert-deftest sekka-test-sharp-number-type3-3 ()
  (should (equal "百" (sekka-henkan-sharp-number "#3" "100"))))
(ert-deftest sekka-test-sharp-number-type3-4 ()
  (should (equal "五千五百" (sekka-henkan-sharp-number "#3" "5500"))))
(ert-deftest sekka-test-sharp-number-type3-5 ()
  (should (equal "五万五千五百五十五" (sekka-henkan-sharp-number "#3" "55555"))))
(ert-deftest sekka-test-sharp-number-type3-6 ()
  (should (equal "一億二千三百四十五万六千七百八十九"
                 (sekka-henkan-sharp-number "#3" "0123456789"))))


;;; ============================================================
;;; roman-lib tests (from test/roman-lib.nnd)
;;; ============================================================

;; --- upcase/downcase ---
(ert-deftest sekka-test-downcase-1 ()
  (should (equal "aabbccddeeffgg" (sekka-downcase "aAbBcCdDeEfFgG"))))
(ert-deftest sekka-test-downcase-2 ()
  (should (equal "aaa@@@@@@bbb" (sekka-downcase "AAA@@@```BBB"))))
(ert-deftest sekka-test-downcase-3 ()
  (should (equal "aaa;;;;;;bbb" (sekka-downcase "AAA+++;;;BBB"))))
(ert-deftest sekka-test-upcase-1 ()
  (should (equal "AABBCCDDEEFFGG" (sekka-upcase "aAbBcCdDeEfFgG"))))
(ert-deftest sekka-test-upcase-2 ()
  (should (equal "AAA``````BBB" (sekka-upcase "AAA@@@```BBB"))))
(ert-deftest sekka-test-upcase-3 ()
  (should (equal "AAA++++++BBB" (sekka-upcase "AAA+++;;;BBB"))))

;; --- hiragana<->katakana ---
(ert-deftest sekka-test-hiragana->katakana-1 ()
  (should (equal "アイウエオーァィゥェォッ"
                 (sekka-hiragana->katakana "あいうえおーぁぃぅぇぉっ"))))
(ert-deftest sekka-test-hiragana->katakana-2 ()
  (should (equal "パイナップル"
                 (sekka-hiragana->katakana "ぱいなっぷる"))))
(ert-deftest sekka-test-hiragana->katakana-3 ()
  (should (equal "アメニモマケズ"
                 (sekka-hiragana->katakana "あめにもまけず"))))
(ert-deftest sekka-test-katakana->hiragana-1 ()
  (should (equal "あいうえおーぁぃぅぇぉっ"
                 (sekka-katakana->hiragana "アイウエオーァィゥェォッ"))))
(ert-deftest sekka-test-katakana->hiragana-2 ()
  (should (equal "ありがとうございます"
                 (sekka-katakana->hiragana "アリガトウゴザイマス"))))
(ert-deftest sekka-test-katakana->hiragana-3 ()
  (should (equal "いろはにほへとちりぬるを"
                 (sekka-katakana->hiragana "イロハニホヘトチリヌルヲ"))))

;; --- is-katakana ---
(ert-deftest sekka-test-is-katakana-1 ()
  (should (sekka-katakana-p "アメニモマケズ")))
(ert-deftest sekka-test-is-katakana-2 ()
  (should-not (sekka-katakana-p "englishア")))
(ert-deftest sekka-test-is-katakana-3 ()
  (should-not (sekka-katakana-p "アenglish")))
(ert-deftest sekka-test-is-katakana-4 ()
  (should-not (sekka-katakana-p "engアlish")))
(ert-deftest sekka-test-is-katakana-5 ()
  (should-not (sekka-katakana-p "あア")))
(ert-deftest sekka-test-is-katakana-6 ()
  (should-not (sekka-katakana-p "アメニEモマケズ")))
(ert-deftest sekka-test-is-katakana-7 ()
  (should (sekka-katakana-p "コーヒー")))

;; --- is-hiragana ---
(ert-deftest sekka-test-is-hiragana-1 ()
  (should (sekka-hiragana-p "ひらがなのぶんしょう")))
(ert-deftest sekka-test-is-hiragana-2 ()
  (should-not (sekka-hiragana-p "ひらがなノぶんしょう")))
(ert-deftest sekka-test-is-hiragana-3 ()
  (should-not (sekka-hiragana-p "Eひらがなのぶんしょう")))
(ert-deftest sekka-test-is-hiragana-4 ()
  (should-not (sekka-hiragana-p "ひらがなEのぶんしょう")))
(ert-deftest sekka-test-is-hiragana-5 ()
  (should-not (sekka-hiragana-p "ひらがなのぶんしょうE")))
(ert-deftest sekka-test-is-hiragana-6 ()
  (should-not (sekka-hiragana-p "あア")))
(ert-deftest sekka-test-is-hiragana-7 ()
  (should (sekka-hiragana-p "こーひー")))

;; --- is-hiragana-and-okuri ---
(ert-deftest sekka-test-is-hiragana-and-okuri-1 ()
  (should (sekka-hiragana-and-okuri-p "あr")))
(ert-deftest sekka-test-is-hiragana-and-okuri-2 ()
  (should-not (sekka-hiragana-and-okuri-p "あ")))
(ert-deftest sekka-test-is-hiragana-and-okuri-3 ()
  (should (sekka-hiragana-and-okuri-p "おこなu")))
(ert-deftest sekka-test-is-hiragana-and-okuri-4 ()
  (should-not (sekka-hiragana-and-okuri-p "おこなU")))
(ert-deftest sekka-test-is-hiragana-and-okuri-5 ()
  (should-not (sekka-hiragana-and-okuri-p "a")))
(ert-deftest sekka-test-is-hiragana-and-okuri-6 ()
  (should-not (sekka-hiragana-and-okuri-p "au")))
(ert-deftest sekka-test-is-hiragana-and-okuri-7 ()
  (should-not (sekka-hiragana-and-okuri-p "1")))
(ert-deftest sekka-test-is-hiragana-and-okuri-8 ()
  (should-not (sekka-hiragana-and-okuri-p "123")))

;; --- other judgement functions ---
(ert-deftest sekka-test-include-hiragana-1 ()
  (should (sekka-include-hiragana-p "123あ456")))
(ert-deftest sekka-test-include-hiragana-2 ()
  (should-not (sekka-include-hiragana-p "123A456")))
(ert-deftest sekka-test-include-hiragana-3 ()
  (should-not (sekka-include-hiragana-p "漢字")))
(ert-deftest sekka-test-include-hiragana-4 ()
  (should-not (sekka-include-hiragana-p "カタカナ")))

(ert-deftest sekka-test-is-kanji-1 ()
  (should (sekka-kanji-p "漢字")))
(ert-deftest sekka-test-is-kanji-2 ()
  (should (sekka-kanji-p "薔薇")))
(ert-deftest sekka-test-is-kanji-3 ()
  (should-not (sekka-kanji-p "感じ")))
(ert-deftest sekka-test-is-kanji-4 ()
  (should-not (sekka-kanji-p "ひらがな")))
(ert-deftest sekka-test-is-kanji-5 ()
  (should-not (sekka-kanji-p "ABCDE")))

(ert-deftest sekka-test-include-kanji-1 ()
  (should (sekka-include-kanji-p "感じ")))
(ert-deftest sekka-test-include-kanji-2 ()
  (should (sekka-include-kanji-p "ABC漢字DEF")))
(ert-deftest sekka-test-include-kanji-3 ()
  (should-not (sekka-include-kanji-p "ABCDEF")))
(ert-deftest sekka-test-include-kanji-4 ()
  (should-not (sekka-include-kanji-p "ひらがな")))
(ert-deftest sekka-test-include-kanji-5 ()
  (should-not (sekka-include-kanji-p "カタカナ")))

;; --- drop okurigana ---
(ert-deftest sekka-test-drop-okuri-1 ()
  (should (equal "行" (sekka-drop-okuri "行う"))))
(ert-deftest sekka-test-drop-okuri-2 ()
  (should (equal "行" (sekka-drop-okuri "行なう"))))
(ert-deftest sekka-test-drop-okuri-3 ()
  (should (equal "見" (sekka-drop-okuri "見る"))))
(ert-deftest sekka-test-drop-okuri-4 ()
  (should (equal "変化" (sekka-drop-okuri "変化する"))))
(ert-deftest sekka-test-drop-okuri-5 ()
  (should (equal "見付" (sekka-drop-okuri "見付ける"))))

;; --- roman->hiragana conversion ---
(ert-deftest sekka-test-roman->hiragana-1 ()
  (sekka-roman-lib-init)
  (should (equal '("つみき") (sekka-roman->hiragana "tsumiki" :normal))))
(ert-deftest sekka-test-roman->hiragana-2 ()
  (should (equal '("こーひー") (sekka-roman->hiragana "ko-hi-" :normal))))
(ert-deftest sekka-test-roman->hiragana-3 ()
  (should (equal '("かんじ" "かぬんい") (sekka-roman->hiragana "kanji" :normal))))
(ert-deftest sekka-test-roman->hiragana-4 ()
  (should (equal '("かぬんい" "かんじ") (sekka-roman->hiragana "kanji" :azik))))
(ert-deftest sekka-test-roman->hiragana-5 ()
  (should (equal '("かんじ") (sekka-roman->hiragana "kannji" :normal))))
(ert-deftest sekka-test-roman->hiragana-6 ()
  (should (equal '("ちゃんじ" "ちゃなんい") (sekka-roman->hiragana "canzi" :normal))))
(ert-deftest sekka-test-roman->hiragana-7 ()
  (should (equal '("ちゃなんい" "ちゃんじ") (sekka-roman->hiragana "canzi" :azik))))
(ert-deftest sekka-test-roman->hiragana-8 ()
  (should (equal '("とうきょうとっきょきょかきょく")
                 (sekka-roman->hiragana "toukyoutokkyokyokakyoku" :normal))))
(ert-deftest sekka-test-roman->hiragana-9 ()
  (should (equal '("はっぴょうってきょうかぁ")
                 (sekka-roman->hiragana "happyouttekyoukala" :normal))))
(ert-deftest sekka-test-roman->hiragana-10 ()
  (should (equal '("はっぴょうってきょうかぁ")
                 (sekka-roman->hiragana "ha@pyou@tekyoukala" :normal))))
(ert-deftest sekka-test-roman->hiragana-11 ()
  (should (equal '("かんじ") (sekka-roman->hiragana "knji" :normal))))
(ert-deftest sekka-test-roman->hiragana-12 ()
  (should (equal '("かっこ") (sekka-roman->hiragana "ka@ko" :normal))))
(ert-deftest sekka-test-roman->hiragana-13 ()
  (should (equal '("こーひー") (sekka-roman->hiragana "ko:hi:" :normal))))
(ert-deftest sekka-test-roman->hiragana-14 ()
  (should (equal nil (sekka-roman->hiragana "b" :normal))))
(ert-deftest sekka-test-roman->hiragana-15 ()
  (should (equal '("んんんん") (sekka-roman->hiragana "nnqnnq" :normal))))
(ert-deftest sekka-test-roman->hiragana-16 ()
  (should (equal '("んんんん" "ないない") (sekka-roman->hiragana "nqnq" :normal))))
(ert-deftest sekka-test-roman->hiragana-17 ()
  (should (equal '("ないない" "んんんん") (sekka-roman->hiragana "nqnq" :azik))))
(ert-deftest sekka-test-roman->hiragana-18 ()
  (should (equal '("そうです") (sekka-roman->hiragana "spds" :normal))))
(ert-deftest sekka-test-roman->hiragana-19 ()
  (should (equal '("そうです") (sekka-roman->hiragana "spds" :azik))))
;; "xo" maps to "ぉ" in elisp (in nendo "xo" also mapped to "しょ" in :normal mode)
(ert-deftest sekka-test-roman->hiragana-20 ()
  (should (equal '("もうぉ") (sekka-roman->hiragana "mpxo" :normal))))
(ert-deftest sekka-test-roman->hiragana-21 ()
  (should (equal '("もうぉ") (sekka-roman->hiragana "mpxo" :azik))))
(ert-deftest sekka-test-roman->hiragana-22 ()
  (should (equal '("ものこと") (sekka-roman->hiragana "mnkt" :normal))))
(ert-deftest sekka-test-roman->hiragana-23 ()
  (should (equal '("ものこと") (sekka-roman->hiragana "mnkt" :azik))))
(ert-deftest sekka-test-roman->hiragana-24 ()
  (should (equal '("しぜんげんごしょり" "しぜにぇにょしょり")
                 (sekka-roman->hiragana "shizengengosyori" :normal))))
(ert-deftest sekka-test-roman->hiragana-25 ()
  (should (equal '("しぜにぇにょしょり" "しぜんげんごしょり")
                 (sekka-roman->hiragana "shizengengosyori" :azik))))
(ert-deftest sekka-test-roman->hiragana-26 ()
  (should (equal '("しぜんげんごしょり")
                 (sekka-roman->hiragana "shizenngenngosyori" :normal))))
(ert-deftest sekka-test-roman->hiragana-27 ()
  (should (equal '("かっこ") (sekka-roman->hiragana "ka@ko" :normal))))
(ert-deftest sekka-test-roman->hiragana-28 ()
  (should (equal '("かった") (sekka-roman->hiragana "ka@ta" :normal))))
(ert-deftest sekka-test-roman->hiragana-29 ()
  (should (equal '("かっこ") (sekka-roman->hiragana "ka;ko" :normal))))
(ert-deftest sekka-test-roman->hiragana-30 ()
  (should (equal '("かった") (sekka-roman->hiragana "ka;ta" :normal))))
;; In elisp, "xa" etc. are excluded from AZIK's "しゃ" mapping in :normal mode,
;; so only the small-kana interpretation exists
(ert-deftest sekka-test-roman->hiragana-31 ()
  (should (equal '("ぁぃぅぇぉ")
                 (sekka-roman->hiragana "xaxixuxexo" :normal))))
(ert-deftest sekka-test-roman->hiragana-32 ()
  (should (equal '("ゃゅょ") (sekka-roman->hiragana "xyaxyuxyo" :normal))))
(ert-deftest sekka-test-roman->hiragana-33 ()
  (should (equal '("ゎっ") (sekka-roman->hiragana "xwaxtu" :normal))))


;;; ============================================================
;;; util tests (from test/util.nnd)
;;; ============================================================

;; --- string-downcase-first ---
(ert-deftest sekka-test-string-downcase-first-1 ()
  (should (equal "aBCDE" (sekka-henkan--string-downcase-first "ABCDE"))))
(ert-deftest sekka-test-string-downcase-first-2 ()
  (should (equal "abcde" (sekka-henkan--string-downcase-first "abcde"))))
(ert-deftest sekka-test-string-downcase-first-3 ()
  (should (equal "abcde" (sekka-henkan--string-downcase-first "Abcde"))))
(ert-deftest sekka-test-string-downcase-first-4 ()
  (should (equal "a" (sekka-henkan--string-downcase-first "A"))))
(ert-deftest sekka-test-string-downcase-first-5 ()
  (should (equal "あいうえお" (sekka-henkan--string-downcase-first "あいうえお"))))
(ert-deftest sekka-test-string-downcase-first-6 ()
  (should (equal "aあいう" (sekka-henkan--string-downcase-first "Aあいう"))))


;;; ============================================================
;;; henkan tests (from test/henkan-main.nnd)
;;; These tests require the L dictionary to be loaded.
;;; ============================================================

;; Helper: extract word list from henkan result
(defun sekka-test--words (result)
  "Extract just the word (car) from each henkan result entry."
  (mapcar #'car result))

;; Helper: ensure dictionary is loaded
(defvar sekka-test--jisyo-initialized nil)
(defun sekka-test--ensure-jisyo ()
  "Load dictionary if not already loaded."
  (unless sekka-test--jisyo-initialized
    (sekka-roman-lib-init)
    (sekka-jisyo-init)
    ;; テスト環境ではidle timerが発火しないため、直接SymSpellインデックスを構築
    (sekka-jisyo-build-symspell-now)
    ;; Jaro-Winklerインデックスも同様に同期構築
    (sekka-jisyo--build-jarowinkler-index)
    (setq sekka-test--jisyo-initialized t)))

;; --- henkan (number) ---
(ert-deftest sekka-test-henkan-number-1 ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let ((result (sekka-henkan--number "1")))
    (should (equal "１" (car (nth 0 result))))
    (should (equal "1" (car (nth 1 result))))
    (should (equal "一" (car (nth 2 result))))
    (should (equal "一" (car (nth 3 result))))))

(ert-deftest sekka-test-henkan-number-2 ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let ((result (sekka-henkan--number "10")))
    (should (equal "１０" (car (nth 0 result))))
    (should (equal "10" (car (nth 1 result))))
    (should (equal "一〇" (car (nth 2 result))))
    (should (equal "十" (car (nth 3 result))))))

(ert-deftest sekka-test-henkan-number-3 ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let ((result (sekka-henkan--number "100")))
    (should (equal "１００" (car (nth 0 result))))
    (should (equal "100" (car (nth 1 result))))
    (should (equal "一〇〇" (car (nth 2 result))))
    (should (equal "百" (car (nth 3 result))))))

(ert-deftest sekka-test-henkan-number-4 ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let ((result (sekka-henkan--number "1234567890")))
    (should (equal "１２３４５６７８９０" (car (nth 0 result))))
    (should (equal "1234567890" (car (nth 1 result))))
    (should (equal "一二三四五六七八九〇" (car (nth 2 result))))
    (should (equal "十二億三千四百五十六万七千八百九十" (car (nth 3 result))))))

;; --- henkan alphabet ---
(ert-deftest sekka-test-henkan-alphabet-1 ()
  :tags '(henkan)
  (let ((result (sekka-henkan--alphabet "abczABCZ")))
    (should (equal "ａｂｃｚＡＢＣＺ" (car (nth 0 result))))
    (should (equal "abczABCZ" (car (nth 1 result))))))

(ert-deftest sekka-test-henkan-alphabet-2 ()
  :tags '(henkan)
  (let ((result (sekka-henkan--alphabet "!abcdefg}")))
    (should (equal "！ａｂｃｄｅｆｇ｝" (car (nth 0 result))))
    (should (equal "!abcdefg}" (car (nth 1 result))))))

(ert-deftest sekka-test-henkan-alphabet-3 ()
  :tags '(henkan)
  (let ((result (sekka-henkan--alphabet "(){}[]")))
    (should (equal "（）｛｝［］" (car (nth 0 result))))
    (should (equal "(){}[]" (car (nth 1 result))))))

;; --- henkan hiragana ---
(ert-deftest sekka-test-henkan-hiragana-1 ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--hiragana "aiueo" :normal))
         (words (sekka-test--words result)))
    (should (member "あいうえお" words))
    (should (member "アイウエオ" words))))

(ert-deftest sekka-test-henkan-hiragana-2 ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--hiragana "no" :normal))
         (words (sekka-test--words result)))
    (should (member "の" words))
    (should (member "ノ" words))))

(ert-deftest sekka-test-henkan-hiragana-3 ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  ;; "b" cannot be converted to hiragana
  (let* ((result (sekka-henkan--hiragana "b" :normal))
         (words (sekka-test--words result)))
    (should (member "b" words))))

(ert-deftest sekka-test-henkan-hiragana-4 ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--hiragana "srktds" :normal))
         (words (sekka-test--words result)))
    (should (member "することです" words))
    (should (member "スルコトデス" words))))

(ert-deftest sekka-test-henkan-hiragana-5 ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--hiragana "srktds" :azik))
         (words (sekka-test--words result)))
    (should (member "することです" words))
    (should (member "スルコトデス" words))))

;; --- henkan okuri-nashi (requires L dictionary) ---
(ert-deftest sekka-test-henkan-okuri-nashi-1 ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "henkan" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "変換" words))
    (should (member "返還" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-kani ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "kani" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "蟹" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-kakko ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "kakko" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "括弧" words))
    (should (member "格好" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-kakko-at ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "ka@ko" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "括弧" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-kakko-semicolon ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "ka;ko" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "括弧" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-icchi ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "icchi" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "一致" words))))

(ert-deftest sekka-test-henkan-okuri-nashi-limit ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "kani" 1 :normal)))
    (should (= 1 (length result)))))

;; --- henkan okuri-ari (requires L dictionary) ---
(ert-deftest sekka-test-henkan-okuri-ari-henka-suru ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "henkaSuru" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "変化する" words))))

(ert-deftest sekka-test-henkan-okuri-ari-okona-u ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "okonaU" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "行う" words))))

(ert-deftest sekka-test-henkan-okuri-ari-mi-ru ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "miRu" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "見る" words))
    (should (member "観る" words))))

(ert-deftest sekka-test-henkan-okuri-ari-ka-tu ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "kaTu" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "勝つ" words))))

(ert-deftest sekka-test-henkan-okuri-ari-ka-tta ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "kaTta" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "勝った" words))))

(ert-deftest sekka-test-henkan-okuri-ari-watashi-ha ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "watashiHa" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "私は" words))))

(ert-deftest sekka-test-henkan-okuri-ari-limit ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-ari "miRu" 1 :normal)))
    (should (= 1 (length result)))))

;; --- henkan non-kanji (requires L dictionary) ---
(ert-deftest sekka-test-henkan-non-kanji-exclamation ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--non-kanji "!"))
         (words (sekka-test--words result)))
    (should (member "！" words))))

(ert-deftest sekka-test-henkan-non-kanji-slash ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--non-kanji "/"))
         (words (sekka-test--words result)))
    (should (member "／" words))))

(ert-deftest sekka-test-henkan-non-kanji-dot ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--non-kanji "."))
         (words (sekka-test--words result)))
    (should (member "．" words))))

;; --- sekka-henkan toplevel (requires L dictionary) ---
(ert-deftest sekka-test-henkan-toplevel-asterisk ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "*" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "＊" words))
    (should (member "※" words))
    (should (member "×" words))))

(ert-deftest sekka-test-henkan-toplevel-henkan ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "Henkan" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "変換" words))
    (should (member "返還" words))
    (should (member "へんかん" words))
    (should (member "ヘンカン" words))))

(ert-deftest sekka-test-henkan-toplevel-henkaSuru ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "henkaSuru" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "変化する" words))))

(ert-deftest sekka-test-henkan-toplevel-eRu ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "eRu" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "得る" words))
    (should (member "える" words))
    (should (member "エル" words))))

(ert-deftest sekka-test-henkan-toplevel-wo ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "wo" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "を" words))
    (should (member "ヲ" words))))

(ert-deftest sekka-test-henkan-toplevel-Wake ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "Wake" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "訳" words))
    (should (member "わけ" words))
    (should (member "ワケ" words))))

(ert-deftest sekka-test-henkan-toplevel-AU ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "AU" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "合う" words))
    (should (member "会う" words))
    (should (member "あう" words))
    (should (member "アウ" words))))

(ert-deftest sekka-test-henkan-toplevel-Ko-hi- ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "Ko-hi-" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "コーヒー" words))
    (should (member "こーひー" words))))

(ert-deftest sekka-test-henkan-toplevel-number ()
  :tags '(henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "1234567890" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "１２３４５６７８９０" words))
    (should (member "1234567890" words))))

(ert-deftest sekka-test-henkan-toplevel-S ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "S" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "Ｓ" words))
    (should (member "S" words))))

(ert-deftest sekka-test-henkan-toplevel-ChangeLog ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "ChangeLog" 0 :normal))
         (words (sekka-test--words result)))
    (should (member "ＣｈａｎｇｅＬｏｇ" words))
    (should (member "ChangeLog" words))))

;; --- henkan with index ---
(ert-deftest sekka-test-henkan-has-index ()
  :tags '(henkan)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan "Henkan" 0 :normal)))
    ;; Each entry should have 5 elements: (word annotation source type index)
    (should (= 5 (length (car result))))
    ;; First entry should have index 0
    (should (= 0 (nth 4 (car result))))
    ;; Second entry should have index 1
    (should (= 1 (nth 4 (cadr result))))))


;;; ============================================================
;;; SymSpell tests
;;; ============================================================

(ert-deftest sekka-test-symspell-levenshtein-same ()
  (should (= 0 (sekka-symspell-levenshtein "abc" "abc"))))

(ert-deftest sekka-test-symspell-levenshtein-insert ()
  (should (= 1 (sekka-symspell-levenshtein "abc" "abcd"))))

(ert-deftest sekka-test-symspell-levenshtein-delete ()
  (should (= 1 (sekka-symspell-levenshtein "abcd" "abc"))))

(ert-deftest sekka-test-symspell-levenshtein-substitute ()
  (should (= 1 (sekka-symspell-levenshtein "abc" "axc"))))

(ert-deftest sekka-test-symspell-levenshtein-empty ()
  (should (= 3 (sekka-symspell-levenshtein "" "abc")))
  (should (= 3 (sekka-symspell-levenshtein "abc" ""))))

(ert-deftest sekka-test-symspell-delete-variants ()
  (should (equal '("bc" "ac" "ab")
                 (sekka-symspell--delete-variants "abc"))))


;;; ============================================================
;;; jisyo tests
;;; ============================================================

(ert-deftest sekka-test-jisyo-split-candidates ()
  (should (equal '("候補1" "候補2" "候補3")
                 (sekka-jisyo--split-candidates "/候補1/候補2/候補3/"))))

(ert-deftest sekka-test-jisyo-merge-candidates ()
  (should (equal "/a/b/c/d/"
                 (sekka-jisyo--merge-candidates "/a/b/" "/b/c/d/"))))

(ert-deftest sekka-test-jisyo-parse-skk-line ()
  (should (equal '("あい" . "/愛/合い/藍/")
                 (sekka-jisyo--parse-skk-line "あい /愛/合い/藍/"))))

(ert-deftest sekka-test-jisyo-parse-skk-line-comment ()
  (should (null (sekka-jisyo--parse-skk-line ";; comment"))))



;;; ============================================================
;;; kakutei (学習) tests (from test/henkan-main.nnd)
;;; ============================================================

;; Helper: use a temporary user dictionary for kakutei tests
(defmacro sekka-test--with-temp-user-jisyo (&rest body)
  "Execute BODY with a temporary user dictionary file."
  `(let ((sekka-user-jisyo-file (make-temp-file "sekka-test-jisyo"))
         (sekka-user-jisyo-hash (make-hash-table :test 'equal :size 100)))
     (unwind-protect
         (progn ,@body)
       (when (file-exists-p sekka-user-jisyo-file)
         (delete-file sekka-user-jisyo-file)))))

;; --- kakutei: basic reordering ---
(ert-deftest sekka-test-kakutei-reorder-1 ()
  "確定で候補順序が変わる: 返還を先頭に移動."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 「へんかん」で「返還」を確定
   (sekka-jisyo-kakutei "へんかん" "返還")
   ;; 変換結果の先頭が「返還」になるはず
   (let* ((result (sekka-henkan "Henkan" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "返還" (car words))))))

(ert-deftest sekka-test-kakutei-reorder-2 ()
  "確定後、再度別の候補を確定で順序が戻る."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 「返還」を確定
   (sekka-jisyo-kakutei "へんかん" "返還")
   (let* ((result (sekka-henkan "Henkan" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "返還" (car words))))
   ;; 「変換」を確定 → 元に戻る
   (sekka-jisyo-kakutei "へんかん" "変換")
   (let* ((result (sekka-henkan "Henkan" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "変換" (car words))))))

(ert-deftest sekka-test-kakutei-no-change ()
  "既に先頭にある候補を確定しても nil を返す(変更なし)."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 「。」を確定(元の先頭候補を確定 → 順序変更なし → nil)
   (sekka-jisyo-kakutei "." "。")
   (let ((result (sekka-jisyo-kakutei "." "。")))
     (should (null result)))))

(ert-deftest sekka-test-kakutei-nonexistent-key ()
  "存在しないキーの確定は nil."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (should (null (sekka-jisyo-kakutei "zzzzz" "テスト")))))

(ert-deftest sekka-test-kakutei-nonexistent-tango ()
  "存在しない単語の確定は nil."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (should (null (sekka-jisyo-kakutei "へんかん" "存在しない単語")))))

;; --- kakutei: 送りあり ---
(ert-deftest sekka-test-kakutei-okuri-ari-1 ()
  "送りあり: 「観」を確定すると先頭に来る."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-kakutei "みr" "観")
   (let* ((result (sekka-henkan--okuri-ari "miR" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "観" (car words))))))

(ert-deftest sekka-test-kakutei-okuri-ari-2 ()
  "送りあり: 「視」を確定すると先頭に来る."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 「観」を先に確定
   (sekka-jisyo-kakutei "みr" "観")
   ;; 次に「視」を確定
   (sekka-jisyo-kakutei "みr" "視")
   (let* ((result (sekka-henkan--okuri-ari "miR" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "視" (car words))))))

(ert-deftest sekka-test-kakutei-okuri-ari-with-okuri ()
  "送りあり: 送り仮名付き「観る」で確定、送り仮名除去して辞書更新."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-kakutei "みr" "観る")
   (let* ((result (sekka-henkan--okuri-ari "miRu" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "観る" (car words))))))

;; --- kakutei: dot/symbol ---
(ert-deftest sekka-test-kakutei-dot ()
  "記号: 「。」を確定すると先頭に来る."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-kakutei "." "。")
   (let* ((result (sekka-henkan "." 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "。" (car words))))))

;; --- kakutei: persistence ---
(ert-deftest sekka-test-kakutei-persistence ()
  "確定結果がユーザー辞書ファイルに永続化される."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-kakutei "へんかん" "返還")
   ;; ファイルが作成されていること
   (should (file-exists-p sekka-user-jisyo-file))
   ;; ファイルの中身を確認
   (with-temp-buffer
     (insert-file-contents sekka-user-jisyo-file)
     (should (string-match-p "へんかん" (buffer-string)))
     (should (string-match-p "返還" (buffer-string))))))

(ert-deftest sekka-test-kakutei-persistence-reload ()
  "ユーザー辞書をリロードしても学習結果が残る."
  :tags '(kakutei jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 確定して保存
   (sekka-jisyo-kakutei "へんかん" "返還")
   ;; ユーザー辞書ハッシュをクリアしてリロード
   (setq sekka-user-jisyo-hash (make-hash-table :test 'equal :size 100))
   (sekka-jisyo-load-file sekka-user-jisyo-file sekka-user-jisyo-hash)
   ;; リロード後も返還が先頭
   (let* ((result (sekka-henkan "Henkan" 0 :normal))
          (words (sekka-test--words result)))
     (should (equal "返還" (car words))))))


;;; ============================================================
;;; register-word (単語登録) tests
;;; ============================================================

(ert-deftest sekka-test-register-word-new ()
  "新規単語の登録."
  :tags '(register jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (should (eq t (sekka-jisyo-register-word "てすと" "テスト単語")))
   ;; 登録結果が辞書から取得できる
   (should (equal "/テスト単語/" (gethash "てすと" sekka-user-jisyo-hash)))))

(ert-deftest sekka-test-register-word-duplicate ()
  "既に登録済みの単語は nil を返す."
  :tags '(register jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (should (eq t (sekka-jisyo-register-word "てすと" "テスト単語")))
   (should (null (sekka-jisyo-register-word "てすと" "テスト単語")))))

(ert-deftest sekka-test-register-word-append ()
  "既存キーに別の単語を追加登録."
  :tags '(register jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-register-word "てすと" "テスト1")
   (sekka-jisyo-register-word "てすと" "テスト2")
   (let ((val (gethash "てすと" sekka-user-jisyo-hash)))
     (should (string-match-p "テスト2" val))
     (should (string-match-p "テスト1" val)))))

(ert-deftest sekka-test-register-word-persistence ()
  "登録した単語がファイルに永続化される."
  :tags '(register jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (sekka-jisyo-register-word "てすと" "テスト単語")
   (should (file-exists-p sekka-user-jisyo-file))
   (with-temp-buffer
     (insert-file-contents sekka-user-jisyo-file)
     (should (string-match-p "てすと" (buffer-string)))
     (should (string-match-p "テスト単語" (buffer-string))))))

(ert-deftest sekka-test-register-word-symspell-update ()
  "新規キー登録時に SymSpell インデックスが更新される."
  :tags '(register jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   ;; 存在しないキーを登録
   (sekka-jisyo-register-word "てすときー" "テストキー")
   ;; SymSpell dict-set に追加されている
   (should (gethash "てすときー" sekka-symspell-dict-set))))

(ert-deftest sekka-test-register-word-jarowinkler-update ()
  "新規キー登録時に Jaro-Winkler インデックスも更新される."
  :tags '(register jw jisyo)
  (sekka-test--ensure-jisyo)
  (sekka-test--with-temp-user-jisyo
   (let ((key "あたらしいことば"))
     (sekka-jisyo-register-word key "新しい言葉")
     ;; ローマ字マップに追加されている
     (let ((roman (sekka-jarowinkler-hiragana->roman key)))
       (should (equal key (gethash roman sekka-jarowinkler-roman-to-hira))))
     ;; 実際に JW 検索でヒットする (先頭4文字一致で確実に入る)
     (let ((hits (sekka-jisyo-jarowinkler-search "atarashiikotoba" nil 10)))
       (should (cl-some (lambda (h) (equal (nth 1 h) key)) hits))))))


;;; ============================================================
;;; okuri-key / drop-okuri helper tests
;;; ============================================================

(ert-deftest sekka-test-okuri-key-p-1 ()
  (should (sekka-jisyo--okuri-key-p "おこなu")))
(ert-deftest sekka-test-okuri-key-p-2 ()
  (should (sekka-jisyo--okuri-key-p "みr")))
(ert-deftest sekka-test-okuri-key-p-3 ()
  (should-not (sekka-jisyo--okuri-key-p "へんかん")))
(ert-deftest sekka-test-okuri-key-p-4 ()
  (should-not (sekka-jisyo--okuri-key-p "")))

(ert-deftest sekka-test-drop-okuri-from-tango-1 ()
  (should (equal "行" (sekka-jisyo--drop-okuri-from-tango "行う"))))
(ert-deftest sekka-test-drop-okuri-from-tango-2 ()
  (should (equal "見" (sekka-jisyo--drop-okuri-from-tango "見る"))))
(ert-deftest sekka-test-drop-okuri-from-tango-3 ()
  (should (equal "観" (sekka-jisyo--drop-okuri-from-tango "観る"))))
(ert-deftest sekka-test-drop-okuri-from-tango-4 ()
  (should (equal "漢字" (sekka-jisyo--drop-okuri-from-tango "漢字"))))



;;; ============================================================
;;; 曖昧検索 (SymSpell) テスト
;;; ============================================================

;; --- sekka-symspell-search 直接テスト ---
(ert-deftest sekka-test-symspell-search-exact ()
  "完全一致は distance=0 で見つかる."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((results (sekka-symspell-search "へんかん" 10))
         (exact (cl-find-if (lambda (r) (string= (cdr r) "へんかん")) results)))
    (should exact)
    (should (= 0 (car exact)))))

(ert-deftest sekka-test-symspell-search-delete ()
  "1文字削除(edit distance=1)で近傍キーが見つかる."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  ;; "へんか" は "へんかん" の1文字削除
  (let* ((results (sekka-symspell-search "へんか" nil))
         (keys (mapcar #'cdr results)))
    (should (member "へんか" keys))    ;; 完全一致
    (should (member "へんかん" keys)))) ;; distance=1

(ert-deftest sekka-test-symspell-search-insert ()
  "1文字挿入(edit distance=1)で近傍キーが見つかる."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  ;; "へんかんん" は "へんかん" への1文字挿入
  (let* ((results (sekka-symspell-search "へんかんん" 20))
         (keys (mapcar #'cdr results)))
    (should (member "へんかん" keys))))

(ert-deftest sekka-test-symspell-search-substitute ()
  "1文字置換(edit distance=1)で近傍キーが見つかる."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  ;; "へんかく" は "へんかん" の末尾1文字置換
  (let* ((results (sekka-symspell-search "へんかく" 20))
         (keys (mapcar #'cdr results)))
    (should (member "へんかん" keys))))

(ert-deftest sekka-test-symspell-search-no-match ()
  "edit distance > 1 のキーは見つからない."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  ;; "へんxx" は "へんかん" と distance=2 なので見つからない
  (let* ((results (sekka-symspell-search "へんxx" 20))
         (keys (mapcar #'cdr results)))
    (should-not (member "へんかん" keys))))

(ert-deftest sekka-test-symspell-search-distance-order ()
  "結果は距離昇順(distance=0 が先、distance=1 が後)."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((results (sekka-symspell-search "へんか" 20)))
    (when (> (length results) 1)
      ;; 全結果が距離昇順であること
      (let ((prev-dist -1)
            (ordered t))
        (dolist (r results)
          (when (< (car r) prev-dist)
            (setq ordered nil))
          (setq prev-dist (car r)))
        (should ordered)))))

;; --- sekka-jisyo-approximate-search テスト ---
(ert-deftest sekka-test-approximate-search-henkan ()
  "「へんかん」の曖昧検索: 完全一致 + 近傍キーが辞書値付きで返る."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((results (sekka-jisyo-approximate-search "へんかん" 20))
         (keys (mapcar #'cadr results)))
    ;; 完全一致
    (should (member "へんかん" keys))
    ;; distance=0 の結果は辞書値を持つ
    (let ((exact (cl-find-if (lambda (r) (string= (nth 1 r) "へんかん")) results)))
      (should exact)
      (should (= 0 (nth 0 exact)))
      (should (stringp (nth 2 exact))))))

(ert-deftest sekka-test-approximate-search-henka ()
  "「へんか」の曖昧検索: 「へんかん」が distance=1 で見つかる."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((results (sekka-jisyo-approximate-search "へんか" nil))
         (keys (mapcar #'cadr results)))
    (should (member "へんか" keys))
    (should (member "へんかん" keys))))

(ert-deftest sekka-test-approximate-search-saki ()
  "「さき」の曖昧検索: 完全一致で辞書値が返る."
  :tags '(symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((results (sekka-jisyo-approximate-search "さき" 20))
         (exact (cl-find-if (lambda (r) (and (string= (nth 1 r) "さき") (= 0 (nth 0 r)))) results)))
    (should exact)
    (should (stringp (nth 2 exact)))))

;; --- henkan レベルで曖昧検索が効いているかのテスト ---
(ert-deftest sekka-test-henkan-fuzzy-henka-finds-henkan ()
  "「henka」(=へんか) の変換で曖昧検索により「変換」が候補に含まれる."
  :tags '(henkan symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "henka" 0 :normal))
         (words (sekka-test--words result)))
    ;; 完全一致: へんか → 変化, 返歌
    (should (member "変化" words))
    ;; 曖昧検索: へんかん(distance=1) → 変換, 返還
    (should (member "変換" words))
    (should (member "返還" words))))

(ert-deftest sekka-test-henkan-fuzzy-exact-before-approx ()
  "完全一致の候補が曖昧検索の候補よりも前に出る."
  :tags '(henkan symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "henka" 0 :normal))
         (words (sekka-test--words result))
         (pos-henka (cl-position "変化" words :test #'equal))
         (pos-henkan (cl-position "変換" words :test #'equal)))
    ;; 「変化」(完全一致: へんか) が「変換」(曖昧: へんかん) より前
    (should pos-henka)
    (should pos-henkan)
    (should (< pos-henka pos-henkan))))

(ert-deftest sekka-test-henkan-fuzzy-kani-finds-kami ()
  "「kani」(=かに) の変換で曖昧検索により「神」(かみ, distance=1)が候補に含まれる."
  :tags '(henkan symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "kani" 0 :normal))
         (words (sekka-test--words result)))
    ;; 完全一致: かに → 蟹
    (should (member "蟹" words))
    ;; 曖昧検索: かみ(distance=1) → 神, かき(distance=1) → 柿
    (should (member "神" words))
    (should (member "柿" words))))

(ert-deftest sekka-test-henkan-fuzzy-kami-finds-kani ()
  "「kami」(=かみ) の変換で曖昧検索により「蟹」(かに, distance=1)が候補に含まれる."
  :tags '(henkan symspell jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "kami" 0 :normal))
         (words (sekka-test--words result)))
    ;; 完全一致: かみ → 神, 紙, 髪
    (should (member "神" words))
    ;; 曖昧検索: かに(distance=1) → 蟹
    (should (member "蟹" words))))

(ert-deftest sekka-test-henkan-fuzzy-no-false-positive ()
  "edit distance > 1 の候補は含まれない."
  :tags '(henkan symspell jisyo)
  (sekka-test--ensure-jisyo)
  ;; 「しぜんげんご」(自然言語) と「へんかん」(変換) は距離が大きすぎるので混ざらない
  (let* ((result (sekka-henkan--okuri-nashi "henkan" 0 :normal))
         (words (sekka-test--words result)))
    (should-not (member "自然言語" words))))


;;; ============================================================
;;; ユーザー辞書の手動追記 + SymSpellインデックス反映テスト
;;; ============================================================

(ert-deftest sekka-test-user-jisyo-init-symspell ()
  "sekka-jisyo-init でユーザー辞書のキーも SymSpell に追加される."
  :tags '(jisyo)
  (sekka-test--ensure-jisyo)
  (let ((sekka-user-jisyo-file (make-temp-file "sekka-test-jisyo"))
        (sekka-user-jisyo-hash (make-hash-table :test 'equal :size 100))
        (key "てすとようじしょきー"))
    (unwind-protect
        (progn
          ;; 手動追記をシミュレート: ファイルに直接書く
          (with-temp-file sekka-user-jisyo-file
            (insert key " /テスト用辞書値/\n"))
          ;; ユーザー辞書をロード
          (sekka-jisyo-load-file sekka-user-jisyo-file sekka-user-jisyo-hash)
          ;; SymSpell にはまだない
          (should-not (gethash key sekka-symspell-dict-set))
          ;; init のユーザー辞書SymSpell追加処理を直接実行
          (maphash
           (lambda (k _v)
             (unless (gethash k sekka-symspell-dict-set)
               (sekka-symspell--index-key k sekka-symspell-index sekka-symspell-dict-set)))
           sekka-user-jisyo-hash)
          ;; SymSpell に追加された
          (should (gethash key sekka-symspell-dict-set))
          ;; 完全一致検索でも見つかる
          (should (equal "/テスト用辞書値/" (sekka-jisyo-get key))))
      (when (file-exists-p sekka-user-jisyo-file)
        (delete-file sekka-user-jisyo-file)))))


;;; ============================================================
;;; 辞書ダウンロード関連テスト
;;; ============================================================

(ert-deftest sekka-test-dictionary-names-defined ()
  "sekka-jisyo-dictionary-names が定義されている."
  :tags '(download)
  (should (listp sekka-jisyo-dictionary-names))
  (should (> (length sekka-jisyo-dictionary-names) 0)))

(ert-deftest sekka-test-ensure-dictionaries-creates-cache-dir ()
  "sekka-jisyo--ensure-dictionaries がキャッシュディレクトリを作成する."
  :tags '(download)
  (let* ((tmp-dir (make-temp-file "sekka-test-cache" t))
         (cache-dir (expand-file-name "subdir" tmp-dir))
         (sekka-dictionary-cache-dir cache-dir)
         (sekka-jisyo-dictionary-names '("test-file"))
         ;; ダウンロードは実行しない (ネットワーク不要)
         (sekka-dictionary-base-url "file:///nonexistent/"))
    (unwind-protect
        (progn
          (should-not (file-directory-p cache-dir))
          (sekka-jisyo--ensure-dictionaries)
          (should (file-directory-p cache-dir)))
      (delete-directory tmp-dir t))))

(ert-deftest sekka-test-ensure-dictionaries-uses-existing-cache ()
  "既にキャッシュに辞書があればダウンロードせずにそれを返す."
  :tags '(download)
  (let* ((tmp-dir (make-temp-file "sekka-test-cache" t))
         (sekka-dictionary-cache-dir tmp-dir)
         (sekka-jisyo-dictionary-names '("test-dict")))
    (unwind-protect
        (progn
          ;; キャッシュにファイルを事前作成
          (with-temp-file (expand-file-name "test-dict" tmp-dir)
            (insert "あ /亜/\n"))
          (let ((result (sekka-jisyo--ensure-dictionaries)))
            (should (= 1 (length result)))
            (should (string-suffix-p "test-dict" (car result)))))
      (delete-directory tmp-dir t))))

(ert-deftest sekka-test-default-file-list-prefers-local ()
  "ローカル data/ に辞書があればキャッシュよりも優先する."
  :tags '(download)
  (let* ((tmp-dir (make-temp-file "sekka-test-local" t))
         (data-dir (expand-file-name "data" tmp-dir))
         (elisp-dir (expand-file-name "emacs" tmp-dir))
         (sekka-jisyo-dictionary-names '("test-dict")))
    (unwind-protect
        (progn
          (make-directory data-dir t)
          (make-directory elisp-dir t)
          ;; data/ にダミー辞書を作成
          (with-temp-file (expand-file-name "test-dict" data-dir)
            (insert "い /位/\n"))
          ;; locate-library を emacs/ サブディレクトリに向ける
          (cl-letf (((symbol-function 'locate-library)
                     (lambda (_name &rest _) (expand-file-name "sekka-jisyo.el" elisp-dir))))
            (let ((result (sekka-jisyo-default-file-list)))
              (should (= 1 (length result)))
              (should (string-match-p "/data/test-dict\\'" (car result))))))
      (delete-directory tmp-dir t))))


;;; ============================================================
;;; Jaro-Winkler tests
;;; ============================================================

;; --- 類似度の基本ケース ---
(ert-deftest sekka-test-jw-identical ()
  (should (= 1.0 (sekka-jarowinkler-similarity "henkan" "henkan"))))

(ert-deftest sekka-test-jw-empty ()
  (should (= 1.0 (sekka-jarowinkler-similarity "" "")))
  (should (= 0.0 (sekka-jarowinkler-similarity "" "abc")))
  (should (= 0.0 (sekka-jarowinkler-similarity "abc" ""))))

(ert-deftest sekka-test-jw-one-char-missing ()
  "末尾1文字欠落は高スコア (オリジナル閾値0.94を通過)."
  (should (>= (sekka-jarowinkler-similarity "henka" "henkan") 0.94)))

(ert-deftest sekka-test-jw-long-word-trailing-missing ()
  "長い単語の後方欠落が閾値0.94を通過する (shizengengos vs shizengengoshori)."
  (should (>= (sekka-jarowinkler-similarity "shizengengos" "shizengengoshori") 0.94)))

(ert-deftest sekka-test-jw-no-match ()
  "無関係な文字列は低スコア."
  (should (< (sekka-jarowinkler-similarity "henkan" "xyz") 0.5)))

(ert-deftest sekka-test-jw-prefix-boost ()
  "先頭一致のプレフィックスボーナスが効く (同じJaroでも先頭一致の方が高い)."
  (let ((s1 (sekka-jarowinkler-similarity "abcdef" "abcxyz"))  ;; prefix=3
        (s2 (sekka-jarowinkler-similarity "abcdef" "xyzdef")))  ;; prefix=0
    (should (> s1 s2))))

;; --- ひらがな→ローマ字変換 ---
(ert-deftest sekka-test-jw-kana-to-roman-basic ()
  (should (equal "henkan" (sekka-jarowinkler-hiragana->roman "へんかん"))))

(ert-deftest sekka-test-jw-kana-to-roman-youon ()
  (should (equal "shizengengoshori"
                 (sekka-jarowinkler-hiragana->roman "しぜんげんごしょり"))))

(ert-deftest sekka-test-jw-kana-to-roman-sokuon ()
  (should (equal "nikki" (sekka-jarowinkler-hiragana->roman "にっき")))
  (should (equal "matcha" (sekka-jarowinkler-hiragana->roman "まっちゃ"))))

(ert-deftest sekka-test-jw-kana-to-roman-single-n ()
  "`ん` は正準化で単独の `n` に統一する."
  (should (equal "kanji" (sekka-jarowinkler-hiragana->roman "かんじ"))))

;; --- プレフィックスインデックス + 検索 ---
(ert-deftest sekka-test-jw-index-and-search ()
  (sekka-jarowinkler-build-index
   (list "しぜんげんごしょり" "しぜんげんご" "へんかん" "かんじ"))
  (let ((hits (sekka-jarowinkler-search "shizengengos")))
    (should hits)
    ;; 自然言語処理に相当するキーが返ること
    (should (cl-some (lambda (h) (equal (cdr h) "しぜんげんごしょり")) hits))))

(ert-deftest sekka-test-jw-search-short-query-rejected ()
  "プレフィックス長未満のクエリは nil."
  (sekka-jarowinkler-build-index (list "へんかん"))
  (should-not (sekka-jarowinkler-search "h")))

;; --- 辞書連携: shizengengos → 自然言語処理 (エンドツーエンド) ---
(ert-deftest sekka-test-jw-end-to-end-shizengengos ()
  "オリジナル(nendo)の強力さを再現: shizengengos が 自然言語処理 にヒットする."
  :tags '(jw jisyo)
  (sekka-test--ensure-jisyo)
  (let ((hits (sekka-jisyo-jarowinkler-search "shizengengos" nil 10)))
    (should hits)
    ;; しぜんげんごしょり (自然言語処理) が結果に含まれる
    (should (cl-some (lambda (h) (equal (nth 1 h) "しぜんげんごしょり")) hits))))

(ert-deftest sekka-test-jw-henkan-integration-shizengengos ()
  "sekka-henkan経由でも shizengengos から 自然言語処理 が得られる."
  :tags '(jw henkan jisyo)
  (sekka-test--ensure-jisyo)
  (let* ((result (sekka-henkan--okuri-nashi "shizengengos" 20 :normal))
         (words (sekka-test--words result)))
    (should (member "自然言語処理" words))))

(provide 'sekka-tests)
;;; sekka-tests.el ends here
