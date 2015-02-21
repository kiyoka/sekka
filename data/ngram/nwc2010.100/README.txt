# Sekka用NGRAM辞書

## 概要
隣接する形態素の共起頻度を使ってSekkaの変換精度を上げるためのものです。
本ドキュメントは辞書の元になるコーパスデータの作りかたと保存先URLを記載しています。

## 共起頻度データ
nwc2010 のサイトから共起頻度データをダウンロードして txt 化します。

### ダウンロード (頻度100回以上のデータ)

以下を結合して 2gm.100.txt として保存します。
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/2gms/2gm-0000.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/2gms/2gm-0001.xz

以下を結合して 3gm.100.txt として保存します。
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0000.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0001.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0002.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0003.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0004.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over99/3gms/3gm-0005.xz

## txt化したもの
以下に置いています。
SekkaのRakefileから利用する時に事前にダウンロードする必要があります。
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/2gm.100.txt.gz
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/3gm.100.txt.gz

[以上]
