require_relative '../test/test_helper' # IGNORE
# IGNORE
# IGNORE
get_opt = Yopt.lift {|cache, key| cache[key]} # IGNORE
process = -> info {p info} # IGNORE
log_failure = -> msg {p "WARN -- #{msg}"} # IGNORE
cache = {} # IGNORE
db = Struct.new(:get).new(-> email {Yopt::None}) # IGNORE
api = Struct.new(:get).new(Yopt.lift {|email| {name: 'user', address: '...'} if email == 'username@mail.com'}) # IGNORE
email = ['username@mail.com', 'invalid@mail.com'].sample # IGNORE
# IGNORE
info = get_opt.(cache, email).or_else {db.get[email]}.or_else {api.get[email]}
case info
when Yopt::Some then info.each(&process)
else log_failure.("could not retrieve info fot #{email}")
end