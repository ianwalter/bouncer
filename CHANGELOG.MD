# Changes to bouncer

## v0.0.6

* Fixed a bug where Session.delete wasn't pattern matching correctly and so
wasn't returning the correct response.

## v0.0.5

* Changed Session.user_request? convenience function to accept an `id` parameter
of type bitstring in addition to integer.
