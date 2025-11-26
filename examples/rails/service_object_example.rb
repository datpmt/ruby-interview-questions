# Simple service object pattern example (standalone)
# This example does not depend on Rails — it's a plain Ruby service object

class CreateReport
  def initialize(user)
    @user = user
  end

  # Simulate a report generation
  # Returns a hash with summary data
  def call
    {
      user: @user[:name],
      posts_count: (@user[:posts] || []).size,
      summary: generate_summary
    }
  end

  private

  def generate_summary
    "Report for \\#{@user[:name]}: \\#{(@user[:posts] || []).size} posts"
  end
end

if __FILE__ == $0
  # Demo runner for the service object
  user = { name: 'Alice', posts: %w[a b c] }
  result = CreateReport.new(user).call
  puts "Report result: \n"
  p result
end
