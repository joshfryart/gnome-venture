# Private test site: test.gnomeventure.ca

The same code runs on two sites:

- **gnomeventure.ca**: the live game (main site).
- **test.gnomeventure.ca**: a private copy for trying things out. Only the admin of the main site can get in, by
  pressing **Sign in with gnomeventure.ca** (single sign-on, SSO). There is no password form on the test site.

How it works: the main site's `sso_issue.php` gives a logged-in admin a signed token that lives 60 seconds and sends
the browser to `https://test.gnomeventure.ca/sso.php?t=<token>`. The test site checks the signature (HMAC-SHA256 with a
shared secret), the time, that the token is for its own host name, that the email is the one it was installed for,
and that the token has not been used before. Then it logs that admin in. Code: `game/includes/lockdown.php`.

## What you need

- A subdomain `test.gnomeventure.ca` with **its own document root** (for example `public_html/test` or `test.gnomeventure.ca/`),
  not inside the main site's folder, and HTTPS on it (Let's Encrypt in the host's control panel).
- PHP **8.1 or newer** (8.3 is what the tests use), with these extensions:
  `pdo` plus `pdo_mysql` (or `pdo_sqlite`), `mbstring`, `json`, `gd` (pictures), `zip` (Admin > Update), `session`.
  No `curl` or `openssl` needed.
- A **separate, empty MySQL database** and database user for the test site (never the main site's database).
  SQLite also works (`data/` must be writable), but MySQL matches the live site better.

## Set it up (in this order)

1. **Main site first.** Deploy the web-update zip that contains `sso_issue.php` to **gnomeventure.ca** (Admin > Update).
   Nothing changes on the main site until the SSO secret is set: `sso_issue.php` answers "Not found" while it is blank.
2. In the host's control panel make the subdomain `test.gnomeventure.ca`, its document root, its HTTPS certificate,
   and an empty MySQL database with a user that has all rights on it.
3. Upload the contents of the **install zip** (the whole `game/` folder) to the test site's document root.
4. Open `https://test.gnomeventure.ca/install.php`.
   - 1. Database: MySQL, with the new database's details.
   - 2. Your game: leave as is.
   - 3. Private test site: **ticked** (it is ticked by itself on a `test.` address). Main site address
     `https://gnomeventure.ca`. Main site admin email: the email of your admin account on gnomeventure.ca.
     How the admin signs in: **Sign in with the main site**. SSO secret: leave the one it made (48 characters).
   - 4. Your admin account: you may leave username and password blank (the account gets the email above and a random
     password nobody knows).
   - Press Install. The installer writes `config.php` with `lockdown`, `lockdown_email`, `sso_secret` and `sso_main`,
     sets email to "write to the mail log only", turns sign-ups and guests off and writes a `robots.txt` that says
     `Disallow: /`.
5. The done page shows the **SSO secret once**. Copy it. Then, on **gnomeventure.ca**, open
   **Admin > Game settings** (section Site, "Test site sign-in"), set **SSO secret** to that value and
   **SSO targets** to `test.gnomeventure.ca`. Save. (The secret field never shows the saved value; leave it blank to keep it.)
6. Log in on gnomeventure.ca as that admin. Open `https://test.gnomeventure.ca/login.php` and press
   **Sign in with gnomeventure.ca**. The first time, the test site makes its admin account and starts the welcome flow.
7. **Delete `install.php`** from the test site.

Updating the test site later: Admin > Update with the same web-update zip as the main site. `config.php` is never
touched by updates; if an update brings back the public `robots.txt`, the test site rewrites it on the next page load.

## Rotate the secret

Do this if the secret may have leaked, or now and then.

1. Make a new one: `php -r 'echo bin2hex(random_bytes(24)), "\n";'` (or any 48 random letters and numbers).
2. On the test site, edit `config.php` (by FTP / the file manager) and replace the value of `'sso_secret'`.
3. On gnomeventure.ca, Admin > Game settings: paste the new value into SSO secret and save.

Between steps 2 and 3 sign-in does not work; that is all. To switch SSO off on the main site, tick **Clear sso_secret**.

## Reset the test site

- **Start over:** empty (or drop and remake) the test database, delete `config.php` (and `data/game.sqlite` for SQLite),
  upload `install.php` again and run it. A new SSO secret is made: copy it to the main site again.
- **Locked out:** check that you are logged in on gnomeventure.ca as an *admin* whose email is exactly the
  `lockdown_email` in the test site's `config.php`, that the two secrets match, and that both servers' clocks are right
  (60 s token, 30 s allowed difference). Every refusal is written to the test site's `data/error-log.txt`
  ("SSO sign-in refused: <reason>"), without the token. Too many failed tries from one address wait 15 minutes.
- **Emergency password login:** in the test site's `config.php` change `'lockdown' => 'sso'` to `'lockdown' => 'admin'`.
  The normal form comes back, but only for the account with `lockdown_email`. That account's password is random,
  so set one first, for example with `php -r 'echo password_hash("a long new password", PASSWORD_DEFAULT);'` and an
  `UPDATE users SET password_hash = '...' WHERE email = '...'` in the database tool.
- **Open the test site to everyone** (not recommended): remove the four lockdown keys from `config.php`.

## Security notes

What the lockdown does:

- Every PHP page except `login.php`, `sso.php` and `logout.php` needs the admin whose email is `lockdown_email`.
  Anyone else gets a redirect to `login.php` (GET) or a 403 (POST and ajax). A session of any other account is signed out.
- `register.php`, `guest.php`, `forgot.php`, `reset.php` and `verify.php` answer 404. The login page has no password form
  (SSO mode) and POSTs to it are refused.
- Every PHP response carries `X-Robots-Tag: noindex, nofollow, noarchive` and `Cache-Control: private, no-store`;
  `robots.txt` says `Disallow: /`. Mail is only written to the mail log.
- Tokens: HMAC-SHA256 checked with `hash_equals`, 60 s life (30 s clock skew), bound to the test site's host name
  (`aud`), to one email, and usable once (used nonces are kept in the settings table until well after they expire).
  `sso_issue.php` only sends to hosts listed in SSO targets, never anywhere else. Failures look the same to the visitor
  and are rate-limited per address (10 in 15 minutes, 60 overall).
- The session cookie is HttpOnly, SameSite=Lax and Secure on HTTPS, as on the main site.

What it does **not** cover:

- **Static files** (`assets/`, pictures, `favicon.ico`, `robots.txt`, `manifest.json`) are served by the web server
  without PHP, so anyone who knows a path can fetch them. They are the same public files as the main site. For a
  noindex header on them as well, add to the test site's `.htaccess`:
  `Header set X-Robots-Tag "noindex, nofollow, noarchive"` (needs mod_headers).
- `install.php` left on the server (it refuses to run once `config.php` exists, but delete it anyway).
- Anyone with access to the main site's admin account (or its database, where `sso_secret` is stored) can sign in to the
  test site. Protect the main admin account with a long, unique password.
- Anyone with the test site's `config.php` can make tokens. Keep it private (the installer sets it to 0640).
- The test site must use its **own database**. Sharing the main database would mix players, settings and the lockdown.
  Because the test site has its own cookie domain (`test.gnomeventure.ca`), its login never affects the main site.
