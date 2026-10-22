# stops/stamp-ferry
- canvas: 64x64, mode icon, 1x (map stamp; also read at 32).
- subject: A round passport-style stamp for the ferry stop: concentric rings around a small sailing ferry on waves.
- must-read-at-16px: round ring with a triangular sail over a boat hull.
- distinct: ring stamp with a dotted outer ring, holding a single triangle sail on a mast over a trapezoid hull and a wavy line; single blue ink on cream.
- parts (back to front):
  1. stamp disc: circle (32,32) r29, cream #f1ece0
  2. outer dotted ring: r28, 2x2 dots every 4 px, ink #2f6290 (water shade)
  3. main ring: 3px ring r24..26, ink #2f6290
  4. inner ring: 1px ring r22, ink #3f8fb0
  5. hull: trapezoid top (22,37)..(43,37), bottom (26,44)..(39,44), ink #2f6290 tinted #c8ecdc
  6. mast: 3px line (32,37)->(32,16), ink
  7. sails: main tri (32,18),(41,34),(32,34) tinted #8fcbd8 with ink outline; jib tri (32,22),(25,34),(32,34) outline only
  8. waves: 3px wavy line y47..50 x16..47, ink #3f8fb0
- joins: none.
- face: none.
- notes: icon chunky, parts min 3 px; no text. One water-blue ink family. Cream-safe, umber outline outside.
