# v2.0.68: Admin > Puzzles GIF upload: admins only, CSRF, size / type / sides / aspect / frames / work limits, files saved with a still, new uploads start off.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pzu-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
# test pictures: real GD GIFs, and hand-built ones (1x1 frames on a canvas) for the frame limits
php -r '
$d = $argv[1];
$m = function ($w, $h) { $i = imagecreate($w, $h); imagecolorallocate($i, 200, 120, 40); $c = imagecolorallocate($i, 40, 80, 160); imagefilledrectangle($i, 4, 4, intdiv($w, 2), intdiv($h, 2), $c); ob_start(); imagegif($i); return ob_get_clean(); };
$g = function ($w, $h, $n) { $s = "GIF89a" . pack("vv", $w, $h) . "\x80\x00\x00" . "\x00\x00\x00\xff\xff\xff";
    for ($k = 0; $k < $n; $k++) $s .= "\x21\xF9\x04\x00\x0A\x00\x00\x00" . "\x2C" . pack("vvvv", 0, 0, 1, 1) . "\x00" . "\x02\x02\x44\x01\x00";
    return $s . "\x3B"; };
file_put_contents("$d/good.gif", $m(128, 96));
file_put_contents("$d/small.gif", $m(32, 32));
file_put_contents("$d/thin.gif", $m(400, 120));
file_put_contents("$d/frames.gif", $g(64, 64, 151));
file_put_contents("$d/frames_ok.gif", $g(64, 64, 150));
file_put_contents("$d/work.gif", $g(640, 640, 100));
file_put_contents("$d/heavy.gif", $m(128, 96) . str_repeat("\0", 1600000));
$p = imagecreatetruecolor(100, 100); imagepng($p, "$d/png.gif");
' $W
ok "parser counts 150 frames" "$(php -r 'define("APP_ROOT","'$GAME'"); require "'$GAME'/includes/puzzles.php"; echo gif_frame_count(file_get_contents($argv[1]));' $W/frames_ok.gif)" 150
ok "parser refuses a broken GIF" "$(php -r 'define("APP_ROOT","'$GAME'"); require "'$GAME'/includes/puzzles.php"; echo gif_frame_count(substr(file_get_contents($argv[1]), 0, 40));' $W/frames_ok.gif)" -1
login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
curl -s -b $W/a $BASE/admin/puzzles.php > $W/lib.html
ok "admin page loads (Library tab)" "$(grep -c 'Upload</a>' $W/lib.html)" 1
ok "admin menu links Puzzles" "$(curl -s -b $W/a $BASE/admin/index.php | grep -c 'admin/puzzles.php' | sed 's/^[1-9][0-9]*$/yes/')" yes
curl -s -b $W/a "$BASE/admin/puzzles.php?tab=upload" > $W/up.html
ok "upload tab shows the Aseprite note" "$(grep -c 'Simple GIFs; ideally drawn through the Aseprite process (Stitched Toy style).' $W/up.html)" 1
T=$(csrf $W/up.html)
up() { curl -s -b $W/$1 -c $W/$1 -o /dev/null -w '%{http_code}' -X POST $BASE/admin/puzzles.php -F "csrf=$2" -F do=upload -F "title=$3" -F pieces_default=24 -F "gif=@$W/$4;type=image/gif"; }
N0=$(dbv "SELECT COUNT(*) FROM puzzle_pics")
ok "player can't upload" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/admin/puzzles.php -F csrf=x -F do=upload -F title=x -F "gif=@$W/good.gif;type=image/gif")" 403
ok "no CSRF = refused" "$(up a wrong 'Bad token' good.gif)" 400
bad() { up a "$T" "Bad $1" $1.gif >/dev/null; ok "refused: $1" "$(curl -s -b $W/a "$BASE/admin/puzzles.php?tab=upload" | grep -c "$2")" 1; }
bad heavy 'GIFs can be up to 1.5 MB'
bad png 'isn’t a GIF'
bad small 'Each side must be 64 to 640 pixels'
bad thin 'too long and thin'
bad frames 'Too many frames: 151'
bad work 'Too much animation'
ok "bad uploads saved nothing" "$(dbv "SELECT COUNT(*) FROM puzzle_pics")" "$N0"
ok "good upload redirects" "$(up a "$T" 'Test Toy Box' good.gif)" 302
ok "one new picture" "$(dbv "SELECT COUNT(*) FROM puzzle_pics")" "$((N0+1))"
ok "starts switched off, source upload" "$(dbv "SELECT active || source || w || 'x' || h || ':' || frames FROM puzzle_pics WHERE slug='test-toy-box'")" "0upload128x96:1"
F=$(dbv "SELECT file FROM puzzle_pics WHERE slug='test-toy-box'"); S=$(dbv "SELECT still FROM puzzle_pics WHERE slug='test-toy-box'")
ok "gif saved as uploads/puzzles/{hex}.gif" "$(echo $F | grep -cE '^[a-f0-9]{24}\.gif$')" 1
ok "still made with GD" "$(php -r 'echo getimagesize($argv[1])["mime"] ?? "";' $GAME/uploads/puzzles/$S)" image/png
ok "gif is served" "$(curl -s -o /dev/null -w '%{http_code}' $BASE/uploads/puzzles/$F)" 200
ok "admin log row" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='puzzle_upload'")" 1
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('puzzles_open','1')"
ok "off: not in the player library" "$(curl -s -b $W/p $BASE/gifsaw.php | grep -c "$F")" 0
ID=$(dbv "SELECT id FROM puzzle_pics WHERE slug='test-toy-box'")
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=pic_save -d id=$ID -d title='Test Toy Box' -d pieces_default=24 -d sort=1 -d active=1
ok "switched on: in the player library" "$(curl -s -b $W/p $BASE/gifsaw.php | grep -c "$F")" 1
up a "$T" 'Test Toy Box' good.gif >/dev/null
ok "same title gets its own slug" "$(dbv "SELECT COUNT(*) FROM puzzle_pics WHERE slug='test-toy-box-2'")" 1
dbx "DELETE FROM settings WHERE name='puzzles_open'"
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/pzu-php.log || echo "(none)"
