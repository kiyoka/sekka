# LevelDBを使って、sekka-serverを構築する

# memcachedをlocalhostにインストールする
 Debian lenny/squeeze では
```bash
sudo aptitude install memcached
```
 でインストールできます。
 OSに付属していない場合はソースからインストールしてください。

# [Redis](http://redis.io/)をインストールする
## Debian weezyの場合(Ubuntu 10.10以上の場合も同じ手順)
OS付属のLevelDBが利用できます。
```bash
$ sudo aptitude install libleveldb-dev
  .
  .

$ dpkg --list | grep leveldb
ii  libleveldb-dev:amd64                      0+20120530.gitdd0d562-1            amd64        fast key-value storage library (development files)
ii  libleveldb1:amd64                         0+20120530.gitdd0d562-1            amd64        fast key-value storage library
```

## Mac OS Xの場合
 OSに付属していませんのでソースからインストールしてください。


# rubyをインストールする
ソースからインストールしてください。

# gem install sekkaを実行する
sekkaに必要なgemが自動的に全てインストールされます。

# gem install leveldbを実行する
LevelDBのクライアントライブラリがインストールされます。

# memcachedを起動する
 ※Debian環境では、debをインストールした時点で起動されています。


# 環境変数を設定する
```bash
export SEKKA_DB=leveldb
```

# sekka-serverを起動する。
Sekka辞書が ~/.sekka-server ディレクトリにダウンロードされ、ダウンロードに成功すれば sekka-serverが起動します。
```bash
$ sekka-server
Info: Downloading SEKKA-JISYO
Command : curl https://raw.githubusercontent.com/kiyoka/sekka/master/public_dict/1.6.1/SEKKA-JISYO-1.6.1.N.ldb.tar.gz.url
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    88  100    88    0     0    116      0 --:--:-- --:--:-- --:--:--   146
   download   URL of target file : https://s3-ap-northeast-1.amazonaws.com/sekkadict/1.6.1/SEKKA-JISYO-1.6.1.N.ldb.tar.gz


Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO-1.6.1.N.ldb.tar.gz https://s3-ap-northeast-1.amazonaws.com/sekkadict/1.6.1/SEKKA-JISYO-1.6.1.N.ldb.tar.gz


  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 65.0M  100 65.0M    0     0  6982k      0  0:00:09  0:00:09 --:--:-- 7207k
Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO-1.6.1.N.ldb.tar.gz.md5 https://raw.githubusercontent.com/kiyoka/sekka/master/public_dict/1.6.1/SEKKA-JISYO-1.6.1.N.ldb.tar.gz.md5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    72  100    72    0     0    111      0 --:--:-- --:--:-- --:--:--   150
   downloaded file's MD5 : bf19c45609846badd608722e657da607
             correct MD5 : bf19c45609846badd608722e657da607
Info:  downloaded file [/home/kiyoka/.sekka-server/SEKKA-JISYO-1.6.1.N.ldb.tar.gz] verify OK.
Info: Checking SEKKA jisyo on leveldb server...
Info: Extracting...
Command : tar zxCf /home/kiyoka/.sekka-server /home/kiyoka/.sekka-server/SEKKA-JISYO-1.6.1.N.ldb.tar.gz
Info: [OK]
----- Sekka Server Started -----
  Sekka version  : 1.6.3
  Nendo version  : 0.7.3
  dict  version  : 1.6.1
  dict-type      : leveldb
  dict-db        : /home/kiyoka/.sekka-server/SEKKA-JISYO-1.6.1.N.ldb
  memcached      : localhost:11211
  listenPort     : 12929
  proxyHost      :
  proxyPort      :
  maxQueryLength : 25
--------------------------------
[2015-05-10 23:00:05] INFO  WEBrick 1.3.1
[2015-05-10 23:00:05] INFO  ruby 2.0.0 (2015-02-25) [x86_64-linux]
[2015-05-10 23:00:05] INFO  WEBrick::HTTPServer#start: pid=8196 port=12929
```

上記のメッセージが表示され、クライアントからのリクエスト待ち状態になります。


[Sekka.Setup](Sekka.Setup.md)ページに戻る
