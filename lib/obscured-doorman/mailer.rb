module Obscured
  module Doorman
    class Mailer
      def initialize(opts = {})
        @to = opts[:to]
        @from = "doorman@#{Obscured::Doorman.configuration.smtp_domain}"
        @subject = opts[:subject]

        @text = opts[:text]
        @html = opts[:html]
      end

      def deliver!
        Obscured.logger.debug "Sending mail to #{@to}, from: #{@from}, with subject: #{@subject}"
        mail = Mail.new(to: @to, from: @from, subject: @subject) do
          delivery_method :smtp,
                          address: Obscured::Doorman.configuration.smtp_server,
                          port: Obscured::Doorman.configuration.smtp_port,
                          domain: Obscured::Doorman.configuration.smtp_domain,
                          enable_starttls_auto: true,
                          authentication: :plain,
                          user_name: Obscured::Doorman.configuration.smtp_username,
                          password: Obscured::Doorman.configuration.smtp_password
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
        Obscured.logger.error e
      end
    end
  end
end