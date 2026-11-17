<?php
// 2.7.06 (Josh): a recipe you have not found yet still has its name and says what it needs (crafting list, scene popover, almanac hint). php tests/unk_recipes.php GAME_DIR (installed game, player "sprout").
$_SERVER['SCRIPT_NAME'] = '/inventory.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/crafting.php';
require_once $argv[1] . '/includes/shelves.php';
require_once $argv[1] . '/includes/craft_map.php';
require_once $argv[1] . '/includes/almanac_notes.php';
$bad = 0;
function chk(string $name, bool $ok, string $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . $got . ')') . "\n"; if (!$ok) $bad++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
q('DELETE FROM user_recipes WHERE user_id = ?', [$uid]);
$recipes = craft_recipes($uid, 'cooking');
$stations = craft_stations($uid);
$all = sh_craft_entries($u, 'cooking', $recipes, $stations);
$unk = array_values(array_filter($all, fn($e) => $e['status'] === 'unk'));
chk('with no recipes known there are unknown entries', count($unk) > 5, (string)count($unk));
chk('no unknown entry is named ???', !array_filter($unk, fn($e) => $e['name'] === '???' || $e['name'] === ''), json_encode(array_column(array_slice($unk, 0, 3), 'name')));
chk('an unknown entry\'s panel lists its ingredients with amounts', str_contains($unk[0]['panel'], ' × ') && str_contains($unk[0]['panel'], 'p2ingunk'), substr($unk[0]['panel'], 0, 200));
chk('the pill head shows the dish name', str_contains($unk[0]['head'], htmlspecialchars($unk[0]['name'], ENT_QUOTES)) && !str_contains($unk[0]['head'], '???'));
$slugOf = []; foreach ($recipes as $r) $slugOf[(int)$r['id']] = (string)($r['slug'] ?? '');
$pop = '';
foreach (['cooking'] as $tab) $pop .= craft_pop_html($tab, $all, $slugOf);
chk('the scene popover Unknown tab names the dish and lists what it needs', !str_contains($pop, '???') && str_contains($pop, 'p2ingunk') && str_contains($pop, htmlspecialchars($unk[0]['name'], ENT_QUOTES)), '');
$r0 = q_one("SELECT slug FROM recipes WHERE slug IS NOT NULL AND slug <> '' LIMIT 1");
$h = almanac_locked_hint(['unlock_key' => 'recipe:' . $r0['slug'], 'hint' => '']);
chk('an undiscovered recipe\'s almanac hint lists the ingredients', str_contains($h, 'Needs ') && str_contains($h, ' × '), $h);
$ing = array_keys(json_decode((string)q_val('SELECT ingredients FROM recipes WHERE slug = ?', [$r0['slug']]), true) ?: [])[0] ?? '';
$note = almanac_gather_notes($u, $ing);
chk('an ingredient\'s "used in" names unknown recipes too', !str_contains($note, '???'), $note);
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
