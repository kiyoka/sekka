# Tokyo Cabinetを使って、sekka-serverを構築する

# memcachedをlocalhostにインストールする
 Debian lenny/squeeze では
```bash
sudo aptitude install memcached
```
 でインストールできます。
 OSに付属していない場合はソースからインストールしてください。

# [Tokyo Cabinet](http://fallabs.com/tokyocabinet/)(Cライブラリ)をインストールする
## Debian lennyの場合
 Debian lennyのTokyo Cabinetはrubygems.orgに存在するバージョンよりも古い
 ので、tokyocabinetのgemのコンパイル時にエラーが出ます。
 ソースからインストールしてください。

## Debian squeezeの場合(Ubuntu 10.10以上の場合も同じ手順)
OS付属のTokyo Cabinetで動作します。aptitudeでインストール可能です。
```bash
$ sudo aptitude install libtokyocabinet-dev libtokyocabinet8 tokyocabinet-bin
   .
   .

$ dpkg --list | grep tokyocab
ii  libtokyocabinet-dev  1.4.37-6             Tokyo Cabinet Database Libraries [development]
rc  libtokyocabinet3     1.2.1-1              Tokyo Cabinet Database Libraries [runtime]
ii  libtokyocabinet8     1.4.37-6             Tokyo Cabinet Database Libraries [runtime]
ii  tokyocabinet-bin     1.4.37-6             Tokyo Cabinet Database Utilities
```

## Mac OS Xの場合
 OSに付属していませんのでソースからインストールしてください。

# rubyをソースからインストールする
ソースからインストールしてください。

# gem install sekkaを実行する
sekkaに必要なgemが自動的に全てインストールされます。

# gem install tokyocabinetを実行する
TokyoCabinetのクライアントライブラリがインストールされます。

# memcachedを起動する
 ※Debian環境では、debをインストールした時点で起動されています。


# sekka-serverを起動する。
SMALL辞書が ~/.sekka-server ディレクトリにダウンロードされ、ダウンロードに成功すれば sekka-serverが起動します。
辞書のダンプイメージ(TSV形式)はダウンロード後、*.tchに変換されます。
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
Info: Converting TSV file to Tokyo Cabinet *.tch
Command : tchmgr importtsv /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tch /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv
Restore:       100% |ooooooooooooooooooooooooooooooooooooooooooo| ETA:  00:00:10
Info: [OK]
Info: inform *.tch
Command : tchmgr inform /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tch
path: /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tch
database type: hash
additional flags:
bucket number: 131071
used bucket number: 131071
alignment: 16
free block pool: 1024
inode number: 6554283
modified time: 2011-09-02T22:17:27+09:00
options:
record number: 3873010
file size: 310252208
Info: database file was clean
----- Sekka Server Started -----
  Sekka version  : 0.9.1
  Nendo version  : 0.5.3
  dict-db        : /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tch
  memcached      : localhost:11211
  listenPort     : 12929
  proxyHost      : 
  proxyPort      : 
--------------------------------
```

上記のメッセージが表示され、クライアントからのリクエスト待ち状態になります。


[Sekka.Setup](Sekka.Setup)ページに戻る
