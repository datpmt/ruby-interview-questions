# Modules & Mixins — Answers (Intermediate)

### 1. What is a module and what are its main uses?

A **module** is a collection of methods and constants that can be mixed into classes or used as namespaces.

```ruby
module Drawable
  def draw
    puts "Drawing #{self.class.name}"
  end
end

module Movable
  def move(x, y)
    puts "Moving to #{x}, #{y}"
  end
end

class Circle
  include Drawable
  include Movable
end

circle = Circle.new
circle.draw        # => Drawing Circle
circle.move(10, 20) # => Moving to 10, 20
```

**Main uses:**
1. **Mixins** – Share behavior across unrelated classes
2. **Namespacing** – Organize code logically
3. **Constants** – Group related constants

### 2. What is the difference between `include` and `extend`?

**`include`** – Mixes module methods as **instance methods**:

```ruby
module Greeting
  def hello
    "Hello from module"
  end
end

class Person
  include Greeting
end

person = Person.new
person.hello  # => Hello from module
# Person.hello  # Error: undefined method
```

**`extend`** – Mixes module methods as **class methods**:

```ruby
module Greeting
  def hello
    "Hello from module"
  end
end

class Person
  extend Greeting
end

Person.hello  # => Hello from module
# person = Person.new
# person.hello  # Error: undefined method
```

**Comparison table:**

| Syntax | Methods become | Example |
|--------|---|---|
| **`include`** | Instance methods | `obj.method` |
| **`extend`** | Class methods | `Class.method` |
| **`prepend`** | Instance methods (higher priority) | Overrides in method lookup |

**Using both:**
```ruby
module Duckable
  def quack
    puts "Quack!"
  end

  def self.fly
    puts "Flying"
  end
end

class Duck
  include Duckable      # Instance methods
  extend Duckable       # Class methods (also adds self.fly)
end

duck = Duck.new
duck.quack             # => Quack! (from include)
Duck.quack             # => Quack! (from extend)
```

### 3. What is a namespace and how do you use modules for namespacing?

**Namespacing** organizes classes and modules under a module to avoid name collisions.

```ruby
module Animals
  class Dog
    def bark
      puts "Woof"
    end
  end

  class Cat
    def meow
      puts "Meow"
    end
  end
end

dog = Animals::Dog.new
cat = Animals::Cat.new
dog.bark  # => Woof
cat.meow  # => Meow
```

**Nested namespaces:**
```ruby
module Company
  module Departments
    class Engineering
      def build
        puts "Building software"
      end
    end

    class Sales
      def sell
        puts "Selling products"
      end
    end
  end
end

eng = Company::Departments::Engineering.new
eng.build  # => Building software
```

**Namespace constants:**
```ruby
module Config
  API_KEY = "secret123"
  DEBUG = true

  DB = "postgres"
end

puts Config::API_KEY  # => secret123
puts Config::DEBUG    # => true
```

### 4. What are module methods and how do you define them?

**Module methods** are methods on the module itself (not mixed into classes).

```ruby
module Math
  def self.square(x)
    x * x
  end

  def self.cube(x)
    x * x * x
  end
end

Math.square(5)  # => 25
Math.cube(3)    # => 27
```

**Equivalent syntax using `module_function`:**
```ruby
module Math
  def square(x)
    x * x
  end

  module_function :square
end

Math.square(5)  # => 25
```

**Module functions (both instance and module methods):**
```ruby
module Util
  def self.log(msg)
    puts "[LOG] #{msg}"
  end

  def helper_method
    log("Helper called")
  end

  module_function :log
end

# Call as module method
Util.log("Test")

# Call as instance method (if included)
class MyClass
  include Util

  def initialize
    helper_method  # Can call helper_method which calls log
  end
end
```

### 5. How do modules handle the method lookup chain?

Ruby searches for methods in a specific order using the **method resolution order (MRO)**.

```ruby
module A
  def greet
    "From A"
  end
end

module B
  def greet
    "From B"
  end
end

class Dog
  include A
  include B
end

dog = Dog.new
dog.greet  # => From B (last included has priority)
```

**The method lookup order (MRO):**
```ruby
class Dog
  include A
  include B
end

Dog.ancestors
# => [Dog, B, A, Object, Kernel, BasicObject]
# Method search: Dog -> B -> A -> Object -> Kernel -> BasicObject
```

**Using `super` with modules:**
```ruby
module Greeting
  def hello
    "Hello from Greeting"
  end
end

class Person
  include Greeting

  def hello
    super + " and Person"
  end
end

person = Person.new
person.hello  # => Hello from Greeting and Person
```

**Prepending modules (highest priority):**
```ruby
module Logging
  def hello
    puts "Logging: hello called"
    super
  end
end

class Person
  prepend Logging

  def hello
    "Hello"
  end
end

person = Person.new
person.hello
# Output:
# Logging: hello called
# => Hello
```

### 6. What are abstract modules and interfaces in Ruby?

Ruby doesn't have formal interfaces, but modules define contracts.

```ruby
module Drawable
  def draw
    raise NotImplementedError, "Subclasses must implement draw"
  end

  def erase
    raise NotImplementedError, "Subclasses must implement erase"
  end
end

class Circle
  include Drawable

  def draw
    puts "Drawing circle"
  end

  def erase
    puts "Erasing circle"
  end
end

circle = Circle.new
circle.draw    # => Drawing circle
circle.erase   # => Erasing circle
```

**Using `respond_to?` to check for methods:**
```ruby
module Animal
  def speak
    raise NotImplementedError
  end
end

class Dog
  include Animal
  def speak
    "Woof"
  end
end

dog = Dog.new
if dog.respond_to?(:speak)
  puts dog.speak  # => Woof
end
```

### 7. How do you avoid conflicts when using multiple mixins?

Use specific method names and organize hierarchically.

```ruby
module Persistable
  def save
    puts "Saving to database"
  end
end

module Cacheable
  def cache
    puts "Caching object"
  end
end

module Validatable
  def validate
    puts "Validating data"
  end
end

class User
  include Persistable
  include Cacheable
  include Validatable
end

user = User.new
user.save
user.cache
user.validate
```

**Explicit method calls with `super`:**
```ruby
module A
  def process
    "A"
  end
end

module B
  def process
    super + " -> B"
  end
end

class Worker
  include A
  include B

  def process
    super + " -> Worker"
  end
end

worker = Worker.new
worker.process  # => A -> B -> Worker
```

**Aliases for disambiguation:**
```ruby
module HTTPClient
  def get
    "HTTP GET"
  end
end

module FTPClient
  def get
    "FTP GET"
  end
end

class Client
  include HTTPClient
  alias_method :http_get, :get

  include FTPClient
  alias_method :ftp_get, :get
end

client = Client.new
client.http_get  # => HTTP GET
client.ftp_get   # => FTP GET
```
