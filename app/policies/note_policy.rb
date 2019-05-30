# frozen_string_literal: true

module LastWillFile
  # Policy to determine if an account can view a particular note
  class NotePolicy
    def initialize(account, note)
      @account = account
      @note = note
    end

    def can_view?
      account_is_owner? || account_is_authorises?
    end

    def can_edit?
      account_is_owner? || account_is_authorises?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_authorises?
    end

    def can_add_inheritors?
      account_is_owner? || account_is_authorises?
    end

    def can_remove_inheritors?
      account_is_owner? || account_is_authorises?
    end

    def can_add_authorises?
      account_is_owner?
    end

    def can_remove_authorises?
      account_is_owner?
    end

    def can_be_authorised?
      not (account_is_owner? or account_is_authorises?)
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

    def account_is_owner?
      @note.owner == @account
    end

    def account_is_authorises?
      @note.authorises.include?(@account)
    end
  end
end
