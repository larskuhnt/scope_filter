# encoding: utf-8
ROOT = File.expand_path("../..", __FILE__)
require File.join(ROOT, "lib", "scope_filter")
require 'factory_girl'
require 'logger'
require_relative 'factories'

def setup_database
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "#{ROOT}/db/scope_filter.db")
  FileUtils.mkdir_p(File.join(ROOT, "log"))
  ActiveRecord::Base.logger = Logger.new(File.open(File.join(ROOT, "log", "test.log"), 'w'))
  ActiveRecord::Base.connection.drop_table(:people) if ActiveRecord::Base.connection.table_exists?(:people)
  ActiveRecord::Base.connection.create_table(:people) do |t|
    t.string  :firstname
    t.string  :lastname
    t.integer :age
    t.integer :height
    t.boolean :knight
    t.date    :date_of_death
  end
end