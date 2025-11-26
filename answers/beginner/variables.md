# Variables — Answers (Beginner)

### 1. What are the different types of variables in Ruby?

Ruby has four main types of variables, each with distinct scoping and behavior:

- **Local Variables** (`name`): Scoped to the current method, block, or file. The most common variable type.
  ```ruby
  def greet
    message = "Hello"  # Local variable
    puts message
  end
  ```

- **Instance Variables** (`@name`): Belong to an object and prefixed with `@`. Persist for the object's lifetime.
  ```ruby
  class Person
    def initialize(name)
      @name = name  # Instance variable
    end
  end
  ```

- **Class Variables** (`@@name`): Shared across all instances of a class and prefixed with `@@`.
  ```ruby
  class Counter
    @@count = 0  # Class variable
    def initialize
      @@count += 1
    end
  end
  ```

- **Global Variables** (`$name`): Accessible from anywhere in the program and prefixed with `$`. Generally discouraged.
  ```ruby
  $debug = true  # Global variable
  ```

### 2. How does Ruby handle variable scope?

Ruby determines variable scope based on where the variable is declared:

- **Lexical scope** for local variables: A local variable is accessible only within the method, block, or file where it's defined.
  ```ruby
  def example
    x = 10
    puts x  # OK
  end
  puts x    # NameError: undefined local variable
  ```

- **Method boundaries** create new scopes: A new local scope is created each time you enter a method.
  ```ruby
  x = 5
  def foo
    x = 10  # Different x, local to this method
  end
  puts x    # => 5 (unchanged)
  ```

- **Blocks share enclosing scope**: Blocks (do...end or {}) can access and modify local variables from their enclosing scope.
  ```ruby
  x = 0
  3.times { |i| x += i }
  puts x  # => 3 (modified by block)
  ```

- **Instance and class variables** are not affected by method boundaries; they belong to the object or class.

### 3. What is the difference between a constant and a variable?

**Constants** (capitalized) are intended to hold values that shouldn't change:

```ruby
PI = 3.14159
MAX_SIZE = 100

class Config
  API_KEY = "secret"  # Class constant
end
```

**Key differences:**
- Constants are named with all uppercase letters by convention.
- Ruby allows reassigning constants (with a warning), but it's discouraged.
- Constants have different scoping rules: they can be accessed from outside their class/scope using `::` (scope resolution).
  ```ruby
  class Math
    PI = 3.14159
  end
  puts Math::PI  # => 3.14159
  ```
- Variables (local, instance, class) cannot be accessed this way.

**Best Practice**: Use constants for values that logically won't change (configuration, magic numbers). Use variables for data that changes during execution.
