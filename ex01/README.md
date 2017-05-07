# 課題1 (2017/5/8)
線形補間 (linear interpolation) の関数を返すコードを書いてみる．

目標は

* [Interpolation の節](https://lectures.quantecon.org/jl/julia_libraries.html#interpolation)の図を描くコードの `li = LinInterp(x, y)` の行や
* [Fitted Value Iteration の節](https://lectures.quantecon.org/jl/optgrowth.html#fitted-value-iteration)の図を描く[コード](https://github.com/QuantEcon/QuantEcon.lectures.code/blob/master/optgrowth/linapprox.jl)の[この行](https://github.com/QuantEcon/QuantEcon.lectures.code/blob/master/optgrowth/linapprox.jl#L9)

を置き換えられるようなプログラムを書くこと．

* 提出方法：GitHub のリポジトリにファイルを「プッシュ」して，Jupyter notebook へのリンクを Notebook リストに加える．
* 中間締め切り：5月15日 (月)
* 最終締め切り：5月20日 (土)

与えられた1次元配列 `grid`, `vals` (ともに同じ長さ `n` とする) に対して，
`(grid[1], vals[1])`, ..., `(grid[n], vals[n])` を結ぶ折れ線グラフの関数を得たい．
(`grid` の要素は小さい順にソートされているとする．)

たとえば，以下のように「関数を返す関数」を書いてみる．

```julia
function my_lin_interp(grid, vals)
    function func(x)
        ...
    end

    return func
end
```

(ほんとはこれは筋が悪く，type で書いた方がよい．それはまた後で考える．)

最初は `grid` の要素が2つ (区間が1つ) だけのケースを想定して書いてみる．
たとえば：

```julia
grid = [1, 2]
vals = [2, 0]
f = my_lin_interp(grid, vals)

f(1.25)
# 1.5 が返ってくるはず
```

* [Arrays](https://lectures.quantecon.org/jl/julia_by_example.html#arrays)
* [User-Defined Functions](https://lectures.quantecon.org/jl/julia_by_example.html#user-defined-functions)

一般の n 要素のケースにおいては，`x` がどの区間に入るのかを調べないといけない．
それには
[`searchsortedfirst`](https://docs.julialang.org/en/stable/stdlib/sort/#Base.searchsortedfirst)
あるいは
[`searchsortedlast`](https://docs.julialang.org/en/stable/stdlib/sort/#Base.searchsortedlast)
を使う．

(`grid` の範囲外の値が `x` として入力されたときの動作は自分で適宜決める．)

ここまでは[昨年度版](https://github.com/OyamaZemi/exercises2016/tree/master/ex01)と同じ．
以下は v0.5 に対応した今年度版．


## 拡張・改良

### AbstractVector 入力への対応

v0.4 までは自分で対応コードを書かないといけなかったが，v0.5 では関数の名前とかっこの間にドット `.` を入れるだけで自動でベクトル化してくれるようになった．
したがって，対応コードを書く必要はない．

例

```jl
function f(s::String)
    return s * "s"
end
```

```jl
julia> f("apple")
"apples"

julia> f.(["apple", "orange"])
2-element Array{String,1}:
 "apples" 
 "oranges"
```

* [Dot Syntax for Vectorizing Functions](https://docs.julialang.org/en/stable/manual/functions/#dot-syntax-for-vectorizing-functions)

### Type として実装

[昨年度版](https://github.com/OyamaZemi/exercises2016/tree/master/ex01#type-として実装)で
`call` メソッド云々とあるところは，v0.5 で書き方が変わって

```jl
function (f::MyLinInterp)(x)
    ...
end
```

と書くようになった．

* [Function-like objects](https://docs.julialang.org/en/stable/manual/methods/#function-like-objects)


## ファイル構成

最初は作業は Jupyter notebook で行えばよいですが，まとまってきたら

1. 関数を定義する `.jl` ファイル
2. そのデモの notebook (たとえば `lin_interp_demo.ipynb`)

を作ってください．

最終的には，自前のパッケージとして

```jl
Pkg.clone("https://github.com/USERNAME/PackageName.jl")
```

または

```jl
Pkg.clone("/PATH/TO/PackageName.jl")
```

でインストールできるようにしてください．

### パッケージの作成方法

* [Juliaのパッケージをつくろう!](https://www.slideshare.net/KentaSato/julia-36649709)
* [Creating a new Package](https://docs.julialang.org/en/stable/manual/packages/#creating-a-new-package)

1. パッケージの名前を決める．
   たとえば "MyInterpolations.jl"．

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
     * `MyInterpolations.jl` ファイル  
       このファイルにコードを書く．
   * `test` フォルダ  
     とりあえず空にしておく．

Julia で `PkgDev.generate` というコマンドを使うと一連の操作を自動でやってくれるらしい．

### `MyInterpolations.jl` ファイル

* 冒頭に `module MyInterpolations`，末尾に `end` と書いておく．
  関数の定義はそれらの間に書く．
* 自分で定義した関数 (たとえば `my_lin_interp`) に対して，`export my_lin_interp` のように書いて export する．

### `lin_interp_demo.ipynb` ファイル

* タイトルと名前を書く ([ここ](https://lectures.quantecon.org/jl/getting_started.html#other-content) も参照)
* GitHub レポへのリンクを張る
* (パッケージ化してあれば) 自前パッケージを `using MyInterpolations` で読み込む
* 定義した関数を使ってみる  
  このページにある簡単な例を実行したり，[この節](https://lectures.quantecon.org/jl/julia_libraries.html#interpolation)や[この節](https://lectures.quantecon.org/jl/optgrowth.html#fitted-value-iteration)の図を書いてみたり，いろいろデモを行ってみる
* [昨年度の notebook リスト](https://github.com/OyamaZemi/exercises2016/blob/master/ex01/notebooks.md)


## ゼミ生の成果物

* [Notebook リスト](notebooks.md)
