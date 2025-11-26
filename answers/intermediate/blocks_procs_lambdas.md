# Blocks, Procs & Lambdas — Answers (Intermediate)

### 1. What is a block in Ruby and how does it differ from a method?

A **block** is an anonymous chunk of code that can be passed to a method. It's not an object itself.

```ruby
# Block passed to each
[1, 2, 3].each { |x| puts x }

# Block passed to map
numbers = [1, 2, 3].map { |x| x * 2 }

# Method definition for comparison
def my_method
  puts "I'm a method"
end
```

**Key differences:**

| Feature | Block | Method |
|---------|-------|--------|
| **Object?** | No (not an object) | Yes (object) |
| **Pass to method?** | Yes, implicitly | No, must convert to Proc/Lambda |
| **Call syntax** | Via `yield` | Via method name |
| **Return behavior** | Returns from enclosing method | Returns from method |
| **Can store?** | No | Yes (as method object) |

### 2. What is a Proc and how do you create one?

A **Proc** is an object that wraps a block. You can create, store, and call Procs.

```ruby
# Create with Proc.new
my_proc = Proc.new { |x| x * 2 }
my_proc.call(5)        # => 10
my_proc[3]             # => 6 (alternative call syntax)

# Create with proc (lowercase)
my_proc = proc { |x| x * 2 }

# Create with -> (stabby lambda syntax)
my_proc = ->(x) { x * 2 }

# Store and reuse
multiply_by_two = Proc.new { |x| x * 2 }
[1, 2, 3].map(&multiply_by_two)  # => [2, 4, 6]
```

**Proc characteristics:**
- Returns from the enclosing method (not just the Proc)
- Lenient with argument count (missing args become nil, extras ignored)
- Mutable (can be modified)

```ruby
def test_proc_return
  my_proc = Proc.new { return "Returned from Proc" }
  my_proc.call
  puts "This line never executes"
end

test_proc_return  # => "Returned from Proc"
```

### 3. What is a Lambda and how does it differ from a Proc?

A **Lambda** is a stricter version of a Proc. It's a Proc object but with different behavior.

```ruby
# Create lambda with -> (preferred)
my_lambda = ->(x) { x * 2 }
my_lambda.call(5)  # => 10

# Create with lambda keyword
my_lambda = lambda { |x| x * 2 }

# Create with Lambda.new (rarely used)
my_lambda = Lambda.new { |x| x * 2 }
```

**Lambda vs Proc comparison:**

| Behavior | Lambda | Proc |
|----------|--------|------|
| **Argument checking** | Strict (raises error) | Lenient (nil or ignore) |
| **Return** | Returns to caller | Returns from enclosing method |
| **Syntax** | `->` or `lambda` | `Proc.new` or `proc` |

**Argument checking example:**
```ruby
my_lambda = ->(x, y) { x + y }
my_lambda.call(1, 2)      # => 3
my_lambda.call(1)         # Error: wrong number of arguments

my_proc = Proc.new { |x, y| x + y }
my_proc.call(1, 2)        # => 3
my_proc.call(1)           # => nil + 2 => Error (nil coercion)
my_proc.call(1, 2, 3)     # => 3 (extra arg ignored)
```

**Return behavior example:**
```ruby
def test_lambda_return
  my_lambda = ->(x) { return x * 2 }
  result = my_lambda.call(5)
  puts "Lambda returned: #{result}"
  puts "Method continues"
end

test_lambda_return
# Output:
# Lambda returned: 10
# Method continues

def test_proc_return
  my_proc = Proc.new { return 5 * 2 }
  result = my_proc.call
  puts "This never prints"
end

test_proc_return  # => 10 (method exits)
```

### 4. When should you use a block, Proc, or Lambda?

**Use a block when:**
- You want to pass simple code to a method
- The block is one-time use (not stored)

```ruby
[1, 2, 3].each { |x| puts x }
result = [1, 2, 3].map { |x| x * 2 }
```

**Use a Proc when:**
- You need to store behavior and call it multiple times
- You want lenient argument handling
- You plan to pass it around

```ruby
greet = Proc.new { |name| puts "Hello, #{name}" }
greet.call("Alice")  # => Hello, Alice
greet.call("Bob")    # => Hello, Bob
```

**Use a Lambda when:**
- You want strict argument checking (like methods)
- You want predictable return behavior
- You're defining a small reusable function

```ruby
add = ->(x, y) { x + y }
add.call(1, 2)       # => 3
add.call(1)          # Error (strict checking)
```

**Best practice:** Prefer lambdas for clarity and correctness.

### 5. How do you pass a block to a method?

Blocks are captured in methods using the `yield` keyword or the `&block` parameter.

**Using `yield`:**
```ruby
def greet
  yield("World")
end

greet { |name| puts "Hello, #{name}" }  # => Hello, World
```

**Using `&block` parameter:**
```ruby
def greet(&block)
  block.call("World")
end

greet { |name| puts "Hello, #{name}" }  # => Hello, World
```

**Checking if a block is given:**
```ruby
def greet
  if block_given?
    yield
  else
    puts "No block given"
  end
end

greet                           # => No block given
greet { puts "Block given!" }   # => Block given!
```

**Converting between blocks and Procs:**
```ruby
def process(&block)
  # block is now a Proc object
  [1, 2, 3].each(&block)
end

process { |x| puts x }  # => 1, 2, 3
```

### 6. What is closure in Ruby and how does it relate to blocks/Procs/Lambdas?

A **closure** captures variables from the enclosing scope and can access them later.

```ruby
# Closure example
def make_multiplier(n)
  lambda { |x| x * n }  # Captures n from enclosing scope
end

times_two = make_multiplier(2)
times_three = make_multiplier(3)

times_two.call(5)    # => 10
times_three.call(5)  # => 15
```

**Blocks, Procs, and Lambdas are all closures:**
```ruby
counter = 0

increment = lambda do
  counter += 1  # Captures and modifies counter from outer scope
end

increment.call  # counter => 1
increment.call  # counter => 2
puts counter    # => 2 (changed by lambda)
```

**Closure example with class:**
```ruby
class Counter
  def initialize
    @count = 0
  end

  def incrementer
    ->(n = 1) { @count += n; @count }
  end
end

counter = Counter.new
inc = counter.incrementer
inc.call      # => 1
inc.call(5)   # => 6
```

### 7. What is the `&` operator and how does it relate to Procs?

The `&` operator converts between blocks and Procs.

**Converting a block to a Proc parameter:**
```ruby
def method_with_proc(&my_proc)
  # &my_proc captures the block as a Proc
  my_proc.call(42)
end

method_with_proc { |x| puts x }  # => 42
```

**Converting a Proc to a block:**
```ruby
my_proc = Proc.new { |x| x * 2 }

[1, 2, 3].map(&my_proc)  # => [2, 4, 6]
# & converts Proc to block
```

**Converting between Proc and block in methods:**
```ruby
def call_twice(&block)
  block.call
  block.call
end

my_proc = ->(){ puts "Hello" }
call_twice(&my_proc)
# Output:
# Hello
# Hello
```

**Practical example:**
```ruby
def with_logging(&block)
  puts "Starting"
  block.call
  puts "Done"
end

# Pass a lambda as a block
greeter = ->(){ puts "I'm running!" }
with_logging(&greeter)
# Output:
# Starting
# I'm running!
# Done
```
