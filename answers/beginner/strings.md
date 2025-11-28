# Strings - Questions (Beginner)

### Q1. What is a string in Ruby and how do you create one?

**A:** A string is a sequence of characters. Create strings using single or double quotes, or the `%w` syntax:

```ruby
single = 'hello'
double = "world"
multi = %w[apple banana cherry]  # array of strings
```

---

### Q2. What's the difference between single-quoted and double-quoted strings?

**A:** Double-quoted strings support escape sequences and interpolation; single-quoted strings are literal except for `\'` and `\\`.

```ruby
puts "Hello\nWorld"    # newline is interpreted
puts 'Hello\nWorld'    # \n is printed literally
```

---

### Q3. How do you concatenate strings in Ruby?

**A:** Use `+`, `<<` (append), or `#{...}` interpolation:

```ruby
str = "Hello" + " " + "World"   # => "Hello World"
str = "Hello" << " World"       # modifies in place
str = "Hello #{name}"           # interpolation
```

---

### Q4. What are string interpolation and how do you use it?

**A:** String interpolation embeds Ruby expressions inside double-quoted strings using `#{}`:

```ruby
name = "Alice"
age = 30
puts "My name is #{name} and I am #{age} years old"
# => My name is Alice and I am 30 years old
```

---

### Q5. How do you find the length of a string?

**A:** Use `.length` or `.size`:

```ruby
"hello".length  # => 5
"hello".size    # => 5
```

---

### Q6. What is a symbol and how does it differ from a string?

**A:** A symbol is an immutable identifier (prefixed with `:`). Symbols are lightweight and often used as hash keys; strings are mutable:

```ruby
:name          # symbol
"name"         # string
{ :name => "Alice" }   # symbol key
{ name: "Alice" }      # shorthand for symbol key
```

---

### Q7. How do you convert a string to an integer or vice versa?

**A:** Use `.to_i` and `.to_s`:

```ruby
"42".to_i      # => 42
42.to_s        # => "42"
"3.14".to_f    # => 3.14
```
