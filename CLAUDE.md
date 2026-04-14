
# Sekka (石火) プロジェクト概要

SKKライクな日本語入力メソッド。Emacsクライアント + 変換サーバーの構成。

## 基本動作
- ローマ字をCtrl-jで日本語に変換する（SKK風の操作）
- 先頭大文字で漢字変換、小文字でひらがな変換、途中大文字で送り仮名変換

## アーキテクチャ
- **Emacsクライアント**: `emacs/sekka.el` (Emacs Lisp)
- **変換サーバー**: `lib/sekka/` 以下のnendo (.nnd) ファイル群（henkan, jisyo-db, roman-lib等）
- サーバーはJava (JARファイル) で起動し、HTTP (ポート12929) で通信
- Melpaからインストール可能

## ディレクトリ構成
- `emacs/` - Emacsクライアント (.el)
- `lib/sekka/` - サーバー側ロジック (.nnd)
- `data/` - 辞書データ (.nnd)
- `test/` - テスト (.nnd)
- `doc/` - ドキュメント
- `bin/`, `script/`, `tool/` - ユーティリティ


## Pure Elisp化の検討

### 目標
サーバー側ロジック(nendo)をすべてEmacs Lisp側に移植し、サーバー不要のpure elispにする。

### 結論
技術的には可能。ただし曖昧検索の性能が最大の課題。

### サーバー側の主要コンポーネント
| コンポーネント | ファイル | 移植難易度 |
|---|---|---|
| ローマ字→かな変換テーブル | `roman-lib.nnd` | 低(静的alist) |
| 全角/半角変換 | `alphabet-lib.nnd` | 低(Emacs組み込みあり) |
| 漢数字変換 | `sharp-number.nnd` | 低〜中(約100行) |
| 辞書の完全一致検索 | `jisyo-db.nnd` | 中(hash-tableで対応) |
| 学習(確定順序変更) | `henkan.nnd` | 中(ファイルベースで可) |
| Google IME連携 | `google-ime.nnd` | 中(url-retrieveで可) |
| **曖昧検索** | `henkan.nnd` + `approximatesearch.rb` | **高(Jaro-Winkler + 分散Trie)** |
| 辞書DB管理 | `jisyo-db.nnd` | 高(KVS→メモリ化が必要) |

### 主な懸念点
1. **曖昧検索の性能**: Cネイティブgem依存のTrie走査+Jaro-Winkler距離計算をElispで実装した場合、リアルタイムガイド(0.2秒間隔)に耐えられるか
2. **辞書のメモリ消費**: 外部KVS→Emacs内hash-tableへの変更で数十MBのメモリ消費の可能性(ddskkも同様方式なので許容範囲の可能性あり)
3. **学習データの永続化**: 自前でファイル保存の仕組みが必要(ddskk方式で対応可)

### 推奨アプローチ(段階的移植)
- **Phase 1**: ローマ字→かな変換、全角半角変換、漢数字変換をElispに移植
- **Phase 2**: 辞書の完全一致検索をhash-tableベースで実装(ここまでで完全一致のみのSKKライクIMEとして動作可能)
- **Phase 3**: 曖昧検索をElispで実装(性能評価が必要。結果次第で曖昧検索を含めるか判断)
- **Phase 4**: 学習・永続化の実装


### 曖昧検索の代替アルゴリズム

現行方式(Trie走査+Jaro-Winkler)は全ノード走査が重い。以下の軽量な代替がある。

#### SymSpell (推奨)
- 辞書ロード時に各キーの「削除文字列」を事前計算しhash-tableに格納
- 検索時も入力の削除文字列を生成し、hash-table lookupで候補を得る
- 検索はO(L^d)で辞書サイズに依存しない(L=キー長、d=最大編集距離)
- hash-tableのみで実装可能。Elispとの相性が最も良い
- edit distance=1で十分(現行閾値0.94+は1〜2文字の違いに相当)

#### N-gram逆引きインデックス
- 辞書キーをbigram分解し逆引きhash-tableを構築
- 一致bigram数でスコアリング。精度はJaro-Winklerより劣る

#### プレフィックスハッシュ + 打ち切りLevenshtein
- 先頭2〜3文字でグループ化し、該当グループのみLevenshtein距離を計算
- メモリ消費が最小だが、検索速度はSymSpellに劣る

#### 比較
| アルゴリズム | 検索速度 | メモリ | 実装難易度 | 精度 |
|---|---|---|---|---|
| SymSpell | 最速(O(1)相当) | 中〜大 | 低 | 高 |
| N-gram逆引き | 速い | 中 | 低 | 中 |
| プレフィックス+Levenshtein | 中 | 低 | 低 | 高 |
| 現行(Trie+Jaro-Winkler) | 遅い | 大 | 高 | 高 |

