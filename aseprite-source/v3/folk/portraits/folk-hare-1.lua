-- folk-hare-1 portrait (folk F1_4) variant: 1
-- Hare rest-stop villager. Tells: long ears with ink-dark tips + pink inner, pale eye ring, split Y lip + buck teeth, long hind feet, cotton tail.
-- v1 gardener: sandy hare, straw hat (ears through slots) + clover sprig, sage overalls, trowel.
-- v2 traveller: grey-fawn mountain hare, one ear folded, rust knit scarf, pack + bedroll, brass lantern.
-- v3 cook: russet hare, ears flung wide, red polka kerchief, plum smock + cream apron, copper ladle.
local V = 1
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-hare-" .. V
local FUR = ({
  { hi = "#ecc892", base = "#c99a62", shade = "#946a58", deep = "#5e4050" },
  { hi = "#dacbb6", base = "#a8988a", shade = "#76687e", deep = "#4a405a" },
  { hi = "#eea464", base = "#c26c3c", shade = "#8a4646", deep = "#58303e" },
})[V]
local CREAM = { hi = "#fcf2da", base = "#efdcb8", shade = "#c6aca2", deep = "#8e7688" }
local PINK = { hi = "#f8c4bc", base = "#e2929a", shade = "#b2667a", deep = "#7c425a" }
local TIP = { hi = "#6c5260", base = "#4e3a48", shade = "#3c2c3a", deep = "#33232f" }
local STRAW = { hi = "#f8e08a", base = "#e0b858", shade = "#ae8044", deep = "#76503e" }
local SAGE = { hi = "#a8cc84", base = "#6e9e5a", shade = "#4a6e54", deep = "#2f4448" }
local METAL = { hi = "#e6e4ec", base = "#a8a8bc", shade = "#6e6c88", deep = "#46445e" }
local WOOD = { hi = "#d49a62", base = "#a06a3e", shade = "#6e4436", deep = "#4a2c30" }
local TEAL = { hi = "#7cc4bc", base = "#3e8c90", shade = "#2c5e72", deep = "#223c54" }
local RUST = { hi = "#f09a5c", base = "#d0603a", shade = "#9a3c3c", deep = "#62283a" }
local LEATHER = { hi = "#c89068", base = "#8e5e44", shade = "#62403e", deep = "#40283a" }
local OAT = { hi = "#efe0b4", base = "#cdb88a", shade = "#9a8270", deep = "#64506a" }
local BRASS = { hi = "#fae79a", base = "#e0b040", shade = "#a87232", deep = "#6c4434" }
local GLOW = { hi = "#fff6c0", base = "#ffe07a", shade = "#f4b04a", deep = "#c8783a" }
local PLUM = { hi = "#c08ac4", base = "#8c5aa0", shade = "#5e3c7c", deep = "#3c2856" }
local KERCH = { hi = "#f08080", base = "#d04850", shade = "#9a2e48", deep = "#621e3a" }
local COPPER = { hi = "#f6b48a", base = "#d27848", shade = "#9a4a3c", deep = "#5e2c34" }
local function F(c, m, r, band, pop)
  c:part(m, r, { band = band or 2, nopop = true })
  if pop then for _, q in ipairs(pop) do if m:has(q[1], q[2]) then c:put(q[1], q[2], r.hi, r) end end end
  return m
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function seg(ax, ay, bx, by, w)
  local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2) / 2
  return oval((ax + bx) / 2, (ay + by) / 2, len, w, math.deg(math.atan(by - ay, bx - ax)))
