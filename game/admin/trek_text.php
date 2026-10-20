<?php
declare(strict_types=1);
// v1.8.0: the Trek story text editor. Joshua writes the body of every slot; Claude's brief says what must go in it.
// Filter by chapter (tabs: Chapter I, II, III, Interludes), kind, status (to do / draft / written) or "only unwritten". Saving a body that is not empty turns "to do" into "draft"
// (v1.9.2: the Save form offers Written first, so a plain Save marks the slot written). Claude's suggestion is the draft body from trek_drafts*.txt; "Restore the suggestion" puts it back.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/trek_data.php';
$me = require_admin();

const TREK_KIND_LABEL = ['speech' => 'Speech', 'place' => 'Place', 'narration' => 'Narration', 'boss' => 'Boss', 'item' => 'Item', 'choice' => 'Choice', 'ui' => 'Hint', 'book' => 'Almanac'];
const TREK_LEN_HINT = ['speech' => 300, 'place' => 400, 'narration' => 600, 'boss' => 400, 'item' => 150, 'choice' => 60, 'ui' => 200, 'book' => 1200];

/** audit 1.9.8: one request value as a string; a field sent as an array (x[]=..) counts as empty instead of raising "Array to string conversion". */
function trek_arg(string $get, string $post = ''): string
{
    foreach ([$_GET[$get] ?? null, $post !== '' ? ($_POST[$post] ?? null) : null] as $v) if (is_scalar($v)) return (string)$v;
    return '';
}
$fCh = trek_arg('ch', 'f_ch');   // '' all, a chapter number, or 'i' = the interludes
if ($fCh !== 'i' && !ctype_digit($fCh)) $fCh = '';
if ($fCh === '0') $fCh = '';
$fKind = trek_arg('kind', 'f_kind');
$fStatus = trek_arg('status', 'f_status');
if ($fStatus === 'written') $fStatus = 'done';
$fOnly = trek_arg('only', 'f_only') === '1';
$filterQs = http_build_query(array_filter(['ch' => $fCh !== '' ? $fCh : null, 'kind' => $fKind ?: null, 'status' => $fStatus ?: null, 'only' => $fOnly ? '1' : null]));
$fOpen = trek_arg('open');   // the slot to show open (after a save)
$fPage = max(1, (int)($_GET['p'] ?? 0));
const TREK_GROUPS_PER_PAGE = 12;

/** The scene a slot belongs to: its key without the last part (ch1.spot.burdock.freed -> ch1.spot.burdock). */
function trek_scene_of(string $key): string { $p = explode('.', $key); return count($p) <= 2 ? $p[0] : implode('.', array_slice($p, 0, -1)); }
function trek_scene_label(string $scene): string
{
    $p = explode('.', $scene);
    if (($p[1] ?? '') === 'spot' && isset($p[2])) return '📍 ' . (trek_spots(max(1, (int)substr($p[0], 2)))[$p[2]]['name'] ?? $p[2]);
    if (($p[1] ?? '') === 'zone' && isset($p[2])) return '🗺️ Zone: ' . ((trek_zone_info((int)substr($p[0], 2), $p[2]) ?? [$p[2]])[0]);
    if (($p[0] ?? '') === 'book') return '📖 Almanac pages';
    return '💬 ' . ucfirst(str_replace('.', ' › ', $scene));
}

if (is_post()) {
    csrf_check();
    $key = is_scalar($_POST['key'] ?? null) ? (string)$_POST['key'] : '';
    $row = q_one('SELECT * FROM trek_texts WHERE text_key = ?', [$key]);
    $back = 'admin/trek_text.php?' . ($filterQs !== '' ? $filterQs . '&' : '') . 'open=' . rawurlencode($key) . '#t-' . str_replace('.', '-', $key);
    if (!$row) { flash('Unknown text slot.', 'err'); redirect('admin/trek_text.php'); }
    $body = str_replace("\r\n", "\n", trim(is_scalar($_POST['body'] ?? null) ? (string)$_POST['body'] : ''));
    $restore = !empty($_POST['restore']);   // v1.9.2: back to Claude's suggestion
    if ($restore) {
        $sug = trek_drafts()[$key] ?? '';
        if ($sug === '') { flash('No suggestion for that slot.', 'err'); redirect($back); }
        q('UPDATE trek_texts SET body = ?, status = ?, updated_at = ? WHERE id = ?', [$sug, 'draft', now(), $row['id']]);
        trek_text_sync_book($key, $sug);
        admin_log('trek_text', $key, 'restored the suggestion');
        flash('↩️ Restored the suggestion for ' . $key . ' (draft).');
        redirect($back);
    }
    if (mb_strlen($body) > 4000) { flash('That is too long (4,000 letters at most).', 'err'); redirect($back); }
    $status = is_scalar($_POST['status'] ?? null) ? (string)$_POST['status'] : (string)$row['status'];
    if (!in_array($status, ['todo', 'draft', 'done'], true)) $status = (string)$row['status'];
    if ($body === '') $status = 'todo';
    elseif ($status === 'todo') $status = 'draft';
    q('UPDATE trek_texts SET body = ?, status = ?, updated_at = ? WHERE id = ?', [$body !== '' ? $body : null, $status, now(), $row['id']]);
    trek_text_sync_book($key, $body);
    admin_log('trek_text', $key, mb_substr($body, 0, 200));
    flash('✅ Saved ' . $key . ' (' . $status . ').');
    redirect($back);
}

