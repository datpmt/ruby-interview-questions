# Caching — Answers (Rails)

### 1. What are the different caching strategies in Rails?

Rails provides three main caching levels:

**1. Page Caching** – Cache entire HTML pages
```ruby
class PostsController < ApplicationController
  caches_page :show, :index

  def show
    @post = Post.find(params[:id])
  end
end

# Cached as /public/posts/1.html
# Fastest but inflexible with user-specific content
```

**2. Action Caching** – Cache controller actions (includes filters)
```ruby
class PostsController < ApplicationController
  caches_action :show, expires_in: 1.hour

  def show
    @post = Post.find(params[:id])
  end
end

# Runs filters before serving cached response
# Good for authenticated pages
```

**3. Fragment Caching** – Cache view fragments
```erb
<!-- app/views/posts/show.html.erb -->
<h1><%= @post.title %></h1>

<% cache @post do %>
  <div class="post-content">
    <%= @post.content %>
  </div>
<% end %>

<% cache @post.comments do %>
  <div class="comments">
    <%= render @post.comments %>
  </div>
<% end %>
```

**4. Low-Level Caching** – Cache data with `Rails.cache`
```ruby
class Post < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("post_#{id}_calc", expires_in: 1.hour) do
      # Expensive operation
      sleep(5)
      "result"
    end
  end
end

# Usage
post = Post.find(1)
post.expensive_calculation  # First call takes 5s, cached after
post.expensive_calculation  # Second call is instant
```

### 2. How do you use Rails.cache for low-level caching?

**Basic cache operations:**
```ruby
# Store a value
Rails.cache.write("key", "value", expires_in: 1.hour)

# Retrieve a value
Rails.cache.read("key")  # => "value"

# Fetch with fallback (store if not cached)
Rails.cache.fetch("key", expires_in: 1.hour) do
  "expensive operation"
end

# Delete a value
Rails.cache.delete("key")

# Clear all cache
Rails.cache.clear
```

**Common caching patterns:**
```ruby
class Post < ApplicationRecord
  def title_with_comments_count
    Rails.cache.fetch("post_#{id}_title", expires_in: 12.hours) do
      "#{title} (#{comments.count} comments)"
    end
  end

  def expensive_stats
    Rails.cache.fetch("stats_#{id}", expires_in: 1.day) do
      {
        total_views: views.count,
        avg_rating: comments.average(:rating),
        trending_score: calculate_trending_score
      }
    end
  end
end

# Usage
post = Post.find(1)
post.title_with_comments_count  # Cached
post.expensive_stats            # Cached
```

**Cache keys:**
```ruby
# Use objects (auto-generates key)
Rails.cache.fetch(@post) { expensive_op }

# Use strings
Rails.cache.fetch("post:#{@post.id}") { expensive_op }

# Use arrays (joins with slashes)
Rails.cache.fetch(["post", @post.id, "comments"]) { expensive_op }
```

### 3. What are cache stores and how do you configure them?

**Cache stores** are backends for storing cached data.

**Memory Store (default for development):**
```ruby
# config/environments/development.rb
Rails.application.configure do
  config.cache_store = :memory_store
end

# Fast but not shared between processes
```

**File Store:**
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :file_store, "/var/cache/rails"
end

# Persists to disk, shared between processes
```

**Redis Store (recommended for production):**
```ruby
# Gemfile
gem 'redis-rails'

# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :redis_store, "redis://localhost:6379/0"
end

# Fast, shared, persistent
```

**Memcached:**
```ruby
# Gemfile
gem 'dalli'

# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :mem_cache_store, "localhost:11211"
end
```

**Null Store (no caching):**
```ruby
Rails.application.configure do
  config.cache_store = :null_store  # For testing
end
```

### 4. What is cache invalidation and why is it important?

**Cache invalidation** – Removing stale cache when data changes.

**"Cache invalidation is one of the only two hard things in Computer Science"** – Phil Karlton

**Problems:**
```ruby
# Without invalidation: users see stale data
class Post < ApplicationRecord
  def cached_title
    Rails.cache.fetch("post_#{id}_title") do
      "#{title} - v1"
    end
  end
end

post = Post.find(1)
post.cached_title  # => "Post title - v1"

# Update post
post.update(title: "New title")
post.cached_title  # => Still "Post title - v1" (STALE!)
```

**Solution 1: Manual invalidation**
```ruby
class Post < ApplicationRecord
  after_save :invalidate_cache

  private

  def invalidate_cache
    Rails.cache.delete("post_#{id}_title")
    Rails.cache.delete("post_#{id}_stats")
  end
