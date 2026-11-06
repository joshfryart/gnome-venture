#!/bin/bash
# v0.9.8 part B: item pictures + Admin -> Images. Run on a fresh SQLite install that walk.sh made (admin / sprout): images.sh GAME PORT ROUTER
# Needs php with GD, python3 (for the zips). Writes only under GAME/uploads and a temp dir.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >"${TMPDIR:-/tmp}/img-php.log" 2>&1 & PID=$!; sleep 1
T=$(mktemp -d "${TMPDIR:-/tmp}/img-test.XXXXXX"); trap 'kill $PID 2>/dev/null; [ -d "${T:?}" ] && rm -rf "${T:?}"' EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $T/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/l.html)" -d username=$2 -d "password=$3" -o /dev/null; }
A=$T/a; S=$T/s; login $A admin TestPassword123; login $S sprout 'TestPass123!'
dbx "UPDATE users SET onboarded=1, tour_step=0 WHERE username='sprout'"
SID=$(db "SELECT id FROM users WHERE username='sprout'")
for s in tomato potato apple garden-honey; do dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID,id,3 FROM items WHERE slug='$s'"; done
CRE=$(db "SELECT slug FROM creatures LIMIT 1"); NPC=$(db "SELECT slug FROM npcs LIMIT 1")
# test pictures: coloured circles (GD)
php -r '
function circ($f,$c,$w=128,$h=128){ $im=imagecreatetruecolor($w,$h); imagesavealpha($im,true); imagealphablending($im,false); imagefill($im,0,0,imagecolorallocatealpha($im,0,0,0,127)); imagealphablending($im,true);
  imagefilledellipse($im,$w/2,$h/2,min($w,$h)-12,min($w,$h)-12,imagecolorallocate($im,...$c)); imagepng($im,$f); }
$d=$argv[1]; $n=["tomato"=>[220,60,50],"potato"=>[190,150,90],"apple"=>[120,190,60],"garden-honey"=>[240,180,30],"kitchen-2"=>[80,120,200],"kitchen-mossy"=>[60,150,110],"picket-fence-straight"=>[160,110,60]];
foreach($n as $s=>$c) circ("$d/$s.png",$c); circ("$d/creature-".$argv[2].".png",[150,60,150]); circ("$d/npc-".$argv[3].".png",[60,150,150],400,500);
circ("$d/nothing-here.png",[1,2,3]);
file_put_contents("$d/carrot.png","<?php echo 1; ?>"); file_put_contents("$d/onion.png","GIF89a<?php system(\$_GET[0]); ?>");
copy("$d/tomato.png","$d/lettuce-seed.php"); copy("$d/tomato.png","$d/radish.gif");
$big=imagecreatetruecolor(900,900); for($i=0;$i<900;$i++) for($j=0;$j<900;$j++) imagesetpixel($big,$i,$j,mt_rand(0,16777215)); imagepng($big,"$d/radish-seed.png",0);
' $T "$CRE" "$NPC" 2>/dev/null
up() { curl -s -c $A -b $A -X POST $BASE/admin/images.php "$@" -o $T/up.html -w '%{http_code}'; }
page() { curl -s -c $A -b $A $BASE/admin/images.php -o $T/img.html; }
rep() { grep -oE "$1" $T/up.html | head -1; }

echo "== fallback: no pictures, the emoji show as before"
curl -s -b $S -c $S $BASE/inventory.php -o $T/sat0.html
# v1.5.2: items without real art show a red-outlined placeholder (assets/img/ph/), still no real picture
chk "satchel has no real <img class=aimg> (only placeholders)" "$(grep -o '<img class="aimg[^>]*>' $T/sat0.html | grep -vc 'assets/img/ph/')" 0
chk "satchel shows placeholders" "$(grep -o '<img class="aimg[^>]*assets/img/ph/' $T/sat0.html | wc -l | awk '{print ($1>3)?"yes":"no"}')" yes
chk "satchel has icons" "$(grep -c 'class="shpill' $T/sat0.html | awk '{print ($1>0)?"yes":"no"}')" yes   # Shelves: a pill per item

