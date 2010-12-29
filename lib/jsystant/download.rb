require "thor"
require "thor/actions"
require "nokogiri"
require "open-uri"

module Jsystant
  module Download
    RE_TWO_VERSIONS = /^(.*)-([\d.]+)-(.*)-([\d.]+)-min.js$/
    RE_ONE_VERSION = /^(.*)-([\d.]+)-min.js$/

    def download_library(name, version, jquery = nil)
      name, version = name.intern, version.intern
      jquery = jquery.intern unless jquery.nil?

      info = libraries_config[name]
      raise "Unknown library #{name}!" unless info
      version = latest_version(info[:latest_version]) if version == :latest
      raise "Unknown version for library #{name.inspect}" unless version

      jquery = nil unless info[:other_download]
      jquery = latest_version(libraries_config[:jquery][:latest_version]) if jquery == :latest

      if jquery.nil?
        url_template, file_name_template = info[:download], info[:file_name]
      else
        url_template, file_name_template = info[:other_download], info[:other_file_name]
      end
      context = create_context_with(:version => version, :jquery => jquery)
      url = ERB.new(url_template).result(context)
      file_name = ERB.new(file_name_template).result(context)
      download_js(url, file_name, :vendor => info[:vendor])
    end

    def latest_library_name(file_name)
      if match = RE_TWO_VERSIONS.match(file_name)
        name = match[1].intern
        version = latest_version(libraries_config[name][:latest_version])
        jquery = latest_version(libraries_config[:jquery][:latest_version])
      elsif match = RE_ONE_VERSION.match(file_name)
        name, jquery = match[1].intern, nil
        version = latest_version(libraries_config[name][:latest_version])
      else
        raise "Unknown library #{file_name}"
      end

      info = libraries_config[name]
      file_name_template = if jquery.nil?
        info[:file_name]
      else
        info[:other_file_name]
      end
      context = create_context_with(:version => version, :jquery => jquery)
      ERB.new(file_name_template).result(context)
    end

    private

    def create_context_with(parameters)
      context = Object.new
      parameters.each do |name, value|
        context.instance_variable_set("@#{name}".intern, value)
      end
      context.instance_eval { binding }
    end

    def download_js(url, file_name, opts = {:vendor => true})
      destination = File.join("public", "javascripts")
      destination = File.join(destination, "vendor") if opts[:vendor]
      destination = File.join(destination, file_name)
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
        :require => {
          :download => "http://requirejs.org/docs/release/<%= @version %>/minified/require.js",
          :file_name => "require-<%= @version %>-min.js",
          :other_download => "http://requirejs.org/docs/release/<%= @version %>/minified/require-jquery-<%= @jquery %>.js",
          :other_file_name => "require-<%= @version %>-jquery-<%= @jquery %>-min.js",
          :vendor => false,
          :latest_version => {
            :url => "http://requirejs.org/docs/download.html",
            :css => 'a[name="latest"]',
            :regexp => /^Latest Release: ([\d.]+)$/
          }
        },
        :jquery => {
          :download => "http://code.jquery.com/jquery-<%= @version %>.min.js",
          :file_name => "jquery-<%= @version %>-min.js",
          :vendor => true,
          :latest_version => {
            :url => "http://jquery.com/",
            :css => "p.jq-version",
            :regexp => /^Current Release: v([\d.]+)$/
          }
        },
        :underscore => {
          :download => "https://github.com/documentcloud/underscore/raw/<%= @version %>/underscore-min.js",
          :file_name => "underscore-<%= @version %>-min.js",
          :vendor => true,
          :latest_version => {
            :url => "http://documentcloud.github.com/underscore/",
            :css => 'a[href="underscore-min.js"]',
            :regexp => /^Production Version \(([\d.]+)\)$/
          }
        },
        :backbone => {
          :download => "https://github.com/documentcloud/backbone/raw/<%= @version %>/backbone-min.js",
          :file_name => "backbone-<%= @version %>-min.js",
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
