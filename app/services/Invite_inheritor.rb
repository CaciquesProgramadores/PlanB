# frozen_string_literal: true

require 'http'

module LastWillFile
  # Send email verfification email
  class InviteInheritor
    # Error for invalid registration details
    class InvalidInvitation < StandardError; end

    #SENDGRID_URL = 'https://api.sendgrid.com/v3/mail/send'

    def initialize(config, auth, invitation_info)
      @config = config
      @auth  = auth
      @invitation_info = invitation_info
    end

    def call
      #raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidInvitation, 'Email already used') unless email_available?

      send_email_invitation
    end

    def call_rechecking
      #raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidInvitation, 'Email already used') unless email_available?
    end

    #def username_available?
      #Account.first(username: @invitation_info[:username]).nil?
    #end

    def email_available?
      Account.first(email: @invitation_info[:inh_email]).nil?
    end

    def email_body
      register_url = "#@invitation_info[:register_url]"

      <<~END_EMAIL
        <H1>Planb Invitation Received<H1>
        <p>You been invited to planb by a member with this email address " #{@auth[:account].email}Please <a href=\"#{@invitation_info[:verification_url]}\">click here</a> to validate your
        email. You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_invitation
      email = @invitation_info[:inh_email].strip
      HTTP.auth(
        "Bearer #{@config.SENDGRID_API_KEY}"
      ).post(
        @config.SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' =>  email }]
          }],
          from: { 'email' => 'noreply@planb.com' },
          subject: 'PlanB Invititation',
          content: [
            { type: 'text/html',
              value: email_body }
          ]
        }
      )
     # binding.pry
    rescue StandardError => e
     # binding.pry
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidInvitation,
            'Could not send invitation ; please check email address')
    end
    # rubocop:enable Metrics/MethodLength
  end
end
