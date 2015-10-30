# Aozora2Html

[![Build Status](https://travis-ci.org/aozorahack/aozora2html.svg?branch=master)](https://travis-ci.org/aozorahack/aozora2html) [![Gem Version](https://badge.fury.io/rb/aozora2html.svg)](https://badge.fury.io/rb/aozora2html)

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

また、青空文庫サイトで配布している、中にテキストファイルが同梱されているzip形式のファイルも変換できます。

```
$ aozora2html foo.zip foo.html
```


## テスト

テストも追加しています。テストは以下のように実行します。

```
$ bundle install
$ rake test
```

## 更新履歴

主な更新履歴は[CHANGELOG.md](CHANGELOG.md)にあります。

## License

CC0

To the extent possible under law, 青空文庫 has waived all copyright and related or neighboring rights to txt2xhtml. This work is published from Japan.
