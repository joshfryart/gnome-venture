<?php
declare(strict_types=1);
/**
 * Sights, sixth pass B: Sights shared ACROSS players (claude/sights/GRAMMAR.md "Sixth pass B"; test tests/trail_sights_shared.sh).
 *   (a) the cairn count: one shared tally, every stone anyone adds (the cairn pass Sight, tally key `cairn-stones`), shown to all;
 *   (b) a note written by one player is delivered to ANOTHER player's message bottle (Satchel "Open the bottle", and the `bottle=1` coast Sight);
 *   (c) stargazers-chalk marks: a short word chalked on the star-chart stones is shown to others who stand there.
 * Everything is anonymous: the receiver never sees a name. Free text is cleaned (tags stripped, links / emails / numbers refused, 80 characters),
 * rate limited per gnome per day, reportable (a note hides at the first report, a mark at the second) and listed in Admin > Shared Sights.
 * Settings: sights_shared_on (the whole feature, default ON since 2.8.77), sights_shared_text (free text on, default on; off = only the counts), sights_shared_block (words refused).
 * No other player = no change: a bottle with no stranger's note uses the old bottle post. New tables: sights_shared_items, sights_shared_reports, sights_shared_tally.
 * Hooks elsewhere (one line each): schema.php, functions.php settings, trail_sights.php require, trail_sight_extras.php tally, trail_sights_5.php chalk / bottle / foot, shelves.php.
 */

const SIGHTS6_MAX = 80;                 // characters in a note or a mark
const SIGHTS6_NOTES_PER_DAY = 3;        // notes one gnome may send a day
const SIGHTS6_MARKS_PER_DAY = 5;        // chalk words one gnome may write a day
const SIGHTS6_REPORTS_PER_DAY = 10;
const SIGHTS6_MARK_HIDE_AT = 2;         // a mark hides itself when this many different gnomes report it (a note hides at the first report)
const SIGHTS6_MARKS_SHOWN = 5;
const SIGHTS6_NOTES_KEPT = 5;           // received notes listed in the Satchel
const SIGHTS6_POOL_CAP = 300;           // undelivered notes waiting: past this no new one is taken (a flood stops here)
const SIGHTS6_TALLIES = ['cairn-stones' => 'cairn-pass'];   // private tally key => shared tally key
const SIGHTS6_CAIRN_SIGHT = 'mountain-the-cairn-pass';
const SIGHTS6_BOTTLE_ITEM = 'message-bottle';
const SIGHTS6_NOTE_ITEM = 'stranger-note';
const SIGHTS6_DEFAULT_BLOCK = 'fuck,shit,bitch,cunt,dick,nazi,rape,sex,porn,kill yourself,kys,hate you';

function sights6_settings(): array
{
    return [
        'sights_shared_on' => ['label' => 'Shared Sights: other players’ notes in the message bottle, chalk words on the stones, the shared cairn count (off = everything stays private, as before)', 'type' => 'bool', 'default' => '1'],
        'sights_shared_text' => ['label' => 'Shared Sights: players may write notes and chalk words (off = only the shared counts, no free text)', 'type' => 'bool', 'default' => '1'],
        'sights_shared_block' => ['label' => 'Shared Sights: words and phrases a note or mark may not contain (comma separated, any case)', 'type' => 'text', 'default' => SIGHTS6_DEFAULT_BLOCK],
    ];
}

function sights6_on(): bool { return setting('sights_shared_on') === '1'; }
function sights6_text_on(): bool { return sights6_on() && setting('sights_shared_text') !== '0'; }

