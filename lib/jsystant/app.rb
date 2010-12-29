require "thor"
require "thor/actions"
require "pathname"

module Jsystant
  class App < Thor
    include Thor::Actions
    include Download

    attr_accessor :project

    source_root File.expand_path("../../../templates", __FILE__)
    add_runtime_options!
    check_unknown_options!

    desc "create PROJECT", "Create a new jsystant project"
    method_option :destroy, :aliases => '-d', :default => false,
      :type => :boolean, :desc => "Destroy files"

    def create(project)
      self.project = project
      self.behavior = :revoke if options[:destroy]
      directory("create", project)
      self.destination_root = project
      copy_file("sinatra/app.rb", "app.rb")
      template("sinatra/views/layout.haml.tt", "views/layout.haml")
      template("sinatra/views/index.haml.tt", "views/index.haml")
      download_library(:require, :latest, :latest)
      download_library(:underscore, :latest)
      download_library(:backbone, :latest)
    end

    desc "outdated [VENDOR_DIR]", "Returns the list of outdated libraries"
    def outdated(vendor_dir = nil)
      puts "Searching for outdated JavaScript libraries..."
      path = Pathname.new(vendor_dir || "public/javascripts/vendor")
      raise "Directory #{vendor_dir} doesn't exist!" unless path.directory?
      files = Dir.glob(File.join(path.parent, "*.js")) + path.children.map(&:to_s)
      files.map { |file| File.basename(file) }.each do |name|
        latest = latest_library_name(name)
        puts "#{name} (latest: #{latest})" if latest != name
      end
    end
  end

end
