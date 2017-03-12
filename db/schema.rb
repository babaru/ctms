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

ActiveRecord::Schema.define(version: 20170312115853) do

  create_table "executions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "scenario_id"
    t.integer  "plan_id"
    t.integer  "result",                    default: 0
    t.text     "remarks",     limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["plan_id"], name: "index_executions_on_plan_id", using: :btree
    t.index ["scenario_id"], name: "index_executions_on_scenario_id", using: :btree
  end

  create_table "issue_labels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "label_id"
    t.integer  "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_labels_on_issue_id", using: :btree
    t.index ["label_id"], name: "index_issue_labels_on_label_id", using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "project_id"
    t.string   "name"
    t.text     "body",                  limit: 65535
    t.string   "gitlab_id"
    t.boolean  "is_existing_on_gitlab",               default: false
    t.integer  "milestone_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "gitlab_iid"
    t.string   "state"
    t.index ["milestone_id"], name: "index_issues_on_milestone_id", using: :btree
    t.index ["project_id"], name: "index_issues_on_project_id", using: :btree
  end

  create_table "labels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "color"
    t.integer  "project_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_requirement", default: false
    t.index ["project_id"], name: "index_labels_on_project_id", using: :btree
  end

  create_table "milestones", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description",           limit: 65535
    t.integer  "project_id"
    t.string   "gitlab_id"
    t.boolean  "is_existing_on_gitlab",               default: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "gitlab_iid"
    t.index ["project_id"], name: "index_milestones_on_project_id", using: :btree
  end

  create_table "plan_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "plan_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_plan_projects_on_plan_id", using: :btree
    t.index ["project_id"], name: "index_plan_projects_on_project_id", using: :btree
  end

  create_table "plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "state",                    default: 0
    t.text     "remarks",    limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "gitlab_id"
    t.boolean  "is_existing_on_gitlab", default: false
    t.string   "namespace"
    t.string   "path"
  end

  create_table "scenarios", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "issue_id"
    t.integer  "project_id"
    t.index ["issue_id"], name: "index_scenarios_on_issue_id", using: :btree
    t.index ["project_id"], name: "index_scenarios_on_project_id", using: :btree
  end

  create_table "user_watching_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_user_watching_plans_on_plan_id", using: :btree
    t.index ["user_id"], name: "index_user_watching_plans_on_user_id", using: :btree
  end

  create_table "user_watching_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_user_watching_projects_on_project_id", using: :btree
    t.index ["user_id"], name: "index_user_watching_projects_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "executions", "plans"
  add_foreign_key "executions", "scenarios"
  add_foreign_key "issue_labels", "issues"
  add_foreign_key "issue_labels", "labels"
  add_foreign_key "issues", "milestones"
  add_foreign_key "issues", "projects"
  add_foreign_key "labels", "projects"
  add_foreign_key "milestones", "projects"
  add_foreign_key "plan_projects", "plans"
  add_foreign_key "plan_projects", "projects"
  add_foreign_key "scenarios", "issues"
  add_foreign_key "scenarios", "projects"
  add_foreign_key "user_watching_plans", "plans"
  add_foreign_key "user_watching_plans", "users"
  add_foreign_key "user_watching_projects", "projects"
  add_foreign_key "user_watching_projects", "users"
end
