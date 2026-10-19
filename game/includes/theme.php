<?php
declare(strict_types=1);

/* v1.6.5: dark/light theme. <html data-theme="dark|light" data-pref="dark|light|auto">. Pref comes from users.theme (logged in), else cookie gvtheme, else dark.
 * 'auto' = assets/early.js picks dark/light from the phone before the first paint (server writes dark as the no-JS fallback). */

function theme_clean(?string $v): string
{
    return in_array($v, ['dark', 'light', 'auto'], true) ? $v : '';
}

function theme_pref(): string
{
    $u = current_user();
    if ($u && ($t = theme_clean((string)($u['theme'] ?? '')))) return $t;
    return theme_clean((string)($_COOKIE['gvtheme'] ?? '')) ?: 'dark';
}

function theme_html_attrs(): string
{
    $p = theme_pref();
    return ' data-theme="' . ($p === 'auto' ? 'dark' : $p) . '" data-pref="' . $p . '"';
}

function theme_set_cookie(string $t): void
{
    if (headers_sent()) return;
    $path = (string)(parse_url((string)(($GLOBALS['CONFIG']['base_url'] ?? '')), PHP_URL_PATH) ?: '/');
    setcookie('gvtheme', $t, ['expires' => time() + 31536000, 'path' => $path, 'secure' => is_https(), 'httponly' => true, 'samesite' => 'Lax']);
}

function theme_save(string $t): void
{
    $u = current_user();
    if ($u) q('UPDATE users SET theme = ? WHERE id = ?', [$t, (int)$u['id']]);
    theme_set_cookie($t);
}

/** A page to come back to: same shape layout.php allows for $back (relative .php path, simple query), else Today. */
function theme_clean_back(string $b): string
{
    $b = ltrim($b, '/');
    return preg_match('~^[a-z0-9_/-]+\.php(\?[A-Za-z0-9=&_.-]*)?$~', $b) ? $b : 'index.php';
}

function theme_back(): string
{
    $b = ltrim((string)preg_replace('~^' . preg_quote(rtrim(url(''), '/'), '~') . '/~', '', (string)($_SERVER['REQUEST_URI'] ?? '')), '/');
    return theme_clean_back($b);
}

/** Small switch: shows the button for the OTHER theme (CSS hides the one that matches the current theme). */
function theme_toggle(string $cls = ''): string
{
    return '<form method="post" action="' . e(url('theme.php')) . '" class="themeform th-toggle ' . $cls . '" data-noajax="1">' . csrf_field()
        . '<input type="hidden" name="back" value="' . e(theme_back()) . '">'
        . '<button type="submit" name="theme" value="light" class="thb th-to-light" aria-label="Switch to light theme"><span aria-hidden="true">☀️</span><span class="thl"> Light</span></button>'
        . '<button type="submit" name="theme" value="dark" class="thb th-to-dark" aria-label="Switch to dark theme"><span aria-hidden="true">🌙</span><span class="thl"> Dark</span></button></form>';
}

/** Account page: dark / light / match my phone. */
function theme_choice(): string
{
    $p = theme_pref();
    $h = '<form method="post" action="' . e(url('theme.php')) . '" class="themeform themechoice" data-noajax="1">' . csrf_field()
        . '<input type="hidden" name="back" value="account.php">';
    foreach (['dark' => '🌙 Dark', 'light' => '☀️ Light', 'auto' => '📱 Match my phone'] as $v => $l) {
        $h .= '<button type="submit" name="theme" value="' . $v . '" class="thb" aria-pressed="' . ($p === $v ? 'true' : 'false') . '">' . e($l) . '</button>';
    }
    return $h . '</form>';
}
