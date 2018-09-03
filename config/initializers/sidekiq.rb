Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.urls['redis_host'] }
  config.on(:startup) do
    job = Sidekiq::Cron::Job.find('cron_job').enque!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.urls['redis_host'] }
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end