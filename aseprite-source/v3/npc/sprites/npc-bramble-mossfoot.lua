-- npc-bramble-mossfoot sprite (npc2 P1_3) species: hedgehog
-- Bramble Mossfoot: shy, earthy hedgehog. Brown spine cloak with pale tips, cream face + pointed snout,
-- green knit sweater, red stitched scarf. Prop/quirk: a red-cap mushroom + moss tuft growing on his spines.
-- 64x96 cell, feet baseline y=90, idle 4 frames (base, breath + mushroom settles, base, blink + ear twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-mossfoot"
local SPN = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2230" }
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local STEM = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local NOSE = P.dusk.deep
local function R(v) return math.floor(v + 0.5) end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function spikes(c, cx, cy, rx, ry, a0, a1, n, len, w, lean)
  local m, tips = HP.mask(), {}
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * i / (n - 1))
    local ca, sa = math.cos(a), math.sin(a)
    local bx, by = cx + ca * (rx - 1), cy + sa * (ry - 1)
    local ta = a + math.rad(lean or 0)
    local tx, ty = cx + math.cos(ta) * (rx + len), cy + math.sin(ta) * (ry + len)
    m:add(c:poly{ { R(bx - sa * w), R(by + ca * w) }, { R(tx), R(ty) }, { R(bx + sa * w), R(by - ca * w) } })
    tips[#tips + 1] = { R(tx), R(ty) }
  end
  return m, tips
end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ex = p.bob or 0, p.ear or 0
  c:groundShadow(32, 89.5, 13, 3)
  for _, fx in ipairs{ 26.5, 38.5 } do
    local m = c:ellipse(fx, 88, 3.5, 2)
    c:part(m, P.skinB, { band = 1, pop = { x = R(fx) - 2, y = 87 } }) under(c, m, P.skinB.deep)
  end
  -- spine cloak (head top + back), pale tips, radial strands
  local cx, cy = 32, 58 + b
  local core = c:ellipse(cx, cy, 16, 17)
  local sk, tips = spikes(c, cx, cy, 16, 17, 150, 390, 15, 4, 2.5, 6)
  local sp = core:copy():add(sk)
  c:part(sp, SPN, { band = 3, pop = { x = 23, y = 46 + b } })
  for i = 0, 15 do
    local a = math.rad(160 + i * 14)
    local s = c:line({ { R(cx + math.cos(a) * 9), R(cy + math.sin(a) * 10) }, { R(cx + math.cos(a + .12) * 15), R(cy + math.sin(a + .12) * 16) } }, 1):clip(sp)
    local lit = math.cos(a) < 0.1 and math.sin(a) < 0
    s:each(function(x, y) c:put(x, y, (lit and i % 2 == 0) and SPN.hi or SPN.deep) end)
  end
  for _, t in ipairs(tips) do for dy = -1, 1 do for dx = -1, 1 do
    if math.abs(dx) + math.abs(dy) <= 1 and sk:has(t[1] + dx, t[2] + dy) and not core:has(t[1] + dx, t[2] + dy) then c:put(t[1] + dx, t[2] + dy, P.wood.hi) end
  end end end
  -- round ears poking from the spines
  for i, e in ipairs{ { 19.5 - ex, 50 }, { 44.5 + ex, 50 } } do
    local m = c:ellipse(e[1], e[2] + b - (i == 2 and ex or 0), 2.5, 2.5)
    c:part(m, FACE, { band = 1, nopop = true })
    c:put(R(e[1]), e[2] + b - (i == 2 and ex or 0), P.skinA.shade)
  end
  -- knit sweater + stubby sleeves and paws
  local sw = c:ellipse(32, 77 + b, 13, 10):clip(c:rect(0, 0, 63, 86))
  c:part(sw, P.moss, { band = 3, pop = { x = 22, y = 71 + b } })
  sw:each(function(x, y) if not sw:has(x, y + 1) then c:put(x, y, P.moss.deep) end end)
  for x = 21, 43, 2 do if sw:has(x, 85) then c:put(x, 85, P.moss.shade) end end
  for _, a in ipairs{ { 18.5, false }, { 45.5, true } } do
    c:part(c:ellipse(a[1], 75 + b, 3, 4), P.moss, { band = 1, nopop = a[2] })
    c:part(c:ellipse(a[1], 79 + b, 2, 1.5), P.skinB, { band = 1, nopop = true })
  end
  c:part(c:rect(31, 76 + b, 32, 77 + b), P.gold, { band = 1, pop = { x = 31, y = 76 + b } })
  -- face, snout, nose
  local fc = c:ellipse(32, 59 + b, 11, 8)
  c:part(fc, FACE, { band = 2, pop = { x = 24, y = 53 + b } })
  local sn = c:ellipse(32.5, 61 + b, 4.5, 3)
  c:part(sn, FACE, { band = 1, sep = true, pop = { x = 30, y = 59 + b } })
  under(c, sn, FACE.deep)
  c:paint({ ".nn.", "nnnn" }, 31, 61 + b, { n = NOSE })
  c:put(32, 61 + b, P.stone.hi)
  c:put(32, 65 + b, P.skinA.shade) c:put(33, 65 + b, P.skinA.shade)
  eye(c, 24, 54 + b, p.blink) eye(c, 38, 54 + b, p.blink)
  c:cheek(22, 60 + b) c:cheek(41, 60 + b)
  -- scarf
  local sc = c:rrect(20, 66 + b, 44, 69 + b, 2)
  c:part(sc, P.ember, { band = 1, pop = { x = 22, y = 66 + b } })
  local tl = c:poly{ { 37, 68 + b }, { 41, 68 + b }, { 42, 77 + b }, { 38, 77 + b } }
  c:part(tl, P.ember, { band = 1, sep = true, nopop = true })
  c:stitch{ { 21, 67 + b }, { 43, 67 + b } }
  for x = 38, 42, 2 do c:put(x, 77 + b, P.ember.deep) end
  -- prop/quirk: moss tuft + red mushroom on the spines (lags one frame when he breathes)
  local my = b + (p.md or 0)
  local tuft = c:ellipse(23, 43 + my, 5, 2) tuft:add(c:ellipse(19, 42 + my, 2, 1.5))
  c:part(tuft, P.moss, { band = 1, sep = true, pop = { x = 19, y = 41 + my } })
  c:part(c:rect(24, 37 + my, 25, 41 + my), STEM, { band = 1, nopop = true })
  local cap = c:ellipse(24.5, 36 + my, 4, 2.5)
  c:part(cap, P.ember, { band = 1, pop = { x = 22, y = 34 + my } })
  under(c, cap, P.ember.deep)
  c:put(25, 35 + my, P.cream) c:put(27, 36 + my, P.cream) c:put(22, 36 + my, P.cream)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { {}, { bob = 1, md = 1 }, {}, { blink = true, ear = 1 } }
local fr = {}
for _, p in ipairs(F) do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
