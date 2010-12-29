require "thor"
require "thor/actions"
require "nokogiri"
require "open-uri"

module Jsystant
  class Download < Thor
    include Thor::Actions

    UNKNOWN_VERSION = "unknown"
    LATEST_VERSION = "latest"

    desc "requirejs REQUIREJS_VERSION [JQUERY_VERSION]", "Download require.js"
    def requirejs(requirejs_version, jquery_version)
      requirejs_version = latest_version_for(:requirejs) if requirejs_version == LATEST_VERSION
      jquery_version = latest_version_for(:jquery) if jquery_version == LATEST_VERSION
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

    def latest_version_for(library)
      config = libraries_config[library][:latest_version] rescue nil
      return UNKNOWN_VERSION unless config
      doc = Nokogiri::HTML(open(config[:url]))
      info = doc.css(config[:css]).first.content rescue UNKNOWN_VERSION
      info.sub!(config[:regexp], '\1')
    end

    def libraries_config
      {
        :requirejs => {
          :latest_version => {
            :url => "http://requirejs.org/docs/download.html",
            :css => 'a[name="latest"]',
            :regexp => /^Latest Release: ([\d.]+)$/
          }
        },
        :jquery => {
          :latest_version => {
            :url => "http://jquery.com/",
            :css => "p.jq-version",
            :regexp => /^Current Release: v([\d.]+)$/
          }
        }
      }
    end

  end
end
