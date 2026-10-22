# ico/ico-bat
- canvas: 64x64, mode icon, 1x.
- subject: Creature icon for an Echo Bat: a small brown bat seen from the front with wide spread wings, pointed ears and echo arcs beside its head; spooky but cute.
- must-read-at-16px: two wide scalloped wings spread left and right of a small round dark head with pointed ears.
- distinct: wings spread nearly the full width with scalloped lower edges, plus two small violet sound arcs beside the head.
- parts (back to front):
  1. left wing: polygon (4,27),(32,35),(32,43), scallops along the lower edge at (10,37),(16,35),(20,39), base #6e5646 (brown)
  2. right wing: mirror, polygon (60,27),(32,35),(32,43), scallops, base #6e5646
  3. wing ribs: four 1px lines #4b3a2f from (32,35) to (18,31),(22,39),(46,31),(42,39)
  4. body: ellipse (32,37) rx6 ry9, base #4b3a2f
  5. head: circle (32,29) r5.5, base #4b3a2f
  6. ears: triangles (28,25)->(26,18)->(31,22) and mirror, #4b3a2f
  7. echo arcs: 2px arcs at x 24 and x 40, y 21..29, #a894dc
- joins: none. Optional belly V (30,33)->(32,36)->(34,33) in #f1e9e4.
- face: locked small eyes (head under 20px: 3x3 disc, 2x2 pupil) at (28,28) and (33,28).
- notes: dark body; keep the rim light so body separates from wings. Wing tips pointed; parts min 3px.