// done / total per chapter
$prog = [];
foreach (q("SELECT chapter, COUNT(*) AS n, SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) AS d, SUM(CASE WHEN body IS NOT NULL AND body <> '' THEN 1 ELSE 0 END) AS w FROM trek_texts GROUP BY chapter ORDER BY chapter")->fetchAll() as $p) $prog[(int)$p['chapter']] = $p;
$where = [];
$args = [];
if ($fCh === 'i') { $where[] = "text_key LIKE 'interlude.%'"; }
elseif ($fCh !== '') { $where[] = "chapter = ? AND text_key NOT LIKE 'interlude.%'"; $args[] = (int)$fCh; }
if ($fKind !== '' && isset(TREK_KIND_LABEL[$fKind])) { $where[] = 'kind = ?'; $args[] = $fKind; }
if (in_array($fStatus, ['todo', 'draft', 'done'], true)) { $where[] = 'status = ?'; $args[] = $fStatus; }
if ($fOnly) $where[] = "(body IS NULL OR body = '')";
$drafts = trek_drafts();   // v1.9.2: Claude's suggestion for each slot
$rows = q('SELECT * FROM trek_texts' . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . ' ORDER BY chapter, sort_order, id', $args)->fetchAll();
page_header('Trek story text', true);
admin_crumbs('trek_text.php');
?>
<h1>✍️ Trek story text</h1>
<p class="help">Every story line in a trek is a slot. A <b>draft</b> is Claude’s suggestion, which players see until you write your own; <b>Save</b> marks a slot written. Admins also see a ✏️ after any draft in the game itself. Write the text in the box; the bullets say what it must cover. Empty slots show a dashed “to write” note to admins and “…” to players. Tokens: <code>{gnome}</code> <code>{calling}</code> <code>{trailmate}</code> <code>{currency}</code>.
  Treks stay admin-only until <a href="<?= e(url('admin/settings.php#s-treks')) ?>">Treks: open</a> is on.</p>
<?php foreach ($prog as $ch => $p): ?>
  <p class="trekprog"><b>Chapter <?= $ch ?></b>: <?= (int)$p['d'] ?> done · <?= (int)$p['w'] ?> written · <?= (int)$p['n'] ?> slots <?= trek_progress_bar((int)$p['w'], (int)$p['n']) ?></p>
<?php endforeach; ?>
<?php
function trek_progress_bar(int $v, int $n): string { return '<progress max="' . max(1, $n) . '" value="' . $v . '"></progress>'; }
?>
<nav class="tabs trekchtabs" aria-label="Chapter">
<?php foreach (['' => 'All', '1' => 'Chapter I', '2' => 'Chapter II', '3' => 'Chapter III', 'i' => 'Interludes'] as $tk => $tl):
    $qs = http_build_query(array_filter(['ch' => $tk !== '' ? $tk : null, 'kind' => $fKind ?: null, 'status' => $fStatus ?: null, 'only' => $fOnly ? '1' : null])); ?>
  <a class="<?= (string)$tk === $fCh ? 'on' : '' ?>" href="<?= e(url('admin/trek_text.php' . ($qs !== '' ? '?' . $qs : ''))) ?>"><?= e($tl) ?></a>
<?php endforeach; ?>
</nav>
<form method="get" class="form trekfilters">
  <input type="hidden" name="ch" value="<?= e($fCh) ?>">
  <label>Kind <select name="kind" data-autosubmit><option value="">All</option><?php foreach (TREK_KIND_LABEL as $k => $l): ?><option value="<?= e($k) ?>"<?= $k === $fKind ? ' selected' : '' ?>><?= e($l) ?></option><?php endforeach; ?></select></label>
  <label>Status <select name="status" data-autosubmit><option value="">All</option><?php foreach (['todo' => 'To do', 'draft' => 'Draft (a suggestion)', 'done' => 'Written'] as $k => $l): ?><option value="<?= $k ?>"<?= $k === $fStatus ? ' selected' : '' ?>><?= $l ?></option><?php endforeach; ?></select></label>
  <label>Show <select name="only" data-autosubmit><option value="">All slots</option><option value="1"<?= $fOnly ? ' selected' : '' ?>>Only unwritten</option></select></label>
  <noscript><button class="btn small">Filter</button></noscript>
