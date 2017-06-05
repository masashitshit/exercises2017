# 課題2 (2017/6/5)
受入保留 (Deferred Acceptance) アルゴリズムを実装してみる．

[Wikipedia の記事](http://ja.wikipedia.org/wiki/安定結婚問題)なり原論文

* D. Gale and L.S. Shapley,
  "[College Admissions and the Stability of Marriage](http://www.jstor.org/stable/2312726),"
  American Mathematical Monthly 69 (1962), 9-15

なりをよく読んでコードを書いてみる．

* 今回は one-to-one (結婚のケース) でよいが，今後 many-to-one (college admission のケース)，many-to-many，student-project allocation に拡張していく．
* 提出方法：GitHub のリポジトリにファイルをプッシュして，Jupyter notebook へのリンクを Notebook リストに加える．
* 中間締め切り：6月12日 (月)
* 最終締め切り：6月17日 (土)


## パッケージ作成

1. パッケージの名前を決める．
   たとえば "MyMatching.jl"．

   * ".jl" をつける
   * CamelCase にする

   この名前で GitHub レポを作る．
   "Initialize this repository with a README" をチェックし，".gitignore", "license" を適切に選ぶ．
   (SourceTree で自分のコンピュータにクローンを作る．)

2. フォルダ構成は以下のようにする．
   (`README`, `.gitignore`, `LICENSE` に加えて)

   * `REQUIRE` ファイル
     とりあえず `julia 0.5` とだけ書いておく．
   * `src` フォルダ
     * `MyMatching.jl` ファイル (パッケージ名と同じ名前にする)
       冒頭に `module MyMatching` (パッケージ名と同じ名前にする)，末尾に `end` と書いておく．
       関数の定義をそれらの間に書いていく．
   * `test` フォルダ  
     下の[テスト](#単体テスト)のセクションから自分に合ったファイルをダウンロードして入れる．

### 上級生向け注

昨年度書いたコードを使うこと (一から書き直したりしない)．

* レポ名が ".jl" で終わってなかったり CamelCase になっていなかったりする場合は名前を変える (`Settings` で変えられる)．
  `-` などモジュール名として使えない記号があることに注意．
  
* 例えば `deffered_acceptance.jl` というファイルにコードを書いた人は，`MyMatching.jl` ファイルで，コードをコピーする代わりに，
  
  ```jl
  module MyMatching
  include("deffered_acceptance.jl")
  end
  ```
  
  とだけ書くのでもよい．


## データ構造

[昨年度](https://github.com/OyamaZemi/exercises2016/tree/master/ex02#データ構造)とは変えて，今年度は次のようなデータ構造を採用することにしましょう．

* 男性陣: `[1, ..., m]`
* 女性陣: `[1, ..., n]`

### 入力データ

* `m_prefs`: 長さ `m` の1次元配列
  第 `i` 要素 `m_prefs[i]` は長さ `n` 以下の1次元配列で，その中には男性 `i` が好きな女性の番号が順番に並べてある．

* `f_prefs`: 長さ `n` の1次元配列
  第 `j` 要素 `f_prefs[j]` は長さ `m` 以下の1次元配列で，その中には女性 `j` が好きな男性の番号が順番に並べてある．

例えば，`m=4`, `n=3` として，

```jl
julia> m_prefs = [[3], [3, 2, 1], [1, 3, 2], [3, 1]]
4-element Array{Array{Int64,1},1}:
 [3]
 [3,2,1]
 [1,3,2]
 [3,1]

julia> f_prefs = [[2, 3], [2, 3, 4, 1], [4, 1, 2]]
3-element Array{Array{Int64,1},1}:
 [2,3]
 [2,3,4,1]
 [4,1,2]
```

上の例で `f_prefs[1]` の `[2, 3]` は，
女性 `1` は「男性 `2` が一番好き，その次は男性 `3` が好き
(男性 `4, 1` とペアになるくらいなら一人でいる方が好き)」であることを意味する．

### 出力データ

* `m_matched`: 長さ `m` の1次元配列
  `m_matched[i]` は男性 `i` が match する女性の番号か `0` ("unmatched") が入る．
* `f_matched`: 長さ `n` の1次元配列
  `f_matched[j]` は女性 `j` が match する男性の番号か `0` ("unmatched") が入る．

### 注

昨年度の2次元配列で関数 (たとえば `deferred_acceptance`) を書いている人は，新たに一から書き直す必要はなく，

```jl
function deferred_acceptance(m_prefs::Vector{Vector{Int}},
                             f_prefs::Vector{Vector{Int}})
    # m_prefs と f_prefs をそれぞれ2次元配列 (たとえば m_prefs_2d と f_prefs_2d) に
    # 変換する
    return deferred_acceptance(m_prefs_2d, f_prefs_2d)
end
```

というメソッドを書き足すだけで事足ります．


## ランダム選好リスト

ランダムに選好リストを生成する関数が必要であれば以下のようにして使ってください．

1. `Pkg.clone("https://github.com/oyamad/Matching.jl")` で `Matching.jl` パッケージをインストールする (一回実行すればよい)．

2. `using Matching` とする．

3. 以下の関数をコピーペーストする (上のパッケージでは昨年度のデータ構造を使っているので，この関数で変換する)：

   ```jl
   function mat2vecs{T<:Integer}(prefs::Matrix{T})
       return [prefs[1:findfirst(prefs[:, j], 0)-1, j] for j in 1:size(prefs, 2)]
   end
   ```

4. `m_prefs, f_prefs = mat2vecs.(random_prefs(4, 3))` や `m_prefs, f_prefs = mat2vecs.(random_prefs(4, 3, allow_unmatched=false))` のように使う．

* [`random_prefs` の使用例](http://nbviewer.jupyter.org/github/oyamad/Matching.jl/blob/2811aed218e1695fffb833554a9d30f449794680/examples/random_prefs.ipynb)


## 単体テスト

1. 今年度のデータ構造対応コードのみを書いた人は
    
    * [runtests.jl (`Vector{Vector}` 版)](https://github.com/OyamaZemi/exercises2017/blob/09b7255a2841ae61a913da1cfeaada4ad29039fa/ex02/test/runtests.jl)
    
    を，昨年度今年度両方対応コードを書いた人は
    
    * [runtests.jl (`Vector{Vector}` + `Matrix` 版)](https://github.com/OyamaZemi/exercises2017/blob/2c33c1117b7ec54540bb3a2b52accee84efe2694/ex02/test/runtests.jl)
    
    をそれぞれダウンロードし (`Raw` ボタンを押す)，`test` フォルダに入れる．

2. パッケージ名は `MyMatching`，関数名は `my_deferred_acceptance` になっているので，これらとは異なる名前をつけている人は，1行目の
    
    ```jl
    using MyMatching
    ```
    
    の `MyMatching` と，4行目の

    ```jl
    const _deferred_acceptance = my_deferred_acceptance
    ```
    
    の `my_deferred_acceptance` を適切なものに変える．

3. 1 (および2) の変更を忘れずにコミットする．

4. インストールされているパッケージを
    
    ```jl
    Pkg.checkout("MyMatching", "branch_name")
    ```
    
    で更新する (Jupyter notebook を restart するのも忘れないように)．

5. Julia か Jupyter notebook で
    
    ```jl
    Pkg.test("MyMatching")
    ```
    
    としてテストを実行してみる．


## ゼミ生の成果物

* [Notebook リスト](notebooks.md)
