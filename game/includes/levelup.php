<?php
declare(strict_types=1);
/**
 * v2.7.43: the level-up lettering. Pixel letters drawn as SVG rects (the style guide says display lettering is art, not a font),
 * so it works with the strict CSP. Each letter sprouts in turn; buds and a vine grow on the word, flowers bloom beside the number.
 * Colours and timing are all classes in style.css (.lvlup-*); nothing inline.
 */
const LVLUP_FONT = [
    'L' => ['X....', 'X....', 'X....', 'X....', 'X....', 'X....', 'XXXXX'],
    'E' => ['XXXXX', 'X....', 'X....', 'XXXX.', 'X....', 'X....', 'XXXXX'],
    'V' => ['X...X', 'X...X', 'X...X', 'X...X', 'X...X', '.X.X.', '..X..'],
    'U' => ['X...X', 'X...X', 'X...X', 'X...X', 'X...X', 'X...X', '.XXX.'],
    'P' => ['XXXX.', 'X...X', 'X...X', 'XXXX.', 'X....', 'X....', 'X....'],
    '!' => ['X', 'X', 'X', 'X', 'X', '.', 'X'],
    '0' => ['.XXX.', 'X...X', 'X..XX', 'X.X.X', 'XX..X', 'X...X', '.XXX.'],
    '1' => ['..X..', '.XX..', '..X..', '..X..', '..X..', '..X..', '.XXX.'],
    '2' => ['.XXX.', 'X...X', '....X', '...X.', '..X..', '.X...', 'XXXXX'],
    '3' => ['XXXXX', '...X.', '..X..', '...X.', '....X', 'X...X', '.XXX.'],
    '4' => ['...X.', '..XX.', '.X.X.', 'X..X.', 'XXXXX', '...X.', '...X.'],
    '5' => ['XXXXX', 'X....', 'XXXX.', '....X', '....X', 'X...X', '.XXX.'],
    '6' => ['..XX.', '.X...', 'X....', 'XXXX.', 'X...X', 'X...X', '.XXX.'],
    '7' => ['XXXXX', '....X', '...X.', '..X..', '.X...', '.X...', '.X...'],
    '8' => ['.XXX.', 'X...X', 'X...X', '.XXX.', 'X...X', 'X...X', '.XXX.'],
    '9' => ['.XXX.', 'X...X', 'X...X', '.XXXX', '....X', '...X.', '.XX..'],
];

/** The glyph's rows made one pixel bolder to the right (a 1-pixel stroke is too thin next to the outline). */
function lvlup_rows(string $ch): ?array
{
    $g = LVLUP_FONT[$ch] ?? null;
    if (!$g) return null;
    return array_map(function ($row) {
        $o = '';
        for ($i = 0, $n = strlen($row); $i <= $n; $i++) $o .= (($row[$i] ?? '.') === 'X' || ($row[$i - 1] ?? '.') === 'X') && $i >= 0 && !($i === 0 && ($row[0] ?? '.') !== 'X') ? 'X' : '.';
        return $o;
    }, $g);
}

/** Pixel rects of one glyph at (ox, oy): 'f' fill, with 'hi' on pixels with nothing above and 'lo' on pixels with nothing below. */
function lvlup_glyph(string $ch, int $ox, int $oy): string
{
    $g = lvlup_rows($ch);
    if (!$g) return '';
    $out = '';
    foreach ($g as $y => $row) {
        for ($x = 0, $n = strlen($row); $x < $n; $x++) {
            if ($row[$x] !== 'X') continue;
            $cls = ($y === 0 || ($g[$y - 1][$x] ?? '.') !== 'X') ? 'hi' : ((($g[$y + 1][$x] ?? '.') !== 'X') ? 'lo' : '');
            $out .= '<rect' . ($cls ? ' class="' . $cls . '"' : '') . ' x="' . ($ox + $x) . '" y="' . ($oy + $y) . '" width="1" height="1"/>';
        }
    }
    return $out;
}