/** Tables, in the shape of the other *_schema() functions: [tables, indexes, columns]. */
function sights6_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS sights_shared_items (
        id $PK,
        kind VARCHAR(8) NOT NULL,
        place VARCHAR(80) NOT NULL,
        user_id $ID NOT NULL,
        body VARCHAR(200) NOT NULL,
        created_at DATETIME NOT NULL,
        to_user $ID NULL,
        delivered_at DATETIME NULL,
        hidden INT NOT NULL DEFAULT 0,
        reports INT NOT NULL DEFAULT 0,
        dismissed INT NOT NULL DEFAULT 0
    )$END",
    "CREATE TABLE IF NOT EXISTS sights_shared_reports (
        item_id $ID NOT NULL,
        user_id $ID NOT NULL,
        created_at DATETIME NOT NULL,
        PRIMARY KEY (item_id, user_id)
    )$END",
    "CREATE TABLE IF NOT EXISTS sights_shared_tally (
        skey VARCHAR(80) NOT NULL PRIMARY KEY,
        n INT NOT NULL DEFAULT 0
    )$END"];
    $i = ['CREATE INDEX idx_sights_shared_kind ON sights_shared_items (kind, place, hidden)', 'CREATE INDEX idx_sights_shared_user ON sights_shared_items (user_id, created_at)', 'CREATE INDEX idx_sights_shared_to ON sights_shared_items (to_user)'];
    return [$t, $i, []];
}

/** Make the tables and the note item if the upgrade has not yet (same-version installs and tests). */
function sights6_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM sights_shared_items LIMIT 1'); q('SELECT 1 FROM sights_shared_reports LIMIT 1'); q('SELECT 1 FROM sights_shared_tally LIMIT 1'); }
    catch (Throwable $e) {
        try {
            $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
            [$t, $i] = sights6_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
            foreach ($t as $sql) db()->exec($sql);
            foreach ($i as $sql) { try { db()->exec($sql); } catch (Throwable $e2) {} }
        } catch (Throwable $e3) { error_log('sights6_ensure: ' . $e3->getMessage()); return $ok = false; }
    }
    try {
        if (!q_val('SELECT 1 FROM items WHERE slug = ?', [SIGHTS6_NOTE_ITEM]))
            db_insert('items', ['slug' => SIGHTS6_NOTE_ITEM, 'name' => 'Note from a Stranger', 'category' => 'misc', 'rarity' => 1, 'base_price' => 0, 'description' => 'A note from another gnome, found in a bottle. Open your Satchel entry to read it (and to report it if it is not kind).', 'edible' => 0, 'effects' => '{}', 'tradable' => 0]);
    } catch (Throwable $e) { error_log('sights6_ensure item: ' . $e->getMessage()); }
    return $ok = true;
}

// ---------------------------------------------------------------- cleaning and limits

/** Clean free text. Returns [text, error]: error '' = fine. Tags are stripped (output is escaped again), whitespace is collapsed, links, emails and long numbers are refused. */
function sights6_clean(string $raw): array
{
    $s = preg_replace('/[\x00-\x1F\x7F]+/u', ' ', strip_tags($raw)) ?? '';
    $s = trim(preg_replace('/\s+/u', ' ', $s) ?? '');
    if ($s === '') return ['', 'Write a few words first.'];
    if (mb_strlen($s) > SIGHTS6_MAX) return [mb_substr($s, 0, SIGHTS6_MAX), 'That is more than ' . SIGHTS6_MAX . ' characters. Please make it shorter.'];
    if (preg_match('~(https?:|www\.|@|\.(com|net|org|io|gg|co|uk|ly|me)\b|\d{5,})~iu', $s)) return [$s, 'Please leave out links, emails, names of places on the web and phone numbers.'];
    $block = setting('sights_shared_block');
    foreach (array_filter(array_map('trim', explode(',', mb_strtolower($block === '' ? SIGHTS6_DEFAULT_BLOCK : $block)))) as $w)
        if ($w !== '' && preg_match('/(?<![\p{L}])' . preg_quote($w, '/') . '(?![\p{L}])/u', mb_strtolower($s))) return [$s, 'Please keep it kind: that word is not allowed.'];
    return [$s, ''];
}

function sights6_day_start(): string { return gmdate('Y-m-d') . ' 00:00:00'; }

function sights6_sent_today(int $uid, string $kind): int
{
    return (int)q_val('SELECT COUNT(*) FROM sights_shared_items WHERE user_id = ? AND kind = ? AND created_at >= ?', [$uid, $kind, sights6_day_start()]);
}