end
-- hare ear: long fur blade, pink inner, ink-dark tip; optional knee K = folded-over ear
local function ear(c, B, T, w, K)
  local m, inner
  if K then
    m = seg(B[1], B[2], K[1], K[2], w) m:add(seg(K[1], K[2], T[1], T[2], w * 0.9))
    inner = seg(B[1] + (K[1] - B[1]) * .15, B[2] + (K[2] - B[2]) * .15, K[1], K[2], w * 0.45)
  else
    m = seg(B[1], B[2], T[1], T[2], w)
    local L = function(f) return B[1] + (T[1] - B[1]) * f, B[2] + (T[2] - B[2]) * f end
    local ix, iy = L(0.12) local jx, jy = L(0.76)
    inner = seg(ix, iy, jx, jy, w * 0.45)
  end
  F(c, m, FUR, 2)
  F(c, inner:clip(m:shrink(1)), PINK, 1)
  F(c, HP.ellipse(T[1], T[2], w * 1.5, w * 1.5):clip(m), TIP, 1)
  return m
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local CX, hcy = 39.5, 56
local BG = ({ { base = "#b4d48e", shade = "#86ae72", deep = "#5c8460" }, { base = "#a4d0cc", shade = "#72a4ae", deep = "#50788e" },
  { base = "#d8b6d6", shade = "#ad88b8", deep = "#7e6098" } })[V]
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
if V == 2 then
  F(c, c:rrect(8, 70, 71, 80, 4), OAT, 2, { { 10, 72 }, { 11, 71 } })
  for _, x in ipairs{ 13, 14, 65, 66 } do for y = 70, 80 do if c:get(x, y) then c:put(x, y, RUST.base) end end end
end
F(c, c:rect(31, 66, 48, 80), FUR, 2)
local body = c:ellipse(CX, 102, 29, 25):clip(c:rect(0, 0, 79, 99))
F(c, body, ({ FUR, TEAL, PLUM })[V], 3, { { 16, 86 }, { 17, 84 }, { 19, 82 } })
if V == 1 then
  F(c, c:ellipse(CX, 96, 9, 16):clip(body), CREAM, 2)
  F(c, c:rrect(27, 87, 52, 99, 2), SAGE, 2, { { 28, 88 }, { 28, 89 } })
  F(c, c:line({ { 29, 88 }, { 25, 77 } }, 3), SAGE, 1) F(c, c:line({ { 50, 88 }, { 54, 77 } }, 3), SAGE, 1)
  F(c, c:rect(34, 91, 45, 97), SAGE, 1)
  F(c, c:rect(28, 88, 29, 89), BRASS, 1) F(c, c:rect(50, 88, 51, 89), BRASS, 1)
elseif V == 2 then
  F(c, c:line({ { 26, 77 }, { 23, 99 } }, 4), LEATHER, 1) F(c, c:line({ { 53, 77 }, { 56, 99 } }, 4), LEATHER, 1)
  F(c, c:rect(22, 89, 26, 91), BRASS, 1)
  F(c, c:rect(39, 86, 40, 87), BRASS, 1) F(c, c:rect(39, 93, 40, 94), BRASS, 1)
else
  F(c, c:rrect(28, 82, 51, 99, 3), CREAM, 2, { { 29, 83 }, { 29, 84 } })
  F(c, c:line({ { 30, 83 }, { 31, 74 } }, 2), CREAM, 1) F(c, c:line({ { 49, 83 }, { 48, 74 } }, 2), CREAM, 1)
  F(c, c:rect(34, 90, 45, 96), CREAM, 1)
  for _, q in ipairs{ { 16, 88 }, { 18, 91 }, { 63, 93 }, { 33, 86 } } do c:put(q[1], q[2], CREAM.hi) end
end
if V == 2 then
  ear(c, { 32, 42 }, { 26, 6 }, 5)
  ear(c, { 47, 42 }, { 63, 27 }, 5, { 51, 18 })
elseif V == 3 then
  ear(c, { 31, 42 }, { 15, 9 }, 5)
  ear(c, { 48, 42 }, { 64, 9 }, 5)
