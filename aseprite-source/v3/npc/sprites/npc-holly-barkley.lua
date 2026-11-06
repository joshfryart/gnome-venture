-- npc-holly-barkley sprite (npc2 P1_14) species: field mouse
-- Holly Barkley: round brown mouse, big pink-lined ears, knitted gold sweater, striped red scarf, long pink tail.
-- prop: holly sprig tucked behind the right ear. idle 4f: base / breath (body 1px down, tail tip settles) / base / left-ear twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-holly-barkley"
local MUZ = { hi = P.skinA.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }
local HOL = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1e3d3c" }
local function holly(ax, ay, bx, by, w)
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts, N = {}, 6
  local function wd(i) return w * math.sin(math.pi * i / N) * (i % 2 == 1 and 1.35 or 0.8) end
  for i = 0, N do pts[#pts + 1] = { ax + dx * i / N + nx * wd(i), ay + dy * i / N + ny * wd(i) } end
  for i = N - 1, 1, -1 do pts[#pts + 1] = { ax + dx * i / N - nx * wd(i), ay + dy * i / N - ny * wd(i) } end
  return HP.poly(pts)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tt, et = p.b or 0, p.tt or 0, p.et or 0
  c:groundShadow(32, 89, 13, 3)
  -- long tail curling up on the left
  c:part(c:line({ {27,84+b},{20,86},{15,83},{13,78},{15,74+tt} }, 2), P.petal, { band = 1, nopop = true })
  -- feet (fixed)
  c:part(c:ellipse(27, 89, 3, 1.5), P.petal, { band = 1, nopop = true })
  c:part(c:ellipse(38, 89, 3, 1.5), P.petal, { band = 1, nopop = true })
  -- knitted sweater body
  local body = c:ellipse(32.5, 77+b, 11, 10):clip(c:rect(0, 0, 63, 87+b))
  c:part(body, P.gold, { band = 2, pop = { x = 25, y = 71+b } })
  for x = 22, 43 do for y = 85+b, 87+b do if x % 2 == 0 and body:has(x, y) then c:put(x, y, P.gold.shade, true) end end end
  for y = 70+b, 83+b, 2 do c:put(32, y, P.gold.hi, true) c:put(33, y+1, P.gold.shade, true) end
  -- arms + paws
  for _, ax in ipairs{ 20, 45 } do
    c:part(c:ellipse(ax, 76+b, 2.5, 3.5), P.gold, { band = 1, nopop = true })
    c:part(c:ellipse(ax, 81+b, 2, 1.5), P.wood, { band = 1, nopop = true })
  end
  -- scarf with stripes and a hanging end
  local sc = c:rrect(21, 64+b, 44, 68+b, 2)
  c:part(sc, P.ember, { band = 1 })
  local st = c:poly{ {36,67+b},{41,67+b},{42,76+b},{36,76+b} }
  c:part(st, P.ember, { band = 1, nopop = true, sep = true })
  sc:copy():add(st):each(function(x, y) if (x + y) % 6 == 0 and c:get(x, y) == P.ember.base then c:put(x, y, P.cream, true) end end)
  for x = 36, 42, 2 do c:put(x, 76+b, P.ember.deep, true) end
  -- big round ears
  for _, e in ipairs{ { 19, -et }, { 46, 0 } } do
    local ex, ey = e[1] + e[2], 44 + b + e[2]
    c:part(c:ellipse(ex, ey, 7, 7), P.wood, { band = 2, pop = { x = ex - 5, y = ey - 4 } })
    c:part(c:ellipse(ex, ey + 1, 4, 4), P.petal, { band = 1, pop = { x = ex - 2, y = ey - 2 } })
  end
  -- head
  local head = c:ellipse(32.5, 54+b, 12.5, 10)
  c:part(head, P.wood, { band = 2, pop = { x = 24, y = 47+b } })
  c:part(c:ellipse(32.5, 60+b, 6, 3.5), MUZ, { band = 1, nopop = true, inner = false })
  for x = 31, 34 do c:put(x, 58+b, P.petal.base, true) end
  c:put(32, 57+b, P.petal.hi, true) c:put(33, 57+b, P.petal.base, true)
  for _, q in ipairs{ {30,61},{31,62},{32,61},{33,61},{34,62},{35,61} } do c:put(q[1], q[2]+b, P.wood.deep, true) end
  c:eyeLocked(24, 50+b) c:eyeLocked(37, 50+b)
  c:cheek(21, 57+b) c:cheek(43, 57+b)
  -- holly sprig behind the right ear
  for _, l in ipairs{ { 51, 42 }, { 47, 37 } } do
    local m = holly(43, 47+b, l[1], l[2]+b, 2.2)
    c:part(m, HOL, { band = 1, nopop = true, sep = true })
    c:line({ {43,47+b},{l[1],l[2]+b} }, 1):clip(m:shrink(1)):each(function(x, y) c:put(x, y, P.moss.base, true) end)
  end
  for _, q in ipairs{ {42,47},{45,48},{43,50} } do
    c:part(c:ellipse(q[1], q[2]+b, .8, .8), P.ember, { band = 1, nopop = true, sep = true })
    c:put(q[1], q[2]+b-1, P.ember.hi, true)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, tt = 1 }, { b = 0 }, { b = 0, et = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
