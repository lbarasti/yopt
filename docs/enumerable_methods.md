## About Enumerable methods
By including `Enumerable`, `Option` gives access to a set of methods which are either redundant or not really meaningful for a `Some` or a `None` object

```ruby
:slice_after :slice_before :slice_when :take :take_while :drop :drop_while :chunk :sort_by :each_entry :each_slice :group_by :minmax_by :sort :each_with_index :partition :find_all :max_by :min_by :reverse_each :each_cons :min :max :minmax
```

On the other hand, all the methods returning a boolean work as expected
```ruby
:all? :any? :include? :none? :one? :member?
```

The following methods work in a predictable way out-of-the-box
```ruby
:reduce :inject :each_with_object :cycle :to_set :find_index :find :detect :first :count :to_a :entries :to_h
```

While the following methods have custom definition to always return an `Option` rather than an `Array`
```ruby
:collect :map :flat_map :collect_concat :reject :select :zip :grep
```
