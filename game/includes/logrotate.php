<?php
declare(strict_types=1);
/** v1.6.x: keep a log file from growing forever. When $file is bigger than $maxBytes it becomes $file.1 (an older .1 is overwritten). */
function log_rotate_if_big(string $file, int $maxBytes = 1048576): void
{
    try {
        clearstatcache(true, $file);
        if (!is_file($file) || (int)@filesize($file) <= $maxBytes) return;
        @unlink($file . '.1');
        @rename($file, $file . '.1');
    } catch (Throwable $e) { /* logging must never break a page */ }
}
