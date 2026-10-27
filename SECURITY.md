# Security Policy

## Supported versions

Only the latest release is supported with security fixes. Please update to the newest version (see [CHANGELOG.md](CHANGELOG.md)) before reporting, and say which version you tested.

## Reporting a vulnerability

Please report privately. Do not open a public issue or post details publicly.

- Preferred: GitHub private vulnerability reporting, at <https://github.com/joshfryart/gnome-venture/security/advisories/new> (the Security tab of the repository).
- Or email hello@joshfry.art.

Include what you found, the steps to reproduce it, the version, and the impact you expect. Never include real player data or credentials.

This is a small hobby project run by one person. You can expect:
- An acknowledgement within about 7 days.
- A follow-up on whether it is accepted or declined, and a fix in a later release where it is accepted. No fixed timeline is promised, though serious issues are handled first.
- Credit in the changelog if you want it.

## Scope

In scope: the PHP code in this repository (`game/`), including accounts and sessions, CSRF, XSS, SQL injection, access control, uploads, the admin panel and the in-place updater.

Out of scope: your own host or server configuration, a live install that still has `install.php` or a weak admin password, denial of service by volume, social engineering, and issues that need access to `config.php` or the server already. Please test only on your own install, not on the live site at gnomeventure.ca.