#### 結論
Phase 3の曖昧検索にはSymSpellを採用する方針。hash-tableベースでElispに自然に馴染み、リアルタイムガイドに耐える速度が期待できる。

### 計測結果

#### 初期化コスト (emacs --batch, Apple Silicon)

| 辞書 | エントリ数 | 辞書ロード | SymSpellインデックス構築 | 合計 | delete entries |
|---|---|---|---|---|---|
| S辞書 | 3,379 | 0.02s | 0.03s | **0.05s** | 6,198 |
| L辞書 | 175,768 | 0.67s | 4.31s | **4.98s** | 2,378,176 |
| 全辞書(L+補助) | 265,272 | 0.94s | 5.39s | **6.33s** | 2,808,269 |

#### 検索性能 (S辞書, 29,598エントリ)

| 処理 | 速度 |
|---|---|
| SymSpell検索単体 | 0.1ms/query |
| 変換全体(henkan) | 0.4ms/query |

- 辞書ロード自体は1秒以下だが、SymSpellインデックス構築に4-5秒かかる
- 検索性能はリアルタイムガイド(0.2秒間隔)に十分
- hash-tableは揮発性(メモリ上のみ)で、Emacs起動ごとに再構築が必要


### Phase 4 実装結果

#### 実装済み機能

| 機能 | ファイル | 状態 |
|---|---|---|
| 確定(候補並び替え) | `emacs/sekka-jisyo.el` `sekka-jisyo-kakutei` | 実装済み |
| 新規単語登録 | `emacs/sekka-jisyo.el` `sekka-jisyo-register-word` | 実装済み |
| ユーザー辞書ファイル永続化 | `emacs/sekka-jisyo.el` `sekka-jisyo--save-user-entry` | 実装済み |
| ユーザー辞書の優先読み込み | `emacs/sekka-jisyo.el` `sekka-jisyo-get` | 実装済み |
| UI連携(確定時の学習) | `emacs/sekka.el` `sekka-select-kakutei` | 実装済み |
| UI連携(単語登録) | `emacs/sekka.el` `sekka-add-new-word-sub` | 実装済み |
| SymSpellインデックス即時更新 | `emacs/sekka-jisyo.el` `sekka-jisyo-register-word` | 実装済み |
| 変更検知(無駄な書き込み回避) | `emacs/sekka-jisyo.el` `sekka-jisyo-kakutei` | 実装済み |

#### ユーザー辞書の仕組み

- ファイル: `~/.sekka-jisyo` (SKK辞書形式、`sekka-user-jisyo-file` で変更可)
- メモリ: `sekka-user-jisyo-hash` (メイン辞書より優先して参照)
- 起動時: `sekka-jisyo-init` でメイン辞書と共にロード
- 確定時: 候補順序を変更しユーザー辞書に保存 (順序変更がない場合はスキップ)
- 単語登録時: ユーザー辞書に追加し、新規キーならSymSpellインデックスも更新

#### バグ修正(Phase 4実装中に発見)

- `sekka-hiragana-and-okuri-p`: `case-fold-search`が`t`のため大文字もマッチしていた → `let`で`nil`にバインド
- `sekka-henkan--okuri-ari`: 正規表現のstem-bodyが`[a-z^-]+`(1文字以上必須)で"eRu","AU"等がマッチしなかった → `[a-z^-]*`に変更

#### ERTテスト

`emacs/sekka-tests.el` に全248テストを実装:

| カテゴリ | テスト数 | 移植元 |
|---|---|---|
| alphabet-lib | 43 | `test/alphabet-lib.nnd` |
| sharp-number | 36 | `test/sharp-number.nnd` |
| roman-lib | 53 | `test/roman-lib.nnd` |
| util | 6 | `test/util.nnd` |
| henkan | 80 | `test/henkan-main.nnd` |
| symspell | 6 | (新規) |
| jisyo | 4 | (新規) |
| kakutei/学習 | 12 | `test/henkan-main.nnd` |
| register-word | 5 | (新規) |
| helper関数 | 3 | (新規) |

実行方法: `emacs --batch -L emacs/ -l emacs/sekka-tests.el -f ert-run-tests-batch-and-exit`

### オリジナル(nendo) vs 現行(pure Elisp) 曖昧検索の比較

#### アーキテクチャの違い

