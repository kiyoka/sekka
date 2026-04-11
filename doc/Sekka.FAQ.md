# SekkaのFAQ

これまでに聞かれた質問に答えます。
操作マニュアルに書かれていない便利な小ネタもここに書かれていることもあります。
技術的なこと、アーキテクチャ設計の話題もいくつかあります。


## Sekkaの名前の由来は？
名前を付けるとき、二つのことに留意して付けました。
ひとつは、SKKから影響を受けているので "S" "K" "K" の3文字を入れること。
複数の日本語変換エンジン開発しているので、自分の作品を "火" シリーズにしたかったこと。
アルファベットだけで考えると、Sekki(石器)とかSankaku(三角)とかSikaku(四角)とか覚えやすい名前も色々あったのですが、最終的に「電光石火」という言葉から「石火(Sekka)」に決めました。

## SKKがあるのに何故別の入力メソッドを作ったの？
自分の入力の癖を振りかえってみると、日本語変換中にミスタイプが多く、ミスタイプを許容してくれる入力方式があれば使いやすいだろう以前から思っていました。
しかし、DDSKKなど既存のソースコードに手を入れるのは難しいのでやりませんでした。
しばらくして、開発中の[Nendo](https://github.com/kiyoka/nendo)というオレ処理系が使えるレベルかどうか検証するためにも何らかの実用アプリを作ってみる必要があったので[Nendo](https://github.com/kiyoka/nendo)で書いてみることにしました。
最初はプロトタイプのつもりで作ったのですが、予想以上に使いやすく、SKKを置き換えれるレベルになりそうだったので、細かい作りこみまで進めることになったのです。

その後、サーバー不要で動作するよう全体をpure Emacs Lispに移植しました。



## モードレス変換はどこから思いつきましたか？
ローマ字のまま変換するモードレス変換の歴史は古く、boiled-egg、yc.elなど過去にお手本があります。
yc.elを使っていた時期もありましたので、SKKもモードレスにしてみたいというのは自然な流れでした。


## 曖昧マッチングアルゴリズムは何を使っていますか？
SymSpellアルゴリズムを使っています。辞書ロード時に各キーの「削除バリアント」を事前計算してhash-tableに格納し、検索時はhash-table lookupのみで高速に候補を取得します。
以前のバージョンではJaro-Winkler距離を使っていましたが、pure Emacs Lisp化に伴いSymSpellに変更しました。


## 開発ブログはありますか？
Sekka専用のブログはありませんが、古い記事が残っています。

以下が関連記事のリンクです。

- [blog.2010_05_08](https://kiyoka.github.io/blog-archive/2010/05/08/post/) [創作心理] 今作りたいもの
- [blog.2010_08_08](https://kiyoka.github.io/blog-archive/2010/08/08/post/) [創作心理] 今創りたいもの(2) 『modeless SKK』
- [blog.2010_08_10](https://kiyoka.github.io/blog-archive/2010/08/10/post/) [創作心理][SKK] modeless SKK
- [blog.2010_08_12](https://kiyoka.github.io/blog-archive/2010/08/12/post/) [Nendo][Sekka] TDD(テスト駆動開発)の重要性
- [blog.2010_08_24](https://kiyoka.github.io/blog-archive/2010/08/24/post/) [Ruby][Sekka] Rackについて学ぶ
- [blog.2010_08_30](https://kiyoka.github.io/blog-archive/2010/08/30/post/) [Sekka] Sticky-shiftを試してみたら、小指が痛くなくなった。
- [blog.2010_09_06](https://kiyoka.github.io/blog-archive/2010/09/06/post/) [KVS][Sekka] 個人的なNoSQL(KVS)のライセンス調査
- [blog.2010_09_18](https://kiyoka.github.io/blog-archive/2010/09/18/post/) [KVS][Sekka] NoSQL(KVS)の選定の続き
- [blog.2010_09_21](https://kiyoka.github.io/blog-archive/2010/09/21/post/) [Sekka][Nendo] NendoがSekkaの足を引っぱっている
- [blog.2010_10_13](https://kiyoka.github.io/blog-archive/2010/10/13/post/) [Ruby] fuzzy-string-match 0.9.0 リリース
- [blog.2010_11_01](https://kiyoka.github.io/blog-archive/2010/11/01/post/) [Sekka][SKK] 石火(Sekka)の日本語入力のデモビデオ公開
- [blog.2010_11_02](https://kiyoka.github.io/blog-archive/2010/11/02/post/) [Sekka] AZIK対応に挑戦
- [blog.2010_11_16](https://kiyoka.github.io/blog-archive/2010/11/16/post/) [Sekka] Sekka 0.8.0 リリース
- [blog.2010_11_29](https://kiyoka.github.io/blog-archive/2010/11/29/post/) [Sekka] Sekka 0.8.1 リリース
- [blog.2010_11_30](https://kiyoka.github.io/blog-archive/2010/11/30/post/) [Sekka] 「modeless SKK」を着想してから「Sekka」が具現化するまで道のり
- [blog.2010_12_01](https://kiyoka.github.io/blog-archive/2010/12/01/post/) [Sekka] ユーザー語彙登録UIについて考える
- [blog.2010_12_05](https://kiyoka.github.io/blog-archive/2010/12/05/post/) [Sekka] ユーザー語彙登録UIについて考える(続き)
- [blog.2010_12_06](https://kiyoka.github.io/blog-archive/2010/12/06/post/) [Sekka] Sekka 0.8.2 リリース
- [blog.2010_12_27](https://kiyoka.github.io/blog-archive/2010/12/27/post/) [Sekka] IM飲み会2010に参加した
- [blog.2011_02_12](https://kiyoka.github.io/blog-archive/2011/02/12/post/) [Sekka] Sekka 0.8.3 リリース
- [blog.2011_02_24](https://kiyoka.github.io/blog-archive/2011/02/24/post/) [Sekka] Sekka 0.8.4 リリース
- [blog.2011_03_10](https://kiyoka.github.io/blog-archive/2011/03/10/post/) [Sekka] Sekka 0.8.5 リリース
- [blog.2011_04_14](https://kiyoka.github.io/blog-archive/2011/04/14/post/) [Sekka] Sekka 0.8.6 リリース
- [blog.2011_06_26](https://kiyoka.github.io/blog-archive/2011/06/26/post/) [Sekka] Sekka 0.8.7 リリース
- [blog.2011_07_06](https://kiyoka.github.io/blog-archive/2011/07/06/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(1)
- [blog.2011_07_07](https://kiyoka.github.io/blog-archive/2011/07/07/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(2)
- [blog.2011_07_13](https://kiyoka.github.io/blog-archive/2011/07/13/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(3)
- [blog.2011_08_10](https://kiyoka.github.io/blog-archive/2011/08/10/post/) [Sekka] 平仮名フレーズ辞書を追加してみようかな(4)
- [blog.2011_07_31](https://kiyoka.github.io/blog-archive/2011/07/31/post/) [Sekka] Sekka 0.8.8 リリース
- [blog.2011_08_18](https://kiyoka.github.io/blog-archive/2011/08/18/post/) [Sekka] グダグダ変換
- [blog.2011_08_21](https://kiyoka.github.io/blog-archive/2011/08/21/post/) [Sekka] スペースキーによる変換確定を試す
- [blog.2011_08_24](https://kiyoka.github.io/blog-archive/2011/08/24/post/) [Sekka] Sekka 0.9.0 リリース
- [blog.2011_08_25](https://kiyoka.github.io/blog-archive/2011/08/25/post/) [Sekka] バグ原因調査: sekka-serverの起動時に辞書の読み込みに失敗する問題
- [blog.2011_08_27](https://kiyoka.github.io/blog-archive/2011/08/27/post/) [Sekka] 平仮名フレーズを辞書として持つのは失敗？
- [blog.2011_09_03](https://kiyoka.github.io/blog-archive/2011/09/03/post/) [Sekka] Sekka 0.9.1 リリース
- [blog.2011_09_17](https://kiyoka.github.io/blog-archive/2011/09/17/post/) [Sekka] Sekka 0.9.2 リリース

