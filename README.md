# Aozora2Html

青空文庫の「組版案内」( http://kumihan.aozora.gr.jp/ )で配布されているtxt2html内にあるt2hs.rbを改造するプロジェクトです。

## 動作環境

Ruby 2.0以上が推奨ですが、1.9でも動くはずです。

## インストール

RubyGemsとしてインストール可能になっています。

```
$ gem install aozora2html
```

ソースからインストールするときは以下のようにします。

```
$ gem install bundler
$ rake install
```

## 実行

コマンドは`aozora2html`です。以下のように実行します。

```
$ aozora2html foo.txt foo.html
```

こうすると、青空文庫記法で書かれたfoo.txtをfoo.htmlに変換します。

## テスト

テストも追加しています。テストは以下のように実行します。

```
$ bundle install
$ rake test
```

## License

CC0

To the extent possible under law, 青空文庫 has waived all copyright and related or neighboring rights to txt2xhtml. This work is published from Japan.
