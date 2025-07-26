# gdbmを使って、sekka-serverを構築する

# memcachedをlocalhostにインストールする
 Debian lenny/squeeze では
```bash
sudo aptitude install memcached
```
 でインストールできます。
 OSに付属していない場合はソースからインストールしてください。
 Windows環境では、Windowsサービスとしてインストール可能なmemcachedサーバーが多数公開されています。googleで探してインストールしてください。

# gdbmを使える状態でRubyをインストールする
-- Windowsの場合
rubyinstaller.orgのインストーラがgdbmを内蔵しています。

## Linux/Mac OS Xの場合
gdbmが使える状態でRubyをインストールしてください。

# memcachedを起動する
 ※Debian環境では、debをインストールした時点で起動されています。

# 環境変数を設定する
```bash
export SEKKA_DB=gdbm
```

# sekka-serverを起動する。
SMALL辞書が ~/.sekka-server ディレクトリにダウンロードされ、ダウンロードに成功すれば sekka-serverが起動します。
辞書のダンプイメージ(TSV形式)はダウンロード後、*.dbに変換されます。
```bash
$ sekka-server
Info: Downloading SEKKA-JISYO
Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv http://sumibi.org/sekka/dict/0.9.1/SEKKA-JISYO.SMALL.tsv
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  223M  100  223M    0     0  11.2M      0  0:00:19  0:00:19 --:--:-- 11.2M
Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.md5 http://sumibi.org/sekka/dict/0.9.1/SEKKA-JISYO.SMALL.md5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    56  100    56    0     0  12283      0 --:--:-- --:--:-- --:--:-- 56000
   downloaded file's MD5 : 45a44858336d1dc310c04956f92c72e4
             correct MD5 : 45a44858336d1dc310c04956f92c72e4
Info:  downloaded file [/home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv] verify OK.
Info: Checking SEKKA jisyo on gdbm server...
Info: Uploading...
Command : sekka-jisyo restore /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.N.tsv /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.N.db
Time: 00:56:30 |=================================================================================================================================================| 100% retore    
Info: [OK]
----- Sekka Server Started -----
  Sekka version  : 1.5.0
  Nendo version  : 0.6.6
  dict  version  : 1.4.0
  dict-type      : gdbm
  dict-db        : /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.N.db
  memcached      : localhost:11211
  listenPort     : 12929
  proxyHost      : 
  proxyPort      : 
  maxQueryLength : 25
--------------------------------
[2013-12-22 00:57:21] INFO  WEBrick 1.3.1
[2013-12-22 00:57:21] INFO  ruby 2.0.0 (2013-11-22) [x86_64-linux]
[2013-12-22 00:57:21] INFO  WEBrick::HTTPServer#start: pid=31721 port=12929
```

上記のメッセージが表示され、クライアントからのリクエスト待ち状態になります。


[Sekka.Setup](Sekka.Setup)ページに戻る