function sights6_tally_add(string $key, int $n = 1): int
{
    try {
        if (q('UPDATE sights_shared_tally SET n = n + ? WHERE skey = ?', [$n, $key])->rowCount() < 1) { try { db_insert('sights_shared_tally', ['skey' => $key, 'n' => $n]); } catch (Throwable $e) { q('UPDATE sights_shared_tally SET n = n + ? WHERE skey = ?', [$n, $key]); } }
        return (int)q_val('SELECT n FROM sights_shared_tally WHERE skey = ?', [$key]);
    } catch (Throwable $e) { return 0; }
}
function sights6_tally(string $key): int { try { return (int)q_val('SELECT n FROM sights_shared_tally WHERE skey = ?', [$key]); } catch (Throwable $e) { return 0; } }

// ---------------------------------------------------------------- (a) the cairn count

/** trail_sight_extras.php: a private tally went up. Returns journal lines for the shared one. */
function sights6_tally_hook(array $u, string $key): array
{
    if (!isset(SIGHTS6_TALLIES[$key]) || !sights6_on() || !sights6_ensure()) return [];
    $n = sights6_tally_add(SIGHTS6_TALLIES[$key]);
    return ['🗿 Yours is stone number ' . $n . ' on this cairn. Gnomes from all over have added to it.'];
}

function sights6_cairn_count(): int { return sights6_on() ? sights6_tally(SIGHTS6_TALLIES['cairn-stones']) : 0; }

// ---------------------------------------------------------------- (b) notes between players

/** Send a note: costs a message bottle. [ok, message] */
function sights6_note_send(array $u, string $raw): array
{
    $uid = (int)$u['id'];
    if (!sights6_text_on() || !sights6_ensure()) return [false, 'Nobody is sending notes right now.'];
    [$text, $err] = sights6_clean($raw);
    if ($err !== '') return [false, $err];
    if (sights6_sent_today($uid, 'note') >= SIGHTS6_NOTES_PER_DAY) return [false, 'You have sent ' . SIGHTS6_NOTES_PER_DAY . ' notes today. The sea needs a rest: try again tomorrow.'];
    if ((int)q_val("SELECT COUNT(*) FROM sights_shared_items WHERE kind = 'note' AND to_user IS NULL AND hidden = 0") >= SIGHTS6_POOL_CAP) return [false, 'The tide is full of bottles already. Try again later.'];
    $iid = (int)item_id_by_slug(SIGHTS6_BOTTLE_ITEM);
    if (!$iid || !give_item($uid, $iid, -1)) return [false, 'You need a Message in a Bottle to send a note.'];
    db_insert('sights_shared_items', ['kind' => 'note', 'place' => 'bottle', 'user_id' => $uid, 'body' => $text, 'created_at' => now(), 'hidden' => 0, 'reports' => 0, 'dismissed' => 0]);
    add_xp($uid, 2);
    return [true, '🍾 You write your note, cork the bottle and let the tide take it. Someone, somewhere, will read it (+2 XP).'];
}

/** Take the oldest waiting note written by somebody else and make it this gnome's. Returns the row, or null when there is none (or the feature is off). */
function sights6_note_take(int $uid): ?array
{
    if (!sights6_text_on() || !sights6_ensure()) return null;
    for ($try = 0; $try < 5; $try++) {
        $n = q_one("SELECT * FROM sights_shared_items WHERE kind = 'note' AND to_user IS NULL AND hidden = 0 AND user_id <> ? ORDER BY id LIMIT 1", [$uid]);
        if (!$n) return null;
        if (q('UPDATE sights_shared_items SET to_user = ?, delivered_at = ? WHERE id = ? AND to_user IS NULL', [$uid, now(), (int)$n['id']])->rowCount() === 1) {
            $iid = (int)item_id_by_slug(SIGHTS6_NOTE_ITEM); if ($iid) give_item($uid, $iid, 1);
            return $n;
        }
    }
    return null;
}

