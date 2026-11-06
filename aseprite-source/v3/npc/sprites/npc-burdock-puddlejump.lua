-- npc-burdock-puddlejump sprite (npc2 P1_5) species: butterfly
-- Cheerful puddling butterfly-folk: butter face, orange smock, pink cream-spotted wings, brown dome cap with
-- antennae curling out, burdock-leaf parasol over the right shoulder with a dew drop (quirk). Idle 4f.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-burdock-puddlejump"
local BUT = { hi = "#fff0b0", base = "#ffd36a", shade = "#e09a3c", deep = "#8f4a1f" }
local ORA = { hi = "#ffb25c", base = "#f08a2e", shade = "#c25a2a", deep = "#6e2f24" }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry) + 1
  for y = math.floor(cy - R), math.ceil(cy + R) do for x = math.floor(cx - R), math.ceil(cx + R) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  for j = 0, 3 do for i = 0, 3 do if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then c:put(x + i, y + j, P.cream) end end end
  c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ws, ls, tw = p.b or 0, p.ws or 0, p.ls or 0, p.tw or 0
  c:groundShadow(32, 89.5, 12, 2.5)
  -- legs + feet (never move)
  c:part(c:rect(28, 83, 29, 88), P.dusk, { band = 1, nopop = true })
  c:part(c:rect(35, 83, 36, 88), P.dusk, { band = 1, nopop = true })
  c:part(c:ellipse(27.5, 89, 3, 1.5), P.dusk, { band = 1, pop = { x = 26, y = 88 } })
  c:part(c:ellipse(36.5, 89, 3, 1.5), P.dusk, { band = 1, pop = { x = 35, y = 88 } })
  -- burdock leaf parasol behind (stem + broad wavy blade, midrib, veins, dew drop)
  local st = c:line({ { 42, 74 + b }, { 45, 52 + b }, { 48, 34 + b + ls } }, 2)
  c:part(st, P.moss, { band = 1, nopop = true })
  local leaf = oval(50, 27 + b + ls, 11, 7.5, -18)
  for _, q in ipairs{ { 40, 24 }, { 46, 18 }, { 54, 18 }, { 60, 23 }, { 59, 31 }, { 52, 35 } } do leaf:add(c:ellipse(q[1], q[2] + b + ls, 2, 2)) end
  c:part(leaf, P.moss, { band = 2, pop = { x = 42, y = 22 + b + ls } })
  c:fillMask(c:line({ { 48, 34 + b + ls }, { 51, 26 + b + ls }, { 55, 19 + b + ls } }, 1):clip(leaf:shrink(1)), P.moss.hi)
  for _, v in ipairs{ { { 50, 28 }, { 43, 24 } }, { { 52, 24 }, { 47, 18 } }, { { 51, 27 }, { 58, 26 } }, { { 53, 22 }, { 58, 20 } } } do
    c:fillMask(c:line({ { v[1][1], v[1][2] + b + ls }, { v[2][1], v[2][2] + b + ls } }, 1):clip(leaf:shrink(1)), P.moss.shade)
  end
  local dy = 21 + b + ls
  c:put(44, dy, P.sky.base) c:put(44, dy + 1, P.sky.shade) c:put(45, dy + 1, P.sky.shade) c:put(43, dy + 1, P.cream)
  -- wings (upper pair + lower pair) behind the body
  for _, s in ipairs{ -1, 1 } do
    local up = oval(32 + s * 13, 59 + b + ws, 8.5, 6, s * -35)
    local lo = oval(32 + s * 11, 72 + b + ws, 5.5, 4, s * 25)
    c:part(lo, P.petal, { band = 1, nopop = true })
    c:part(up, P.petal, { band = 2, pop = { x = 32 + s * 13 - 4, y = 56 + b + ws } })
    c:fillMask(c:ellipse(32 + s * 18, 57 + b + ws, 1.5, 1.5), P.cream)
    c:put(32 + s * 13, 63 + b + ws, P.cream)
    c:put(32 + s * 12, 73 + b + ws, P.cream)
  end
  -- orange smock body + tiny arms
  local body = c:ellipse(32, 76 + b, 9.5, 8.5)
  c:part(body, ORA, { band = 2, pop = { x = 26, y = 71 + b } })
  for x = 25, 39 do if body:has(x, 84 + b) and (x % 3 ~= 0) then c:put(x, 83 + b, ORA.deep) end end
  c:fillMask(c:line({ { 27, 69 + b }, { 32, 73 + b }, { 37, 69 + b } }, 1), P.wood.deep)
  c:put(32, 74 + b, P.sky.base) c:put(32, 75 + b, P.sky.shade) c:put(31, 74 + b, P.cream)
  c:part(c:ellipse(22.5, 76 + b, 2.5, 3), BUT, { band = 1, nopop = true })
  c:part(c:ellipse(41.5, 73 + b, 2.5, 2.5), BUT, { band = 1, nopop = true })
  -- head
  c:part(c:ellipse(32, 48 + b, 12.5, 10), BUT, { band = 2, pop = { x = 24, y = 44 + b } })
  -- dome cap: wavy brim, round dome, acorn nub
  local hb = p.hb or 0
  local hat = c:ellipse(32, 40 + b + hb, 15, 3)
  hat:add(c:ellipse(32, 35 + b + hb, 10, 7):clip(c:rect(0, 0, 63, 40 + b + hb)))
  hat:add(c:ellipse(32, 27 + b + hb, 2, 2))
  c:part(hat, P.wood, { band = 2, pop = { x = 26, y = 31 + b + hb } })
  c:stitch{ { 23, 38 + b + hb }, { 41, 38 + b + hb } }
  for x = 18, 46 do if hat:has(x, 42 + b + hb) and not hat:has(x, 43 + b + hb) then c:put(x, 42 + b + hb, P.wood.deep) end end
  -- antenna tips (stalks after outline)
  c:part(c:ellipse(21, 19 + b, 1.5, 1.5), P.dusk, { band = 1, pop = { x = 20, y = 18 + b } })
  c:part(c:ellipse(43 + tw, 19 + b - tw, 1.5, 1.5), P.dusk, { band = 1, pop = { x = 42 + tw, y = 18 + b - tw } })
  -- face
  eye(c, 25, 46 + b, p.blink) eye(c, 35, 46 + b, p.blink)
  c:put(32, 50 + b, ORA.shade) c:put(31, 51 + b, ORA.shade) c:put(32, 51 + b, ORA.deep)
  for _, q in ipairs{ { 29, 53 }, { 30, 54 }, { 31, 54 }, { 32, 54 }, { 33, 54 }, { 34, 53 } } do c:put(q[1], q[2] + b, P.ink) end
  c:cheek(23, 51 + b) c:cheek(39, 51 + b)
  c:finish{ outline = true }
  c:fillMask(c:line({ { 28, 30 + b }, { 25, 25 + b }, { 22, 21 + b } }, 1), P.ink)
  c:fillMask(c:line({ { 36, 30 + b }, { 40, 25 + b }, { 42 + tw, 21 + b - tw } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, ws = 1, ls = 1, hb = 0 }, { b = 0 }, { b = 0, blink = true, tw = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
