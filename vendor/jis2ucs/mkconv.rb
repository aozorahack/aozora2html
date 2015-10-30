#!/usr/bin/env ruby

print <<EOB
class Aozora2Html
  JIS2UCS = {
EOB

in_header = true

File.open("jisx0213-2004-mono.html") do |f|
  f.each_line do |line|
    rows = line.split()
    if rows[0] =~ /\d-\d\d-\d\d/ && rows[4] =~ /&#x/
      print "    :'",rows[0],"' => '",rows[4],"',\n"
    end
  end
end

print <<EOB
  }
end
EOB

