require_relative '../test/test_helper' # IGNORE
# IGNORE
# stub functions # IGNORE
get_from_cache  = Yopt.lift {|email| 'E1W 01' if email == 'alice@mail.com'} # IGNORE
get_from_db     = Yopt.lift {|email| 'EC1 W1' if email == 'bob@mail.com'} # IGNORE
get_from_remote = Yopt.lift {|email| 'N16 4AP' if email == 'eve@mail.com'} # IGNORE
process = -> info {"found #{info}"} # IGNORE
log_failure = -> msg {"WARN -- #{msg}"} # IGNORE
# example # IGNORE
get_postcode = -> email do
  get_from_cache[email]
    .or_else { get_from_db[email] }
    .or_else { get_from_remote[email] }
end
assert_equal get_postcode['alice@mail.com'], Yopt::Some.new("E1W 01") # IGNORE
assert_equal get_postcode['bob@mail.com'],   Yopt::Some.new("EC1 W1") # IGNORE
assert_equal get_postcode['eve@mail.com'],   Yopt::Some.new("N16 4AP") # IGNORE
assert_equal get_postcode['zed@mail.com'],   Yopt::None # IGNORE
