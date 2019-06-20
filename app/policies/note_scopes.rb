# frozen_string_literal: true

module LastWillFile
  # Policy to determine if account can view a note
  class NotePolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_notes(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |proj|
            includes_executor?(proj, @current_account)
          end
        end
      end

      private

      def all_notes(account)
        account.owned_notes + account.executors
      end

      def includes_executor?(note, account)
        note.executors.include? account
      end
    end
  end
end