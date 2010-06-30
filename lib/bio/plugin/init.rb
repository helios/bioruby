
#Load all the plugins located in defined directories:
#lib/bio/shell/plugin
require 'rubygems'

#load plugin: first into home directory and then into the bioruby distribution.

Dir.glob([File.join(Gem.user_home,".bioruby/shell/plugin/*"), File.join(File.dirname(__FILE__),'../shell/plugin/*')]) do |plugin|
  if File.directory?(plugin)
    $: << File.join(plugin,'lib')
    require File.join(plugin,'init.rb')
  #TODO: implement also loading file.rb
  #elsif 
  end
end
