-- npc-tumble-seedwell sprite (npc2 P1_36) species: hedgehog
-- Round lavender-quilled hedgehog seed-keeper, seeds stuck in the quills, sprout growing from the crown,
-- pink smock with cream ruff. Prop: seed satchel with seeds peeking out. 64x96, feet y=90, idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tumble-seedwell"
local SPINE = { hi = "#c9b2f0", base = "#8a6fd0", shade = "#5a459e", deep = "#35295f" }
local FACE  = { hi = "#ffe8c8", base = "#f0c89a", shade = "#c98f72", deep = "#7a4a46" }
local SNOUT = { hi = P.cream, base = "#ffe8c8", shade = "#f0c89a", deep = "#c98f72" }
local CR    = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local FLAP  = { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }
local SMOCK, LEAF, BAG, NOSE = P.petal, P.moss, P.wood, "#5a2a4a"
local function keep(c, x, y, hex) if x >= 0 and y >= 0 and x < c.w and y < c.h then local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end end
local function spikes(c, m, cx, cy, rx, ry, a0, a1, step, len, half)
  for a = a0, a1, step do
    local r, h = math.rad(a), math.rad(half)
    m:add(c:poly{ { cx + math.cos(r - h) * rx * .85, cy + math.sin(r - h) * ry * .85 },
      { cx + math.cos(r + .12) * (rx + len), cy + math.sin(r + .12) * (ry + len) },
      { cx + math.cos(r + h) * rx * .85, cy + math.sin(r + h) * ry * .85 } })
  end
  return m
end
local function quills(c, m, cx, cy, deg)
  m:each(function(x, y)
    local a = math.deg(math.atan(y + .5 - cy, x + .5 - cx)) % 360
    local k, v = math.floor(a / deg) % 3, c:get(x, y)
    if k == 0 and v == SPINE.base then keep(c, x, y, SPINE.shade)
    elseif k == 0 and v == SPINE.shade then keep(c, x, y, SPINE.deep)
    elseif k == 1 and v == SPINE.base and x < cx and y < cy then keep(c, x, y, SPINE.hi) end
  end)
end
local function seed(c, x, y) c:put(x, y, P.gold.hi) c:put(x + 1, y, P.gold.base) c:put(x, y + 1, P.gold.base) c:put(x + 1, y + 1, P.gold.shade) end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 14, 3)
  for _, fx in ipairs{ 26, 38 } do c:part(c:ellipse(fx, 87.5, 3.5, 2), FACE, { band = 1, nopop = true }) end
  -- quill skirt behind the body
  local sky = 67 + b
  local sk = c:ellipse(32, sky, 15, 12)
  spikes(c, sk, 32, sky, 15, 12, 140, 220, 20, 4, 8) spikes(c, sk, 32, sky, 15, 12, -40, 40, 20, 4, 8)
  c:part(sk, SPINE, { band = 2, nopop = true }) quills(c, sk, 32, sky, 7)
  -- smock
  local body = c:ellipse(32, 70 + b, 11, 13)
  body:add(c:poly{ { 22, 74 + b }, { 42, 74 + b }, { 44, 84 + b }, { 20, 84 + b } })
  c:part(body, SMOCK, { band = 2 })
  for x = 22, 42, 3 do if body:has(x, 83 + b) then keep(c, x, 82 + b, SMOCK.hi) end end
  c:part(c:ellipse(20, 69 + b, 2.5, 3.5), FACE, { band = 1 })
  -- satchel strap + seed satchel (prop)
  c:part(c:line({ { 23, 55 + b }, { 41, 71 + b } }, 2), BAG, { band = 1, nopop = true })
  c:part(c:rrect(38, 70 + b, 49, 79 + b, 2), BAG, { band = 1 })
  c:part(c:rrect(38, 70 + b, 49, 73 + b, 1), FLAP, { band = 1, sep = true, nopop = true })
  c:put(43, 74 + b, P.gold.base) c:put(44, 74 + b, P.gold.shade)
  local sd = p.sd or 0
  seed(c, 40, 68 + b) seed(c, 45, 67 + b - sd)
  c:part(c:ellipse(47, 70 + b, 2, 2), FACE, { band = 1, nopop = true })
  -- cream ruff
  c:part(c:ellipse(32, 54 + b, 10, 2.5), CR, { band = 1 })
  -- quilled head
  local hy = 38 + b
  local sp = c:ellipse(32, hy, 17, 15)
  spikes(c, sp, 32, hy, 17, 15, 160, 380, 18, 5, 8)
  c:part(sp, SPINE, { band = 2, nopop = true }) quills(c, sp, 32, hy, 6)
  seed(c, 21, hy - 9) seed(c, 41, hy - 12) seed(c, 15, hy + 3) seed(c, 47, hy + 1)
  for _, ex in ipairs{ 21, 43 } do
    c:part(c:ellipse(ex, hy - 3, 2.5, 2.5), FACE, { band = 1, nopop = true }) c:put(ex, hy - 3, P.petal.base)
  end
  local face = c:ellipse(32, hy + 5, 11, 9)
  c:part(face, FACE, { band = 2, pop = { x = 24, y = hy } })
  local hl = HP.mask()
  for _, x in ipairs{ 25, 29, 33, 37 } do hl:add(c:poly{ { x - 2, hy - 5 }, { x + 2, hy - 5 }, { x, hy - 1 } }) end
  c:part(hl:clip(face), SPINE, { band = 1, nopop = true, inner = false })
  c:part(c:ellipse(32, hy + 10, 4, 3), SNOUT, { band = 1, nopop = true })
  c:fillMask(c:ellipse(32, hy + 12, 1.5, 1), NOSE) c:put(31, hy + 11, P.petal.hi)
  local ey = hy + 1
  for _, ex in ipairs{ 25, 35 } do
    if p.blink then for i = 0, 4 do c:put(ex + i, ey + 2, P.ink) c:put(ex + i, ey + 1, FACE.shade) end
    else c:eyeLocked(ex, ey) end
  end
  c:cheek(22, hy + 7) c:cheek(41, hy + 7)
  -- crown sprout
  local lt, ld = p.lt or 0, p.ld or 0
  c:fillMask(c:line({ { 33, hy - 14 }, { 34, hy - 19 }, { 34, hy - 22 } }, 1), LEAF.shade)
  c:part(c:ellipse(31, hy - 22 + ld, 2.5, 1.5), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(37, hy - 23 - lt + ld, 2.5, 1.5), LEAF, { band = 1, sep = true })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, ld = 1, sd = 0 }, { bob = 0 }, { bob = 0, blink = true, lt = 1, sd = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
