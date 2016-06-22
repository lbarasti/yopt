require 'ytry/version'

module Ytry
  def Try
    raise ArgumentError, 'missing block' unless block_given?
    begin
      Success.new(yield)
    rescue StandardError => e
      Failure.new(e)
    end
  end
  module Try
    include Enumerable
    def self.ary_to_type value
      raise Try.invalid_argument('Argument must be an array-like object', value) unless value.respond_to? :to_ary
      return value if value.is_a? Try
      if value.to_ary.empty? then Failure.new(Exception.new) else Success.new(value.to_ary.first) end
    end
    def each &block
      to_ary.each &block
    end
    %i(map select reject collect collect_concat).each do |method|
      define_method method, ->(&block) {
        block or return enum_for(method)
        self.empty? ? self : Try.ary_to_type(super(&block))
      }
    end
    def flat_map &block
      block or return enum_for(method)
      self.empty? ? self : Try.ary_to_type(block.call(self.get))
    end
    def grep(pattern, &block)
      Try.ary_to_type super
    end
    def flatten
      return self if empty?
      Try.ary_to_type self.get
    end
    def zip *others
      # TODO return first Failure among arguments - if any
      return Failure.new(Exception.new) if self.empty? || others.any?(&:empty?)
      collection = others.reduce(self.to_a, &:concat)
      Success.new collection
    end
    def | lambda
      self.flat_map &lambda # slow but easy to read + supports symbols out of the box
    end
    def or_else
      return self unless empty?
      other = yield
      other.is_a?(Try) ? other : raise(Try.invalid_argument('Block should evaluate to an Try', other))
    end
    def get_or_else
      raise ArgumentError, 'missing block' unless block_given?
      return self.get unless empty?
      yield
    end
    private
    def self.invalid_argument type_str, arg
      TypeError.new "#{type_str}. Found #{arg.class}"
    end
  end
  class Success
    include Try
    def initialize value
      @value = value.freeze
    end
    def get() @value end
    def empty?() false end
    def to_s() "Success(#{get})" end
    def to_ary() [get] end
    def == other
      other.is_a?(Success) && self.get == other.get
    end
    def === other
      other.is_a?(Success) && self.get === other.get
    end
  end
  class Failure
    include Try
    attr_reader :error
    def initialize value
      @error = value.freeze
    end
    def get() raise @error end
    def empty?() true end
    def to_s() "Failure(#{@error})" end
    def to_ary() [] end
    def == other
      other.is_a?(Failure) && self.error == other.error
    end
    def === other
      other.is_a?(Failure) && self.error === other.error
    end
  end
end