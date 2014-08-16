# Sekka (石火) SKK like Japanese input method

 ![Logo]( https://dl.dropboxusercontent.com/u/3870066/blog/iStock_000016378483XTiny.jpg )　[![Build Status](https://travis-ci.org/kiyoka/sekka.svg?branch=master)](https://travis-ci.org/kiyoka/sekka)

----

## 基本操作

Sekkaには日本語モードがありません。
ローマ字表記ルールはSKKに似ています。

   Emacsの編集中バッファで _Kanji_ `[Ctrl-j]` とタイプすると **漢字** に変換されます。
   
   Emacsの編集中バッファで _kanji_ `[Ctrl-j]` とタイプすると **かんじ** に変換されます。
   
   Emacsの編集中バッファで _kanJi_ `[Ctrl-j]` とタイプすると **感じ** に変換されます。

詳細は <http://oldtype.sumibi.org/show-page/Sekka.Emacs> を参照してください。

----

## EmacsLispのインストール

Melpaから`sekka`パッケージをインストールしてください。

.emacsに以下を追記すると、Sekkaが有効になります。

    (require 'sekka)
    (global-sekka-mode 1)

![enabled]( ./doc/img/sekka.modeline.png )

## 変換サーバーのインストール

dockerでsekkaイメージをインストール・実行してください。
localhostのポート番号12929でクライアントからのHTTP通信待ち状態になります。

    sudo docker run -p 12929:12929 -t kiyoka/sekka

## 詳細
 <http://oldtype.sumibi.org/show-page/Sekka>
 
 
