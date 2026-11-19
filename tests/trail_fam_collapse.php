<?php
// 2.7.06 (Josh): every Trail family panel starts collapsed with its first line showing, like the moon pill. No DB, no server.
require __DIR__ . '/../game/includes/trail_families.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$forest = '<section class="tfforest tff-dusk" aria-label="Lantern row"><p class="tff-h"><span aria-hidden="true">🌲</span> Lantern row at dusk: 1 of 3 lit</p><ul class="tff-row"><li>one</li></ul><p class="tff-relay">Relay</p></section>';
$o = trail_fam_collapse($forest);
chk('a plain panel becomes a collapsed pill (details, no open attribute)', str_contains($o, '<details class="moonpill">') && !str_contains($o, '<details class="moonpill" open'), $o);
chk('the summary shows the panel\'s first line, with its emoji as the icon', str_contains($o, '<summary><span aria-hidden="true">🌲</span> Lantern row at dusk: 1 of 3 lit</summary>'), $o);
chk('the rest of the panel is inside the pill body and the section keeps its own tag and classes', str_contains($o, '<div class="moonpill-body"><p class="tff-h">') && str_contains($o, '<ul class="tff-row">') && str_starts_with($o, '<section class="tfforest tff-dusk"') && str_ends_with($o, '</section>'), $o);
$wind = '<section class="tfgrass"><div class="tfg-h">Wind from the west, light</div><p>Seeds drift east.</p></section>';
chk('a div headline works too', str_contains(trail_fam_collapse($wind), '<summary><span aria-hidden="true">🧭</span> Wind from the west, light</summary>'), trail_fam_collapse($wind));
$pill = '<section class="x"><details class="moonpill"><summary>🌕 Full</summary><div class="moonpill-body">z</div></details></section>';
chk('a panel that already collapses (a moon pill) is left alone', trail_fam_collapse($pill) === $pill);
$det = '<details class="tfcoast"><summary>Tide</summary>x</details>';
chk('a panel that is its own <details> is left alone', trail_fam_collapse($det) === $det);
$ledger = '<section class="mwl" aria-label="Sugar-shack ledger"><div class="mwl-h"><b>🧵 Sugar-shack ledger</b> <span class="mwl-n">11/82 patches</span></div><ul class="mwl-row"><li>x</li></ul><details class="mwl-quilt"><summary>🪡 The whole quilt <small>11/82</small></summary><ul class="mwl-grid"><li>y</li></ul></details></section>';
$o = trail_fam_collapse($ledger);
chk('a panel with its own inner details (the Sugar-shack ledger and its quilt) still starts collapsed under its headline', str_contains($o, '<details class="moonpill">') && str_contains($o, '<summary><span aria-hidden="true">🧵</span> Sugar-shack ledger 11/82 patches</summary>') && str_contains($o, '<details class="mwl-quilt">'), $o);
chk('empty stays empty, text that is not a section is left alone', trail_fam_collapse('') === '' && trail_fam_collapse('<p>x</p>') === '<p>x</p>');
$long = '<section><p>' . str_repeat('word ', 40) . '</p></section>';
chk('a long first line is cut for the summary', mb_strlen(strip_tags(explode('</summary>', explode('<summary>', trail_fam_collapse($long))[1])[0])) <= 95);
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
