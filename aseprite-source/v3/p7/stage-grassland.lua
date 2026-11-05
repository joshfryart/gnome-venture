-- stage-grassland v3: clear-day base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-grassland" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local G = { hi = "#d8f880", base = "#9ce048", shade = "#58b040", deep = "#2a7a44" }
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local BARK = { hi = "#c89060", base = "#94603c", shade = "#6e4234", deep = "#442a2c" }
local WOOL = { hi = "#fffaf0", base = "#f0ead8", shade = "#c8c0cc", deep = "#8e869c" }
local EARTH = { hi = "#f0d8a0", base = "#d8b072", shade = "#b48850", deep = "#8a6040" }

-- sky: plain gradient, small sun
GX.bands(c, 0, 150, { "#5aa8e8", "#74b8ee", "#8ecaf2", "#aadcf6", "#c8ecf6", "#e6f6ee" }, 3, .05)
local sg = mk(); E(sg, 388, 32, 15, 15); c:fillMask(sg, GX.mix("#8ecaf2", "#fff4c0", .35))
local sun = mk(); E(sun, 388, 32, 9, 9); sun = GX.rough(sun, 5, 1)
GX.lit(c, sun, R6({ hi = "#fffbe0", base = "#fff0a0", shade = "#ffe070", deep = "#f0c050" }), { R = 8, tex = .1, seed = 3, ink = false })

-- far hills with earthy patches
local function far(x) return 118 + floor(9 * sin(x / 61 + 1) + 4 * sin(x / 23) + 3 * sin(x / 9)) end
GX.ground(c, far, { hi = "#c0e0b8", base = "#a4d0a8", shade = "#88b8a0", deep = "#6c9898" }, 5, { top = .72, fall = .22, tex = .26, sc = 9 })
for x = 0, 479 do for y = far(x), far(x) + 26 do   -- tilled strips on the far slopes
  if GX.vn(x * .5, y, 14, 17) > .66 and (x + y) % 5 < 2 then c:px(x, y, "#d4c898") end
end end
-- mid hill
local function mid(x) return 138 + floor(6 * sin(x / 47 + 3) + 2 * sin(x / 13)) end
GX.ground(c, mid, { hi = "#d8f49c", base = "#b0e070", shade = "#88c860", deep = "#62a860" }, 6, { top = .8, fall = .3, tex = .3 })
-- rail fence on the right hill
for fx = 330, 440, 18 do c:fillMask(c:rect(fx, mid(fx) - 9, fx + 1, mid(fx) + 1), "#8a6a58") end
for fx = 330, 441 do c:px(fx, mid(fx) - 7, "#a8826a"); c:px(fx, mid(fx) - 4, "#a8826a") end
-- distant tree clumps
for _, t in ipairs{ { 30, 134 }, { 62, 138 }, { 396, 136 }, { 430, 132 }, { 456, 138 } } do
  local m = mk(); E(m, t[1], t[2], 11, 8); m = GX.rough(m, t[1], 1)
  GX.lit(c, m, R6({ hi = "#8cd070", base = "#5aa860", shade = "#3e8858", deep = "#2a6a50" }), { R = 6, tex = .5, sc = 3, seed = t[1], ink = false })
end

-- front meadow
local function mead(x) return 158 + floor(3 * sin(x / 29 + 2) + 1.5 * sin(x / 9)) end
GX.ground(c, mead, G, 7, { top = .88, fall = .6, tex = .3, sc = 8 })
for x = 0, 479 do for y = mead(x) - 2, mead(x) + 1 do   -- grassy fringe
  if H(x, y, 2) > .45 then c:px(x, y, G.hi) end
end end

-- worn path to the oak
local function pc(y) return 240 + floor(6 * sin(y / 22)) end
local function phw(y) return 4 + (y - 172) * .42 end
do
  local m = mk()
  for y = 172, 269 do for x = floor(pc(y) - phw(y) - 3), floor(pc(y) + phw(y) + 3) do
    local e = abs(x - pc(y)) - phw(y) + (GX.vn(x, y, 5, 4) - .5) * 5
    if e < 0 then m:set(x, y) end
  end end
  GX.lit(c, m, R6(EARTH), { R = 5, tex = .5, sc = 3, seed = 8, ink = false, amb = .5 })
  for i = 0, 18 do local y = 180 + floor(H(i, 1, 4) * 88); local x = pc(y) + floor((H(i, 2, 4) - .5) * phw(y) * 1.4)
    if m:has(x, y) then c:px(x, y, EARTH.hi); c:px(x + 1, y, EARTH.hi); c:px(x, y + 1, EARTH.deep) end end
end

