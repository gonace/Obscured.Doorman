# frozen_string_literal: true

module Obscured
  module Doorman
    MESSAGES = {
      auth_required: 'You must be logged in to view this page.',
      signup_disabled: 'Registration is disabled, contact team member for creation of account!',
      signup_success: 'You have signed up successfully. A confirmation email has been sent to you.',
      confirm_no_user: 'Invalid confirmation URL. Please make sure you have the correct link from the email, and are not already confirmed.',
      confirm_success: 'You have successfully confirmed your account. Please log in.',
      # Auto login upon confirmation?
      login_bad_credentials: 'Invalid Login and Password. Please try again.',
      login_not_confirmed: 'You must confirm your account before you can log in. Please click the confirmation link sent to you.',
      # Note: resend confirmation link?
      logout_success: 'You have been logged out.',
      forgot_no_user: 'There is no user with that Username or Email. Please try again.',
      forgot_success: 'An email with instructions to reset your password has been sent to you.',
      reset_no_user: 'Invalid reset URL. Please make sure you have the correct link from the email, and have already reset the password.',
      reset_system_user: 'Your trying to reset the password of a system user, unfortunate for you, this action is not allowed',
      reset_unmatched_passwords: 'Password and confirmation do not match. Please try again.',
      reset_success: 'Your password has been reset.',
      # Registration
      register_account_exists: 'Account already registered.',
      # Token
      token_used: 'The token has already been used, request a new token and try again.',
      token_expired: 'The token has expired, request a new token and try again.',
      token_not_found: 'The token was not found, request a new token and try again.'
    }.freeze
  end
end
