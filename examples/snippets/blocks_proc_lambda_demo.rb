#!/usr/bin/env ruby
# Demo: Proc vs Lambda (arity and return behavior)

def demo_lambda
  l = ->(x) { "lambda returned: \\#{x * 2}" }
  result = l.call(3)
  "after lambda: \\#{result}"
end

def demo_proc
  p = proc { |x| return "proc returned: \\#{x * 2}" }
  p.call(3)
  'after proc'
end

puts 'demo_lambda => ', demo_lambda
puts 'demo_proc  => ', demo_proc
