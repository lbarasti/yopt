require_relative '../test/test_helper' # IGNORE
# IGNORE
require 'test/unit' # IGNORE
include Test::Unit::Assertions # IGNORE

# You can create an option from any object `obj`
# In general, any object gets wrapped into a `Some` instance
some = Yopt::Option[42] # Some(42)
# The only exception being `nil`, which turns into `None`
none = Yopt::Option[nil] # None

# since Some and None have the same API, let's choose one of the two
# randomly, and record the intermediate result of each computation
# for both None and Some(42) following the convention <result_if_none> | <result_if_some>
opt = [none, some].sample

opt                  # None | Some(42)
  .select{|x| x > 0} # None | Some(42)
  .map(&:succ)       # None | Some(43)
  .get_or_else(1)    # 1    | 43

# Calling select/reject on a Some instance can return None
# Whereas a None can never be transformed into a Some
                        # None | Some(42)
opt.select{ |x| x < 0 } # None | None

# One of the perks of working with options is that it allow us to stay
# away from `nil` and `if` statements. You can still revert to using them if you need to though
# There always is a better way to go though.
opt.or_nil # nil | 42
# Even better, if the option is None we can return a default value straight away
opt.get_or_else 31 # 31 | 42

# If we intend to stay in the Option domain for some more time we can swap None with an other Option
opt.or_else(Yopt::Option[61]) # Some(61) | Some(42)
   .reject(&:even?)           # Some(61) | None
   .get_or_else 0             # 61       | 0

# Once in the Option domain, it's nice to avoid accessing
# the content of an option explicitly as far as possible.
# You might eventually need to extract the value wrapped by
# Option.
begin     # None                  | Some(42)
  opt.get # raises a RuntimeError | 42
rescue RuntimeError
  puts "cannot call #get on #{opt}"
end

# This does not look safe. Luckily we can check if the option
# is None by calling `empty?` on it
opt.empty? # true | false


# v = s2.reduce(2){|default, opt_val| opt_val - default} # 47
# n = Yopt::Some.new(v) # Some(47)
#   .collect{|x| if x % 2 == 1 then x + 1 end} # None
#   .map{|x| x ** 2} # None

# if s1.reduce(s2.get, &:-) < 0 && s1.include?(42) # true
#   s2.collect{ n.empty? && n } # Some(None)
#     .flatten # None
#     .or_nil # nil
# end
# head_opt = Util.lift &:first
# old_school_validate = -> email {if email.end_with?('my-domain.com') then email else nil end}
# valid = 'user@my-domain.com'
# invalid = '@gmail.com'
# old_school_validate.(invalid).must_equal nil
# old_school_validate.(valid).wont_be_nil
# old_school_validate.(valid).must_equal valid

# brand_new_validate = Util.lift &old_school_validate
# brand_new_validate.(invalid).must_equal None
# brand_new_validate.(valid).must_equal Some.new(valid)

# user = brand_new_validate.(valid) | Util.lift{|email| email.split('@')[0]} | :upcase
# user.get.must_equal "USER"
