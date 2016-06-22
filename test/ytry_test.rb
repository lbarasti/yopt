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

describe 'Success' do
  before do
    @success = Try{ 41 + 1 }
  end
  it 'should not support flattening a scalar value' do
    -> {@success.flatten}.must_raise TypeError
  end
  it 'should support `#flatten`/`#flat_map`' do
    Try{@success}.flatten.must_equal @success
    @success.map{|v| Try{v}}.flatten.must_equal @success
    @success.flat_map{|c| Try{c - 42}}.must_equal Try{0}
    @success.flat_map{|c| Try{raise TypeError}}.must_be_kind_of Failure
  end
end

describe 'Failure' do
  before do
    @failure = Try{ 1 / 0 }
    @failure_type = @failure.error.class
    @failure_message = @failure.error.message
  end
  it 'should raise an exception on #get' do
    -> { @failure.get }.must_raise ZeroDivisionError
  end
  it 'should return the wrapped exception on #error' do
    Try{raise TypeError}.error.must_be_kind_of TypeError
  end
  it 'should support case statements' do
    case @failure
      when Failure then :ok
      else fail
    end
    case @failure
      when Failure.new(@failure_type) then :ok
      else fail
    end
  end
  it 'should support `#map`/`#collect`/`#select`' do
    @failure.map{|v| v + 1}.must_equal @failure
    @failure.collect(&:succ).must_equal @failure
    @failure.select{|x| x < 0}.must_equal @failure
  end
  it 'should support `#flatten`/`#flat_map`' do
    @failure.flatten.must_equal @failure
    Try{@failure}.flatten.must_equal @failure
    Try{@failure}.flat_map{|c| c}.must_equal @failure
  end
  it 'should be enumerable' do
    @failure.each{|x| raise RuntimeError}.must_equal []
    @failure.any?{|x| x > 0}.must_equal false
    @failure.all?{|x| x > 0}.must_equal true
    @failure.reduce(42){raise RuntimeError}.must_equal 42
    @failure.include?(42).must_equal false
  end
  it 'should return `other` on `#or_else`' do
    @failure.or_else {Try {1}}.get.must_equal 1
  end
  it 'should return `other` on `#get_or_else`' do
    @failure.get_or_else {'lazily evaluated'}.must_equal "lazily evaluated"
  end
  it 'does not support passing an argument to #get_or_else' do
    -> {@failure.get_or_else(42)}.must_raise ArgumentError
  end
  it 'should be empty' do
    @failure.empty?.must_equal true
  end
  it 'should have a nice string representation' do
    @failure.to_s.must_equal "Failure(#{@failure_message})"
  end
end