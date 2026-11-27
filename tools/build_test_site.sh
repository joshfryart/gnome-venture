#!/bin/bash
# Build the packages that create a PRIVATE TEST COPY of the game (e.g. test.gnomeventure.ca) on the same kind of host as the live site.
# Usage: bash tools/build_test_site.sh <outdir> [hostname]       (run from the repo root; <outdir> must exist)
# Makes, in <outdir>:
#   GnomeVenture-<v>-TEST-1-site.zip     the whole game except the trail ground art, WITH install.php, a robots.txt that blocks search engines,
#                                        an X-Robots-Tag noindex header, and TEST-SITE-README.txt. Unzip it into the test site's web folder (files at the top level).
#   GnomeVenture-<v>-TEST-2-trail-N.zip  the trail ground art (about 250 MB) in parts, to unzip on top of the site (they extract into assets/img/trail/ground/).
#                                        Skip them if you copy game/assets/img/trail from the live site instead (File Manager > Copy).
# Later updates for the test site: the slim zips from tests/build_update.sh go on through the test site's Admin > Update, like the live site.
set -e
OUT=$(cd "${1:?usage: build_test_site.sh <outdir> [hostname]}" && pwd); HOST=${2:-test.gnomeventure.ca}
ROOT=$(cd "$(dirname "$0")/.." && pwd); cd "$ROOT"
V=$(grep -oP "define\('APP_VERSION', '\K[0-9.]+" game/includes/bootstrap.php)
T=$(mktemp -d); S=$T/site; mkdir -p "$S"
# 1. the game, without secrets, runtime data, the sqlite files and the trail ground art (that goes in its own parts)
( cd game && tar cf - --exclude='./config.php' --exclude='./data/*.sqlite*' --exclude='./data/*.log' --exclude='./data/*.txt' --exclude='./uploads/*' --exclude='./assets/img/trail/ground' . ) | ( cd "$S" && tar xf - )
mkdir -p "$S/assets/img/trail/ground" "$S/data" "$S/uploads"
cp game/uploads/.htaccess "$S/uploads/.htaccess"; cp game/uploads/.keep "$S/uploads/.keep"; cp game/data/.htaccess "$S/data/.htaccess"
# 2. private: no search engines
printf '# TEST SITE (%s): not for search engines.\nUser-agent: *\nDisallow: /\n' "$HOST" > "$S/robots.txt"
cat >> "$S/.htaccess" <<'EOF'

# TEST SITE: never index it
<IfModule mod_headers.c>
  Header set X-Robots-Tag "noindex, nofollow, noarchive"
</IfModule>
EOF
cat > "$S/TEST-SITE-README.txt" <<EOF
GNOME VENTURE TEST SITE ($HOST), version $V
==========================================================
A separate copy of the game with its OWN database and its OWN accounts. Nothing here touches the live site.

1. In cPanel (CanSpace) make the subdomain  $HOST  with its own web folder (for example public_html/test).
2. In cPanel > MySQL Databases make a NEW database and a NEW user for the test site (for example <account>_gvtest / <account>_gvtest),
   give the user ALL PRIVILEGES on that database. Do not reuse the live database.
3. Upload this zip into the test site's web folder and Extract it THERE (index.php must sit directly in that folder, not inside a "game" folder).
4. The trail ground pictures (assets/img/trail/ground, about 250 MB) are in the TEST-2 zips: upload and extract each one in the same folder.
   Shortcut: instead, copy the folder assets/img/trail from the live site into the test site (File Manager > Copy). Without them the trail maps have no ground.
5. Open  https://$HOST/install.php  : database details from step 2, site name "Gnome Venture TEST", make an admin account. The installer writes config.php and then locks itself.
6. Make it private. Easiest: cPanel > Directory Privacy > the test folder > "Password protect this directory". (robots.txt and an X-Robots-Tag header already keep search engines out.)
7. Outgoing email: the test site sends mail like the live one. Do not give real players' addresses to test accounts; use a test address.

Updating the test site later: Admin > Update on the test site with the slim zip (GnomeVenture-<version>-web-update.zip), exactly as on the live site.
Starting over: drop and recreate the test database (or empty it in phpMyAdmin), delete config.php and data/ files, and run install.php again.
EOF
# 3. zips
( cd "$S" && rm -f "$OUT/GnomeVenture-$V-TEST-1-site.zip" && zip -qr -1 "$OUT/GnomeVenture-$V-TEST-1-site.zip" . )
# 4. the trail ground art in parts of about 85 MB
G=game/assets/img/trail/ground; MAX=$((85*1024*1024)); n=1; sum=0; : > "$T/part$n.txt"
for f in $(ls "$G"); do sz=$(stat -c %s "$G/$f"); if [ $((sum + sz)) -gt $MAX ] && [ $sum -gt 0 ]; then n=$((n+1)); sum=0; : > "$T/part$n.txt"; fi; echo "$f" >> "$T/part$n.txt"; sum=$((sum+sz)); done
mkdir -p "$T/tz/assets/img/trail"
ln -s "$ROOT/$G" "$T/tz/assets/img/trail/ground"
for i in $(seq 1 $n); do rm -f "$OUT/GnomeVenture-$V-TEST-2-trail-$i.zip"; ( cd "$T/tz" && sed 's|^|assets/img/trail/ground/|' "$T/part$i.txt" | zip -q -1 "$OUT/GnomeVenture-$V-TEST-2-trail-$i.zip" -@ ); done
echo "built in $OUT: site + $n trail part(s) for $HOST (v$V)"
ls -la "$OUT"/GnomeVenture-$V-TEST-*.zip
