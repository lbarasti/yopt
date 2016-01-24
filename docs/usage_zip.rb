require_relative '../test/test_helper' # IGNORE
# IGNORE
require 'test/unit' # IGNORE
include Test::Unit::Assertions # IGNORE

validate_email = Yopt.lift {|x| x if x.end_with? "@domain.com"}
validate_password = Yopt.lift {|x| x if x.size > 8}
hash_f = lambda {|str| str.each_char.map(&:ord).reduce(:+)}

# returns Yopt::Some(Fixnum) if email and password are both valid
# returns Yopt::None otherwise
hash_credentials = -> (email, password) do
    maybe_email    = validate_email.(email)
    maybe_password = validate_password.(password)

    maybe_email.zip(maybe_password)
               .map {|(valid_email, valid_pass)| hash_f.(valid_email + valid_pass)}
end

same_string( # IGNORE
hash_credentials.('invalid_mail', 'valid_pass')
).('None') # COMMENT
# IGNORE
same_string( # IGNORE
hash_credentials.('valid@domain.com', 'invalid')
).('None') # COMMENT
# IGNORE
same_string( # IGNORE
hash_credentials.('valid@domain.com', 'valid_pass')
).('Some(2651)') # COMMENT
