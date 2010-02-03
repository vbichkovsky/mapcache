require 'rubygems'
require 'wx'

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each do |src|
  require src
end

Wx::App.run { MapFrame.new }
