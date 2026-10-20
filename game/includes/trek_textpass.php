<?php
/**
 * v2.0.20: Treks text passes from here on. trek_apply_text_file() is the generic form of the earlier trek_apply_text_20xx() passes:
 * a row takes the new body only when it is empty, still holds a text we shipped before (the drafts or any earlier final file), or already is the new one.
 * A body Joshua edited is never touched. Idempotent. Needs trek_data.php (trek_kv_file, trek_drafts, trek_import_texts).
 */
require_once __DIR__ . '/trek_data.php';

/** Every final file shipped before the 2.0.20 pass (their bodies count as "unedited"). */
function trek_text_old_files(): array
{
    return ['trek_final_200.txt', 'trek_final_204.txt', 'trek_final_207.txt', 'trek_final_2012.txt', 'trek_final_2015.txt', 'trek_final_2015_old.txt'];
}

/**
 * Apply $newFile (key|body). $oldFile (optional) holds the exact bodies the new ones replace. Sets setting trek_text_pass = $pass when the file had rows.
 * Returns the number of rows written.
 */
function trek_apply_text_file(string $newFile, string $oldFile = '', int $pass = 0): int
{
    $new = trek_kv_file($newFile);
    if (!$new) return 0;
    $old = [trek_drafts()];
    foreach (trek_text_old_files() as $f) $old[] = trek_kv_file($f);
    if ($oldFile !== '') $old[] = trek_kv_file($oldFile);
    $n = 0;
    foreach (q('SELECT id, text_key, body, status FROM trek_texts')->fetchAll() as $r) {
        $k = $r['text_key'];
        if (!isset($new[$k])) continue;
        $cur = trim((string)$r['body']);
        $was = false;
        foreach ($old as $set) if ($cur === trim((string)($set[$k] ?? ''))) $was = true;
        if ($cur === '' || $was || $cur === $new[$k]) {
            q('UPDATE trek_texts SET body = ?, status = ? WHERE id = ?', [$new[$k], $cur === '' ? 'done' : ($r['status'] ?: 'done'), $r['id']]);
            $n++;
        }
    }
    if ($pass > 0 && (int)setting('trek_text_pass') < $pass) set_setting('trek_text_pass', (string)$pass);
    trek_text_rows(true);
    return $n;
}

/** v2.0.20 pass 7: sluice lines name the water level and the clay layer; the new Chapter II slots (stash, shrine) first. */
function trek_apply_text_2020(): int
{
    trek_import_texts();   // the new slots ship their briefs and drafts in trek_texts_2020.txt / trek_drafts_2020.txt
    return trek_apply_text_file('trek_final_2020.txt', 'trek_final_2020_old.txt', 7);
}

/** v2.0.20 pass 8: camp-type rests heal everyone fully and take fatigue to 0; the kit, old campsite and rest spot lines say rested and whole. */
function trek_apply_text_2021(): int
{
    return trek_apply_text_file('trek_final_2021.txt', 'trek_final_2021_old.txt', 8);
}
