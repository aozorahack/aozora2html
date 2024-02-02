# HACKING

aozora2htmlの技術的なnoteです。

## `char_type`について

aozora2htmlでは、`String#char_type`というメソッドが追加されています。

`char_type`はルビの範囲を判別するために使われるメソッドです。

* ひらがな: :hiragana
* カタカナ: :katakana
* 全角英数(ギリシア文字含む): :zenkaku
* 半角英数(記号#-&',含む): :hankaku
* 漢字: :kanji
* 半角句読点等(.;"?!)): :hankaku_terminate
* その他: :else

欧文アクセント文字は半角英数、濁点つきカタカナはカタカナ、外字は漢字、訓点はその他、ルビ付き文字はその他になります。

RubyBufferも`RubyBuffer#char_type`を持っています。これはRubyBufferの中身次第で変更されます。複数のchar_typeを内部で持つ場合、char_typeは:elseになります。


## `Aozora2Html::TextBuffer`について

古いRubyでは、`Array#to_s`はArrayの全要素が文字列だった場合、`join`と同じ挙動でした。

現在のRubyでは、同様のことをするには`Array#join`を使わなければならなくなっており、`Array#to_s`をすると`[]`等が出力されます。これは埋め込み文字列に使った場合も同様です。
そのため、aozora2htmlでは`Array`の代わりに`Aozora2Html::TextBuffer`クラスを導入しています。`Aozora2Html::TextBuffer#to_s`は適切な文字列を返します。


## `Jstream`について

`JStream`は`IO`の代わりとなるクラスです。

主に、読み込み行の行数の管理と、任意の文字数の先読みを行うために使われています。

先読みは同一行内のみ有効で、CRLFを超える先読みは動作が保証されません。


## `Aozora2Html::Tag::Multiline`について

`Aozora2Html::Tag::Multiline`は、そのタグが複数行であることを表すマーカー用のモジュールです。

マーカーとして使われるため、メソッド等は特に持っていない、空のモジュールとして実装されています。実行中に追加されたりすることもありません。


## parserと入れ子について

青空文庫の記法は一部入れ子にできます。

Aozora2Htmlのparserは入れ子で実行されることがあります。
実装としては、parserとしてのAozora2HtmlにはサブクラスとしてAozora2Html::TagParserとAozora2Html::AccentParserがあります。Aozora2Htmlは`［...］`をparseする際にはTagParserを、`《...》`をparseする際にはAccentParserを呼び出します。

`［...］`のparseには`read_to_nest`メソッドが、`《...》`のparseには`read_acccent`メソッドが使われます。

`［...］`は入れ子にできますが、`《...》`は入れ子にできません。`《...》`の中に`［...］`を入れたり`《...》`を入れたりすることはできません。
