require 'spec_helper'

describe Cman::Executor do
  def new(command)
    Cman::Executor.new command
  end

  it 'instantiates with correct command' do
    command = Cman::Executor::COMMANDS[0]
    expect { new command }.not_to raise_error
  end

  it 'raise error on incorrect command' do
    expect { new 'status123123' }.to raise_error
  end

  it 'raise error on wrong number of arguments' do
    comm = new 'add'
    expect { comm.execute }.to raise_error Cman::ExecutorError
  end
end
