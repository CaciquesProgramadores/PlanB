# frozen_string_literal: true

module LastWillFile
  # Policy to determine if an account can view a particular note
  class AuthoriseRequestPolicy
    def initialize(note, requestor_account, target_account)
      @note = note
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = NotePolicy.new(requestor_account, note)
      @target = NotePolicy.new(target_account, note)
    end

    def can_invite?
      @requestor.can_add_authorises? && @target.can_be_authorised?
    end

    def can_remove?
      @requestor.can_remove_authorises? && target_is_authorises?
    end

    private

    def target_is_authorises?
      @note.authorises.include?(@target_account)
    end
  end
end
