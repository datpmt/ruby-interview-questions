# Data Types - Questions (Beginner)

### 1. What are the main data types in Ruby?

**A:** Main types include Integer, Float, String, Symbol, Array, Hash, Boolean (true/false), and nil:

```ruby
42              # Integer
3.14            # Float
"hello"         # String
:name           # Symbol
[1, 2, 3]       # Array
{ a: 1, b: 2 }  # Hash
true / false    # Boolean
nil             # nil
```

---

### 2. What is the difference between mutable and immutable data types?

**A:** Mutable types can be modified in place; immutable types cannot. Symbols and integers are immutable; strings, arrays, and hashes are mutable:

```ruby
str = "hello"
str << " world"   # mutates the string

num = 42
num = num + 1     # creates a new integer, doesn't mutate
```

---

### 3. How do you check the type of an object?

**A:** Use `.class` or `.is_a?`:

```ruby
"hello".class           # => String
42.is_a?(Integer)       # => true
[1, 2].is_a?(Array)     # => true
```

---

### 4. What is type coercion and when does it happen?

**A:** Type coercion is automatic conversion between types. Ruby sometimes does it implicitly:

```ruby
"5" + 10        # => TypeError (no implicit conversion)
5 + 10          # => 15
"5".to_i + 10   # => 15 (explicit conversion)
```

---

### 5. What are frozen objects and how do you freeze them?

**A:** Frozen objects cannot be modified. Use `.freeze`:

```ruby
str = "hello"
str.freeze
str << " world"  # => FrozenError
```

---

### 6. How do you convert between different data types?

**A:** Use conversion methods like `.to_s`, `.to_i`, `.to_a`, `.to_h`:

```ruby
42.to_s         # => "42"
"3.14".to_f     # => 3.14
"a,b,c".split   # => ["a", "b", "c"]
```

---

### 7. What is `nil` and how do you check for it?

**A:** `nil` represents the absence of a value. Check it with `.nil?` or compare directly:

```ruby
x = nil
x.nil?           # => true
x == nil         # => true
x.class          # => NilClass
```
