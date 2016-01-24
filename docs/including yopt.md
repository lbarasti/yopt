Some might find that having to specify the scope every time we want to use `Some` or `None` a bit too verbose. If that is the case, please consider that module scoping is a good receipe to avoid hideous naming clashes.

If you understand the risk then you can either `include Yopt` or cherry-pick the tools you need from the module like so:

```ruby
Some = Yopt::Some
None = Yopt::None
```
