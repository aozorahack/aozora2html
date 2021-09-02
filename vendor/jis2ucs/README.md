# JIS2UCS

JIS X 0213の面区点番号からUnicode(UCS)の数値文字参照に変換するためのテーブル（Hash）を作るものです。

元となる対応表は、下記URLのものを使っています。

<http://w3.kcua.ac.jp/~fujiwara/jis2000/jis2004/jisx0213-2004-mono.html>

## 生成方法

テーブルのコードを生成するスクリプトは`mkconv.rb`で、生成結果のファイルは`jis2ucs.rb`になります。

`jis2ucs.rb`を生成するには、コマンドラインで以下のように実行します。

```shell-session
ruby mkconv.rb > ../../lib/aozora2html/jis2ucs.rb
```

## License

`jis2ucs.rb`のLicenseはCC0とします。

Masayoshi Takahashi
