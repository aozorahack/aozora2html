# Aozora2Html

[![Build Status](https://travis-ci.org/aozorahack/aozora2html.svg?branch=master)](https://travis-ci.org/aozorahack/aozora2html) [![Gem Version](https://badge.fury.io/rb/aozora2html.svg)](https://badge.fury.io/rb/aozora2html) [![Code Climate](https://codeclimate.com/github/aozorahack/aozora2html/badges/gpa.svg)](https://codeclimate.com/github/aozorahack/aozora2html)

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

第1引数にURLを指定すると、そのURLのファイルをダウンロードして変換します。

```
$ aozora2html http://example.jp/foo/bar.zip foo.html
```

第2引数を省略すると、ファイルではなく標準出力に変換結果を出力します。

```
$ aozora2html foo.txt
```

コマンドラインオプションとして`--gaiji-dir`と`--use-jisx0213`、`--use-unicode`があります。
`--gaiji-dir`は外字画像のパスを指定します。
`--use-jisx0213`はJIS X 0213の外字画像を使わず、数値実体参照として表示します。
`--use-unicode`はUnicodeのコードポイントが指定されている外字を数値実体参照として表示します。

可能な限り数値実体参照を使って表示するには、以下のようにオプションを指定します。

```
$ aozora2html --use-jisx0213 --use-unicode foo.txt
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
