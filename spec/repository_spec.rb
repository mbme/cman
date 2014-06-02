require 'spec_helper'

describe Cman::Repository do
  include FakeFS::SpecHelpers
  before :each do
    FileUtils.mkdir_p BASE_DIR
    @repo_name = 'i3'
    @repo = new @repo_name
  end

  def new(name)
    Cman::Repository.new name
  end

  it "exist when it's dir exist and config exists" do
    FileUtils.mkdir File.join(BASE_DIR, @repo_name)
    touch @repo.config_path

    @repo.exist?.should be_true
  end

  it "doesn't exist when its dir or config doesn't exist" do
    @repo.exist?.should be_false

    FileUtils.mkdir File.join(BASE_DIR, @repo_name)
    @repo.exist?.should be_false
  end

  it 'correctly builds full repo path' do
    @repo.path.should eq File.join(BASE_DIR, @repo_name)
  end

  it 'correctly builds repo config path' do
    expected_path = File.join(
      BASE_DIR, @repo_name, Cman::Repository::REPO_CONFIG
    )
    @repo.config_path.should eq expected_path
  end

  it 'can be created' do
    @repo.exist?.should be_false

    @repo.create

    @repo.exist?.should be_true

    # check if config file exist
    File.file?(@repo.config_path).should be_true
  end

  it 'cannot be created if already exist' do
    @repo.create

    repo = new @repo_name
    expect { repo.create }.to raise_error
  end

  it 'cannot be created with wrong name' do
    expect { new '.test' }.to raise_error
  end

  it 'cannot be created if dir already exists' do
    FileUtils.mkdir File.join(BASE_DIR, @repo_name)

    repo = new @repo_name
    expect { repo.create }.to raise_error
  end

  it 'can be removed if exist' do
    @repo.create
    @repo.exist?.should be_true

    @repo.remove
    @repo.exist?.should be_false
  end

  it "cannot be removed if doesn't exist" do
    @repo.exist?.should be_false

    expect { @repo.remove }.to raise_error
  end

  it 'can add new file' do
    @repo.create

    file_path = '/test/file'
    touch file_path

    rec = @repo.add_record file_path

    rec.repository.should eq @repo
    rec.id.should eq 0
    rec.repo_file.should eq ':test:file'

    File.file?(file_path).should be_true
    File.file?(rec.repo_path).should be_true
    File.file?(@repo.config_path).should be_true
  end

  it 'cannot add same file twice' do
    @repo.create

    file_path = '/test/file'
    touch file_path

    # we can add file first time
    @repo.add_record(file_path).should_not be_nil

    # but cannot add it second time
    expect { @repo.add_record file_path }.to raise_error
  end

  it 'cannot add symlink' do
    @repo.create

    file_path = '/test/file'
    touch file_path

    link = '/test/symlink'
    FileUtils.symlink file_path, link

    expect { @repo.add_record(link) }.to raise_error
  end

  it 'can add dir with multiple files and dirs' do
    @repo.create

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

    rec = @repo.add_record base_dir

    rec.repository.should eq @repo
    rec.id.should eq 0

    Dir.exist?(rec.repo_path).should be_true
    File.exist?(File.join(@repo.path, rec.repo_file, f1)).should be_true
    File.exist?(File.join(@repo.path, rec.repo_file, f2)).should be_true

    # we should skip empty dirs
    Dir.exist?(File.join(@repo.path, rec.repo_file, d1)).should be_false

    # we should skip symlinks
    File.symlink?(File.join(@repo.path, rec.repo_file, l1)).should be_false
  end

  it 'can be deserialized from config file' do
    file_path = '/test/file'
    touch file_path

    @repo.create
    rec1 = @repo.add_record file_path

    repo = Cman::Repository.read @repo_name
    repo.size.should eq 1

    rec2 = repo.get_record 0

    rec1.id.should eq rec2.id
    rec1.path.should eq rec2.path
  end

  it 'can add files with the same name' do
    name = 'file'
    path1 = "/test/#{name}"
    path2 = "/test/1/#{name}"
    touch "#{path1}/somefile", path2

    @repo.create

    rec1 = @repo.add_record path1

    rec2 = @repo.add_record path2
    File.exist?(rec2.repo_path).should be_true

    File.directory?(rec1.repo_path).should be_true
  end

  it 'can add hidden file' do
    @repo.create

    file_path = '/test/.file'
    touch file_path

    rec = @repo.add_record file_path

    File.file?(rec.repo_path).should be_true
  end

  it 'can remove file' do
    @repo.create

    file_path1 = '/test/.file'
    file_path2 = '/test1/file'
    touch file_path1, file_path2

    rec = @repo.add_record file_path1
    @repo.add_record file_path2

    @repo.size.should eq 2
    File.file?(rec.repo_path).should be_true

    @repo.remove_record rec.id

    repo = Cman::Repository.read @repo_name
    repo.size.should eq 1
    File.file?(rec.repo_path).should be_false
  end

  it 'cannot remove not existing file' do
    @repo.create

    expect { @repo.remove_record 1000 }.to raise_error

    @repo.size.should eq 0
  end
end
