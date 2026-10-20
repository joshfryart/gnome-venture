<?php
// v2.0.8/2.0.9: the Treks talk pop-over ("scene"). Every story line the engine says (trek_say_text) is also noted in the session; the next Map render turns
// the notes into beats and emits them once as a hidden stage that assets/trekscene.js opens as a dialog. The normal log lines stay as they are.

/**
 * A text slot as PLAIN text (same row, fallback and {token} logic as trek_text(), no HTML, no admin pencil). '' when the slot is not written.
 * $vars override the page's tokens; {gnome} and {calling} are filled from the player when the page has not set them (tests, other entry points).
 */
function trek_scene_plain(string $key, array $vars, array $u): string
{
    $body = trim((string)(trek_text_row($key)['body'] ?? ''));
    if ($body === '') return '';
    $calling = (string)(defined('CALLINGS') ? (CALLINGS[$u['calling'] ?? ''][0] ?? 'gnome') : 'gnome');
    $all = $vars + trek_text_vars() + ['gnome' => gnome_name($u), 'calling' => $calling, 'currency' => (string)setting('currency_name')];
    foreach ($all as $k => $v) $body = str_replace('{' . $k . '}', (string)$v, $body);
    return trim(str_replace(["\r\n", "\r"], "\n", $body));
}

/** Is this line speech (starts with a curly or straight double quote)? */
function trek_scene_is_speech(string $line): bool
{
    return $line !== '' && (str_starts_with($line, '“') || str_starts_with($line, '"') || str_starts_with($line, '„'));
}

const TREK_SCENE_KINDS = ['speech', 'narration', 'place', 'boss'];   // book, choice, ui and item rows are panels, not talk
const TREK_SCENE_MAX = 16;

/** Note a story line for the pop-over (called by trek_say_text). Once per key per run; mid-fight boss chatter (hits, moves) is skipped: only .intro and .defeat. */
function trek_scene_collect(array $run, string $key, array $vars = []): void
{
    $row = function_exists('trek_text_row') ? trek_text_row($key) : null;
    if (!$row || !in_array((string)($row['kind'] ?? ''), TREK_SCENE_KINDS, true) || trim((string)$row['body']) === '') return;
    if ($row['kind'] === 'boss' && !preg_match('/\.(intro|defeat)$/', $key)) return;
    $rid = (int)$run['id'];
    $seen = &$_SESSION['trek_scene_seen'][$rid];
    if (isset($seen[$key])) return;
    $seen[$key] = 1;
    if (count($seen) > 400) $seen = array_slice($seen, -200, null, true);
    trek_scene_push($rid, ['k' => $key, 'v' => $vars]);
}

/** The party-member-joined card: crew key + whether they got a place (false = waits on the bench). */
function trek_scene_join(array $run, string $crewKey, bool $placed): void
{
    trek_scene_push((int)$run['id'], ['join' => $crewKey, 'placed' => $placed]);
}

function trek_scene_push(int $rid, array $item): void
{
    $a = $_SESSION['trek_scene_auto'] ?? null;
    if (!is_array($a) || (int)($a['run'] ?? 0) !== $rid || time() - (int)($a['t'] ?? 0) > 30) $a = ['run' => $rid, 't' => time(), 'items' => []];
    if (count($a['items']) < TREK_SCENE_MAX) $a['items'][] = $item;
    $a['t'] = time();
    $_SESSION['trek_scene_auto'] = $a;
}

/** Who a speaker slug is: ['name', 'ico'] (cached per request). 'gnome' is handled by the caller. */
function trek_scene_who(string $slug): array
{
    static $c = [];
    if (isset($c[$slug])) return $c[$slug];
    $npc = q_one('SELECT name, slug FROM npcs WHERE slug = ?', [$slug]);
    $calling = '';
    foreach (trek_crew() as $cr) if ($cr['npc_slug'] === $slug) { $calling = (string)$cr['calling']; break; }
    $name = $npc ? trek_first_name_of((string)$npc['name']) : ucfirst(explode('-', $slug)[0]);
    return $c[$slug] = ['name' => $name, 'ico' => ph_or_emoji('npc-' . $slug, TREK_CREW_ICONS[$calling] ?? '🐾', 64)];
}

