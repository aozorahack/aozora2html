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


## `Array#to_s`について

古いRubyでは、`Array#to_s`はArrayの全要素が文字列だった場合、`join`と同じ挙動でした。

aozora2htmlの前身のt2hs.rbでもこれを利用して文字列化していたため、aozora2htmlでも`Array#to_s`を`join`に変更しています。

将来的にはArrayの代わりにTextBuffer等のクラスを導入する可能性があります。


## `Jstream`について

`JStream`は`IO`の代わりとなるクラスです。

主に、読み込み行の行数の管理と、任意の文字数の先読みを行うために使われています。

先読みは同一行内のみ有効で、CRLFを超える先読みは動作が保証されません。


## `Aozora2Html::Tag::Multiline`について

`Aozora2Html::Tag::Multiline`は、そのタグが複数行であることを表すマーカー用のモジュールです。

マーカーとして使われるため、メソッド等は特に持っていない、空のモジュールとして実装されています。実行中に追加されたりすることもありません。