</form>
<?php
$groups = [];
foreach ($rows as $r) $groups[trek_scene_of((string)$r['text_key'])][] = $r;
$ids = array_keys($groups);
$pages = max(1, (int)ceil(count($ids) / TREK_GROUPS_PER_PAGE));
if ($fOpen !== '' && !isset($_GET['p'])) { $gi = array_search(trek_scene_of($fOpen), $ids, true); if ($gi !== false) $fPage = intdiv((int)$gi, TREK_GROUPS_PER_PAGE) + 1; }
$fPage = min($fPage, $pages);
$show = array_slice($ids, ($fPage - 1) * TREK_GROUPS_PER_PAGE, TREK_GROUPS_PER_PAGE);
$pager = function () use ($pages, $fPage, $filterQs) {
    if ($pages <= 1) return '';
    $h = '<p class="trekpager">';
    for ($i = 1; $i <= $pages; $i++) $h .= $i === $fPage ? '<b class="tag">' . $i . '</b> ' : '<a class="btn small ghost" href="' . e(url('admin/trek_text.php?' . ($filterQs !== '' ? $filterQs . '&' : '') . 'p=' . $i)) . '">' . $i . '</a> ';
    return $h . '</p>';
};
?>
<p class="help"><?= count($rows) ?> slot<?= count($rows) === 1 ? '' : 's' ?> in <?= count($ids) ?> scene<?= count($ids) === 1 ? '' : 's' ?>. Open a scene, then a slot.</p>
<?= $pager() ?>
<?php foreach ($show as $scene):
    $list = $groups[$scene];
    $written = count(array_filter($list, fn($r) => (string)$r['body'] !== ''));
    $groupOpen = $fOpen !== '' && trek_scene_of($fOpen) === $scene; ?>
  <details class="trekgroup"<?= $groupOpen ? ' open' : '' ?>>
    <summary><b><?= e(trek_scene_label($scene)) ?></b> <span class="tag"><?= $written ?>/<?= count($list) ?></span></summary>
    <?php foreach ($list as $r):
        $len = mb_strlen((string)$r['body']);
        $hint = TREK_LEN_HINT[$r['kind']] ?? 400;
        $short = substr((string)$r['text_key'], strlen($scene) + 1) ?: (string)$r['text_key'];
        $bullets = array_filter(array_map(fn($l) => trim(ltrim(trim($l), '•')), explode("\n", (string)$r['brief'])), 'strlen');
        $sug = $drafts[(string)$r['text_key']] ?? ''; ?>
      <details class="trekrow status-<?= e($r['status']) ?>" id="t-<?= e(str_replace('.', '-', $r['text_key'])) ?>"<?= $fOpen === $r['text_key'] ? ' open' : '' ?>>
        <summary><code><?= e($short) ?></code> <span class="tag st-<?= e($r['status']) ?>"><?= e(['todo' => 'to do', 'draft' => 'draft', 'done' => 'written'][$r['status']] ?? $r['status']) ?></span><?= $r['speaker'] ? ' <small class="muted">🗣 ' . e((string)$r['speaker']) . '</small>' : '' ?></summary>
        <form method="post" class="form">
          <?= csrf_field() ?><input type="hidden" name="key" value="<?= e($r['text_key']) ?>">
          <input type="hidden" name="f_ch" value="<?= e($fCh) ?>"><input type="hidden" name="f_kind" value="<?= e($fKind) ?>"><input type="hidden" name="f_status" value="<?= e($fStatus) ?>"><input type="hidden" name="f_only" value="<?= $fOnly ? '1' : '' ?>">
          <p class="help"><code><?= e($r['text_key']) ?></code> · <span class="tag"><?= e(TREK_KIND_LABEL[$r['kind']] ?? $r['kind']) ?></span> aim for up to <?= $hint ?> letters</p>
          <p class="help"><b>Where it shows</b></p>
          <ul class="trekbrief"><?php foreach ($bullets as $b): ?><li><?= e($b) ?></li><?php endforeach; ?></ul>
          <?php if ($sug !== ''): ?><div class="trek-sug"><b>Claude’s suggestion</b><div class="trekdraftbody"><?= nl2br(e($sug), false) ?></div></div><?php endif; ?>
          <label>Your text <small class="muted">(<?= $len ?>/<?= $hint ?>)</small>
            <textarea name="body" rows="<?= min(12, max(3, (int)ceil($hint / 70))) ?>"><?= e((string)$r['body']) ?></textarea></label>
          <?php $selSt = $r['status'] === 'todo' ? 'done' : ($r['status'] === 'draft' ? 'done' : $r['status']); ?>
          <label>Mark as <select name="status"><?php foreach (['done' => 'Written', 'draft' => 'Still a draft', 'todo' => 'To do'] as $k => $l): ?><option value="<?= $k ?>"<?= $k === $selSt ? ' selected' : '' ?>><?= $l ?></option><?php endforeach; ?></select></label>
          <p><button class="btn small">💾 Save</button> <?php if ($sug !== '' && (string)$r['body'] !== $sug): ?><button class="btn small ghost" name="restore" value="1" formnovalidate>↩️ Restore the suggestion</button> <?php endif; ?> <?= $r['updated_at'] ? '<small class="muted">saved ' . e((string)$r['updated_at']) . ' UTC</small>' : '' ?></p>
        </form>
      </details>
    <?php endforeach; ?>
  </details>
<?php endforeach; ?>
<?= $pager() ?>
<?php page_footer();
