# SekkaのFAQ

これまでに聞かれた質問に答えます。
操作マニュアルに書かれていない便利な小ネタもここに書かれていることもあります。
技術的なこと、アーキテクチャ設計の話題もいくつかあります。


## Sekkaの名前の由来は？
名前を付けるとき、二つのことに留意して付けました。
ひとつは、SKKから影響を受けているので "S" "K" "K" の3文字を入れること。
もうひとつは、[Sekka](Sekka)の前に[Sumibi.org](Sumibi.org)(炭火)という日本語変換エンジン開発していたので、自分の作品を "火" シリーズにしたかったこと。

アルファベットだけで考えると、Sekki(石器)とかSankaku(三角)とかSikaku(四角)とか覚えやすい名前も色々あったのですが、最終的に「電光石火」という言葉から「石火(Sekka)」に決めました。
誰かがＣ言語でより高速なサーバーを書いてくれた場合に「電光石火」と命名できるという余地も残してあります。


## SKKがあるのに何故別の入力メソッドを作ったの？
自分の入力の癖を振りかえってみると、日本語変換中にミスタイプが多く、ミスタイプを許容してくれる入力方式があれば使いやすいだろう以前から思っていました。
しかし、DDSKKなど既存のソースコードに手を入れるのは難しいのでやりませんでした。
しばらくして、開発中の[Nendo](Nendo)というオレ処理系が使えるレベルかどうか検証するためにも何らかの実用アプリを作ってみる必要があったので[Nendo](Nendo)で書いてみることにしました。

最初はプロトタイプの積もりで作ったのですが、予想以上に使いやすく、SKKを置き換えれるレベルになりそうだったので、細かい作りこみまで進めることになったのです。


## Key-value-storeにTokyoCabinetを使っている理由は？
枯れており、Debian 6.0(squeeze)など主要なディストリビューションに入っていることが大きな理由です。
kyotoCabinetをいう選択もあったのですが、まだ普及してなかったのでやめました。 (2010年10月頃の話)
memcached互換APIでは、レンジサーチなどできないことが多かったのであきらめました。
結局、どのKVSを選んでも専用のクライアントライブラリを使う必要があったため、その中から一番枯れたものにしました。
kvsへのアクセス部分は一段抽象化してあるので、将来別のKVSを使うことも容易な設計になっています。

