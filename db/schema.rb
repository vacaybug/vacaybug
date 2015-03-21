# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150319023059) do

  create_table "followers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.boolean  "blocked"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "followers", ["follower_id", "user_id"], :name => "index_followers_on_follower_id_and_user_id", :unique => true
  add_index "followers", ["follower_id"], :name => "index_followers_on_follower_id"
  add_index "followers", ["user_id"], :name => "index_followers_on_user_id"

  create_table "guide_place_associations", :force => true do |t|
    t.integer "guide_id"
    t.integer "place_id"
    t.integer "order_num"
    t.text    "note"
  end

  add_index "guide_place_associations", ["guide_id"], :name => "index_guide_place_associations_on_guide_id"
  add_index "guide_place_associations", ["place_id"], :name => "index_guide_place_associations_on_place_id"

  create_table "guides", :force => true do |t|
    t.integer  "privacy"
    t.string   "country"
    t.string   "city"
    t.string   "region"
    t.integer  "geonames_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "gn_data"
    t.integer  "popularity",  :default => 0
  end

  add_index "guides", ["geonames_id"], :name => "index_guides_on_geonames_id"
  add_index "guides", ["popularity", "geonames_id"], :name => "index_guides_on_popularity_and_geonames_id"
  add_index "guides", ["popularity"], :name => "index_guides_on_popularity"
  add_index "guides", ["user_id"], :name => "index_guides_on_user_id"

  create_table "notes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "place_id"
    t.string   "note"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "notes", ["place_id"], :name => "index_notes_on_place_id"
  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "places", :force => true do |t|
    t.text     "fs_data"
    t.string   "phone"
    t.string   "title"
    t.text     "address"
    t.integer  "geonames_id"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "fs_id"
    t.text     "yelp"
    t.text     "trip_advisor"
  end

  create_table "user_guide_associations", :force => true do |t|
    t.integer "user_id"
    t.integer "guide_id"
  end

  add_index "user_guide_associations", ["guide_id"], :name => "index_user_guide_associations_on_guide_id"
  add_index "user_guide_associations", ["user_id"], :name => "index_user_guide_associations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "website"
    t.string   "location"
    t.string   "photo_url"
    t.text     "tag_line"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "username"
    t.date     "birthday"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
