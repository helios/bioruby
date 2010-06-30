
#Load all the plugins located in defined directories:
#lib/bio/shell/plugin


#load plugin 
Dir.glob('bio/shell/plugin/*') do |plugin|
  if File.directory?(plugin)
    $: << File.join(plugin,'lib')
    puts File.basename(plugin)
    require File.join(plugin,'init.rb')
  #TODO: implement also loading file.rb
  #elsif 
  end
end
