require_relative 'test_helper'

include Ytry

describe 'Ytry module' do
  it 'should have a version' do
    refute_nil ::Ytry::VERSION
  end
end

describe 'Try' do
  it 'should wrap a successful computation into Success' do
    Try{'hello'}.must_equal Success.new('hello')
  end
  it 'should wrap an exception into Failure when an exception is raised' do
    Try{raise TypeError}.must_be_kind_of Failure
  end
end

describe 'Failure' do
  before do
    @failure = Try{ 1 / 0 }
  end
  it 'should raise an exception on #get' do
    -> { @failure.get }.must_raise ZeroDivisionError
  end
  it 'should return the wrapped exception on #error' do
    Try{raise TypeError}.error.must_be_kind_of TypeError
  end
  it 'should support case statements' do
    case Try{raise TypeError.new("Wrong Type")}
    when Failure then :ok
    else fail
    end
    case Try{raise TypeError.new("Wrong Type")}
    when Failure.new(TypeError) then :ok
    else fail
    end
  end
  it 'should support `#map`/`#collect`/`#flatten`' do
    @failure.map{|v| v + 1}.must_equal @failure
    @failure.collect(&:succ).must_equal @failure
    @failure.flatten.must_equal @failure
  end
end