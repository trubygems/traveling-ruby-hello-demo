#!/usr/bin/env ruby
require 'faker'
puts "hello #{Faker::Name.name} from traveling-ruby on #{RUBY_PLATFORM} with ruby #{RUBY_VERSION}"

#!/usr/bin/env ruby
require 'faker'
require 'sqlite3'

name = Faker::Name.name
puts "hello #{name} from traveling-ruby native extensions demo on #{RUBY_PLATFORM} with ruby #{RUBY_VERSION}"
db = SQLite3::Database.new("hello.sqlite3")
db.execute("create table if not exists foo (name varchar(255))")
db.execute("insert into foo values ('#{name}')")
rows = db.execute("select * from foo")
db.close
puts "Hello #{name}, database file modified."
rows.each do |row|
  puts "DB row: #{row.join(", ")}"
end