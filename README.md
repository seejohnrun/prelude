# Prelude

## Installation

Prelude is available on RubyGems as `prelude-batch-loader`.

## Why?

A lot of times you write code in a view that leads to an `n+1`, like:

``` erb
<% posts.each do |post| %>
  <% post.comments.featured.each do |comment| %>
    <%= comment.body %>
  <% end %>
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

---

Imagine we want to preload all of the `Comment`s for the posts in an `Array`,
but only the ones that are `featured`. Normally this would lead to an `N+1`,
so we might write:

``` erb
<% featured_comments_by_post_id = Comment.featured.where(post: posts).group_by(&:post_id) %>
<% posts.each do |post| %>
  <% featured_comments = featured_comments_by_post_id[post.id] %>
  <% featured_comments.each do |comment| %>
    <%= comment.body %>
  <% end %>
<% end %>
```

This is fine, but it's pretty annoying to write, and can be even messier when
doing things like using partials to render individual items in a collection (in
that case, the preload has to happen in the parent view even though the partial
is where the data is actually being rendered).

This gem aims to approach the preloading in a way that's closer to `ActiveRecord`,
and brings the preloading closer to the data.

## How?

### Relation

In the model we can define a custom preloader which takes in a collection of objects
and returns a Hash of `object -> result`:

``` ruby
class Post < ActiveRecord::Base
  # An implementation which takes in an Array[Post], and returns
  # a Hash[Post]=>Array[Comment]
  define_prelude(:featured_comments) do |posts|
    Comment.featured.where(post: posts).group_by(&:post_id)
  end
end
```

The view stays simple:

``` erb
<% posts.each.with_prelude do |post| %>
  <% post.featured_comments.each do |comment| %> <%# no n+1 %>
    <%= comment.body %>
  <% end %>
<% end %>
```

The first time that `featured_comments` is accessed on `post`, the batch method
on the `Model` will be executed, and data will be ready for the objects in each
iteration.

You may also combine this API with `strict_loading` to make sure that no records
inside of an iteration load other associations without using batched loaders.

### Arrays

If you'd like to use Prelude with an Array of records, it's simple. Just call
`with_prelude` while iterating, for example:

``` ruby
posts = [Post.find(1), Post.find(2)] # Array, not relation
posts.each.with_prelude do |post|
  post.featured_comments
end
```

### Single elements

A lot of times in our apps we end up writing a batch version of something, and
an individual object version. Preloaders can be called on either a collection
of objects or on a single object.

In the case of being called on a single object, they behave just like a
memoized method call:

``` ruby
post = Post.new
post.featured_comments # hit db
post.featured_comments # memoized
```

### Hash#default_proc

It's also possible to make prelude definitions that return a `Hash` with a
`default_proc` set instead of containing the proper values. This can be useful
when it's not convenient to build the entire hash up front. (See example in the
'Arguments' section)

### Arguments

Prelude methods can also be defined to take in arguments. In this case, your
batch method will be called one time for each unique set of arguments passed
to a given method. This can often be useful when trying to preload things
like authorizations for a given user:

``` erb
<% breweries.each do |brewery| %>
  <%= brewery.name %>

  <% if brewery.has_admin?(current_user) %>
    <%= link_to 'Edit', '#' %>
  <% end %>
<% end %>
```

Where your model defines a prelude like:

``` ruby
define_prelude :has_admin? do |breweries, current_user|
  admin_ids = current_user.admin_brewery_ids
  Hash.new { |h, brewery| admin_ids.include?(brewery.id) }
end
```

### Explicit preloading

Sometimes it's useful to preload values before you need to use them.

``` ruby
Prelude.preload(comments, :body, format: :html)
```

Later, you can require Prelude to use the preloaded value:

``` erb
<% comments.each do |comment| %>
  <%= comment.preloaded.body(format: :html) %>
<% end %>
```

This prevents you from accidentally loading data twice by changing the arguments
to the `Prelude.preload` call without also remembering to change the arguments
to the `Comment#body` call in the view or vice versa.
