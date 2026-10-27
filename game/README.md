# Gnome Venture: the `game/` folder

This folder is the web root of Gnome Venture (gnomeventure.ca), a cosy garden browser game in plain PHP 8.1+ with PDO. No framework, no build step.

- What the game is, its systems, conventions and release process: see the [root README](../README.md).
- What changed in each release, and the current version: see the [CHANGELOG](../CHANGELOG.md). The version is defined once, as `APP_VERSION` in `includes/bootstrap.php`; this file deliberately carries no version number.

## Install on a web host
1. Use hosting with PHP 8.1+ and MySQL. Create a MySQL database and a user with all rights on it.
2. Upload the contents of this folder to `public_html` (or a sub-folder).
3. Open `https://yoursite/install.php`, fill in the form and press Install. It creates the tables, starter content and your admin account, and writes `config.php`.
4. Delete `install.php` from the server (the admin dashboard reminds you).
5. Turn on HTTPS.

For a local try-out, run `php -S localhost:8000` in this folder, open `/install.php` and choose SQLite. Delete `config.php` and `data/game.sqlite` to start over. The automated test suites are described in the root README.

## Updating
Use Admin → Update with the update zip (it backs up first and never touches `config.php`, `install.php`, `data/` or `uploads/`), or upload the files by FTP. The database upgrades itself on the first request after the version changes.

## Layout
- `includes/`: game code, locked from the web. `includes/data/*.txt` is shipped content (importers add missing rows only).
- `admin/`: the admin panel. `assets/`: CSS, JS and art. `data/`: runtime cache, backups and logs, denied to the web.
- `config.php` holds database and SMTP details. Never share or commit it.

## Security
See [SECURITY.md](../SECURITY.md) for supported versions and how to report a vulnerability. Use a long, unique admin password.
