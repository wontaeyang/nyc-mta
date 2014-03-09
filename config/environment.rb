require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  # :adapter => "sqlite3",
  :adapter => "jdbcsqlite3",
  :database => "db/mta.sqlite"
)

Dir[File.join(File.dirname(__FILE__), "../app/models", "*.rb")].each {|f| require f}
# Dir[File.join(File.dirname(__FILE__), "../app/controllers", "*.rb")].each {|f| require f}