# ico/ico-castle
- canvas: 64x64, mode icon, 1x.
- subject: A stone castle seen from the front, two tall side towers with battlements around a lower cream keep with an arched wooden door; sturdy and friendly.
- must-read-at-16px: two tall towers with notched tops flanking a shorter middle block with a dark arch door.
- distinct: twin tall towers each topped with two merlons, joined by a low cream keep with a wide round-top door.
- parts:
  1. left tower: rect x 9..20, y 17..55, base #8b8f96 (stone)
  2. right tower: rect x 44..55, y 17..55, base #8b8f96
  3. keep: rect x 19..45, y 28..55, base #f2e4c0 (pale, cream-safe) with stone tint #c9c5bc
  4. merlons: four blocks 6x10 at (7,9),(17,9),(42,9),(51,9), base #8b8f96
  5. door: rect x 26..38, y 42..55 with round top r6 centred (32,42), base #6a4528 (wood)
- joins: mortar seam optional at tower tops y 17; none required.
- face: none.
- notes: parts min 3px, merlon gaps at least 3px so notches read at 16 px. Stone: no edge stitch. Keep pale: umber outline.
