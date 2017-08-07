# Sekkaの変更履歴

## version 1.7.1 (2017年07月25日)
- JRuby 1.7.27上ではRedisなどのリモートKVSが無くても内臓のMapDBだけで動くようにした。
- JRuby 上では，デフォルトの辞書をMapDBを使う。(MapDBの辞書をダウンロードして変換処理無しにした)
- sekka-serverにMapDBのjarを含むようにした。


## version 1.7.0 (2017年06月28日)
- memcachedpod 0.0.2を使うことで、memcachedサーバーを不要にした。
- JRuby 1.7.27で動くようにした。(Rubyスレッドのstack sizeが100KByteでも動くように修正した)
- WebAPIのフォーマットとして、S式の他にJSONをサポートした(Chrome Extension用)
- 外部からの疎通確認用に、/status WebAPIを追加した。


## version 1.6.6 (2017年03月14日)
- CRuby 2.4.0に対応した。
- nendo 0.8.0を使うようにした。
- redis利用時の接続先メッセージを修正した。
- memcachedがダウンしている時は、sekka-serverを起動しないようにした。


## version 1.6.4 (2015年07月08日)
- 辞書を更新した。dictVersion=1.6.2
    - TokyoCabinet、Redis、gdbm用の辞書ファイル(*.tsv)が壊れていたのを修正した。


## version 1.6.3 (2015年05月13日)
- 辞書を更新した。dictVersion=1.6.1
    - 辞書データベースとしてLevelDBを追加した。
    - メモリ効率がよくレスポンスもよい。
    - データベースがCPU非依存のため辞書DBは無加工で配布しているので、一番セットアップが早い。
    - ただし，LevelDBをサポートしたLinuxディストリビューションが少ないためオプションとしている。


## version 1.6.2 (2015年04月21日)
- memcachedが停止していても縮退運転で運用できるようした。
    - 縮退運転中はレスポンスが悪くても運用可能なので、memachedが無い環境でも利用可能となった。
    - なお、約10分ごとにmemcachedを確認して通常運転に復帰する。


## version 1.6.1 (2015年04月18日)
- 辞書を更新した。dictVersion=1.6.0
    - Sekka辞書ファイルにバージョンを含めるように変更した ( SEKKA-JISYO-1.6.0.N.tsv )
    - 以下のカタカナ語を追加した。
        ```
 みす /ミス/
        ```
    - 以下のひらがなフレーズを追加した。
        ```
 しないと /しないと/
 これを /これを/
        ```
    - Nendo 0.7.3を使うようにした。
    - sekka.elのcurlなしのモードでもsekka-serverの自動切り替えをサポートした。


## version 1.6.0 (2015年02月28日)
- 辞書を更新した。dictVersion=1.5.0
    - SMALL辞書を開始し、辞書サイズを１つにした。(元LARGEのみに１本化)
    - 環境変数 SEKKA_LARGE を廃止した。
    - 環境変数 SEKKA_AZIK  を廃止した。


## version 1.5.9 (2015年02月06日)
- 辞書を更新した。dictVersion=1.4.2
- Sekkaの辞書として，2010年8月のものから2015年1月時点のSKK-JISYO.Lに更新した。
- 以下のカタカナ語を追加した。
    ```
 きー /キー/
 ましん /マシン/
 えんじん /エンジン/
 さいと /サイト/
 めもり /メモリ/
     ```
- CRuby 2.2.0で配列のsort-byの挙動が変わり、テストがfailするようになったのを修正した。


## version 1.5.8 (2014年11月29日)
    - sekka.elからcurlなしで変換可能となった。
        - カスタマイズ変数にsekka-use-curlをnilにすると、Emacs内蔵のHTTPクライアントを使う。
        - Windowsはプロセス起動が重いのでこのオプションで高速化できる。


## version 1.5.7 (2014年10月13日)
    - Nendo 0.7.1を使うようにした。
        - Nendo 0.7.0から0.7.1になってマイクロベンチマークで約2倍に高速化したので、sekka-serverのレスポンスも改善した。
    - gemの作成にjeweler2を使うのをやめ、bundlerを使うようにした。


