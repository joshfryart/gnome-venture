-- picket-fence-corner (final, Opus single pass): a corner seen from the front edge: a square raw-wood post turned 45
-- degrees with two picket runs (three slim painted pickets each) receding up-left and up-right in a V. Material: per-pixel
-- pillow light, lit left faces and violet-shaded right faces, pale end grain with a growth ring on the post top, a bright
-- arris down the post's front edge, grain streaks, a paint chip, rails with end grain, contact shadow behind pickets,
-- AO at the feet, moss tufts and a ground shadow.
-- quirk: a tiny spider dangles on a silk thread from the right-hand rail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_4.lua")
local c = A.new("picket-fence-corner")
c:groundShadow(32, 51, 24, 3)
-- rails (behind pickets)
A.rail(c, 9, 29, 28, 38, 0.5, { ends = { "l" } })
A.rail(c, 9, 29, 28, 46, 0.5, { ends = { "l" } })
A.rail(c, 35, 55, 36, 38, -0.5, { ends = { "r" }, bias = -1 })
A.rail(c, 35, 55, 36, 46, -0.5, { ends = { "r" }, bias = -1 })
local HGT = 22
A.picket(c, 12, 44, HGT, 0.5, { grain = 1 })
A.picket(c, 52, 44, HGT, -0.5, { bias = -1, grain = -1 })
A.picket(c, 18, 47, HGT, 0.5, { grain = -1, chip = { 0, -12 } })
A.picket(c, 46, 47, HGT, -0.5, { bias = -1, grain = 1 })
A.picket(c, 24, 50, HGT, 0.5, { grain = 1 })
A.picket(c, 40, 50, HGT, -0.5, { bias = -1, grain = -1 })
for _, p in ipairs{ { 12, 44, .5 }, { 18, 47, .5 }, { 24, 50, .5 }, { 52, 44, -.5 }, { 46, 47, -.5 }, { 40, 50, -.5 } } do
  local y1 = 38 + math.floor(p[3] * (p[1] - (p[3] > 0 and 28 or 36))) + 1
  local y2 = y1 + 8
  A.nail(c, p[1], y1) A.nail(c, p[1], y2)
end
A.post(c, 32, 55, 4, 31)
-- spider on a thread between the right-hand pickets
for y = 32, 37 do c:put(49, y, "#d9d2e8") end
A.map(c, { "k.k", ".K.", "kgk", ".k." }, 48, 38, { k = A.INK, K = A.INK, g = "#9a8cb0" })
A.tuft(c, 21, 51) A.tuft(c, 42, 51) A.tuft(c, 27, 55) A.tuft(c, 10, 45)
A.save(c, "picket-fence-corner")
