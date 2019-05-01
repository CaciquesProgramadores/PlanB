#frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(authorise_id: :accounts, note_id: :notes)
  end
end