require_relative 'test_helper'

include Yopt

describe 'Yopt module' do
  it 'should have a version' do
    refute_nil ::Yopt::VERSION
  end
  describe '.lift, a helper method that turns a block: A -> B into a proc: A -> Option[B]' do
    let(:base_proc) {proc {|x| x + 1 if x < 0}}
    let(:lifted_proc) { Yopt.lift &base_proc}

    it 'should raise an error when no block is provided' do
      proc {Yopt.lift}.must_raise ArgumentError
    end
    it 'should turn a block into a proc' do
      lifted_proc.class.must_equal Proc
    end
    it 'should turn nil into None' do
      input = 2
      base_proc.(input).must_equal nil
      lifted_proc.(input).must_equal None
    end
    it 'should wrap non-nil values into `Some`' do
      input = -1
      base_proc.(input).wont_be_nil
      lifted_proc.(input).get.must_equal base_proc.(input)
    end
    it 'supports blocks handling blocks' do
      sum_and_yield = Yopt.lift {|*args, &block| block.call args.reduce(&:+)}
      sqrt = lambda {|x| if x >= 0 then Math.sqrt x else nil end}
      sum_and_yield.(1, 2, 1, &sqrt).must_equal Some.new(2.0)
      sum_and_yield.(1, -1, -1, &sqrt).must_equal None
    end
  end
end
describe 'Option' do
  it 'should wrap an object into `Some` when the object is not `nil`' do
    [1, 2, [1,2,3], [:a, :b], {c: 2}].each {|v|
      Option.(v).must_equal Some.new(v)
    }
  end
  it 'should wrap `nil` into `None`' do
    Option.(nil).must_equal None
  end
  it 'should turn array-like objects into `Option`s in a consistent way' do
    Option.ary_to_type([]).must_equal None
    Option.ary_to_type(None).must_equal None
    Option.ary_to_type([1,2,3]).must_equal Some.new(1)
    Option.ary_to_type([[:a, :c], [:b]]).must_equal Some.new([:a, :c])
  end
  it 'should be idempotent on array-like objects' do
    [[1,2,3], [:a, :b], None].map{|v|
      Option.ary_to_type(v)
    }.each {|opt|
      Option.ary_to_type(opt).must_equal opt
    }
  end
  it 'should play well with `Array#flatten`' do
    a = [Some.new(0), None, Some.new(Some.new(1))]
    a.flatten(1).must_equal [0, Some.new(1)]
    a.flatten.must_equal [0, 1]
  end
  it 'should play well with `Array#flat_map`' do
    a = (0..4).map {|i| if i.odd? then Some.new(i) else None end}
    a.flat_map{|opt| opt.map(&:pred)}.must_equal [0, 2]
  end
  it 'should raise an error on `#or_else` when the caller is `empty` and the given block returns a non-`Option` value' do
    proc {None.or_else {"not-an-option"}}.must_raise TypeError
  end
  it 'should lazily evaluate the block passed to `#or_else`' do
    Some.new(1).or_else {fail}.must_equal Option[1]
  end
  it 'supports lazy disjunction of Options with `#or_else`' do
    f = Yopt.lift {|x| x if x < 0}
    g = Yopt.lift {|x| x if x > 0}
    c = -> {Option[42]} # a lambda returning a constant

    f.(1).or_else{ g.(1) }.must_equal g.(1)
    f.(-1).or_else{ g.(-1) }.must_equal f.(-1)
    f.(1).or_else(&c).or_else{ Option[0] }.get.must_equal 42
    f.(0).or_else{ g.(0) }.or_else{ Option[0] }.get.must_equal 0
  end
  it 'is not affected by changes to the array representation' do
    s1 = Some.new([1,2,3])
    s1.to_ary << 4
    s1.to_ary[0] = 0
    s1.get.must_equal [1,2,3]
    None.to_ary << 0
    None.to_ary.must_equal []
  end
  it 'support zipping as a mean to collect `Options`' do
    Some.new(3).zip(None).must_equal None
    None.zip(Some.new(1)).must_equal None
    Some.new(0).zip(Some.new(4)).must_equal Some.new([0,4])
    a = (0..4).map {|i| if i.odd? then Some.new(i) else None end}
    a.reduce(&:zip).must_equal None
    a.rotate.reduce(&:zip).must_equal None
    a.grep(Some).reduce(&:zip).must_equal Some.new([1,3])
  end
  it 'supports piping on lambdas' do
    result = Some.new(3) | :succ | lambda {|x| x ** 2}
    result.get.must_equal 16
    nothing = None | :pred | -> (x) {x ** 2}
    nothing.must_equal None
  end
  it 'supports lifting on lambdas' do
    sqrt = lambda {|x| if x >= 0 then Math.sqrt x else nil end}
    valid = 4
    invalid = -4
    (Some.new(valid) ^ sqrt).must_equal Some.new(Math.sqrt(valid))
    (Some.new(invalid) ^ sqrt).must_equal None
    (None ^ sqrt).must_equal None
  end
  it 'supports case statements' do
    case Some.new(3)
    when None then fail
    when Some then :ok
    else fail
    end
    case Some.new(3)
    when Some.new(->(x) {x.even?}) then fail
    when Some.new((4..10)) then fail
    when Some.new((1..4)) then :ok
    else fail
    end
    case None
    when Some then fail
    when Some.new(nil) then fail
    when None then :ok
    else fail
    end
  end
