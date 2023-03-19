require 'mysql2'
require 'yaml'

require_relative './app/main'

dbconfig = YAML::load(File.open('config/database.yml'))

conn = Mysql2::Client.new(dbconfig['production'])

run Main.new conn
