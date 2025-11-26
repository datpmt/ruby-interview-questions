# Testing in Rails — Answers (Rails)

### 1. What are the different types of tests in Rails?

**Unit tests** – Test individual classes/methods in isolation:
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe "#valid_email?" do
    it "returns true for valid emails" do
      user = User.new(email: "test@example.com")
      expect(user.valid_email?).to be true
    end

    it "returns false for invalid emails" do
      user = User.new(email: "invalid")
      expect(user.valid_email?).to be false
    end
  end
end
```

**Integration tests** – Test how multiple components work together:
```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  describe "GET /posts/:id" do
    it "returns the post" do
      post = create(:post)
      get "/posts/#{post.id}"
      expect(response).to be_successful
      expect(response.body).to include(post.title)
    end
  end
end
```

**System tests** – Test entire user workflows in a browser:
```ruby
# spec/system/user_creates_post_spec.rb
RSpec.describe "User creates post", type: :system do
  it "allows user to create a post" do
    user = create(:user)
    login_as(user)

    visit "/posts/new"
    fill_in "Title", with: "My Post"
    click_button "Create"

    expect(page).to have_content("Post created")
    expect(Post.last.title).to eq("My Post")
  end
end
```

**Types summary:**
| Type | Speed | Cost | Use Case |
|------|-------|------|----------|
| **Unit** | Fast | Low | Single methods |
| **Integration** | Medium | Medium | API endpoints |
| **System** | Slow | High | User workflows |

### 2. What is the difference between RSpec and Minitest?

**RSpec** – DSL-based, expressive syntax:
```ruby
describe User do
  context "with valid attributes" do
    it "creates a user" do
      expect {
        User.create(email: "test@example.com")
      }.to change(User, :count).by(1)
    end
  end
end
```

**Minitest** – Assertion-based, closer to stdlib:
```ruby
class UserTest < Minitest::Test
  def test_creates_user
    assert_difference 'User.count', 1 do
      User.create(email: "test@example.com")
    end
  end
