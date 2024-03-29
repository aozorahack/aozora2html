# frozen_string_literal: true

require 'zip'

class Aozora2Html
  # zipファイルからテキストを抽出する
  class Zip
    def self.unzip(zipfilename, textfilename)
      ::Zip::File.open(zipfilename) do |zip_file|
        entry = zip_file.glob('*.txt').first
        entry.extract(textfilename)
      end
    end
  end
end
