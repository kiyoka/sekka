# Sekka用NGRAM辞書

## 概要
隣接する形態素の共起頻度を使ってSekkaの変換精度を上げるためのものです。
本ドキュメントは辞書の元になるコーパスデータの作りかたと保存先URLを記載しています。

## 共起頻度データ
nwc2010 のサイトから共起頻度データをダウンロードして txt 化します。

### ダウンロード (頻度1000回以上のデータ)
wget http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over999/2gms/2gm-0000.xz && sz -d 2gm-0000.xz
wget http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over999/3gms/3gm-0000.xz && sz -d 3gm-0000.xz

## txt化したもの
以下に置いています。
SekkaのRakefileから利用する時に事前にダウンロードする必要があります。
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/2gm.1000.txt
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/3gm.1000.txt

[以上]