echo "== only admins"
chk "player POST images.php refused" "$(curl -s -b $S -c $S -X POST $BASE/admin/images.php -F "pics[]=@$T/tomato.png" -o /dev/null -w '%{http_code}')" "$(curl -s -b $S -c $S $BASE/admin/index.php -o /dev/null -w '%{http_code}')"
chk "player upload saved nothing" "$(ls $GAME/uploads/items 2>/dev/null | wc -l)" 0
chk "anonymous POST refused" "$(curl -s -X POST $BASE/admin/images.php -F "pics[]=@$T/tomato.png" -o /dev/null -w '%{http_code}' | grep -c '^200$')" 0
echo "== CSRF"
page
curl -s -b $A -c $A -X POST $BASE/admin/images.php -F "csrf=nope" -F "pics[]=@$T/tomato.png" -o $T/up.html -w '%{http_code}\n' >/dev/null
chk "bad CSRF saved nothing" "$(ls $GAME/uploads/items 2>/dev/null | wc -l)" 0
chk "bad CSRF no report" "$(grep -c 'id="report"' $T/up.html)" 0

echo "== bulk upload"
page; TOK=$(csrf $T/img.html)
F=(); for n in tomato potato apple garden-honey kitchen-2 kitchen-mossy picket-fence-straight creature-$CRE npc-$NPC nothing-here carrot onion radish-seed; do F+=(-F "pics[]=@$T/$n.png"); done
F+=(-F "pics[]=@$T/lettuce-seed.php" -F "pics[]=@$T/radish.gif;filename=../../evil.png" -F "pics[]=@$T/tomato.png;filename=../../../tomato.png")
up -F "csrf=$TOK" "${F[@]}" >/dev/null
rep '<b class="good">[0-9]+ matched'; rep '<b>[0-9]+ replaced'; rep '<b>[0-9]+ unmatched'; rep '<b class="bad">[0-9]+ rejected'
chk "matched count" "$(rep '<b class="good">[0-9]+ matched' | grep -oE '[0-9]+')" 9
chk "replaced count (tomato sent twice, second time via a traversal name)" "$(rep '<b>[0-9]+ replaced' | grep -oE '[0-9]+')" 1
chk "unmatched (nothing-here, evil.png)" "$(rep '<b>[0-9]+ unmatched' | grep -oE '[0-9]+')" 2
chk "rejected (php code, fake gif, .php, too big)" "$(rep '<b class="bad">[0-9]+ rejected' | grep -oE '[0-9]+')" 4
for f in items/tomato items/potato items/apple items/garden-honey buildings/kitchen-2 skins/kitchen-mossy yard/picket-fence-straight creatures/$CRE npcs/$NPC; do
  chk "saved uploads/$f.png" "$([ -f $GAME/uploads/$f.png ] && echo yes || echo no)" yes; done
chk "saved files are real PNGs" "$(file -b $GAME/uploads/items/tomato.png | cut -c1-9)" "PNG image"
chk "item image set" "$(db "SELECT image FROM items WHERE slug='tomato'")" "uploads/items/tomato.png"
chk "fence image uses {shape}" "$(db "SELECT image FROM items WHERE slug='picket-fence'")" 'uploads/yard/picket-fence-{shape}.png'
chk "npc image set" "$(db "SELECT image FROM npcs WHERE slug='$NPC'")" "uploads/npcs/$NPC.png"
chk "nothing written outside uploads/" "$(ls $GAME/evil.png $GAME/../evil.png $GAME/../tomato.png $GAME/../../tomato.png 2>/dev/null | wc -l)" 0
chk "no stray temp files" "$(find $GAME/uploads -name '.up-*' | wc -l)" 0
chk "no .php or odd files in uploads" "$(find $GAME/uploads -type f ! -name '*.png' ! -name .htaccess ! -name .keep | wc -l)" 0
chk "uploads/.htaccess written" "$([ -f $GAME/uploads/.htaccess ] && echo yes || echo no)" yes
chk "rejected files not saved" "$(ls $GAME/uploads/items | grep -cE 'carrot|onion|lettuce|radish')" 0
chk "carrot has no image" "$(db "SELECT COALESCE(image,'') FROM items WHERE slug='carrot'")" ""

