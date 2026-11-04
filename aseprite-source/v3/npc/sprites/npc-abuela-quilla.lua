-- npc-abuela-quilla sprite (npc2 P1_0) species: alpaca
-- Abuela Quilla: elder alpaca grandma. Fawn fleece, silver wool braids, brown bowler with red band and a gold
-- feather, red aguayo shawl with gold/teal/pink stripes. Prop: drop spindle with teal yarn hanging from her hoof.
-- Idle 4f (64x96 cells): base / breath (1px lower, ears droop, feather + spindle settle) / base / left ear flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-abuela-quilla"
local FLE = { hi = "#f7e2b8", base = "#dcb184", shade = "#a97c74", deep = "#6a4a5e" }
local MUZ = { hi = "#fff4d6", base = "#f3d9ae", shade = "#cfa594", deep = "#7f5a66" }
local HAT = { hi = "#9c6a52", base = "#6e4638", shade = "#4e3044", deep = "#38223a" }
local HOOF = { hi = "#8a6a6a", base = "#5e4250", shade = "#45304a", deep = "#38223a" }
local SHW = P.ember
local function D(c, x, y, hex) c:put(x, y, hex, c.own[y * c.w + x] or "d") end
local function restrip(c, m, y0, y1, r, from)
  m:each(function(x, y) if y >= y0 and y <= y1 then
    local v = c:get(x, y)
    local t = (v == from.hi and "hi") or (v == from.base and "base") or (v == from.shade and "shade")
    if t then D(c, x, y, r[t]) end end end)
