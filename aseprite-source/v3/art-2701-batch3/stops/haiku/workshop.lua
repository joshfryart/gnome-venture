-- workshop.lua : "Tinkers' workshop" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "workshop", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- the barn: plaster walls, deep red roof, a wide sliding door
F.building{ x0 = 296, x1 = 436, yb = 170, wh = 42, rh = 24, wall = L.plaster, roof = L.roof2 }
F.door(340, 132, 380, 170, L.timber, false)
vline(360, 134, 168, L.timber.deep)
F.window(308, 140, 314, 147, L.timber)
F.window(414, 140, 420, 147, L.timber)

-- a forge out front: stone box, glowing mouth, chimney
local box = rect(120, 150, 154, 172)
local chimney = rect(132, 126, 138, 150)
rimOf(F.union(box, chimney), L.stone)
part(box, L.stone, { sep = true }) part(chimney, L.stone, { nopop = true })
F.courses(F.union(box, chimney), 126, 5, 7, L.stone)
c:fillMask(rect(128, 158, 146, 166), L.glow.base)
hline(128, 146, 158, L.glow.hi)
hline(128, 146, 166, L.glow.shade)
for y = 124, 128 do px(135, y, L.stone.hi) end -- smoke puff
F.crown(134, 120, 4, 3, L.stone, 52)

-- workbench with tools and a half-built contraption
local bench = rect(170, 186, 216, 192)
rimOf(bench, L.timber) part(bench, L.timber, { nopop = true })
vline(174, 192, 200, L.timber.deep) vline(212, 192, 200, L.timber.deep)
part(c:line({ { 184, 186 }, { 194, 172 }, { 200, 170 } }, 1), L.timber, { nopop = true, noshade = true })
local gear = c:ellipse(196, 180, 4, 4)
rimOf(gear, L.accent) part(gear, L.accent, { nopop = true })

-- a stack of planks and a wheelbarrow on the left
for k = 0, 3 do
  local plank = rect(60, 200 - k * 4, 104, 203 - k * 4)
  rimOf(plank, L.board) part(plank, L.board, { sep = true })
end
local tray = c:poly{ { 116, 196 }, { 146, 196 }, { 140, 206 }, { 120, 206 } }
rimOf(tray, L.timber) part(tray, L.board, { sep = true })
local wheel = c:ellipse(132, 210, 4, 4)
rimOf(wheel, L.timber) part(wheel, L.timber, { nopop = true })

-- gear sign and a tree
F.sign(452, 142, 22, 12)
F.tree(42, 136, 26, 9)
F.tree(262, 124, 16, 10, true)

F.finish()
