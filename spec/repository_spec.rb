require 'spec_helper'

describe Cman::Repository do
  include FakeFS::SpecHelpers

  it "exists when it's dir exists" do
    name = 'repo1'
    FileUtils.mkdir_p File.join(Cman.config['base_dir'], name)

    repo = Cman::Repository.new name

    repo.exists?.should be_true
  end

  it "doesn't exists when its dir doesn't exists" do
    repo = Cman::Repository.new 'repo1'

    repo.exists?.should be_false
  end
end