/** A pixel flower (5x5: four petals round a centre) at (ox, oy). */
function lvlup_flower(int $ox, int $oy, string $cls): string
{
    $petals = [[1, 0], [2, 0], [3, 0], [0, 1], [4, 1], [0, 2], [4, 2], [0, 3], [4, 3], [1, 4], [2, 4], [3, 4]];
    $o = '<g class="lvlup-flower ' . $cls . '">';
    foreach ($petals as [$x, $y]) $o .= '<rect class="pt" x="' . ($ox + $x) . '" y="' . ($oy + $y) . '" width="1" height="1"/>';
    foreach ([[1, 1], [2, 1], [3, 1], [1, 2], [3, 2], [1, 3], [2, 3], [3, 3]] as [$x, $y]) $o .= '<rect class="pt" x="' . ($ox + $x) . '" y="' . ($oy + $y) . '" width="1" height="1"/>';
    return $o . '<rect class="ce" x="' . ($ox + 2) . '" y="' . ($oy + 2) . '" width="1" height="1"/></g>';
}

/**
 * The lettering as one inline SVG. $kind 'word' = green letters that sprout, with buds and a vine; 'num' = gold numerals with a flower each side.
 */
function lvlup_svg(string $text, string $kind, string $label): string
{
    $chars = str_split($text);
    $w = 0;
    foreach ($chars as $c) $w += $c === ' ' ? 3 : strlen(lvlup_rows($c)[0] ?? '.') + 1;
    $w -= 1;
    $top = $kind === 'word' ? 5 : 0;
    $pad = $kind === 'num' ? 8 : 0;   // room for a flower on each side
    $vb = ($w + $pad * 2 + 2) . ' ' . ($top + 7 + ($kind === 'word' ? 5 : 0) + 2);
    $o = '<svg class="lvlup-art lvlup-' . $kind . '" viewBox="-1 -1 ' . $vb . '" aria-hidden="true" focusable="false">';
    $x = $pad; $i = 0; $glyphs = [];
    foreach ($chars as $c) {
        if ($c === ' ') { $x += 3; continue; }
        $glyphs[] = [$c, $x, $i++];
        $x += strlen(lvlup_rows($c)[0] ?? '.') + 1;
    }
    foreach (['o', 'f'] as $pass) {   // outline pass first (fat strokes), then the fills on top
        $o .= '<g class="lvlup-' . $pass . '">';
        foreach ($glyphs as [$c, $gx, $n]) $o .= '<g class="lg lg' . $n . '">' . lvlup_glyph($c, $gx, $top) . '</g>';
        $o .= '</g>';
    }
    if ($kind === 'word') {
        $o .= '<g class="lvlup-buds">';   // a sprout above some letters: stem, two leaves
        foreach ($glyphs as [$c, $gx, $n]) {
            if (!in_array($n, [1, 3, 6], true)) continue;
            $cx = $gx + intdiv(strlen(lvlup_rows($c)[0]), 2);
            $o .= '<g class="bud bud' . $n . '"><rect class="st" x="' . $cx . '" y="3" width="1" height="2"/><rect class="lf" x="' . ($cx - 1) . '" y="2" width="1" height="1"/><rect class="lf" x="' . ($cx + 1) . '" y="1" width="1" height="1"/><rect class="lf hi" x="' . ($cx + 1) . '" y="2" width="1" height="1"/></g>';
        }
        $o .= '</g><g class="lvlup-vine">';   // a vine under the word, with a leaf every few steps
        $vy = $top + 8;
        for ($vx = 0; $vx <= $w; $vx++) {
            $dy = (int)round(sin($vx / 2.6));
            $o .= '<rect x="' . $vx . '" y="' . ($vy + $dy) . '" width="1" height="1"/>';
            if ($vx % 7 === 3) $o .= '<rect class="lf" x="' . $vx . '" y="' . ($vy + $dy + ($dy <= 0 ? 1 : -1)) . '" width="1" height="1"/>';
        }
        $o .= '</g>';
    } else {
        $o .= lvlup_flower(0, 1, 'fl1') . lvlup_flower($w + $pad * 2 - 5, 1, 'fl2');
    }
    return $o . '</svg>';
}
