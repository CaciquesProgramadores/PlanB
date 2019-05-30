# frozen_string_literal: true

 # Policy to determine if account can view a inheritor
class InheritorPolicy
  def initialize(account, inheritor)
    @account = account
    @inheritor = inheritor
  end

  def can_view?
    account_owns_note? || account_authorises_on_note?
  end

  def can_edit?
    account_owns_note? || account_authorises_on_note?
  end

  def can_delete?
    account_owns_note? || account_authorises_on_note?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_note?
    @inheritor.note.owner == @account
  end

  def account_authorises_on_note?
    @inheritor.note.authorises.include?(@account)
  end
end
