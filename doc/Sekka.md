# Sekka(石火): SKK like Japanese input method
Sekka(石火)は[kiyoka](kiyoka)が開発中のSKKライクな日本語入力メソッドです。現在はEmacs専用です。
 ![](http://dl.dropbox.com/u/3870066/blog/iStock_000016378483XSmall.jpg)
# 特徴
## モードレス
Sekkaには日本語入力モードという概念がありません。Emacsのカーソル位置のローマ字を(Ctrl+J)キーで直接、漢字変換できます。

## SKKライク
入力するローマ字表記ルールはSKKに近いルールを採用していますので、SKKユーザーは簡単にSekkaで文章を入力することができるでしょう。

## ミスタイプ許容
ローマ字表記の揺れ(siとshi、nとnnなどの混在)や少々のローマ字のミスタイプは曖昧辞書検索によって救済されます。
 Kanji    => "漢字"            Kannj    => "漢字"
 Funiki   => "雰囲気"          fuinki   => "雰囲気"
 Shizegegosor => "自然言語処理"

## DDSKKと共存可能
SekkaとDDSKKの両方インストールしても競合しないので、徐々にSekkaに慣れることができます。
Sekkaが有効になった状態でも、[Ctrl-X][Ctrl-J] で従来通りDDSKKが有効になります。


# 動画
Sekkaの日本語入力風景です。
 YouTube: https://www.youtube.com/watch?v=xVgO1JoOKAs

0.8.1の新機能の紹介です。
 YouTube: https://www.youtube.com/watch?v=wFKNnMkQQOY


# ソースコード
開発言語には[Nendo](Nendo)とRubyが使われています。
[kiyoka/sekka - GitHub](http://github.com/kiyoka/sekka)


# ドキュメント
[Sekka.Setup](Sekka.Setup)
[Sekka.VersionUp](Sekka.VersionUp)
[Sekka.Emacs](Sekka.Emacs)
[Sekka.FAQ](Sekka.FAQ)
[Sekka.Dictionary](Sekka.Dictionary)
[Sekka.WebAPI](Sekka.WebAPI)
[Sekka.Benchmark](Sekka.Benchmark)
[Sekka.ReleaseNote](Sekka.ReleaseNote)
[Sekka.TODO](Sekka.TODO)
[Sekka.DONE](Sekka.DONE)


# スライド
- [IM飲み会2010 Sekka開発秘話](http://www.slideshare.net/KiyokaNishiyama/im2010-sekka)
    ![](../img/InputMethodNomikai2010_Sekka.page1.png)


# 議論
[sekka_users | Google グループ](http://groups.google.com/group/sekka_users?hl=ja) でユーザー同士の情報交換や開発者への質問ができます。


# このページへの質問・要望など、コメントおねがいします
<!-- Comments section -->
