local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "craft-workshop" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin, abs = math.floor, math.max, math.min, math.sin, math.abs
local INK = "#2b1c26"
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, SBLUE, DIRT =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON, S.SBLUE, S.DIRT
local hash = S.hash
local function P(x, y, col) c:put(x, y, col) end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local function box(x0, y0, x1, y1, ramp, base, o) o = o or {}; o.rim = INK; return S.obj(c:rect(x0, y0, x1, y1), ramp, o) end
local function mix(a, b, t)
  local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
  local r1,g1,b1 = rgb(a); local r2,g2,b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
local function disc(cx, cy, rx, ry, ramp, o)  -- inked round object, lit upper-left
  o = o or {}
  local m = c:ellipse(cx, cy, rx, ry)
  c:rim(m, INK)
  m:each(function(x, y)
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local v = .5 - .45 * (nx * .7 + ny * .7) + (hash(x, y, o.s or 3) - .5) * .12
    local i = max(1, min(6, floor(v * 6) + 1))
    P(x, y, ramp[i])
  end)
  return m
end

---------------------------------------------------------------- wall: warm plaster with timber, wainscot
local FL = 172
for y = 0, FL do for x = 0, W - 1 do
  local v = .62 + (hash(x // 2, y // 2, 5) - .5) * .18 - y / FL * .08
  if hash(x, y, 9) > .985 then v = v - .12 end
  P(x, y, CREAM[min(6, max(3, floor(v * 6) + 1))])
end end
-- warm gradient toward the window: lighter plaster pixels
for y = 0, FL do for x = 150, 340 do
  local dd = math.sqrt((x - 250) ^ 2 + ((y - 50) * 1.3) ^ 2)
  if dd < 120 and hash(x, y, 4) < (1 - dd / 120) * .6 then P(x, y, CREAM[6]) end
end end
-- wainscot boards on lower wall
S.planks(c:rect(0, 132, W - 1, FL), OAK, { w = 8, base = 3, seed = 7 })
R(0, 130, W - 1, 130, INK); R(0, 131, W - 1, 131, OAK[5]); R(0, 132, W - 1, 132, OAK[6])
R(0, FL - 1, W - 1, FL - 1, OAK[2]); R(0, FL, W - 1, FL, INK)
-- ceiling beam and posts
S.planks(c:rect(0, 0, W - 1, 13), TIMB, { w = 60, vert = false, base = 4, seed = 2 })
R(0, 14, W - 1, 14, INK); R(0, 13, W - 1, 13, TIMB[2])
for _, px in ipairs{ 4, 134, 348, 466 } do
  box(px, 15, px + 11, FL - 1, TIMB, 4, { lit = 0, shade = 0 })
  for y = 15, FL - 2 do if hash(px, y // 3, 3) > .6 then P(px + 3 + floor(hash(px, y, 1) * 5), y, TIMB[3]) end end
  R(px + 1, 15, px + 1, FL - 2, TIMB[5])
  -- brace
  for k = 0, 9 do R(px + 12 + k, 15 + k, px + 12 + k + 1, 15 + k, INK); R(px + 12 + k, 16 + k, px + 12 + k, 16 + k, TIMB[4]) end
end
-- window (centre-top), warm light
local wx0, wy0, wx1, wy1 = 214, 26, 272, 82
box(wx0 - 4, wy0 - 4, wx1 + 4, wy1 + 4, TIMB, 4)
for y = wy0, wy1 do for x = wx0, wx1 do
  local t = (y - wy0) / (wy1 - wy0)
  P(x, y, t < .35 and "#f6e8a8" or (t < .7 and "#f2d88a" or "#e8c06c"))
end end
R(wx0, wy0 + 40, wx1, wy1, "#e8c06c")
for x = wx0 + 6, wx0 + 44, 14 do R(x, wy0 + 30, x + 5, wy0 + 32, "#fbf0c0") end
-- distant roofline & a branch in the window
for x = wx0, wx1 do local h = 40 + floor(5 * sin(x / 7)); for y = wy0 + h, wy1 do P(x, y, "#c89a5c") end end
for y = wy0 + 14, wy0 + 24 do for x = wx1 - 12, wx1 do if hash(x, y, 8) > .35 then P(x, y, "#9ab868") end end end
R(wx0 + 28, wy0, wx0 + 29, wy1, INK); R(wx0, wy0 + 27, wx1, wy0 + 28, INK)
R(wx0 + 28, wy0, wx0 + 28, wy1, TIMB[5]); R(wx0, wy0 + 27, wx1, wy0 + 27, TIMB[5])
-- sill with a pot
box(wx0 - 7, wy1 + 5, wx1 + 7, wy1 + 9, TIMB, 5)
box(wx0 + 6, wy1 - 6, wx0 + 17, wy1 + 4, BARN, 4)
for i = 0, 4 do R(wx0 + 8 + i * 2 - (i % 2), wy1 - 16 + (i % 3), wx0 + 9 + i * 2 - (i % 2), wy1 - 7, i % 2 == 0 and GREEN[4] or GREEN[5]) end
P(wx0 + 8, wy1 - 17, PINK[5]); P(wx0 + 12, wy1 - 19, PINK[5]); P(wx0 + 13, wy1 - 18, PINK[6])

---------------------------------------------------------------- floor planks
for y = FL + 1, H - 1 do
  local row = (y - FL - 1) // 12
  local rp = (y - FL - 1) % 12
  for x = 0, W - 1 do
    local off = (row * 53) % 90
    local k = (x + off) // 90
    local px = (x + off) % 90
    local tone = 4 + ((hash(k, row, 11) > .55) and 1 or 0) - ((hash(k, row, 12) > .7) and 1 or 0)
    local col
    if rp == 0 then col = OAK[2]
    elseif px == 0 then col = OAK[2]
    elseif rp == 1 then col = OAK[min(6, tone + 1)]
    else
      col = OAK[tone]
      if hash(x // 6, y, 14 + row) > .94 then col = OAK[tone - 1] end
      if hash(x, y // 3, 15) > .97 then col = OAK[tone + 1] end
    end
    P(x, y, col)
  end
end
-- bottom 20px calm: keep it tonally quiet (flatten)
for y = 250, H - 1 do for x = 0, W - 1 do
  local col = c:get(x, y)
  if col == OAK[6] or col == OAK[5] then P(x, y, OAK[4]) end
end end
-- light pool from window on the floor (hard steps)
for y = FL + 1, 249 do for x = 0, W - 1 do
  local u = (x - 200) - (y - FL) * -.9   -- slanted
  local lx = (x - (230 + (y - FL) * 0.55))
  if lx > -4 and lx < 46 and (y - FL) < 52 then
    local col = c:get(x, y)
    if col then P(x, y, mix(col, "#fbe8a4", (lx > 6 and lx < 34) and .38 or .2)) end
  end
end end
-- a rug
for y = 236, 247 do for x = 168, 252 do
  local inside = (y > 236 and y < 247 and x > 168 and x < 252) or ((y == 236 or y == 247) and x > 172 and x < 248)
  if inside then
    local band = (x - 170) // 7 % 2 == 0
    P(x, y, (y == 237 or y == 246 or x == 169 or x == 251) and ROSE[3] or (band and ROSE[4] or ROSE[5]))
  end
end end

local function shadow(cx, cy, rx, ry)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    if ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then
      local col = c:get(x, y); if col then P(x, y, mix(col, "#2b1c26", .35)) end
    end
  end end
end

---------------------------------------------------------------- hanging bits: lantern + herbs
for _, hx in ipairs{ 108, 322, 440 } do
  R(hx, 15, hx, 22, INK)
  for i = 0, 6 do
    local col = (i % 2 == 0) and GREEN[4] or LEAF[4]
    R(hx - 3 + i, 22 + abs(i - 3), hx - 3 + i, 30 + abs(i - 3), col)
    if i % 3 == 0 then P(hx - 3 + i, 31 + abs(i - 3), LEAF[6]) end
  end
  R(hx - 2, 22, hx + 2, 23, ROSE[3])
end
R(190, 15, 190, 26, INK)
box(185, 27, 195, 40, IRON, 3, { lit = 1, shade = 1 })
R(187, 29, 193, 38, "#f6d868"); R(188, 30, 192, 37, "#fce8a0"); P(190, 33, "#ffffff" and "#fff4c8")
R(184, 26, 196, 26, INK)

---------------------------------------------------------------- 1 COOKING: stove (92,150)
shadow(92, 173, 36, 4)
local sx0, sy0, sx1, sy1 = 64, 126, 120, 172
box(sx0, sy0, sx1, sy1, STONE, 4, { lit = 2, shade = 3 })
for y = sy0 + 3, sy1 - 2, 6 do for x = sx0 + 1, sx1 - 1 do P(x, y, STONE[3]) end
  for x = sx0 + ((y // 6) % 2) * 6 + 4, sx1 - 2, 12 do R(x, y - 5, x, y - 1, STONE[3]) end end
box(sx0 - 3, sy0 - 4, sx1 + 3, sy0 + 1, IRON, 3, { lit = 1, shade = 1 })  -- hob top
-- fire mouth
R(76, 148, 108, 168, INK)
R(77, 150, 107, 168, "#4a2418")
for x = 79, 105 do local h = 6 + floor(5 * sin(x / 2.2) ^ 2); R(x, 168 - h, x, 168, "#e0732e") end
for x = 83, 101 do local h = 3 + floor(4 * sin(x / 2.7 + 1) ^ 2); R(x, 168 - h, x, 168, "#f4b040") end
R(88, 164, 96, 168, "#fce07c")
R(76, 150, 108, 150, INK); R(74, 146, 110, 149, STONE[2]); R(74, 146, 110, 146, INK)
-- flue
box(104, 96, 116, sy0 - 4, IRON, 3, { lit = 1, shade = 2 })
-- cookpot on hob
local pot = disc(88, 117, 15, 9, IRON, { s = 21 })
box(70, 106, 106, 110, IRON, 4, { lit = 1, shade = 1 })
R(72, 107, 104, 108, "#c9703a")  -- stew
R(76, 107, 82, 107, "#e8a060")
box(66, 112, 72, 115, IRON, 3); box(104, 112, 110, 115, IRON, 3)  -- handles
box(84, 100, 92, 104, IRON, 5)
for i, sp in ipairs{ {80, 96}, {86, 92}, {82, 88}, {90, 85}, {85, 80} } do
  R(sp[1], sp[2], sp[1] + 3, sp[2] + 2, i % 2 == 0 and CREAM[5] or CREAM[6])
end
-- ladle hanging
R(122, 100, 122, 112, INK); R(123, 101, 123, 112, IRON[5]); box(119, 112, 126, 116, IRON, 4)

---------------------------------------------------------------- 2 PANTRY: jar shelves (190,112)
local px0, py0, px1, py1 = 152, 78, 228, 146
box(px0, py0, px1, py1, TIMB, 3, { lit = 1, shade = 1 })
R(px0 + 3, py0 + 3, px1 - 3, py1 - 3, TIMB[1])
R(px0 + 4, py0 + 4, px1 - 4, py1 - 4, mix(TIMB[1], TIMB[2], .5))
local JC = { ROSE, TEAL, GOLD, VIOLET, BARN, GREEN, SBLUE, LEAF }
local shelvesY = { 100, 123, 144 }
for si, sy in ipairs(shelvesY) do
  box(px0 + 1, sy, px1 - 1, sy + 3, OAK, 4, { lit = 1, shade = 1 })
  local x = px0 + 6
  local n = 0
  while x < px1 - 14 do
    n = n + 1
    local h = 12 + floor(hash(si, n, 2) * 9)
    local w = 9 + floor(hash(si, n, 3) * 6)
    local ramp = JC[floor(hash(si, n, 4) * #JC) + 1]
    local top = sy - h
    if hash(si, n, 5) > .6 then   -- sack/box instead
      box(x, sy - h + 2, x + w - 1, sy - 1, OAK, 5, { lit = 1, shade = 1 })
      R(x + 2, sy - h + 5, x + w - 3, sy - h + 7, CREAM[5])
    else
      box(x + 1, top, x + w - 2, top + 2, OAK, 5, { lit = 1, shade = 1 }) -- lid
      box(x, top + 3, x + w - 1, sy - 1, ramp, 4, { lit = 2, shade = 2 })
      R(x + 2, top + 5, x + 2, sy - 5, ramp[6])
      R(x + 2, top + 8 + (n % 3), x + w - 3, top + 10 + (n % 3), CREAM[5]) -- label
    end
    x = x + w + 2
  end
end
-- hanging garlic string at the side
for k = 0, 4 do R(px1 + 3, py0 + 8 + k * 4, px1 + 5, py0 + 10 + k * 4, CREAM[5]); P(px1 + 3, py0 + 8 + k * 4, INK) end

---------------------------------------------------------------- 3 TOOLS: workbench with hammer and saw (300,158)
shadow(300, 183, 42, 4)
-- pegboard
box(264, 114, 336, 146, OAK, 3, { lit = 1, shade = 1 })
for y = 118, 143, 6 do for x = 268, 332, 6 do P(x, y, OAK[1]) end end
-- hammer
R(274, 118, 275, 136, INK); R(275, 119, 275, 135, TIMB[6])
box(268, 118, 282, 124, IRON, 5, { lit = 1, shade = 1 })
-- saw
box(290, 122, 318, 130, IRON, 6, { lit = 1, shade = 1 })
for x = 291, 318, 2 do P(x, 131, INK) end
box(284, 121, 291, 131, TIMB, 5)
R(287, 124, 288, 127, INK)
-- wrench / chisels
for i = 0, 3 do R(322 + i * 3, 120, 323 + i * 3, 134, INK); R(322 + i * 3, 121, 322 + i * 3, 128, IRON[5]); R(322 + i * 3, 129, 322 + i * 3, 133, TIMB[5]) end
-- bench
box(260, 148, 340, 156, OAK, 5, { lit = 2, shade = 2 })
box(266, 157, 274, 180, OAK, 3, { lit = 0, shade = 3 })
box(326, 157, 334, 180, OAK, 3, { lit = 0, shade = 3 })
box(274, 164, 326, 167, OAK, 4)
-- vise, shavings, nails, a plank on top
box(262, 140, 272, 147, IRON, 4, { lit = 1, shade = 1 })
box(300, 142, 322, 147, TIMB, 6, { lit = 1, shade = 1 })
for i = 0, 5 do P(283 + i * 2, 146 + (i % 2), TIMB[6]) end
for i = 0, 3 do P(330 + i, 160, CREAM[4]) end
R(290, 176, 304, 178, TIMB[5])

---------------------------------------------------------------- 4 GARDEN: seed shelf + potting bench (396,126)
shadow(396, 160, 34, 3)
box(364, 94, 430, 98, OAK, 5, { lit = 1, shade = 1 })  -- shelf 1
box(364, 118, 430, 122, OAK, 5, { lit = 1, shade = 1 })
box(366, 98, 369, 160, OAK, 3, { lit = 0, shade = 2 }); box(425, 98, 428, 160, OAK, 3, { lit = 0, shade = 2 })
-- seed packets
for i = 0, 5 do
  local x = 372 + i * 9
  local ramp = ({ ROSE, GREEN, GOLD, VIOLET, TEAL, BARN })[i + 1]
  box(x, 104, x + 6, 117, ramp, 4, { lit = 1, shade = 1 })
  R(x + 2, 107, x + 4, 109, CREAM[6]); P(x + 3, 112, ramp[6])
end
-- potted sprouts on mid shelf
for i = 0, 3 do
  local x = 372 + i * 14
  box(x, 109 + 0, x - 1 + 0, 109, OAK, 4)
end
for i = 0, 3 do
  local x = 372 + i * 14
  box(x, 126, x + 9, 134 - 1 + 6, BARN, 4, { lit = 1, shade = 2 })
  for k = 0, 2 do R(x + 1 + k * 3, 114 + 4 + k % 2 * 0, x + 2 + k * 3, 124, (k + i) % 2 == 0 and GREEN[4] or LEAF[5]) end
end
-- bench top + dirt sack + trowel + watering can
box(364, 138, 430, 144, OAK, 5, { lit = 2, shade = 2 })
box(372, 126, 384, 137, DIRT, 3, { lit = 2, shade = 2 })
R(372, 126, 384, 127, DIRT[5])
box(400, 128, 416, 137, TEAL, 4, { lit = 2, shade = 2 })
R(416, 130, 424, 132, INK); R(416, 131, 423, 131, TEAL[5])
R(396, 128, 399, 137, TEAL[3])
box(368, 146, 376, 158, OAK, 3, { lit = 0, shade = 2 }); box(418, 146, 426, 158, OAK, 3, { lit = 0, shade = 2 })
box(380, 150, 412, 156, DIRT, 3, { lit = 2, shade = 2 })
for i = 0, 6 do P(383 + i * 4, 151, GREEN[5]) end
-- trailing ivy
for y = 98, 112 do P(369 + (y % 3 == 0 and 1 or 0), y, GREEN[4]); if y % 4 == 0 then P(367, y, LEAF[5]); P(371, y + 1, GREEN[5]) end end

---------------------------------------------------------------- 5 POTIONS: cauldron (142,214)
shadow(142, 240, 34, 5)
-- legs + flame
for _, lx in ipairs{ 120, 156 } do box(lx, 230, lx + 5, 241, IRON, 3, { lit = 1, shade = 2 }) end
for x = 126, 152 do local h = 3 + floor(3 * sin(x / 2) ^ 2); R(x, 240 - h, x, 241, (x % 4 < 2) and "#e0732e" or "#f4b040") end
-- body
local body = disc(142, 216, 30, 22, IRON, { s = 30 })
-- rim + brew
box(110, 192, 174, 198, IRON, 4, { lit = 1, shade = 1 })
R(113, 193, 171, 196, "#58c07a")
for x = 113, 171, 1 do if hash(x, 5, 3) > .6 then P(x, 193, "#a8f0a0") end end
R(120, 195, 128, 195, "#3a9a62")
-- bubbles
for _, b in ipairs{ {124, 186, 3}, {138, 181, 4}, {152, 187, 3}, {146, 174, 2}, {132, 172, 2} } do
  local m = c:ellipse(b[1], b[2], b[3], b[3]); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (x < b[1] and y < b[2]) and "#d8fcd0" or "#7ad88c") end)
end
-- handles & label plate
box(105, 206, 111, 210, IRON, 4); box(173, 206, 179, 210, IRON, 4)
R(132, 210, 152, 224, INK); R(133, 211, 151, 223, BARN[4]); R(134, 212, 150, 214, BARN[5])
R(138, 216, 146, 217, GOLD[5]); R(140, 219, 144, 220, GOLD[5])
-- little vials beside it
box(88, 226, 94, 240, SBLUE, 4, { lit = 1, shade = 1 }); box(89, 222, 93, 226, GLASS or TEAL, 5)
box(98, 230, 106, 240, VIOLET, 4, { lit = 1, shade = 1 })

---------------------------------------------------------------- 6 BUILDING: planks and bricks (282,222)
shadow(282, 246, 40, 4)
-- bricks (right)
for row = 0, 4 do
  for col = 0, 2 do
    local x = 292 + col * 13 + (row % 2) * 6
    box(x, 232 - row * 7, x + 11, 237 - row * 7, BARN, 4 + (hash(row, col, 3) > .6 and 1 or 0), { lit = 1, shade = 1 })
  end
end
-- planks (left) stack
for i = 0, 5 do
  local y = 240 - i * 6
  box(250 + (i % 2) * 2, y, 292 - (i % 3) * 2, y + 4, OAK, 4 + (i % 2), { lit = 1, shade = 1 })
  for k = 0, 2 do P(256 + k * 9 + i, y + 2, OAK[3]) end
end
-- strapping + tool: saw horse bar on top
R(266, 207, 268, 245, INK); R(267, 208, 267, 244, GOLD[3])
box(268, 202, 298, 205, TIMB, 6, { lit = 1, shade = 1 })

---------------------------------------------------------------- 7 DECOR: loom + painted pots (404,212)
shadow(404, 246, 40, 4)
-- loom frame
box(372, 180, 378, 244, TIMB, 4, { lit = 0, shade = 2 }); box(420, 180, 426, 244, TIMB, 4, { lit = 0, shade = 2 })
box(372, 180, 426, 187, TIMB, 5, { lit = 1, shade = 1 })
box(372, 232, 426, 238, TIMB, 4, { lit = 1, shade = 1 })
-- warp threads + woven cloth
for x = 380, 418, 3 do R(x, 188, x, 231, CREAM[4]) end
for y = 188, 214 do for x = 379, 419 do
  local stripe = ((y - 188) // 4) % 3
  local ramp = ({ ROSE, TEAL, GOLD })[stripe + 1]
  P(x, y, ramp[((x + y) % 4 < 2) and 4 or 5])
end end
R(379, 215, 419, 215, INK)
box(384, 216, 412, 220, TIMB, 6, { lit = 1, shade = 1 })  -- batten
-- shuttle
box(396, 224, 410, 227, GOLD, 5)
-- painted pots at foot
local pots = { { 430, 226, 10, 18, PINK }, { 444, 232, 12, 14, TEAL }, { 456, 228, 9, 16, VIOLET } }
for _, p in ipairs(pots) do
  local x, y, w, h, ramp = p[1], p[2], p[3], p[4], p[5]
  box(x, y, x + w, y + h, ramp, 4, { lit = 2, shade = 2 })
  R(x + 1, y + 5, x + w - 1, y + 5, CREAM[5]); P(x + 3, y + 9, GOLD[5]); P(x + 6, y + 10, GOLD[5]); P(x + 4, y + 8, CREAM[6])
end
R(432, 223, 438, 226, GREEN[4]); P(433, 221, PINK[5]); P(436, 220, GOLD[5])

---------------------------------------------------------------- QUIRK: barrel with a sleepy cat (left)
shadow(46, 242, 26, 4)
local bx0, by0, bx1, by1 = 24, 198, 68, 240
box(bx0, by0, bx1, by1, OAK, 4, { lit = 0, shade = 0 })
for y = by0, by1 do for x = bx0, bx1 do
  local t = (x - bx0) / (bx1 - bx0)
  local bulge = abs(t - .5) * 2
  local col = OAK[3 + (t < .3 and 2 or (t < .6 and 1 or 0))]
  if (x - bx0) % 7 == 0 then col = OAK[2] end
  if bulge > .85 and y > by0 + 2 and y < by1 - 2 then col = OAK[2] end
  P(x, y, col)
end end
for _, hy in ipairs{ by0 + 8, by1 - 9 } do R(bx0, hy, bx1, hy + 2, INK); R(bx0, hy, bx1, hy, IRON[5]); R(bx0, hy + 1, bx1, hy + 1, IRON[3]) end
R(bx0 - 1, by0 - 1, bx1 + 1, by0 + 1, INK); R(bx0, by0, bx1, by0, TIMB[6])
-- cat curled on top: bean shape, orange tabby
local cat = HP.mask()
for y = 180, 198 do for x = 28, 64 do
  local nx, ny = (x - 46) / 19, (y - 191) / 8.5
  if nx * nx + ny * ny <= 1 and y <= 198 then cat:set(x, y) end
end end
c:rim(cat, INK)
cat:each(function(x, y)
  local ny = (y - 182) / 17
  local col = ny < .3 and "#f0b070" or (ny < .65 and "#dc8e4a" or "#b86a38")
  if (x + y // 2) % 6 == 0 and ny > .1 and ny < .8 then col = "#a45a30" end
  P(x, y, col)
end)
-- head tucked at left, ears, closed eye, tail curling around the front
local head = HP.mask()
for y = 184, 198 do for x = 24, 42 do
  local nx, ny = (x - 33) / 9, (y - 192) / 7
  if nx * nx + ny * ny <= 1 then head:set(x, y) end
end end
c:rim(head, INK)
head:each(function(x, y) P(x, y, (y < 190) and "#f4bc7c" or "#e09a56") end)
for _, e in ipairs{ {27, 183}, {38, 183} } do   -- ears
  R(e[1], e[2], e[1] + 3, e[2] + 2, INK); R(e[1] + 1, e[2] + 1, e[1] + 2, e[2] + 2, "#e8a0a0")
end
R(28, 191, 31, 191, INK); R(36, 191, 39, 191, INK)  -- sleeping eyes
P(33, 194, "#e8a0a0"); R(32, 195, 34, 195, INK)
for i = 0, 6 do R(58 + i, 197 - floor(i / 3), 58 + i, 199, (i % 2 == 0) and "#b86a38" or "#a45a30") end  -- tail tip
R(66, 195, 67, 198, INK)
-- z z
R(22, 174, 26, 174, CREAM[6]); R(25, 175, 25, 176, CREAM[6]); R(22, 177, 26, 177, CREAM[6])
R(30, 168, 33, 168, CREAM[5]); P(32, 169, CREAM[5]); R(30, 170, 33, 170, CREAM[5])

---------------------------------------------------------------- small details
-- broom leaning at far right wall, wall shelf with mugs near the left
box(8, 100, 50, 104, OAK, 5, { lit = 1, shade = 1 })
for i = 0, 2 do box(12 + i * 12, 90, 20 + i * 12, 99, ({ TEAL, BARN, GOLD })[i + 1], 4, { lit = 2, shade = 2 }) ; R(21 + i * 12, 93, 22 + i * 12, 96, INK) end
-- cobweb-free corner: a little hanging sign (no text) near the tool bench
-- ground clutter: sawdust & scrap
for i = 0, 10 do P(240 + floor(hash(i, 1, 60) * 40), 180 + floor(hash(i, 2, 60) * 10), OAK[6]) end

c:save{ aseprite = d .. "/out/craft-workshop.aseprite", png = d .. "/out/craft-workshop.png", scale = 1 }
