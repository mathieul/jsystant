module Jsystant
  module DownloadConfig

    def self.included(base)
      base.extend(ClassMethods)
    end

    def libraries_config
      klass = self.class
      klass.load_download_config!
      klass.libraries_config
    end

    module ClassMethods
      attr_accessor :libraries_config

      def load_download_config!
        @libraries_config ||= {
          :lib_require => {
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
          :lib_jquery => {
            :download => "http://code.jquery.com/jquery-<%= @version %>.min.js",
            :file_name => "jquery-<%= @version %>-min.js",
            :vendor => true,
            :latest_version => {
              :url => "http://jquery.com/",
              :css => "p.jq-version",
              :regexp => /^Current Release: v([\d.]+)$/
            }
          },
          :jqueryui => {
            :download => "http://ajax.googleapis.com/ajax/libs/jqueryui/<%= @version %>/jquery-ui.min.js",
            :file_name => "jqueryui-<%= @version %>-min.js",
            :css => "http://ajax.googleapis.com/ajax/libs/jqueryui/<%= @version %>/themes/base/jquery-ui.css",
            :css_name => "jqueryui-<%= @version %>.css",
            :vendor => true,
            :latest_version => {
              :url => "http://jqueryui.com/",
              :css => "#home-download ul:first li:first",
              :regexp => /^Stable\s+\(([\d.]+): jQuery .*\)$/
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
          },
          :handlebars => {
            :download => "http://cloud.github.com/downloads/wycats/handlebars.js/handlebars.js",
            :file_name => "handlebars.js",
            :vendor => true
          },
          :json2 => {
            :download => "https://github.com/douglascrockford/JSON-js/raw/master/json2.js",
            :file_name => "json2.js",
            :vendor => "true"
          }
        }
      end

      def add_library(name, config)
        keys_missing = [:download, :file_name, :vendor] - config.keys
        raise "adding library: invalid config" unless keys_missing.empty?
        load_download_config!
        libraries_config[name.to_sym] = config
      end
    end
  end
end
