# [Sekka](Sekka)(石火)のセットアップ手順

## てっとりばやいセットアップ方法
手元にDockerが使える環境があれば、こちらの手順がおすすめです。Ruby/gem/memcached/辞書 など全部入りのDockerイメージがあります。
 [kiyoka/sekka - GitHub](http://github.com/kiyoka/sekka)


## 必要システム(Dockerが使えない場合)
- Mac OS X 10.6(Snow Leopard)/10.7(Lion)、Debian 5.0(lenny)と6.0(squeeze)、Windows 7動作確認しています。
-- ruby          1.9.2、1.9.3、2.0.0、2.2.0でテスト済み (WindowsはRubyInstaller.org 1.9.3)
 Travis-CIで複数バージョンのrubyで動作確認しています。
 [Travis CI - Distributed build platform for the Ruby community](http://travis-ci.org/#!/kiyoka/sekka/builds/85100)
 ![](http://travis-ci.org/kiyoka/sekka.png)
-- memcached     1.2.2、 1.4.5 でテスト済み
-- [Tokyo Cabinet](http://fallabs.com/tokyocabinet/) 1.4.37、1.4.46 でテスト済み
-- [Redis](http://redis.io/)         1.2.6、2.2.12、2.4.2、3.0.0でテスト済み
-- LevelDB       1.15.0 でテスト済み
-- curl          7.19でテスト済み
-- Emacs         23、24でテスト済み。WindowsはGNU Emacs 24.2.1 (i386-mingw-nt6.1.7601) でテスト済み。
-- apel          10.7、10.8 でテスト済み (但し、Emacs24ではapel 10.8を使う必要があります)


## 辞書ストレージサーバの選択
[Tokyo Cabinet](Sekka]] の辞書ストーレージサーバとして[[http://fallabs.com/tokyocabinet/)、[Redis](http://redis.io/)、[LevelDB](http://leveldb.org/)、gdbmのどれかから選ぶことができます。
一番バランスが良いのはLevelDBで少ないメモリでもかなり快適に使えます。
sekka-serverを動かすサーバの空きメモリサイズによって決めてください。

### OSにLevelDBが付属している場合
Debian lenny/squeeze Ubuntu 10.10以上では、簡単にLevelDBをインストールできます。
環境によってはTokyo Cabinetがインストールしやすいため、Tokyo Cabinetもよいでしょう。
gdbmはI/O負荷が高く、あまりおすすめできません。Windowsでgdbmしか選択肢が無い場合などに使います。

### 搭載メモリが多い場合
Redis用に800MByte程度のメモリを使える場合、Redisが応答速度が良いです。
Debian       squeeze Ubuntu 10.10以上では、簡単にRedisをインストールできます。

## sekka-serverの環境構築
LevelDBを使う場合
→ [Sekka.Setup.LevelDB](Sekka.Setup.LevelDB)

Tokyo Cabinetを使う場合
→ [Sekka.Setup.TokyoCabinet](Sekka.Setup.TokyoCabinet)

Redisを使う場合
→ [Sekka.Setup.Redis](Sekka.Setup.Redis)

gdbmを使う場合
→ [Sekka.Setup.gdbm](Sekka.Setup.gdbm)


### proxyサーバーの指定
sekka-server はGoogleImeApiを使います。
httpプロキシサーバーを経由する必要がある場合は、sekka-serverの起動前に環境変数http_porxyを設定してください。
```bash
#bash用コマンドライン(.bashrcに入れるなどしてください)
export http_proxy="http://プロキシサーバーのホスト名:ポート番号"
```

 設定例
```bash
export http_proxy="http://host.example.com:8080/"
```

なお、sekka-serverが環境変数を正しく読み込めたかどうかは、sekka-serverの起動メッセージで確認しくてください。
 上記設定での表示例
```bash
----- Sekka Server Started -----
     .
     .
     .
  proxyHost : host.example.com
  proxyPort : 8080
--------------------------------
```


## sekka.el(Emacs側)のインストール
# ~/.emacsに以下を追加します。
```bash
(when (= 0 (shell-command "sekka-path"))
  (push (concat (car (split-string (shell-command-to-string "sekka-path"))) "/emacs") load-path)
  (require 'sekka)
  ;;(setq sekka-sticky-shift t)   ;; sticky-shiftを使用する場合、この行を有効にする
  ;;(setq sekka-muhenkan-key "q") ;; sekka-kakutei-with-spacekey を tにした時専用。"q"キーで即無変換にする。
  (global-sekka-mode 1))
```
# Emacsを起動します。
# Emacsのモードラインに 「Sekka」という文字が出たらインストール完了です。
# Emacsからの操作方法は[Sekka.Emacs](Sekka.Emacs)を参照してください。


## sekka-serverを多人数で共有する
sekka-serverは、マルチユーザー環境を考慮して設計されています。
sekka-serverのWebAPIは、引数のユーザーID毎にユーザー辞書が保存されます。
(sekka.elはユーザーIDとしてUNIXのログインアカウント名を使う設計になっています)

そのため、チームで1台のsekka-serverを用意し、リモートから複数ユーザーで同時利用することができます。
※ sekka.elのカスタマイズ変数 sekka-sever-url はデフォルトで localhost:12929 となっています。このホスト名を書きかえればEmacsからリモートサーバーにアクセスできます。


## memcachedについて
sekka-serverの内部でmemcachedがlocalhostに存在することを前提としてハードコーディングされています。
sekka-serverと同一ホスト内にmemcachedをインストールしてください。

## 参考リンク
- [日本語入力メソッド Sekkaのインストール - Practice of Programming](http://d.hatena.ne.jp/ktat/20110210/1297276515)
 ktatさんによるUbuntu 10.04へのインストール手順

[以上]
