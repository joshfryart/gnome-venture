-- here-village: the "Here" picture for kind village. 480x270 native (layout here_layouts.json 'village').
-- A small forest village: three cottages (tiled hero cottage at 'homes', slate cottage, turf-roof
-- cottage) among two big oaks, a wishing well ('people'), a raised vegetable bed ('garden'), a
-- 'do here' crafting corner (pegboard, workbench, sawhorse), a wild trail into a dark wood on the
-- right edge ('wild'). Planes: sky (4 bands, sun, puffs) / far hills + forest edge / mid village /
-- near framing tree, bushes, mossy log. Vignettes: smoking chimney, rain barrel, lean-to woodpile,
-- flower pots, beehive skep + sunflower, mailbox stuffed with letters, crates + barrel, bench,
-- watering can, signpost, toadstools.
-- quirk: a pair of boots left on the hero cottage doorstep, one has a flower growing out of it.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-village" }
local floor, sin, abs, sqrt = math.floor, math.sin, math.abs, math.sqrt
local HOR = 112

local function px(x, y, h) if x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, h) end end
local function R(x0, y0, x1, y1, h) c:fillMask(c:rect(x0, y0, x1, y1), h) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function hh(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return v - floor(v) end

local EXITS = { {240,118}, {372,128}, {452,176}, {396,236}, {240,258}, {84,236}, {28,176}, {108,128} }
local STANDS = { {200,200}, {280,206}, {120,214}, {360,214}, {240,226}, {50,214} }
local function clear(x, y)
  for _, e in ipairs(EXITS) do if (x - e[1])^2 + (y - e[2])^2 < 31 * 31 then return true end end
  for _, s in ipairs(STANDS) do if (x - s[1])^2 + (y - s[2])^2 < 29 * 29 then return true end end
  return false
end

local NEAR = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.dusk.deep }
local MID = { hi = P.moss.hi, base = P.moss.base, shade = P.moss.shade, deep = P.moss.deep }
local CREAMR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }

-- speckled foliage: clumps shaded each from its own centre (upper-left lit), hash speckles
local function foliage(clumps, rp, seed, edge)
  local all = HP.mask()
  for _, k in ipairs(clumps) do all:add(E(k[1], k[2], k[3], k[4])) end
  c:rim(all, edge or rp.deep)
  local T = { rp.hi, rp.base, rp.shade, rp.deep }
  for i, k in ipairs(clumps) do
    local m = E(k[1], k[2], k[3], k[4])
    m:each(function(x, y)
      local dd = ((x - k[1]) / k[3] + (y - k[2]) / k[4]) * .62
      local t = dd < -.42 and 1 or dd < .18 and 2 or dd < .62 and 3 or 4
      local h = hh(x, y, seed + i)
      if h < .1 then t = math.max(1, t - 1) elseif h > .9 then t = math.min(4, t + 1) end
      px(x, y, T[t])
    end)
    -- leaf flecks: little 2px light dashes upper-left of each clump
    for j = 0, 5 do
      local fx = floor(k[1] - k[3] * .5 + hh(j, i, seed) * k[3] * .8)
      local fy = floor(k[2] - k[4] * .5 + hh(i, j, seed) * k[4] * .6)
      if m:has(fx, fy) and m:has(fx + 1, fy) then px(fx, fy, rp.hi) px(fx + 1, fy, rp.hi) px(fx + 1, fy + 1, rp.shade) end
    end
  end
  return all
end

