require "rubygems"
require "sinatra"
require "active_record"
require File.expand_path('../db.rb', __FILE__)



#@configpathlog = File.expand_path('../config/logs.txt', __FILE__)
#@configpathdb = File.expand_path('../config/database.yml', __FILE__)
#dbconfig = YAML::load(File.open(@configpathdb))
#ActiveRecord::Base.pluralize_table_names = false
#ActiveRecord::Base.establish_connection(dbconfig)

#gem install activerecord-mysql-adapter with the below connect code
#If quates are set on the port a convertion error happens
ActiveRecord::Base.establish_connection(
    :adapter     => "mysql2",
#    :host        => "10.5.5.10",
    :host        => "10.211.55.2",
    :port        => 3306,
#    :database    => "asterisk",
    :database    => "asteriskdominos",
    :username    => "root",
#    :password    => "sefv3nc"
    :password    => "root"
)

class WsUsers < ActiveRecord::Base
  self.table_name = "ws_users"
  self.primary_key = "id"
end

class WsModulos < ActiveRecord::Base
  self.table_name = "ws_modulos"
  self.primary_key = "id"
end

class WsLogs < ActiveRecord::Base
  self.table_name = "ws_logs"
  self.primary_key = "id"
end

class Cdr < ActiveRecord::Base
  self.table_name = "cdr"
  self.primary_key = "id"
end