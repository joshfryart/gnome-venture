#!/usr/bin/env bash
# Private test site lockdown + SSO (includes/lockdown.php, sso_issue.php, mainlogin.php). Unit checks (sso_lockdown.php), then HTTP checks on a walk.sh install
# (admin "admin", player "sprout"): first as the main site (sso_issue.php), then with lockdown keys written into config.php (sso mode, then admin mode).
# Usage: sso_lockdown.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3
HERE=$(cd "$(dirname "$0")" && pwd)
TD="${TMPDIR:-/tmp}"
FAILS=0
php -d session.save_path=/tmp $HERE/sso_lockdown.php $GAME || FAILS=$((FAILS+1))

BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d opcache.revalidate_freq=0 -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/sso-php.log 2>&1 &
PID=$!
trap "kill $PID 2>/dev/null" EXIT
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/login.php" && break; sleep 0.2; done
ok() { if [ "$2" = "1" ]; then echo "ok   $1"; else echo "FAIL $1  ($3)"; FAILS=$((FAILS+1)); fi; }
is() { [ "$1" = "$2" ] && echo 1 || echo 0; }
has() { grep -q -- "$2" "$1" && echo 1 || echo 0; }
code() { curl -s -o $TD/sso.html -D $TD/sso.hdr -w '%{http_code}' "$@"; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
login() {   # login COOKIEJAR USER PASS -> http code of the POST
  curl -s -c $1 -b $1 "$BASE/login.php" -o $TD/sso-login.html
  curl -s -c $1 -b $1 -X POST "$BASE/login.php" --data-urlencode "csrf=$(csrf $TD/sso-login.html)" --data-urlencode "username=$2" --data-urlencode "password=$3" -o $TD/sso-login-post.html -w '%{http_code}'
}
sqlq() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
conf() {   # (the server runs with opcache.revalidate_freq=0 so a rewritten config.php is read at once) conf '{json of keys to add}' (or '{}' to strip the lockdown keys)
  php -r '$f=$argv[1]; $c=require $f; foreach(["lockdown","lockdown_email","sso_secret","sso_main"] as $k) unset($c[$k]); $c=array_merge($c,json_decode($argv[2],true)); file_put_contents($f,"<?php\nreturn ".var_export($c,true).";\n");' "$GAME/config.php" "$1"
}
A=$TD/sso-admin.ck; P=$TD/sso-sprout.ck; N=$TD/sso-anon.ck; rm -f $A $P $N
SECRET=$(php -r 'echo bin2hex(random_bytes(24));')
cp $GAME/robots.txt $TD/sso-robots.orig

echo "== normal install (the main site): behaves as before"
ok "register.php is open" $(is "$(code $BASE/register.php)" 200)
ok "no noarchive header" $(grep -qi 'noarchive' $TD/sso.hdr && echo 0 || echo 1)
code $BASE/login.php >/dev/null; ok "login.php has the password form" $(has $TD/sso.html 'name="password"')
ok "admin logs in with a password" $(is "$(login $A admin TestPassword123)" 302)
ok "sprout logs in with a password" $(is "$(login $P sprout 'TestPass123!')" 302)

echo "== main site: sso_issue.php"
ok "blank sso_secret: 404 even for the admin" $(is "$(code -b $A $BASE/sso_issue.php)" 404)
sqlq "INSERT OR REPLACE INTO settings (name, value) VALUES ('sso_secret', '$SECRET')"
ok "secret set: anonymous gets 403" $(is "$(code $BASE/sso_issue.php)" 403)
ok "secret set: a player gets 403" $(is "$(code -b $P $BASE/sso_issue.php)" 403)
ok "...with no hint" $(is "$(cat $TD/sso.html)" "Not available.")
c=$(code -b $A $BASE/sso_issue.php)
ok "admin: 200 page that POSTs the token to https://test.gnomeventure.ca/mainlogin.php" $( [ "$c" = 200 ] && grep -q 'method="post" action="https://test.gnomeventure.ca/mainlogin.php"' $TD/sso.html && grep -q 'name="t" value="[^"]*\.[^"]*"' $TD/sso.html && grep -qi "^content-security-policy:.*form-action https://test.gnomeventure.ca;" $TD/sso.hdr && echo 1 || echo 0) "$c"
ok "open redirect ?to=evil.com refused" $(is "$(code -b $A "$BASE/sso_issue.php?to=evil.com")" 400)
ok "?to=test.gnomeventure.ca.evil.com refused" $(is "$(code -b $A "$BASE/sso_issue.php?to=test.gnomeventure.ca.evil.com")" 400)
ok "?to=127.0.0.1 (not listed) refused" $(is "$(code -b $A "$BASE/sso_issue.php?to=127.0.0.1")" 400)
sqlq "INSERT OR REPLACE INTO settings (name, value) VALUES ('sso_targets', 'test.gnomeventure.ca,127.0.0.1')"
code -b $A "$BASE/sso_issue.php?to=127.0.0.1" >/dev/null
TOKEN=$(grep -o 'name="t" value="[^"]*"' $TD/sso.html | sed 's/.*value="//;s/"$//')
ok "listed ?to=127.0.0.1: a token for that host" $( grep -q 'action="https://127.0.0.1/mainlogin.php"' $TD/sso.html && [ -n "$TOKEN" ] && echo 1 || echo 0)
code -b $A $BASE/admin/settings.php?q=sso >/dev/null
ok "Admin > Game settings shows the SSO fields" $(has $TD/sso.html 'name="s\[sso_secret\]"')
ok "...but never the secret itself" $(grep -q "$SECRET" $TD/sso.html && echo 0 || echo 1)
ok "mainlogin.php is a 404 on a site that is not locked down" $(is "$(code "$BASE/mainlogin.php?t=$TOKEN")" 404)

echo "== test site: lockdown sso"
conf "{\"lockdown\":\"sso\",\"lockdown_email\":\"a@b.local\",\"sso_secret\":\"$SECRET\",\"sso_main\":\"https://gnomeventure.ca\"}"
ok "anonymous GET garden.php: 302 to login.php" $( [ "$(code $BASE/garden.php)" = 302 ] && grep -qi '^location: .*login.php' $TD/sso.hdr && echo 1 || echo 0)
ok "anonymous home page: 302 to login.php" $(is "$(code $BASE/index.php)" 302)
ok "anonymous POST: 403" $(is "$(code -X POST -d x=1 $BASE/garden.php)" 403)
ok "anonymous ajax: 403" $(is "$(code -H 'X-Requested-With: fetch' $BASE/puzzles_api.php)" 403)
for pg in register guest forgot reset verify; do ok "$pg.php is a 404" $(is "$(code $BASE/$pg.php)" 404); done
code $BASE/login.php >/dev/null
ok "noindex, nofollow, noarchive header" $(grep -qi '^x-robots-tag: noindex, nofollow, noarchive' $TD/sso.hdr && echo 1 || echo 0)
ok "login.php: the Sign in with gnomeventure.ca button" $(has $TD/sso.html 'https://gnomeventure.ca/sso_issue.php?to=127.0.0.1')
ok "login.php: no password form" $(grep -q 'name="password"' $TD/sso.html && echo 0 || echo 1)
ok "login.php: POST refused" $(is "$(code -X POST -d username=admin -d password=TestPassword123 $BASE/login.php)" 403)
ok "robots.txt says Disallow: /" $(curl -s $BASE/robots.txt | grep -qx 'Disallow: /' && echo 1 || echo 0)
ok "the player's old session is bounced" $(is "$(code -b $P $BASE/garden.php)" 302)
ok "mainlogin.php with a bad token: 403, the generic page" $( [ "$(code "$BASE/mainlogin.php?t=abc.def")" = 403 ] && grep -q 'That sign-in did not work' $TD/sso.html && echo 1 || echo 0)
ok "...logged without the token" $(grep -q 'SSO sign-in refused: bad signature' $GAME/data/error-log.txt && ! grep -q 'abc.def' $GAME/data/error-log.txt && echo 1 || echo 0)
c=$(curl -s -c $N -b $N -o /dev/null -D $TD/sso.hdr -w '%{http_code}' --data-urlencode "t=$TOKEN" "$BASE/mainlogin.php")
ok "mainlogin.php with the main site's token: logged in, 302 to the game" $( [ "$c" = 302 ] && grep -qiE '^location: .*(welcome|gnome).php' $TD/sso.hdr && echo 1 || echo 0) "$c"
c=$(curl -s -c $N -b $N -o /dev/null -D $TD/sso.hdr -w '%{http_code}' "$BASE/garden.php")
ok "the signed-in admin is not bounced to login.php" $( grep -qi '^location: .*login.php' $TD/sso.hdr && echo 0 || echo 1) "$c"
ok "the same token again (replay) is refused" $(is "$(code "$BASE/mainlogin.php?t=$TOKEN")" 403)

echo "== test site: lockdown admin (password, only the lockdown admin)"
conf '{"lockdown":"admin","lockdown_email":"a@b.local","sso_main":"https://gnomeventure.ca"}'
code $BASE/login.php >/dev/null; ok "login.php has the password form" $(has $TD/sso.html 'name="password"')
ok "...and no sign-up link" $(grep -q 'register.php' $TD/sso.html && echo 0 || echo 1)
rm -f $P; login $P sprout 'TestPass123!' >/dev/null
ok "a player with the right password is refused" $(has $TD/sso-login-post.html 'Wrong username or password')
rm -f $A; ok "the lockdown admin logs in" $(is "$(login $A admin TestPassword123)" 302)
ok "mainlogin.php is a 404 in admin mode" $(is "$(code "$BASE/mainlogin.php?t=x.y")" 404)

conf '{}'; cp $TD/sso-robots.orig $GAME/robots.txt
ok "lockdown keys removed: register.php open again" $(is "$(code $BASE/register.php)" 200)
echo "$FAILS FAILED" | grep -v '^0 '
[ $FAILS -eq 0 ]
