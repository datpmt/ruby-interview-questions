# Loops — Answers (Beginner)

### 1. What are the main iteration constructs in Ruby?

Ruby provides several ways to iterate over collections and repeat code:

- **`.each`** – Iterates over each element (most common)
- **`.times`** – Repeats a block N times
- **`.while`** – Repeats while a condition is true
- **`.until`** – Repeats until a condition is true
- **`.for`** – Syntactic sugar over `.each` (rarely used)
- **`.loop`** – Infinite loop (must break explicitly)
- **`.map`** – Iterates and transforms elements
- **`.select`** – Iterates and filters elements

### 2. When should you use `.each` vs `.while` vs `.until`?

**`.each` – For iterating over collections:**
```ruby
fruits = ["apple", "banana", "cherry"]
fruits.each { |fruit| puts fruit }
# Preferred for iterating collections

# Multi-line form
fruits.each do |fruit|
  puts "I like #{fruit}"
end
```
**Use `.each` when:** You have a collection and want to process each element.

**`.while` – For conditional loops (check condition first):**
```ruby
count = 0
while count < 5
  puts "Count: #{count}"
  count += 1
end
# Repeats as long as condition is true
```
**Use `.while` when:** You need to loop based on a boolean condition checked before each iteration.

**`.until` – For inverse condition loops:**
```ruby
count = 0
until count >= 5
  puts "Count: #{count}"
  count += 1
end
# Repeats until condition becomes true
```
**Use `.until` when:** Your condition reads more naturally as "until X happens."

**`.for` – Rarely used (avoid):**
```ruby
for fruit in ["apple", "banana"]
  puts fruit
end
# Variables leak into outer scope!
puts fruit  # => "banana" (should not exist!)
```
**Avoid `.for`**: Use `.each` instead; variables don't leak.

### 3. How do you use `.times` and range iteration?

**`.times` – Repeat N times:**
```ruby
3.times { |i| puts "Iteration #{i}" }
# Output:
# Iteration 0
# Iteration 1
# Iteration 2

# Multi-line form
5.times do |i|
  puts i * 2
end
```

**Range iteration with `.each`:**
```ruby
(1..5).each { |i| puts i }    # 1 to 5 inclusive
(1...5).each { |i| puts i }   # 1 to 4 (exclusive end)

# With step
(1..10).step(2) { |i| puts i }  # => 1, 3, 5, 7, 9

# Reverse
(1..5).reverse_each { |i| puts i }  # => 5, 4, 3, 2, 1
```

### 4. What's the difference between `.loop` and `.while`?

**`.while` – Condition checked first:**
```ruby
count = 0
while count < 3
  puts count
  count += 1
end
# If condition is false from start, loop never runs
```

**`.loop` – Infinite until break:**
```ruby
count = 0
loop do
  puts count
  count += 1
  break if count >= 3
end
# Must use break to exit; condition checked inside
```

**Comparison:**
| Feature | `.while` | `.loop` |
|---------|----------|--------|
| **Condition** | Checked before each iteration | Must use `break` inside |
| **Infinite** | Can be infinite if condition always true | Always infinite without `break` |
| **Use case** | Known termination condition | Break based on complex logic inside |

### 5. What are `.map` and `.select`? How are they different from `.each`?

**`.map` – Transform elements (returns new array):**
```ruby
numbers = [1, 2, 3, 4]
doubled = numbers.map { |n| n * 2 }
# => [2, 4, 6, 8]

# .each returns the original array
result = numbers.each { |n| n * 2 }
# => [1, 2, 3, 4] (unchanged)
```

**`.select` – Filter elements (returns new array):**
```ruby
numbers = [1, 2, 3, 4, 5]
evens = numbers.select { |n| n.even? }
# => [2, 4]

odds = numbers.select { |n| n.odd? }
# => [1, 3, 5]

# Opposite: .reject
not_evens = numbers.reject { |n| n.even? }
# => [1, 3, 5]
```

**Comparison:**
| Method | Purpose | Returns |
|--------|---------|---------|
| **`.each`** | Iterate, execute side effects | Original array |
| **`.map`** | Transform elements | New array with transformed values |
| **`.select`** | Filter elements | New array with matching elements |

### 6. What is an infinite loop and how do you exit it?

An **infinite loop** repeats forever unless you explicitly break out.

```ruby
# Infinite loop with .loop
loop do
  puts "Infinite"
  break if some_condition  # Must have exit condition
end

# Infinite .while
while true
  puts "Infinite"
  break
end

# Infinite range
(1..Float::INFINITY).each do |i|
  break if i > 5
  puts i
end
```

**Exit infinite loops using:**
- **`break`** – Exit immediately
- **`next`** – Skip to next iteration
- **`return`** – Exit the method
- **`exit`** – Exit the program (dangerous!)

```ruby
loop do
  input = gets.chomp
  break if input == "quit"
  puts "You said: #{input}"
end
```

### 7. What is a block and how does it work in iteration?

A **block** is a chunk of code passed to a method. Blocks are used heavily in iteration.

```ruby
# Block syntax 1: single-line with {}
[1, 2, 3].each { |x| puts x }

# Block syntax 2: multi-line with do...end
[1, 2, 3].each do |x|
  puts "Number: #{x}"
  puts x * 2
end
```

**Block parameters** are the variables in `|x|`:
```ruby
["a", "b", "c"].each { |letter| puts letter }
# letter is a block parameter; it's different for each iteration

(1..3).each_with_index { |value, index| puts "#{index}: #{value}" }
# value and index are block parameters
```

**Blocks are passed to methods:**
```ruby
def greet
  yield "World"  # yield calls the block
end

greet { |name| puts "Hello, #{name}" }
# => Hello, World
```

**Best Practice**: Use `.each` for side effects, `.map` to transform, `.select` to filter.
