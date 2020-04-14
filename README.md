# Prelude

## Why?

A lot of times you write code in a view that leads to an `n+1`, like:

``` erb
<% posts.each do |post| %>
  <%= post.author.name %>
<% end %>
```

Each of the current ways to handle this scenario come with drawbacks:

1. `includes`:
  - only works on `ActiveRecord::Relation` (not `Array`s) of records
  - only can preload other associations defined on the model
  - requires that you either declare the associations to load in the `controller`, _or_ add `includes` throughout the `view`

2. gems like `bullet`
  - raise errors when `n+1`s are detected, instead of optimizing them
  - are still difficult to fix with `includes` due to the reasons above

A lot of times for more complex relationships or `Array`s we write something
like:

``` erb
<% authors_by_id = Author.where(id: posts.map(&:author_id)).index_by(&:id) %>
<% posts.each do |post| %>
  <% author = authors_by_id[post.author_id] %>
  <%= author.name %>
<% end %>
```

This is fine, but it's pretty annoying to write, and can be even messier when
doing things like using partials to render individual items in a collection (in
that case, the preload has to happen in the parent view even though the partial
is where the data is actually being rendered).

This gem aims to approach the preloading in a way that's closer to `ActiveRecord`,
and brings the preloading closer to the data.

## How?

In the model we can define a custom preloader which takes in a collection of objects
and returns a Hash of `object -> result`:

``` ruby
class Post < ActiveRecord::Base
  include Preload::Preloadable

  # An implementation which takes in an Array[Post], and returns
  # a Hash[Post]=>[Author]
  define_prelude(:author) do |posts|
    authors_by_id = Author.where(id: posts.map(&:author_id)).index_by(&:id)
    Hash.new { |h, k| h[k] = authors_by_id[k.author_id] }
  end
end
```

The view stays simple:

``` erb
<% posts.each do |post| %>
  <%= post.author.name %> <%# no n+1 %>
<% end %>
```

The first time that `author` is accessed on `post`, the batch method on the
`Model` will be executed, and data will be ready for each of the objects in
each iteration.

You may also combine this API with `strict_loading` to make sure that no records
inside of an iteration load other associations without using batched loaders.

### Arrays

If you'd like to use Prelude with an Array of records, it's simple. Just call
`with_prelude` while iterating, for example:

``` ruby
posts = [Post.find(1), Post.find(2)] # Array, not relation
posts.each.with_prelude do |post|
  post.author
end
```
