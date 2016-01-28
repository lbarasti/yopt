# Yopt

A [Scala](http://www.scala-lang.org/api/current/index.html#scala.Option) inspired gem that introduces `Option`s to Ruby while aiming for an idiomatic API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yopt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yopt

## Basic usage

The Option type models the possible absence of a value. It lets us deal with the uncertainty related to such a value being there without having to resort to errors or conditional blocks.

Instances of Option are either an instance of `Yopt::Some` - meaning the option contains a value - or the object `Yopt::None` - meaning the option is *empty*.

```ruby
require 'yopt'

some = Yopt::Some.new(42)
none = Yopt::None
```

We can access and manipulate the optional value by passing a block to `Option#map`.

```ruby
some.map {|value| value + 2} # returns Some(44)
none.map {|value| value + 2} # returns None
```

When we are not interested in the result of a computation on the optional value, it is a good practice to use `Option#each` rather than `Option#map`. That will make our intention clearer.

```ruby
some.each {|value| puts value} # prints 42
none.each {|value| puts value} # does not print anything
```

We can safely retrieve the optional value by passing a default value to `Option#get_or_else`

```ruby
some.get_or_else 0 # returns 42
none.get_or_else 0 # returns 0
```

We can also filter the optional value depending on how it evaluates against a block via `Option#select`

```ruby
some.select {|value| value < 0} # returns None
none.select {|value| value < 0} # returns None
some.select {|value| value > 0} # returns Some(42)
```

We can easily turn any object into an Option by means of `Option.call` - aliased to `Option[]` for convenience.
For instance, this is useful when dealing with functions that might return `nil` to express the absence of a result.

```ruby
Yopt::Option[nil] # returns None
Yopt::Option[42] # returns Some(42)
```


A combination of the few methods just introduced already allows us to implement some pretty interesting logic. Checkout `basics.rb` in the docs folder to get some inspiration.

## Why opt?

Using `Option`s reduces the amount of branching in our code and lets us deal with exceptional cases in a seamless way. No more check-for-nil, no more `rescue` blocks, just plain and simple data transformation.

It also makes our code safer by treating *the absence of something* like a fully fledged object, and enables us to use the Null Object Pattern everywhere we want without the overhead of having to write specialized Null-type classes for different classes.

## Advanced Usage
### #reduce
Given an Option `opt`, a value `c` and a lambda `f`,
```
opt.reduce(c, &f)
```
returns `c` if `opt` is `None`, and `f.(c, opt)` otherwise.

This is a shortcut to
```
opt.map{|v| f.(c,v)}.get_or_else(c)`
```


### #flatten and #flat_map
When working with functions returning `Option`, we might end up dealing with nested options...
```ruby
maybe_sqrt = lambda {|x| Yopt::Option[x >= 0 ? Math.sqrt(x) : nil]}
maybe_increment = lambda {|x| Yopt::Option[x > 1  ? x + 1 : nil]}

maybe_sqrt.(4).map {|v| maybe_increment.(v)} # Some(Some(3.0))
maybe_sqrt.(1).map {|v| maybe_increment.(v)} # Some(None)
```

Usually, this is not what we want, so we call `Option#flatten` on the result
```ruby
maybe_sqrt.(4).map {|v| maybe_increment.(v)}.flatten # Some(3.0)
maybe_sqrt.(1).map {|v| maybe_increment.(v)}.flatten # None
```

`Option#flat_map` combines the two calls into one

```ruby
maybe_sqrt.(4).flat_map {|v| maybe_increment.(v)} # Some(3.0)
maybe_sqrt.(1).flat_map {|v| maybe_increment.(v)} # None
```

A difference to keep in mind is that `#flatten` will raise an error if the wrapped value does not respond to `#to_ary`
```ruby
Yopt.Option[42].flatten # raises TypeError: Argument must be an array-like object. Found Fixnum
```
whereas #flat_map behaves like #map when the passed block does not return an array-like value
```ruby
Yopt.Option[42].flat_map{|v| v} # returns Some(42)
```


### #zip
When dealing with a set of `Option` instances, we might want to ensure that they are all defined - i.e. not __empty__ - before continuing a computation...
```ruby
email_opt.each(&send_pass_recovery) unless (email_opt.empty? or captcha_opt.empty?)
```

We can avoid `empty?` checks by using `Option#zip`
```ruby
email_opt.zip(captcha_opt).each{|(email,_)| send_pass_recovery(email)}
```

`Option#zip` returns `None` if any of the arguments is `None` or if the caller is `None`
```ruby
Yopt::None.zip Option[42] # None
Option[42].zip Yopt::None # None
Option[42].zip Option[0], Yopt::None, Option[-1] # None
```

When both the caller and all the arguments are defined then `zip` collects all the values in an Array wrapped in a `Yopt::Some`

```ruby
Option[42].zip Option[0], Option["str"] # Some([42, 0, "str"])
```


### #grep
We often find ourselves filtering data before applying a transformation...

```ruby
opt.filter {|v| (1...10).include? v}.map {|v| v + 1}
```

In this scenario, `Option#grep` can sometimes make the code more concise

```ruby
opt.grep(1...10) {|v| v + 1}
```

`Option#grep` supports lambdas as well

```ruby
is_positive = lambda {|x| x > 0}

opt.grep(is_positive) {|v| Math.log(v)}
# is equivalent to
opt.filter(&is_positive).map {|v| Math.log(v)}
```


## Haskell Data.Maybe cheat sheet

Some (None?) might enjoy a comparison with Haskell's [Maybe](https://hackage.haskell.org/package/base/docs/Data-Maybe.html). Here is how the Data.Maybe API translate to Yopt.
```ruby
maybe default f opt     -> opt.map(&f).get_or_else(default)
isJust opt              -> not opt.empty?
isNothing opt           -> opt.empty?
fromJust opt            -> opt.get
fromMaybe default opt   -> opt.get_or_else default
listToMaybe list        -> Option.ary_to_type list
maybeToList opt         -> opt.to_a
catMaybes listOfOptions -> listOfOptions.flatten
mapMaybe f list         -> list.flat_map &f
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lbarasti/yopt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

