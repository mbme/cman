require 'spec_helper'

describe Cman::Repository do
  include FakeFS::SpecHelpers

  BASE_DIR = Cman.config['base_dir']
  def new(name)
    Cman::Repository.new name
  end

  def touch(file)
    FileUtils.mkdir_p File.dirname file
    File.open(file, 'w') { |f| f.write 'TEST' }
  end

  def cat(file)
    puts "\n\n--- File #{file}:"
    File.readlines(file).each do |line|
      puts line
    end
    puts "\n\n--- #{file} ends here\n\n"
  end

  before :each do
    FileUtils.mkdir_p BASE_DIR
  end

  it "exists when it's dir exists" do
    name = 'repo1'
    FileUtils.mkdir File.join(BASE_DIR, name)

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

    repo.path.should eq File.join(BASE_DIR, name)
  end

  it 'correctly builds repo config path' do
    name = 'i3'
    repo = new name

    expected_path = File.join(BASE_DIR, name, Cman::Repository::REPO_CONFIG)
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
    repo = new name
    repo.create

    repo = new name
    expect { repo.create }.to raise_error
  end

  it 'can be removed if exists' do
    name = 'i3'
    repo = new name

    repo.create
    repo.exists?.should be_true

    repo.delete
    repo.exists?.should be_false
  end

  it "cannot be removed if doesn't exists" do
    repo = new 'i3'

    repo.exists?.should be_false

    expect { repo.delete }.to raise_error
  end

  it 'can add new file' do
    repo = new 'i3'
    repo.create

    file_path = '/test/file'
    touch file_path

    rec = repo.add_record file_path

    rec.repository.should eq repo
    rec.id.should eq 0
    rec.name.should eq File.basename file_path

    File.file?(rec.repo_path).should be_true
    File.file?(repo.config_path).should be_true
  end

  it 'cannot add same file twice' do
    repo = new 'i3'
    repo.create

    file_path = '/test/file'
    touch file_path

    # we can add file first time
    repo.add_record(file_path).should_not be_nil

    # but cannot add it second time
    expect { repo.add_record file_path }.to raise_error
  end

  it 'can add dir with multiple files and dirs' do
    repo = new 'i3'
    repo.create

    base_dir = '/test/test-dir'

    f1 = 'dir/other'
    f1_path = "#{base_dir}/#{f1}"
    touch f1_path

    l1 = 'dir/symlink'
    File.symlink f1_path, "#{base_dir}/#{l1}"

    f2 = 'file'
    touch "#{base_dir}/#{f2}"

    d1 = 'empty-dir'
    FileUtils.mkdir "#{base_dir}/#{d1}"

    rec = repo.add_record base_dir

    rec.repository.should eq repo
    rec.id.should eq 0
    rec.name.should eq File.basename base_dir

    Dir.exist?(rec.repo_path).should be_true
    File.exist?(File.join(repo.path, rec.name, f1)).should be_true
    File.exist?(File.join(repo.path, rec.name, f2)).should be_true

    # we should skip empty dirs
    Dir.exist?(File.join(repo.path, rec.name, d1)).should be_false

    # we should skip symlinks
    File.symlink?(File.join(repo.path, rec.name, l1)).should be_false
  end

  it 'can be deserialized from config file' do
    file_path = '/test/file'
    touch file_path

    repo_name = 'i3'
    repo = new repo_name
    repo.create
    repo.add_record file_path

    repo = Cman::Repository.read repo_name
    repo.size.should eq 1
  end

  it 'can add files with the same name' do
    pending
  end
end
