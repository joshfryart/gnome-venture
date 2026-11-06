-- carrot-cake (final, Opus single pass). A tall, narrow wedge slice of layered carrot cake on a small pale plate, seen
-- from the front-left: lit cut face showing two spiced sponge layers (crumb pores, orange carrot shreds, walnut bits)
-- split by a cream-cheese filling, a thick frosted top with a bright lip and spatula swirl marks, frosting drips over
-- the cut edge, a shaded outer crust face, a piped rosette with a marzipan carrot (ridges + leafy tuft).
-- Plate: 5-tone glaze, rim highlight, inner well, contact shadow along the cake's foot.
-- quirk: someone already took a bite out of the pointed tip.
local NAME = "carrot-cake"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CK = { "#5a2622", "#8a4228", "#b0602e", "#cc7d3c", "#e29c58", "#f4be7e" }
local FR = { "#8f7f9c", "#bfb0c0", "#ddd0cc", "#efe4d4", "#fbf3e2", "#fffaee" }
local PL = { "#4e557e", "#7d84a8", "#aab1cc", "#d2d7e6", "#eef0f6" }
local CAR = { "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local GRN = { "#21593f", "#45954c", "#9dd06c" }
local SHRED, SHRED2, NUT, NUT2 = "#f07a28", "#ffa04a", "#6e4026", "#c99c6a"

local H = 14
local P0, P1, P2 = { 10, 30 }, { 40, 38 }, { 50, 24 }
local function topY(x) return P0[2] + (x - P0[1]) * (P1[2] - P0[2]) / (P1[1] - P0[1]) end
local function crustTopY(x) return P1[2] + (x - P1[1]) * (P2[2] - P1[2]) / (P2[1] - P1[1]) end

-- plate
local ptok = A.tok("plate")
local plate = HP.mask()
local PCX, PCY, PRX, PRY = 31, 47, 24, 7.5
for y = 38, 56 do for x = 5, 57 do
  local d = ((x - PCX) / (PRX + .5))^2 + ((y - PCY) / (PRY + .5))^2
  if d <= 1 then plate:set(x, y) end end end
plate:each(function(x, y)
  local d = ((x - PCX) / (PRX + .5))^2 + ((y - PCY) / (PRY + .5))^2
  local well = ((x - PCX) / 17)^2 + ((y - PCY + 0.5) / 4.6)^2
  local col
  if well <= 1 then col = PL[3] if well > 0.82 and y < PCY then col = PL[2] end
  else
    col = (y < PCY - 1) and PL[4] or PL[3]
    if d > 0.86 and y >= PCY + 2 then col = PL[2] end
    if d > 0.9 and y <= PCY - 3 and x < PCX + 6 then col = PL[5] end
  end
  if y >= PCY + PRY - 0.6 then col = PL[1] end
  c:put(x, y, col, ptok)
end)

-- cake masks
local cut = A.poly{ { P0[1], P0[2] }, { P1[1] + 0.5, P1[2] }, { P1[1] + 0.5, P1[2] + H }, { P0[1], P0[2] + H } }
local crust = A.poly{ { P1[1] + 0.5, P1[2] }, { P2[1] + 0.5, P2[2] }, { P2[1] + 0.5, P2[2] + H }, { P1[1] + 0.5, P1[2] + H } }
local top = A.poly{ { P0[1], P0[2] + 0.5 }, { P2[1] + 0.5, P2[2] - 0.6 }, { P1[1] + 0.5, P1[2] + 0.5 } }
top:cut(cut) crust:cut(cut) top:cut(crust)
local cake = cut:copy():add(crust):add(top)
-- bite out of the tip
local bite = HP.mask()
for _, b in ipairs{ { 8.5, 35, 4.2 }, { 10.5, 40.5, 3.2 }, { 11, 31, 2.6 } } do
  for y = floor(b[2] - 5), floor(b[2] + 5) do for x = floor(b[1] - 5), floor(b[1] + 5) do
    if (x - b[1])^2 + (y - b[2])^2 <= b[3]^2 then bite:set(x, y) end end end end
cut:cut(bite) top:cut(bite) crust:cut(bite) cake:cut(bite)

-- contact shadow on the plate along the foot and right of the crust
cake:shift(1, 1):add(cake:shift(2, 1)):add(cake:shift(1, 2)):each(function(x, y)
  if plate:has(x, y) and not cake:has(x, y) then c:put(x, y, PL[1], ptok) end end)
cake:shift(3, 1):add(cake:shift(2, 3)):each(function(x, y)
  if plate:has(x, y) and not cake:has(x, y) and not cake:shift(1, 1):has(x, y) and not cake:shift(2, 1):has(x, y) and not cake:shift(1, 2):has(x, y) then
    c:put(x, y, PL[2], ptok) end end)

-- layers: v = rows below the top edge
local function layer(v)
  if v < 3 then return "fr" elseif v < 7 then return "sp" elseif v < 9 then return "fil" else return "sp" end
end
local tok = A.tok("cake")
local function sponge(x, y, base, v)
  local i = base
  local h = X.hash(x, y, 11)
  if v == 3 or v == 9 then i = i - 1 end                 -- AO under the frosting / filling
  if v >= H - 1 then i = i - 1 end                       -- browned base
  if h > 0.84 then i = i - 1 elseif h < 0.07 then i = i + 1 end
  local col = CK[max(1, min(6, i))]
  local h2 = X.hash(x, y, 23)
  if h2 > 0.9 and v ~= 3 and v ~= 9 then col = (h2 > 0.95) and SHRED2 or SHRED end
  return col
end
cut:each(function(x, y)
  local v = floor(y - topY(x) + 0.5)
  local L = layer(v)
  local base = x < 26 and 5 or 4
  if L == "fr" then c:put(x, y, v == 0 and FR[5] or (v == 1 and FR[4] or FR[3]), tok)
  elseif L == "fil" then c:put(x, y, v == 7 and FR[4] or FR[2], tok)
  else c:put(x, y, sponge(x, y, base, v), tok) end
end)
crust:each(function(x, y)
  local v = floor(y - crustTopY(x) + 0.5)
  local L = layer(v)
  if L == "fr" then c:put(x, y, v == 0 and FR[4] or (v == 1 and FR[3] or FR[2]), tok)
  elseif L == "fil" then c:put(x, y, FR[1], tok)
  else
    local i = 3
    if x >= P2[1] - 1 or v >= H - 1 or v == 3 or v == 9 then i = 2 end
    if X.hash(x, y, 31) > 0.8 then i = i - 1 end
    c:put(x, y, CK[max(1, i)], tok)
  end
end)
-- corner bevel: lit column on the cut face edge, darker first column of the crust
for y = P1[2] + 3, P1[2] + H - 1 do
  if crust:has(P1[1] + 1, y) then local v = y - P1[2] if layer(v) == "sp" then c:put(P1[1] + 1, y, CK[1], tok) end end
end
-- walnut bits on the cut face: dark 2x2 with a pale glint
for _, q in ipairs{ { 17, 39 }, { 29, 46 }, { 34, 38 }, { 22, 47 } } do
  local x, y = q[1], q[2]
  for _, d in ipairs{ { 0, 0, NUT2 }, { 1, 0, NUT }, { 0, 1, NUT }, { 1, 1, CK[1] } } do
    if cut:has(x + d[1], y + d[2]) then c:put(x + d[1], y + d[2], d[3], tok) end end
end
-- top frosting: lit, with spatula swirl arcs
top:each(function(x, y)
  local col = FR[5]
  local dx, dy = x - 33, (y - 31) * 1.9
  local r = sqrt(dx * dx + dy * dy)
  if floor(r) % 6 == 0 and r > 3 then col = FR[4] end
  if x > 44 then col = FR[4] end
  c:put(x, y, col, tok)
end)
-- bright lip along the front top edge
for x = P0[1] + 2, P1[1] do local y = floor(topY(x) + 0.5) - 1 if top:has(x, y) then c:put(x, y, FR[6], tok) end end
-- drips over the cut edge
for _, d in ipairs{ { 16, 2 }, { 24, 3 }, { 31, 1 }, { 36, 2 } } do
  local x = d[1]
  local y0 = floor(topY(x) + 0.5) + 3
  for j = 0, d[2] - 1 do
    if cut:has(x, y0 + j) then c:put(x, y0 + j, j == d[2] - 1 and FR[2] or FR[4], tok) end
    if j < d[2] - 1 and cut:has(x + 1, y0 + j) then c:put(x + 1, y0 + j, FR[3], tok) end
  end
end
-- bite: crumbly sponge where the teeth went through
bite:grow(1):each(function(x, y)
  if cake:has(x, y) and not bite:has(x, y) then
    local onTop = top:has(x, y)
    c:put(x, y, onTop and FR[2] or CK[(x + y) % 2 == 0 and 2 or 3], tok)
  end end)
bite:grow(2):each(function(x, y)
  if cut:has(x, y) and not bite:grow(1):has(x, y) and layer(floor(y - topY(x) + 0.5)) == "sp" then c:put(x, y, CK[3], tok) end end)

-- piped rosette on the top: spiral of frosting
local rtok = A.tok("rosette")
local RX, RY = 38, 27
local ros = {
  "..cbb..",
  ".cddcb.",
  "cdeccba",
  "cdcbdba",
  ".bbaba.",
  "..aaa..",
}
local RM = { a = FR[2], b = FR[3], c = FR[4], d = FR[5], e = FR[6] }
for yy, row in ipairs(ros) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if RM[ch] then c:put(RX + xx - 4, RY + yy - 4, RM[ch], rtok) end end end
for _, q in ipairs{ { 36, 29 }, { 37, 30 }, { 41, 29 } } do if top:has(q[1], q[2]) then c:put(q[1], q[2], FR[3], tok) end end
-- marzipan carrot lying across the rosette, leafy tuft up-right
local ctok = A.tok("marzipan")
local carrot = {
  "..........gG",
  "........hGg.",
  "......hdcG..",
  "....hddcb...",
  "..hddcba....",
  "hddcba......",
  ".bba........",
}
local CM = { h = CAR[5], d = CAR[4], c = CAR[3], b = CAR[2], a = CAR[1], g = GRN[3], G = GRN[2] }
for yy, row in ipairs(carrot) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if CM[ch] then c:put(32 + xx - 1, 18 + yy - 1, CM[ch], ctok) end end end
-- carrot ridges
c:put(37, 22, CAR[2], ctok) c:put(40, 20, CAR[2], ctok)
c:put(44, 16, GRN[1], ctok) c:put(43, 15, GRN[3], ctok)
A.save(c, NAME)
