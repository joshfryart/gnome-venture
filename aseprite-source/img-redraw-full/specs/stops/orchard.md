# stops/orchard
- canvas: 48x48, mode icon, 1x (map stop).
- subject: Map-stop symbol for an orchard: a round leafy fruit tree crown on a short trunk with three red fruits.
- must-read-at-16px: a big round green crown over a short trunk with a base bar.
- distinct: round crown (not conical or pine) with three separate fruit dots in a triangle and a small flat foot bar at the base.
- parts:
  1. crown: circle (24,19) r12, base #7ab55c (moss base)
  2. trunk: rect x22..26, y30..42, base #a8582f (wood shade), with branch forks (24,31)->(19,27) and (24,33)->(29,29), 2px
  3. foot bar: rect x19..29, y41..43, #8a4f2a
  4. fruits: circles r2.5 at (19,16), (28,14), (26,23), base #dd3a2a (red)
- joins: none.
- face: none.
- notes: icon palette; keep halo small (2px) because of the 48 canvas. Crown gloss #c8d77a upper-left. Trunk min 3px at final.
