require_relative 'test_helper'

include Ytry

describe 'Ytry module' do
  it 'should have a version' do
    refute_nil ::Ytry::VERSION
  end
end

describe 'Try' do
  it 'something' do
    Try{'hello'}.must_equal Success.new('hello')
    Try{1/0}.error.must_be_kind_of ZeroDivisionError
    lambda{Try{1/0}.get}.must_raise ZeroDivisionError
    Try{raise TypeError}.must_be_kind_of Failure
    Try{raise TypeError}.error.must_be_kind_of TypeError
    case Try{raise TypeError.new("Wrong Type")}
    when Failure then :ok
    else fail
    end
    case Try{raise TypeError.new("Wrong Type")}
    when Failure.new(TypeError) then :ok
    else fail
    end
  end
end
