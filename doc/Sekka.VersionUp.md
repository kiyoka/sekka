# [Sekka](Sekka)(石火)のバージョンアップ手順
まだ[Sekka](Sekka)がインストールされていない場合は、[Sekka.Setup](Sekka.Setup)を参照してください。

## Sekka本体のバージョンアップ
既に[Sekka](Sekka)の過去バージョンがインストール済であれば、次のコマンドでバージョンアップできます。
!$ gem update

## EmacsLispのバージョンアップ
gem updateすると最新のSekkaのgemがインストールされ、sekka.el の場所が変わります。
[Sekka.Setup](Sekka.Setup)の例のように、sekka-pathコマンドを使った設定をしていれば、自動的に最新のEmacsLispをロードします。


## 辞書の更新について
Sekkaのバージョンアップにともなって、辞書の構造や登録エントリ数が増えていることがあります。
その場合は、以下のコマンドでサーバ側辞書の削除が必要です。
! /bin/rm ~/.sekka-server/*.tsv

### 辞書の削除が必要なバージョンアップは以下の通りです
- sekka-1.6.0へのバージョンアップ時
- sekka-1.5.5へのバージョンアップ時
- sekka-1.4.0へのバージョンアップ時
- sekka-1.2.4へのバージョンアップ時

次のsekka-serverの起動タイミングで、sekka-serverのバージョンにマッチした辞書が自動的にダウンロードされます。
これで、辞書の更新が完了します。
!$ sekka-server
!Info: Downloading SEKKA-JISYO
!Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv http://sumibi.org/sekka/dict/0.9.2/SEKKA-JISYO.SMALL.tsv
!  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
!                                 Dload  Upload   Total   Spent    Left  Speed
!100  223M  100  223M    0     0  11.2M      0  0:00:19  0:00:19 --:--:-- 11.2M
!Command : curl -o /home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.md5 http://sumibi.org/sekka/dict/0.9.2/SEKKA-JISYO.SMALL.md5
!  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
!                                 Dload  Upload   Total   Spent    Left  Speed
!100    56  100    56    0     0  11166      0 --:--:-- --:--:-- --:--:-- 56000
!   downloaded file's MD5 : 29f232626c20d22f44b4e4b1f34f17f8
!             correct MD5 : 29f232626c20d22f44b4e4b1f34f17f8
!Info:  downloaded file [/home/kiyoka/.sekka-server/SEKKA-JISYO.SMALL.tsv] verify OK.
!Info: Checking SEKKA jisyo on redis server...
!    .
!    .

### 学習結果は削除されます
ユーザ登録語彙はローカルのユーザ語彙ファイル .sekka-jisyo に保存されていますが、選択候補の学習結果はサーバ側の辞書にしか保存されない残念な仕様です。ごめんなさい。
例えば、句読点を「、。」を最後に確定したという情報はサーバ側の辞書 *.tch にしか無いため、serkka-server用辞書を入れかえると「，．」が最初に出ます。


### .sekka-jisyoの内容は維持されます
Emacsを再起動後、初回変換時に、.sekka-jisyoの内容が全て再送信されます。
それにより、サーバ側の辞書データに全てのユーザ語彙が復元されます。
※ この再登録中は、sekka-serverの負荷が少し上がります。

<!-- Comments section -->
