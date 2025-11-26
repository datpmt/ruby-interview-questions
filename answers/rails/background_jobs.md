# Background Jobs — Answers (Rails)

### 1. What are background jobs and why would you use them?

**Background jobs** execute code asynchronously, outside the web request cycle.

**When to use background jobs:**
```ruby
# Bad: slow request (user waits)
class UsersController < ApplicationController
  def create
    @user = User.create(user_params)
    send_welcome_email(@user)  # Slow! 1-2 seconds
    redirect_to @user
  end
end

# Good: use background job
class UsersController < ApplicationController
  def create
    @user = User.create(user_params)
    SendWelcomeEmailJob.perform_later(@user)  # Queued, returns immediately
    redirect_to @user
  end
end
```

**Benefits:**
- Faster user response (don't wait for email)
- Reliable (retries if fails)
- Scalable (dedicated workers)
- Decoupled (job doesn't depend on web server)

**Common use cases:**
- Sending emails
- Generating reports
- Processing images
- Syncing with external APIs
- Heavy calculations

### 2. How do you create and enqueue background jobs with ActiveJob?

**Create a job:**
```ruby
# app/jobs/send_welcome_email_job.rb
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    WelcomeMailer.email(user).deliver_later
  end
end
```

**Enqueue a job:**
```ruby
# Enqueue immediately
SendWelcomeEmailJob.perform_now(user)

# Enqueue for later
SendWelcomeEmailJob.perform_later(user)

# Enqueue at specific time
SendWelcomeEmailJob.set(wait: 1.hour).perform_later(user)
SendWelcomeEmailJob.set(wait_until: Date.tomorrow.noon).perform_later(user)

# Enqueue with priority
SendWelcomeEmailJob.set(priority: 10).perform_later(user)
```

**Job with retry logic:**
```ruby
class ProcessPaymentJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(order)
    payment_service.charge(order)
  rescue StandardError => e
    Rails.logger.error("Payment failed: #{e.message}")
    raise  # Will retry
  end
end
```

**Job with error handling:**
```ruby
class SyncDataJob < ApplicationJob
  queue_as :default
  retry_on NetworkError, wait: 1.minute, attempts: 5
  discard_on ValidationError  # Don't retry, just log

  def perform(item_id)
    item = Item.find(item_id)
    SyncService.sync(item)
  end
end
```

### 3. What are different job queue backends (adapters)?

**Async (default for development):**
```ruby
# config/environments/development.rb
config.active_job.queue_adapter = :async

# Runs jobs in background threads (single process)
# Good for development, not production
```

**Inline (testing):**
```ruby
# config/environments/test.rb
config.active_job.queue_adapter = :inline

# Runs jobs immediately, synchronously
# Good for testing
```

**Delayed Job:**
```ruby
# Gemfile
gem 'delayed_job_active_record'

# config/environments/production.rb
config.active_job.queue_adapter = :delayed_job

# Stores jobs in database, runs with workers
# Good for small deployments
```

**Sidekiq (recommended for production):**
```ruby
# Gemfile
gem 'sidekiq'

# config/environments/production.rb
config.active_job.queue_adapter = :sidekiq

# Fast, scalable, requires Redis
# Best for production
```

**Resque:**
```ruby
# Gemfile
gem 'resque'

# config/environments/production.rb
config.active_job.queue_adapter = :resque

# Jobs stored in Redis
```

### 4. How do you ensure idempotency in background jobs?

**Idempotency** – Running a job multiple times produces the same result.

**Problem: Non-idempotent job**
```ruby
# Bad: running twice charges user twice
class ChargeUserJob < ApplicationJob
  def perform(user_id, amount)
    user = User.find(user_id)
    user.balance -= amount  # Problem: runs twice, charges twice
    user.save!
  end
end
```

**Solution 1: Idempotent key (prevent duplicates)**
```ruby
# Check if already processed
class ChargeUserJob < ApplicationJob
  def perform(user_id, amount, idempotency_key:)
    user = User.find(user_id)

    # Check if already charged
    charge = Charge.find_by(idempotency_key: idempotency_key)
    return if charge  # Already processed

    user.balance -= amount
    user.save!
    Charge.create(idempotency_key: idempotency_key, user_id: user_id)
  end
end

# Enqueue with key
ChargeUserJob.perform_later(user_id, amount, idempotency_key: "user_#{user_id}_charge_#{order_id}")
```

**Solution 2: Database-level uniqueness**
```ruby
class CreateOrderJob < ApplicationJob
  def perform(user_id, order_data)
    user = User.find(user_id)

    # Find or create (idempotent)
    order = Order.find_or_create_by(
      user_id: user_id,
      external_id: order_data[:external_id]
    ) do |order|
      order.amount = order_data[:amount]
      order.status = "pending"
    end
  end
end
```

**Solution 3: Database transaction with check**
```ruby
class UpdateInventoryJob < ApplicationJob
  def perform(product_id, quantity, transaction_id)
    Product.transaction do
      product = Product.lock.find(product_id)

      # Check if already processed
      return if product.transactions.exists?(transaction_id: transaction_id)

      product.quantity -= quantity
      product.save!
      product.transactions.create(transaction_id: transaction_id)
    end
  end
end
```

### 5. How do you handle errors and retries in background jobs?

**Retry on specific errors:**
```ruby
class FetchDataJob < ApplicationJob
  queue_as :default
  retry_on NetworkError, wait: 5.seconds, attempts: 3
  retry_on TimeoutError, wait: 1.minute, attempts: 5

  def perform(url)
    response = fetch_url(url)  # May raise NetworkError or TimeoutError
    process(response)
  end
end
```

**Discard on unrecoverable errors:**
```ruby
class ProcessReportJob < ApplicationJob
  retry_on StandardError, wait: 5.seconds, attempts: 3
  discard_on ActiveRecord::RecordNotFound  # Don't retry, record is gone

  def perform(report_id)
    report = Report.find(report_id)  # May not exist
    report.process!
  end
end
```

**Custom error handling:**
```ruby
class SendEmailJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    begin
      WelcomeMailer.email(user).deliver_later
    rescue Net::SMTPAuthenticationError => e
      Rails.logger.error("SMTP auth failed: #{e.message}")
      # Don't retry SMTP issues, log and move on
    rescue StandardError => e
      Rails.logger.error("Email failed: #{e.message}")
      raise  # Will trigger retry logic
    end
  end
end
```

**Retry with exponential backoff:**
```ruby
class SyncDataJob < ApplicationJob
  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  # Waits: 3s, 18s, 83s, 258s, 683s
end
```

### 6. How do you test background jobs?

**Testing in Rails:**
```ruby
require 'rails_helper'

describe SendWelcomeEmailJob, type: :job do
  describe "#perform_later" do
    it "enqueues the job" do
      expect {
        SendWelcomeEmailJob.perform_later(user)
      }.to have_been_enqueued.with(user)
    end

    it "is enqueued in the default queue" do
      expect {
        SendWelcomeEmailJob.perform_later(user)
      }.to have_been_enqueued.on_queue("default")
    end
  end

  describe "#perform" do
    it "sends welcome email" do
      expect {
        SendWelcomeEmailJob.perform_now(user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "handles missing user" do
      expect {
        SendWelcomeEmailJob.perform_now(nil)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
```

**Mock external services:**
```ruby
describe ProcessPaymentJob, type: :job do
  describe "#perform" do
    it "charges the order" do
      order = create(:order)
      service = double(charge: true)
      allow(PaymentService).to receive(:new).and_return(service)

      ProcessPaymentJob.perform_now(order)

      expect(service).to have_received(:charge).with(order)
    end
  end
end
```

### 7. What are best practices for background jobs?

**1. Keep jobs simple**
```ruby
# Bad: too much logic
class ComplexJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    user.validate_all_fields
    user.sync_with_api
    user.generate_reports
    user.send_notifications
  end
end

# Good: single responsibility
class SendNotificationJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    NotificationService.send(user)
  end
end
```

**2. Pass IDs, not objects**
```ruby
# Bad: serializing large objects
SendEmailJob.perform_later(user)  # Serializes entire user

# Good: pass ID
SendEmailJob.perform_later(user.id)

class SendEmailJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    # ...
  end
end
```

**3. Make jobs idempotent**
```ruby
# OK to run multiple times with same result
class UpdateCacheJob < ApplicationJob
  def perform(post_id)
    post = Post.find(post_id)
    Rails.cache.write("post_#{post_id}", post)  # Idempotent
  end
end
```

**4. Handle missing records**
```ruby
class ProcessOrderJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound  # Skip if order deleted

  def perform(order_id)
    order = Order.find(order_id)  # May raise RecordNotFound
    order.process!
  end
end
```

**5. Set appropriate timeouts**
```ruby
class LongRunningJob < ApplicationJob
  sidekiq_options lock: { time_limit: 1.hour, on_conflict: :replace }

  def perform
    # Will timeout after 1 hour
    long_operation
  end
end
```
