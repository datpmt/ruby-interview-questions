# Blocks examples
def greet
  yield 'world'
end

greet { |name| puts "Hello, #{name}" }
# Examples of blocks, Procs, and lambdas in Ruby

# 1) Using yield with an implicit block
def repeat(n)
  i = 0
  while i < n
    yield i
    i += 1
  end
end

puts 'repeat with yield:'
repeat(3) do |i|
  puts "  Hello ##{i}"
end

# 2) Passing an explicit block object with &block
def call_block(n, &block)
  n.times { |i| block.call(i) }
end

puts "\ncall_block with Proc:"
my_proc = proc { |i| puts '  Proc called with ', i }
call_block(2, &my_proc)

# 3) Lambdas (enforce arity + return semantics)
my_lambda = ->(x) { x * 2 }
puts "\nlambda example: 5 -> ", my_lambda.call(5)

# 4) Converting between Proc and lambda behaviors
def returns_from_block
  l = -> { :from_lambda }
  p = proc { return :from_proc }

  val_lambda = l.call
  # The Proc return will return from the enclosing method
  val_proc = p.call
  [val_lambda, val_proc]
end

puts "\nreturns_from_block:"
puts '  ', returns_from_block.inspect
