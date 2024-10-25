# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_10_134831) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "applicants", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "ni_number"
    t.boolean "married"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "ho_number"
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.string "partner_ni_number"
    t.date "partner_date_of_birth"
    t.boolean "over_16"
    t.index ["application_id"], name: "index_applicants_on_application_id"
    t.index ["first_name"], name: "index_applicants_on_first_name"
    t.index ["last_name"], name: "index_applicants_on_last_name"
    t.index ["ni_number"], name: "index_applicants_on_ni_number"
  end

  create_table "applications", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.integer "office_id"
    t.decimal "threshold"
    t.boolean "threshold_exceeded"
    t.boolean "partner_over_66"
    t.boolean "benefits"
    t.integer "children"
    t.integer "income"
    t.boolean "dependents"
    t.string "application_type"
    t.string "outcome"
    t.decimal "amount_to_pay"
    t.boolean "high_threshold_exceeded"
    t.string "reference"
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.string "decision"
    t.string "decision_type"
    t.integer "state", default: 0, null: false
    t.string "deleted_reason"
    t.datetime "deleted_at", precision: nil
    t.integer "deleted_by_id"
    t.integer "business_entity_id"
    t.datetime "decision_date", precision: nil
    t.decimal "decision_cost"
    t.integer "online_application_id"
    t.boolean "income_min_threshold_exceeded"
    t.boolean "income_max_threshold_exceeded"
    t.decimal "income_min_threshold"
    t.decimal "income_max_threshold"
    t.string "medium"
    t.string "income_kind"
    t.boolean "purged", default: false
    t.date "purged_at"
    t.text "children_age_band"
    t.string "income_period"
    t.index ["business_entity_id"], name: "index_applications_on_business_entity_id"
    t.index ["created_at"], name: "index_applications_on_created_at"
    t.index ["decision_cost"], name: "index_applications_on_decision_cost"
    t.index ["decision_date"], name: "index_applications_on_decision_date"
    t.index ["office_id"], name: "index_applications_on_office_id"
    t.index ["online_application_id"], name: "index_applications_on_online_application_id"
    t.index ["reference"], name: "index_applications_on_reference", unique: true
    t.index ["state"], name: "index_applications_on_state"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "audit_personal_data_purges", force: :cascade do |t|
    t.date "purged_date"
    t.string "application_reference_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "benefit_checks", id: :serial, force: :cascade do |t|
    t.string "last_name"
    t.date "date_of_birth"
    t.string "ni_number"
    t.date "date_to_check"
    t.string "parameter_hash"
    t.boolean "benefits_valid"
    t.string "dwp_result"
    t.string "error_message"
    t.string "dwp_api_token"
    t.string "our_api_token"
    t.integer "application_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "api_response"
    t.integer "applicationable_id"
    t.string "applicationable_type"
    t.index ["application_id"], name: "index_benefit_checks_on_application_id"
    t.index ["applicationable_id", "applicationable_type"], name: "index_bc_applicationable_id_type"
    t.index ["user_id"], name: "index_benefit_checks_on_user_id"
  end

  create_table "benefit_overrides", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.boolean "correct"
    t.integer "completed_by_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "incorrect_reason"
    t.index ["application_id"], name: "index_benefit_overrides_on_application_id"
  end

  create_table "business_entities", id: :serial, force: :cascade do |t|
    t.integer "office_id", null: false
    t.integer "jurisdiction_id", null: false
    t.string "be_code"
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "valid_from", precision: nil
    t.datetime "valid_to", precision: nil
    t.string "sop_code"
    t.index ["jurisdiction_id"], name: "index_business_entities_on_jurisdiction_id"
    t.index ["name"], name: "index_business_entities_on_name"
    t.index ["office_id", "jurisdiction_id", "valid_to"], name: "unique_active_office_jurisdiction", unique: true
    t.index ["office_id"], name: "index_business_entities_on_office_id"
  end

  create_table "decision_overrides", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "application_id"
    t.string "reason"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_decision_overrides_on_application_id"
    t.index ["user_id"], name: "index_decision_overrides_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "details", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.decimal "fee"
    t.integer "jurisdiction_id"
    t.date "date_received"
    t.string "form_name"
    t.string "case_number"
    t.boolean "probate"
    t.string "deceased_name"
    t.date "date_of_death"
    t.boolean "refund"
    t.date "date_fee_paid"
    t.string "emergency_reason"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "discretion_applied"
    t.string "discretion_manager_name"
    t.string "discretion_reason"
    t.string "fee_manager_firstname"
    t.string "fee_manager_lastname"
    t.string "calculation_scheme"
    t.string "statement_signed_by"
    t.index ["application_id"], name: "index_details_on_application_id"
    t.index ["case_number"], name: "index_details_on_case_number"
    t.index ["fee"], name: "index_details_on_fee"
  end

  create_table "dwp_warnings", id: :serial, force: :cascade do |t|
    t.string "check_state", default: "default_checker"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "evidence_check_flags", id: :serial, force: :cascade do |t|
    t.string "reg_number"
    t.boolean "active", default: true
    t.integer "count"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reg_number", "active"], name: "evidence_check_flags_active_unique", unique: true, where: "(active = true)"
  end

  create_table "evidence_checks", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "expires_at", precision: nil, null: false
    t.boolean "correct"
    t.integer "income"
    t.string "outcome"
    t.decimal "amount_to_pay"
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.string "incorrect_reason"
    t.string "check_type"
    t.string "incorrect_reason_category"
    t.string "staff_error_details"
    t.string "checks_annotation"
    t.string "income_check_type"
    t.index ["application_id"], name: "index_evidence_checks_on_application_id"
  end

  create_table "export_file_storages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "feature_switchings", force: :cascade do |t|
    t.string "feature_key", null: false
    t.datetime "activation_time"
    t.integer "office_id"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key"], name: "index_feature_switchings_on_feature_key", unique: true
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.string "experience"
    t.string "ideas"
    t.integer "rating"
    t.string "help"
    t.integer "user_id"
    t.integer "office_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["office_id"], name: "index_feedbacks_on_office_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "hmrc_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "call_params"
    t.integer "hmrc_check_id", null: false
    t.string "endpoint_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hmrc_checks", force: :cascade do |t|
    t.integer "evidence_check_id", null: false
    t.integer "user_id"
    t.string "ni_number"
    t.string "date_of_birth"
    t.text "address"
    t.text "employment"
    t.text "income"
    t.text "tax_credit"
    t.string "error_response"
    t.string "request_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "purged_at", precision: nil
    t.integer "additional_income", default: 0
    t.string "sa_income"
    t.string "check_type", default: "applicant"
  end

  create_table "hmrc_tokens", force: :cascade do |t|
    t.string "encrypted_access_token"
    t.datetime "expires_in", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jurisdictions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.boolean "active"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.text "message"
    t.boolean "show", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "office_jurisdictions", id: false, force: :cascade do |t|
    t.integer "office_id", null: false
    t.integer "jurisdiction_id", null: false
    t.index ["office_id", "jurisdiction_id"], name: "index_office_jurisdictions_on_office_id_and_jurisdiction_id"
  end

  create_table "offices", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "entity_code"
  end

  create_table "online_applications", id: :serial, force: :cascade do |t|
    t.boolean "married", null: false
    t.boolean "min_threshold_exceeded", null: false
    t.boolean "benefits", null: false
    t.integer "children"
    t.integer "income"
    t.boolean "refund", null: false
    t.date "date_fee_paid"
    t.boolean "probate"
    t.string "deceased_name"
    t.date "date_of_death"
    t.string "case_number"
    t.string "form_name"
    t.string "ni_number"
    t.date "date_of_birth", null: false
    t.string "title"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.text "address", null: false
    t.string "postcode", null: false
    t.boolean "email_contact", null: false
    t.string "email_address"
    t.boolean "phone_contact", null: false
    t.string "phone"
    t.boolean "post_contact", null: false
    t.string "reference"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "fee"
    t.integer "jurisdiction_id"
    t.text "emergency_reason"
    t.boolean "feedback_opt_in", null: false
    t.date "date_received"
    t.boolean "max_threshold_exceeded"
    t.boolean "over_66"
    t.integer "amount"
    t.boolean "income_min_threshold_exceeded"
    t.boolean "income_max_threshold_exceeded"
    t.string "fee_manager_firstname"
    t.string "fee_manager_lastname"
    t.string "ho_number"
    t.string "income_kind"
    t.boolean "benefits_override", default: false
    t.boolean "purged", default: false
    t.date "purged_at"
    t.integer "user_id"
    t.string "applying_method"
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.date "partner_date_of_birth"
    t.string "children_age_band"
    t.string "calculation_scheme"
    t.string "applying_on_behalf"
    t.string "partner_ni_number"
    t.boolean "legal_representative"
    t.string "legal_representative_first_name"
    t.string "legal_representative_last_name"
    t.string "legal_representative_email"
    t.string "legal_representative_organisation_name"
    t.string "legal_representative_feedback_opt_in"
    t.string "legal_representative_street"
    t.string "legal_representative_postcode"
    t.string "legal_representative_town"
    t.string "legal_representative_address"
    t.boolean "over_16"
    t.string "statement_signed_by"
    t.string "income_period"
    t.string "legal_representative_position"
    t.boolean "discretion_applied"
    t.index ["jurisdiction_id"], name: "index_online_applications_on_jurisdiction_id"
    t.index ["reference"], name: "index_online_applications_on_reference", unique: true
  end

  create_table "online_failures", id: :serial, force: :cascade do |t|
    t.text "received_data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "part_payments", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "correct"
    t.string "incorrect_reason"
    t.datetime "completed_at", precision: nil
    t.integer "completed_by_id"
    t.string "outcome"
    t.index ["application_id"], name: "index_part_payments_on_application_id"
  end

  create_table "representatives", force: :cascade do |t|
    t.integer "application_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "organisation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
  end

  create_table "savings", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.decimal "min_threshold"
    t.boolean "min_threshold_exceeded"
    t.decimal "max_threshold"
    t.boolean "max_threshold_exceeded"
    t.decimal "amount"
    t.boolean "passed"
    t.decimal "fee_threshold"
    t.boolean "over_66"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "choice"
    t.index ["application_id"], name: "index_savings_on_application_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "role", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.string "name"
    t.integer "office_id", null: false
    t.integer "jurisdiction_id"
    t.datetime "deleted_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "unique_session_id"
    t.datetime "last_password_reset_check_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applicants", "applications", on_update: :cascade
  add_foreign_key "applications", "business_entities", on_update: :cascade
  add_foreign_key "applications", "offices", on_update: :cascade
  add_foreign_key "applications", "online_applications", on_update: :cascade
  add_foreign_key "applications", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "applications", "users", column: "deleted_by_id", on_update: :cascade
  add_foreign_key "applications", "users", on_update: :cascade
  add_foreign_key "benefit_checks", "applications", on_update: :cascade
  add_foreign_key "benefit_checks", "users", on_update: :cascade
  add_foreign_key "benefit_overrides", "applications", on_update: :cascade
  add_foreign_key "benefit_overrides", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "business_entities", "jurisdictions", on_update: :cascade
  add_foreign_key "business_entities", "offices", on_update: :cascade
  add_foreign_key "decision_overrides", "applications"
  add_foreign_key "decision_overrides", "users"
  add_foreign_key "details", "applications", on_update: :cascade
  add_foreign_key "details", "jurisdictions", on_update: :cascade
  add_foreign_key "evidence_checks", "applications", on_update: :cascade
  add_foreign_key "evidence_checks", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "feedbacks", "offices", on_update: :cascade
  add_foreign_key "feedbacks", "users", on_update: :cascade
  add_foreign_key "office_jurisdictions", "jurisdictions", on_update: :cascade
  add_foreign_key "office_jurisdictions", "offices", on_update: :cascade
  add_foreign_key "online_applications", "jurisdictions", on_update: :cascade
  add_foreign_key "part_payments", "applications", on_update: :cascade
  add_foreign_key "part_payments", "users", column: "completed_by_id", on_update: :cascade
  add_foreign_key "savings", "applications"
  add_foreign_key "users", "jurisdictions", on_update: :cascade
  add_foreign_key "users", "offices", on_update: :cascade
end