end
describe 'Some' do
  before do
    @some = Some.new(42)
  end
  it 'should wrap a value' do
    @some.get.must_equal 42
  end
  it 'should be mappable' do
    @some.map{|v| v + 1}.must_equal Some.new(43)
    @some.map{|v| nil}.must_equal Some.new(nil)
  end
  it 'should return Some(nil) when a block passed to `#collect` returns nil' do
    increase_if_odd = -> (v) {if v % 2 == 1 then v + 1 end}
    @some.collect(&increase_if_odd).must_equal Some.new(nil)
    Some.new(41).collect(&increase_if_odd).get.must_equal 42
  end
  it 'should return `Option`s on selected `Enumerable` methods' do
    @some.each{|x| x + 1}.must_equal [@some.get]
    predicate = -> (x) {x > 0}
    @some.any?(&predicate).must_equal true
    @some.all?(&predicate).must_equal true
    @some.any?{|x| !predicate.(x)}.must_equal false
    @some.all?{|x| !predicate.(x)}.must_equal false
    @some.reduce(1){|x, y| x + y}.must_equal 43
    @some.select{|x| x > 0}.must_equal @some
    @some.select{|x| x < 0}.must_equal None
    @some.include?(42).must_equal true
    @some.include?(41).must_equal false
    @some.flat_map {|v| Option.(v + 1)}
      .must_equal Option.(@some.get + 1)
    flat_mappable_obj = [1,2,3]
    @some.flat_map {[]}.must_equal None
    @some.flat_map {[1]}.must_equal Option.(1)
    @some.flat_map {[1,2,3]}.must_equal Option.(1)
  end
  it 'should not raise an error when flat_map block does not return an ary-like object' do
    @some.flat_map {42}.must_equal Option.(42)
  end
  it 'should return an Option on #grep' do
    @some.grep(42) {|v| v + 1}.must_equal Option.(43)
    @some.grep(42..55) {|v| v + 1}.must_equal Option.(43)
    @some.grep(->(c) {c.even?}).must_equal Option.(42)
    @some.grep(->(c) {c.odd?}).must_equal None
    None.grep(nil){|v| fail}.must_equal None
    None.grep(->(c) {fail}).must_equal None
  end
  it 'should be flattenable' do
    nestedSome = Some.new(Some.new(@some))
    nestedSome.flatten.must_equal Some.new(@some)
    Some.new(None).flatten.must_equal None
  end
  it 'should raise an error when flattening a non-`Option` value' do
    nestedSome = @some
    proc {nestedSome.flatten}.must_raise TypeError
  end
  it 'should return its value on `#or_nil`' do
    @some.or_nil.must_equal @some.get
  end
  it 'should return itself on `#or_else`' do
    @some.or_else {Some.new(4)}.must_equal @some
    @some.or_else {None}.must_equal @some
  end
  it 'should return itself on `#get_or_else`' do
    (@some.get_or_else {raise}).must_equal @some.get
    proc {@some.get_or_else}.must_raise ArgumentError
  end
  it 'should not be empty' do
    @some.empty?.must_equal false
  end
  it 'should have a nice string representation' do
    @some.to_s.must_equal "Some(42)"
    Some.new(@some).to_s.must_equal "Some(Some(42))"
  end
  it 'should compare for equality based on the wrapped value' do
    @some.must_equal Some.new(@some.get)
    Some.new([1,2,3]).must_equal Some.new([1,2,3])
    @some.wont_equal None
    @some.wont_equal Some.new(rand(@some.get) % @some.get)
  end
end
describe 'None' do
  it 'should support `#map`/`#collect`/`#flatten`' do
    None.map{|v| v + 1}.must_equal None
    None.collect(&:succ).must_equal None
    None.flatten.must_equal None
  end
  it 'should be enumerable' do
    None.each{|x| raise RuntimeError}.must_equal []
    None.any?{|x| x > 0}.must_equal false
    None.all?{|x| x > 0}.must_equal true
    None.reduce(42){raise RuntimeError}.must_equal 42
    None.select{|x| x < 0}.must_equal None
    None.include?(42).must_equal false
  end
  it 'should throw an exception on `#get`' do
    proc {None.get}.must_raise RuntimeError
  end
  it 'should return nil on `#or_nil`' do
    None.or_nil.must_equal nil
  end
  it 'should return `other` on `#or_else`' do
    None.or_else {Some.new(4)}.get.must_equal 4
  end
  it 'should return `other` on `#get_or_else`' do
    None.get_or_else {'lazily evaluated'}.must_equal "lazily evaluated"
    proc {None.get_or_else(42)}.must_raise ArgumentError
  end
  it 'should be empty' do
    None.empty?.must_equal true
  end
  it 'should have a nice string representation' do
    None.to_s.must_equal "None"
  end
  it 'should only be equal to itself' do
    None.must_equal None
    None.wont_equal nil
    None.wont_equal Some.new(rand(100))
  end
end
