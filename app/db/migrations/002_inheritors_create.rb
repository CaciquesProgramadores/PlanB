# frozen_string_literal: true

require 'sequel'
require 'securerandom'

Sequel.migration do
  change do
    create_table(:inheritors) do
      uuid :id, primary_key: true
      foreign_key :note_id, :notes

      String :description_secure
      String :relantionship_secure, null: false
      String :emails, null: false
      String :phones, null: false
      String :nickname
      String :pgp
      String :fullname, null: false
 
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
