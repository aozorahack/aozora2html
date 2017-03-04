require "aozora2html/yaml_loader"
class Aozora2Html
  loader = Aozora2Html::YamlLoader.new(File.dirname(__FILE__))
  JIS2UCS = loader.load("../../yml/jis2ucs.yml")
end
