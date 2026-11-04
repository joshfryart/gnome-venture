-- here-haven: rest haven beside a calm evening lake. 480x270, horizon y112.
-- Planes: sky (4 warm bands, low sun, puffs) / far dusk hills + lake / mid: willow, jetty, tent, shop stall,
-- campfire with log bench / near: bushes, mossy boulder, flower clump, apple basket.
-- Heroes: campfire (240,170), shop stall (140,156), jetty. Quirk: the jetty fishing rod has hooked an old boot.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "here-haven" }
local floor, sin, sqrt, abs = math.floor, math.sin, math.sqrt, math.abs
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function H(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end

local EX = { {240,118}, {372,128}, {452,176}, {396,236}, {240,258}, {84,236}, {28,176}, {108,128} }
local ST = { {200,200}, {280,206}, {120,214}, {360,214}, {240,226}, {50,214} }
local function speckle(m, ramp, seed, a, b)
  m:each(function(x, y)
    local h = H(x, y, seed)
    if h < (a or .07) then c:px(x, y, ramp.hi) elseif h < (b or .15) then c:px(x, y, ramp.shade) end
  end)
end

------------------------------------------------------------ SKY (4 flat bands, darkest on top)
c:stripes(0, 111, { P.dusk.base, P.dusk.hi, P.petal.hi, P.gold.hi }, { 3, 3, 3, 3 })
-- low sun
c:fillMask(E(392, 74, 13, 13), P.gold.base) c:fillMask(E(392, 74, 10, 10), P.gold.hi) c:fillMask(E(390, 72, 6, 6), P.cream)
-- puff clouds
c:cloud(40, 34, 46, P.petal.hi, P.dusk.hi)
c:cloud(180, 22, 34, P.petal.hi, P.dusk.hi)
c:cloud(282, 52, 26, P.cream, P.petal.hi)
c:cloud(420, 30, 40, P.petal.hi, P.dusk.hi)
c:cloud(118, 60, 22, P.cream, P.petal.hi)

------------------------------------------------------------ FAR hills (low contrast) + lake
c:terrain(function(x) return 76 + 7 * sin(x / 47 + 1) + 3 * sin(x / 17) end, P.dusk.hi, 96)
local function ridge(x)
  local y = 88 + 3 * sin(x / 29 + 2) + 1.5 * sin(x / 7)
  local k = (x % 11) local b = abs(k - 5) if b < 4 and floor(x / 11) % 3 ~= 1 then y = y - (4 - b) end
  return y
end
c:terrain(ridge, P.dusk.base, 96)
-- lake
R(0, 96, 479, 111, P.sea.base)
R(0, 96, 479, 97, P.sea.shade)
for i = 0, 40 do
  local y = 99 + (i * 7) % 12 local x = floor(H(i, 3, 1) * 470)
  R(x, y, x + 4 + (i % 5), y, (i % 3 == 0) and P.petal.hi or P.sea.hi)
end
for y = 99, 110, 2 do local w = 3 + (y - 99) // 2 R(392 - w, y, 392 + w, y, P.gold.hi) c:px(392 - w - 3, y, P.gold.hi) end
-- lily pads
for _, l in ipairs{ {168, 105}, {180, 108}, {428, 103}, {440, 107} } do
  c:fillMask(E(l[1], l[2], 4, 1), P.moss.shade) c:fillMask(E(l[1] - 1, l[2], 3, 1), P.moss.base) c:px(l[1] + 2, l[2], P.sea.base)
end
c:px(181, 107, P.petal.hi) c:px(180, 107, P.petal.base)

------------------------------------------------------------ GROUND
R(0, 112, 479, 269, P.moss.base)
R(0, 112, 479, 113, P.wood.hi)
for x = 0, 479, 5 do if H(x, 1, 9) < .5 then c:px(x + 1, 113, P.stone.base) end end
R(0, 114, 479, 114, P.moss.shade)
-- foreground corners darker
c:terrain(function(x) return 250 + 12 * sin(x / 60) + 5 * sin(x / 13) end, P.moss.shade)

------------------------------------------------------------ PLAZA + PATHS
local paths = HP.mask()
paths:add(E(240, 200, 118, 32))
local hub = { 240, 198 }
for _, a in ipairs(EX) do
  local dx, dy = a[1] - hub[1], a[2] - hub[2]
  local len = sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local t = 400
  if uy < 0 then t = math.min(t, (114 - a[2]) / uy) end
  if uy > 0 then t = math.min(t, (275 - a[2]) / uy) end
  if ux > 0 then t = math.min(t, (485 - a[1]) / ux) end
  if ux < 0 then t = math.min(t, (-5 - a[1]) / ux) end
  paths:add(c:line({ hub, { a[1], a[2] }, { a[1] + ux * t, a[2] + uy * t } }, 8))
  paths:add(E(a[1], a[2], 22, 16))
end
paths:clip(c:rect(0, 113, 479, 269))
c:fillMask(paths, P.wood.hi)
c:edgeIn(paths:copy():clip(c:rect(0, 115, 479, 269)), P.wood.base)
-- warm fire glow on the plaza
c:fillMask(E(240, 178, 34, 11), P.gold.hi)

------------------------------------------------------------ free-ground test + scatter
local function free(x, y, pad)
  pad = pad or 2
  for _, a in ipairs(EX) do if (x - a[1]) ^ 2 + (y - a[2]) ^ 2 < (30 + pad) ^ 2 then return false end end
  for _, s in ipairs(ST) do if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 < (28 + pad) ^ 2 then return false end end
  return true
end
for y = 117, 266, 3 do
  for x = 2, 477, 4 do
    local jx, jy = x + floor(H(x, y, 2) * 3), y + floor(H(x, y, 4) * 2)
    if free(jx, jy, 3) and free(jx + 3, jy + 3, 3) then
      local h = H(jx, jy, 7)
      if paths:has(jx, jy) or paths:has(jx + 2, jy + 1) then
        if h < .12 then c:px(jx, jy, P.wood.base) c:px(jx + 1, jy, P.wood.hi) end
      elseif h < .30 then
        local col = jy > 230 and P.moss.deep or P.moss.shade
        c:px(jx, jy, col) c:px(jx - 1, jy - 1, P.moss.hi) c:px(jx + 1, jy - 1, col) c:px(jx, jy - 1, P.moss.base)
      elseif h < .38 then
        local f = ({ P.petal, P.gold, P.dusk })[1 + floor(H(jx, jy, 3) * 3)]
        c:px(jx, jy, f.base) c:px(jx, jy - 1, f.hi) c:px(jx + 1, jy, f.shade) c:px(jx, jy + 1, P.moss.shade)
      elseif h < .44 then
        R(jx, jy, jx + 2, jy, P.stone.hi) R(jx, jy + 1, jx + 2, jy + 1, P.stone.shade)
      elseif h < .50 then
        c:fillMask(E(jx, jy, 3, 1), P.moss.shade) c:px(jx - 1, jy - 1, P.moss.hi)
      end
    end
  end
end

------------------------------------------------------------ WILLOW (mid, left)
do
  local tr = c:poly{ {28, 142}, {50, 142}, {44, 134}, {42, 70}, {34, 70}, {33, 134} }
  local cr = E(40, 50, 40, 24):add(E(14, 70, 18, 14)):add(E(66, 66, 14, 12)):add(E(30, 30, 18, 12))
  local strands = HP.mask()
  for x = 2, 74, 4 do
    local yb = 96 + floor(H(x, 5, 1) * 26)
    strands:add(c:line({ { x, 60 }, { x + 1, yb } }, 2))
  end
  strands:clip(c:rect(0, 0, 76, 124))
  c:fillMask(E(40, 143, 18, 3), P.moss.shade)
  c:rim(tr:copy():add(cr):add(strands), P.moss.deep)
  c:part(tr, "wood", { band = 2, nopop = true })
  for y = 78, 136, 6 do c:px(36 + (y // 6) % 3, y, P.wood.shade) c:px(37 + (y // 6) % 3, y + 1, P.wood.shade) c:px(40, y + 3, P.wood.deep) end
  c:part(strands:copy():cut(tr), "moss", { band = 1, nopop = true, inner = false })
  strands:each(function(x, y) if y % 4 == 0 and not tr:has(x, y) then c:px(x, y, P.moss.hi) end end)
  c:part(cr, "moss", { band = 3, pop = { 22, 34 } })
  speckle(cr, P.moss, 11)
end

------------------------------------------------------------ reeds
local function reeds(x0, x1, yb, seed)
  for x = x0, x1, 3 do
    local h = 8 + floor(H(x, seed, 1) * 10)
    local lx = x + floor(H(x, seed, 2) * 2)
    R(lx, yb - h, lx, yb, P.moss.shade) c:px(lx, yb - h, P.moss.hi)
    if H(x, seed, 3) < .4 then R(lx, yb - h - 1, lx + 1, yb - h + 3, P.wood.shade) c:px(lx, yb - h - 1, P.wood.base) end
    if H(x, seed, 4) < .5 then c:px(lx - 1, yb - 3, P.moss.base) c:px(lx - 2, yb - 5, P.moss.base) end
  end
end
reeds(146, 204, 116, 1) reeds(318, 340, 116, 2) reeds(460, 478, 118, 3) reeds(0, 26, 116, 4)

------------------------------------------------------------ JETTY (hero) + rowboat + QUIRK boot
do
  local deck = c:rect(294, 98, 308, 118)
  c:fillMask(c:rect(292, 112, 310, 113), P.sea.shade)
  for _, p in ipairs{ {292, 100}, {309, 100}, {292, 108}, {309, 108} } do
    R(p[1], p[2], p[1] + 1, p[2] + 4, P.wood.deep) c:px(p[1], p[2] + 5, P.sea.shade)
  end
  c:rim(deck, P.wood.deep)
  c:part(deck, "wood", { band = 2, nopop = true })
  for y = 100, 117, 3 do R(294, y, 308, y, P.wood.shade) c:px(296 + (y % 7), y - 1, P.wood.hi) end
  -- jetty lantern post
  R(306, 84, 307, 99, P.wood.deep) R(302, 84, 307, 84, P.wood.deep)
  c:rim(c:rect(301, 86, 304, 91), P.gold.deep) c:fillMask(c:rect(301, 86, 304, 91), P.gold.base)
  R(302, 87, 303, 89, P.gold.hi)
  -- rowboat tied alongside
  local hull = c:poly{ {314, 101}, {340, 101}, {336, 107}, {318, 107} }
  c:rim(hull, P.ember.deep) c:part(hull, "ember", { band = 1, nopop = true })
  R(316, 101, 338, 101, P.wood.hi) R(325, 102, 327, 104, P.wood.base)
  c:px(309, 103, P.wood.base) c:px(311, 103, P.wood.base) c:px(313, 102, P.wood.base)
  R(318, 108, 336, 108, P.sea.shade)
  -- fishing rod, line hooked to an old boot dangling over the water
  c:fillMask(c:line({ { 299, 108 }, { 282, 84 } }, 1), P.wood.deep)
  for y = 85, 98 do c:px(281 - (y - 85) // 7, y, P.stone.hi) end
  local boot = c:poly{ {277, 98}, {282, 98}, {282, 104}, {286, 104}, {286, 107}, {276, 107} }
  c:rim(boot, P.wood.deep) c:part(boot, "wood", { band = 1, nopop = true })
  R(277, 99, 281, 99, P.wood.hi) c:px(278, 101, P.cream) c:px(279, 102, P.cream)
  c:px(275, 109, P.sea.hi) c:px(284, 110, P.sea.hi) c:px(280, 109, P.sea.hi)
end

------------------------------------------------------------ TENT (mid, right)
do
  local t = c:poly{ {412, 146}, {435, 118}, {458, 146} }
  c:fillMask(E(436, 147, 24, 2), P.moss.shade)
  c:fillMask(c:line({ { 413, 145 }, { 404, 148 } }, 1), P.wood.base) c:fillMask(c:line({ { 457, 145 }, { 466, 148 } }, 1), P.wood.base)
  c:rim(t, P.gold.deep) c:part(t, "gold", { band = 3, pop = { 428, 130 } })
  c:fillMask(c:poly{ {429, 146}, {435, 130}, {441, 146} }, P.dusk.deep)
  c:fillMask(c:poly{ {435, 130}, {441, 146}, {444, 146} }, P.gold.shade)
  R(434, 115, 435, 119, P.wood.deep) c:px(436, 115, P.ember.base) c:px(437, 116, P.ember.base)
  c:fillMask(c:rect(418, 136, 423, 139), P.ember.base) c:px(418, 136, P.ember.hi) -- patch
end

------------------------------------------------------------ lantern posts
local function lantern(x, yb, h)
  c:fillMask(E(x + 1, yb, 4, 1), P.moss.shade)
  R(x, yb - h, x + 1, yb, P.wood.deep) R(x, yb - h, x + 7, yb - h + 1, P.wood.deep)
  local box = c:rect(x + 4, yb - h + 4, x + 9, yb - h + 11)
  c:rim(box, P.gold.deep) c:fillMask(box, P.gold.base)
  R(x + 5, yb - h + 5, x + 7, yb - h + 9, P.gold.hi) c:px(x + 5, yb - h + 5, P.cream)
  R(x + 6, yb - h + 2, x + 6, yb - h + 3, P.wood.deep)
end
lantern(184, 156, 28) lantern(318, 150, 28)

------------------------------------------------------------ BUCKET by the shore
do
  local b = c:rect(328, 120, 335, 128)
  c:rim(b, P.stone.deep) c:part(b, "stone", { band = 1, nopop = true })
  R(329, 120, 334, 121, P.sea.base) c:px(330, 120, P.sea.hi)
  R(328, 124, 335, 124, P.stone.shade)
end

------------------------------------------------------------ SHOP STALL (hero), centred (140,156)
do
  c:fillMask(E(144, 175, 22, 3), P.moss.shade)
  local posts = c:rect(130, 142, 132, 158):add(c:rect(156, 142, 158, 158))
  local counter = c:rect(127, 156, 161, 174)
  local top = c:rect(125, 153, 163, 156)
  local awn = c:poly{ {128, 136}, {160, 136}, {164, 146}, {124, 146} }
  local scal = HP.mask() for x = 126, 162, 6 do scal:add(E(x, 147, 3, 2)) end
  awn:add(scal)
  local all = posts:copy():add(counter):add(top):add(awn)
  c:rim(all, P.wood.deep)
  c:part(posts, "wood", { band = 1, nopop = true })
  c:part(counter, "wood", { band = 2, nopop = true })
  for y = 160, 172, 4 do R(128, y, 160, y, P.wood.shade) end
  for _, x in ipairs{ 138, 151 } do c:px(x, 158, P.wood.hi) c:px(x + 1, 166, P.wood.hi) end
  c:part(top, "wood", { band = 1, pop = { 127, 153, horizontal = true } })
  -- striped awning with tile-like courses
  c:fillMask(awn, P.cream)
  awn:each(function(x, y) if ((x - (y - 136) // 3) // 6) % 2 == 0 then c:px(x, y, P.petal.base) end end)
  R(128, 141, 163, 141, P.petal.shade)
  awn:each(function(x, y) if not awn:has(x, y + 1) or not awn:has(x + 1, y) then c:px(x, y, P.petal.shade) end end)
  -- goods: jars, loaves, apples
  for i, x in ipairs{ 129, 134 } do
    local j = c:rect(x, 147, x + 3, 152)
    c:rim(j, P.sea.deep) c:fillMask(j, P.sea.base) R(x, 147, x + 3, 147, P.wood.base) c:px(x, 149, P.sea.hi)
    R(x + 1, 150, x + 2, 152, i == 1 and P.gold.base or P.ember.base)
  end
  c:part(E(144, 151, 4, 2), "gold", { band = 1 }) c:px(143, 150, P.gold.shade) c:px(145, 150, P.gold.shade)
  for _, a in ipairs{ {151, 151}, {154, 151}, {157, 151}, {155, 149} } do R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) c:px(a[1], a[2], P.ember.hi) end
  -- hanging sign with a teacup
  local sg = c:rect(137, 162, 151, 169)
  c:rim(sg, P.wood.deep) c:fillMask(sg, P.cream) R(137, 169, 151, 169, P.stone.hi)
  R(141, 164, 146, 167, P.sea.shade) R(147, 165, 148, 166, P.sea.shade) R(142, 164, 145, 164, P.sea.hi)
  -- little lantern under the awning
  R(161, 148, 161, 150, P.wood.deep) c:rim(c:rect(160, 151, 163, 155), P.gold.deep) c:fillMask(c:rect(160, 151, 163, 155), P.gold.hi)
  -- crate beside it
  local cr = c:rect(164, 164, 172, 174)
  c:rim(cr, P.wood.deep) c:part(cr, "wood", { band = 1, nopop = true })
  R(164, 169, 172, 169, P.wood.shade) c:fillMask(E(168, 163, 3, 1), P.moss.base) c:px(167, 162, P.moss.hi)
end

------------------------------------------------------------ CAMPFIRE (hero) + bench + stump
do
  -- stump seat (left)
  local st = c:rect(198, 160, 211, 170):add(E(204.5, 160, 6.5, 3))
  c:fillMask(E(205, 171, 9, 2), P.wood.base)
  c:rim(st, P.wood.deep) c:part(st, "wood", { band = 2, nopop = true })
  c:fillMask(E(204.5, 159, 5.5, 2), P.wood.hi) c:fillMask(E(204.5, 159, 3, 1), P.gold.hi) c:px(204, 159, P.wood.base)
  for y = 163, 169, 3 do c:px(201 + y % 2, y, P.wood.shade) c:px(207, y + 1, P.wood.shade) end
  -- log bench (right)
  local lg = c:rrect(262, 158, 302, 168, 4)
  c:fillMask(E(283, 169, 22, 2), P.wood.base)
  c:rim(lg, P.wood.deep) c:part(lg, "wood", { band = 3, nopop = true })
  for x = 268, 300, 5 do R(x, 160 + (x % 3), x + 2, 160 + (x % 3), P.wood.shade) c:px(x + 1, 165 - (x % 2), P.wood.deep) end
  R(268, 159, 296, 159, P.wood.hi)
  c:fillMask(E(264, 163, 2, 4), P.wood.hi) c:px(264, 163, P.wood.base)
  -- teapot and mug on the bench
  local tp = E(290, 154, 5, 4):add(c:line({ { 295, 154 }, { 298, 151 } }, 1))
  c:rim(tp, P.sea.deep) c:part(tp, "sea", { band = 1, pop = { 287, 152 } }) R(289, 149, 291, 150, P.sea.shade)
  local mug = c:rect(272, 152, 275, 157)
  c:rim(mug, P.ember.deep) c:part(mug, "ember", { band = 1, nopop = true }) c:px(276, 154, P.ember.deep)
  -- fire: ring of stones, crossed logs, flames
  for i = 0, 11 do
    local a = i / 12 * 6.283
    local sx, sy = 240 + 16 * math.cos(a), 177 + 6 * math.sin(a)
    if sy > 172 or i % 2 == 0 then
      local s = E(sx, sy, 3, 2)
      c:rim(s, P.stone.deep) c:part(s, "stone", { band = 1, nopop = i % 3 ~= 0, inner = false })
    end
  end
  c:fillMask(E(240, 177, 11, 4), P.ember.deep)
  for _, e in ipairs{ {234, 177}, {244, 178}, {239, 179}, {247, 176} } do c:px(e[1], e[2], P.ember.base) end
  local logs = c:line({ { 229, 180 }, { 251, 172 } }, 3):add(c:line({ { 229, 172 }, { 251, 180 } }, 3))
  c:rim(logs, P.wood.deep) c:part(logs, "wood", { band = 1, nopop = true })
  c:px(229, 180, P.wood.hi) c:px(251, 180, P.wood.hi)
  local fl = c:poly{ {229, 176}, {231, 166}, {234, 170}, {236, 156}, {240, 166}, {243, 150}, {246, 165}, {249, 160}, {252, 176} }
  local f2 = c:poly{ {233, 176}, {236, 165}, {239, 170}, {243, 158}, {246, 170}, {248, 166}, {249, 176} }
  local f3 = c:poly{ {237, 176}, {240, 168}, {243, 164}, {245, 176} }
  c:rim(fl, P.ember.deep)
  c:fillMask(fl, P.ember.base) c:fillMask(f2, P.gold.base) c:fillMask(f3, P.gold.hi)
  c:px(242, 170, P.cream) c:px(242, 171, P.cream)
  for _, s in ipairs{ {234, 152}, {248, 151}, {251, 156}, {231, 158} } do c:px(s[1], s[2], P.ember.hi) end
  c:px(246, 148, P.gold.hi)
  -- roasting stick with a mushroom
  c:fillMask(c:line({ { 212, 168 }, { 226, 163 } }, 1), P.wood.shade)
  local mc = E(227, 161, 3, 2)
  c:rim(mc, P.ember.deep) c:fillMask(mc, P.wood.hi) c:px(226, 160, P.cream) c:px(228, 162, P.wood.base)
end

------------------------------------------------------------ WOODPILE + axe stump (right of plaza)
do
  local pile = HP.mask()
  local logs = {}
  for row = 0, 2 do for i = 0, 3 - row do
    local lx, ly = 334 + i * 7 + row * 3, 180 - row * 6
    logs[#logs + 1] = { lx, ly } pile:add(E(lx, ly, 3, 3))
  end end
  pile:add(c:rect(331, 174, 361, 182))
  c:fillMask(E(347, 184, 17, 2), P.moss.shade)
  c:rim(pile, P.wood.deep) c:fillMask(pile, P.wood.shade)
  for _, l in ipairs(logs) do c:fillMask(E(l[1], l[2], 3, 3), P.wood.hi) c:fillMask(E(l[1], l[2], 1, 1), P.wood.base) c:px(l[1] - 2, l[2] - 1, P.gold.hi) end
  local st = c:rect(318, 178, 326, 186):add(E(322, 178, 4, 2))
  c:rim(st, P.wood.deep) c:part(st, "wood", { band = 1, nopop = true })
  c:fillMask(E(322, 177, 3, 1), P.wood.hi)
  c:fillMask(c:line({ { 322, 176 }, { 314, 168 } }, 1), P.wood.base)
  local head = c:rect(321, 174, 324, 177) c:fillMask(head, P.stone.base) c:px(321, 174, P.stone.hi)
end

------------------------------------------------------------ SIGNPOST + bedroll on the plaza edge
do
  R(165, 228, 166, 248, P.wood.deep) c:fillMask(E(166, 249, 4, 1), P.wood.base)
  local a1 = c:poly{ {158, 229}, {173, 229}, {176, 232}, {173, 235}, {158, 235} }
  local a2 = c:poly{ {155, 239}, {158, 236}, {173, 236}, {173, 242}, {158, 242} }
  c:rim(a1:copy():add(a2), P.wood.deep)
  c:part(a1, "wood", { band = 1, nopop = true }) c:part(a2, "wood", { band = 1, nopop = true })
  R(161, 232, 170, 232, P.wood.shade) R(160, 239, 168, 239, P.wood.shade)
  -- bedroll
  local br = c:rrect(302, 236, 322, 244, 4)
  c:fillMask(E(312, 245, 11, 1), P.wood.base)
  c:rim(br, P.dusk.deep) c:part(br, "dusk", { band = 1, pop = { 305, 237, horizontal = true } })
  R(308, 236, 309, 244, P.wood.shade) R(316, 236, 317, 244, P.wood.shade)
  c:fillMask(E(303, 240, 2, 3), P.dusk.hi) c:px(303, 240, P.dusk.shade)
end

------------------------------------------------------------ NEAR: bushes, boulder, mushrooms, basket, flowers
local NEAR = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.ink }
local function bush(m, seed, flowers, pop)
  c:rim(m, P.moss.deep)
  c:part(m, NEAR, { band = 3, pop = pop })
  speckle(m, { hi = P.moss.base, shade = P.moss.deep }, seed, .08, .14)
  for i = 1, #flowers do local f = flowers[i]
    c:px(f[1], f[2], f[3].base) c:px(f[1] - 1, f[2], f[3].hi) c:px(f[1] + 1, f[2], f[3].shade) c:px(f[1], f[2] - 1, f[3].hi)
  end
end
bush(E(12, 262, 32, 16):add(E(40, 268, 14, 7)), 21,
  { {10, 254, P.petal}, {22, 258, P.petal}, {4, 262, P.gold}, {30, 264, P.petal}, {16, 266, P.cream and P.gold} }, { 2, 250 })
bush(E(468, 254, 30, 20):add(E(442, 268, 14, 7)), 22,
  { {456, 246, P.gold}, {468, 250, P.gold}, {450, 258, P.petal}, {474, 262, P.gold}, {462, 264, P.petal} }, { 446, 242 })
-- mossy boulder + mushrooms (bottom left-centre)
do
  local b = E(170, 264, 22, 11)
  c:rim(b, P.stone.deep) c:part(b, "stone", { band = 3, pop = { 156, 256 } })
  local mo = E(166, 255, 15, 4):clip(b)
  c:fillMask(mo, P.moss.base) speckle(mo, P.moss, 31, .15, .3)
  for _, s in ipairs{ {178, 262}, {184, 266}, {160, 266} } do c:px(s[1], s[2], P.stone.shade) c:px(s[1] + 1, s[2] + 1, P.stone.shade) end
  for _, m in ipairs{ {144, 262, 4}, {136, 265, 3}, {198, 262, 3} } do
    local cap = E(m[1], m[2] - 2, m[3], 2):clip(c:rect(0, 0, 479, m[2] - 1))
    R(m[1], m[2] - 1, m[1], m[2] + 3, P.cream)
    c:rim(cap, P.ember.deep) c:fillMask(cap, P.ember.base) c:px(m[1] - 1, m[2] - 3, P.cream) c:px(m[1] + 1, m[2] - 2, P.ember.hi)
  end
end
-- basket of apples + wildflower clump (bottom right-centre)
do
  local bk = c:poly{ {286, 252}, {306, 252}, {303, 264}, {289, 264} }
  local apples = E(291, 251, 3, 3):add(E(297, 250, 3, 3)):add(E(302, 251, 3, 3))
  c:fillMask(E(296, 265, 12, 2), P.moss.deep)
  c:rim(bk:copy():add(apples), P.wood.deep)
  c:part(apples, "ember", { band = 1, sep = true, pop = { 296, 248 } })
  c:part(bk, "wood", { band = 1, nopop = true })
  for y = 254, 263, 3 do R(288, y, 304, y, P.wood.shade) end
  for x = 290, 302, 4 do R(x, 253, x, 263, P.wood.hi) end
  c:fillMask(c:line({ { 288, 252 }, { 296, 243 }, { 304, 252 } }, 1), P.wood.shade)
  local fc = E(340, 264, 24, 8)
  c:rim(fc, P.moss.deep) c:part(fc, NEAR, { band = 2, nopop = true }) speckle(fc, { hi = P.moss.base, shade = P.moss.deep }, 41)
  for i = 0, 8 do
    local fx, fy = 322 + i * 4 + (i % 2), 258 + (i * 5) % 7
    local f = (i % 3 == 0) and P.dusk or P.gold
    R(fx, fy, fx, fy + 3, P.moss.shade)
    c:px(fx, fy - 1, f.base) c:px(fx - 1, fy, f.base) c:px(fx + 1, fy, f.shade) c:px(fx, fy + 1, f.shade) c:px(fx, fy, P.gold.hi)
  end
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "here-haven.aseprite", png = out .. "here-haven.png", scale = 1 }