| | オリジナル (nendo) | 現行 (pure Elisp) |
|---|---|---|
| 検索キー空間 | ローマ字 ("henkan") | ひらがな ("へんかん") |
| アルゴリズム | Jaro-Winkler (閾値0.94) + DistributedTrie | SymSpell (Levenshtein d≤1) + hash-table |
| 検索方式 | 全Trieノード走査 | 削除バリアントのhash-table lookup |

オリジナルは `lib/sekka/approximatesearch.rb` + `distributedtrie` gem (Cネイティブ) で実装。
現行は `emacs/sekka-symspell.el` で純粋なEmacs Lispで実装。

#### 検索速度 (Apple Silicon, 全辞書265,272エントリ)

| 処理 | 速度 |
|---|---|
| SymSpell検索単体 | 1.5〜2.5ms/query |
| approximate-search (辞書値付き) | 2.0〜2.4ms/query |
| henkan全体 | 4〜12ms/query |

リアルタイムガイド(200ms間隔)には十分な速度。

#### 精度の比較

| ケース | オリジナル | 現行 | 備考 |
|---|---|---|---|
| 1文字の打ち間違い (henka→henkan) | ✓ (Jaro 0.97) | ✓ (Levenshtein 1) | 同等 |
| nn/nの揺れ (hennka→henka) | ✓ (曖昧検索) | ✓ (ローマ字変換層で吸収) | 方式は異なるが結果は同等 |
| ローマ字多義性 (kani→かに/かんい) | ✓ (Trie上で完全一致) | ✗ (ひらがな空間でd=2) | **劣化** |
| 長い文字列の許容範囲 (8文字で2文字ミス等) | ✓ (Jaro-Winkler閾値0.94) | ✗ (d≤1固定) | **やや劣化** |
| ひらがなフレーズ検索 (=narimas→=narimasu等) | ✓ (type="h"で検索) | ✗ (未実装) | **未実装** |

#### 劣化の原因と対策

最大の違いは「検索をローマ字空間ではなくひらがな空間で行う」設計変更に起因する。

- **ローマ字多義性**: `sekka-roman->hiragana` が複数候補を返せれば曖昧検索に頼らず解決可能 (現在 "kani" → ("かに") のみ、"かんい" は未対応)
- **長い文字列**: SymSpellのmax edit distanceを2に拡張可能だが、インデックスサイズと検索時間が増大するトレードオフ
- **ひらがなフレーズ**: 辞書データとして未登録のため、辞書追加が必要


### MELPA配布時の辞書配置

GitHub raw URLから辞書を自動ダウンロードする方式を採用。

#### 仕組み

- 初回起動時、ローカル `data/` に辞書がなければ `~/.emacs.d/sekka/` にGitHubからダウンロード
- 2回目以降はキャッシュ済みファイルをそのまま使用(オフライン動作可)
- `sekka-dictionary-base-url` でダウンロード元URLをカスタマイズ可能
- `sekka-dictionary-cache-dir` でキャッシュディレクトリをカスタマイズ可能

#### 関連変数・関数

| 変数/関数 | 役割 |
|---|---|
| `sekka-dictionary-base-url` | ダウンロード元URL (デフォルト: GitHub raw) |
| `sekka-dictionary-cache-dir` | キャッシュ先ディレクトリ (デフォルト: `~/.emacs.d/sekka/`) |
| `sekka-jisyo-dictionary-names` | ダウンロード対象の辞書ファイル名リスト |
| `sekka-jisyo--download-file` | URL→ローカルファイルのダウンロード |
| `sekka-jisyo--ensure-dictionaries` | キャッシュ確認＋必要ならダウンロード |
| `sekka-jisyo-default-file-list` | ローカルdata/優先、なければキャッシュ/DL |
| `sekka-jisyo-download-dictionaries` | 手動ダウンロード用インタラクティブコマンド |

#### 動作確認

開発環境ではローカル `data/` が存在するため自動ダウンロードは発動しない。
手動テストは `M-x sekka-jisyo-download-dictionaries` で実行可能。


### Phase 5: タイプミス修正の高度化 (Jaro-Winkler 併用)

#### 目的

SymSpell (ひらがな空間, d≤1) では救えない以下のケースをオリジナル (nendo)
相当まで回復する。

- 長い単語の後方欠落 (例: `shizengengos` → `自然言語処理`)
- ローマ字多義性の一部 (例: `kani` → `かに`/`かんい`)

#### アプローチ

SymSpell はそのまま残し、**生ローマ字クエリに対する Jaro-Winkler 検索** を
並走させる。オリジナルと同じく Jaro-Winkler の長さ正規化とプレフィックス
ボーナスにより、長い単語の後方欠落を閾値 0.94 で拾える。