end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do D(c, x + i, y + 2, P.ink) end return end
  D(c, x + 1, y, P.ink) D(c, x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} } do D(c, x + q[1], y + q[2], P.cream) end
  D(c, x + 2, y + 1, P.ink) D(c, x + 1, y + 2, P.ink) D(c, x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, s = p.b or 0, p.sp or 0
  c:groundShadow(32, 89, 13, 2.5)
  -- legs + hooves (never move)
  for _, x in ipairs{ 27, 37 } do
    c:part(c:rect(x - 2, 82, x + 2, 87), FLE, { nopop = true })
    c:part(c:ellipse(x, 88, 3, 1.5), HOOF, { nopop = true })
  end
  -- woolly pear body with scalloped fleece hem
  local body = c:ellipse(32, 72 + b, 13, 11)
  for _, x in ipairs{ 22, 27, 32, 37, 42 } do body:add(c:ellipse(x, 81 + b, 2.5, 2.5)) end
  c:part(body, FLE, { band = 2 })
  -- aguayo shawl, pointed at front, woven stripes
  local sh = c:poly{ {19,58+b},{45,58+b},{48,68+b},{32,78+b},{16,68+b} }
  c:part(sh, SHW, { band = 2 })
  restrip(c, sh, 61 + b, 62 + b, P.gold, SHW)
  restrip(c, sh, 65 + b, 65 + b, P.sea, SHW)
  restrip(c, sh, 68 + b, 69 + b, P.petal, SHW)
  for x = 20, 44, 4 do if c:get(x, 61 + b) == P.gold.base then D(c, x, 61 + b, P.cream) D(c, x, 62 + b, P.ember.base) end end
  c:part(c:rect(31, 78 + b, 33, 80 + b), P.gold, { nopop = true })
  -- tiny arms, dark hoof hands
  c:part(c:ellipse(18, 68 + b, 2.5, 4), FLE, { nopop = true })
  c:part(c:ellipse(46, 68 + b, 2.5, 4), FLE, { nopop = true })
  c:part(c:ellipse(18, 72 + b, 2, 1.5), HOOF, { nopop = true })
  -- drop spindle hanging from the right hoof (prop)
  c:part(c:line({ {46, 73 + b}, {47 + s, 86 + b} }, 1), P.wood, { nopop = true, noshade = true })
  c:part(c:ellipse(46.5 + s * 0.5, 78 + b, 2, 2.5), P.sea, { band = 1, pop = { 45 + s, 77 + b } })
  D(c, 47, 79 + b, P.sea.shade) D(c, 46, 80 + b, P.sea.shade)
  c:part(c:ellipse(47 + s, 83.5 + b, 3, 1), P.wood, { band = 1, nopop = true })
  c:part(c:ellipse(46, 72 + b, 2, 1.5), HOOF, { nopop = true })
  -- silver wool braids with red ties
  for _, q in ipairs{ {23, 21}, {41, 43} } do
    c:part(c:line({ {q[1], 46 + b}, {q[2], 58 + b} }, 3), P.stone, { nopop = true, band = 1 })
    for y = 49, 57, 3 do local x = math.floor(q[1] + (q[2] - q[1]) * (y - 46) / 12 + .5) D(c, x, y + b, P.stone.shade) end
    c:part(c:ellipse(q[2], 60 + b, 1.5, 1.5), P.ember, { nopop = true })
  end
  -- banana ears (behind head), left can flick
  local eL, et = p.eL or 0, p.et or 0
  local earL = c:line({ {24, 40 + b}, {20, 32 + b}, {19 + eL, 25 + b + et + (p.eLy or 0)} }, 4)
  local earR = c:line({ {40, 40 + b}, {44, 32 + b}, {45, 25 + b + et} }, 4)
  c:part(earL, FLE, { band = 1, nopop = true }) c:part(earR, FLE, { band = 1, nopop = true })
  for _, q in ipairs{ {20 + eL, 28 + et + (p.eLy or 0)}, {20, 30}, {21, 32} } do D(c, q[1], q[2] + b, MUZ.shade) end
  for _, q in ipairs{ {44, 28 + et}, {44, 30}, {43, 32} } do D(c, q[1], q[2] + b, MUZ.shade) end
  -- head + fleece tufts poking under the brim
  local head = c:ellipse(32, 44 + b, 11, 9.5)
  head:add(c:ellipse(22.5, 38 + b, 2, 1.5)) head:add(c:ellipse(41.5, 38 + b, 2, 1.5))
  c:part(head, FLE, { band = 2, pop = { 24, 38 + b } })
  -- muzzle, split lip, nostrils
  c:part(c:ellipse(32, 50 + b, 6, 4), MUZ, { band = 1, pop = { 28, 47 + b } })
  for _, q in ipairs{ {30,48},{34,48},{32,49},{32,50},{31,51},{33,51} } do D(c, q[1], q[2] + b, MUZ.deep) end
  eye(c, 24, 40 + b, p.blink) eye(c, 36, 40 + b, p.blink)
  D(c, 23, 40 + b, FLE.deep) D(c, 40, 40 + b, FLE.deep) -- lashes
  for _, x in ipairs{ 22, 23, 41, 42 } do D(c, x, 45 + b, P.petal.base) end
  -- bowler hat with red band + gold feather
  local hm = c:rrect(26, 26 + b, 38, 35 + b, 4)
  hm:add(c:ellipse(32, 35.5 + b, 10.5, 2))
  c:part(hm, HAT, { band = 2, pop = { 28, 28 + b } })
  restrip(c, hm:copy():clip(c:rect(26, 31 + b, 38, 32 + b)), 31 + b, 32 + b, P.ember, HAT)
  for x = 24, 40 do if c:get(x, 34 + b) == HAT.base then D(c, x, 34 + b, HAT.shade) end end
  local fh = p.fh or 0
  c:part(c:line({ {37, 31 + b}, {40, 26 + b}, {43 + fh, 21 + b + fh} }, 2), P.gold, { band = 1, nopop = true })
  D(c, 43 + fh, 21 + b + fh, P.ember.base) D(c, 42 + fh, 21 + b + fh, P.ember.base) D(c, 39, 27 + b, P.gold.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, et = 1, fh = 1, sp = 1 }, { b = 0 }, { b = 0, eL = -1, eLy = 1, sp = -1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