function sights6_note_lines(array $n): string { return '🍾 The note inside is from another gnome, a stranger. It says: “' . $n['body'] . '”'; }

/** sights5_bottle_open(): open a message bottle with a stranger's note when one is waiting. null = none: the old bottle post runs. [ok, message] */
function sights6_bottle_open(array $u, int $itemId): ?array
{
    $uid = (int)$u['id'];
    if (!sights6_text_on() || !sights6_ensure()) return null;
    if (!q_val("SELECT 1 FROM sights_shared_items WHERE kind = 'note' AND to_user IS NULL AND hidden = 0 AND user_id <> ? LIMIT 1", [$uid])) return null;
    if (!give_item($uid, $itemId, -1)) return [false, 'You do not have that.'];
    $n = sights6_note_take($uid);
    if (!$n) { give_item($uid, $itemId, 1); return null; }
    add_xp($uid, 2);
    return [true, 'You pull the cork. ' . sights6_note_lines($n) . ' (+2 XP. It is in your Satchel if you want to read it again.)'];
}

/** trail_sight_b_pay (bottle=1 at the coast): sometimes the washed-up bottle holds a stranger's note. Returns journal lines or [] (then the old machinery pays). */
function sights6_bottle_stranger(array $u, int $pct = 60): array
{
    if (!sights6_text_on() || random_int(1, 100) > $pct) return [];
    $n = sights6_note_take((int)$u['id']);
    return $n ? ['🍾 A bottle washes up. ' . sights6_note_lines($n)] : [];
}

/** Notes this gnome has been sent (not hidden, not put away), newest first. */
function sights6_notes_for(int $uid): array
{
    if (!sights6_ensure()) return [];
    return q("SELECT * FROM sights_shared_items WHERE kind = 'note' AND to_user = ? AND hidden = 0 AND dismissed = 0 ORDER BY id DESC LIMIT " . SIGHTS6_NOTES_KEPT, [$uid])->fetchAll();
}

// ---------------------------------------------------------------- (c) chalk marks

/** A chalk mark was made at $place (trail_sights_5.php). Counts every chalk; writes the words when there are some. Returns text to add to the journal line. */
function sights6_chalk_after(array $u, string $place, ?string $raw = null): string
{
    if (!sights6_on() || !sights6_ensure()) return '';
    $uid = (int)$u['id'];
    $n = sights6_tally_add('chalk-' . $place);
    $out = ' ' . $n . ' gnomes in all have chalked here.';
    $raw ??= is_scalar($_POST['chalk_text'] ?? null) ? (string)$_POST['chalk_text'] : '';
    if (trim($raw) === '' || !sights6_text_on()) return $out;
    [$text, $err] = sights6_clean($raw);
    if ($err !== '') return $out . ' Your words were not written: ' . $err;
    if (sights6_sent_today($uid, 'mark') >= SIGHTS6_MARKS_PER_DAY) return $out . ' Your words were not written: you have written ' . SIGHTS6_MARKS_PER_DAY . ' marks today.';
    db_insert('sights_shared_items', ['kind' => 'mark', 'place' => $place, 'user_id' => $uid, 'body' => $text, 'created_at' => now(), 'hidden' => 0, 'reports' => 0, 'dismissed' => 0]);
    return $out . ' Your words are on the stones now for others to read.';
}

/** Marks by other gnomes at a place, newest first, never hidden, never this gnome's own. */
function sights6_marks_at(int $uid, string $place): array
{
    if (!sights6_text_on() || !sights6_ensure()) return [];
    return q("SELECT * FROM sights_shared_items WHERE kind = 'mark' AND place = ? AND hidden = 0 AND user_id <> ? ORDER BY id DESC LIMIT " . SIGHTS6_MARKS_SHOWN, [$place, $uid])->fetchAll();
}

function sights6_report_form(int $id, string $back): string
{
    return '<form method="post" action="' . e(url('sights_shared.php')) . '" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="report"><input type="hidden" name="item" value="' . $id . '"><input type="hidden" name="back" value="' . e($back) . '"><button class="btn small alt" title="Tell the Admins this is not kind">⚑ Report</button></form>';
}

