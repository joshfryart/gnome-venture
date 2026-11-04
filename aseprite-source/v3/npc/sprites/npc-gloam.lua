-- npc-gloam sprite (npc2 P1_12) species: bat
-- Gloam: shy dusk bat, wings folded like a cape, gold knit sweater, carries a red paper lantern (prop).
-- 64x96 cell, 3/4 top-down, feet baseline y=90 at x=32. idle x4: base / breath+lantern sway / base / blink+ear twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-gloam"
local FUR = P.dusk
local WING = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#241a40" }
local MUZ = { hi = "#e6dcfa", base = P.dusk.hi, shade = "#a88ee0", deep = P.dusk.base }
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local function mir(pts) local r = {} for i, q in ipairs(pts) do r[i] = { 64 - q[1], q[2] } end return r end
local function sh(pts, dx, dy) local r = {} for i, q in ipairs(pts) do r[i] = { q[1] + dx, q[2] + dy } end return r end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local O = { r = { name = "detail" } }
  local function put(x, y, h) c:put(x, y, h, O) end
  local function fm(m, h) m:each(function(x, y) put(x, y, h) end) end
  local b = p.b or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  -- feet (static)
  for _, fx in ipairs{ 27.5, 36.5 } do
    c:part(c:ellipse(fx, 88.5, 3, 1.5), WING, { band = 1, nopop = true })
    put(math.floor(fx), 89, WING.deep)
  end
  -- folded wings (cape) behind the body, scalloped hem + finger ribs
  local wl = { { 21, 62 }, { 26, 64 }, { 26, 84 }, { 23, 82 }, { 20, 85 }, { 17, 81 }, { 14, 83 }, { 14, 70 } }
  for side = 1, 2 do
    local pts = sh(side == 1 and wl or mir(wl), 0, b)
    local w = c:poly(pts)
    c:part(w, WING, { band = 2, nopop = true })
    local s = side == 1 and 1 or -1
    local function X(x) return side == 1 and x or 64 - x end
    fm(c:line({ { X(22), 64 + b }, { X(20), 84 + b } }, 1):clip(w:shrink(1)), WING.deep)
    fm(c:line({ { X(21), 64 + b }, { X(16), 81 + b } }, 1):clip(w:shrink(1)), WING.deep)
    put(X(15), 71 + b, WING.hi) put(X(15), 72 + b, WING.hi)
  end
  -- gold knit sweater: round barrel, ribbed hem
  local sw = c:ellipse(32, 77 + b, 11, 7.5)
  c:part(sw, P.gold, { band = 2 })
  sw:each(function(x, y) if not sw:has(x, y + 2) and x % 2 == 0 then put(x, y, P.gold.shade) end end)
  sw:each(function(x, y) if not sw:has(x, y + 1) then put(x, y, P.gold.deep) end end)
  c:part(c:poly{ { 27, 70 + b }, { 37, 70 + b }, { 32, 75 + b } }, CR, { band = 1, nopop = true })
  put(32, 77 + b, P.gold.hi)
  -- stubby wing-arms
  c:part(c:ellipse(20, 75 + b, 2.5, 3), FUR, { band = 1 })
  -- lantern stick + red paper lantern (prop); sways on breath
  local lx = p.lx or 0
  fm(c:line({ { 45, 74 + b }, { 53, 65 + b } }, 1), P.wood.shade)
  put(53, 66 + b, P.wood.deep) put(53 + lx, 67 + b, P.wood.deep)
  local lan = c:rrect(50 + lx, 68 + b, 56 + lx, 75 + b, 2)
  c:part(lan, P.ember, { band = 1, nopop = true })
  for x = 51, 55 do put(x + lx, 68 + b, P.wood.deep) put(x + lx, 75 + b, P.wood.deep) end
  for y = 70, 73 do for x = 52, 54 do put(x + lx, y + b, P.gold.hi) end end
  put(52 + lx, 70 + b, P.cream) put(54 + lx, 73 + b, P.gold.base)
  for _, y in ipairs{ 70, 72 } do put(51 + lx, y + b, P.ember.deep) put(55 + lx, y + b, P.ember.deep) end
  put(53 + lx, 76 + b, P.gold.base) put(53 + lx, 77 + b, P.gold.shade)
  c:part(c:ellipse(44.5, 74 + b, 2.5, 2.5), FUR, { band = 1, nopop = true })
  -- tall pointed ears (tips lag on breath, right one twitches)
  local et, ex = p.et or 0, p.ex or 0
  for side = 1, 2 do
    local tipx = side == 1 and 16 or 48 + ex
    local tipy = 24 + et + (side == 2 and (p.ey or 0) or 0)
    local ear = side == 1 and { { 19, 50 + b }, { 28, 43 + b }, { tipx, tipy + b } } or { { 45, 50 + b }, { 36, 43 + b }, { tipx, tipy + b } }
    c:part(c:poly(ear), FUR, { band = 2, nopop = true })
    local inn = side == 1 and { { 21, 46 + b }, { 26, 44 + b }, { tipx + 2, tipy + 6 + b } } or { { 43, 46 + b }, { 38, 44 + b }, { tipx - 2, tipy + 6 + b } }
    c:part(c:poly(inn), P.petal, { band = 1, nopop = true })
  end
  -- big round head, top lit (3/4 view)
  local hd = c:ellipse(32, 53 + b, 13.5, 11)
  c:part(hd, FUR, { band = 3 })
  c:part(c:poly{ { 29, 43 + b }, { 30, 39 + b }, { 32, 42 + b }, { 34, 39 + b }, { 35, 43 + b } }, FUR, { band = 1, nopop = true })
  for _, q in ipairs{ { 25, 45 }, { 26, 45 }, { 25, 46 } } do put(q[1], q[2] + b, FUR.hi) end
  -- muzzle, pug nose, fangs
  c:part(c:ellipse(32, 59 + b, 6, 3.5), MUZ, { band = 1, nopop = true })
  put(31, 56 + b, P.petal.hi) put(32, 56 + b, P.petal.base) put(31, 57 + b, P.petal.shade) put(32, 57 + b, P.petal.shade)
  for _, q in ipairs{ { 29, 59 }, { 30, 60 }, { 31, 60 }, { 32, 60 }, { 33, 60 }, { 34, 59 } } do put(q[1], q[2] + b, P.ink) end
  put(30, 61 + b, P.cream) put(33, 61 + b, P.cream)
  -- eyes
  local function eye(x, y)
    if p.blink then for i = 0, 3 do put(x + i, y + 2, P.ink) end return end
    for _, q in ipairs{ { 1, 0 }, { 2, 0 }, { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } } do put(x + q[1], y + q[2], P.cream) end
    put(x + 2, y + 1, P.ink) put(x + 1, y + 2, P.ink) put(x + 2, y + 2, P.ink)
  end
  eye(25, 50 + b) eye(36, 50 + b)
  put(21, 56 + b, P.petal.base) put(22, 56 + b, P.petal.base) put(42, 56 + b, P.petal.base) put(43, 56 + b, P.petal.base)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, lx = -1, et = -1 }, { b = 0 }, { b = 0, blink = true, ex = 1, ey = 2 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