end
```

**Comparison:**

| Feature | RSpec | Minitest |
|---------|-------|----------|
| **Syntax** | DSL (`describe`, `it`) | Methods (`def test_`) |
| **Readability** | More readable, closer to English | More like Ruby |
| **Performance** | Slightly slower | Slightly faster |
| **Learning curve** | Steeper | Easier |
| **Community** | Large (Rails default) | Smaller |

**When to use:**
- **RSpec**: When readability and expressiveness matter
- **Minitest**: When simplicity and speed matter

### 3. How do you write model tests?

**Model test structure:**
```ruby
# spec/models/post_spec.rb
RSpec.describe Post, type: :model do
  # Test validations
  describe "validations" do
    it "validates presence of title" do
      post = Post.new(title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it "validates presence of content" do
      post = Post.new(content: nil)
      expect(post).not_to be_valid
    end
  end

  # Test associations
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end

    it "has many comments" do
      post = create(:post)
      comment1 = create(:comment, post: post)
      comment2 = create(:comment, post: post)
      expect(post.comments).to include(comment1, comment2)
    end
  end

  # Test methods
  describe "#published?" do
    it "returns true if published" do
      post = Post.new(published: true)
      expect(post.published?).to be true
    end

    it "returns false if not published" do
      post = Post.new(published: false)
      expect(post.published?).to be false
    end
  end

  # Test scopes
  describe ".published" do
    it "returns only published posts" do
      published_post = create(:post, published: true)
      draft_post = create(:post, published: false)
      expect(Post.published).to include(published_post)
      expect(Post.published).not_to include(draft_post)
    end
  end

  # Test callbacks
  describe "before_save callbacks" do
    it "slugifies title" do
      post = Post.new(title: "Hello World")
      post.save
      expect(post.slug).to eq("hello-world")
    end
  end
end
```

### 4. How do you write controller tests?

**Controller test structure:**
```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns all posts" do
      post1 = create(:post)
      post2 = create(:post)

      get "/posts"

      expect(response).to be_successful
      expect(response.body).to include(post1.title)
      expect(response.body).to include(post2.title)
    end
  end

  describe "GET /posts/:id" do
    it "returns the post" do
      post = create(:post)
      get "/posts/#{post.id}"

      expect(response).to be_successful
      expect(response.body).to include(post.title)
    end

    it "returns 404 for missing post" do
      get "/posts/999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /posts" do
    it "creates a post" do
      expect {
        post "/posts", params: {
          post: { title: "New Post", content: "Content" }
        }
      }.to change(Post, :count).by(1)
    end

    it "renders errors for invalid post" do
      post "/posts", params: { post: { title: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /posts/:id" do
    it "deletes the post" do
      post = create(:post)
      expect {
        delete "/posts/#{post.id}"
      }.to change(Post, :count).by(-1)
    end
  end
end
```

### 5. How do you write feature/system tests?

**System test with Capybara:**
```ruby
# spec/system/user_flow_spec.rb
RSpec.describe "User creates and publishes a post", type: :system do
  it "allows user to create and publish a post" do
    # 1. User visits site
    visit root_path
    expect(page).to have_content("Welcome")

    # 2. User clicks "New Post"
    click_link "New Post"
    expect(page).to have_content("Create Post")

    # 3. User fills in form
    fill_in "Title", with: "My First Post"
    fill_in "Content", with: "This is great content"

    # 4. User submits
    click_button "Create"

    # 5. Post is created and user sees it
    expect(page).to have_content("My First Post")
    expect(Post.last.title).to eq("My First Post")
  end
end
```

**Common Capybara methods:**
```ruby
# Navigation
visit "/posts"
click_link "Post title"
click_button "Submit"

# Forms
fill_in "Email", with: "test@example.com"
select "Published", from: "Status"
check "Subscribe"
uncheck "Unsubscribe"

# Assertions
expect(page).to have_content("text")
expect(page).to have_css(".class")
expect(page).to have_link("Link text")
expect(page).to have_button("Button")
expect(page).not_to have_content("text")
```

### 6. How do you use factories for test data?

**Factory Bot setup:**
```ruby
# spec/factories/user_factory.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    created_at { Time.current }
  end
end

# spec/factories/post_factory.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    user { association :user }
  end
end
```

**Using factories in tests:**
```ruby
# Create one instance
user = create(:user)

# Create multiple
users = create_list(:user, 3)

# Build (don't save)
user = build(:user)

# Create with attributes
post = create(:post, title: "Custom Title", published: true)

# Create with associations
comment = create(:comment, post: post, user: user)
```

### 7. What are best practices for Rails testing?

**1. Test behavior, not implementation**
```ruby
# Bad: testing private methods
expect(user.send(:normalize_email)).to eq("test@example.com")

# Good: test public behavior
user.email = "TEST@EXAMPLE.COM"
user.save
expect(user.reload.email).to eq("test@example.com")
```

**2. Keep tests focused**
```ruby
# Bad: test too much in one test
it "creates user and sends email and logs event" do
  # 3 things being tested
end

# Good: one assertion per test
it "creates a user" do
  expect { create(:user) }.to change(User, :count).by(1)
end

it "sends welcome email" do
  expect { create(:user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
end
```

**3. Use appropriate test types**
```ruby
# Bad: system test for simple behavior
it "validates email" do
  visit "/users/new"
  fill_in "Email", with: "invalid"
  # Too slow for simple validation
end

# Good: model test
it "validates email" do
  user = User.new(email: "invalid")
  expect(user).not_to be_valid
end
```

**4. Mock external dependencies**
```ruby
# Bad: actually calls external API in tests
it "syncs with payment provider" do
  PaymentAPI.sync(user)
  # Slow, brittle, flaky
end

# Good: mock the API
it "syncs with payment provider" do
  allow(PaymentAPI).to receive(:sync).and_return(true)
  PaymentAPI.sync(user)
  expect(PaymentAPI).to have_received(:sync).with(user)
end
```

**5. Use descriptive test names**
```ruby
# Bad: unclear
it "works" do
end

# Good: describes behavior
it "returns error when email is blank" do
end

it "sends welcome email to new users" do
end
```

**6. Setup and teardown properly**
```ruby
describe User do
  before do
    @user = create(:user)  # Run before each test
  end

  after do
    @user.destroy  # Run after each test (usually not needed)
  end

  it "has email" do
    expect(@user.email).to be_present
  end
end
```
