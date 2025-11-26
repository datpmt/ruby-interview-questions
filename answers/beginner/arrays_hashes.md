# Arrays & Hashes — Answers (Beginner)

### 1. What is an Array in Ruby and how do you create one?

An **Array** is an ordered collection of elements (objects) that can be accessed by index. Arrays are zero-indexed and can contain any type of object.

```ruby
# Create arrays using literal syntax
arr = [1, 2, 3, 4, 5]
mixed = [1, "hello", :symbol, true, nil]

# Create arrays using Array.new
arr = Array.new(5)           # => [nil, nil, nil, nil, nil]
arr = Array.new(3, "default") # => ["default", "default", "default"]

# Create arrays from ranges
arr = (1..5).to_a  # => [1, 2, 3, 4, 5]
```

**Array indexing:**
```ruby
arr = ["a", "b", "c", "d"]
arr[0]   # => "a" (first element)
arr[-1]  # => "d" (last element)
arr[1..2] # => ["b", "c"] (slice)
```

### 2. What are common Array methods and their use cases?

**Access and Inspection:**
```ruby
arr = [1, 2, 3, 4, 5]
arr.first         # => 1
arr.last          # => 5
arr.size          # => 5
arr.empty?        # => false
arr.include?(3)   # => true
```

**Modification (mutating):**
```ruby
arr = [1, 2, 3]
arr.push(4)       # => [1, 2, 3, 4] (add to end)
arr << 5          # => [1, 2, 3, 4, 5] (same as push)
arr.pop           # => 5, arr is now [1, 2, 3, 4]
arr.shift         # => 1 (remove from start)
arr.unshift(0)    # => [0, 2, 3, 4] (add to start)
```

**Iteration:**
```ruby
arr = [1, 2, 3]
arr.each { |x| puts x }          # iterate over each element
arr.map { |x| x * 2 }            # => [2, 4, 6] (transform)
arr.select { |x| x > 1 }         # => [2, 3] (filter)
arr.reject { |x| x > 2 }         # => [1, 2] (opposite of select)
arr.find { |x| x > 2 }           # => 3 (first match)
```

**Transformation:**
```ruby
arr = [1, 2, 3]
arr.reverse       # => [3, 2, 1]
arr.sort          # => [1, 2, 3]
arr.uniq          # => [1, 2, 3] (remove duplicates)
arr.flatten       # => flattens nested arrays
arr.join(", ")    # => "1, 2, 3" (converts to string)
```

### 3. What is a Hash in Ruby and how do you create one?

A **Hash** is an unordered collection of key-value pairs. Keys must be unique; if a duplicate key is used, the newer value overwrites the old one.

```ruby
# Symbol keys (preferred in modern Ruby)
person = { name: "Alice", age: 30, city: "NYC" }

# String keys
person = { "name" => "Alice", "age" => 30 }

# Mixed keys (not recommended)
mixed = { name: "Alice", "age" => 30 }

# Create with Hash.new
hash = Hash.new           # => {}
hash = Hash.new("default") # Returns "default" for missing keys
```

**Hash access:**
```ruby
person = { name: "Alice", age: 30 }
person[:name]    # => "Alice"
person[:age]     # => 30
person[:job]     # => nil (missing key returns nil)
person.fetch(:name)  # => "Alice"
person.fetch(:job, "Unknown")  # => "Unknown" (with default)
```

### 4. What are common Hash methods?

**Access and Inspection:**
```ruby
person = { name: "Alice", age: 30, city: "NYC" }
person.keys           # => [:name, :age, :city]
person.values         # => ["Alice", 30, "NYC"]
person.length         # => 3
person.empty?         # => false
person.key?(:name)    # => true
person.value?("Alice") # => true
```

**Modification:**
```ruby
person = { name: "Alice", age: 30 }
person[:job] = "Engineer"     # Add new key-value
person[:age] = 31             # Update existing value
person.delete(:city)          # Remove key
person.clear                  # Remove all entries
```

**Iteration:**
```ruby
person = { name: "Alice", age: 30 }
person.each { |key, value| puts "#{key}: #{value}" }
person.keys.each { |k| puts k }
person.values.each { |v| puts v }

# Transform
person.map { |k, v| "#{k}=#{v}" }
```

**Merge and Combine:**
```ruby
person = { name: "Alice", age: 30 }
job = { job: "Engineer", salary: 100000 }
merged = person.merge(job)    # => { name: "Alice", age: 30, job: "Engineer", salary: 100000 }
```

### 5. What's the difference between Arrays and Hashes?

| Feature | Array | Hash |
|---------|-------|------|
| **Order** | Ordered by index | Unordered (Ruby 1.9+ maintains insertion order) |
| **Access** | By position (integer index) | By key (any object) |
| **Use Case** | Lists, sequences | Key-value mappings, lookups |
| **Add element** | `arr << item` or `arr.push(item)` | `hash[key] = value` |
| **Find by value** | `arr.include?(value)` — O(n) | `hash.value?(value)` — O(n) |
| **Create** | `[1, 2, 3]` | `{ key: value }` |

**When to use:**
- **Arrays**: Ordered collections, lists, stacks, queues
- **Hashes**: Fast lookups by key, configuration, attributes of an object

### 6. What is the difference between symbol keys and string keys in hashes?

```ruby
# Symbol keys (preferred)
person = { name: "Alice", age: 30 }
person[:name]  # => "Alice"

# String keys
person = { "name" => "Alice", "age" => 30 }
person["name"]  # => "Alice"
```

**Advantages of symbols:**
- **Immutable**: Symbols are reused in memory, saving space
- **Performance**: Symbol lookups are faster than string lookups
- **Convention**: Rails and most Ruby code uses symbol keys
- **Idiomatic**: `:symbol` syntax is more readable than `"string"`

**When to use strings:**
- JSON data typically uses string keys
- External APIs often provide string keys
- When keys are dynamic or come from user input
