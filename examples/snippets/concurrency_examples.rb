# Concurrency example: race condition vs. Mutex-protected increments

# Race condition example (unsafe)
# Note: Thread and Mutex are part of Ruby's core library; no require needed in modern MRI.
counter = 0
threads = []
10.times do
  threads << Thread.new do
    1000.times { counter += 1 }
  end
end
threads.each(&:join)
puts 'Race (unsafe) counter: ', counter

# Mutex-protected example (safe)
safe_counter = 0
mutex = Mutex.new
threads = []
10.times do
  threads << Thread.new do
    1000.times do
      mutex.synchronize { safe_counter += 1 }
    end
  end
end
threads.each(&:join)
puts 'Mutex-protected counter: ', safe_counter
