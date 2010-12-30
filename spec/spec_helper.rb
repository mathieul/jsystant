require File.expand_path('../../lib/jsystant', __FILE__)
require 'rubygems'
require 'rspec'
require 'diff/lcs'
require 'fakeweb'
require 'stringio'

RSpec.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  alias :silence :capture

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end
end