-- bark: lit left edge, grain streaks, shaded right
local function bark(m, seed)
  c:rim(m, P.wood.deep)
  m:each(function(x, y)
    local col = P.wood.base
    if not m:has(x + 1, y) or not m:has(x + 2, y) or not m:has(x + 3, y) then col = P.wood.shade
    elseif not m:has(x - 1, y) then col = P.wood.hi
    elseif hh(x, y // 5, seed) < .2 then col = P.wood.shade end
    if not m:has(x + 1, y) and hh(x, y // 3, seed + 2) < .5 then col = P.wood.deep end
    px(x, y, col)
  end)
end

------------------------------------------------------------ SKY (4 bands, sun, puffs)
c:bands(0, HOR - 1, "sky", 4)
c:fillMask(E(252, 30, 10, 10), P.gold.base) c:fillMask(E(251, 29, 7, 7), P.gold.hi) px(248, 25, P.cream) px(249, 25, P.cream)
c:cloud(96, 66, 34, P.cream, P.sky.hi)
c:cloud(214, 82, 22, P.cream, P.sky.hi)
c:cloud(372, 58, 36, P.cream, P.sky.hi)
c:cloud(404, 86, 18, P.cream, P.sky.hi)

------------------------------------------------------------ FAR: low-contrast hills, ridge, forest edge
c:terrain(function(x) return 84 + 6 * sin(x / 41 + 1) + 3 * sin(x / 17) end, P.sky.hi)
c:terrain(function(x) return 96 + 4 * sin(x / 29 + 2) + 2 * sin(x / 11) end, P.sea.hi)
c:terrain(function(x) return 103 + 2 * sin(x / 23) end, P.moss.hi)
do -- forest edge: rounded tree bumps, gaps where the N / NW / NE trails leave
  local fm = HP.mask()
  for x = -6, W + 6, 9 do
    local gap = abs(x - 240) < 22 or abs(x - 372) < 22 or abs(x - 108) < 22
    if not gap then
      local r = 6 + floor(hh(x, 1, 3) * 4)
      fm:add(E(x, HOR - 3 - r * .4, r, r)):add(c:rect(x - r, HOR - 3, x + r, HOR))
    end
  end
  fm:clip(c:rect(0, 0, W - 1, HOR))
  c:fillMask(fm, P.moss.shade)
  fm:each(function(x, y)
    if not fm:has(x - 1, y - 1) or not fm:has(x, y - 2) then px(x, y, P.moss.base)
    elseif hh(x, y, 9) < .12 then px(x, y, P.moss.deep) end
  end)
end

------------------------------------------------------------ GROUND: moss, dapples, tufts, flowers
R(0, HOR, W - 1, H - 1, P.moss.base)
for y = HOR + 1, H - 1 do
  for x = 0, W - 1 do
    if not clear(x, y) then
      local v = sin(x * .11 + sin(y * .23) * 2) * sin(y * .19 + x * .035)
      local h = hh(x, y, 1)
      if v > .7 and h > .3 then px(x, y, P.moss.hi)
      elseif v < -.82 and h > .35 then px(x, y, P.moss.shade) end
      if h < .012 then px(x, y, P.moss.shade) px(x - 1, y - 1, P.moss.shade) px(x + 1, y - 1, P.moss.shade)
      elseif h > .996 then
        local fl = ({ P.petal.base, P.gold.hi, P.cream, P.dusk.hi })[floor(hh(y, x, 2) * 4) + 1]
        px(x, y, fl) px(x, y + 1, P.moss.shade)
      end
    end
  end
end

------------------------------------------------------------ PATHS (trodden earth) + exit patches
local PATH = HP.mask()
local hub = { 240, 206 }
local routes = {
  { { 240, 206 }, { 214, 188 }, { 207, 160 }, { 222, 132 }, { 240, 118 } },               -- N
  { { 214, 188 }, { 170, 186 }, { 130, 160 }, { 108, 128 } },                              -- NW
  { { 258, 194 }, { 296, 176 }, { 310, 148 }, { 345, 126 }, { 372, 128 } },                -- NE
  { { 262, 200 }, { 310, 202 }, { 380, 198 }, { 420, 184 }, { 452, 176 }, { 480, 172 } },  -- E
  { { 262, 212 }, { 330, 226 }, { 396, 236 }, { 418, 270 } },                              -- SE
  { { 240, 206 }, { 240, 258 }, { 240, 270 } },                                            -- S
  { { 218, 212 }, { 150, 230 }, { 84, 236 }, { 62, 270 } },                                -- SW
  { { 214, 196 }, { 150, 192 }, { 80, 183 }, { 28, 176 }, { -2, 174 } },                   -- W
}
for i, r in ipairs(routes) do PATH:add(c:line(r, (i == 1 or i == 2 or i == 3) and 6 or 8)) end
PATH:add(E(hub[1], hub[2], 26, 12))
for _, e in ipairs(EXITS) do PATH:add(E(e[1], e[2], 22, 11)) end
-- horizon stubs: narrowing trails slipping through the forest gaps
PATH:add(c:poly{ { 234, 118 }, { 246, 118 }, { 242, 104 }, { 239, 104 } })
PATH:add(c:poly{ { 366, 128 }, { 378, 128 }, { 378, 104 }, { 375, 104 } })
PATH:add(c:poly{ { 102, 128 }, { 114, 128 }, { 106, 104 }, { 103, 104 } })
PATH:clip(c:rect(0, 0, W - 1, H - 1))
c:fillMask(PATH, P.wood.hi)
PATH:each(function(x, y)
  if not PATH:has(x, y + 1) or not PATH:has(x + 1, y + 1) then px(x, y, P.wood.base)
  elseif not clear(x, y) and hh(x, y, 5) < .025 then px(x, y, P.stone.hi) px(x + 1, y, P.stone.base) px(x, y + 1, P.stone.base)
  elseif not clear(x, y) and hh(x, y, 6) < .03 then px(x, y, P.gold.hi) end
end)
-- grass creeping onto the path edges
PATH:edge():each(function(x, y) if not clear(x, y) and hh(x, y, 7) < .18 then px(x, y, P.moss.base) end end)

------------------------------------------------------------ BIG OAK A (behind the homes)
c:fillMask(E(192, 142, 22, 3), P.moss.shade)
local trA = c:poly{ { 168, 142 }, { 174, 136 }, { 175, 70 }, { 184, 70 }, { 186, 136 }, { 193, 142 } }
bark(trA, 11)
foliage({ { 150, 72, 22, 15 }, { 204, 70, 20, 15 }, { 160, 42, 22, 17 }, { 198, 40, 22, 17 }, { 178, 24, 22, 14 }, { 178, 58, 30, 22 } }, MID, 20)

------------------------------------------------------------ BIG OAK B (with birdhouse)
c:fillMask(E(334, 121, 16, 2), P.moss.shade)
local trB = c:poly{ { 313, 121 }, { 318, 116 }, { 319, 62 }, { 328, 62 }, { 330, 116 }, { 336, 121 } }
bark(trB, 12)
foliage({ { 300, 72, 20, 14 }, { 346, 70, 20, 14 }, { 306, 38, 20, 16 }, { 340, 38, 20, 16 }, { 322, 22, 20, 13 }, { 322, 58, 28, 22 } }, MID, 30)

------------------------------------------------------------ cottage helper
local function tiles(roof, rp, x0, x1, y0, y1)
  for y = y0, y1, 4 do
    local k = (y // 4) % 2
    for x = x0, x1 do if roof:has(x, y) then px(x, y, rp.shade) end end
    for x = x0 + k * 3, x1, 6 do
      for yy = y + 1, y + 3 do if roof:has(x, yy) then px(x, yy, rp.shade) end end
      if roof:has(x + 1, y + 1) and roof:has(x + 2, y + 1) and x < (x0 + x1) / 2 + 4 then px(x + 1, y + 1, rp.hi) end
    end
  end
end
local function window(cx, cy, frame)
  local f = c:rect(cx - 3, cy - 3, cx + 3, cy + 3)
  c:rim(f, frame) R(cx - 3, cy - 3, cx + 3, cy + 3, P.gold.hi)
  R(cx, cy, cx + 3, cy + 3, P.gold.base)
  R(cx, cy - 3, cx, cy + 3, P.wood.base) R(cx - 3, cy, cx + 3, cy, P.wood.base)
  px(cx - 2, cy - 2, P.cream)
end
local function flowerbox(cx, y)
  R(cx - 4, y, cx + 4, y + 1, P.wood.shade) R(cx - 4, y, cx + 4, y, P.wood.base)
  for i = 0, 3 do
    local col = ({ P.petal, P.gold, P.dusk, P.ember })[i + 1]
    px(cx - 3 + i * 2, y - 1, col.base) px(cx - 3 + i * 2, y - 2, col.hi) px(cx - 2 + i * 2, y - 1, P.moss.base)
  end
end

------------------------------------------------------------ COTTAGE 2 (back left, slate roof, smoke)
do
  c:fillMask(E(56, 143, 24, 3), P.moss.shade)
  local wall = c:rect(36, 122, 68, 142)
  local roof = c:poly{ { 30, 125 }, { 52, 103 }, { 74, 125 } }
  local chim = c:rect(60, 102, 65, 114)
  c:rim(wall:copy():add(roof):add(chim), P.dusk.deep)
  c:part(chim, "stone", { band = 1, nopop = true, inner = false })
  R(59, 101, 66, 102, P.stone.shade)
  c:part(wall, "stone", { band = 2, nopop = true, inner = false })
  for y = 126, 141, 4 do
    R(36, y, 68, y, P.stone.shade)
    for x = 38 + ((y // 4) % 2) * 4, 68, 8 do R(x, y + 1, x, y + 3, P.stone.shade) end
  end
  R(36, 125, 68, 126, P.stone.shade)
  c:part(roof:copy():cut(chim), "dusk", { band = 2, nopop = true, inner = false })
  tiles(roof:copy():cut(chim), P.dusk, 30, 74, 107, 124)
  local door = c:rrect(42, 130, 49, 142, 3)
  c:rim(door, P.wood.deep) c:part(door, "wood", { band = 1, nopop = true }) px(47, 136, P.gold.hi)
  window(60, 132, P.wood.deep) flowerbox(60, 137)
  -- smoke curls
  c:fillMask(E(65, 96, 3, 2), P.stone.hi) c:fillMask(E(70, 89, 4, 3), P.stone.hi) c:fillMask(E(78, 81, 5, 3), P.cream)
  px(66, 95, P.cream) px(69, 88, P.cream)
end

------------------------------------------------------------ COTTAGE 3 (behind well, turf roof)
do
  c:fillMask(E(292, 137, 20, 2), P.moss.shade)
  local wall = c:rect(274, 117, 302, 136)
  local roof = c:poly{ { 268, 120 }, { 288, 100 }, { 308, 120 } }:add(E(288, 104, 6, 4))
  c:rim(wall:copy():add(roof), P.wood.deep)
  c:part(wall, "wood", { band = 2, nopop = true, inner = false })
  for x = 277, 301, 4 do R(x, 118, x, 136, P.wood.shade) end
  R(274, 120, 302, 121, P.wood.deep)
  foliage({ { 288, 110, 20, 11 } }, MID, 41, P.moss.deep)
  roof = c:poly{ { 268, 120 }, { 288, 100 }, { 308, 120 } }:add(E(288, 104, 6, 4))
  c:fillMask(roof:copy():cut(E(288, 110, 20, 11)), P.moss.base)
  for x = 270, 306, 3 do px(x, 120, P.moss.shade) end
  -- tufts + one daisy on the ridge
  px(284, 99, P.moss.base) px(285, 98, P.moss.hi) px(291, 98, P.moss.base) px(292, 97, P.moss.hi)
  px(288, 97, P.cream) px(287, 98, P.cream) px(289, 98, P.cream) px(288, 98, P.gold.base)
  local door = c:rrect(279, 125, 286, 136, 3)
  c:rim(door, P.wood.deep) c:part(door, "moss", { band = 1, nopop = true }) px(284, 131, P.gold.hi)
  window(295, 127, P.wood.deep)
end

------------------------------------------------------------ WILD TRAIL (right edge, into the dark wood)
do
  local mouth = E(445, 118, 24, 24):clip(c:rect(0, 0, W - 1, 140))
  c:rim(mouth, P.dusk.deep)
  c:fillMask(mouth, P.moss.deep)
  mouth:each(function(x, y) if hh(x, y, 50) < .2 then px(x, y, P.moss.shade) end end)
  local tun = E(447, 124, 10, 14):clip(c:rect(0, 0, W - 1, 138))
  c:fillMask(tun, P.dusk.deep)
  tun:each(function(x, y) if hh(x, y, 51) < .06 then px(x, y, P.dusk.shade) end end)
  -- a single far glint of light deep in the wood
  px(448, 118, P.gold.hi) px(449, 118, P.gold.base)
  -- stepping stones narrowing in
  for i, s in ipairs{ { 430, 146, 5, 2 }, { 438, 140, 4, 2 }, { 444, 134, 3, 1 }, { 448, 129, 2, 1 } } do
    c:fillMask(E(s[1], s[2] + 1, s[3], s[4]), P.stone.deep)
    c:fillMask(E(s[1], s[2], s[3], s[4]), P.stone.base)
    px(s[1] - 1, s[2] - (s[4] > 1 and 1 or 0), P.stone.hi)
  end
  -- ferns either side
  for _, f in ipairs{ { 424, 136, -1 }, { 456, 138, 1 }, { 462, 130, 1 } } do
    for k = 0, 5 do
      px(f[1] + f[3] * k, f[2] - k, P.moss.base) px(f[1] + f[3] * k, f[2] - k + 1, P.moss.shade)
      px(f[1] + f[3] * k - 1, f[2] - k - 1, P.moss.hi)
    end
  end
  -- toadstools
  for _, t in ipairs{ { 459, 143 }, { 464, 145 } } do
    px(t[1], t[2], P.cream) px(t[1], t[2] - 1, P.cream)
    R(t[1] - 2, t[2] - 3, t[1] + 2, t[2] - 2, P.ember.base) px(t[1] - 1, t[2] - 3, P.ember.hi) px(t[1] + 1, t[2] - 3, P.cream)
    px(t[1] + 2, t[2] - 2, P.ember.shade)
  end
  -- signpost with an arrow into the wood
  local post = c:rect(420, 121, 421, 145)
  local sign = c:poly{ { 413, 117 }, { 428, 117 }, { 432, 120 }, { 428, 123 }, { 413, 123 } }
  c:rim(post:copy():add(sign), P.wood.deep)
  c:fillMask(post, P.wood.shade)
  c:part(sign, "wood", { band = 1, nopop = true, inner = false })
  R(415, 119, 425, 119, P.wood.hi) px(417, 121, P.wood.shade) px(420, 121, P.wood.shade) px(423, 121, P.wood.shade)
end

------------------------------------------------------------ RIGHT FRAMING TREE (over the wild trail)
do
  local tr = c:poly{ { 466, 146 }, { 469, 138 }, { 470, 30 }, { 479, 30 }, { 479, 146 } }
  bark(tr, 13)
  foliage({ { 444, 8, 24, 10 }, { 466, 34, 18, 12 }, { 472, 12, 26, 16 } }, NEAR, 60)
end

------------------------------------------------------------ LEFT FRAMING TREE (foreground)
do
  local tr = c:poly{ { 0, 0 }, { 14, 0 }, { 15, 96 }, { 19, 126 }, { 26, 140 }, { 0, 140 } }
  c:fillMask(E(18, 141, 14, 2), P.moss.shade)
  bark(tr, 14)
  local br = c:line({ { 12, 34 }, { 40, 26 }, { 62, 22 } }, 3)
  bark(br, 15)
  foliage({ { 20, 32, 18, 12 }, { 66, 8, 20, 10 }, { 44, 10, 26, 14 }, { 10, 10, 30, 18 } }, NEAR, 70)
  -- moss creeping up the trunk base
  for y = 112, 139 do for x = 0, 25 do if tr:has(x, y) and hh(x, y, 71) < (y - 108) / 50 then px(x, y, P.moss.base) end end end
end

------------------------------------------------------------ WOODPILE LEAN-TO (left)
do
  c:fillMask(E(78, 173, 15, 2), P.moss.shade)
  local roof = c:poly{ { 60, 155 }, { 90, 150 }, { 90, 153 }, { 60, 158 } }
  local posts = c:rect(62, 156, 63, 172):add(c:rect(87, 152, 88, 172))
  c:rim(roof:copy():add(posts), P.wood.deep)
  c:fillMask(posts, P.wood.shade) c:part(roof, "wood", { band = 1, nopop = true, inner = false })
  local logs = HP.mask()
  local L = {}
  for row = 0, 2 do for i = 0, 4 - (row == 0 and 1 or 0) do
    local x, y = 67 + i * 5 + (row == 0 and 2 or 0), 170 - row * 4
    if row < 2 or i > 0 then L[#L + 1] = { x, y } logs:add(E(x, y, 2, 2)) end
  end end
  c:rim(logs, P.wood.deep)
  for _, l in ipairs(L) do c:fillMask(E(l[1], l[2], 2, 2), P.wood.hi) px(l[1], l[2], P.wood.base) px(l[1] + 1, l[2] + 1, P.wood.base) end
end

------------------------------------------------------------ FLOWER POTS (by the W path)
for i, p in ipairs{ { 81, P.petal }, { 87, P.gold }, { 93, P.dusk } } do
  local x = p[1]
  local pot = c:poly{ { x - 2, 198 }, { x + 2, 198 }, { x + 1, 203 }, { x - 1, 203 } }
  c:rim(pot, P.wood.deep) c:fillMask(pot, P.gold.shade) px(x + 1, 199, P.gold.deep) R(x - 2, 198, x + 2, 198, P.gold.base)
  px(x, 196, P.moss.base) px(x, 197, P.moss.shade) px(x - 1, 195, P.moss.base)
  local f = p[2]
  px(x, 193 - i % 2, f.base) px(x - 1, 194 - i % 2, f.hi) px(x + 1, 194 - i % 2, f.base) px(x, 195 - i % 2, f.shade)
end

------------------------------------------------------------ HERO: HOMES cottage (tile roof)
do
  c:fillMask(E(146, 178, 25, 3), P.moss.shade)
  local wall = c:rect(126, 150, 158, 177)
  local roof = c:poly{ { 119, 155 }, { 142, 127 }, { 165, 155 } }
  local chim = c:rect(150, 128, 155, 146):add(c:rect(149, 126, 156, 128))
  local all = wall:copy():add(roof):add(chim)
  c:rim(all, P.ember.deep)
  c:part(chim, "stone", { band = 1, nopop = true, inner = false })
  R(149, 126, 156, 127, P.stone.shade) R(150, 129, 155, 129, P.stone.shade)
  c:part(wall, CREAMR, { band = 3, nopop = true, inner = false })
  R(126, 155, 158, 156, P.stone.base) -- eave shadow
  -- timber posts + sill beam
  R(126, 157, 127, 177, P.wood.base) R(157, 157, 158, 177, P.wood.shade)
  R(126, 174, 158, 177, P.stone.shade)
  for i = 0, 7 do c:part(c:rrect(126 + i * 4, 174 + (i % 2), 129 + i * 4, 177, 1), "stone", { band = 1, nopop = i % 3 ~= 0, inner = false }) end
  local rv = roof:copy():cut(chim)
  c:part(rv, "ember", { band = 2, nopop = true, inner = false })
  tiles(rv, P.ember, 119, 165, 131, 153)
  R(119, 154, 165, 155, P.ember.deep)
  -- gable porthole
  c:rim(E(142, 143, 3, 3), P.wood.deep) c:fillMask(E(142, 143, 3, 3), P.gold.hi) px(141, 142, P.cream) R(140, 144, 144, 144, P.gold.base)
  -- door, doorstep
  local door = c:rrect(138, 162, 146, 177, 4)
  c:rim(door, P.wood.deep) c:part(door, "moss", { band = 2, pop = { 140, 165 } })
  R(142, 164, 142, 177, P.moss.shade) px(145, 170, P.gold.hi) px(145, 171, P.gold.base)
  R(136, 178, 148, 179, P.stone.base) R(137, 178, 147, 178, P.stone.hi)
  window(132, 163, P.wood.deep) flowerbox(132, 168)
  window(152, 163, P.wood.deep) flowerbox(152, 168)
  -- lantern by the door
  px(136, 158, P.ink) R(135, 159, 137, 162, P.gold.base) px(135, 159, P.gold.hi) px(137, 162, P.gold.shade)
  -- a wisp from the chimney
  c:fillMask(E(156, 121, 2, 1), P.stone.hi) c:fillMask(E(160, 116, 3, 2), P.cream)
  -- QUIRK: boots left on the step, a flower growing out of one
  local boots = c:rect(149, 175, 151, 179):add(c:rect(149, 178, 153, 179)):add(c:rect(154, 176, 156, 179)):add(c:rect(154, 178, 158, 179))
  c:rim(boots, P.wood.deep) c:fillMask(boots, P.wood.shade)
  px(149, 175, P.wood.base) px(154, 176, P.wood.base) px(152, 178, P.wood.base) px(157, 178, P.wood.base)
  R(150, 170, 150, 174, P.moss.base) px(151, 172, P.moss.hi)
  px(150, 168, P.petal.base) px(149, 169, P.petal.base) px(151, 169, P.petal.shade) px(150, 170, P.petal.base) px(150, 169, P.gold.hi)
end

------------------------------------------------------------ RAIN BARREL (by the cottage)
do
  local b = c:rrect(161, 161, 171, 178, 2)
  c:fillMask(E(169, 179, 7, 1), P.moss.shade)
  c:rim(b, P.wood.deep) c:part(b, "wood", { band = 2, nopop = true })
  for x = 163, 169, 3 do R(x, 163, x, 177, P.wood.shade) end
  R(161, 165, 171, 165, P.stone.shade) R(161, 174, 171, 174, P.stone.shade)
  R(163, 161, 169, 161, P.sea.base) px(164, 161, P.sea.hi) px(162, 163, P.wood.hi)
end

------------------------------------------------------------ PEOPLE: the wishing well + bench
do
  c:fillMask(E(343, 169, 16, 2), P.moss.shade)
  local base = c:rect(329, 152, 351, 168)
  local posts = c:rect(330, 138, 331, 152):add(c:rect(349, 138, 350, 152))
  local roof = c:poly{ { 324, 142 }, { 340, 130 }, { 356, 142 } }
  local all = base:copy():add(posts):add(roof)
  c:rim(all, P.stone.deep)
  c:fillMask(posts, P.wood.shade) px(330, 139, P.wood.base) px(330, 140, P.wood.base)
  c:part(base, "stone", { band = 2, nopop = true, inner = false })
  for y = 156, 167, 4 do
    R(329, y, 351, y, P.stone.shade)
    for x = 331 + ((y // 4) % 2) * 3, 350, 6 do R(x, y + 1, x, y + 3, P.stone.shade) end
  end
  R(329, 152, 351, 153, P.stone.hi) R(331, 153, 349, 154, P.dusk.deep) R(334, 154, 346, 154, P.sea.deep)
  c:part(roof, "ember", { band = 1, nopop = true, inner = false })
  tiles(roof, P.ember, 324, 356, 134, 141)
  R(324, 142, 356, 142, P.ember.deep)
  -- rope + bucket + crank
  R(340, 143, 340, 147, P.wood.hi)
  local bk = c:rrect(337, 147, 343, 151, 1)
  c:rim(bk, P.wood.deep) c:part(bk, "wood", { band = 1, nopop = true }) R(337, 149, 343, 149, P.stone.base)
  R(351, 144, 354, 144, P.stone.deep) R(354, 144, 354, 147, P.stone.deep)
  -- bench
  local bench = c:rect(357, 159, 369, 160):add(c:rect(358, 161, 358, 164)):add(c:rect(368, 161, 368, 164))
  c:rim(bench, P.wood.deep) c:fillMask(bench, P.wood.base) R(357, 159, 369, 159, P.wood.hi)
end

------------------------------------------------------------ GARDEN: raised vegetable bed + watering can
do
  local bed = c:rrect(316, 178, 364, 194, 2)
  c:rim(bed, P.wood.deep) c:fillMask(bed, P.wood.base) R(316, 178, 364, 178, P.wood.hi)
  R(318, 180, 362, 192, P.wood.shade)
  R(318, 186, 362, 186, P.wood.deep)
  for i = 0, 5 do
    local x = 322 + i * 8
    c:fillMask(E(x, 183, 3, 2), P.moss.base) px(x - 1, 182, P.moss.hi) px(x, 182, P.moss.hi) px(x + 2, 184, P.moss.shade) px(x, 183, P.moss.shade)
    if i < 5 then
      px(x + 3, 188, P.moss.base) px(x + 4, 187, P.moss.hi) px(x + 5, 188, P.moss.base)
      R(x + 3, 190, x + 5, 190, P.ember.hi) px(x + 4, 191, P.gold.shade)
    end
  end
  local pk = E(357, 189, 4, 3)
  c:rim(pk, P.gold.deep) c:part(pk, "gold", { band = 1, pop = { 355, 188 } }) px(357, 186, P.moss.shade) px(357, 189, P.gold.shade)
  -- label stick
  R(319, 175, 319, 181, P.wood.hi) R(317, 175, 321, 177, P.cream) px(318, 176, P.moss.shade) px(320, 176, P.ember.base)
  -- watering can
  local can = c:rrect(306, 186, 312, 192, 1)
  local spout = c:line({ { 312, 189 }, { 315, 185 } }, 1)
  c:rim(can:copy():add(spout), P.sea.deep)
  c:part(can, "sea", { band = 1 }) c:fillMask(spout, P.sea.shade)
end

------------------------------------------------------------ DO HERE: crafting corner
do
  c:fillMask(E(242, 178, 22, 3), P.moss.shade)
  -- shavings on the ground
  for _, s in ipairs{ { 228, 180 }, { 236, 181 }, { 247, 180 }, { 254, 182 }, { 224, 176 } } do
    px(s[1], s[2], P.wood.hi) px(s[1] + 1, s[2] - 1, P.gold.hi) px(s[1] + 2, s[2], P.wood.hi)
  end
  -- pegboard on posts
  local board = c:rect(226, 147, 254, 157)
  local posts = c:rect(226, 157, 227, 161):add(c:rect(253, 157, 254, 161))
  c:rim(board:copy():add(posts), P.wood.deep)
  c:part(board, "wood", { band = 1, nopop = true, inner = false }) c:fillMask(posts, P.wood.shade)
  for x = 229, 252, 4 do for y = 149, 156, 3 do px(x, y, P.wood.shade) end end
  -- tools: saw, hammer, pliers
  R(229, 150, 236, 152, P.stone.hi) for x = 229, 236, 2 do px(x, 153, P.stone.base) end R(237, 150, 238, 152, P.ember.base)
  R(242, 149, 242, 155, P.wood.shade) R(240, 149, 245, 150, P.stone.base) px(240, 149, P.stone.hi)
  px(248, 149, P.stone.base) px(251, 149, P.stone.base) px(249, 150, P.stone.base) px(250, 150, P.stone.base)
  R(249, 151, 249, 155, P.ember.shade) R(250, 151, 250, 155, P.ember.base)
  -- lantern hooked on the right post
  R(256, 148, 257, 148, P.wood.deep) px(257, 149, P.wood.deep)
  local ln = c:rect(256, 150, 259, 154)
  c:rim(ln, P.gold.deep) c:fillMask(ln, P.gold.hi) R(258, 152, 259, 154, P.gold.base) px(256, 150, P.cream)
  -- workbench
  local top = c:rect(219, 160, 261, 163)
  local legs = c:rect(221, 164, 223, 177):add(c:rect(257, 164, 259, 177)):add(c:rect(222, 171, 258, 172))
  c:rim(top:copy():add(legs), P.wood.deep)
  c:part(top, "wood", { band = 1, pop = { 221, 160 }, inner = false })
  for x = 224, 258, 9 do px(x, 162, P.wood.shade) px(x + 1, 162, P.wood.shade) end
  c:fillMask(legs, P.wood.shade) R(222, 171, 258, 171, P.wood.base)
  -- jars on the shelf
  for i, col in ipairs{ P.sea, P.gold, P.petal } do
    local x = 228 + i * 7
    R(x, 167, x + 3, 170, col.base) R(x + 3, 168, x + 3, 170, col.shade) px(x, 167, col.hi) R(x, 166, x + 3, 166, P.wood.deep)
  end
  -- vice on the left end
  R(217, 157, 222, 159, P.stone.shade) R(217, 157, 222, 157, P.stone.hi) R(219, 155, 220, 156, P.stone.base)
  -- half-built birdhouse on the bench
  local bh = c:rect(243, 154, 250, 159)
  local bhr = c:poly{ { 241, 155 }, { 246, 150 }, { 247, 150 }, { 252, 155 } }
  c:rim(bh:copy():add(bhr), P.wood.deep)
  c:fillMask(bh, P.wood.hi) R(249, 154, 250, 159, P.wood.base) c:fillMask(bhr, P.ember.base)
  px(246, 151, P.ember.hi) c:fillMask(E(246, 156, 1, 1), P.wood.deep)
  -- plane tool
  R(232, 158, 238, 159, P.wood.base) R(234, 157, 235, 157, P.wood.deep)
  -- sawhorse with a log
  local sh = c:line({ { 264, 178 }, { 268, 168 } }, 1):add(c:line({ { 274, 178 }, { 270, 168 } }, 1))
  local lg = c:rrect(261, 164, 277, 168, 2)
  c:rim(sh:copy():add(lg), P.wood.deep)
  c:fillMask(sh, P.wood.shade)
  c:part(lg, "wood", { band = 1, nopop = true })
  c:fillMask(E(276, 166, 1, 2), P.wood.hi) px(276, 166, P.wood.base)
  R(266, 163, 266, 160, P.stone.base) px(266, 159, P.stone.hi)
end

------------------------------------------------------------ BEEHIVE SKEP + SUNFLOWERS (between garden and E)
do
  c:fillMask(E(397, 183, 9, 2), P.moss.shade)
  local st = c:rect(389, 172, 401, 182)
  local sk = E(395, 165, 7, 7):clip(c:rect(0, 0, W - 1, 171))
  c:rim(st:copy():add(sk), P.wood.deep)
  c:part(st, "wood", { band = 1, nopop = true, inner = false })
  for x = 391, 400, 3 do R(x, 174, x, 182, P.wood.shade) end
  R(389, 172, 401, 172, P.wood.hi)
  c:part(sk, "gold", { band = 2, pop = { 392, 160 }, inner = false })
  for y = 161, 170, 3 do for x = 388, 402 do if sk:has(x, y) then px(x, y, P.gold.shade) end end end
  c:fillMask(E(395, 170, 1, 1), P.wood.deep)
  for _, f in ipairs{ { 408, 146, 181 }, { 414, 154, 183 } } do
    R(f[1], f[2] + 4, f[1], f[3], P.moss.shade)
    px(f[1] + 1, f[2] + 12, P.moss.base) px(f[1] + 2, f[2] + 11, P.moss.base) px(f[1] - 1, f[2] + 16, P.moss.base) px(f[1] - 2, f[2] + 15, P.moss.base)
    local hd = E(f[1], f[2], 3, 3)
    c:rim(hd, P.gold.deep) c:fillMask(hd, P.gold.base) px(f[1] - 2, f[2] - 1, P.gold.hi)
    R(f[1], f[2], f[1] + 1, f[2] + 1, P.wood.shade)
  end
end

------------------------------------------------------------ MAILBOX (stuffed with letters)
do
  c:fillMask(E(320, 247, 6, 1), P.moss.shade)
  local post = c:rect(317, 230, 318, 247)
  local box = c:rrect(311, 222, 324, 230, 2)
  c:rim(post:copy():add(box), P.sea.deep)
  c:fillMask(post, P.wood.shade)
  c:part(box, "sea", { band = 1, pop = { 313, 223 } })
  R(313, 225, 322, 225, P.sea.deep)
  R(314, 220, 316, 224, P.cream) R(318, 219, 320, 224, P.cream) px(320, 219, P.stone.hi) px(315, 220, P.ember.base)
  R(325, 221, 325, 226, P.wood.deep) R(326, 221, 328, 222, P.ember.base)
  -- one letter blown onto the ground
  R(326, 244, 329, 246, P.cream) px(329, 246, P.stone.hi) px(327, 245, P.stone.base)
end

------------------------------------------------------------ CRATES + BARREL (by the SE/E paths)
do
  c:fillMask(E(440, 229, 14, 2), P.moss.shade)
  local cr = c:rect(426, 215, 438, 228)
  local br = c:rrect(440, 208, 450, 228, 2)
  c:rim(cr:copy():add(br), P.wood.deep)
  c:part(cr, "wood", { band = 1, nopop = true, inner = false })
  R(426, 215, 438, 215, P.wood.hi) R(426, 221, 438, 221, P.wood.shade)
  c:part(br, "wood", { band = 2, pop = { 442, 210 } })
  R(440, 212, 450, 212, P.stone.shade) R(440, 224, 450, 224, P.stone.shade)
  for _, a in ipairs{ { 429, 213 }, { 433, 213 }, { 431, 211 } } do R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) px(a[1], a[2], P.ember.hi) end
end

------------------------------------------------------------ NEAR: bottom-left bush + foxgloves
do
  local spikes = { { 8, 228, 246 }, { 20, 234, 250 } }
  local fg = HP.mask()
  for _, f in ipairs(spikes) do
    local k = 0
    for y = f[2], f[3], 3 do fg:add(E(f[1] + (k % 2), y, 1 + floor((y - f[2]) / 9), 1.5)) k = k + 1 end
  end
  c:rim(fg, P.petal.deep)
  c:fillMask(fg, P.petal.base)
  fg:each(function(x, y) if not fg:has(x + 1, y) or not fg:has(x, y + 1) then px(x, y, P.petal.shade) end end)
  for _, f in ipairs(spikes) do px(f[1], f[2], P.moss.base) for y = f[2] + 3, f[3], 3 do px(f[1] - 1, y, P.petal.hi) end end
  foliage({ { 2, 262, 22, 12 }, { 30, 266, 14, 8 } }, NEAR, 80)
end

------------------------------------------------------------ NEAR: mossy log with shelf fungi + toadstools
do
  local lg = c:rrect(140, 253, 198, 266, 6)
  local endc = E(197, 259, 4, 6)
  c:rim(lg:copy():add(endc), P.wood.deep)
  bark(lg, 90)
  c:fillMask(endc, P.wood.hi) c:fillMask(E(197, 259, 2, 4), P.gold.hi) px(197, 259, P.wood.base) px(197, 257, P.wood.base)
  -- moss blanket on top
  lg:each(function(x, y) if y < 257 and hh(x, y, 91) < .75 - (y - 253) * .18 then px(x, y, ({ P.moss.base, P.moss.hi })[hh(y, x, 92) < .3 and 2 or 1]) end end)
  -- shelf fungi
  for _, s in ipairs{ { 152, 262 }, { 160, 260 }, { 178, 263 } } do
    R(s[1], s[2], s[1] + 4, s[2], P.gold.hi) R(s[1] + 1, s[2] + 1, s[1] + 4, s[2] + 1, P.gold.shade)
  end
  -- toadstools in front
  for _, t in ipairs{ { 134, 266, 3 }, { 206, 264, 4 }, { 212, 268, 2 } } do
    local cap = E(t[1], t[2] - t[3] - 2, t[3], t[3] - 1)
    local stem = c:rect(t[1] - 1, t[2] - t[3] - 1, t[1], t[2])
    c:rim(cap:copy():add(stem), P.ember.deep)
    c:fillMask(stem, P.cream) px(t[1], t[2], P.stone.hi)
    c:part(cap, "ember", { band = 1, nopop = true, inner = false })
    px(t[1] - 1, t[2] - t[3] - 3, P.cream) px(t[1] + 1, t[2] - t[3] - 2, P.cream)
  end
  -- ferns
  for _, f in ipairs{ { 128, 269 }, { 200, 270 } } do
    for k = 0, 7 do px(f[1] + k, f[2] - k, P.moss.shade) px(f[1] + k + 1, f[2] - k, P.moss.base) if k % 2 == 0 then px(f[1] + k - 1, f[2] - k - 1, P.moss.base) end end
  end
end

------------------------------------------------------------ NEAR: pumpkin patch bush (bottom middle-right)
do
  foliage({ { 300, 268, 24, 12 }, { 334, 266, 20, 10 } }, NEAR, 100)
  for _, p in ipairs{ { 296, 263, 5, 4 }, { 312, 266, 4, 3 }, { 338, 264, 3, 3 } } do
    local m = E(p[1], p[2], p[3], p[4])
    c:rim(m, P.gold.deep) c:part(m, "ember", { band = 1, pop = { p[1] - p[3] + 2, p[2] - p[4] + 1 } })
    R(p[1], p[2] - p[4] + 1, p[1], p[2] + p[4] - 1, P.ember.shade)
    px(p[1], p[2] - p[4] - 1, P.moss.deep) px(p[1] + 1, p[2] - p[4] - 2, P.moss.base)
  end
  for _, f in ipairs{ { 322, 258 }, { 346, 259 }, { 284, 260 } } do px(f[1], f[2], P.cream) px(f[1] - 1, f[2] + 1, P.cream) px(f[1] + 1, f[2] + 1, P.cream) px(f[1], f[2] + 1, P.gold.base) end
end

------------------------------------------------------------ NEAR: bottom-right bush + bluebells
do
  foliage({ { 468, 262, 22, 14 }, { 448, 268, 14, 7 } }, NEAR, 110)
  for _, b in ipairs{ { 452, 252 }, { 460, 249 }, { 472, 250 } } do
    R(b[1], b[2], b[1], b[2] + 5, P.moss.base) px(b[1] + 1, b[2], P.dusk.base) px(b[1] + 1, b[2] + 1, P.dusk.shade) px(b[1] + 2, b[2] + 2, P.dusk.base) px(b[1] + 1, b[2] - 1, P.dusk.hi)
  end
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "here-village.aseprite", png = out .. "here-village.png", scale = 1 }
