# frozen_string_literal: true
require 'pry'
module LastWillFile
  # Policy to determine if an account can view a particular note
  class NotePolicy
    def initialize(account, note, auth_scope = nil)
      @account = account
      @note = note
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_executors?)
    end

    def can_edit?
      can_write? && (account_is_owner? || account_is_executors?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_executors?
    end

    def can_add_inheritors?
      can_write? && (account_is_owner? || account_is_executors?)
    end

    def can_remove_inheritors?
      can_write? && (account_is_owner? || account_is_executors?)
    end

    def can_add_executors?
      account_is_owner?
    end

    def can_remove_executors?
      account_is_owner?
    end

    def can_remove_notes?
      can_write? && account_is_owner?
    end

    def can_be_executord?
      #not (account_is_owner? or account_is_executors?)
      !(account_is_owner? || account_is_executors?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_inheritors: can_add_inheritors?,
        can_delete_inheritors: can_remove_inheritors?,
        can_add_executors: can_add_executors?,
        can_remove_executors: can_remove_executors?,
        can_remove_notes: can_remove_notes?,
        can_be_executord: can_be_executord?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('notes') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('notes') : false
    end

    def account_is_owner?
      @note.owner_id == @account.id
    end

    def account_is_executors?
      @note.executors.include?(@account)
    end
  end
end
