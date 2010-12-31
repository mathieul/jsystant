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
      silence(:stdout) { runner(:require => true).create("tomtom") }
      (@path + "public/javascripts/require-0.2.1-min.js").should be_a_file
    end
  end
end