end
local head = c:ellipse(CX, hcy, 20, 16.5)
for _, sg in ipairs{ -1, 1 } do head:add(c:ellipse(CX + sg * 19, hcy + 6, 3, 3)) head:add(c:ellipse(CX + sg * 17, hcy + 10, 3, 2.5)) end
F(c, head, FUR, 3, { { 27, 43 }, { 28, 43 }, { 26, 44 }, { 25, 45 } })
for _, q in ipairs{ { 33, 44 }, { 34, 43 }, { 44, 44 }, { 21, 52 }, { 22, 51 } } do if c:get(q[1], q[2]) == FUR.base then c:put(q[1], q[2], FUR.hi) end end
for _, q in ipairs{ { 54, 60 }, { 55, 59 }, { 50, 66 }, { 57, 64 } } do if c:get(q[1], q[2]) == FUR.base then c:put(q[1], q[2], FUR.shade) end end
local muz = c:ellipse(CX - 4, hcy + 8, 5, 4):add(c:ellipse(CX + 4, hcy + 8, 5, 4)):add(c:ellipse(CX, hcy + 11, 4, 3))
F(c, muz, CREAM, 1, { { 32, 61 }, { 33, 61 } })
c:fillMask(c:ellipse(29.5, 53.5, 4.5, 4.5), CREAM.base) c:fillMask(c:ellipse(50.5, 53.5, 4.5, 4.5), CREAM.base)
c:eyeLocked(27, 51) c:eyeLocked(48, 51)
for x = 37, 42 do c:put(x, 59, PINK.base) end for x = 38, 41 do c:put(x, 60, PINK.base) end
c:put(39, 61, PINK.shade) c:put(40, 61, PINK.shade) c:put(37, 59, PINK.hi) c:put(38, 59, PINK.hi) c:put(41, 60, PINK.shade)
for _, q in ipairs{ { 39, 62 }, { 40, 62 }, { 37, 63 }, { 38, 63 }, { 41, 63 }, { 42, 63 }, { 36, 64 }, { 38, 64 }, { 41, 64 }, { 43, 64 }, { 39, 65 }, { 40, 65 } } do c:put(q[1], q[2], P.ink) end
for _, q in ipairs{ { 39, 63 }, { 40, 63 }, { 39, 64 }, { 40, 64 } } do c:put(q[1], q[2], CREAM.hi) end
for _, q in ipairs{ { 32, 65 }, { 33, 67 }, { 46, 65 }, { 45, 67 } } do c:put(q[1], q[2], CREAM.deep) end
for _, l in ipairs{ { { 29, 64 }, { 23, 62 } }, { { 29, 67 }, { 23, 68 } }, { { 50, 64 }, { 56, 62 } }, { { 50, 67 }, { 56, 68 } } } do
  c:line(l, 1):each(function(x, y) if c:get(x, y) == FUR.base or c:get(x, y) == FUR.shade or c:get(x, y) == FUR.hi then c:put(x, y, CREAM.hi) end end)
end
for _, q in ipairs{ { 23, 59 }, { 24, 59 }, { 25, 59 }, { 23, 60 }, { 24, 60 }, { 54, 59 }, { 55, 59 }, { 56, 59 }, { 55, 60 }, { 56, 60 } } do c:put(q[1], q[2], PINK.base) end
if V == 1 then
  local brim, crown = c:ellipse(CX, 41, 25, 4.5), c:rrect(27, 26, 52, 38, 5)
  F(c, brim, STRAW, 2, { { 17, 40 }, { 18, 39 } })
  brim:each(function(x, y) if not brim:has(x, y + 1) then c:put(x, y, STRAW.deep) end end)
  F(c, crown, STRAW, 2, { { 29, 28 }, { 30, 27 }, { 29, 29 } })
  brim:copy():add(crown):each(function(x, y) if c:get(x, y) == STRAW.base and (x + 2 * y) % 4 == 0 then c:put(x, y, STRAW.shade) end end)
  crown:each(function(x, y) if y >= 34 and y <= 36 then c:put(x, y, y == 34 and SAGE.hi or (y == 35 and SAGE.base or SAGE.shade)) end end)
  ear(c, { 34, 31 }, { 28, 3 }, 5) ear(c, { 45, 31 }, { 52, 4 }, 5)
  for x = 31, 37 do c:put(x, 31, STRAW.deep) end for x = 42, 48 do c:put(x, 31, STRAW.deep) end
  -- clover sprig in the band
  F(c, c:ellipse(51, 31, 2, 2), SAGE, 1, { { 50, 30 } }) F(c, c:ellipse(54, 32, 2, 2), SAGE, 1) F(c, c:ellipse(52, 34, 1.6, 1.6), SAGE, 1)
  c:put(53, 33, PINK.base)
  -- trowel held up at the right
  F(c, c:rect(62, 84, 64, 95), WOOD, 1, { { 62, 85 } })
  F(c, c:rect(62, 82, 64, 83), BRASS, 1)
  F(c, c:poly{ { 59, 82 }, { 67, 82 }, { 66, 74 }, { 63, 68 }, { 60, 74 } }, METAL, 2, { { 61, 74 }, { 61, 75 }, { 62, 72 } })
  for y = 71, 81 do c:put(63, y, METAL.shade) end c:put(65, 79, WOOD.shade) c:put(64, 80, WOOD.base)
  F(c, c:ellipse(63, 88, 4, 3), FUR, 1, { { 61, 87 } })