## version 1.5.6 (2014年08月16日)
    - sekka.elをMelpaに公開した
        - sekka.elをMelpaのフォーマットに適合させた。
        - http-get.el と http-cookies.el への依存を外し、gemから両ソースを削除した
        - Melpaの最新版(0.5.0)のpopup.elで動くようにした。


## version 1.5.5 (2014年07月11日)
    - 辞書バージョン1.4.1
        - Sekka使用中に必要と判断したひらがなフレーズを辞書に追加した。


## version 1.5.4 (2014年06月11日)
    - sekka.el
        - 辞書登録をバックグラウンドで実行するようにし、初回変換時の辞書登録待ち時間を無くした。
        - (deferred.el 、concurrent.elを使用)


## version 1.5.3 (2014年06月04日)
    - Nendo 0.7.0を使うようになった。
        - GitHub上の辞書リソースへのURLリダイレクトができなくなっていた問題を修正。 ( Thanks! [[http://github.com/ento|ento (Marica Odagaki)]] )
             - GitHubのルール変更でリポジトリ上のRawdataの直接参照は https://raw.github.com/ では禁止されたため、
             -  https://raw.githubusercontent.com/ を使うようにした。


## version 1.5.2 (2014年04月17日)
    - バグ修正。
    - sekka.el
        - LANG=ja_JP.UTF-8 意外の環境では再変換ができないバグを修正した。
        - Emacsのバッファのコードセットが単なるunicodeになり、カーソル位置の直前の文字のマルチバイト判定に失敗し再変換ができなかった。


## version 1.5.1 (2014年02月09日)
    - CRuby 2.1.0 をサポートした
        - gemの依存規則を、CRuby 2.1.0 をサポートしたNendo 0.6.8に設定した。


## version 1.5.0 (2014年01月26日)
    - Windowsに対応した。
        - sekka-serverにgdbmサポートを追加し、Windows版Rubyで動くようにした。
        - sekka.elをWindows版GNU Emacsに対応
    - GNU Emacs 24.2.1 (i386-mingw-nt6.1.7601) でテスト済み
    - sekka.elがbash無しで動くように変更。(curl.exeコマンドは必要)


## version 1.4.0 (2013年09月09日)
    - 単語の末尾方向からの曖昧検索をサポートした。
        - 例えば「日本語変換」と入力しようした場合、次のように1文字目が抜けていても「日本語変換」が変換候補に出る
```    
!ihongohenkan
```
        - ※ 入力キーワードの末尾から先頭に向かってキーワードマッチングを行う機能追加による効果。Sekka 1.2.4では、「いほんごへんかん」という候補しか出なかった。

    - 辞書バージョン1.4.0
    - 上記の機能を実現するための末尾方向からの曖昧検索インデックスを追加した。
    - AZIKサポートを廃止した。


## version 1.2.4 (2013年08月25日)
    - SekkaServer
        - SekkaServerが辞書バージョン1.3.1をバージョン指定していなかったバグを修正した。


## version 1.2.3 (2013年04月20日)
    - sekka.el
        - フェイルオーバー時のSekkaServerの代替URLのローテーション方法を変更した。
        - SekkaServerへの変換リクエストがタイムアウトした時も、別サーバーにフェイルオーバーするようにした。つまり、connectonTimeoutの場合も代替SekkaServerに切りかわる。
    - nendo の依存バージョンを 0.6.5 に変更した。
    - SekkaServer
        - SekkaServerが処理可能なクエリ文字列最大長を制限した。 (25文字をlimitとした)
    - 辞書バージョン1.3.1
        - 平仮名フレーズの不備を修正した。
        - 辞書バージョン1.3.0にはWikipedia日本語版から抽出した平仮名フレーズが含まれていなかった。


## version 1.2.2 (2013年03月25日)
    - 辞書バージョン1.3.0
        - 平仮名フレーズのコーパスを変更。
        - [[http://s-yata.jp/corpus/nwc2010/|日本語ウェブコーパス 2010]]を廃止してWikipedia日本語版を使うようにした。
    - SMALL辞書とLARGE辞書を使いわけれるようにした。
    - 環境変数で、LARGE辞書が選択される。未定義でSMALLが使われる。
    ```
!export SEKKA_LARGE=1
    ```

## version 1.2.1 (2013年03月14日)
    - プログレスバー表示用gemとして、progressbar をやめ、ruby-progressbar を使うようにした。


# version 1.2.0 (2012年08月14日)
    - version 1.1.4 preからの変更無し


# version 1.1.4.pre (2012年07月10日)
    - バグ修正。
        - インストール済み辞書バージョンのチェック方法が間違っていたのを修正した。
            - キー SEKKA:VERSION ではなく SEKKA::VERSION でチェックしていた。
            - コロンの数が違う。


# version 1.1.3.pre (2012年05月29日)
    - 辞書データの圧縮を行なった。
    - 辞書バージョン1.2.2
        - キーの圧縮
            - マスター辞書のユーザ名 MASTER という文字列を M 1文字に、
            - デリミタ :: を : 1文字にした。
```
 サイズ (MacOS X 64bit上 : Tokyo Cabinet version 1.4.47 for Mac OS X)
  圧縮前 version 1.2.0
   SEKKA-JISYO.SMALL.tsv             0.37GByte 399549310 Byte
   SEKKA-JISYO.SMALL.tch#xmsiz=256m  0.59GByte 631434784 Byte
   Redis-2.5.8 の消費メモリ          1.47GByte
  圧縮後 version 1.2.1
   SEKKA-JISYO.SMALL.tsv             0.30GByte 322684820 Byte  19%減
   SEKKA-JISYO.SMALL.tch#xmsiz=256m  0.50GByte 545817488 Byte  13%減
   Redis-2.5.8 の消費メモリ          1.40GByte                  5%減
```
        - AZIK非搭載の辞書を用意した。
        - AZIKの不要なユーザーはより少ないメモリ消費量で利用できる。
```
  サイズ
 AZIKを含むもの      SEKKA-JISYO.SMALL.A.tsv
  Redis-2.5.8 の消費メモリ          1.40GByte
 AZIKを含まないもの  SEKKA-JISYO.SMALL.N.tsv
  Redis-2.5.8 の消費メモリ          0.46GByte       67%減
```
    - 環境変数
        - !export SEKKA_AZIK=1 が定義されている時だけAZIKを含む辞書が選択される。
        - 設定無しではデフォルトのAZIK非搭載の辞書がインストールされる。


# version 1.1.2.pre (2012年05月29日)
    - リリースミス。欠番。

# version 1.1.1.pre (2012年05月19日)
    - .sekka-jisyoファイルに次の平仮名フレーズの書式を追加した。
```
 既存仕様
  ひらがな	//[改行]
 追加使用
 ひらがな[改行]
```
    - sekka-serverに辞書バージョンの整合性チェック追加した。


# version 1.1.0.pre (2012年05月05日)
    - [[http://github.com/kiyoka/distributed-trie|distributed-trie]]を使って曖昧辞書検索を高速化した。
    - 辞書バージョン1.2.0 
    - Tokyo Cabinetのメモリキャッシュ指定を64MByteから256MByteに増やした。


# version 1.0.0 (2012年04月07日)
    - Memcachedのタイムアウトを1秒に拡大した。


# version 0.9.7 (2012年03月03日)
    - jewelerの仕様変更に対応した
        - カレントディレクトリにGemfileがあると、生成されたgemspecの依存規則に採用されてしまう。
        - SekkaのGemfileはTrivis CI専用なので gemfiles/Gemfile に移動した。
    - rubygems-testに対応した
        - .gemfileをgemに含めた。
        - "rake" のデフォルトタスクではredisのテストを省いた。
        - 辞書データフォーマット変換の出力を簡潔にした。(MD5の結果値のみにした)
        - STDOUT出力と、STDERR出力を混ぜるとrubygems-testがブロックする問題の回避
    - テストのコンソール出力は、STDOUTのみ使うようにした。
    - gem2debでDebianパッケージ化してもsekka-serverが正常に起動するようにした。
        - sekka.ruのパスを RbConfig::CONFIG['vendordir'] を使って解決するようにした。
        - 但し、RbConfig::CONFIG['vendordir'] 配下にsekka.ruが無い場合は、
        - これまで通りsekka-server自身からの相対パスを使う。

# version 0.9.6 (2011年11月08日)
    - gemの依存規則で、Nendoの必須バージョンを0.6.1に限定した。
    - sekka-serverのエラー処理を追加した。
        - memcachedがダウンしている状況をクライアントに報せるようにした。
        - Redis-serverがダウンしている状況をクライアントに報せるようにした。
        - テストスイートにmemcachedとRedis serverへの接続エラーの例外発生ケースを追加した。
        - 公開辞書の提供サイトをsumibi.orgから、DropBoxに変更した。(ハードウェア障害に強いサイトへ)
        - 将来 URLの変更が効くように、github上の以下のファイルにダウンロードURL を記載する方式にした。(自前リダイレクト方式)
```            ```
https://github.com/kiyoka/sekka/blob/master/public_dict/0.9.2/SEKKA-JISYO.SMALL.url
```


# version 0.9.5 (2011年10月15日)
    - sekka.el: url-host関数が呼び出せず、mode-lineのSekka[]の表示が消えるバグを修正した。  (require 'url-parse)が必要だった。
    - sekka.el: sekka-kakutei-with-spacekey のデフォルト値を nil に戻した。
    - sekka.el: sekka-muhenkan-key のデフォルト値をnilに設定した。
    - また、指定したキーをkeymapに設定する必要があるので、カスタマイズ変数でなくした。
    - 例えば、.emacsで(setq sekka-muhenkan-key "q") する必要がある。
    - sekka-serverの辞書追加/既に登録済みのメッセージをシンプルなものに変更した。


# version 0.9.4 (2011年10月06日)
    - sekka.elが変数の初期化不良でsekka-serverに接続できないバグを修正した。
        - 変数 current-sekka-server-url の初期化不良


# version 0.9.3 (2011年10月04日)
    - sekka.elに最大３つの接続先sekka-serverのURLを登録できるようにした。
        - カスタマイズ変数 sekka-server-url、sekka-server-url-2、sekka-server-url-3の３つ。
        - 第一サーバが落ちていたら、第二サーバ、第三サーバを順に試す。
        - モードラインに接続中のsekka-serverのホスト名を常に表示する。
        - これにより、ユーザが意識しなくても自宅で変換した時は自宅サーバーの
        - sekka-serverを使い、オフラインで変換した時は、localhostの
        - sekka-serverを使うという運用ができる。


# version 0.9.2 (2011年09月17日)
    - 辞書用ストレージとして、Redisに対応した。
    - [経緯など]
        -  [[kiyoka.2011_09_08]][Sekka] [[http://redis.io/|Redis]]を試す
        -  [[kiyoka.2011_09_10]][Sekka] [[http://redis.io/|Redis]]は仮想メモリ機能を使ってメモリを節約してくれる
    - 辞書にバージョン番号を含めた。(key=SEKKA::VERSION)
        - [[Sekka.VersionUp]]を参考に古い辞書を一旦削除してください。
        -  sekka-serverへの辞書データアップロード済みかどうかを、上記のキー(SEKKA::VERSION)の有無で判断します。
    - 'q'キーで無変換を指定するユーザ・インタフェースを追加した。
    - 有効/無効は、sekka-muhenkan-keyで 'q' 以外のキーに変更可能。


# version 0.9.1 (2011年09月02日)
    - Ctrl-RでGoogleIME経由の辞書登録と平仮名フレーズの登録の両方を行えるようにした。
    - Tokyo Cabinetのサポートバージョンを 1.4.37 以上に引き下げた。
        - Debian squeezeとUbuntu 10.10以上に含まれるTokyo Cabinetが1.4.37であるため。
    - 辞書ファイルの提供形式をTSV(タブで区切りのテキストファイル)にした。
        - sekka-serverの初期化時にTSVの辞書ファイルをダウンロードし、その場で辞書ファイル(tch)に変換するようにした。
        - (Tokyo Cabinetの辞書は異なるCPUアーキテクチャ間で互換性が無いため)
    - バグ修正
        - M-x 20 [space] でスペースが20文字入るはずが1文字しか入らないバグを修正した。
        - sekka-pathが廃止予定のRubygemsのメソッドの使用をやめた。
```
  https://gist.github.com/1168173
  rubygems 1.8.xの環境では大量の NOTE: の表示が出てしまう
```
        - "2011nen9gatu"などの数字混じりのクエリを変換するとサーバエラーが出る
        - sprintfのフォーマット文字列(%s)と実引数の個数が異なるというエラー。


# version 0.9.0 (2011年08月24日)
    - 平仮名入力時も平仮名フレーズ辞書でスペルミスを救済するようにした。
    - 辞書ソースはWebCorpusとipadic-2.7.0を使用した。
```
  [[http://s-yata.jp/corpus/nwc2010/ngrams/|N-gram コーパス - 日本語ウェブコーパス 2010]]
  [[http://chasen.aist-nara.ac.jp/stable/ipadic/|Index of /stable/ipadic]]
  [経緯など]
   [[kiyoka.2011_07_06]][Sekka] 平仮名フレーズ辞書を追加してみようかな(1)
   [[kiyoka.2011_07_07]][Sekka] 平仮名フレーズ辞書を追加してみようかな(2)
   [[kiyoka.2011_07_13]][Sekka] 平仮名フレーズ辞書を追加してみようかな(3)
   [[kiyoka.2011_08_10]][Sekka] 平仮名フレーズ辞書を追加してみようかな(4)
```
    - gemの依存規則で、Nendoの必須バージョンを0.5.3に限定した。
    - 継続的インテグレーションを開始した。
        - [[http://travis-ci.org/|Travis CI]]でCRuby 1.9.2とCRuby 1.9.3のテストを通るようにした。
        - Travis CIのテスト環境用にkvs.rbにdbmとRubyのHash(オンメモリ)での辞書管理を追加した。
    - リアルタイム候補表示中(サジェスト期間中)はスペースキーで変換可能なユーザ・インタフェースにした。
        - カスタマイズ変数 sekka-kakutei-with-spacekey で有効/無効を制御できる。
        - デフォルトは有効。


# version 0.8.8 (2011年07月31日)
    - gemの依存規則で、Nendoの必須バージョンを0.5.2に限定した。
        - Nendo 0.5.1からNendo 0.5.2に変更することで、Nendo処理系が高速化する。
    - C-gで変換候補のリアルタイム表示を終了するようにした。
    - バグ修正
        - 変換候補の中に漢字候補(type=j)が含まれない場合、候補選択ができないバグを修正した。
        - 後で平仮名から片仮名に選択し直そうと思ってもできない。
        - 例えば、「とらとらとら」を「toratoratora」で入力・確定したあと、Ctrl-Jで変換候補選択に入れない。


# version 0.8.7 (2011年06月24日)
    - gemの依存規則で、Nendoの必須バージョンを0.5.1に限定した。
    - 組み合わせ関数を自前で持たず、Nendoのutil.combinationsを使うようにした。
    - memcacehdプロトコルで辞書を保存する機能を廃止した。
    - Tokyo Cabinetの辞書ファイルが壊れている場合、sekka-server起動時に自動修復するようにした。


#* version 0.8.6 (2011年04月12日)
    - gemの依存規則で、Nendoの必須バージョンを0.4.1に限定した。
    - 今後、NendoのライブラリAPIの仕様変更で動かなくなる可能性があるため。
```
gemspec.add_dependency( "nendo", "= 0.4.1" )
```
    - sekka-server起動時、sekka-serverが使用中のNendoバージョンを表示するようにした。


# version 0.8.5 (2011年03月10日)
    - 辞書中の「数字+単位」の変換をサポート
```
 例)
 "20ko" → "二十個" や "２０個" など
 "5kagetu" → "5ヶ月" や "五ヶ月" など
 "10gatu10ka" → "１０月１０日" や "10月10日" など
```
    - 数字文字列を漢数字に変換する
        - "123450000" → "１２３４５００００" や  "一二三四五〇〇〇〇" 、 "一億二千三百四十五万" に変換するなど
    - バグ修正
        - sekka.el: 変換確定動作で、メジャーモードのfaceを上書きしてしまうバグを修正した。


# version 0.8.4 (2011年02月24日)
    - 変更内容
        - Google IME APIへのアクセスタイムアウトを5秒から20秒に変更した。(Herokuが重い場合があるので、そのための調整)
        - ローマ字表記に xa xi xu xe xo xya xyu xyo xwa xtu を追加した。
        - それぞれ、「ぁぃぅぇぉゃゅょゎっ」に対応する。
    - Sekka最新版のインストールパスを返す sekka-path コマンドを追加した。(Emacs用load-path設定用)
    - バグ修正
        - sekka.el: popupから候補を確定した単語は確定キャンセルが効かないバグを修正した。
        - sekka.el: [Ctrl-J]を連打して変換候補popupが開いた時、無条件に第一候補に引き戻されるバグを修正した。
        - sekka.el: ユーザー辞書ファイル ~/.sekka-jisyo が存在しない場合、辞書登録に失敗するバグを修正した。


# version 0.8.3 (2011年02月12日)
    - 概要
        - ユーザー定義語彙の登録UIを追加。
        - Gogole IME APIを使った未知語の解決をサポート。
        - popup.elを使った候補選択をサポート。
    - その他の変更内容
        - sekka.el: カスタマイズ変数 sekka-no-proxy-hosts を新設。
        - sekka-server: http_proxy環境変数を読んで、proxyサーバー経由のアクセスができるようにした。
        - sekka-server: memcachedサーバーの停止状態を検知して、クライアントにエラーメッセージを返すようにした。



# version 0.8.2 (2010年12月06日)
    - 変更内容
        - Sekka Web APIのベンチマークツール sekka-benchmark を追加した。 (使いかたは[[Sekka.Benchmark]]を参照)
        - sekka.el: viperのサポートを廃止した。
    - バグ修正:
        - 巨大なユーザー辞書ファイル(.sekka-jisyo)を登録すると、sekka.elがエラーになる問題を修正した。


# version 0.8.1 (2010年11月26日)
    - 概要
    - AZIKの定義間違いを多数修正
    - 英語キーボードのサポート
    - 確定undoできる件数を100件までサポート

    - 変更内容
        - 機能追加: sekka.el
        - リリースバージョンをソースコードに自動埋め込むようにした。(rake compile)
        - 2つ以上前に確定した単語に対しても再度候補選択できるようにした。(確定アンドゥ)
        - Emacs１プロセスにつき最大100個の単語を覚えるようにした(カスタマイズ変数で変更可能)
        - カスタマイズ変数により、日本語/英語キーボードを選択できるようにした。(defaultは日本語キーボード)
        - 仕様変更:
            - "'" でも 棒線「ー」が入力可能にした (英語キーボード対応)
        - バグ修正:
            - 棒線 「ー」に対応するローマ字 "-" と ":" がインデクスに登録されない。"^" のみ登録される。
            - 単純な正規表現の記述ミ
            - つまり、辞書に "コーヒー" という単語があっても "Ko-hi-" で引くことができなかった。
            - "Ko^hi^"では引けていた。
            - ユーザー辞書から消した単語がDBに残ってしまう。
            - 単語の追加しかできなかった。
            - M-x sekka-flush-userdict でユーザー辞書をフラッシュできるようにした。(苦肉の策であるが‥)
            - AZIKに「dr」 => 「である」のようなルールが抜けているのを修正した。
            - DDSKKのskk-azik.elのテーブルからテストスイートを生成して、テーブルに抜けが無いかチェックした。


# version 0.8.0 (2010年11月17日)
    - 初回リリース




