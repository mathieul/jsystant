require "thor"
require "thor/actions"
require "pathname"

module Jsystant
  class App < Thor
    include Thor::Actions
    include Download

    source_root File.expand_path("../../../templates", __FILE__)
    add_runtime_options!
    check_unknown_options!

    desc "create PROJECT", "Create a new jsystant project"
    method_option :destroy, :aliases => '-d', :default => false,
      :type => :boolean, :desc => "Destroy files"
    method_option :sinatra, :default => true, :type => :boolean, :desc => "Install scaffold for Sinatra"

    def create(project)
      self.behavior = :revoke if options[:destroy]
      self.destination_root = File.join(self.destination_root, project)

      directory "create", "."
      if options[:sinatra]
        copy_file "sinatra/app.rb", "app.rb"
        template "sinatra/views/layout.haml.tt", "views/layout.haml"
        template "sinatra/views/index.haml.tt", "views/index.haml"
      end
      # download_library(:require, :latest, :latest)
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
  end

end
