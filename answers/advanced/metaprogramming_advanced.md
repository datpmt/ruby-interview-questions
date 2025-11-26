# Metaprogramming Advanced — Answers (Advanced)

### 1. What is the Ruby object model and how does it work?

The **Ruby object model** defines how objects, classes, and methods interact.

**Everything is an object:**
```ruby
5.class              # => Integer
"hello".class        # => String
5.methods            # => [:+, :-, :*, ...]
5.object_id          # => unique identifier
```

**Classes are objects:**
```ruby
class Dog
end

Dog.class            # => Class
Dog.object_id        # => unique ID
Dog.methods          # => includes new, allocate, ...
```

**The class hierarchy:**
```ruby
class Dog
end

dog = Dog.new
dog.class            # => Dog
Dog.class            # => Class
Class.class          # => Class
Class.superclass     # => Module
Module.superclass    # => Object
Object.superclass    # => BasicObject
```

**Method lookup chain:**
```ruby
class Animal
  def speak; "sound"; end
end

class Dog < Animal
  def speak; "woof"; end
end

dog = Dog.new
dog.speak  # Finds: Dog#speak

# To see the chain
Dog.ancestors  # => [Dog, Animal, Object, Kernel, BasicObject]
```

### 2. What is `method_missing` advanced usage and where might it cause problems?

**Advanced pattern – dynamic attributes:**
```ruby
class Record
  def initialize(data = {})
    @data = data
  end

  def method_missing(method_name, *args)
    method_str = method_name.to_s

    if method_str.end_with?("=")
      @data[method_str.chomp("=").to_sym] = args[0]
    elsif @data.key?(method_name)
      @data[method_name]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @data.key?(method_name) || super
  end
end

record = Record.new(name: "Alice", age: 30)
record.name      # => Alice
record.age = 31
record.age       # => 31
```

**Problems with `method_missing`:**

1. **Performance**: Called only when method not found (slower than direct methods)
   ```ruby
   # Slow: method_missing called each time
   obj.email
   obj.email = "new@example.com"

   # Better: pre-define methods with define_method
   ```

2. **Introspection breaks**: Methods not found by reflection tools
   ```ruby
   obj.respond_to?(:email)     # => false (if only in method_missing)
   obj.methods.include?(:email) # => false
   ```

3. **Debugging difficulty**: Stack traces are confusing
   ```ruby
   # Hard to trace where the call comes from
   ```

**Better approach – use `define_method`:**
```ruby
# Instead of method_missing for known methods
%i[name age email].each do |attr|
  define_method(attr) { @data[attr] }
  define_method("#{attr}=") { |val| @data[attr] = val }
end
```

### 3. What is `eval` and why is it dangerous?

**`eval`** executes arbitrary Ruby code from a string.

```ruby
code = "1 + 2"
result = eval(code)  # => 3

x = 10
eval("x * 2")        # => 20
```

**Why it's dangerous:**

1. **Security risk – code injection:**
   ```ruby
   # DANGEROUS! Never do this with user input
   user_input = "system('rm -rf /')"  # Malicious input
   eval(user_input)  # Would execute shell command!
   ```

2. **Performance cost – must parse and compile:**
   ```ruby
   # Slow: compiles string every time
   100.times { eval("1 + 1") }
   
   # Better: pre-compile
   code = lambda { 1 + 1 }
   100.times { code.call }
   ```

3. **Scope confusion:**
   ```ruby
   x = 10
   eval("x = 20")     # Modifies outer x
   puts x             # => 20
   ```

**Safer alternatives:**

```ruby
# Use send instead of eval
obj = "hello"
obj.send(:length)  # Safe, controlled

# Use instance_eval/class_eval only with trusted code
obj.instance_eval { @value = 10 }  # Better than eval

# For DSLs, use blocks
class Builder
  def build(&block)
    instance_eval(&block)
  end
end
```

### 4. What is singleton classes and singleton methods?

**Singleton method** – a method that belongs only to a specific object instance.

```ruby
obj = "hello"

# Define a singleton method
def obj.special_greeting
  "I'm special!"
end

obj.special_greeting  # => I'm special!

# Other strings don't have this method
"world".special_greeting  # Error: undefined method
```

**Singleton class** – the class of a specific object.

```ruby
obj = "hello"

class << obj
  def custom_method
    "Custom"
  end
end

obj.custom_method  # => Custom
obj.singleton_class  # => #<Class:#<String:0x...>>
obj.singleton_class.methods  # => includes custom_method
```

