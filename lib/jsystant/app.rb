require "thor"
require "thor/actions"
require "pathname"

require "jsystant/directory_config"
require "jsystant/download"
require "jsystant/download_config"

module Jsystant
  class App < Thor
    include Thor::Actions
    include Download
    include DownloadConfig

    BUILT_IN_LIBS = [:lib_require, :lib_jquery]

    source_root File.expand_path("../../../templates", __FILE__)
    add_runtime_options!
    check_unknown_options!

    desc "create PROJECT", "Create a new jsystant project"
    method_option :destroy, :aliases => '-d', :default => false,
      :type => :boolean, :desc => "Destroy files"
    method_option :sinatra,     :default => true, :type => :boolean, :desc => "Install scaffold for Sinatra"
    method_option :compass,     :default => true, :type => :boolean, :desc => "Install scaffold for Compass"
    method_option :lib_require, :default => true, :type => :boolean, :desc => "Install RequireJS"
    method_option :lib_jquery,  :default => true, :type => :boolean, :desc => "Install jQuery"

    def create(project)
      self.behavior = :revoke if options[:destroy]
      self.destination_root = File.join(self.destination_root, project)
      config = DirectoryConfig.new(options)

      directory "create", "."
      add_sinatra(config) if options[:sinatra]
      add_compass(config) if options[:compass]
      if options[:lib_jquery]
        if options[:lib_require]
          download_library(:lib_require, :latest, :latest)
        else
          download_library(:lib_jquery, :latest)
        end
      else
        download_library(:lib_require, :latest) if options[:lib_require]
      end
      lib_options = options.reject do |name, value|
        name !~ /^lib_/ || value == false || BUILT_IN_LIBS.include?(name.to_sym)
      end
      lib_options.each do |lib, version|
        download_library(lib, version == true ? :latest : version)
      end
      # download_library(:jqueryui, :latest)
      # download_library(:underscore, :latest)
      # download_library(:backbone, :latest)
      # download_library(:handlebars, :latest)
      # download_library(:json2, :latest)
    end

    desc "outdated [VENDOR_DIR]", "Returns the list of outdated libraries"
    def outdated(vendor_dir = nil)
      puts "Searching for outdated JavaScript libraries..."
      path = Pathname.new(vendor_dir || "public/javascripts/vendor")
      raise "'#{vendor_dir}': directory doesn't exist" unless path.directory?
      files = Dir.glob(File.join(path.parent, "*.js")) + path.children.map(&:to_s)
      files.map { |file| File.basename(file) }.each do |name|
        latest = latest_library_name(name)
        puts "#{name} (latest: #{latest})" if latest != name
      end
    end

    private

    def add_sinatra(config)
      copy_file "sinatra/app.rb", "app.rb"
      template "sinatra/views/layout.haml.tt", "views/layout.haml"
      template "sinatra/views/index.haml.tt", "views/index.haml"
    end

    def add_compass(config)
      copy_file "compass/config/compass.rb", (config.config_path + "compass.rb")
      directory "compass/src", config.compass_source_path
    end
  end
end
