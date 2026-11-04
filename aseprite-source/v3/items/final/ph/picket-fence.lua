-- picket-fence (final, Opus single pass): a front-on section of five slim painted pickets with a scalloped top line
-- (tall ends dipping to the middle), nailed to two raw-wood rails behind. Material: per-pixel pillow light on 6-tone
-- cream paint (cool violet shade), broken grain streaks, a paint chip showing bare wood, pale end grain on the rail
-- ends, metal nail heads, contact shadow where pickets cross the rails, AO at the feet, moss tufts and ground shadow.
-- quirk: a snail is slowly climbing the middle picket, leaving a shiny trail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_4.lua")
local c = A.new("picket-fence")
c:groundShadow(30, 54, 25, 2)
A.rail(c, 6, 54, 6, 31, 0, { ends = { "l", "r" } })
A.rail(c, 6, 54, 6, 43, 0, { ends = { "l", "r" } })
local H = { 31, 28, 26, 28, 31 }
for i = 1, 5 do
  local cx = 3 + i * 9
  A.picket(c, cx, 53, H[i], 0, { grain = (i % 2 == 0) and -1 or 1, chip = (i == 4) and { 1, -9 } or nil })
  A.nail(c, cx, 33) A.nail(c, cx, 45)
end
-- snail on the middle picket (head up), shiny trail below
A.map(c, {
  "k.k....",
  "b.b....",
  "bbb....",
  "bdSSS..",
  "bShsSS.",
  "bSsHsSs",
  "bSssSSs",
  "bdSSSs.",
  ".bdd...",
}, 28, 34, { k = A.INK, b = "#e2c2a6", d = "#a97f6c", S = "#e88a34", h = "#ffd27a", H = "#fff1cf", s = "#9b4a2c" })
c:put(29, 45, A.CREAM) c:put(29, 47, A.CREAM) c:put(28, 46, "#e8f0f4")
A.tuft(c, 9, 54) A.tuft(c, 25, 54) A.tuft(c, 44, 54)
A.save(c, "picket-fence")
