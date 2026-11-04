-- npc-yarrow-mossfoot sprite (npc2 P1_39) species: frog (green tree frog)
-- Cheerful herbalist frog: squat wide head, bulging gold-ringed eyes, mossy webbed feet, pink smock with V collar,
-- small floppy brown hat tucked between the eye bumps. Prop: a tall flowering yarrow stalk held like a staff.
-- 64x96 cell, 3/4 top-down, feet baseline y=90, x=32. idle x4: base, breath(-1px, hat tip settles), base, blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-yarrow-mossfoot"
local FR = { hi = "#cfe38c", base = "#8fbf5a", shade = "#4f8a5e", deep = "#2f5452" }
local BELLY = { hi = "#fff1c2", base = "#ecd99a", shade = "#bfae8e", deep = "#7e7486" }
local STEM = { hi = P.moss.hi, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3a3a" }
local UMB = { hi = P.cream, base = "#f1e6cf", shade = "#cdb8c8", deep = "#8f7a9a" }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
  local function eye(x, y)
    for j = 0, 4 do for i = 0, 4 do if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then keep(x + i, y + j, P.cream) end end end
    for j = 1, 3 do for i = 1, 3 do keep(x + i, y + j, P.ink) end end
    keep(x + 1, y + 1, P.cream)
  end
  local b = p.b or 0
  c:groundShadow(32, 89.5, 14, 2.5)
  -- big webbed feet with moss tufts (fixed)
  for _, fx in ipairs{ 24, 40 } do
    c:part(c:ellipse(fx + 0.5, 88.5, 5.5, 2), FR, { band = 1, nopop = true })
    keep(fx - 2, 90, FR.deep) keep(fx + 1, 90, FR.deep) keep(fx + 3, 90, FR.deep)
    keep(fx - 1, 87, P.moss.shade) keep(fx, 87, P.moss.base) keep(fx + 1, 87, P.moss.hi) keep(fx, 88, P.moss.shade)
  end
  -- body + pink smock + V collar
  local body = c:ellipse(32, 77 + b, 13, 9)
  c:part(body, FR, { band = 2 })
  local tun = body:copy():clip(c:rect(0, 0, 63, 82 + b))
  c:part(tun, P.petal, { band = 2, pop = { 22, 72 + b } })
  for x = 20, 44, 2 do keep(x, 82 + b, P.gold.base) end
  c:part(c:poly{ { 28, 68 + b }, { 36, 68 + b }, { 32, 74 + b } }, BELLY, { band = 1, nopop = true })
  c:part(c:ellipse(19.5, 76 + b, 3, 4.5), FR, { band = 1 })
  -- yarrow stalk with feathery leaves, flat cream umbel
  c:part(c:line({ { 48, 85 + b }, { 48, 39 + b } }, 2), STEM, { noshade = true, nopop = true })
  for _, l in ipairs{ { 49, 64, 53, 61 }, { 47, 57, 43, 54 }, { 49, 50, 52, 48 }, { 47, 70, 44, 68 } } do
    c:part(c:line({ { l[1], l[2] + b }, { l[3], l[4] + b } }, 1), STEM, { noshade = true, nopop = true })
  end
  local u = b + (p.u or 0)
  local um = c:ellipse(48.5, 36 + u, 6, 2.5)
  for _, q in ipairs{ { 43.5, 37 }, { 53.5, 37 }, { 46, 34 }, { 51, 34 } } do um:add(c:ellipse(q[1], q[2] + u, 1.5, 1.5)) end
  c:part(um, UMB, { band = 1, pop = { 44, 35 + u } })
  for _, q in ipairs{ { 46, 36 }, { 49, 35 }, { 51, 37 }, { 48, 37 }, { 53, 36 } } do keep(q[1], q[2] + u, P.gold.hi) end
  c:part(c:ellipse(46.5, 74 + b, 3, 3), FR, { band = 1 })
  -- wide head, throat, spots, nostrils, big smile
  local head = c:ellipse(32, 61 + b, 16, 9.5)
  c:part(head, FR, { band = 2, pop = { 20, 58 + b } })
  c:part(c:rect(24, 67 + b, 40, 71 + b):clip(head), BELLY, { band = 1, inner = false, nopop = true })
  for _, q in ipairs{ { 27, 57 }, { 28, 57 }, { 37, 56 }, { 38, 56 }, { 33, 58 }, { 19, 61 }, { 44, 60 } } do keep(q[1], q[2] + b, FR.shade) end
  keep(30, 61 + b, FR.deep) keep(34, 61 + b, FR.deep)
  for x = 21, 43 do
    local d = math.abs(x - 32)
    keep(x, 65 + b - (d >= 9 and 1 or 0) - (d >= 11 and 1 or 0), P.ink)
  end
  keep(20, 64 + b, P.petal.base) keep(21, 65 + b, P.petal.base) keep(43, 65 + b, P.petal.base) keep(44, 64 + b, P.petal.base)
  -- little floppy hat between the eye bumps, moss tuft on brim
  local h, tip = b + (p.hb or 0), p.tip or 0
  local hm = c:ellipse(32, 50 + h, 8.5, 2)
  hm:add(c:poly{ { 27, 50 + h }, { 37, 50 + h }, { 34, 42 + h }, { 30, 43 + h } })
  hm:add(c:line({ { 32, 43 + h }, { 35, 39 + h + tip }, { 38, 40 + h + tip } }, 2))
  c:part(hm, P.wood, { band = 2, pop = { 29, 45 + h } })
  c:part(c:rect(28, 47 + h, 36, 48 + h):clip(hm), P.gold, { band = 1, nopop = true })
  keep(25, 50 + h, P.moss.base) keep(26, 49 + h, P.moss.hi)
  -- bulging eye bumps with gold rings
  for _, ex in ipairs{ 23.5, 40.5 } do
    c:part(c:ellipse(ex, 54.5 + b, 5, 4.5), FR, { band = 1 })
    local ir = c:ellipse(ex, 54.5 + b, 3.5, 3.5)
    c:part(ir, P.gold, { band = 1, nopop = true })
    if p.blink then ir:each(function(x, y) keep(x, y, y == 55 + b and P.ink or FR.base) end)
    else eye(math.floor(ex) - 2, 52 + b) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, tip = 1, u = 0 }, { b = 0 }, { b = 0, blink = true } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