-- oak (hero, centre)
local sh = mk(); E(sh, 244, 176, 52, 5); sh = GX.rough(sh, 9, 1); c:fillMask(sh, GX.mix(G.shade, G.deep, .3))
GX.trunk(c, 229, 252, 100, 176, BARK, 21, { moss = GRN2 })
local CAN = { GRN1, GRN2, { hi = "#d8f070", base = "#8cc850", shade = "#4e9c48", deep = "#2a6a44" } }
GX.foliage(c, 240, 78, 58, 30, CAN[2], 301)
GX.foliage(c, 238, 38, 36, 18, CAN[1], 302)
GX.foliage(c, 214, 60, 28, 14, CAN[3], 303)
GX.foliage(c, 270, 92, 30, 14, CAN[2], 304)
GX.foliage(c, 206, 96, 24, 11, CAN[1], 305)

-- bushes with berries
local function bush(cx, cy, rw, rh, seed, berries)
  local sb = mk(); E(sb, cx + 4, cy + rh - 1, rw + 5, 4); c:fillMask(GX.rough(sb, seed, 1), GX.mix(G.shade, G.deep, .3))
  local m = GX.foliage(c, cx, cy, rw, rh, GRN1, seed)
  if berries then for i = 1, 6 do
    local bx, by = cx - rw * .6 + floor(H(i, seed, 11) * rw * 1.2), cy - rh * .3 + floor(H(i, seed, 12) * rh * .9)
    if m:has(bx, by) and m:has(bx + 1, by + 1) then c:fillMask(c:rect(bx, by, bx + 1, by + 1), "#e8506c"); c:px(bx, by, "#ffa0b0") end
  end end
end
bush(172, 160, 22, 11, 401, true)
bush(318, 162, 20, 10, 402, false)

-- sheep
local function sheep(x, y, s, f)
  local b = mk(); E(b, x, y, 8, 5); E(b, x - 3 * f, y - 2, 5, 4); E(b, x + 4 * f, y - 1, 5, 4); b = GX.rough(b, x, 1)
  for _, lx in ipairs{ -4, 4 } do c:fillMask(c:rect(x + lx, y + 4, x + lx, y + 8), INK) end
  GX.lit(c, b, R6(WOOL), { R = 5, tex = .5, sc = 2, seed = x, rimlight = true })
  local hd = mk(); E(hd, x + 9 * f, y - 1, 3, 3)
  GX.lit(c, hd, R6({ hi = "#8a7078", base = "#5c4452", shade = "#44303e", deep = "#2e202c" }), { R = 3, tex = 0, seed = x })
  c:px(x + 10 * f, y - 2, WOOL.hi)
end
sheep(98, 152, 1, 1); sheep(352, 148, 1, 1); sheep(398, 153, 1, -1)

-- soft lighter patches (upper meadow only)
for i = 0, 8 do
  local x, y = 20 + floor(H(i, 51, 1) * 440), 168 + floor(H(i, 53, 1) * 20)
  local m = mk(); E(m, x, y, 12 + i % 4 * 3, 3); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(G.hi, "#ffffd0", .25))
end

-- calm walkable foreground: sparse tufts, small flowers, pebbles
local FL = { "#ff9fc0", "#fff4d6", "#ffd470", "#c9b2f0", "#ff8a5c" }
for i = 0, 38 do
  local x, y = 6 + floor(H(i, 61, 1) * 468), 176 + floor(H(i, 63, 1) * 92)
  if abs(x - pc(y)) > phw(y) + 6 then GX.tuft(c, x, y, y > 214 and { hi = G.base, base = G.shade, shade = G.deep } or G) end
end
for i = 0, 16 do
  local x, y = 10 + floor(H(i, 41, 1) * 460), 180 + floor(H(i, 43, 1) * 84)
  if abs(x - pc(y)) > phw(y) + 5 then GX.flower(c, x, y, FL[1 + i % 5]) end
end
for i = 0, 8 do   -- pebbles
  local x, y = 8 + floor(H(i, 71, 1) * 464), 200 + floor(H(i, 72, 1) * 66)
  local m = mk(); E(m, x, y, 1 + i % 2, 1)
  GX.lit(c, m, R6({ hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }), { R = 2, tex = .1, seed = i, rimlight = true })
end
-- quirk: a ladybird on a clover leaf by the path
do local x, y = 190, 214
  c:fillMask(c:rect(x - 3, y, x + 3, y + 1), GRN1.base); c:px(x, y - 1, GRN1.hi)
  c:fillMask(c:rect(x - 1, y - 2, x + 1, y - 1), "#e8503c"); c:px(x, y - 2, INK); c:px(x - 1, y - 1, INK)
end

c:save{ aseprite = d.."/out/stage-grassland.aseprite", png = d.."/out/stage-grassland.png", scale = 1 }
