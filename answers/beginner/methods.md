# Methods - Questions (Beginner)

### 1. What is a method in Ruby and how do you define one?

**A:** A method is a reusable block of code that performs a specific task. Define it with `def`:

```ruby
def greet(name)
  puts "Hello, #{name}!"
end

greet("Alice")  # => Hello, Alice!
```

---

### 2. What are required, optional (default), and keyword parameters?

**A:** Required parameters must be provided; optional parameters have default values; keyword parameters are named:

```ruby
def describe(name, age = 18, city: "Unknown")
  puts "#{name}, #{age}, from #{city}"
end

describe("Alice")                          # uses defaults
describe("Alice", 30, city: "NYC")        # overrides defaults
```

---

### 3. How do you return a value from a method?

**A:** Use `return` or the implicit last expression:

```ruby
def add(a, b)
  a + b  # implicit return
end

def multiply(a, b)
  return a * b  # explicit return
end
```

---

### 4. What is the difference between a method and a function?

**A:** In Ruby, methods are functions defined on objects or classes. All code is object-oriented; even "top-level" methods are private methods on `Object`:

```ruby
def hello
  "hi"
end

# This method is actually defined on Object
```

---

### 5. What are splat operators and how do you use them?

**A:** Splat operators (`*`) capture multiple arguments into an array:

```ruby
def greet(*names)
  names.each { |name| puts "Hello, #{name}" }
end

greet("Alice", "Bob", "Charlie")
```

---

### 6. How do you define a method that takes a block as an argument?

**A:** Use `yield` or `&block` to accept a block:

```ruby
def repeat(n)
  n.times { yield }  # call the block
end

repeat(3) { puts "Hello" }
```

---

### 7. What is method scope and visibility (public, private, protected)?

**A:** Methods have visibility levels:
- **public**: accessible from anywhere (default)
- **private**: accessible only within the class (not even with `self`)
- **protected**: accessible within the class and subclasses

```ruby
class MyClass
  def public_method
    "public"
  end

  private
  def private_method
    "private"
  end
end
```
