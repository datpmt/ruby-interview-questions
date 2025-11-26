# Error Handling — Answers (Intermediate)

### 1. What are exceptions in Ruby and how do you raise them?

**Exceptions** are objects that represent errors or exceptional conditions. They inherit from the `Exception` class.

```ruby
# Common exception types
raise StandardError, "Something went wrong"
raise RuntimeError, "Runtime problem"
raise ArgumentError, "Invalid argument"
raise ZeroDivisionError, "Cannot divide by zero"

# Raise without type (defaults to RuntimeError)
raise "This is a RuntimeError"

# Custom exceptions
class MyCustomError < StandardError
end

raise MyCustomError, "Custom error message"
```

**Exception hierarchy:**
```
Exception
├── StandardError (for general errors)
│   ├── ArgumentError
│   ├── RuntimeError
│   ├── ZeroDivisionError
│   └── ... (many more)
├── SystemExit
├── Interrupt
└── SignalException
```

### 2. How do you rescue (catch) exceptions?

**Basic rescue:**
```ruby
begin
  result = 10 / 0
rescue ZeroDivisionError
  puts "Cannot divide by zero"
end
```

**Rescue with error variable:**
```ruby
begin
  result = 10 / 0
rescue ZeroDivisionError => error
  puts "Error: #{error.message}"
  puts "Backtrace: #{error.backtrace}"
end
```

**Rescue multiple exception types:**
```ruby
begin
  # risky code
rescue ZeroDivisionError, ArgumentError => error
  puts "Caught error: #{error.class}"
end
```

**Rescue StandardError (most common errors):**
```ruby
begin
  # risky code
rescue => error
  puts "Caught: #{error.message}"
end
```

### 3. What is the difference between `ensure` and `else` in exception handling?

**`ensure` – Always executes** (cleanup code):
```ruby
begin
  puts "Try block"
  raise "Error!"
rescue
  puts "Rescue block"
ensure
  puts "Ensure block (always runs)"
end

# Output:
# Try block
# Rescue block
# Ensure block (always runs)
```

**`else` – Executes if no exception**:
```ruby
begin
  x = 10
rescue
  puts "Rescue block"
else
  puts "Else block (no exception)"
  puts "x = #{x}"
end

# Output:
# Else block (no exception)
# x = 10
```

**Combined `begin-rescue-else-ensure`:**
```ruby
begin
  puts "1. Try"
  x = 10 / 2
rescue ZeroDivisionError
  puts "2. Rescue"
else
  puts "3. Else (no error, x = #{x})"
ensure
  puts "4. Ensure (always runs)"
end

# Output:
# 1. Try
# 3. Else (no error, x = 5)
# 4. Ensure (always runs)
```

### 4. How do you create custom exceptions?

**Basic custom exception:**
```ruby
class InvalidAgeError < StandardError
end

begin
  age = -5
  raise InvalidAgeError, "Age cannot be negative"
rescue InvalidAgeError => e
  puts "Caught: #{e.message}"
end
```

**Custom exception with extra functionality:**
```ruby
class ValidationError < StandardError
  attr_reader :field, :value

  def initialize(field, value, message)
    @field = field
    @value = value
    super(message)
  end
end

begin
  raise ValidationError.new(:email, "invalid@", "Invalid email format")
rescue ValidationError => e
  puts "Field: #{e.field}"
  puts "Value: #{e.value}"
  puts "Message: #{e.message}"
end
```

**Exception with custom methods:**
```ruby
class APIError < StandardError
  attr_reader :status_code, :response_body

  def initialize(status_code, response_body)
    @status_code = status_code
    @response_body = response_body
    super("API returned #{status_code}")
  end

  def retriable?
    status_code >= 500
  end
end

begin
  raise APIError.new(503, "Service Unavailable")
rescue APIError => e
  puts "API Error: #{e.message}"
  puts "Retriable: #{e.retriable?}"
end
```

### 5. What are exception handling best practices?

**Be specific with rescue:**
```ruby
# Bad: catches all exceptions
begin
  risky_operation
rescue
  puts "Something went wrong"
end

# Good: catch specific exceptions
begin
  risky_operation
rescue IOError, TimeoutError
  puts "IO or timeout error"
rescue ArgumentError
  puts "Invalid argument"
end
```

**Always use ensure for cleanup:**
```ruby
file = nil
begin
  file = File.open("data.txt")
  file.each_line { |line| puts line }
rescue IOError
  puts "Cannot read file"
ensure
  file.close if file
end
```

**Re-raise with context:**
```ruby
begin
  process_order(order)
rescue OrderProcessingError => e
  puts "Failed to process order #{order.id}"
  raise OrderFailureError, "Could not process: #{e.message}"
end
```

**Don't catch Exception (too broad):**
```ruby
# Bad: catches SystemExit, Interrupt, etc.
begin
  risky_code
rescue Exception
  puts "Something bad happened"
end

# Good: catch StandardError
begin
  risky_code
rescue StandardError
  puts "An error occurred"
end
```

### 6. What is the difference between raise and retry?

**`raise` – Throws an exception**:
```ruby
begin
  puts "Attempting..."
  raise "Error!"
rescue
  puts "Caught error"
end
```

**`retry` – Re-execute the begin block**:
```ruby
attempts = 0
begin
  attempts += 1
  puts "Attempt #{attempts}"
  raise "Failed!" if attempts < 3
rescue
  puts "Error, retrying..."
  retry
end

# Output:
# Attempt 1
# Error, retrying...
# Attempt 2
# Error, retrying...
# Attempt 3
```

**Using retry with a limit:**
```ruby
attempts = 0
max_attempts = 3

begin
  attempts += 1
  puts "Attempt #{attempts}"
  response = fetch_api_data
rescue NetworkError
  if attempts < max_attempts
    sleep(2)
    retry
  else
    raise "Failed after #{max_attempts} attempts"
  end
end
```

### 7. How do you handle exceptions in methods?

**Method-level exception handling:**
```ruby
def divide(a, b)
  begin
    a / b
  rescue ZeroDivisionError
    puts "Cannot divide by zero"
    0
  end
end

divide(10, 2)   # => 5
divide(10, 0)   # => Cannot divide by zero, returns 0
```

**Let exceptions propagate:**
```ruby
def process_data(data)
  validate_data(data)  # May raise ValidationError
  transform_data(data)
end

begin
  process_data(user_data)
rescue ValidationError => e
  puts "Invalid data: #{e.message}"
end
```

**Rescue in initialize:**
```ruby
class Database
  def initialize(connection_string)
    begin
      @connection = connect(connection_string)
    rescue ConnectionError => e
      puts "Failed to connect: #{e.message}"
      @connection = nil
    end
  end
end
```

**Method with explicit error handling:**
```ruby
def safe_file_read(filename)
  File.read(filename)
rescue Errno::ENOENT
  puts "File not found: #{filename}"
  nil
rescue IOError
  puts "IO error reading file"
  nil
ensure
  puts "Finished reading attempt"
end
```
