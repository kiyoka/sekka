# Sekkaのベンチマーク
このページでは、Sekka付属のベンチマークツールを使ったベンチマーク方法について解説します。
※ Sekka version 0.8.2から付属しています。

# sekka-benchmarkについて
localhostで起動しているsekka-serverに対してWeb APIのスループットを実測するツールです。
OSやハードウェアによって大きくパフォーマンスが変わるので、それを手軽に計測することが目的です。
同一のローマ字で連続100回リクエストするパターンや、全て異なるローマ字を連続100回リクエストするパターンなどを用意しています。

## 使いかた
sekka-benchmarkを引数なしで起動すると使いかたが表示されます。
```bash
$ ./sekka-benchmark 
Usage : 
  sekka-benchmark samekey0  .... henkan 100 times with same keyword  [Kanji]        (get N candidate)
  sekka-benchmark samekey1  .... henkan 100 times with same keyword  [Kanji]        (get 1 candidate)
  sekka-benchmark uniqkey0  .... henkan 100 times with uniq keywords [Aimai Ao ...] (get N candidate)
```

## 計測にあたっての注意
![](https://cacoo.com/diagrams/jzRPejte9jsbhbBp-6912B.png)
sekka-serverは、一度計算した変換リクエストをmemcachedでキャッシュする構造になっています。
従って、同一のローマ字で100回の変換リクエストを行う 'samekey0' などは 99回はmemcachedに蓄積されているキャッシュが使われます。

sekka-severが使っているTokyoCabinetでは、辞書DBがmmapシステムコールでファイルシステムにマッピングされているため、readしている箇所から局所的にじわじわメモリにキャッシュされます。
このように、計測の際にはキャッシュの特性をある程度把握した上で行ってください。

sekka-benchmarkはcurlコマンドを使用しており、100回のhttpリクエストには100回のcurlコマンドの起動が行われます。
従って、sekka-server単体では計測値よりももっと良い結果が出る可能性があります。
ただ、sekka.elの内部でも同様にcurlコマンドを起動しており、条件は同一なので、クライアント側の高速化は行っていません。

## 各パターンの説明

- samekey0
"Kanji"というローマ字で /henkan というAPIを100回叩くベンチマークです。
返却する変換候補数は「無制限」です。
そのため、samekey1よりも返却されるデータ容量は多いです。

- samekey1
samekey0 の返却する変換候補数制限版です。
返却する変換候補数を「1」 に設定しています。

- uniqkey0
100個のユニークなローマ字で /henkan というAPIを100回叩くベンチマークです。
返却する変換候補数は「無制限」です。
ローマ字の例:
 "Aimai" "Ao" "Aoumigame" "Akakeitou" "Bangou" ... 100個

## 計測例
次の例は uniqkey0 のベンチマークを使った計測手順です。
 sekka-server: version 0.8.2
 OS : Mac OS X snow leopard
 辞書DB : LARGE辞書(407MByteのtch)
 ハードウェア: MacBook Pro '13
 CPU: 2.4 GHz Intel Core 2 Duo
 RAM: 4 GByte

# 何もキャッシュしない状態で計測
## OSをリブートする(TokyoCabinetがDBをmmapした時のファイルシステムに対するバッファをクリアするため)
## sekka-server , memcachedを起動する
## sekka-benchmark uniqkey0を実行する
```bash
$ ./sekka-benchmark uniqkey0
----------------------------------------
[Uniqkey limit=0]
      user     system      total        real
....................................................................................................
  0.290000   0.600000   1.770000 (165.929929)
```
約166秒かかった。

# memcachedが全件キャッシュした場合を計測
## sekka-benchmark uniqkey0を再度実行する
```bash
$ ./sekka-benchmark uniqkey0
----------------------------------------
[Uniqkey limit=0]
      user     system      total        real
....................................................................................................
  0.040000   0.270000   1.200000 (  3.828723)
```
約4秒かかった。

# memcachedのキャッシュをクリアして計測
## memcachedを再起動する
```bash
memcached
^C
$ memcached
```

## sekka-benchmark uniqkey0を実行する
```bash
$ ./sekka-benchmark uniqkey0
----------------------------------------
[Uniqkey limit=0]
      user     system      total        real
....................................................................................................
  0.050000   0.290000   1.230000 ( 21.766171)
```
約22秒かかった。

## 計測例の考察
sekka-serverはTokyoCabinetとmemcahcedのそれぞれのキャッシュ状況がパフォーマンスに影響を与えます。
OSの再起動直後や初めて変換する語句には処理時間がかかりますが、長時間運用すると頻繁に使う語句から順にリアルタイムに近い速度で反応が返ってくるようになります。


[以上]
