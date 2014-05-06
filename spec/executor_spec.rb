require 'spec_helper'

describe Cman::Executor do
  it 'instantiates with correct command' do
    Cman::Executor.new 'status'
  end

  it 'raise error on incorrect command' do
    expect { Cman::Executor.new 'status123123' }.to raise_error
  end
end
