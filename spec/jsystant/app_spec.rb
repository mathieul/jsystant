require File.expand_path("../../spec_helper", __FILE__)

describe Jsystant::App do
  before(:each) do
    ::FileUtils.rm_rf(destination_root)
  end

  describe "create task" do
    it "creates the project directory" do
      runner = Jsystant::App.new([], {}, :destination_root => destination_root)
      runner.create("tomtom")
      puts "dir: #{File.join(destination_root, "tomtom").inspect}"
      File.directory?(File.join(destination_root, "tomtom")).should be_true
    end
  end
end
