# Basic OOP — Answers (Beginner)

### 1. What are classes and objects in Ruby?

A **class** is a blueprint or template that defines the structure and behavior of objects.

An **object** (or instance) is a concrete thing created from a class.

```ruby
# Define a class
class Dog
  def initialize(name, breed)
    @name = name       # instance variable
    @breed = breed
  end

  def bark
    puts "#{@name} says woof!"
  end

  def info
    "#{@name} is a #{@breed}"
  end
end

# Create objects (instances)
fido = Dog.new("Fido", "Golden Retriever")
rex = Dog.new("Rex", "German Shepherd")

fido.bark        # => Fido says woof!
puts fido.info   # => Fido is a Golden Retriever
```

**Key concepts:**
- **Class**: The template (Dog)
- **Instance**: A specific dog (fido, rex)
- **Methods**: Actions the object can perform (bark, info)
- **Instance variables**: Data stored in each object (@name, @breed)

### 2. What are instance variables and why use them?

**Instance variables** (prefixed with `@`) belong to each object and persist for the object's lifetime.

```ruby
class Person
  def initialize(name, age)
    @name = name    # Instance variable: stored in the object
    @age = age
  end

  def introduce
    puts "Hi, I'm #{@name} and I'm #{@age} years old"
  end

  def have_birthday
    @age += 1       # Can modify instance variables
  end
end

person = Person.new("Alice", 30)
person.introduce    # => Hi, I'm Alice and I'm 30 years old
person.have_birthday
person.introduce    # => Hi, I'm Alice and I'm 31 years old
```

**Why use instance variables:**
- Store unique data for each object
- Share data between methods within the same object
- Represent the state of an object
- Persist for the lifetime of the object

**Scope:**
- Only accessible within instance methods of that object
- Each object has its own copy of instance variables
- Cannot be accessed directly from outside the object

### 3. What is inheritance and how does it work?

**Inheritance** allows a class to inherit methods and instance variables from a parent class (superclass).

```ruby
# Parent class
class Animal
  def initialize(name)
    @name = name
  end

  def speak
    puts "#{@name} makes a sound"
  end

  def move
    puts "#{@name} is moving"
  end
end

# Child class (inherits from Animal)
class Dog < Animal
  # Inherits initialize, speak, move from Animal

  def speak
    # Override parent method
    puts "#{@name} barks"
  end

  def fetch
    puts "#{@name} is fetching the ball"
  end
end

dog = Dog.new("Rex")
dog.speak   # => Rex barks (overridden method)
dog.move    # => Rex is moving (inherited method)
dog.fetch   # => Rex is fetching the ball (new method)
```

**Key concepts:**
- Use `<` to inherit from a parent class
- Child class inherits all parent methods
- Child can **override** parent methods
- Child can define new methods
- Child accesses parent instance variables through inherited methods

### 4. What is the `super` keyword and when do you use it?

The `super` keyword calls the parent class's version of the current method.

```ruby
class Animal
  def initialize(name)
    @name = name
    puts "Animal initialized"
  end

  def speak
    puts "Generic sound"
  end
end

class Dog < Animal
  def initialize(name, breed)
    super(name)      # Call parent's initialize with @name
    @breed = breed
    puts "Dog initialized"
  end

  def speak
    super            # Call parent's speak
    puts "Woof!"     # Then add dog-specific behavior
  end
end

dog = Dog.new("Rex", "German Shepherd")
# Output:
# Animal initialized
# Dog initialized

dog.speak
# Output:
# Generic sound
# Woof!
```

**Using `super` with no parentheses:**
```ruby
def speak
  super    # Passes all arguments to parent automatically
end
```

**Using `super` with specific arguments:**
```ruby
def initialize(name, breed)
  super(name)  # Passes only name to parent
  @breed = breed
end
```

### 5. What is method visibility (public, private, protected)?

Ruby has three visibility levels that control how methods can be called.

