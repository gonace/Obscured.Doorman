# frozen_string_literal: true

module Obscured
  module Doorman
    class Mailer
      def initialize(opts = {})
        @to = opts[:to]
        @from = "doorman@#{Doorman.configuration.smtp_domain}"
        @subject = opts[:subject]

        @text = opts[:text]
        @html = opts[:html]
      end

      def deliver!
        Doorman.logger.debug "Sending mail to #{@to}, from: #{@from}, with subject: #{@subject}"
        mail = Mail.new(to: @to, from: @from, subject: @subject) do
          delivery_method :smtp,
                          address: Doorman.configuration.smtp_server,
                          port: Doorman.configuration.smtp_port,
                          domain: Doorman.configuration.smtp_domain,
                          enable_starttls_auto: true,
                          authentication: :plain,
                          user_name: Doorman.configuration.smtp_username,
                          password: Doorman.configuration.smtp_password
        end

        unless @text.blank?
          text_part = Mail::Part.new(body: @text)
          mail.text_part = text_part
        end

        unless @html.blank?
          html_part = Mail::Part.new(body: @html) do
            content_type 'text/html; charset=utf-8'
          end
          mail.html_part = html_part
        end

        mail.deliver
      rescue => e
        Doorman.logger.error e
      end
    end
  end
end