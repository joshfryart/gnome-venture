-- butterfly-house (pass B, final; Opus). Tall slim cedar box seen a little from the right: three front planks
-- (seams, wavy grain, one knot, pale end grain along the bottom), a narrow shaded side wall, three tall entry
-- slots with a dark top lip and a pale sill, gable pediment, two sage-painted roof boards with shingle-butt
-- notches and a tin ridge cap, AO under the eaves and under the box, 4 px post with grain, grass tuft + shadow.
-- History: butterfly-house.pA (pass A), Sonnet draft overwritten.
-- quirk: a monarch has landed on the right roof board, wings spread, its feet shadowing the paint.
local NAME = "butterfly-house"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin = math.floor, math.abs, math.sin

local CEDAR = { "#4c2a24", "#6e3d2b", "#94573a", "#b67548", "#d09562", "#e9bb88" }
local ROOF  = { "#1f3d3b", "#2c5a4d", "#417a5b", "#5c9867", "#84b878", "#b6da98" }
local TIN   = { "#444663", "#5d5f78", "#74758c", "#9696a8", "#c2c1cc", "#eceaf0" }
local MON   = { "#6e2038", "#c2462a", "#ec7a2a", "#ffb04a" }
local SLOT  = "#2a1820"

c:groundShadow(32.5, 58, 9, 1.5)

-- post (cylinder + grain line)
local post = H.cyl(c, 31.5, 44, 31.5, 57, function() return 1.9 end, CEDAR)
post:each(function(x, y) if x == 31 and (y % 5) ~= 0 then c:px(x, y, CEDAR[3]) end end)
for x = 30, 33 do c:px(x, 45, CEDAR[1]) c:px(x, 46, x == 30 and CEDAR[3] or CEDAR[2]) end   -- AO under the box

-- grass tuft (slim blades, darker base)
for _, b in ipairs{ {28, 57, 3, 0}, {29, 57, 5, -1}, {34, 57, 4, 1}, {35, 57, 2, 0} } do
  for i = 0, b[3] - 1 do
    local x = b[1] + ((i >= 2) and b[4] or 0)
    c:px(x, b[2] - i, i == b[3] - 1 and ROOF[6] or (i == 0 and ROOF[2] or ROOF[4]))
  end
end

-- side wall (seen at a slant): x 40..42, shaded, one seam
local side = c:poly{ {40, 22}, {42, 20}, {42, 42}, {40, 44} }
side:each(function(x, y)
  local i = (x == 40) and 3 or 2
  if y > 40 then i = i - 1 end
  c:px(x, y, CEDAR[math.max(1, i)])
end)
for y = 23, 42 do if side:has(41, y) and y % 4 == 0 then c:px(41, y, CEDAR[1]) end end

-- box front: planks x 24..39, y 21..44
local function plank(x) if x <= 28 then return 0, x - 24, 5 elseif x <= 33 then return 1, x - 29, 5 else return 2, x - 34, 6 end end
local box = c:rect(24, 21, 39, 44)
local bias = {}
box:each(function(x, y)
  local w, px, pw = plank(x)
  local g = 0
  if px == 0 then g = -2 elseif px == pw - 1 then g = -1 end
  local gl = 2 + floor(1.3 * sin(y * 0.42 + w * 2.1) + 0.5)
  if px == gl and (y + w * 3) % 7 > 1 then g = g - 1 end
  if px == gl - 1 and (y + w * 3) % 9 == 0 then g = g + 1 end              -- lit fleck beside the grain
  if y >= 42 then g = g - 1 end
  bias[K(x, y)] = g
end)
H.lit(c, box, CEDAR, { R = 1.5, amb = 0.28, bias = bias })
-- knot on the left plank
c:px(26, 41, CEDAR[1]) c:px(27, 41, CEDAR[2]) c:px(26, 40, CEDAR[3]) c:px(27, 42, CEDAR[3])
-- pale end grain along the bottom edge
for x = 24, 39 do local _, px, pw = plank(x) c:px(x, 44, (px == 0) and CEDAR[3] or (x < 34 and CEDAR[5] or CEDAR[4])) end
-- slots: dark top lip (shadow), pale sill, lit right jamb
for _, sx in ipairs{ 26, 31, 36 } do
  c:fillMask(c:rect(sx, 26, sx + 1, 37), SLOT)
  c:px(sx, 25, CEDAR[2]) c:px(sx + 1, 25, CEDAR[2])
  c:px(sx, 38, CEDAR[6]) c:px(sx + 1, 38, CEDAR[5])
  for y = 27, 37 do c:px(sx + 2, y, CEDAR[5]) end
  c:px(sx + 2, 26, CEDAR[4])
