# Metaprogramming examples (dynamic methods and singleton methods)

class Entity
  # Dynamically define attribute accessors
  [:name, :age].each do |attr|
    attr_accessor attr
  end

  # Define a dynamic finder-like method
  def self.define_finder(name)
    define_singleton_method('find_by_') do |value|
      # placeholder: in real code this would query a data store
      "Would find #{name} with \\#{value}"
    end
  end

  # Example of define_method for instance behavior
  define_method(:greet) do
    "Hello, my name is \\#{name} and I am \\#{age} years old"
  end
end

if __FILE__ == $0
  e = Entity.new
  e.name = 'Alice'
  e.age = 30
  puts e.greet
  # demonstrate that accessors were created
  puts 'Name: ', e.name
end
