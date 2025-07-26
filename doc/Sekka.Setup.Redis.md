# Redisを使って、sekka-serverを構築する

# memcachedをlocalhostにインストールする
 Debian lenny/squeeze では
```bash
sudo aptitude install memcached
```
 でインストールできます。
 OSに付属していない場合はソースからインストールしてください。

# [Redis](http://redis.io/)をインストールする
## Debian squeezeの場合(Ubuntu 10.10以上の場合も同じ手順)
OS付属のRedis Serverで動作します。aptitudeでインストール可能です。
```bash
$ sudo aptitude install redis-server
  .
  .

$ dpkg --list | grep -i redis
ii  redis-server                                    2:1.2.6-1                            Persistent key-value database with network interface
```

## Mac OS Xの場合
 OSに付属していませんのでソースからインストールしてください。


# rubyをインストールする
ソースからインストールしてください。

# gem install sekkaを実行する
sekkaに必要なgemが自動的に全てインストールされます。

# gem install redisを実行する
redis-rb(Redisのクライアントライブラリ)がインストールされます。

# memcachedを起動する
 ※Debian環境では、debをインストールした時点で起動されています。

# redis-serverを起動する
 ※Debian環境では、redis-serverをインストールした時点で起動されています。
 起動確認方法
```bash
$ ps auxw | grep redis
redis     1402  1.4  5.2 106848 105356 ?       Ss   05:59   0:08 /usr/bin/redis-server /etc/redis/redis.conf
```

それ以外の環境ではredis-severをコマンドラインから起動してください。
```bash
$ redis-server
```


# 環境変数を設定する
## localhost の redis-serverに接続する場合
```bash
export SEKKA_DB=redis:
```

## ホスト名 svr のredis-serverに接続する場合
```bash
export SEKKA_DB=redis:svr
```

# sekka-serverを起動する。
SMALL辞書が ~/.sekka-server ディレクトリにダウンロードされ、ダウンロードに成功すれば sekka-serverが起動します。
辞書のダンプイメージ(TSV形式)はダウンロード後、Redisサーバーに登録されます。
```bash
$ sekka-server
Info: Downloading SEKKA-JISYO
Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv http://sumibi.org/sekka/dict/0.9.2/SEKKA-JISYO.SMALL.tsv
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  223M  100  223M    0     0  11.2M      0  0:00:19  0:00:19 --:--:-- 11.2M
Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.md5 http://sumibi.org/sekka/dict/0.9.2/SEKKA-JISYO.SMALL.md5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    56  100    56    0     0  11166      0 --:--:-- --:--:-- --:--:-- 56000
   downloaded file's MD5 : 29f232626c20d22f44b4e4b1f34f17f8
             correct MD5 : 29f232626c20d22f44b4e4b1f34f17f8
Info:  downloaded file [/home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv] verify OK.
Info: Checking SEKKA jisyo on redis server...
Info: Uploading...
Command : sekka-jisyo restore /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv redis:localhost
Restore:       100% |ooooooooooooooooooooooooooooooooooooooooooo| ETA:  00:00:10
Info: [OK]
Info: database file was clean
----- Sekka Server Started -----
  Sekka version  : 0.9.2
  Nendo version  : 0.5.3
  dict-type      : redis
  dict-db        : localhost
  memcached      : localhost:11211
  listenPort     : 12929
  proxyHost      : 
  proxyPort      : 
--------------------------------
```

上記のメッセージが表示され、クライアントからのリクエスト待ち状態になります。


[Sekka.Setup](Sekka.Setup.md)ページに戻る
