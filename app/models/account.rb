# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module LastWillFile
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_notes, class: :'LastWillFile::Note', key: :owner_id

    one_to_many :owned_existences, class: :'LastWillFile::Existence', key: :owner_id
    #plugin :association_dependencies, owned_notes: :destroy

    many_to_many :authorises,
                 class: :'LastWillFile::Note',
                 join_table: :accounts_notes,
                 left_key: :authorise_id, right_key: :note_id

    plugin :association_dependencies,
           owned_notes: :destroy,
           authorises: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def self.create_github_account(github_account)
      create(username: github_account[:username],
             email: github_account[:email])
    end

    def notes
      owned_notes + authorises
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = LastWillFile::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username: username,
            email: email
          }
        }, options
      )
    end
  end
end
