-- butterfly-house pass A (Opus). Tall slim cedar box on a 4 px post: three vertical planks with grain, three
-- narrow entry slots (bevelled lip), gable pediment, two sage-painted roof boards with a tin ridge cap,
-- AO under the eaves and where the box meets the post, small grass tuft + ground shadow.
-- quirk: a monarch has landed on the right edge of the box, one wing poking past the wall.
local NAME = "butterfly-house.pA"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin = math.floor, math.abs, math.sin

local CEDAR = { "#4c2a24", "#6e3d2b", "#94573a", "#b67548", "#d09562", "#e9bb88" }
local ROOF  = { "#21423e", "#2f5e4f", "#447c5c", "#5f9a68", "#86b977", "#b5d995" }
local TIN   = { "#444663", "#5d5f78", "#74758c", "#9696a8", "#c2c1cc", "#eceaf0" }
local MON   = { "#6e2038", "#c2462a", "#ec7a2a", "#ffb04a" }

c:groundShadow(31.5, 58, 9, 1.5)

-- post (cylinder + grain)
local post, pT, pS = H.cyl(c, 31.5, 44, 31.5, 57, function() return 1.9 end, CEDAR)
post:each(function(x, y) if x == 31 and (y % 5) ~= 0 then c:px(x, y, CEDAR[3]) end end)
for x = 30, 33 do c:px(x, 45, CEDAR[1]) end                         -- AO under the box

-- grass tuft at the foot (slim blades, darker base)
for _, b in ipairs{ {28, 57, 3, 0}, {29, 57, 5, -1}, {34, 57, 4, 1}, {35, 57, 2, 0}, {27, 57, 2, -1} } do
  for i = 0, b[3] - 1 do
    local x = b[1] + ((i >= 2) and b[4] or 0)
    c:px(x, b[2] - i, i == b[3] - 1 and ROOF[6] or (i == 0 and ROOF[2] or ROOF[4]))
  end
end

-- box front: planks x 24..39, y 21..44
local function plank(x) if x <= 28 then return 0, x - 24, 5 elseif x <= 33 then return 1, x - 29, 5 else return 2, x - 34, 6 end end
local box = c:rect(24, 21, 39, 44)
local bias = {}
box:each(function(x, y)
  local k = K(x, y)
  local w, px, pw = plank(x)
  local g = 0
  if px == 0 then g = -2 elseif px == pw - 1 then g = -1 end            -- plank seams
  local gl = 2 + floor(1.2 * sin(y * 0.45 + w * 2.1) + 0.5)          -- wavy grain line per plank
  if px == gl and (y + w * 3) % 7 > 1 then g = g - 1 end
  if y >= 42 then g = g - 1 end
  bias[k] = g
end)
H.lit(c, box, CEDAR, { R = 1.5, amb = 0.25, bias = bias })
-- slots with bevelled lips
for _, sx in ipairs{ 26, 31, 36 } do
  c:fillMask(c:rect(sx, 26, sx + 1, 37), "#2a1820")
  c:px(sx, 26, CEDAR[1]) c:px(sx + 1, 26, CEDAR[1])
  c:px(sx, 38, CEDAR[6]) c:px(sx + 1, 38, CEDAR[5])
end

-- pediment
local ped = c:poly{ {24, 21}, {31.5, 13}, {39, 21} }
local pb = {}
ped:each(function(x, y) pb[K(x, y)] = (y >= 19 and -1 or 0) end)
H.lit(c, ped, CEDAR, { R = 1, amb = 0.4, bias = pb })
for x = 24, 39 do c:px(x, 21, CEDAR[2]) end                         -- trim shadow line

-- roof boards
local function board(ax, ay, bx, by)
  local m, T, S = H.cyl(c, ax, ay, bx, by, function() return 1.6 end, ROOF, { amb = 0.15 })
  return m, T, S
end
local rl = board(31.5, 9, 18.5, 22)
local rr = board(31.5, 9, 44.5, 22)
-- AO under the eaves on the pediment / box
ped:each(function(x, y) if (rl:has(x - 1, y - 1) or rr:has(x + 1, y - 1) or rl:has(x, y - 1) or rr:has(x, y - 1)) and not rl:has(x, y) and not rr:has(x, y) then c:px(x, y, CEDAR[2]) end end)
-- ridge cap
local cap = c:rrect(29, 7, 34, 10, 1)
H.lit(c, cap, TIN, { R = 1 })
c:px(30, 7, TIN[6]) c:px(31, 7, TIN[6])

-- quirk: monarch on the right wall edge, wings open
c:paint({
  ".kkk.....kkk.",
  "koovok.kovook",
  "kwoovokovoowk",
  ".koovkbkvook.",
  "..kkkkbkkkk..",
  ".kooovbvoook.",
  ".kwoovkvoowk.",
  "..kkk...kkk..",
}, 40, 8, { k = P.ink, o = MON[3], v = MON[2], w = "#fff4d6", b = "#3a2430" })
c:px(41, 9, MON[4]) c:px(42, 9, MON[4]) c:px(42, 13, MON[4])
c:px(45, 7, P.ink) c:px(47, 7, P.ink)                                   -- antennae
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }
