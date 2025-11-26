# Rails MVC — Answers (Rails)

### 1. Explain the MVC pattern in Rails and how it works.

**MVC (Model-View-Controller)** separates concerns into three layers:

- **Model** – Business logic and data (ActiveRecord)
- **View** – User interface (HTML, templates)
- **Controller** – Handles requests and coordinates M and V

**Request flow:**
```
1. Request -> Router
2. Router -> Controller#action
3. Controller -> Model (fetch/update data)
4. Controller -> View (pass data)
5. View -> Response (render HTML)
```

**Example:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])  # Model: fetch data
  end
end

# app/views/posts/show.html.erb
<h1><%= @post.title %></h1>
<p><%= @post.content %></p>
```

**Request cycle:**
1. User requests `/posts/5`
2. Router maps to `PostsController#show`
3. Controller fetches `Post` with id=5
4. View renders HTML with post data
5. Response sent to browser

### 2. What is the role of the Controller in Rails?

The **Controller** receives HTTP requests, processes them, and returns responses.

**Main responsibilities:**
```ruby
class PostsController < ApplicationController
  # 1. GET /posts - list all
  def index
    @posts = Post.all
    render :index
  end

  # 2. GET /posts/5 - show one
  def show
    @post = Post.find(params[:id])
  end

  # 3. GET /posts/new - form for creating
  def new
    @post = Post.new
  end

  # 4. POST /posts - create
  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  # 5. GET /posts/5/edit - form for updating
  def edit
    @post = Post.find(params[:id])
  end

  # 6. PATCH /posts/5 - update
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  # 7. DELETE /posts/5 - destroy
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
```

**Key concepts:**
- **Actions** – Methods that handle requests
- **Request parameters** – `params` hash
- **Instance variables** – Passed to views (e.g., `@post`)
- **Rendering** – Return HTML, JSON, etc.
- **Redirecting** – Send user to different URL
- **Filters** – `before_action`, `after_action`

### 3. What is the role of Views in Rails?

**Views** render the user interface, typically HTML.

```erb
<!-- app/views/posts/show.html.erb -->
<h1><%= @post.title %></h1>
<p><%= @post.content %></p>
<p>By <%= @post.author.name %></p>

<% if @post.published? %>
  <span>Published</span>
<% end %>

<%= link_to "Edit", edit_post_path(@post) %>
<%= link_to "Delete", post_path(@post), method: :delete %>
```

**View responsibilities:**
- Present data to user
- Use ERB templates (embedded Ruby)
- Use Rails helpers
- Don't contain business logic

**Rails helpers:**
```erb
<!-- Link helper -->
<%= link_to "Edit", edit_post_path(@post) %>

<!-- Form helper -->
<%= form_with(model: @post) do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>

<!-- Conditional rendering -->
<% if @post.published? %>
  <p>This post is published</p>
<% end %>
```

### 4. How is the flow from a User request to Response in Rails?

**Complete request-response cycle:**

```
1. Browser sends HTTP request: GET /posts/5

2. Routing (config/routes.rb)
   Rails router matches to: PostsController#show with id=5

3. Controller (app/controllers/posts_controller.rb)
   - Instantiate controller
   - Run before_action filters
   - Call show action
   - Find Post in database
   - Set @post instance variable

4. View (app/views/posts/show.html.erb)
   - Access @post instance variable
   - Render HTML template
   - Evaluate ERB tags

5. Response
   - Return HTML with 200 OK status
   - Browser renders HTML

6. User sees web page
```

**Example with parameters:**
```ruby
# Route: POST /posts
# Request: POST /posts?title=Hello&content=Test

class PostsController < ApplicationController
  def create
    puts params  # { "title" => "Hello", "content" => "Test", ... }
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post  # Redirect to /posts/1
    else
      render :new       # Show form again with errors
    end
  end
end
```

### 5. What are filters and how do you use them?

**Filters** (callbacks) run before, after, or around actions.

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post, only: [:show, :edit, :update, :destroy]
  after_action :log_activity

  def show
    # find_post already ran
  end

  private

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def find_post
    @post = Post.find(params[:id])
  end

  def log_activity
    puts "Action #{action_name} completed"
  end
end
```

**Filter types:**
```ruby
# before_action - run before action
before_action :authenticate_user!

# after_action - run after action (before render)
after_action :log_activity

# around_action - wraps the action
around_action :with_timing

def with_timing
  start = Time.now
  yield  # Run the action
  puts "Took #{Time.now - start} seconds"
end

# Skip filters in specific actions
before_action :authenticate!, except: [:index, :show]
```

### 6. What is REST and how does Rails implement it?

**REST (Representational State Transfer)** uses HTTP methods to represent operations.

**REST conventions:**
```ruby
# config/routes.rb
resources :posts  # Generates 7 routes

# Routes generated:
GET    /posts            -> posts#index   (list all)
GET    /posts/new        -> posts#new     (form for new)
POST   /posts            -> posts#create  (create)
GET    /posts/:id        -> posts#show    (show one)
GET    /posts/:id/edit   -> posts#edit    (form for edit)
PATCH  /posts/:id        -> posts#update  (update)
DELETE /posts/:id        -> posts#destroy (delete)
```

**RESTful controller:**
```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.create(post_params)
    redirect_to @post
  end

  def destroy
    Post.find(params[:id]).destroy
    redirect_to posts_path
  end

  # ... other actions
end
```

**Links using REST helpers:**
```erb
<%= link_to "Show", post_path(@post) %>
<%= link_to "Edit", edit_post_path(@post) %>
<%= link_to "Delete", post_path(@post), method: :delete %>
```

### 7. What's the difference between rendering and redirecting?

**Rendering** – Display template without changing URL.
```ruby
def show
  @post = Post.find(params[:id])
  render :show  # Display show.html.erb template
  # URL stays as /posts/5
end
```

**Redirecting** – Send browser to new URL (new request).
```ruby
def create
  @post = Post.new(post_params)
  if @post.save
    redirect_to @post  # Browser makes new GET request to /posts/1
  else
    render :new        # Display form again (not a redirect)
  end
end
```

**Comparison:**
```
Render:
  Controller -> View -> Response (same URL)

Redirect:
  Controller -> Response (new URL)
  Browser -> New Request -> New Controller Action
```

**Common patterns:**
```ruby
def update
  @post = Post.find(params[:id])
  if @post.update(post_params)
    redirect_to @post, notice: "Updated!"  # New request
  else
    render :edit                            # Same request
  end
end
```
