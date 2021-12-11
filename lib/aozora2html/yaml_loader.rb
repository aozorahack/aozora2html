# frozen_string_literal: true

require 'yaml'

class Aozora2Html
  # YAML Loader class for Shift_JIS
  class YamlLoader
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def load(path)
      tmp_data = YAML.load_file(File.join(@base_dir, path))
      normalize_data(tmp_data)
    end

    def normalize_data(data)
      case data
      when String
        data.encode('shift_jis')
      when Hash
        new_data = {}
        data.each do |k, v|
          new_data[normalize_data(k)] = normalize_data(v)
        end
        new_data
      when Array
        data.map { |item| normalize_data(item) }
      else
        # noop
        data
      end
    end
  end
end
