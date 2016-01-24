require_relative '../test/test_helper' # IGNORE
# IGNORE
require 'test/unit' # IGNORE
include Test::Unit::Assertions # IGNORE

name2phone = [[:a, "+1 310-000-001"],
              [:b, "+1 323-000-002"],
              [:d, "+1 310-000-003"],
              [:e, "+1 213-000-004"],
              [:f, "+1 323-000-005"],
              [:h, "+1 213-000-006"],
              [:k, "+1 213-000-007"],
              [:s, "+1 310-000-009"],
              [:w, "+1 800-000-010"]]

phone2postcode = [["+1 310-000-001", "CA 90210"],
                  ["+1 310-000-003", "CA 90210"],
                  ["+1 323-000-005", "CA 90028"],
                  ["+1 213-000-006", "CA 90027"],
                  ["+1 213-000-007", "CA 90027"],
                  ["+1 800-000-010", "CA 91608"]]

postcode2income = [["CA 90210", "$80000"],
                  ["CA 91608", "$65000"]]


lookup = -> (table, key) {
  row_or_nil = table.find { |row| row.first == key }
  Yopt::Option[row_or_nil] | :last
}

same_string( # IGNORE
lookup.(name2phone, :s)
).('Some(+1 310-000-009)') # COMMENT

same_string( # IGNORE
lookup.(name2phone, :x)
).('None') # COMMENT

same_string( # IGNORE
same_string( # IGNORE
same_string( # IGNORE
lookup.(name2phone, :a)
).('Some(+1 310-000-001)') # COMMENT
  .flat_map {|phone| lookup.(phone2postcode, phone)}
).('Some(CA 90210)') # COMMENT
  .flat_map {|postcode| lookup.(postcode2income, postcode)}
).('Some($80000)') # COMMENT

# or if you want to go crazy-functional
lookup.(name2phone, :a) | lookup.curry[phone2postcode] | lookup.curry[postcode2income]
