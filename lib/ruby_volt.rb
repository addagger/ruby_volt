require 'uri'
require 'digest'
require 'securerandom'
require 'socket'
require 'ipaddr'

module RubyVolt
  # VoltDB Wire Protocol specs at http://downloads.voltdb.com/documentation/wireprotocol.pdf
    
  DEFAULT_HOSTNAME = "localhost"
  DEFAULT_PORT = 21212
  LOGIN_PROTOCOL=1
  PROCEDURE_PROTOCOL=0
  SERVICE_NAME = "database"
  DEFAULT_TIMEOUT = 8
  CONNECT_TIMEOUT = 8
  PROCEDURE_TIMEOUT = 8
    
  def self.config(const, value)
    remove_const(const) if const_defined?(const)
    const_set(const, value)
  end
  
end

require 'ruby_volt/helper'
require 'ruby_volt/exceptions'
require 'ruby_volt/data_type'
require 'ruby_volt/meta'
require 'ruby_volt/read_partial'
require 'ruby_volt/connection'
require 'ruby_volt/base'
require 'ruby_volt/volt_table'