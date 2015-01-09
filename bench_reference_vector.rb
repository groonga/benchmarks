#!/usr/bin/env ruby

def random_tag
  random_tag = (0...8).map{ (65 + rand(26)).chr }.join
  random_tag
end

def known_tags
  ["Groonga", "full text search", "C Lang", "mruby", "Text", "MySQL", "Ruby", "C++",
   "OSS", "Javascript", "Storage Engine", "binding", "nodejs", "Mroonga",
   "Rroonga", "Nroonga", "Droonga", "Distributed"]
end

def get_known_tags
  tags = []
  5.times do
    tags << known_tags.sample
  end
  tags
end

def get_unknown_tags
  unknown_tags = []
  5.times do
    unknown_tags << random_tag
  end
  unknown_tags
end

def get_dir_size(dirname, num_records=0)
  size = `du #{dirname}`
  STDERR.puts("#{num_records} record(s): #{size}")
end

def article_tags
  article_tags = get_known_tags
  article_tags.concat(get_unknown_tags)
  article_tags
end

def create_table
  print(<<-EOH.strip)
table_create Tags TABLE_HASH_KEY ShortText
table_create Articles TABLE_HASH_KEY ShortText
column_create Articles tags COLUMN_VECTOR Tags
load --table Articles
[
EOH
end

def load_data(num_loop, dirname, print_frequency)
  num_loop.times.each do |i|
    print(<<-EOH.strip)
{"_key": "http://groonga.org/#{i}", "tags": "#{article_tags}"},
EOH
    if (i % print_frequency) == 0
      get_dir_size(dirname, i)
    end
  end
end

def eof_data
  print("]")
end

target_records_size = 100000
print_frequency = target_records_size / 10
create_table
load_data(target_records_size, "db", print_frequency)
eof_data
get_dir_size("db", target_records_size)