end

-- pediment (horizontal cladding, two lines)
local ped = c:poly{ {24, 21}, {31.5, 13}, {39, 21} }
local pb = {}
ped:each(function(x, y) pb[K(x, y)] = (y == 17 or y == 20) and -1 or 0 end)
H.lit(c, ped, CEDAR, { R = 1, amb = 0.42, bias = pb })
for x = 24, 39 do c:px(x, 21, CEDAR[2]) end
for x = 40, 42 do c:px(x, 21, CEDAR[1]) c:px(x, 22, CEDAR[1]) end

-- roof boards with shingle-butt notches on the lower edge
local function board(ax, ay, bx, by, w)
  local m, T, S = H.cyl(c, ax, ay, bx, by, function() return w end, ROOF, { amb = 0.15 })
  m:each(function(x, y)
    local t, s = T[K(x, y)], S[K(x, y)]
    if t and s and s > 0.45 and floor(t * 15) % 3 == 0 then c:px(x, y, ROOF[1]) end
    if t and s and s < -0.5 and floor(t * 15) % 3 == 1 then c:px(x, y, ROOF[6]) end
  end)
  return m
end
local rr = board(31.5, 9, 46, 22.5, 1.9)
local rl = board(31.5, 9, 18, 22.5, 1.7)
-- AO under the eaves
ped:copy():add(box):add(side):each(function(x, y)
  if (rl:has(x, y - 1) or rr:has(x, y - 1) or rl:has(x - 1, y - 1) or rr:has(x + 1, y - 1)) and not rl:has(x, y) and not rr:has(x, y) then
    c:px(x, y, CEDAR[1]) end end)
-- tin ridge cap
local cap = c:rrect(29, 7, 34, 10, 1)
H.lit(c, cap, TIN, { R = 1 })
c:px(30, 7, TIN[6]) c:px(31, 7, TIN[6]) c:px(34, 10, TIN[1])

-- quirk: monarch landed on the right roof board (body col 6 of the stamp sits on x = 44)
local BX, BY = 38, 12
c:paint({
  ".kkk.....kkk.",
  "koovok.kovook",
  "kwoovokovoowk",
  ".koovkbkvook.",
  "..kkkkbkkkk..",
  ".kooovbvoook.",
  ".kwoovkvoowk.",
  "..kkk.k.kkk..",
}, BX, BY, { k = P.ink, o = MON[3], v = MON[2], w = "#fff4d6", b = "#3a2430" })
c:px(BX + 1, BY + 1, MON[4]) c:px(BX + 2, BY + 1, MON[4]) c:px(BX + 11, BY + 1, MON[4])  -- lit forewing tops
c:px(BX + 3, BY + 3, MON[4])
c:px(BX + 5, BY - 1, P.ink) c:px(BX + 7, BY - 1, P.ink) c:px(BX + 4, BY - 2, P.ink) c:px(BX + 8, BY - 2, P.ink)  -- antennae
c:px(BX + 5, BY + 8, ROOF[1]) c:px(BX + 7, BY + 8, ROOF[1])                            -- foot shadows on the board

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }
