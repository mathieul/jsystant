require "thor"
require "thor/actions"

module Jsystant
  class App < Thor
    include Thor::Actions

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
      invoke("jsystant:download:requirejs", ["0.2.1", "1.4.4"])
    end
  end

  class Download < Thor
    include Thor::Actions

    desc "requirejs REQUIREJS_VERSION [JQUERY_VERSION]", "Download require.js"
    def requirejs(requirejs_version, jquery_version)
      url = "http://requirejs.org/docs/release/#{requirejs_version}/minified/"
      url += jquery_version.nil? ? "require.js" : "require-jquery-#{jquery_version}.js"
      download_js(url, :vendor => false)
    end

    private

    def download_js(url, opts = {:vendor => true})
      destination = File.join("public", "javascripts")
      destination = File.join(destination, "vendor") if opts[:vendor]
      destination = File.join(destination, File.basename(url))
      get(url, destination)
    end
  end
end
