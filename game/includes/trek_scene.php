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
    if (!trek_scene_push($rid, ['k' => $key, 'v' => $vars])) return;   // queue full: not marked seen, so it can still show later
    $seen[$key] = 1;
    if (count($seen) > 400) $seen = array_slice($seen, -200, null, true);
}

/**
 * v2.0.18: the story text of the spot the party stands on (or next to a shut gate) is a talk pop-over the FIRST time too. Those lines are printed
 * by trek_spot_panel() with trek_text(), not trek_say_text(), so nothing noted them (Captain Bracken's duel challenge was only a panel).
 * Called on the Map render before trek_scene_stage(); once per key per run (trek_scene_seen); the panel itself stays.
 */
function trek_scene_spot(array &$run, array $u): void
{
    if (!empty($run['fi'])) return;
    $ch = (int)$run['chapter'];
    $spot = trek_here($run, $u);
    if (!$spot) {
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $s = trek_spot_at($ch, (int)$run['x'] + $dx, (int)$run['y'] + $dy);
            if ($s && $s['type'] === 'gate' && !trek_gate_open($run, $s)) { trek_scene_collect($run, 'ch' . $ch . '.spot.' . $s['code'] . '.locked'); return; }
        }
        return;
    }
    $code = (string)$spot['code'];
    $done = trek_spot_done($run, $spot);
    $crew = isset($spot['data']['crew']) ? (string)$spot['data']['crew'] : '';
    $vars = $crew !== '' && trek_crew_npc($crew) ? ['trailmate' => trek_crew_npc($crew)['name']] : [];
    $part = null;
    switch ($spot['type']) {
        case 'start': case 'sign': case 'hidden': $part = 'arrive'; break;
        case 'find': $part = $done ? null : 'arrive'; break;
        case 'npc': $part = 'talk'; break;
        case 'recruit':
            if ($done) break;
            $part = !empty($spot['data']['needs']) && !trek_flag($run, (string)$spot['data']['needs']) ? 'locked' : 'before';
            break;
        case 'fetch': case 'cart': case 'mush': case 'slide': case 'trade': $part = $done ? null : 'before'; break;
        case 'switch': case 'rest': $part = $done ? null : 'before'; break;
        case 'chest': $part = $done ? null : 'locked'; break;
        case 'riddle':
            $max = (int)($spot['data']['tries'] ?? 2);
            $part = !$done && (int)($run['st']['tries_' . $code] ?? 0) < $max ? 'question' : null;
            break;
        case 'duel': $part = $done ? null : 'before'; break;
        case 'miniboss': case 'boss': $part = $done ? null : 'intro'; break;
    }
    if ($part !== null) trek_scene_collect($run, 'ch' . $ch . '.spot.' . $code . '.' . $part, $vars);
}

/** The party-member-joined card: crew key + whether they got a place (false = waits on the bench). */
function trek_scene_join(array $run, string $crewKey, bool $placed): void
{
    trek_scene_push((int)$run['id'], ['join' => $crewKey, 'placed' => $placed]);
}

function trek_scene_push(int $rid, array $item): bool
{
    $a = $_SESSION['trek_scene_auto'] ?? null;
    if (!is_array($a) || (int)($a['run'] ?? 0) !== $rid || time() - (int)($a['t'] ?? 0) > 30) $a = ['run' => $rid, 't' => time(), 'items' => []];
    $fit = count($a['items']) < TREK_SCENE_MAX;
    if ($fit) $a['items'][] = $item;
    $a['t'] = time();
    $_SESSION['trek_scene_auto'] = $a;
    return $fit;
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
    if (!$npc) return null;
    $st = trek_party_stats($run, $u);
    $m = null;
    foreach ($st as $p) if ($p['key'] === $crewKey) { $m = $p; break; }
    if ($m) { $lvl = (int)$m['tl']; $hp = (int)$m['max']; $gc = $m['gc']; }
    else { $mu = trek_crew_user($crewKey, $u); $gc = gnome_combat($mu); $lvl = isset($run['st']['tl'][$crewKey]) ? trek_tl_get($run, $crewKey)[0] : max(1, (int)round(trek_tl_avg($run)) - 2); $hp = (int)$gc['max_hp']; }
    $cl = CALLINGS[$crew['calling']] ?? null;
    $bio = trim((string)($npc['bio'] ?? ''));
    if (mb_strlen($bio) > 220) $bio = mb_substr($bio, 0, 217) . '…';
    return ['w' => (string)$crew['npc_slug'], 'name' => trek_first_name_of((string)$npc['name']), 'full' => (string)$npc['name'],
        'sub' => trim(((string)($npc['species'] ?? '') !== '' ? (string)$npc['species'] . ' · ' : '') . ($cl ? $cl[0] : '') . ' · Trek Lv ' . $lvl, ' ·'),
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
            $parts = [[$w !== '' && trek_scene_is_speech($line) ? $w : 'nar', $line]];
            if ($w !== '' && !trek_scene_is_speech($line) && preg_match('/^([^“"]+?)\s*(“[^”]+”)$/u', $line, $mm)) $parts = [['nar', $mm[1]], [$w, $mm[2]]];   // 'Tumble bows. “Lovely!”' = narration, then speech
            foreach ($parts as [$bw, $txt]) {
                $beats[] = ['w' => $bw, 't' => $txt];
                if ($bw === 'me') $who['me'] ??= ['name' => gnome_name($u), 'ico' => trek_me_ico($u)];
                elseif ($bw !== 'nar') $who[$bw] ??= trek_scene_who($bw);
            }
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
