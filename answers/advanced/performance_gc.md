# Performance & GC — Answers (Advanced)

### 1. How does Ruby garbage collection work?

Ruby uses **mark-and-sweep garbage collection** to manage memory.

**How it works:**

1. **Mark phase** – Walk object graph from roots (local variables, global variables) and mark live objects
2. **Sweep phase** – Iterate through heap and free unmarked objects
3. **Compact phase** (Ruby 2.7+) – Defragment heap to reduce memory

```ruby
# Objects are collected automatically
def create_objects
  100.times { String.new }  # 100 objects created
end  # Objects become unreachable and are collected

# Force garbage collection (rarely needed)
GC.start
```

**GC configuration:**
```ruby
# Check GC status
GC.stat
# => {:count=>5, :heap_allocatable_pages=>6, ...}

# Disable GC (sometimes done during benchmarks)
GC.disable
# ... code ...
GC.enable

# Manual collection
GC.start
```

### 2. What causes garbage collection performance problems?

**Problem 1: Creating too many objects**
```ruby
# Bad: creates millions of intermediate strings
def slow_string_concat(n)
  result = ""
  n.times { result += "x" }  # Creates new string each time
  result
end

# Better: use array and join
def fast_string_concat(n)
  result = []
  n.times { result << "x" }
  result.join
end

# Or use string builder
require 'stringio'
def better_string_concat(n)
  io = StringIO.new
  n.times { io << "x" }
  io.string
end
```

**Problem 2: Large collections in memory**
```ruby
# Bad: loads entire file into memory as separate strings
lines = File.read("huge_file.txt").split("\n")
lines.each { |line| process(line) }

# Better: stream file
File.foreach("huge_file.txt") do |line|
  process(line)
  # line is garbage collected after each iteration
end
```

**Problem 3: Circular references (less common in Ruby)**
```ruby
# Ruby's GC handles circular references
class Node
  attr_accessor :prev, :next

  def initialize
    @prev = nil
    @next = nil
  end
end

a = Node.new
b = Node.new
a.next = b
b.prev = a  # Circular reference, but GC still cleans up

# Set them to nil to help GC
a = nil
b = nil
```

### 3. How do you profile Ruby applications?

**Using `require 'benchmark'`:**
```ruby
require 'benchmark'

Benchmark.bm do |x|
  x.report("method_a") { 1_000_000.times { method_a } }
  x.report("method_b") { 1_000_000.times { method_b } }
end

# Output:
#            user     system      total        real
# method_a   0.123000   0.000000   0.123000 (  0.125234)
# method_b   0.456000   0.000000   0.456000 (  0.458901)
```

**Memory profiling:**
```ruby
require 'objspace'

ObjectSpace.each_object { |obj| puts obj.class }  # All objects
ObjectSpace.count_objects   # Count by type

# Memory used
ObjectSpace.memsize_of(obj)  # Size of single object
ObjectSpace.memsize_of_all   # Total heap size
```

**Using ruby-prof gem:**
```ruby
require 'ruby-prof'

RubyProf.start
# ... code to profile ...
result = RubyProf.stop

# Print results
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
```

### 4. What are N+1 queries and how do you fix them?

**N+1 problem** – executing one query per record instead of loading related data upfront.

```ruby
# Bad: N+1 queries
@users = User.all  # 1 query
@users.each do |user|
  puts user.posts  # N queries (one per user)
end

# Better: eager load with includes
@users = User.includes(:posts).all  # 2 queries (load users + posts)
@users.each do |user|
  puts user.posts  # No additional queries
end

# Or use joins
@users = User.joins(:posts).all
```

**Detecting N+1:**
```ruby
# Use query logging
ActiveRecord::Base.logger = Logger.new(STDOUT)

@users.each { |u| u.posts }  # See N queries in logs
```

### 5. What are common memory leaks in Ruby?

**Memory leak 1: Global variables**
```ruby
# Bad: accumulates memory
$cache = {}
def cache_result(key, value)
  $cache[key] = value  # Never garbage collected
end

# Better: use instance variable with limits
class Cache
  def initialize(max_size = 1000)
    @cache = {}
    @max_size = max_size
  end

  def set(key, value)
    @cache.delete(@cache.keys.first) if @cache.size >= @max_size
    @cache[key] = value
  end
end
```

**Memory leak 2: Callbacks with references**
```ruby
# Bad: callback holds reference
class Observer
  def initialize(observable)
    @observable = observable
    @observable.add_observer(self)  # Never unsubscribed
  end

  def update
    puts "Updated"
  end
end

# Better: unsubscribe when done
observer = Observer.new(observable)
# ...
observable.remove_observer(observer)
```

**Memory leak 3: Keeping large objects in memory**
```ruby
# Bad: string stays in memory forever
@large_string = File.read("huge_file.txt")

# Better: read when needed or in chunks
def read_file_line_by_line
  File.foreach("huge_file.txt") do |line|
    # Process and discard
  end
end
```

### 6. How do you optimize Ruby code for performance?

**1. Use built-in methods (written in C):**
```ruby
# Slow: ruby implementation
result = []
[1, 2, 3].each { |x| result << x * 2 }

# Better: map (built-in, faster)
result = [1, 2, 3].map { |x| x * 2 }
```

**2. Avoid unnecessary object creation:**
```ruby
# Slow: creates array
names = users.map(&:name).join(", ")

# Better: iterate once
names = users.map { |u| u.name }.join(", ")

# Even better: select before processing
names = users.select(&:active?).map(&:name).join(", ")
```

**3. Use appropriate data structures:**
```ruby
# Slow: array with many searches
list = [1, 2, 3, 4, 5]
list.include?(3)  # O(n)

# Better: set for fast lookup
require 'set'
set = Set.new([1, 2, 3, 4, 5])
set.include?(3)  # O(1)
```

**4. Cache expensive computations:**
```ruby
# Slow: recalculates every time
def expensive_calc(n)
  sum = 0
  n.times { |i| sum += i }
  sum
end

# Better: cache result
@cache = {}
def expensive_calc(n)
  @cache[n] ||= begin
    sum = 0
    n.times { |i| sum += i }
    sum
  end
end
```

### 7. What is the difference between profiling, benchmarking, and monitoring?

**Profiling** – analyzing where time/memory is spent during execution.
```ruby
# Ruby-prof
RubyProf.start
# ... run code ...
result = RubyProf.stop
printer = RubyProf::CallStackPrinter.new(result)
printer.print(STDOUT)
```

**Benchmarking** – comparing performance of specific operations.
```ruby
require 'benchmark'
Benchmark.bm do |x|
  x.report("A") { 1_000.times { operation_a } }
  x.report("B") { 1_000.times { operation_b } }
end
```

**Monitoring** – tracking application performance in production.
```ruby
# Tools like New Relic, Datadog, Scout
# They track:
# - Response times
# - Error rates
# - Memory usage
# - Database queries
```

**Practical example:**
```ruby
# Benchmark quick operation
time = Benchmark.realtime do
  1_000_000.times { "hello".upcase }
end
puts "Took #{time} seconds"

# Profile method
RubyProf.start
method_under_test
result = RubyProf.stop

# Monitor in production
NewRelic::Agent.start
# Application continues and sends metrics to New Relic
```