※ その時の調査内容はブログ記事 「[blog.2010_09_18](https://kiyoka.github.io/blog-archive/2010/09/18/post/) [KVS][Sekka] NoSQL(KVS)の選定の続き」を参照のこと。


## モードレス変換はどこから思いつきましたか？
ローマ字のまま変換するモードレス変換の歴史は古く、boiled-egg、yc.el、sumibi.elなど過去にお手本があります。
私([kiyoka](kiyoka))もyc.elを使っていた時期もありました。
ですので、SKKもモードレスにしてみたいというのは自然な流れでした。


## Sumibiを使わない理由は？
[Sumibi.org](Sumibi.org)については色々失敗があります。
ひとつは、自分が長文を一気に入力するタイプではないことがわかったことです。
[Sumibi.org](Sumibi.org)は、より自然な単語が選択されるためには、なるべく長文で変換する必要があります。1〜2文節程度では変換精度が出ません。たとえば、ある文脈で "漢字" と "感じ"のどちらが出てほしいかは、前後の文章を見れば精度は上がりますが、文節単位で変換していては不自然な候補が出てきてしまいます。
特に、送り仮名ありの単語と送り仮名なしの単語の推定ミスが多かったです。

もうひとつは、ローマ字で長文をどんどん入力していると、間違いがあっても目視で見つけることができないことです。
[Sekka](Sekka)のようにリアルタイムで変換してみてフィードバックしてくれればいいのですが、Sumibi.orgでは変換処理の計算量が大きいのでそうもいかないのです。(MySQLに複雑なクエリが大量に飛ぶ構造)
また、長文で変換してミスタイプに気づいても、そこまで戻って修正する必要があり、文章に集中できないという問題もありました。
それが、[Sekka](Sekka)の曖昧辞書マッチングを搭載するという流れに繋がっています。

さらに、メンテナンスが難しくなっているというのがありました。
エンジンのテストスイートが無かったので、[Sumibi.org](Sumibi.org)を改造するというのが難しく、モチベーションが上がらないという問題がありました。これは明らかな失敗です。
[Sekka](Sekka)はTDDで開発しているので、どれだけ開発に空白期間があっても再度メンテナンスに入れるようになっています。
また、リファクタリングも気軽に行うことができます。


## 曖昧マッチングアルゴリズムにJaro-Winklerが使用されている理由は？
私([kiyoka](kiyoka))の知識不足です。
Jaro、Jaro-Winklerを試してみて、結果的にローマ字による曖昧マッチングとしては、Jaro-Winklerが感覚的に良い結果を出していたので決めました。
もしかしたら、ローマ字のミスタイプの傾向から独自のアルゴリズムを開発すると良いのかもしれませんが、そこまでやっていません。
専門の方でもっと良いアルゴリズムの提案があれば教えてください(笑)
 追記:
   キーボードの物理的なキー配置での距離や、母音や子音を区別して重みを変えるなどの案が存在することを勉強会で教えて頂きました。


## アーキテクチャはどのようになっているのですか？
![](https://cacoo.com/diagrams/jzRPejte9jsbhbBp-6912B.png)
図の通り、TokyoCabinetを使ってなるべく辞書へのアクセスを高速に行えるようにしています。
また、変換済のクエリと結果はmemcachedにキャッシュし、2回目以降の同一クエリにはCPUリソースを消費しないような工夫をしています。


## どのようなソフトウェア部品が使われているのですか？
![](https://cacoo.com/diagrams/NxyK2rnQkDZPap7S-81C9C.png)
図の通り、沢山のRubyのGems(モジュール)を使っています。
それにより、本質的な変換アルゴリズムに注力することができます。
また、全体の約90%を[Nendo](Nendo)という言語で書いています。


## Windownsでも動きますか？
Sekka 1.5.0からWindowsに対応しています。RubyInstaller.orgのRubyを使用します。


## 開発ブログはありますか？
Sekka専用のブログはありませんが、[kiyoka](kiyoka)のブログ([!kiyoka.blog](!kiyoka.blog))で時々関連記事を書いています。
以下が関連記事のリンクです。
[blog.2010_05_08](https://kiyoka.github.io/blog-archive/2010/05/08/post/) [創作心理] 今作りたいもの
[blog.2010_08_08](https://kiyoka.github.io/blog-archive/2010/08/08/post/) [創作心理] 今創りたいもの(2) 『modeless SKK』
[blog.2010_08_10](https://kiyoka.github.io/blog-archive/2010/08/10/post/) [創作心理][SKK] modeless SKK
[blog.2010_08_12](https://kiyoka.github.io/blog-archive/2010/08/12/post/) [Nendo][Sekka] TDD(テスト駆動開発)の重要性
[blog.2010_08_24](https://kiyoka.github.io/blog-archive/2010/08/24/post/) [Ruby][Sekka] Rackについて学ぶ
[Rack](kiyoka.2010_08_27]] [Nendo][Sekka] Sekkaを[[http://rack.rubyforge.org/)に載せて、試験運用中
[blog.2010_08_30](https://kiyoka.github.io/blog-archive/2010/08/30/post/) [Sekka] Sticky-shiftを試してみたら、小指が痛くなくなった。
[blog.2010_09_06](https://kiyoka.github.io/blog-archive/2010/09/06/post/) [KVS][Sekka] 個人的なNoSQL(KVS)のライセンス調査
[blog.2010_09_18](https://kiyoka.github.io/blog-archive/2010/09/18/post/) [KVS][Sekka] NoSQL(KVS)の選定の続き
[blog.2010_09_21](https://kiyoka.github.io/blog-archive/2010/09/21/post/) [Sekka][Nendo] NendoがSekkaの足を引っぱっている
[blog.2010_10_13](https://kiyoka.github.io/blog-archive/2010/10/13/post/) [Ruby] fuzzy-string-match 0.9.0 リリース
[blog.2010_11_01](https://kiyoka.github.io/blog-archive/2010/11/01/post/) [Sekka][SKK] 石火(Sekka)の日本語入力のデモビデオ公開
[blog.2010_11_02](https://kiyoka.github.io/blog-archive/2010/11/02/post/) [Sekka] AZIK対応に挑戦
[blog.2010_11_16](https://kiyoka.github.io/blog-archive/2010/11/16/post/) [Sekka] Sekka 0.8.0 リリース
[blog.2010_11_29](https://kiyoka.github.io/blog-archive/2010/11/29/post/) [Sekka] Sekka 0.8.1 リリース
[blog.2010_11_30](https://kiyoka.github.io/blog-archive/2010/11/30/post/) [Sekka] 「modeless SKK」を着想してから「Sekka」が具現化するまで道のり
[blog.2010_12_01](https://kiyoka.github.io/blog-archive/2010/12/01/post/) [Sekka] ユーザー語彙登録UIについて考える
[blog.2010_12_05](https://kiyoka.github.io/blog-archive/2010/12/05/post/) [Sekka] ユーザー語彙登録UIについて考える(続き)
[blog.2010_12_06](https://kiyoka.github.io/blog-archive/2010/12/06/post/) [Sekka] Sekka 0.8.2 リリース
[blog.2010_12_27](https://kiyoka.github.io/blog-archive/2010/12/27/post/) [Sekka] IM飲み会2010に参加した
[blog.2011_02_12](https://kiyoka.github.io/blog-archive/2011/02/12/post/) [Sekka] Sekka 0.8.3 リリース
[blog.2011_02_24](https://kiyoka.github.io/blog-archive/2011/02/24/post/) [Sekka] Sekka 0.8.4 リリース
[blog.2011_03_10](https://kiyoka.github.io/blog-archive/2011/03/10/post/) [Sekka] Sekka 0.8.5 リリース
[blog.2011_04_14](https://kiyoka.github.io/blog-archive/2011/04/14/post/) [Sekka] Sekka 0.8.6 リリース
[blog.2011_06_26](https://kiyoka.github.io/blog-archive/2011/06/26/post/) [Sekka] Sekka 0.8.7 リリース
[blog.2011_07_06](https://kiyoka.github.io/blog-archive/2011/07/06/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(1)
[blog.2011_07_07](https://kiyoka.github.io/blog-archive/2011/07/07/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(2)
[blog.2011_07_13](https://kiyoka.github.io/blog-archive/2011/07/13/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(3)
[blog.2011_08_10](https://kiyoka.github.io/blog-archive/2011/08/10/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(4)
[blog.2011_07_31](https://kiyoka.github.io/blog-archive/2011/07/31/post/) [Sekka] Sekka 0.8.8 リリース
[blog.2011_08_18](https://kiyoka.github.io/blog-archive/2011/08/18/post/) [Sekka] グダグダ変換
[blog.2011_08_21](https://kiyoka.github.io/blog-archive/2011/08/21/post/) [Sekka] スペースキーによる変換確定を試す
[blog.2011_08_24](https://kiyoka.github.io/blog-archive/2011/08/24/post/) [Sekka] Sekka 0.9.0 リリース
[blog.2011_08_25](https://kiyoka.github.io/blog-archive/2011/08/25/post/) [Sekka] バグ原因調査: sekka-serverの起動時に辞書の読み込みに失敗する問題
[blog.2011_08_27](https://kiyoka.github.io/blog-archive/2011/08/27/post/) [Sekka] 平仮名フレーズを辞書として持つのは失敗？
[blog.2011_09_03](https://kiyoka.github.io/blog-archive/2011/09/03/post/) [Sekka] Sekka 0.9.1 リリース
[Redis](kiyoka.2011_09_08]] [Sekka] [[http://redis.io/)を試す
[Redis](kiyoka.2011_09_10]] [Sekka] [[http://redis.io/)は仮想メモリ機能を使ってメモリを節約してくれる
[blog.2011_09_17](https://kiyoka.github.io/blog-archive/2011/09/17/post/) [Sekka] Sekka 0.9.2 リリース


# 他に質問などありましたらコメント欄に書きこんで下さい
<!-- Comments section -->

[以上]
