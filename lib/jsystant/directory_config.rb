require "pathname"

module Jsystant
  class DirectoryConfig
    def initialize(opts = {})
      if opts[:sinatra]
        @config_dir = "config"
        @compass_source_dir = "views/stylesheets"
      else
        @config_dir = ""
        @compass_source_dir = "src"
      end
    end

    # xxx_dir returns @xxx_dir as a String if it is set
    # xxx_path returns a Pathname for @xxx_dir if it is set
    def method_missing(meth, *args, &blk)
      case meth
      when /^(.*)_path$/
        value = value_for($1)
        return Pathname.new(value) unless value.nil?
      when /^(.*)_dir$/
        value = value_for($1)
        return value unless value.nil?
      end
      super
    end

    private

    def value_for(name)
      instance_variable_get(:"@#{name}_dir")
    end
  end
end
