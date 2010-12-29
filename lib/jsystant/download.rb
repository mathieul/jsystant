require "thor"
require "thor/actions"
require "nokogiri"
require "open-uri"

module Jsystant
  module Download

    def download_library(name, version, jquery = nil)
      name, version = name.intern, version.intern
      jquery = jquery.intern unless jquery.nil?

      info = libraries_config[name]
      raise "Unknown library #{name}!" unless info
      version = latest_version(info[:latest_version]) if version == :latest
      raise "Unknown version for library #{name.inspect}" unless version

      jquery = nil unless info[:other_download]
      jquery = latest_version(libraries_config[:jquery][:latest_version]) if jquery == :latest

      url_tpl = jquery.nil? ? info[:download] : info[:other_download]
      context = create_context_with(:version => version, :jquery => jquery)
      url = ERB.new(url_tpl).result(context)
      download_js(url, :vendor => info[:vendor])
    end

    private

    def create_context_with(parameters)
      context = Object.new
      parameters.each do |name, value|
        context.instance_variable_set("@#{name}".intern, value)
      end
      context.instance_eval { binding }
    end

    def download_js(url, opts = {:vendor => true})
      destination = File.join("public", "javascripts")
      destination = File.join(destination, "vendor") if opts[:vendor]
      destination = File.join(destination, File.basename(url))
      get(url, destination)
    end

    def latest_version(config)
      doc = Nokogiri::HTML(open(config[:url]))
      info = doc.css(config[:css]).first.content
      info.sub!(config[:regexp], '\1')
    rescue
      nil
    end

    def libraries_config
      {
        :requirejs => {
          :download => "http://requirejs.org/docs/release/<%= @version %>/minified/require.js",
          :other_download => "http://requirejs.org/docs/release/<%= @version %>/minified/require-jquery-<%= @jquery %>.js",
          :vendor => false,
          :latest_version => {
            :url => "http://requirejs.org/docs/download.html",
            :css => 'a[name="latest"]',
            :regexp => /^Latest Release: ([\d.]+)$/
          }
        },
        :jquery => {
          :download => "http://code.jquery.com/jquery-<%= @version %>.min.js",
          :vendor => true,
          :latest_version => {
            :url => "http://jquery.com/",
            :css => "p.jq-version",
            :regexp => /^Current Release: v([\d.]+)$/
          }
        },
        :underscorejs => {
          :download => "https://github.com/documentcloud/underscore/raw/<%= @version %>/underscore-min.js",
          :vendor => true,
          :latest_version => {
            :url => "http://documentcloud.github.com/underscore/",
            :css => 'a[href="underscore-min.js"]',
            :regexp => /^Production Version \(([\d.]+)\)$/
          }
        },
        :backbone => {
          :download => "https://github.com/documentcloud/backbone/raw/<%= @version %>/backbone-min.js",
          :vendor => true,
          :latest_version => {
            :url => "http://documentcloud.github.com/backbone/",
            :css => 'a[href="backbone-min.js"]',
            :regexp => /^Production Version \(([\d.]+)\)$/
          }
        }
      }
    end
  end
end
