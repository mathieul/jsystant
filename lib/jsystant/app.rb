require "thor"
require "thor/actions"

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
      download_library(:requirejs, :latest, :latest)
      download_library(:jquery, :latest)
      download_library(:underscorejs, :latest)
      download_library(:backbone, :latest)
      # invoke("jsystant:download:library", %w(requirejs latest latest))
      # invoke("jsystant:download:library", %w(jquery latest))
      # invoke("jsystant:download:library", %w(underscorejs latest))
      # invoke("jsystant:download:library", %w(backbone latest))
    end
  end

end
