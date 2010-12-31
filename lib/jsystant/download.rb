require "thor"
require "thor/actions"
require "nokogiri"
require "open-uri"

module Jsystant
  module Download

    RE_TWO_VERSIONS = /^(.*)-([\d.]+)-(.*)-([\d.]+)-min.js$/
    RE_ONE_VERSION = /^(.*)-([\d.]+)-min.js$/

    def download_library(name, version, jquery = nil)
      name, version = name.to_sym, version.to_sym
      jquery = jquery.to_sym unless jquery.nil?

      info = libraries_config[name]
      
      raise "'#{name}': library doesn't exist" unless info
      version = latest_version(info[:latest_version]) if version == :latest

      jquery = nil unless info[:other_download]
      if jquery == :latest
        jquery = latest_version(libraries_config[:lib_jquery][:latest_version])
      end

      if jquery.nil?
        url_template, file_name_template = info[:download], info[:file_name]
      else
        url_template, file_name_template = info[:other_download], info[:other_file_name]
      end
      context = create_context_with(:version => version, :jquery => jquery)
      url = ERB.new(url_template).result(context)
      file_name = ERB.new(file_name_template).result(context)
      download_js(url, file_name, :vendor => info[:vendor])
      # TODO: add download_css
    end

    def latest_library_name(file_name)
      if match = RE_TWO_VERSIONS.match(file_name)
        name = match[1].to_sym
        version = latest_version(libraries_config[name][:latest_version])
        jquery = latest_version(libraries_config[:lib_jquery][:latest_version])
      elsif match = RE_ONE_VERSION.match(file_name)
        name, jquery = match[1].to_sym, nil
        version = latest_version(libraries_config[name][:latest_version])
      else
        return file_name
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
        context.instance_variable_set("@#{name}".to_sym, value)
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
      return nil if config.nil?
      doc = Nokogiri::HTML(open(config[:url]))
      info = doc.css(config[:css]).first.content
      info.sub!(config[:regexp], '\1')
    rescue
      nil
    end
  end
end
