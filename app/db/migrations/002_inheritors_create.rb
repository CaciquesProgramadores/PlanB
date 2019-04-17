# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:inheritors) do
      primary_key :id
      foreign_key :note_id, table: :notes

      String :description
      String :relantionship, null: false
      String :emails, null: false
      String :phones, null: false
      String :nickname
      String :pgp
      String :fullname, null: false 

      DateTime :created_at
      DateTime :updated_at

      unique [:note_id, :emails, :phones]
    end
  end
end
