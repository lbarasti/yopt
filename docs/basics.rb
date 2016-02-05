require_relative '../test/test_helper' # IGNORE
# IGNORE
class Cache < Hash
  def maybe_get key
    Yopt::Option[self[key]]
  end

  def store_if_some key, opt_value
    opt_value.each {|value| self.store(key, value)}
  end
end

def maybe_sqrt value
  opt = Yopt::Option[value]
  opt.select {|value| value >= 0}
    .map {|value| Math.sqrt(value)}
end

def get_info cache, key
  cache.maybe_get(key)
    .map {|value| "found value %.2f for key %s" % [value, key]}
    .get_or_else {"value not found for key #{key}"}
end

cache = Cache.new

cache.store_if_some 42, maybe_sqrt(42)

key = 42 + rand(2) # could be either 42 or 43

puts get_info(cache, key)
# IGNORE
same_string(cache.maybe_get(key)).(Yopt::Some.new(Math.sqrt(42)).to_s) if key == 42 # IGNORE
same_string(cache.maybe_get(key)).(Yopt::None.to_s) if key != 42 # IGNORE
