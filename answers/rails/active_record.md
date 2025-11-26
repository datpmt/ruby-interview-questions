# ActiveRecord — Answers (Rails)

### 1. What is ActiveRecord and how do you define models?

**ActiveRecord** is an ORM (Object-Relational Mapping) that maps database tables to Ruby classes.

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  # ActiveRecord automatically maps to 'posts' table
end

# Usage
post = Post.new(title: "Hello")  # Create instance
post.save                         # Save to database
```

**Database schema:**
```ruby
# db/migrate/20240101_create_posts.rb
create_table :posts do |t|
  t.string :title
  t.text :content
  t.references :user
  t.timestamps
end
```

**ActiveRecord model:**
```ruby
class Post < ApplicationRecord
  belongs_to :user
  has_many :comments

  validates :title, presence: true
  validates :content, length: { minimum: 10 }
end
```

### 2. What are associations and how do you define them?

**Associations** define relationships between models.

**`belongs_to` – many to one:**
```ruby
class Post < ApplicationRecord
  belongs_to :user  # Post has one User
end

# Usage
post = Post.find(1)
post.user  # Get associated user
```

**`has_many` – one to many:**
```ruby
class User < ApplicationRecord
  has_many :posts  # User has many Posts
end

# Usage
user = User.find(1)
user.posts          # Get all posts
user.posts.create(title: "New Post")
user.posts.count    # => 5
```

**`has_many through` – many to many:**
```ruby
class User < ApplicationRecord
  has_many :enrollments
  has_many :courses, through: :enrollments
end

class Course < ApplicationRecord
  has_many :enrollments
  has_many :users, through: :enrollments
end

class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
end

# Usage
user = User.find(1)
user.courses  # Get all courses for user
```

**`has_one` – one to one:**
```ruby
class User < ApplicationRecord
  has_one :profile
end

class Profile < ApplicationRecord
  belongs_to :user
end

# Usage
user = User.find(1)
user.profile  # Get the one profile
```

### 3. What are validations and how do you use them?

**Validations** ensure data integrity before saving.

```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
  validates :age, numericality: { greater_than: 0, less_than: 150 }
  validates :name, presence: true
end

# Usage
user = User.new(email: "")
user.valid?         # => false
user.errors.full_messages  # => ["Email can't be blank"]
```

**Common validators:**
```ruby
validates :name, presence: true                    # Must be present
validates :email, uniqueness: true                 # Must be unique
validates :password, length: { minimum: 8 }       # Length check
validates :age, numericality: { only_integer: true }  # Must be integer
validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }  # Format
validates :status, inclusion: { in: %w[active inactive] }  # Must be in list
validates :terms, acceptance: true                 # Must be accepted (checkbox)
```

**Custom validators:**
```ruby
class User < ApplicationRecord
  validate :email_domain_valid

  private

  def email_domain_valid
    if email && !email.include?("@")
      errors.add(:email, "must have @")
    end
  end
end
```

### 4. What are scopes and how do you use them?

**Scopes** are reusable query filters.

```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
end

# Usage
Post.published                      # Only published posts
Post.published.recent               # Published, ordered by recent
Post.by_user(5)                     # Posts by user 5
Post.published.recent.by_user(5)    # Chain scopes
```

**Class methods vs scopes:**
```ruby
class Post < ApplicationRecord
  # Scope: returns ActiveRecord relation (chainable)
  scope :published, -> { where(published: true) }

  # Class method: equivalent to scope
  def self.published
    where(published: true)
  end

  # Class method with logic
  def self.recent_published
    published.order(created_at: :desc)
  end
end

# Both are chainable
Post.published.recent_published
```

### 5. What are N+1 queries and how do you optimize them?

**N+1 problem** – loading related data one at a time instead of in bulk.

**Bad (N+1 queries):**
```ruby
@posts = Post.all  # 1 query
@posts.each do |post|
  puts post.user.name  # N queries (1 per post)
end
# Total: 1 + N queries
```

**Solution 1: eager load with `includes`:**
```ruby
@posts = Post.includes(:user).all  # 2 queries (posts + users)
@posts.each do |post|
  puts post.user.name  # No additional queries
end
```

**Solution 2: use `joins`:**
```ruby
@posts = Post.joins(:user).all  # Joins tables
```

**Solution 3: use `preload` or `eager_load`:**
```ruby
# preload - separate queries (faster)
Post.preload(:user).all

# eager_load - single query with joins
Post.eager_load(:user).all
```

**For nested associations:**
```ruby
# Load posts, users, and user avatars
Post.includes(user: :avatar).all
```

### 6. What is a scope and how does it relate to the Active Record chain?

**Scopes** return `ActiveRecord::Relation` objects, allowing method chaining.

```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
end

# Chain scopes
Post.published
     .featured
     .recent
     .limit(10)
     # Builds single query:
     # SELECT * FROM posts WHERE published=true AND featured=true
     # ORDER BY created_at DESC LIMIT 10
```

**Lazy evaluation:**
```ruby
# Query not executed until you access data
scope = Post.published.recent

# Executed when:
scope.each { |p| puts p }     # Iterate
scope.first                    # Get first
scope.count                    # Count
scope.pluck(:title)           # Get titles
```

### 7. What are callbacks and when should you use them?

**Callbacks** execute code at specific lifecycle events.

```ruby
class Post < ApplicationRecord
  before_save :slugify_title
  after_save :invalidate_cache
  before_destroy :archive_content

  private

  def slugify_title
    self.slug = title.downcase.gsub(" ", "-")
  end

  def invalidate_cache
    Rails.cache.delete("posts")
  end

  def archive_content
    Archive.create(content: content)
  end
end
```

**Lifecycle callbacks:**
```ruby
# Creating a new record
before_validation
after_validation
before_save
after_save
after_commit

# Updating existing record
before_validation
after_validation
before_save
after_save
after_commit

# Destroying
before_destroy
after_destroy
after_commit
```

**When to use callbacks:**
```ruby
# ✓ Good: data normalization
before_save :downcase_email

# ✓ Good: logging/audit
after_save :log_changes

# ✗ Bad: complex business logic (use service objects)
# ✗ Bad: calling external APIs (use jobs)
# ✗ Bad: multiple responsibilities (should be simpler)
```

**Callback conditions:**
```ruby
class Post < ApplicationRecord
  before_save :notify_user, if: :published_changed?
  before_save :slugify, unless: :slug_present?

  private

  def published_changed?
    saved_change_to_published?
  end

  def slug_present?
    slug.present?
  end
end
```

**Halting callbacks:**
```ruby
class Post < ApplicationRecord
  before_save :validate_custom

  private

  def validate_custom
    throw :abort if some_condition  # Prevent save
  end
end
```
