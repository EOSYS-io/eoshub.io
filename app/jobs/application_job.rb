class ApplicationJob
  include Sidekiq::Worker
  include Loggable
end