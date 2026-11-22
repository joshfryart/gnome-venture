<?php
declare(strict_types=1);
/**
 * 2.7.57 Puzzle combat intro: a short card of 4 steps, shown the first time a player opens the Puzzle box or starts a puzzle fight (whichever comes first),
 * and the same text on the Puzzle box's "How it works" tab. Seen flag per player on the server: table pf_intro (made on first use, SQLite and MySQL).
 * No inline script or style (CSP): assets/pfintro.js steps through the card and sends the "seen" form; without script the steps show one under the other
 * and the form posts to puzzlebox.php (do=pfi_seen). CSS: the .pfi block in assets/pfv1.css.
 */

function pfi_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { db()->exec('CREATE TABLE IF NOT EXISTS pf_intro (user_id INTEGER NOT NULL PRIMARY KEY, seen_at VARCHAR(20) NULL)'); return $ok = true; }
    catch (Throwable $e) { return $ok = false; }
}

/** Has this player closed the intro? (true when the table cannot be made: never nag on a broken install) */
function pfi_seen(int $uid): bool
{
    if (!pfi_ensure()) return true;
    try { return (bool)q_val('SELECT 1 FROM pf_intro WHERE user_id = ?', [$uid]); } catch (Throwable $e) { return true; }
}

function pfi_mark(int $uid): void
{
    if (!pfi_ensure() || pfi_seen($uid)) return;
    try { db_insert('pf_intro', ['user_id' => $uid, 'seen_at' => gmdate('Y-m-d H:i:s')]); } catch (Throwable $e) { /* a second tab got there first */ }
}

/** The four steps: [key, title, icon (assets/img/...), lines]. Plain words, short sentences. */
function pfi_steps(): array
{
    return [
        ['box', 'Your Puzzle box', 'ico/ico-jigsaw-box.png', [
            'The Puzzle box holds the pieces you take into a fight.',
            'Kit: your own pieces. Each one hurts, guards, heals, charms or plays a trick. You choose which ones come along.',
            'Belt: tools you carry. A tool adds a piece and wears down as you use it.',
            'Pals: friends who come with you. Each pal adds a piece of its own.',
        ]],
        ['fight', 'How a fight works', 'ico/ico-link.png', [
            'You and the creature take turns placing jigsaw pieces on the board.',
            'When two edges fit, the pieces link into a chain.',
            'Place a piece and its chain fires: it hurts the creature, guards you, heals you or charms it.',
            'Weather pieces, like sun, rain and bramble, also land on the board. They change what a chain does.',
            'The creature has a guard meter. Its guard soaks up your hits first.',
            'Hurt and charm fill its Yield bar. When the bar is full, you win. More charm than hurt and you win it over.',
        ]],
        ['codex', 'The Creature Codex', 'ico/ico-book-open.png', [
            'The Codex is a tab in the Puzzle box. It lists every creature.',
            'A creature shows up once you meet it in a fight.',
            'Its pieces fill in as it plays them on the board.',
            'Win once and you learn what it is.',
        ]],
        ['deck', 'Change your deck', 'ico/ico-pencil.png', [
            'Open the Puzzle box from the menu (Hobbies) or from My Gnome.',
            'Tap a piece to pack it or take it out.',
            'Before a fight you can swap pieces too, unless Auto deck is on.',
            'Your deck is locked while a fight is on.',
        ]],
    ];
}

/** The steps as list items (shared by the card and the tab). */
function pfi_steps_html(bool $card): string
{
    $h = ''; $n = count(pfi_steps());
    foreach (pfi_steps() as $i => [$k, $title, $icon, $lines]) {
        $h .= '<li class="pfi-step" data-step="' . $i . '" id="pfi-' . ($card ? 'c' : 't') . '-' . $k . '"><div class="pfi-ic"><img src="' . e(url('assets/img/' . $icon)) . '" width="48" height="48" alt="" decoding="async"></div>'
            . '<div class="pfi-tx"><h3>' . ($card ? '<span class="pfi-n">' . ($i + 1) . ' of ' . $n . '</span>' : '') . e($title) . '</h3>';
        if ($k === 'fight') $h .= '<p class="pfi-types" aria-hidden="true">' . implode('', array_map(fn($t) => '<img src="' . e(url('assets/img/pfight/ico-' . $t . '-s.png')) . '" width="24" height="24" alt="">', ['hurt', 'guard', 'heal', 'charm'])) . '<img src="' . e(url('assets/img/ico/ico-sun-rain.png')) . '" width="24" height="24" alt=""></p>';
        $h .= '<ul>' . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', $lines)) . '</ul></div></li>';
    }
    return $h;
}

/**
 * The first-time card ('' once seen, for a guest, or when the table is missing). $back: where the no-script form returns to (puzzlebox | adventure).
 * $keep = true: once seen, the card is still sent, hidden (the fight's help sheet opens it again).
 * Not modal for the page under it: a close (Skip, Done, Esc, a tap outside) hides it and the page goes on as it was.
 */
function pfi_card_html(array $u, string $back = 'puzzlebox', bool $keep = false): string
{
    if (is_guest($u)) return '';
    $seen = setting('pfight_intro') === '0' || pfi_seen((int)$u['id']);   // the admin switch: Off = it never opens by itself
    if ($seen && !$keep) return '';   // $keep: a fight page carries the card hidden, so the help sheet can open it again in place
    $n = count(pfi_steps());
    return '<div class="pfi" id="pfi" data-n="' . $n . '"' . ($seen ? ' data-seen="1" hidden' : '') . '><div class="pfi-bg" data-pfi-x="1" aria-hidden="true"></div>'
        . '<section class="pfi-card" role="dialog" aria-modal="false" aria-labelledby="pfi-h" tabindex="-1">'
        . '<div class="pfi-head"><span class="pfi-chest" aria-hidden="true"><img src="' . e(url('assets/img/chest-body.png')) . '" width="40" height="40" alt=""><img src="' . e(url('assets/img/chest-lid.png')) . '" width="40" height="40" alt=""></span><h2 id="pfi-h">Puzzle combat in 4 steps</h2></div>'
        . '<ol class="pfi-steps">' . pfi_steps_html(true) . '</ol>'
        . '<p class="pfi-dots" aria-hidden="true">' . str_repeat('<i></i>', $n) . '</p>'
        . '<form method="post" action="' . e(url('puzzlebox.php')) . '" class="pfi-act" data-noajax="1">' . csrf_field() . '<input type="hidden" name="do" value="pfi_seen"><input type="hidden" name="back" value="' . e($back === 'adventure' ? 'adventure' : 'puzzlebox') . '">'
        . '<button type="submit" class="btn ghost pfi-skip" name="skip" value="1">Skip</button><button type="button" class="btn ghost pfi-prev" hidden>Back</button><button type="button" class="btn primary pfi-next" hidden>Next</button><button type="submit" class="btn primary pfi-done">Got it</button></form>'
        . '<p class="pfi-foot">Read it again any time: Puzzle box, <a href="' . e(url('puzzlebox.php?t=how')) . '">How it works</a>.</p>'
        . '</section></div><script src="' . e(url('assets/pfintro.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
}

/** The "How it works" tab of the Puzzle box: the same text, all steps open. */
function pfi_tab_html(): string
{
    return '<section class="pfi-page" aria-labelledby="pfi-th"><h3 id="pfi-th" class="pfi-title">How puzzle combat works</h3><ol class="pfi-steps pfi-all">' . pfi_steps_html(false) . '</ol></section>';
}
