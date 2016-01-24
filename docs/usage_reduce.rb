require 'yopt'

compute_increase = Yopt.lift {|user| 10000 if ['Bob', 'Joe', 'Eve'].member?(user)}

base_salary = 20000
user = ['Noel', 'Eve'].sample
salary_increase_opt = compute_increase.(user) # None | Some(10000)

salary_increase_opt.reduce(base_salary, &:+) # 20000 | 30000
# is equivalent to
salary_increase_opt.map{|increase| base_salary + increase} # None | Some(30000)
                   .get_or_else(base_salary) # 20000 | 30000