/** The text field in the chalk button's form (trail_sights_5.php). */
function sights6_chalk_input(): string
{
    return sights6_text_on() ? '<input type="text" name="chalk_text" maxlength="' . SIGHTS6_MAX . '" placeholder="A few kind words (optional, others will read it)" aria-label="Words to chalk on the stones" class="trailchalktext"> ' : '';
}

/** Under the Trail map: the cairn count near the cairn pass, the others' chalk words near the star-chart stones. */
function sights6_trailfoot_html(array $u, ?array $sc): string
{
    if (!$sc || !sights6_on() || !function_exists('sights5_near') || !sights6_ensure()) return '';
    $h = '';
    if (sights5_near($sc, SIGHTS6_CAIRN_SIGHT) && ($n = sights6_cairn_count()) > 0) $h .= '<p class="help sights6cairn">🗿 This cairn holds <b>' . $n . '</b> stones, added by gnomes from all over.</p>';
    if (sights5_near($sc, SIGHTS5_STONES)) {
        $marks = sights6_marks_at((int)$u['id'], SIGHTS5_STONES);
        $c = sights6_tally('chalk-' . SIGHTS5_STONES);
        if ($marks || $c > 0) {
            $h .= '<div class="help sights6marks">🖍️ Chalked on these stones by other gnomes' . ($c > 0 ? ' (' . $c . ' marks)' : '') . ':';
            foreach ($marks as $m) $h .= ' <span class="sights6mark">“' . e($m['body']) . '” ' . sights6_report_form((int)$m['id'], 'adventure.php') . '</span>';
            $h .= '</div>';
        }
    }
    return $h;
}

/** shelves.php: extra Satchel parts for an item row: a send form on the message bottle, the notes received on the stranger note. */
function sights6_satchel_acts(array $i, string $hid, int $uid): array
{
    $slug = (string)($i['slug'] ?? '');
    if (!sights6_on()) return [];
    if ($slug === SIGHTS6_BOTTLE_ITEM && sights6_text_on())
        return ['<form method="post" action="' . e(url('sights_shared.php')) . '" class="shf">' . csrf_field() . '<input type="hidden" name="do" value="send_note"><input type="hidden" name="back" value="inventory.php">' . $hid
            . '<input type="text" name="text" maxlength="' . SIGHTS6_MAX . '" placeholder="A note for a stranger (up to ' . SIGHTS6_MAX . ' characters, no names or links)" aria-label="Your note" required> <button class="btn alt">✉️ Send a note in this bottle</button></form>'];
    if ($slug !== SIGHTS6_NOTE_ITEM) return [];
    $out = [];
    foreach (sights6_notes_for($uid) as $n)
        $out[] = '<div class="help sights6note">“' . e($n['body']) . '” ' . sights6_report_form((int)$n['id'], 'inventory.php') . ' <form method="post" action="' . e(url('sights_shared.php')) . '" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="putaway"><input type="hidden" name="item" value="' . (int)$n['id'] . '"><input type="hidden" name="back" value="inventory.php"><button class="btn small alt">Put it away</button></form></div>';
    return $out;
}

// ---------------------------------------------------------------- reports, put away

