require File.expand_path('../../lib/jsystant', __FILE__)
require 'rubygems'
require 'rspec'
require 'diff/lcs'
require 'stringio'

require 'fakeweb'
FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  def capture(stream)
    begin
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.to_s.upcase}")
    end

    result
  end
  alias :silence :capture

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end
end
