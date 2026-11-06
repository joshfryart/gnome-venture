-- npc-thistle-leafwhisker portrait (npc2 P1_35) species: dragonfly
-- 80x100 head+shoulders. Same design as the sprite: blue dragonfly, green compound-eye domes holding the locked eyes,
-- pink knit cap, glassy wings, brown smock + cream bib, snout plate. Prop: thistle flower in hand. Backdrop: dusk disc.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-thistle-leafwhisker"
local BLU = { hi = "#8fd8f0", base = "#3f9ad8", shade = "#2f5fa8", deep = "#2a3a72" }
local SN  = { hi = "#c8f0fa", base = "#8fd8f0", shade = "#3f9ad8", deep = "#2f5fa8" }
local WING = { hi = "#e4f6ff", base = P.sky.base, shade = P.sky.shade, deep = P.sky.deep }
local GRN, CAP, SMK = P.moss, P.petal, P.wood
local FLW = { hi = "#ffa8e0", base = "#e05aa8", shade = "#a83a86", deep = "#6a2058" }
local CR  = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  disc:grow(1):cut(disc):each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- wings
for _, sgn in ipairs{ -1, 1 } do
  for _, w in ipairs{ { 24, 58, 9, 3.5, -15, 1 }, { 26, 37, 12, 4.5, 20, 2 } } do
    local cx, cy, rx, ry, ang = 39.5 + sgn * w[1], w[2], w[3], w[4], w[5]
    local m = oval(cx, cy, rx, ry, -sgn * ang)
    c:part(m, WING, { band = w[6], nopop = true, inner = false })
    local ox, oy = sgn * math.cos(math.rad(ang)), -math.sin(math.rad(ang))
    for _, off in ipairs{ -1, 1 } do
      c:fillMask(c:line({ { cx - ox * (rx - 3), cy - oy * (rx - 3) + off }, { cx + ox * (rx - 2), cy + oy * (rx - 2) + off } }, 1):clip(m:shrink(1)), WING.shade)
    end
    m:edge():each(function(x, y) if not m:has(x, y - 1) and c:get(x, y) == WING.base then c:put(x, y, WING.hi) end end)
    local tx, ty = math.floor(cx + ox * (rx - 3) + .5), math.floor(cy + oy * (rx - 3) + .5)
    c:fillMask(c:rect(tx, ty, tx + 1, ty), P.dusk.shade)
  end
end
-- shoulders: smock, bib, neck
local body = c:ellipse(39.5, 102, 32, 28):clip(c:rect(0, 0, 79, 99))
c:part(body, SMK, { band = 3, pop = { x = 15, y = 88 } })
local bib = c:rrect(29, 81, 50, 99, 4)
c:part(bib, CR, { band = 2, nopop = true })
c:part(c:line({ { 31, 82 }, { 29, 77 } }, 3), CR, { band = 1, nopop = true })
c:part(c:line({ { 48, 82 }, { 50, 77 } }, 3), CR, { band = 1, nopop = true })
c:button(31, 83) c:button(48, 83)
c:stitch{ { 32, 88 }, { 47, 88 } }
c:part(c:ellipse(39.5, 72, 7, 5), BLU, { band = 1, nopop = true })
-- head, cap, eye domes
c:part(c:ellipse(39.5, 58, 17, 14), BLU, { band = 3, pop = { x = 27, y = 50 } })
local cap = c:ellipse(39.5, 37, 12, 6.5)
cap:add(HP.ellipse(39.5, 29.5, 2.2, 2.2))
c:part(cap, CAP, { band = 2, pop = { x = 31, y = 33 } })
c:stitch{ { 29, 35 }, { 34, 32 }, { 45, 32 }, { 50, 35 } }
for _, cx in ipairs{ 28.5, 50.5 } do
  local d = c:ellipse(cx, 45, 10, 9)
  c:part(d, GRN, { band = 3, pop = { x = math.floor(cx) - 6, y = 39 } })
  d:each(function(x, y) if (x + 2 * y) % 5 == 0 and c:get(x, y) == GRN.base then c:put(x, y, GRN.shade) end end)
  under(d, GRN.deep)
end
c:eyeLocked(26, 43) c:eyeLocked(49, 43)
-- snout plate with mandible ticks, smile, cheeks
local sn = c:ellipse(39.5, 60, 4, 2.5)
c:part(sn, SN, { band = 1, pop = { x = 37, y = 58 } })
c:put(39, 61, SN.deep) c:put(40, 61, SN.deep)
c:put(35, 62, P.ink) c:put(44, 62, P.ink)
c:paint({ "i....i", ".iiii." }, 37, 64, { i = "ink" })
c:paint({ "PPP", "PPP" }, 24, 57, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 57, { P = "petal.base" })
-- thistle in a blue hand
c:part(c:line({ { 63, 84 }, { 65, 74 }, { 66, 67 } }, 2), GRN, { band = 1, nopop = true, inner = false })
local bulb = c:ellipse(66, 64, 4, 3.5)
c:part(bulb, GRN, { band = 2, pop = { x = 64, y = 62 } })
bulb:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, GRN.deep) end end)
local fl = c:ellipse(66, 59.5, 4.5, 2)
for _, t in ipairs{ { 59, 53 }, { 61, 51 }, { 64, 50 }, { 66, 49 }, { 68, 50 }, { 71, 51 }, { 73, 53 } } do fl:add(c:line({ { 66, 60 }, t }, 2)) end
c:part(fl, FLW, { band = 1, pop = { x = 62, y = 53 }, inner = false })
local hand = c:ellipse(63, 86, 4, 3.5)
c:part(hand, BLU, { band = 2, pop = { x = 61, y = 84 } })
c:finish{ outline = true }
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
