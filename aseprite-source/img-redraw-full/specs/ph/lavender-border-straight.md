# ph/lavender-border-straight
- canvas: 64x64, mode scene (tile piece), 1x. Bleeds left and right edges, no halo.
- subject: A straight flower border: a low green band with two staggered rows of purple lavender blooms along its length; fragrant, cottage-garden soft.
- must-read-at-16px: green band topped with purple blobs in two tones (dark violet above, pale lilac below).
- distinct: purple bloom puffs in two staggered rows (dark violet upper, pale lilac lower), the only hedge tile with two bloom tones.
- parts:
  1. soil strip: x 0..63, y 37..43, #7a4a1f
  2. green base band: y 24..40, overlapping puffs r 8, base #6a9a3a moss
  3. upper bloom row: 5 px round puffs at y 28..32, x = -1,5,12,18,25,31,37,44,50,57,63, base #7b66b4 (dusk), shade #3e2f66
  4. lower bloom row: 4 px puffs at y 32..36, x = 2,8,15,21,28,34,40,47,53,60 (offset 3 px right of the upper row), base #c3b2ea pale lilac, 1px shade #7b66b4
  5. top highlight line y 27, #c8d77a
- joins: tileable; both rows repeat every 6.4 px so ends match.
- face: none.
- notes: pale lilac blooms are cream-safe, keep the dark row clearly darker than the pale row. A few 1 px #54447f stem ticks allowed between puffs.
