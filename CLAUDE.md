
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
