# Metaprogramming Basics — Answers (Intermediate)

### 1. What is metaprogramming and why would you use it?

**Metaprogramming** is writing code that writes or modifies code at runtime. It lets you reduce boilerplate and add dynamic behavior.

```ruby
# Simple metaprogramming example
class User
  # Instead of writing getters/setters, we generate them
  attr_accessor :name, :email, :age
end

user = User.new
user.name = "Alice"
puts user.name  # => Alice

# Without metaprogramming, you'd write:
# def name; @name; end
# def name=(val); @name = val; end
# ... repeated for email and age
```

**Use cases:**
- Remove boilerplate code
- Generate methods dynamically
- Add behavior to classes conditionally
- Create DSLs (Domain Specific Languages)

### 2. What is `method_missing` and how do you use it?

**`method_missing`** is called when you call a method that doesn't exist. You can define it to handle undefined methods.

```ruby
class DynamicObject
  def method_missing(method_name, *args)
    "You called #{method_name} with args: #{args.inspect}"
  end
end

obj = DynamicObject.new
obj.hello(1, 2)         # => You called hello with args: [1, 2]
obj.goodbye("world")    # => You called goodbye with args: ["world"]
```

**Practical example – lazy attribute storage:**
```ruby
class OpenStruct
  def initialize
    @table = {}
  end

  def method_missing(method_name, *args)
    if method_name.to_s.end_with?("=")
      # Setter: obj.name = "Alice"
      @table[method_name.to_s[0..-2].to_sym] = args[0]
    else
      # Getter: obj.name
      @table[method_name]
    end
  end
end

obj = OpenStruct.new
obj.name = "Alice"
obj.age = 30
puts obj.name  # => Alice
puts obj.age   # => 30
```

**Override `respond_to_missing?` for introspection:**
```ruby
class DynamicObject
  def method_missing(method_name, *args)
    "Called #{method_name}"
  end

  def respond_to_missing?(method_name, include_private = false)
    true  # This object responds to any method
  end
end

obj = DynamicObject.new
obj.respond_to?(:any_method)  # => true
```

### 3. What is `define_method` and how do you use it?

**`define_method`** creates methods dynamically at runtime.

```ruby
class Calculator
  [:add, :subtract, :multiply].each do |operation|
    define_method(operation) do |a, b|
      case operation
      when :add
        a + b
      when :subtract
        a - b
      when :multiply
        a * b
      end
    end
  end
end

calc = Calculator.new
calc.add(5, 3)       # => 8
calc.subtract(5, 3)  # => 2
calc.multiply(5, 3)  # => 15
```

**Generate getters and setters:**
```ruby
class Person
  attr_names = [:name, :age, :email]

  attr_names.each do |attr|
    define_method(attr) do
      instance_variable_get("@#{attr}")
    end

    define_method("#{attr}=") do |value|
      instance_variable_set("@#{attr}", value)
    end
  end
end

person = Person.new
person.name = "Alice"
person.age = 30
puts person.name  # => Alice
```

**Dynamic method with parameters:**
```ruby
class Validator
  %i[email phone zip_code].each do |field|
    define_method("validate_#{field}") do |value|
      # Validation logic
      puts "Validating #{field}: #{value}"
    end
  end
end

validator = Validator.new
validator.validate_email("test@example.com")
validator.validate_phone("555-1234")
```

### 4. What is `class_eval` and when would you use it?

**`class_eval`** evaluates a string or block in the context of a class, letting you modify the class dynamically.

```ruby
class Dog
end

# Add methods to Dog using class_eval
Dog.class_eval do
  def bark
    "Woof!"
  end

  def sit
    "Sitting"
  end
end

dog = Dog.new
dog.bark  # => Woof!
dog.sit   # => Sitting
```

**Using class_eval with strings:**
```ruby
class Person
end

Person.class_eval %{
  def introduce
    "Hello, I'm a person"
  end
}

person = Person.new
person.introduce  # => Hello, I'm a person
```

**Dynamically add class methods:**
```ruby
class Product
end

Product.class_eval do
  def self.available
    "Products in stock"
  end
end

Product.available  # => Products in stock
```

**Modify existing classes:**
```ruby
String.class_eval do
  def reverse_upcase
    self.reverse.upcase
  end
end

"hello".reverse_upcase  # => OLLEH
```

### 5. What is `instance_eval` and how does it differ from `class_eval`?

**`instance_eval`** evaluates code in the context of a specific instance (changes `self` to the object).

```ruby
class Dog
  def initialize(name)
    @name = name
  end
end

dog = Dog.new("Rex")

# instance_eval
dog.instance_eval do
  puts "My name is #{@name}"
  def extra_method
    "Added to this instance only"
  end
end

dog.extra_method  # => Added to this instance only

# This method is NOT on the class
Dog.new("Buddy").respond_to?(:extra_method)  # => false
```

**Comparison:**

| Method | Context | Example |
|--------|---------|---------|
| **`class_eval`** | Class | Affects all instances |
| **`instance_eval`** | Instance | Affects only that instance |

**instance_eval examples:**
```ruby
obj = "hello"

obj.instance_eval do
  # self is now obj
  def custom_method
    "Custom method on #{self}"
  end
end

obj.custom_method  # => Custom method on hello
```

### 6. What are `send` and `public_send` and how are they different?

**`send`** calls a method dynamically using a symbol or string.

```ruby
class Greeting
  def hello
    "Hello!"
  end

  def private_method
    "Private"
  end

  private :private_method
end

obj = Greeting.new
obj.send(:hello)  # => Hello!
obj.send("hello") # => Hello!
```

**`public_send`** only calls public methods (safer).

```ruby
obj = Greeting.new
obj.public_send(:hello)         # => Hello!
obj.public_send(:private_method) # Error: private method
```

**Dynamic method calling:**
```ruby
class Calculator
  def add(a, b); a + b; end
  def subtract(a, b); a - b; end
  def multiply(a, b); a * b; end
end

calc = Calculator.new
operation = :add
result = calc.send(operation, 5, 3)  # => 8

# Dynamic based on user input
operation = params[:operation].to_sym  # :multiply
calc.send(operation, 10, 2)  # => 20
```

**Introspection with send:**
```ruby
obj = "hello"
puts obj.send(:length)      # => 5
puts obj.send(:upcase)      # => HELLO
puts obj.send(:include?, "ll")  # => true
```

### 7. What are common metaprogramming patterns?

**Pattern 1: Aliasing methods**
```ruby
class String
  alias_method :original_reverse, :reverse

  def reverse
    result = original_reverse
    puts "Reversing: #{self}"
    result
  end
end

"hello".reverse  # => Prints "Reversing: hello", returns "olleh"
```

**Pattern 2: Delegating methods**
```ruby
class Manager
  def initialize(assistant)
    @assistant = assistant
  end

  def delegate(*methods)
    methods.each do |method|
      define_method(method) do
        @assistant.send(method)
      end
    end
  end

  delegate :write, :read
end

class Assistant
  def write; "Writing..."; end
  def read; "Reading..."; end
end

manager = Manager.new(Assistant.new)
manager.write  # => Writing...
```

**Pattern 3: Before/After hooks**
```ruby
class Logger
  def self.log_calls(method_name)
    original = instance_method(method_name)

    define_method(method_name) do |*args|
      puts "Before: calling #{method_name}"
      result = original.bind(self).call(*args)
      puts "After: #{method_name} returned #{result}"
      result
    end
  end
end

class API
  def fetch_data
    "Data"
  end

  log_calls :fetch_data
end

api = API.new
api.fetch_data
# Output:
# Before: calling fetch_data
# After: fetch_data returned Data
```