echo "== the pictures show"
curl -s -b $S -c $S $BASE/inventory.php -o $T/sat1.html
chk "satchel shows pictures" "$(grep -cE 'class="aimg aimg-lg( pix)?" src="[^"]*uploads/items/' $T/sat1.html | awk '{print ($1>=3)?"yes":"no"}')" yes
# Shelves: the open panel shows the 64 px picture with an empty alt (the name is right beside it)
chk "img has width/height/lazy/alt" "$(grep -oE '<img class="aimg aimg-lg( pix)?"[^>]*uploads/items/tomato.png[^>]*>' $T/sat1.html | head -1 | grep -c 'width="64" height="64" alt="" loading="lazy" decoding="async"')" 1
chk "items without real art show a placeholder (v1.5.2)" "$(grep -o '<img class="aimg[^>]*assets/img/ph/' $T/sat1.html | wc -l | awk '{print ($1>=1)?"yes":"no"}')" yes
dbx "UPDATE items SET image='../config.php.png' WHERE slug='potato'"; dbx "UPDATE items SET image='uploads/items/nope.png' WHERE slug='apple'"; dbx "UPDATE items SET image='uploads/items/garden-honey.svg' WHERE slug='garden-honey'"
curl -s -b $S -c $S $BASE/inventory.php -o $T/sat2.html
chk "traversal / missing file / svg paths fall back to emoji" "$(grep -c 'src="[^"]*\(\.\./config\|config.php\|items/nope\|uploads/items/garden-honey.svg\)' $T/sat2.html)" 0
chk "tomato still shows" "$(grep -c 'uploads/items/tomato.png' $T/sat2.html | awk '{print ($1>0)?"yes":"no"}')" yes
for s in potato apple garden-honey; do dbx "UPDATE items SET image='uploads/items/$s.png' WHERE slug='$s'"; done

echo "== zip"
python3 - $T <<'PY'
import sys, zipfile, shutil
t=sys.argv[1]
with zipfile.ZipFile(t+'/art.zip','w') as z:
    z.write(t+'/tomato.png','art/onion.png')   # nested folder is fine; a real PNG for onion
    z.write(t+'/tomato.png','../../escape.png')
    z.writestr('notes.txt','hello')
    z.writestr('art/carrot.png','<?php echo 1;')
    z.write(t+'/tomato.png','art/carrot-seed.png')
PY
page; TOK=$(csrf $T/img.html)
up -F "csrf=$TOK" -F "pics[]=@$T/art.zip" >/dev/null
chk "zip: onion matched from a folder" "$(db "SELECT image FROM items WHERE slug='onion'")" "uploads/items/onion.png"
chk "zip: ../ entry rejected" "$(grep -c 'unsafe path' $T/up.html)" 1
chk "zip: fake png rejected" "$(grep -c 'not a real' $T/up.html | awk '{print ($1>0)?"yes":"no"}')" yes
chk "zip: txt skipped quietly" "$(grep -c 'notes.txt' $T/up.html)" 0
chk "zip: nothing escaped" "$(ls $GAME/escape.png $GAME/../escape.png $GAME/../../escape.png 2>/dev/null | wc -l)" 0
echo "== missing art list"
page
chk "missing-art box" "$(grep -c 'id="missing"' $T/img.html)" 1
chk "lists an item to draw" "$(grep -c '<code>[a-z-]*\.png</code></td></tr>' $T/img.html | awk '{print ($1>5)?"yes":"no"}')" yes
chk "tomato no longer listed" "$(grep -c '<code>tomato.png</code></td></tr>' $T/img.html)" 0
curl -s -b $A -c $A $BASE/admin/index.php | grep -oE '[0-9]+ of [0-9]+ pictures in' | head -1

echo "== php errors"
grep -iE "warning|notice|fatal|deprecated" "${TMPDIR:-/tmp}/img-php.log" | head -5 || true
chk "no php warnings" "$(grep -ciE 'warning|notice|fatal|deprecated' "${TMPDIR:-/tmp}/img-php.log")" 0
