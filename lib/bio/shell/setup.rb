#
# = bio/shell/setup.rb - setup initial environment for the BioRuby shell
#
# Copyright::   Copyright (C) 2006
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: setup.rb,v 1.8 2007/06/28 11:21:40 k Exp $
#

require 'getoptlong'

class Bio::Shell::Setup

  def initialize
    check_ruby_version
    # command line options
    getoptlong

    #puts "Argomenti dopo getoptlong: #{ARGV.inspect}"
    # setup working directory
    savedir = setup_savedir

    #puts "Argomenti dopo setup_savedir: #{ARGV.inspect}"
    # load configuration and plugins
    Bio::Shell.configure(savedir)

    # set default to irb mode
    Bio::Shell.cache[:mode] = @mode || :irb

    case Bio::Shell.cache[:mode]
    when :web
      # setup rails server
      Bio::Shell::Web.new
    when :irb
      # setup irb server
      Bio::Shell::Irb.new
    when :plugin
      #puts "Evvai Argomenti plugin: #{ARGV.inspect}"
      # setup irb server
      #Commands::Plugin.parse!(ARGV.collect{|arg| arg.sub(/^--/,"")})
      root = "--root=#{savedir}"

      #puts "PlugInRoot: #{root}"

      argv_for_plugin = ARGV

      argv_for_plugin = argv_for_plugin.join(" ").sub(/install/, "install --force").split if @force
      #TODO: if user want to --force reinstall of a plugin there is an error because the parameter need to be --force
      #now --force is purged from --
      #argv = /--plugin (.*)/.match(argv_for_plugin)
      ##@plugin=ARGV.collect{|arg| arg.sub(/^--/,"")}.insert(0,root)
      #Bio::Shell::Script.new(__FILE__.sub(/setup/,"plugin")+" #{cmd}")
      #puts "Pippo: #{argv[1].split.insert(0,root)}"
      #Bio::Shell::Plugin.new(argv[1].split.insert(0,root))
      Bio::Shell::Plugin.new(argv_for_plugin.insert(0,root))
    when :script
      # run bioruby shell script
      Bio::Shell::Script.new(@script)
    end
  end

  def check_ruby_version
    if RUBY_VERSION < "1.8.2"
      raise "BioRuby shell runs on Ruby version >= 1.8.2"
    end
  end

  # command line argument (working directory or bioruby shell script file)
  def getoptlong
    opts = GetoptLong.new
    opts.set_options(
      [ '--rails',   '-r',  GetoptLong::NO_ARGUMENT ],
      [ '--web',     '-w',  GetoptLong::NO_ARGUMENT ],
      [ '--console', '-c',  GetoptLong::NO_ARGUMENT ],
      [ '--irb',     '-i',  GetoptLong::NO_ARGUMENT ],
      [ '--plugin', '-p', GetoptLong::NO_ARGUMENT],
      [ '--force',  '-f',  GetoptLong::NO_ARGUMENT]
    )
    opts.each_option do |opt, arg|
      #puts "getoptlong ARGV: #{ARGV.inspect}"
      #puts "getoptlong opt: #{opt.inspect}"
      #puts "getoptlong arg: #{arg.inspect}"

      case opt
      when /--rails/, /--web/
        @mode = :web
      when /--console/, /--irb/
        @mode = :irb
       when /plugin/
        @mode = :plugin
       when /force/
	@force=true
      end
    end
  end

  def setup_savedir
    arg = ARGV.shift

    #puts "Argomenti setup_savedir: #{ARGV.inspect}"
    # Options after the '--' argument are not parsed by GetoptLong and
    # are passed to irb or rails.  This hack preserve the first option
    # when working directory of the project is not given.
    #
    
    #
    #
    if @mode==:plugin 
      ARGV.unshift arg
      if File.exists?(ARGV.last)
	arg = ARGV.pop
      else
	arg = nil
      end
   elsif arg and arg[/^-/]
      ARGV.unshift arg
      arg = nil
    end



    if arg.nil?
      # run in the current directory
      if File.exist?(Bio::Shell::Core::HISTORY)
        savedir = Dir.pwd
      else
        savedir = File.join(ENV['HOME'].to_s, ".bioruby")
        install_savedir(savedir)
      end
    elsif File.file?(arg)
      # run file as a bioruby shell script
      savedir = File.join(File.dirname(arg), "..")
      @script = arg
      @mode = :script
    else
      # run in new or existing directory
      if arg[/^#{File::SEPARATOR}/]
        savedir = arg
      else
        savedir = File.join(Dir.pwd, arg)
      end
      #puts savedir
      install_savedir(savedir)
    end

    return savedir
  end

  def install_savedir(savedir)
    FileUtils.makedirs(savedir)
  end

end # Setup
