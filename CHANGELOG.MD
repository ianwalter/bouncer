# Changes to bouncer

## v0.1.0

* #1: Add ability to set the lifetime of a session. Users can now pass ttl as
  the third parameter to Bouncer.Session.create.
* #2: Add ability to easily invalidate all sessions. Added
  Bouncer.Session.destroy_all function.
* #3: Add email verification functionality. Users can now use the
  Bouncer.EmailVerification module to generate email verification tokens.
* #4: Add password reset functionality. Users can now use the
  Bouncer.PasswordReset module to generate password reset tokens.
* #5: Use real Redis instance for testing. Also added a Supervisor and
  RedixPool module so that it's easier for users to get started.
* #10: Use private instead of assigns as suggested by Plug documentation.
* #11: Mock Endpoint instead of Phoenix.Token.

## v0.0.6

* Fixed a bug where Session.delete wasn't pattern matching correctly and so
wasn't returning the correct response.

## v0.0.5

* Changed Session.user_request? convenience function to accept an `id` parameter
of type bitstring in addition to integer.
