-- ico-roadworks (Opus artist pass). Slim road barrier: a bevelled board with red/cream diagonal stripes on two thin
-- wooden posts with block feet, amber warning lamp on a short stalk on top. Material: pillow-lit board (6 tones per
-- stripe colour, bevel + bright top edge), grained posts with pale end grain, steel bolts, glossy lamp dome.
-- AO under the board and where posts sink into the feet; 2-tone ground shadow.
-- quirk: a small pink snail is slowly climbing the right post.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_0.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min = math.floor, math.max, math.min
local c = D.new("ico-roadworks")

c:groundShadow(32, 54, 24, 1)

-- posts (drawn first; board overlaps their tops)
local board = c:rrect(8, 17, 55, 31, 2)
local tokW = { r = { name = "wood" } }
local function post(x0)
  local m = c:rect(x0, 30, x0 + 3, 49)
  local _, n = X.cyl(x0 + 1.5, 30, x0 + 1.5, 49, function() return 2 end, m)
  local bias = {}
  m:each(function(x, y) if y <= 33 then bias[K(x, y)] = (y <= 32) and -2 or -1 end
    if y >= 47 then bias[K(x, y)] = -1 end end)
  local idx = D.tone(c, m, n, D.WOOD, { bias = bias, tok = tokW, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- grain: one broken dark line down the post
  for y = 35, 46 do if y % 5 ~= 0 then D.shift(c, x0 + 2, y, D.WOOD, -1) end end
  D.shift(c, x0 + 1, 40, D.WOOD, -1) D.shift(c, x0 + 1, 41, D.WOOD, -1)
  return m
end
local pl, pr = post(15), post(45)
-- feet: blocks with pale end grain on top
local tokF = { r = { name = "foot" } }
local function foot(x0)
  local m = c:rect(x0, 49, x0 + 11, 53)
  local n = X.pillow(m, 1.6)
  local bias = {}
  m:each(function(x, y) if y == 49 and x >= x0 + 4 and x <= x0 + 7 then bias[K(x, y)] = -2 end end)
  D.tone(c, m, n, D.WOOD, { bias = bias, tok = tokF, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  for x = x0 + 1, x0 + 10 do if x < x0 + 4 or x > x0 + 7 then c:put(x, 49, D.WOOD[6], tokF) end end
  for x = x0 + 2, x0 + 9 do if x % 3 ~= 0 then D.shift(c, x, 51, D.WOOD, -1) end end
  c:put(x0 + 4, 48, D.WOOD[2], tokW) c:put(x0 + 7, 48, D.WOOD[2], tokW)
  return m
end
foot(11) foot(41)

-- board: stripes, pillow bevel
local n = X.pillow(board, 2.6)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
local tokB = { r = { name = "board" } }
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }
board:each(function(x, y)
  local k = K(x, y)
  local stripe = floor((x + (y - 17) * 0.75 + 2) / 7) % 2 == 0
  local rp = stripe and D.RED or D.CRM
  local i = 1 for j, t in ipairs(cuts) do if v[k] >= t then i = j + 1 end end
  -- stripe boundary: thin dark seam on the cream side reads as painted edge
  local b = (x + (y - 17) * 0.75 + 2) % 7
  if not stripe and b < 1 then i = i - 1 end
  if y == 31 then i = i - 1 end
  c:put(x, y, rp[max(1, min(6, i))], tokB)
end)
-- bright top edge + specular glints
for x = 11, 52 do local cur = c:get(x, 18) if D.find(D.RED, cur) then c:put(x, 18, D.RED[6], tokB) elseif D.find(D.CRM, cur) then c:put(x, 18, D.CRM[6], tokB) end end
c:put(12, 19, D.CREAM, tokB) c:put(13, 19, D.CREAM, tokB)
-- bolts at post heads
for _, bx in ipairs{ 16, 46 } do
  c:put(bx, 24, D.STEEL[5], tokB) c:put(bx + 1, 24, D.STEEL[3], tokB)
  c:put(bx, 25, D.STEEL[3], tokB) c:put(bx + 1, 25, D.STEEL[1], tokB)
end

-- lamp: stalk + bracket + dome
local tokS = { r = { name = "steel" } }
for y = 14, 16 do c:put(31, y, D.STEEL[4], tokS) c:put(32, y, D.STEEL[2], tokS) end
local base = c:rect(28, 14, 35, 15)
local nb = X.pillow(base, 1)
D.tone(c, base, nb, D.STEEL, { tok = tokS })
local dome, dn = G.oval(31.5, 10.5, 4, 3.6, 0)
dome:cut(c:rect(20, 14, 44, 20))
local dbias = {}
dome:each(function(x, y) if y == 13 then dbias[K(x, y)] = -1 end end)
D.tone(c, dome, dn, D.AMBER, { bias = dbias, tok = { r = { name = "lamp" } }, cuts = { 0.15, 0.3, 0.48, 0.66, 0.82 } })
c:put(30, 9, D.CREAM) c:put(29, 10, D.CREAM) c:put(30, 10, D.AMBER[6])
-- lamp lens ridge
for x = 29, 34 do D.shift(c, x, 12, D.AMBER, -1) end

-- quirk: little pink snail climbing the right post (shell spiral, head up)
local sx, sy = 49, 38
local map = {
  ".o.",
  "ok..",
  "hhSSs",
  "hSPPd",
  "hSpPd",
  ".SSdd",
}
local SC = { o = D.INK, k = D.SNAIL[5], h = "#e8d4b0", S = D.SNAIL[3], P = D.SNAIL[4], p = D.SNAIL[2], s = D.SNAIL[5], d = D.SNAIL[1] }
local tokQ = { r = { name = "snail" } }
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if SC[ch] then c:put(sx + xx - 2, sy + yy - 1, SC[ch], tokQ) end end end

D.save(c, "ico-roadworks")
