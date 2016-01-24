$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yopt'

require 'minitest/autorun'

def same_string(exp1)
  -> exp2 {assert_equal(exp1.to_s, exp2); exp1}
end