| 項目 | 実装 |
|---|---|
| 距離尺度 | Jaro-Winkler (prefix 最大 4、scaling 0.1) |
| 検索キー空間 | 生ローマ字 (ひらがな辞書キーを正準 Hepburn に変換) |
| 候補生成 | 適応型プレフィックスブロッキング (qlen に応じて 2/3/4 文字) |
| 足切り | 長さ差 `min/max < 0.7` の組合せはスキップ |
| SymSpell との関係 | 併用 (SymSpell は先頭タイプミス保険、JW は長い単語担当) |

正準ローマ字は `sekka-jarowinkler-hiragana->roman` で 1:1 変換 (`ん` は
単独 `n`、Hepburn sokuon+ch → `t` 等)。SKK 辞書が保持する全ひらがなキー
それぞれについて 1 つのローマ字形を生成する。

#### 実装ファイル

| 機能 | ファイル | 備考 |
|---|---|---|
| Jaro-Winkler + ひらがな→Hepburn + プレフィックスインデックス | `emacs/sekka-jarowinkler.el` | 新規 |
| 辞書ロード時の JW インデックス構築 | `emacs/sekka-jisyo.el` `sekka-jisyo--build-jarowinkler-index` | SymSpell 構築完了後に同期実行 |
| JW 曖昧検索 API | `emacs/sekka-jisyo.el` `sekka-jisyo-jarowinkler-search` | `((score key value) ...)` |
| 変換フローへの統合 | `emacs/sekka-henkan.el` `sekka-henkan--okuri-nashi` | 生ローマ字 keyword を JW に渡す |
| ユーザー辞書登録時の JW 更新 | `emacs/sekka-jisyo.el` `sekka-jisyo-register-word` | SymSpell と同様 |

#### 計測結果 (L 辞書 175,768 エントリ, Apple Silicon)

初期化コスト (SymSpell + JW 合計):

| 項目 | 時間 |
|---|---|
| 辞書ロード + SymSpell + JW 構築 | 約 4.9 秒 |

JW 単独の構築時間は 1 秒未満 (prefix=2,3,4 の 3 レベル同時構築で約 0.5 秒)。

検索性能 (適応型プレフィックスブロッキング + 長さ足切り):

| クエリ | 長さ | プレフィックス長 | ヒット | 速度 |
|---|---|---|---|---|
| `shizengengos` | 12 | 4 | 2 | 6.5 ms |
| `shizengengoshori` | 16 | 4 | 1 | 6.0 ms |
| `henka` | 5 | 2 | 8 | 12.9 ms |
| `kanj` | 4 | 2 | 6 | 13.9 ms |
| `kokoro` | 6 | 2 | 10 | 52.9 ms |
| `ringo` | 5 | 2 | 9 | 8.1 ms |
| `tabe` | 4 | 2 | 6 | 8.6 ms |

リアルタイムガイド (200ms 間隔) に十分収まる。長いクエリほどプレフィックス
4 文字で候補が激減するため高速。逆に短いクエリは prefix=2 バケットが大きく
なるため比較的遅いが、最悪でも ~55ms。

長さ適応型プレフィックスを入れる前は `shizengengos` が 414 ms/query と
リアルタイムガイドに耐えない速度だった。長さ足切り + 適応型プレフィックス
で約 64 倍の高速化。

#### 残課題

| 項目 | 状態 |
|---|---|
| ローマ字多義性 (kani → かに/かんい) | 未着手 (`sekka-roman->hiragana` の複数解釈対応が必要) |
| ひらがなフレーズ検索 (type "h") | 別 issue 化 (#13) |
| 閾値 0.94 のチューニング | 初期値のまま (利用後に再検討) |

#### ERT テスト

`emacs/sekka-tests.el` に Jaro-Winkler 関連 15 件を追加:

| カテゴリ | テスト数 | 内容 |
|---|---|---|
| 類似度 | 6 | 完全一致/空文字/1文字欠落/長い単語後方欠落/無関係/プレフィックス加点 |
| ひらがな→ローマ字 | 4 | 基本/拗音/促音/ん の正準化 |
| インデックス + 検索 | 2 | ビルド+検索、短クエリ拒否 |
| 辞書連携 | 2 | `shizengengos` → `自然言語処理` 検索と henkan 統合 |
| 動的更新 | 1 | register-word 時の JW 更新 |

合計 282 テスト (既存 267 + JW 15) が全てパスする。
