<?php
// v2.0.8: the Treks talk pop-over ("scene"). The server turns a few story text slots into plain-text beats and parks them in the session;
// the next Map render emits them once as a hidden stage that assets/trekscene.js opens as a dialog. The normal log lines stay as they are.

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

/**
 * Park a scene for the next Map render. $parts = [[who, crewKey|null, textKey, vars], ...] with who = 'npc' | 'npc2' | 'me'.
 * npc parts: a line that starts with a quote is that speaker's speech, any other line is a narration beat ('nar'). A 'me' part is all the gnome's.
 * Unwritten (empty) slots are skipped; with no beat at all nothing is stored.
 */
function trek_scene_queue(array $run, array $u, array $parts): void
{
    $who = [];
    $beats = [];
    foreach ($parts as $p) {
        [$w, $crew, $key] = [(string)($p[0] ?? 'npc'), $p[1] ?? null, (string)($p[2] ?? '')];
        $text = trek_scene_plain($key, (array)($p[3] ?? []), $u);
        if ($text === '') continue;
        $isMe = $w === 'me';
        $before = count($beats);
        foreach (explode("\n", $text) as $line) {
            $line = trim($line);
            if ($line === '') continue;
            $beats[] = ['w' => $isMe ? 'me' : (trek_scene_is_speech($line) ? $w : 'nar'), 't' => $line];
        }
        if (count($beats) === $before) continue;
        if ($isMe) {
            $who['me'] ??= ['name' => gnome_name($u), 'ico' => trek_me_ico($u)];
        } elseif ($crew !== null && $crew !== '' && !isset($who[$w])) {
            $npc = trek_crew_npc((string)$crew);
            $calling = (string)(trek_crew()[$crew]['calling'] ?? '');
            $who[$w] = ['name' => trek_first_name_of((string)$npc['name']), 'ico' => ph_or_emoji('npc-' . (string)($npc['slug'] ?? ''), TREK_CREW_ICONS[$calling] ?? '🧑', 64)];
        }
    }
    if (!$beats) return;
    foreach ($beats as $b) if ($b['w'] !== 'nar' && !isset($who[$b['w']])) $who[$b['w']] = ['name' => '', 'ico' => '🧑'];   // a speaker with no crew key: never leave a beat without a portrait
    $_SESSION['trek_scene'] = ['run' => (int)$run['id'], 't' => time(), 'who' => $who, 'beats' => $beats];
}

/** The one-shot stage for assets/trekscene.js, or ''. Taken (and cleared) on every call; this run only, fresh for 30 s. */
function trek_scene_stage(array $run, array $u): string
{
    $s = $_SESSION['trek_scene'] ?? null;
    unset($_SESSION['trek_scene']);
    if (!is_array($s) || (int)($s['run'] ?? 0) !== (int)$run['id'] || time() - (int)($s['t'] ?? 0) > 30 || empty($s['beats'])) return '';
    return '<div class="trekscene" hidden data-scene="' . e((string)json_encode(['who' => $s['who'], 'beats' => $s['beats']], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)) . '"></div>';
}

/** A recruit scene: the trailmate's slot, then the gnome's reply (also written to the log, so it reads there too). */
function trek_scene_recruit(array &$run, array $u, string $crewKey, string $npcKey, string $meKey, array $vars): void
{
    trek_say_text($run, $meKey);
    trek_scene_queue($run, $u, [['npc', $crewKey, $npcKey, $vars], ['me', null, $meKey, []]]);
}