/** The join card's facts for a trailmate: name, calling, level, numbers, role line, a bit about them. */
function trek_scene_joincard(array $run, array $u, string $crewKey, bool $placed): ?array
{
    $crew = trek_crew()[$crewKey] ?? null;
    if (!$crew) return null;
    $npc = trek_crew_npc($crewKey);
    $st = trek_party_stats($run, $u);
    $m = null;
    foreach ($st as $p) if ($p['key'] === $crewKey) { $m = $p; break; }
    if ($m) { $lvl = (int)$m['level'] + max(0, (int)$m['tl'] - 1); $hp = (int)$m['max']; $gc = $m['gc']; }
    else { $mu = trek_crew_user($crewKey, $u); $gc = gnome_combat($mu); $lvl = (int)$mu['level']; $hp = (int)$gc['max_hp']; }
    $cl = CALLINGS[$crew['calling']] ?? null;
    $bio = trim((string)($npc['bio'] ?? ''));
    if (mb_strlen($bio) > 220) $bio = mb_substr($bio, 0, 217) . '…';
    return ['w' => (string)$crew['npc_slug'], 'name' => trek_first_name_of((string)$npc['name']), 'full' => (string)$npc['name'],
        'sub' => trim(((string)($npc['species'] ?? '') !== '' ? (string)$npc['species'] . ' · ' : '') . ($cl ? $cl[0] : '') . ' · Level ' . $lvl, ' ·'),
        'stats' => ['Health' => $hp, 'Attack' => (int)($gc['atk'] ?? 0), 'Armour' => (int)($gc['ac'] ?? 0)],
        'role' => $cl ? (string)($cl[5] ?? '') : '', 'bio' => $bio, 'placed' => $placed];
}

/** The one-shot stage for assets/trekscene.js, or ''. Taken (and cleared) on every call; this run only, fresh for 30 s. */
function trek_scene_stage(array $run, array $u): string
{
    $a = $_SESSION['trek_scene_auto'] ?? null;
    unset($_SESSION['trek_scene_auto']);
    if (!is_array($a) || (int)($a['run'] ?? 0) !== (int)$run['id'] || time() - (int)($a['t'] ?? 0) > 30 || empty($a['items'])) return '';
    $who = [];
    $beats = [];
    foreach ($a['items'] as $it) {
        if (isset($it['join'])) {
            $jc = trek_scene_joincard($run, $u, (string)$it['join'], !empty($it['placed']));
            if (!$jc) continue;
            $who[$jc['w']] ??= trek_scene_who($jc['w']);
            $beats[] = ['w' => $jc['w'], 't' => $jc['name'] . ' joined!', 'j' => array_diff_key($jc, ['w' => 1])];
            continue;
        }
        $key = (string)($it['k'] ?? '');
        $row = trek_text_row($key);
        $text = trek_scene_plain($key, (array)($it['v'] ?? []), $u);
        if ($text === '' || !$row) continue;
        $spk = (string)($row['speaker'] ?? '');
        $w = $spk === 'gnome' ? 'me' : ($spk !== '' && $row['kind'] !== 'place' ? $spk : '');
        foreach (explode("\n", $text) as $line) {
            $line = trim($line);
            if ($line === '') continue;
            $bw = $w !== '' && trek_scene_is_speech($line) ? $w : 'nar';
            $beats[] = ['w' => $bw, 't' => $line];
            if ($bw === 'me') $who['me'] ??= ['name' => gnome_name($u), 'ico' => trek_me_ico($u)];
            elseif ($bw !== 'nar') $who[$bw] ??= trek_scene_who($bw);
        }
    }
    if (!$beats) return '';
    return '<div class="trekscene" hidden data-scene="' . e((string)json_encode(['who' => (object)$who, 'beats' => $beats], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)) . '"></div>';
}

/** A recruit: the gnome's reply (log + pop-over), then the "joined!" card. */
function trek_scene_recruit(array &$run, array $u, string $crewKey, string $meKey, bool $placed = true): void
{
    trek_say_text($run, $meKey);
    trek_scene_join($run, $crewKey, $placed);
}