**Practical example – decorating objects:**
```ruby
user = User.new("Alice")

# Temporarily add admin behavior
def user.admin_action
  "User can delete everything"
end

user.admin_action  # => User can delete everything

# Other users don't have this
User.new("Bob").admin_action  # Error
```

### 5. What is metaprogramming DSL (Domain Specific Language) and how do you build one?

A **DSL** uses metaprogramming to create readable syntax for a specific domain.

**Example – simple DSL for validation:**
```ruby
class Validator
  def self.validate(&block)
    validator = new
    validator.instance_eval(&block)
    validator
  end

  def required(field)
    puts "Field #{field} is required"
  end

  def length(field, min, max)
    puts "Field #{field} must be #{min}-#{max} chars"
  end
end

# DSL usage – reads like English
Validator.validate do
  required :name
  required :email
  length :password, 8, 128
end

# Output:
# Field name is required
# Field email is required
# Field password must be 8-128 chars
```

**Rails ActiveRecord DSL example (how Rails does it):**
```ruby
# This looks simple but uses metaprogramming behind the scenes
class User < ApplicationRecord
  has_many :posts        # method call that sets up relationships
  validates :email, presence: true  # method that validates
end
```

**Building a more complex DSL:**
```ruby
class APIEndpoint
  def self.define_route(&block)
    endpoint = new
    endpoint.instance_eval(&block)
  end

  def get(path, &block)
    puts "GET #{path}"
    instance_eval(&block)
  end

  def response_fields(&block)
    puts "Response has: #{block.call.join(', ')}"
  end
end

# DSL usage
APIEndpoint.define_route do
  get "/users/:id" do
    response_fields { [:id, :name, :email] }
  end
end

# Output:
# GET /users/:id
# Response has: id, name, email
```

### 6. What is reflection and introspection in Ruby?

**Reflection** – examining and modifying code structure at runtime.

**Common reflection methods:**
```ruby
class Dog
  attr_accessor :name

  def bark
    "Woof"
  end

  private
  def eat
    "Eating"
  end
end

dog = Dog.new

# Object information
dog.class               # => Dog
dog.object_id           # => unique number
dog.instance_variables  # => [:@name]
dog.methods             # => all public methods
dog.private_methods     # => [:eat]
dog.respond_to?(:bark)  # => true

# Class information
Dog.instance_methods    # => all methods on instances
Dog.method_defined?(:bark)  # => true
Dog.ancestors           # => [Dog, Object, Kernel, BasicObject]

# Method information
method = dog.method(:bark)
method.call             # => "Woof"
method.arity            # => number of parameters
```

**Practical example – automatic documentation:**
```ruby
class APIClient
  def get(path); end
  def post(path, data); end
  def delete(id); end
end

client = APIClient.new
client.public_methods.each do |method|
  puts "Public method: #{method}"
end

# Output:
# Public method: get
# Public method: post
# Public method: delete
```

### 7. What are performance considerations with metaprogramming?

**1. Prefer `define_method` over `method_missing` for known methods:**
```ruby
# Slow: method_missing on every call
class DynamicObject
  def method_missing(name, *args)
    @data[name]
  end
end

# Better: pre-define methods
class PreDefinedObject
  def initialize(data)
    @data = data
    @data.keys.each do |key|
      self.class.send(:define_method, key) { @data[key] }
    end
  end
end
```

**2. Cache results of metaprogramming:**
```ruby
# Slow: repeated reflection
class Model
  def initialize(attrs)
    @attrs = attrs
  end

  def valid?
    self.class.validators.each { |v| v.validate(self) }
  end
end

# Better: cache validators at class definition
class Model
  @@validators = []

  def self.add_validator(&block)
    @@validators << block
  end

  def valid?
    @@validators.each { |v| v.call(self) }
  end
end
```

**3. Minimize eval usage – it's slow:**
```ruby
# Very slow
100.times { eval("puts 'hello'") }

# Fast
100.times { puts "hello" }

# Moderate
code = "puts 'hello'"
compiled = eval("Proc.new { #{code} }")
100.times { compiled.call }
```

**Benchmarking metaprogramming:**
```ruby
require 'benchmark'

Benchmark.bm do |x|
  x.report("method_missing") { 100_000.times { obj.dynamic_method } }
  x.report("defined_method")  { 100_000.times { obj.static_method } }
end
```
