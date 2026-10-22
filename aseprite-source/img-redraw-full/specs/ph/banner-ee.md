# ph/banner-ee
- canvas: 240x80, mode scene (banner, full-bleed, no halo, no text); draw at half-size 120x40, write 2x.
- subject: Wide banner of the Birchbramble steppe: pale sky over rolling green hills, golden grass plain and a row of white birch trees with rounded green crowns.
- must-read-at-16px: pale blue top, green hill band, gold steppe band, white trunks.
- distinct: seven birch trees at uneven heights (three tall, two medium, two short), with dark bark ticks; dashed golden grass tufts along the bottom; two flat white clouds.
- parts (final 240x80 px):
  1. sky: full rect #a9d6ea
  2. far hills: wavy ridge y 36..44 across, #7ab55c, fills to bottom
  3. golden steppe: from y 53 down, #f5cf6a
  4. near moss strip: wavy edge y 53..58, #b0bc66 (moss a4b86a), fills to bottom
  5. clouds: ellipses (60,13) rx16 ry4 and (180,19) rx12 ry3, #f4f0e0
  6. birch trunks: 3px wide #f4f0e0 at x 18, 47, 80, 119, 150, 186, 220; heights 27/22/18/27/22/18/27 px, three #2a1a10 dash ticks each
  7. crowns: ellipses rx6 ry7 #b0bc66 atop each trunk, 1px gloss dot upper left
  8. grass tufts: small gold-brown "v" ticks #b07a10 every 31 px at y 71..76
- joins: thread-gold hem stitch along top and bottom edges.
- face: none.
- notes: full-bleed; selective umber 2px frame inset 1px at 50% allowed. Trunks pale-safe: umber outline. Keep trees evenly spread, not cloned heights.
