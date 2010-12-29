require "thor"
require "thor/actions"

module Jsystant
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
