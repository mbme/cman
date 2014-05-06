require 'spec_helper'

describe Cman::Repository do
  include FakeFS::SpecHelpers

  base_dir = Cman.config['base_dir']
  def new(name)
    Cman::Repository.new name
  end

  before :each do
    FileUtils.mkdir_p base_dir
  end

  it "exists when it's dir exists" do
    name = 'repo1'
    FileUtils.mkdir File.join(base_dir, name)

    repo = new name

    repo.exists?.should be_true
  end

  it "doesn't exists when its dir doesn't exists" do
    repo = new 'repo1'

    repo.exists?.should be_false
  end

  it 'correctly builds full repo path' do
    name = 'i3'
    repo = new name

    repo.path.should eq File.join(base_dir, name)
  end

  it 'correctly builds repo config path' do
    name = 'i3'
    repo = new name

    expected_path = File.join(base_dir, name, Cman::Repository::REPO_CONFIG)
    repo.config_path.should eq expected_path
  end

  it 'can be created' do
    repo = new 'i3'

    repo.exists?.should be_false

    repo.create

    repo.exists?.should be_true

    # check if config file exists
    File.file?(repo.config_path).should be_true
  end

  it 'cannot be created if already exists' do
    name = 'i3'
    FileUtils.mkdir File.join(base_dir, name)
    repo = new name

    expect { repo.create }.to raise_error
  end

  it 'can be removed if exists' do
    name = 'i3'
    repo = new name

    repo.create
    repo.exists?.should be_true

    repo.remove
    repo.exists?.should be_false
  end

  it "cannot be removed if doesn't exists" do
    name = 'i3'
    repo = new name

    repo.exists?.should be_false

    expect { repo.remove }.to raise_error
  end
end
