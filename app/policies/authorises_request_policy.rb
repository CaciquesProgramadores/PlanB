# frozen_string_literal: true

module LastWillFile
  class AuthoriseRequestPolicy
    # Policy to determine if an account can view a particular note
    def initialize(note, requestor_account, target_account, auth_scope = nil)
      @note = note
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = NotePolicy.new(@requestor_account, @note, @auth_scope)
      @target = NotePolicy.new(@target_account, @note, @auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_authorises? && @target.can_be_authorised?)
        binding.pry
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_authorises? && target_is_authorises?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('notes') : false
    end

    def target_is_authorises?
      @note.authorises.include?(@target_account)
    end
  end
end
