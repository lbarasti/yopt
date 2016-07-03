require_relative '../test/test_helper' # IGNORE
# IGNORE
require 'test/unit' # IGNORE
include Test::Unit::Assertions # IGNORE
# IGNORE
opt = Yopt::Some.new(2) # IGNORE
def function_with_side_effects(v); p v; end # IGNORE
# IGNORE
opt.each {|v| function_with_side_effects(v)}.get_or_else {log_failure}