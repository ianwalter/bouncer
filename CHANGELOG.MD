# Changes to bouncer

## v0.3.0

* Change Authorization header to accept "Bearer $token" instead of
  "Bearer: $token" since the former is the actual standard pattern.

## v0.2.0

* Move from atom-keyed to string-keyed maps [#17](https://github.com/ianwalter/bouncer/issues/17)
* Ensure tokens are URL-safe [#15](https://github.com/ianwalter/bouncer/issues/15)

## v0.1.6

* Updating poison dependency from "~> 1.5" to "~> 1.5 or ~> 2.0" and phoenix
  dependency to >= 1.2.1

##  v0.1.5

* Adding Utility module and debug_piped function so that users can see result
  of auth token verification when logger is set to debug.
* Updating plug dependency so that (hopefully) generated tokens are URL-safe.
* Changing adapter to be a function instead of module property so that it
  can be changed after being compiled.
* Reorganizing lib directory.

## v0.1.4

* #13: Use Poison instead of HTTPoison.
* #14: Only include environment config file if Mix.env is :test.

## v0.1.3

* Adding sleep calls in tests between token generation to ensure tokens are
  unique.
* Adding destroy function to EmailVerification and PasswordReset modules.

## v0.1.2

* Adding `init/1` back to the Authorize plug after being accidentally removed.
* Clearing up some documentation within Bouncer.EmailVerification.

## v0.1.1

* Bumping required Elixir version to 1.1.1 because of odd behavior on 1.0.5.
* Fixing link to Bouncer.Session documentation in README.
* Cleaning up RedixPool config.
* Cleaning up Bouncer.Token delete_all and regenerate functions.

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
