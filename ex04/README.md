# 課題4 (2017/6/19)
次は，(新たな関数を書くのではなく) [課題2](../ex02)で作った関数に many-to-one マッチング
(college admission のケース) を扱う機能を加えましょう．

とりあえず

* [医師臨床研修マッチング協議会](https://www.jrmp.jp)の[マッチングアルゴリズム図解](https://www.jrmp.jp/distribution/matching.html)
* [昨年のページ](https://github.com/OyamaZemi/exercises2016/tree/master/ex03)

を参照してください．

* 中間締め切り：6月26日 (月)
* 最終締め切り：7月1日 (土)


## データ構造

* 学生たち: `[1, ..., m]` (とりあえず提案側とする)
* 大学たち: `[1, ..., n]` (とりあえず応答側とする)

### 入力データ

* `prop_prefs`: 長さ `m` の1次元配列  
  第 `i` 要素 `prop_prefs[i]` は長さ `n` 以下の1次元配列で，その中には学生 `i` が入りたい大学の番号が順番に並べてある．

* `resp_prefs`: 長さ `n` の1次元配列  
  第 `j` 要素 `resp_prefs[j]` は長さ `m` 以下の1次元配列で，その中には大学 `j` が受け入れたい学生の番号が順番に並べてある．

* `caps`: 長さ `n` の1次元配列  
  `caps[j]` は大学 `j` の受入上限

(`prop_prefs`, `resp_prefs` はいままでの `m_prefs`, `f_prefs` と同じ．)

### 出力データ

以下のようなデータ構造を採用することにしましょう．

`caps` が指定されなければいままで通り

* `prop_matched`: 長さ `m` の1次元配列

* `resp_matched`: 長さ `n` の1次元配列

`caps` が指定されたら次の3つを返す：

* `prop_matched`: 長さ `m` の1次元配列

* `resp_matched`: 長さ `L` の1次元配列  
  大学側が受け入れる学生をすべて列挙する．
  ただし `L` = `sum(caps)`．

* `indptr`: 長さ `n+1` の1次元配列  
  `resp_matched[indptr[j]:indptr[j+1]-1]` が大学 `j` が受け入れる学生のリスト．

入る大学のない学生や大学の空きスロットには `0` を入れておく．

`indptr` は次のようにして作ることができます：

```jl
indptr = Array{Int}(n+1)
indptr[1] = 1
for i in 1:n
    indptr[i+1] = indptr[i] + caps[i]
end
```


## 一対一 vs. 多対一

たとえば，次のように書くようにしてみましょう．

```jl
# 多対一のケース
function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}},
                                caps::Vector{Int})

    # 多対一のコードを書く

    return prop_matches, resp_matches, indptr
end

# 一対一のケース
function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}})
    caps = ones(Int, length(resp_prefs))
    prop_matches, resp_matches, indptr =
        my_deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end
```

* 複数スロットを持つ方 (つまり大学) が responders であることを想定している．
* このケースで書けたら，逆のケースも書いてみる．
* 最初から多対多で書いておいてもよい．


## 単体テスト

1. [runtests.jl](https://github.com/OyamaZemi/exercises2017/blob/80847d0169ad1c0ce445797d4243f5d04a7d0c01/ex02/test/runtests.jl)
   をダウンロードし (`Raw` ボタンを押す)，`test` フォルダに入れる．

2. パッケージ名は `MyMatching`，関数名は `my_deferred_acceptance` になっているので，これらとは異なる名前をつけている人は，1行目の
    
    ```jl
    using MyMatching
    ```
    
    の `MyMatching` と，4行目の

    ```jl
    const _deferred_acceptance = my_deferred_acceptance
    ```
    
    の `my_deferred_acceptance` を適切なものに変える．

3. 昨年度今年度両方対応コードを書いた人は，5行目の
    
    ```jl
    const test_matrix = false
    ```
    
    の `false` を `true` に変える．

4. 1 (および2, 3) の変更を忘れずにコミットする．

5. インストールされているパッケージを
    
    ```jl
    Pkg.checkout("MyMatching", "branch_name")
    ```
    
    で更新する (Jupyter notebook を restart するのも忘れないように)．

6. Julia か Jupyter notebook で
    
    ```jl
    Pkg.test("MyMatching")
    ```
    
    としてテストを実行してみる．


## ゼミ生の成果物

* [Notebook リスト](notebooks.md)
