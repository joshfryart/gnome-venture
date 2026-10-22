# ph/flame-of-the-forest-seed
- canvas: 64x64, mode sticker, 1x.
- subject: A seed item for flame-of-the-forest (a fiery-orange tree): a small tin box with a hinged lid, holding golden seeds, with a sprout label; cheerful and compact.
- must-read-at-16px: a squat metal box with a lid band across the top, and one orange-gold seed disc on its front.
- distinct: tin box with hinged lid (back hinge nubs, clasp button), the only seed here in a metal container.
- parts:
  1. ground shadow: ellipse (32,56) rx 16 ry 3, #6a4528 flat (solid=false)
  2. box body: rrect x 13..51, y 24..54 (r 3), base #b9b4b9 (tin, run GV.ramp, stone family)
  3. lid: rrect x 11..53, y 14..26 (r 3), base #cfc9cf lighter tin, overlaps body top
  4. hinge: two 3x3 nubs at back top corners (x 16..18 and 45..47, y 12..14), #968f96
  5. front label: rrect x 20..44, y 30..49 (r 3), cream #f4f0e0 with 1px #dcb06a border
  6. seed disc on label: circle (32,41) r 6, #dcb06a (wood/gold ramp), crescent #a5663a
  7. sprout: stem 2px (32,33..35) #2e5a2c plus leaf bean 5x3 at (35,32) #58a03e
- joins: seam along lid/body line y 26, x 14..50 (thread gold 2 on/1 off); button 4x4 at (30,24) as clasp.
- face: none.
- notes: tin is cool grey so the orange-gold seed pops; cream label cream-safe with umber outline; gloss on lid upper left.