/** A gnome reports a note it was sent or a mark it can read. [ok, message] */
function sights6_report(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    if (!sights6_ensure()) return [false, 'There is nothing to report.'];
    $it = q_one('SELECT * FROM sights_shared_items WHERE id = ?', [$itemId]);
    if (!$it || (int)$it['user_id'] === $uid) return [false, 'There is nothing to report.'];
    if ($it['kind'] === 'note' && (int)($it['to_user'] ?? 0) !== $uid) return [false, 'There is nothing to report.'];
    if ((int)q_val('SELECT COUNT(*) FROM sights_shared_reports WHERE user_id = ? AND created_at >= ?', [$uid, sights6_day_start()]) >= SIGHTS6_REPORTS_PER_DAY) return [false, 'You have sent a lot of reports today. The Admins will look at them first.'];
    if (q_val('SELECT 1 FROM sights_shared_reports WHERE item_id = ? AND user_id = ?', [$itemId, $uid])) return [true, 'You already reported that. Thank you.'];
    db_insert('sights_shared_reports', ['item_id' => $itemId, 'user_id' => $uid, 'created_at' => now()]);
    $n = (int)q_val('SELECT COUNT(*) FROM sights_shared_reports WHERE item_id = ?', [$itemId]);
    $hide = $it['kind'] === 'note' || $n >= SIGHTS6_MARK_HIDE_AT;
    q('UPDATE sights_shared_items SET reports = ? WHERE id = ?', [$n, $itemId]);
    if ($hide) q('UPDATE sights_shared_items SET hidden = 1 WHERE id = ?', [$itemId]);
    return [true, '⚑ Thank you. ' . ($hide ? 'It is hidden now and the Admins will look at it.' : 'The Admins will look at it.')];
}

/** Put a received note away (the note item goes with it). [ok, message] */
function sights6_putaway(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    if (!sights6_ensure() || !q_val("SELECT 1 FROM sights_shared_items WHERE id = ? AND kind = 'note' AND to_user = ? AND dismissed = 0", [$itemId, $uid])) return [false, 'There is nothing to put away.'];
    q('UPDATE sights_shared_items SET dismissed = 1 WHERE id = ?', [$itemId]);
    $iid = (int)item_id_by_slug(SIGHTS6_NOTE_ITEM); if ($iid) give_item($uid, $iid, -1);
    return [true, 'You put the note away.'];
}

/** sights_shared.php: one POST. Returns [ok, message]. */
function sights6_post(array $u, array $p): array
{
    $s = fn(string $k): string => is_scalar($p[$k] ?? null) ? (string)$p[$k] : '';
    return match ($s('do')) {
        'send_note' => sights6_note_send($u, $s('text')),
        'report' => sights6_report($u, (int)$s('item')),
        'putaway' => sights6_putaway($u, (int)$s('item')),
        default => [false, 'Nothing to do.'],
    };
}

// ---------------------------------------------------------------- Admin (game/admin/sights_shared.php)

/** Items for the Admin page: reported first, then newest. */
function sights6_admin_rows(string $filter = 'reported', int $limit = 100): array
{
    if (!sights6_ensure()) return [];
    $where = ['reported' => 'i.reports > 0', 'hidden' => 'i.hidden = 1', 'notes' => "i.kind = 'note'", 'marks' => "i.kind = 'mark'"][$filter] ?? '1 = 1';
    return q("SELECT i.*, a.username AS author, r.username AS receiver FROM sights_shared_items i LEFT JOIN users a ON a.id = i.user_id LEFT JOIN users r ON r.id = i.to_user WHERE $where ORDER BY i.reports DESC, i.id DESC LIMIT " . max(1, min(500, $limit)))->fetchAll();
}

/** Admin action on one item: hide, unhide, delete, clear (reports). Returns a message. */
function sights6_admin_act(int $id, string $act): string
{
    if (!sights6_ensure() || !q_val('SELECT 1 FROM sights_shared_items WHERE id = ?', [$id])) return 'No such item.';
    if ($act === 'hide') q('UPDATE sights_shared_items SET hidden = 1 WHERE id = ?', [$id]);
    elseif ($act === 'unhide') q('UPDATE sights_shared_items SET hidden = 0 WHERE id = ?', [$id]);
    elseif ($act === 'clear') { q('DELETE FROM sights_shared_reports WHERE item_id = ?', [$id]); q('UPDATE sights_shared_items SET reports = 0 WHERE id = ?', [$id]); }
    elseif ($act === 'delete') { q('DELETE FROM sights_shared_reports WHERE item_id = ?', [$id]); q('DELETE FROM sights_shared_items WHERE id = ?', [$id]); }
    else return 'Unknown action.';
    return 'Done: ' . $act . ' #' . $id . '.';
}
