-- npc-fennick-hollowell sprite (npc2 P1_10) species: garden snail
-- Tan snail with a brown spiral shell, eye stalks poking up through the brim of a crooked blue pointy hat
-- (leans LEFT, gold band); prop: a little gold bell on the hat tip. 64x96, foot baseline y=90, idle 4 frames.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-fennick-hollowell"
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function spiral(c, cx, cy, r0, clip, hex)
  local pts = {}
  for i = 0, 40 do local t = i / 40 local a = math.rad(200 + t * 560) local r = r0 * (1 - t * 0.85)
    pts[#pts + 1] = { cx + math.cos(a) * r, cy + math.sin(a) * r } end
  c:fillMask(c:line(pts, 1):clip(clip), hex)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, st, tw = p.bob or 0, p.stalk or 0, p.tw or 0
  c:groundShadow(32, 89.5, 19, 3)
  -- foot (never moves)
  local foot = c:ellipse(32, 87, 18, 3)
  c:part(foot, "skinA", { band = 1 })
  for x = 16, 48, 4 do c:put(x, 89, P.skinA.deep) end
  -- shell behind right
  local shell = c:ellipse(44, 67 + b, 13.5, 14)
  c:part(shell, "wood", { band = 3, pop = { 37, 57 + b } })
  spiral(c, 45, 68 + b, 11, shell:shrink(1), P.wood.deep)
  -- body column + head
  local body = c:rrect(20, 58 + b, 36, 86, 7)
  c:part(body, "skinA", { band = 2, sep = true })
  local head = c:ellipse(28, 53 + b, 12.5, 9.5)
  c:part(head, "skinA", { band = 2, sep = true, pop = { 19, 50 + b } })
  -- muzzle, nose, smile
  c:part(c:ellipse(28, 56 + b, 5, 2.5), CR, { band = 1, nopop = true })
  c:put(27, 54 + b, P.wood.shade) c:put(28, 54 + b, P.wood.shade) c:put(27, 53 + b, P.wood.hi)
  for x = 25, 31 do c:put(x, 58 + b, P.ink) end c:put(24, 57 + b, P.ink) c:put(32, 57 + b, P.ink)
  c:cheek(18, 55 + b) c:cheek(37, 55 + b)
  c:stitch{ { 21, 64 + b }, { 28, 66 + b }, { 35, 64 + b } }
  -- crooked blue hat leaning left, bell on tip
  local hd = p.tip or 0
  local hat = c:ellipse(28, 44 + b, 16.5, 3.5)
  hat:add(c:poly{ { 18, 44 + b }, { 38, 44 + b }, { 31, 24 + b }, { 27, 19 + b } })
  hat:add(c:line({ { 28, 20 + b }, { 25, 14 + b }, { 21 + hd, 11 + b } }, 3))
  c:part(hat, "sea", { band = 2, pop = { 25, 28 + b } })
  for x = 13, 43 do if hat:has(x, 46 + b) and not hat:has(x, 47 + b) then c:put(x, 46 + b, P.sea.deep) end end
  c:stitch{ { 19, 42 + b }, { 28, 43 + b }, { 37, 42 + b } }
  c:put(30, 28 + b, P.sea.shade) c:put(30, 29 + b, P.sea.shade) -- crease
  c:part(c:ellipse(19 + hd, 12 + b + (p.bell or 0), 2, 2), "gold", { band = 1 })
  -- eye stalks through the brim
  local L1 = { 16 - tw, 32 + b + st }
  local R1 = { 40 + tw, 32 + b + st }
  c:part(c:line({ { 22, 49 + b }, { L1[1] + 1, L1[2] + 2 } }, 2), "skinA", { band = 1, nopop = true, sep = true })
  c:part(c:line({ { 34, 49 + b }, { R1[1] - 1, R1[2] + 2 } }, 2), "skinA", { band = 1, nopop = true, sep = true })
  for _, e in ipairs{ L1, R1 } do
    c:part(c:ellipse(e[1] + 0.5, e[2] + 0.5, 3.5, 3.5), "skinA", { band = 1, nopop = true, sep = true })
    if p.blink then for i = -2, 2 do c:put(e[1] + i, e[2] + 1, P.ink) end
    else c:eyeLocked(e[1] - 2, e[2] - 2) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, stalk = 1, tip = 1, bell = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
