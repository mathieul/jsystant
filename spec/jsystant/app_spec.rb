require File.expand_path("../../spec_helper", __FILE__)
require "pathname"

describe Jsystant::App do
  def runner(opts = {})
    @runner ||= Jsystant::App.new([], {}, :destination_root => destination_root)
  end
  before(:each) do
    ::FileUtils.rm_rf(destination_root)
  end

  describe "create task" do
    it "creates the project directories" do
      silence(:stdout) { runner.create("tomtom") }
      project_path = Pathname.new(destination_root) + "tomtom"

      project_path.should be_a_directory
      (project_path + "config").should be_a_directory
      (project_path + "public/images").should be_a_directory
      (project_path + "public/stylesheets").should be_a_directory
      %w(controllers models vendor views).each do |name|
        (project_path + "public/javascripts" + name).should be_a_directory
      end
    end
  end
end
