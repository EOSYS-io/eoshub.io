# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_22_013039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_admin_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "eos_ram_price_histories", force: :cascade do |t|
    t.integer "intvl", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.decimal "open", precision: 38, scale: 8, null: false
    t.decimal "close", precision: 38, scale: 8, null: false
    t.decimal "high", precision: 38, scale: 8, null: false
    t.decimal "low", precision: 38, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intvl", "start_time"], name: "index_eos_ram_price_histories_on_intvl_and_start_time", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "state", default: 0, null: false
    t.integer "pgcode", default: 0, null: false
    t.string "order_no", null: false
    t.integer "amount", null: false
    t.string "product_name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_no", default: "", comment: "virtual account number"
    t.string "account_name", comment: "the name of the payer who issued the virtual account"
    t.string "bank_code", comment: "Virtual account bank code"
    t.string "bank_name", comment: "Virtual account bank name"
    t.date "expire_date", comment: "expiration date of the virtual account"
    t.string "eos_account", default: "", null: false
    t.string "public_key", default: "", null: false
    t.string "return_code", default: ""
    t.string "return_message", default: ""
    t.string "tid", default: ""
    t.index ["eos_account"], name: "index_orders_on_eos_account"
    t.index ["order_no"], name: "index_orders_on_order_no"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_results", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "tid"
    t.string "cid"
    t.string "pay_info"
    t.datetime "transaction_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", default: ""
    t.string "message", default: ""
    t.string "payhash", default: ""
    t.string "user_id", default: ""
    t.string "amount", default: ""
    t.index ["order_id"], name: "index_payment_results_on_order_id"
  end

  create_table "price_history_intvls", primary_key: "seconds", id: :serial, force: :cascade do |t|
  end

  create_table "producers", primary_key: "owner", id: :string, force: :cascade do |t|
    t.float "total_votes", null: false
    t.string "producer_key", null: false
    t.integer "location", null: false
    t.string "url"
    t.string "logo_image_url"
    t.string "last_claim_time"
    t.integer "unpaid_blocks", null: false
    t.boolean "is_active", default: true, null: false
    t.integer "rank", null: false
    t.integer "prev_rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country", default: ""
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "event_activation", default: false, null: false
    t.float "cpu", default: 0.0
    t.float "net", default: 0.0
    t.integer "ram", default: 0
    t.index ["name"], name: "index_products_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "confirm_token", limit: 22, default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0
    t.string "eos_account"
    t.datetime "confirm_token_created_at"
    t.string "ip_address", default: "", null: false
    t.index ["confirm_token"], name: "index_users_on_confirm_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["eos_account"], name: "index_users_on_eos_account", unique: true
  end

  create_table "vote_stats", force: :cascade do |t|
    t.float "total_voted_eos", null: false
    t.float "total_staked_eos", null: false
    t.float "eosys_proxy_staked_eos", null: false
    t.integer "eosys_proxy_staked_account_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
