# [Sekka](https://github.com/kiyoka/sekka)(石火)の辞書について
Sekkaの辞書はSKKの辞書をベースにしています。
sekka-serverを初めて起動した時に自動的に辞書データをサイトから取得・変換します。

# sekka-serverの辞書選択ルール
sekka-serverは起動時に ~/.sekka-server ディレクトリに構築される辞書(.tch)を使います。

# 変換済み辞書の内容
変換元のSKK辞書ファイルは、2015年1月頃のものをダウンロードしたものです。

## SEKKA-JISYO.N

[SKK辞書Wiki](http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK辞書)のSKK辞書とその他コーパスから変換したものです。
- SKK-JISYO.L                (SKKのLARGE辞書)
- SKK-JISYO.L.hira-kata      (カタカナ語を生成したもの)
- SKK-JISYO.fullname         (著名人のフルネーム辞書)
- SKK-JISYO.jinmei           (日本人の姓名辞書)
- SKK-JISYO.station          (駅名・路線名・鉄道会社名の辞書)
- SKK-JISYO.hiragana-phrase  (webCorpusの6-gramから文末の平仮名フレーズを抜きだした辞書。「しています」等)
- SKK-JISYO.hiragana-phrase2 (ipadocから平仮名フレーズを抜きだした辞書。「つまり」「とりあえず」等)

## 補足
中間フォーマットを介している理由は、辞書DBとしてTokyo Cabinet以外も利用できるようにするためです。
0.9.2からTokyo Cabinetの他にRedisもサポートしました。

[以上]
