# frozen_string_literal: true

module LastWillFile
    # Add a collaborator to another owner's existing project
    class AuthorizeAccount
      # Error if requesting to see forbidden account
      class ForbiddenError < StandardError
        def message
          'You are not allowed to access that account'
        end
      end

      def self.call(auth:, username:, auth_scope:)
        puts 'Entro 1'
        account = Account.first(username: username)
        puts 'Entro 2'
        policy = AccountPolicy.new(auth[:account], account)
        puts 'Entro 3'
        policy.can_view? ? account : raise(ForbiddenError)
        puts 'Entro 4'
        raise ForbiddenError unless policy.can_view?
        puts 'Entro 5'
        account_and_token(account, auth_scope)
      end

      def self.account_and_token(account, auth_scope)
        {
          type: 'authorized_account',
          attributes: {
            account: account,
            auth_token: AuthToken.create(account, auth_scope)
          }
        }
      end
    end
end