end

post = Post.find(1)
post.update(title: "New title")
post.cached_title  # => "New title" (FRESH)
```

**Solution 2: Time-based expiration**
```ruby
def cached_title
  Rails.cache.fetch("post_#{id}_title", expires_in: 1.hour) do
    "#{title}"
  end
end

# Automatically expires after 1 hour
```

**Solution 3: Touch-based invalidation (for Rails)**
```ruby
class Post < ApplicationRecord
  has_many :comments

  def cache_key
    "#{super}-#{updated_at.to_i}"
  end
end

class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    # Cache key changes when post is updated
  end
end
```

**Solution 4: Dependency-based invalidation**
```ruby
class Post < ApplicationRecord
  after_save :invalidate_user_cache

  private

  def invalidate_user_cache
    Rails.cache.delete("user_#{user_id}_posts")
  end
end
```

### 5. What is HTTP caching and how does it work?

**HTTP caching** – Browser and CDN caching using HTTP headers.

**Cache-Control headers:**
```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    # Cache for 1 hour
    response.headers["Cache-Control"] = "public, max-age=3600"

    # Never cache
    response.headers["Cache-Control"] = "no-cache, no-store"

    # Cache only for current user
    response.headers["Cache-Control"] = "private, max-age=3600"
  end
end
```

**ETag and Last-Modified:**
```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    # Set ETag
    if stale?(@post)
      render :show
    else
      head :not_modified  # 304 - use browser cache
    end
  end
end

# Client sends If-None-Match or If-Modified-Since
# Server responds with 304 Not Modified if not changed
# Browser uses cached version
```

**Fresh/Stale checks:**
```ruby
def show
  @post = Post.find(params[:id])

  # Check if content is fresh or stale
  fresh_when(@post, public: true)

  # Equivalent to:
  # response.headers["ETag"] = @post.cache_key
  # response.headers["Last-Modified"] = @post.updated_at.httpdate
  # response.headers["Cache-Control"] = "public"
end
```

### 6. What are common caching pitfalls and how do you avoid them?

**Pitfall 1: Caching sensitive data**
```ruby
# Bad: cache user-specific data globally
Rails.cache.fetch("user_#{user_id}_data") do
  current_user.private_data
end

# Good: use private cache
response.headers["Cache-Control"] = "private"
```

**Pitfall 2: Stale cache**
```ruby
# Bad: no invalidation
def user_full_name
  Rails.cache.fetch("user_#{id}_name") do
    "#{first_name} #{last_name}"
  end
end

# Good: invalidate on change
after_save :invalidate_name_cache
```

**Pitfall 3: Cache stampede (thundering herd)**
```ruby
# Bad: many processes recalculate at once when cache expires
Rails.cache.fetch("expensive_key", expires_in: 1.hour) do
  expensive_operation
end

# Good: use cache locks
Rails.cache.fetch("expensive_key", expires_in: 1.hour, race_condition_ttl: 5.seconds) do
  expensive_operation
end

# Or add jitter
expires_in = 1.hour + rand(5.minutes)
```

**Pitfall 4: Cache bloat**
```ruby
# Bad: caching too much data
Rails.cache.write(key, large_object)

# Good: cache only what's needed
Rails.cache.write(key, large_object.slice(:id, :name))
```

### 7. How do you debug and monitor caching?

**Monitoring cache hits/misses:**
```ruby
class CacheInstrumentor
  def self.monitor
    ActiveSupport::Notifications.subscribe("cache_read.active_support") do |name, start, finish, id, payload|
      if payload[:hit]
        puts "Cache HIT: #{payload[:key]}"
      else
        puts "Cache MISS: #{payload[:key]}"
      end
    end
  end
end

CacheInstrumentor.monitor
```

**Rails log output:**
```
Cache read: user:1 (2.5ms)
Cache write: post:42 (1.2ms)
Cache delete: post:42:comments
```

**Manual debugging:**
```ruby
# Check cache store
Rails.cache.class  # => Redis::Store

# Check what's cached
Rails.cache.read("key")

# Clear specific cache
Rails.cache.delete_matched("post:*")

# Statistics (Redis)
Rails.cache.stats
```

**New Relic / APM integration:**
```ruby
# Automatically tracks cache performance
# Shows cache hit/miss ratio, latency
```