elseif V == 2 then
  local sc = c:rrect(20, 70, 59, 78, 3)
  F(c, sc, RUST, 2, { { 22, 71 }, { 23, 71 } })
  sc:each(function(x, y) if x % 3 == 0 and c:get(x, y) == RUST.base then c:put(x, y, RUST.shade) end end)
  F(c, c:rrect(24, 74, 31, 94, 2), RUST, 2, { { 25, 76 } })
  for y = 76, 92, 3 do for x = 25, 30 do if c:get(x, y) == RUST.base then c:put(x, y, RUST.shade) end end end
  for x = 24, 31, 2 do c:put(x, 95, RUST.base) c:put(x, 96, RUST.shade) end
  -- brass lantern held up at the left
  c:line({ { 13, 75 }, { 14, 72 }, { 19, 72 }, { 20, 75 } }, 1):each(function(x, y) c:put(x, y, BRASS.deep) end)
  F(c, c:rect(12, 75, 21, 77), BRASS, 1, { { 13, 75 } })
  F(c, c:rect(12, 78, 21, 91), BRASS, 1)
  F(c, c:rect(14, 80, 19, 89), GLOW, 2, { { 14, 80 }, { 15, 80 }, { 14, 81 } })
  for y = 80, 89 do c:put(16, y, BRASS.shade) end c:put(18, 82, GLOW.hi)
  F(c, c:rect(11, 92, 22, 94), BRASS, 1)
  F(c, c:ellipse(16.5, 72, 3.5, 2.5), FUR, 1, { { 15, 71 } })
else
  local band = head:copy():clip(c:rect(0, 41, 79, 46))
  F(c, band, KERCH, 1, { { 24, 43 } })
  band:each(function(x, y) if (x + 2 * y) % 6 == 0 and y >= 42 and y <= 45 then c:put(x, y, CREAM.hi) end end)
  F(c, c:ellipse(59, 47, 2.5, 2), KERCH, 1)
  F(c, c:poly{ { 60, 48 }, { 66, 52 }, { 64, 54 }, { 59, 50 } }, KERCH, 1)
  F(c, c:poly{ { 60, 46 }, { 66, 43 }, { 66, 45 }, { 61, 48 } }, KERCH, 1)
  -- copper ladle held up at the right
  F(c, c:line({ { 61, 96 }, { 63, 71 } }, 2), COPPER, 1)
  F(c, c:ellipse(64.5, 66, 5.5, 4), COPPER, 2, { { 61, 66 }, { 61, 67 }, { 62, 68 } })
  for x = 61, 68 do c:put(x, 63, x < 63 and BRASS.hi or BRASS.base) end for x = 62, 67 do c:put(x, 64, BRASS.shade) end
  F(c, c:ellipse(61, 88, 4, 3), FUR, 1, { { 59, 87 } })
end
c:finish{ outline = true }
if V == 3 then for _, q in ipairs{ { 63, 60 }, { 64, 59 }, { 64, 58 }, { 65, 57 }, { 66, 59 }, { 67, 58 } } do c:put(q[1], q[2], CREAM.base) end end
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
