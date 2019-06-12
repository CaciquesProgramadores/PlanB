# frozen_string_literal: true

module LastWillFile
  # Policy to determine if an account can view a particular note
  class NotePolicy
    def initialize(account, note, auth_scope = nil)
      @account = account
      @note = note
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_authorises?)
    end

    def can_edit?
      can_write? && (account_is_owner? || account_is_authorises?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_authorises?
    end

    def can_add_inheritors?
      can_write? && (account_is_owner? || account_is_authorises?)
    end

    def can_remove_inheritors?
      can_write? && (account_is_owner? || account_is_authorises?)
    end

    def can_add_authorises?
      account_is_owner?
    end

    def can_remove_authorises?
      account_is_owner?
    end

    def can_be_authorised?
      #not (account_is_owner? or account_is_authorises?)
      !(account_is_owner? || account_is_authorises?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_inheritors: can_add_inheritors?,
        can_delete_inheritors: can_remove_inheritors?,
        can_add_authorises: can_add_authorises?,
        can_remove_authorises: can_remove_authorises?,
        can_be_authorised: can_be_authorised?
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
      @note.owner == @account
    end

    def account_is_authorises?
      @note.authorises.include?(@account)
    end
  end
end
