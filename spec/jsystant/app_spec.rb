require File.expand_path("../../spec_helper", __FILE__)
require "pathname"

describe Jsystant::App do
  def runner(options = {})
    Jsystant::App.new([], options, :destination_root => destination_root)
  end
  before(:each) do
    ::FileUtils.rm_rf(destination_root)
  end

  describe "create task" do
    before(:each) do
      @path = Pathname.new(destination_root) + "tomtom"
    end

    it "creates the project directories" do
      silence(:stdout) { runner.create("tomtom") }
      @path.should be_a_directory
      (@path + "public/images").should be_a_directory
      (@path + "public/stylesheets").should be_a_directory
      %w(controllers models vendor views).each do |name|
        (@path + "public/javascripts" + name).should be_a_directory
      end
      (@path + "app.rb").should_not be_a_file
      (@path + "views/stylesheets/screen.sass" ).should_not be_a_file
    end

    it "installs scaffold for Sinatra when --sinatra" do
      silence(:stdout) { runner(:sinatra => true).create("tomtom") }
      (@path + "app.rb").should be_a_file
      (@path + "views").should be_a_directory
      (@path + "views/layout.haml").should be_a_file
      (@path + "views/index.haml").should be_a_file
    end

    it "installs proper scaffold for Compass when --compass" do
      silence(:stdout) { runner(:compass => true).create("tomtom") }
      (@path + "compass.rb").should be_a_file
      spath = (@path + "src")
      spath.should be_a_directory
      (spath + "ie.sass").should be_a_file
      (spath + "print.sass").should be_a_file
      (spath + "screen.sass").should be_a_file
      ppath = (spath + "partials")
      (ppath + "_blueprint.sass").should be_a_file
      (ppath + "_form.sass").should be_a_file
      (ppath + "_layout.sass").should be_a_file
      (ppath + "_page.sass").should be_a_file
    end

    it "installs proper scaffold for Compass when --sinatra and --compass" do
      silence(:stdout) { runner(:sinatra => true, :compass => true).create("tomtom") }
      (@path + "config" + "compass.rb").should be_a_file
      (@path + "views").should be_a_directory
      spath = (@path + "views/stylesheets")
      spath.should be_a_directory
      (spath + "ie.sass").should be_a_file
      (spath + "print.sass").should be_a_file
      (spath + "screen.sass").should be_a_file
      ppath = (spath + "partials")
      (ppath + "_blueprint.sass").should be_a_file
      (ppath + "_form.sass").should be_a_file
      (ppath + "_layout.sass").should be_a_file
      (ppath + "_page.sass").should be_a_file
    end

    it "installs require.js when --require" do
      FakeWeb.register_uri(:get, 'http://requirejs.org/docs/download.html',
        :body => '<html><body><a href="" name="latest">Latest Release: 1.2.3</a></body></html>')
      FakeWeb.register_uri(:get, 'http://requirejs.org/docs/release/1.2.3/minified/require.js',
        :body => 'content for require.js')
      silence(:stdout) { runner(:require => true).create("tomtom") }
      jpath = @path + "public/javascripts"
      (jpath + "require-1.2.3-min.js").should be_a_file
      File.read(jpath + "require-1.2.3-min.js").should == 'content for require.js'
    end

    it "installs jQuery when --jquery" do
      FakeWeb.register_uri(:get, 'http://jquery.com/',
        :body => '<html><body><p class="jq-version">Current Release: v1.4.5</p></body></html>')
      FakeWeb.register_uri(:get, 'http://code.jquery.com/jquery-1.4.5.min.js',
        :body => 'content for jQuery')
      silence(:stdout) { runner(:jquery => true).create("tomtom") }
      vpath = @path + "public/javascripts/vendor"
      (vpath + "jquery-1.4.5-min.js").should be_a_file
      File.read(vpath + "jquery-1.4.5-min.js").should == 'content for jQuery'
    end

    it "installs jQuery with integrated require.js support when --jquery && --require" do
      FakeWeb.register_uri(:get, 'http://jquery.com/',
        :body => '<html><body><p class="jq-version">Current Release: v0.1.2</p></body></html>')
      FakeWeb.register_uri(:get, 'http://requirejs.org/docs/download.html',
        :body => '<html><body><a href="" name="latest">Latest Release: 1.2.3</a></body></html>')
      FakeWeb.register_uri(:get, 'http://requirejs.org/docs/release/1.2.3/minified/require-jquery-0.1.2.js',
        :body => 'content for jQuery and require.js')
      silence(:stdout) { runner(:jquery => true, :require => true).create("tomtom") }
      jpath = @path + "public/javascripts"
      (jpath + "require-1.2.3-jquery-0.1.2-min.js").should be_a_file
      File.read(jpath + "require-1.2.3-jquery-0.1.2-min.js").should == 'content for jQuery and require.js'
    end
  end
end
