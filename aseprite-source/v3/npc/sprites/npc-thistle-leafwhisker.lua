-- npc-thistle-leafwhisker sprite (npc2 P1_35) species: dragonfly
-- Thistle Leafwhisker: young blue dragonfly, huge green compound-eye domes, pink knit cap, brown smock + cream apron,
-- four glassy wings raised in a V, segmented tail curling out left. Prop: a thistle flower in the right hand.
-- 64x96 cell, 3/4 top-down, feet y=90 x=32. idle x4: base / breath / base / blink + wing flick + tail twitch.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-thistle-leafwhisker"
local BLU = { hi = "#8fd8f0", base = "#3f9ad8", shade = "#2f5fa8", deep = "#2a3a72" }
local WING = { hi = "#e4f6ff", base = P.sky.base, shade = P.sky.shade, deep = P.sky.deep }
local GRN, CAP, SMK = P.moss, P.petal, P.wood
local FLW = { hi = "#ffa8e0", base = "#e05aa8", shade = "#a83a86", deep = "#6a2058" }
local CR  = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, wd, tt = p.b or 0, p.wd or 0, p.tt or 0
  c:groundShadow(32, 89, 13, 3)
  -- wings (behind): fore pair raised in a V, hind pair flatter
  for _, sgn in ipairs{ -1, 1 } do
    for _, w in ipairs{ { 16, 55, 8, 3, 15 }, { 15, 45, 10, 3.5, 52 } } do
      local cx, cy, rx, ry, ang = 32 + sgn * w[1], w[2] + b + wd, w[3], w[4], w[5]
      local m = oval(cx, cy, rx, ry, -sgn * ang)
      c:part(m, WING, { band = 1, nopop = true, inner = false })
      local ox, oy = sgn * math.cos(math.rad(ang)), -math.sin(math.rad(ang))
      c:fillMask(c:line({ { cx - ox * (rx - 3), cy - oy * (rx - 3) }, { cx + ox * (rx - 2), cy + oy * (rx - 2) } }, 1):clip(m:shrink(1)), WING.shade)
      c:put(math.floor(cx + ox * (rx - 2) + .5), math.floor(cy + oy * (rx - 2) + .5), P.dusk.shade)
    end
  end
  -- segmented tail curling out to the left
  local tail = c:line({ { 26, 80 + b }, { 16, 82 + b }, { 10, 77 + b }, { 8 - tt, 69 + b } }, 3)
  c:part(tail, BLU, { band = 1, pop = { x = 9 - tt, y = 69 + b }, inner = false })
  tail:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == BLU.base then c:put(x, y, BLU.deep) end end)
  -- smock + apron
  local body = c:ellipse(32, 75 + b, 11, 12):clip(c:rect(0, 0, 63, 86))
  c:part(body, SMK, { band = 2, pop = { x = 24, y = 70 + b } })
  under(c, body, SMK.deep)
  c:part(c:rrect(28, 72 + b, 36, 87 + b, 2):clip(body), CR, { band = 1, nopop = true })
  c:button(32, 75 + b)
  c:part(c:ellipse(20, 76 + b, 2.5, 2.5), BLU, { band = 1, nopop = true })
  -- thistle in the right hand
  c:fillMask(c:line({ { 44, 76 + b }, { 47, 72 + b }, { 49, 69 + b } }, 1), GRN.deep)
  local bulb = c:ellipse(49, 68 + b, 2.5, 2.5)
  c:part(bulb, GRN, { band = 1, pop = { x = 48, y = 67 + b } })
  c:put(48, 69 + b, GRN.deep) c:put(50, 67 + b, GRN.deep)
  local fl = c:ellipse(49, 65 + b, 3, 1.5)
  for _, t in ipairs{ { 45, 62 }, { 47, 61 }, { 49, 60 }, { 51, 61 }, { 53, 62 } } do fl:add(c:line({ { 49, 65 + b }, { t[1], t[2] + b } }, 1)) end
  c:part(fl, FLW, { band = 1, pop = { x = 47, y = 62 + b }, inner = false })
  c:part(c:ellipse(44, 76 + b, 2.5, 2.5), BLU, { band = 1, nopop = true })
  -- head, cap, eye domes
  c:part(c:ellipse(32, 60 + b, 5, 3), BLU, { band = 1, nopop = true })
  local head = c:ellipse(32, 51 + b, 13, 11)
  c:part(head, BLU, { band = 2, pop = { x = 23, y = 47 + b } })
  local cap = c:ellipse(32, 39 + b + wd * 0, 7, 3.5)
  cap:add(c:ellipse(32, 35 + b, 1.5, 1.5))
  c:part(cap, CAP, { band = 1, pop = { x = 28, y = 37 + b } })
  for _, cx in ipairs{ 24.5, 39.5 } do
    local d = c:ellipse(cx, 44 + b, 6.5, 6)
    c:part(d, GRN, { band = 2, pop = { x = math.floor(cx) - 4, y = 40 + b } })
    d:each(function(x, y) if (x + 2 * y) % 4 == 0 and c:get(x, y) == GRN.base then c:put(x, y, GRN.shade) end end)
  end
  local function eye(x, y)
    if p.blink then
      for i = 0, 3 do c:put(x + i, y + 1, GRN.shade) c:put(x + i, y + 2, P.ink) end
      return
    end
    for j = 0, 3 do for i = 0, 3 do if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then c:put(x + i, y + j, P.cream) end end end
    c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
  end
  eye(22, 43 + b) eye(38, 43 + b)
  -- little snout plate + smile + cheeks
  c:put(31, 52 + b, BLU.hi) c:put(32, 52 + b, BLU.hi) c:put(31, 53 + b, BLU.shade) c:put(32, 53 + b, BLU.shade)
  for _, q in ipairs{ { 29, 54 }, { 30, 55 }, { 31, 55 }, { 32, 55 }, { 33, 55 }, { 34, 54 } } do c:put(q[1], q[2] + b, P.ink) end
  c:cheek(24, 52 + b) c:cheek(38, 52 + b)
  -- feet (fixed)
  for _, x in ipairs{ 27, 37 } do
    local m = c:ellipse(x, 88, 3, 2)
    c:part(m, BLU, { band = 1, nopop = true }) under(c, m, BLU.deep)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1 }, {}, { blink = true, wd = -1, tt = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