**Public methods** (default):
Accessible from anywhere.

```ruby
class Dog
  def bark
    puts "Woof!"
  end
end

dog = Dog.new
dog.bark  # OK - public method
```

**Private methods:**
Accessible only within the class (cannot call with explicit receiver, even `self`).

```ruby
class Dog
  def bark
    private_method  # OK - implicit self
  end

  private

  def private_method
    puts "Internal logic"
  end
end

dog = Dog.new
dog.bark              # OK
# dog.private_method  # Error: private method
```

**Protected methods:**
Accessible within the class and by other instances of the same class (but not from outside).

```ruby
class Dog
  def compare_bark(other_dog)
    if other_dog.bark_volume > self.bark_volume
      "#{other_dog.name} barks louder"
    end
  end

  protected

  def bark_volume
    10
  end
end

dog1 = Dog.new
dog2 = Dog.new
dog1.compare_bark(dog2)      # OK - can access dog2's protected method
# dog1.bark_volume            # Error - cannot access protected from outside
```

**Visibility table:**
| Visibility | Within Class | From Other Class | Called with Receiver? |
|------------|-------------|-----------------|----------------------|
| **Public** | ✓ | ✓ | ✓ (required) |
| **Private** | ✓ | ✗ | ✗ (no receiver) |
| **Protected** | ✓ | ✓ (same class) | ✓ (same class only) |

### 6. What are attr_accessor, attr_reader, and attr_writer?

These are shortcuts for creating getter and setter methods.

**Manual approach (verbose):**
```ruby
class Person
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def name=(new_name)
    @name = new_name
  end
end

person = Person.new("Alice")
puts person.name      # => Alice
person.name = "Bob"
puts person.name      # => Bob
```

**Using attr_accessor (both getter and setter):**
```ruby
class Person
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

person = Person.new("Alice")
puts person.name      # => Alice
person.name = "Bob"   # Setter created by attr_accessor
puts person.name      # => Bob
```

**attr_reader (getter only):**
```ruby
class Person
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

person = Person.new(123)
puts person.id   # => 123
# person.id = 456  # Error: no setter
```

**attr_writer (setter only):**
```ruby
class Person
  attr_writer :password

  def initialize
    @password = nil
  end
end

person = Person.new
person.password = "secret"  # Setter works
# puts person.password        # Error: no getter
```

**Multiple attributes:**
```ruby
class Person
  attr_accessor :name, :age
  attr_reader :id
  attr_writer :password

  def initialize(id, name, age)
    @id = id
    @name = name
    @age = age
  end
end
```

### 7. What is encapsulation and why is it important?

**Encapsulation** is bundling data (instance variables) and methods together, and hiding internal details from the outside.

```ruby
class BankAccount
  def initialize(balance)
    @balance = balance
  end

  def deposit(amount)
    if amount > 0
      @balance += amount
      puts "Deposited: $#{amount}"
    end
  end

  def withdraw(amount)
    if amount <= @balance
      @balance -= amount
      puts "Withdrew: $#{amount}"
    else
      puts "Insufficient funds"
    end
  end

  def balance
    @balance
  end

  private

  def log_transaction(type, amount)
    puts "[LOG] #{type}: $#{amount}"
  end
end

account = BankAccount.new(1000)
account.deposit(500)      # OK - public method
puts account.balance      # => 1500
# account.log_transaction  # Error - private method
# account.@balance = 999  # Error - cannot access directly
```

**Benefits of encapsulation:**
- **Hide complexity**: Users interact with simple public methods
- **Protect state**: Private methods prevent invalid operations
- **Maintain invariants**: Ensure data stays valid
- **Allow changes**: Modify internal implementation without breaking code that uses your class

**Best practices:**
- Make instance variables private (don't expose `@balance` directly)
- Provide public methods for what users need (deposit, withdraw, balance)
- Hide implementation details (log_transaction)
- Use `attr_accessor` for simple attributes; use custom methods for validation
