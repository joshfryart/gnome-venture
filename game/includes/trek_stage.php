<?php
declare(strict_types=1);
/** v2.0.40: the Trek stage — the party standing on the chapter's scene, with the foes opposite in a fight. Pictures are optional (see includes/scene.php). */
require_once __DIR__ . '/scene.php';

/** Colour-band fallback per chapter when its backdrop is not drawn yet. */
const TREK_STAGE_FALLBACK = [1 => 'forest', 2 => 'wetland', 3 => 'mountain'];

function trek_stage_html(array &$run, array $u): string
{
    $ch = (int)$run['chapter'];
    $fi = $run['fi'] ?? null;
    $kind = $fi ? 'fight' : (trek_at_camp($run) ? 'camp' : 'path');
    $units = [];
    foreach (trek_party_stats($run, $u) as $slot => $m) {
        $hp = (int)$run['party'][$slot]['hp'];
        $units[] = ['id' => 'a' . $slot, 'side' => 'p', 'name' => (string)$m['name'], 'mini' => 'mini-crew-' . (string)($m['key'] ?? ''), 'html' => (string)$m['ico'],
            'hp' => $fi ? $hp : 0, 'max' => $fi ? (int)$m['max'] : 0, 'ko' => $hp <= 0];
    }
    if ($fi) {
        $n = 0;
        foreach (trek_foe_groups($fi) as $g) {
            if ($n >= 4) break;
            $f = $fi['foes'][$g['show']];
            if ((int)$f['hp'] <= 0) continue;
            $slug = (string)($f['slug'] ?? '');
            $rel = $slug !== '' ? creature_image($slug, true) : '';
            $units[] = ['id' => 'f' . $g['gid'], 'side' => 'f', 'name' => (string)$f['name'], 'mini' => $slug !== '' ? 'mini-' . $slug : '', 'img' => $rel,
                'html' => $rel === '' ? '<span class="gvs-emo">' . emoji_swap(e((string)($f['icon'] ?? '🐾'))) . '</span>' : '',
                'hp' => (int)$f['hp'], 'max' => (int)$f['max']];
            $n++;
        }
    }
    return scene_stage('trek', $ch . '-' . $kind, $units, 'trekstage', TREK_STAGE_FALLBACK[$ch] ?? 'forest');
}
