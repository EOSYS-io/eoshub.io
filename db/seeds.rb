# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# 1m, 5m, 30m, 1h, 4h, 1d, 1w.
price_intvl_list_as_seconds = [
  60, 300, 900, 1800, 3600, 14400, 86400, 604800
]

price_intvl_list_as_seconds.each do | intvl | 
  PriceHistoryIntvl.create(seconds: intvl)
end