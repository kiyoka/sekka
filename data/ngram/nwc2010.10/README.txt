# Sekka用NGRAM辞書

## 概要
隣接する形態素の共起頻度を使ってSekkaの変換精度を上げるためのものです。
本ドキュメントは辞書の元になるコーパスデータの作りかたと保存先URLを記載しています。

## 共起頻度データ
nwc2010 のサイトから共起頻度データをダウンロードして txt 化します。

### ダウンロード (頻度10回以上のデータ)

以下を結合して 2gm.10.txt として保存します。
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0000.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0001.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0002.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0003.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0004.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0005.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/2gms/2gm-0006.xz


以下を結合して 3gm.10.txt として保存します。
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0000.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0001.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0002.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0003.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0004.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0005.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0006.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0007.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0008.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0009.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0010.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0011.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0012.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0013.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0014.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0015.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0016.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0017.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0018.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0019.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0020.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0021.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0022.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0023.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0024.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0025.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0026.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0027.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0028.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0029.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0030.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0031.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0032.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0033.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0034.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0035.xz
http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over9/3gms/3gm-0036.xz

## txt化したもの
以下に置いています。
SekkaのRakefileから利用する時に事前にダウンロードする必要があります。
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/2gm.10.txt.gz
   https://s3-ap-northeast-1.amazonaws.com/sekkadict/dictsource/3gm.10.txt.gz

[以上]
