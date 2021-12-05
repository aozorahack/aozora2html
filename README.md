# Aozora2Html

[![Build Status](https://github.com/aozorahack/aozora2html/workflows/Test/badge.svg)](https://github.com/aozorahack/aozora2html/actions)
[![Gem Version](https://badge.fury.io/rb/aozora2html.svg)](https://badge.fury.io/rb/aozora2html)
[![Code Climate](https://codeclimate.com/github/aozorahack/aozora2html/badges/gpa.svg)](https://codeclimate.com/github/aozorahack/aozora2html)

青空文庫の[「組版案内」](http://kumihan.aozora.gr.jp/)で配布されている `txt2html`内にある`t2hs.rb`を改造するプロジェクトです。

## 動作環境

Ruby 3.0以上が推奨ですが、2.7.xでも動くはずです。

それ以前のRuby 2.xで利用する場合は、aozora2html-2.0.xをご利用ください。

## インストール

RubyGemsとしてインストール可能になっています。

```shell-session
$ gem install aozora2html
```

ソースからインストールするときは以下のようにします。

```shell-session
$ gem install bundler
$ rake install
```

## 実行

コマンドは`aozora2html`です。以下のように実行します。

```shell-session
$ aozora2html foo.txt foo.html
```

こうすると、青空文庫記法で書かれた`foo.txt`を`foo.html`に変換します。

また、青空文庫サイトで配布している、中にテキストファイルが同梱されているzip形式のファイルも変換できます。

```shell-session
$ aozora2html foo.zip foo.html
```

第1引数にURLを指定すると、そのURLのファイルをダウンロードして変換します。

```shell-session
$ aozora2html http://example.jp/foo/bar.zip foo.html
```

第2引数を省略すると、ファイルではなく標準出力に変換結果を出力します。

```shell-session
$ aozora2html foo.txt
```

コマンドラインオプションとして`--gaiji-dir`と`--use-jisx0213`、`--use-unicode`があります。
`--gaiji-dir`は外字画像のパスを指定します。
`--use-jisx0213`はJIS X 0213の外字画像を使わず、数値実体参照として表示します。
`--use-unicode`はUnicodeのコードポイントが指定されている外字を数値実体参照として表示します。

可能な限り数値実体参照を使って表示するには、以下のようにオプションを指定します。

```shell-session
$ aozora2html --use-jisx0213 --use-unicode foo.txt
```

## テスト

テストも追加しています。テストは以下のように実行します。

```shell-session
$ bundle install
$ rake test
```

## 更新履歴

主な更新履歴は[CHANGELOG.md](CHANGELOG.md)にあります。

## License

CC0

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.ja)

To the extent possible under law, 青空文庫 has waived all copyright and related or neighboring rights to txt2xhtml. This work is published from Japan.
