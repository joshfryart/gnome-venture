-- shrine.lua : "Moss shrine" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- the shrine hall at the end of the road: plaster walls, red-tiled roof
F.building{ x0 = 204, x1 = 276, yb = 126, wh = 26, rh = 18, wall = L.plaster, roof = L.roof2 }
F.door(232, 102, 246, 126, L.timber, true)
F.window(212, 110, 218, 117, L.timber)
F.window(262, 110, 268, 117, L.timber)

-- stone steps leading up to the torii
for k = 0, 2 do
  local y0 = 184 + k * 6
  local st = rect(190 + k * 4, y0, 290 - k * 4, y0 + 5)
  part(st, L.stone, { sep = true })
  F.speckle(st, L.leaf, .05, 40 + k)
end

-- torii gate on the road: two red posts and two beams
local posts = F.union(rect(212, 146, 218, 190), rect(258, 146, 264, 190))
rimOf(posts, L.roof2)
part(posts, L.roof2, { sep = true })
local beamTop = rect(200, 138, 276, 143)
local beamTie = rect(214, 156, 262, 159)
rimOf(F.union(beamTop, beamTie), L.roof2)
part(beamTop, L.roof2, { band = 2 })
part(beamTie, L.roof2, { nopop = true })
hline(200, 276, 137, L.roof2.hi)

-- stone lanterns (toro) either side of the steps
for _, x in ipairs({ 176, 304 }) do
  local base = rect(x - 3, 178, x + 3, 184)
  local column = rect(x - 1, 166, x + 1, 178)
  local cap = rect(x - 5, 160, x + 5, 166)
  local lamp = rect(x - 2, 152, x + 2, 159)
  local roof = rect(x - 7, 147, x + 7, 152)
  rimOf(F.union(base, column, cap, lamp, roof), L.stone)
  part(base, L.stone) part(column, L.stone, { nopop = true }) part(cap, L.stone) part(roof, L.stone)
  c:fillMask(lamp, L.glow.base)
  px(x - 1, 154, L.glow.hi)
  F.speckle(F.union(base, cap), L.leaf, .10, 60 + x)
end

-- moss and trees on the banks
F.tree(40, 150, 28, 5)
F.tree(440, 150, 30, 6)
F.tree(118, 128, 22, 7, true)
F.tree(360, 124, 24, 8, true)

F.finish()
