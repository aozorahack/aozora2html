# frozen_string_literal: true

require 'yaml'

class Aozora2Html
  # YAML Loader class
  # Internal processing is done in UTF-8
  class YamlLoader
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def load(path)
      # YAMLファイルはUTF-8として読み込み、そのまま使用
      YAML.load_file(File.join(@base_dir, path))
    end
  end
end
