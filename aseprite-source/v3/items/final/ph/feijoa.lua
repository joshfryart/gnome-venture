-- feijoa (B30, Opus single pass). A slim, tilted egg-shaped feijoa (dull green, bumpy skin with a dusty waxy bloom,
-- one soft specular, cool reflected light on the shade side) crowned with its dried brown sepals, beside a halved
-- fruit showing the skin ring, cream flesh and the glassy jelly core with its four-lobed seed cross. A slim
-- grey-green leaf with a silvery underside lies behind. Ambient shading where the fruits overlap the leaf.
-- quirk: a teaspoon is stuck in the half (feijoas are eaten with a spoon).
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = G.new("feijoa")
local SK = { "#1d3a2c", "#2f5a35", "#4a7a3a", "#6c9a42", "#93b955", "#c3d98a" }
local LF = { "#1f3d33", "#2f5a45", "#4a7a5c", "#6e9a72", "#9cbf92", "#cfe3bf" }
local SIL = { "#6a7e78", "#93a8a0", "#bccbc2", "#dde7df" }
local FLs = { "#a8a074", "#d4cf9c", "#ece8bc", "#fbf7dc" }
local JEL = { "#7c9654", "#a8c27a", "#cfe0a4", "#eef6cc" }
local STL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6", "#f6f5fa" }
local SEP = { "#3a2420", "#5e3a2e", "#8a5a3e" }
local BLOOM = "#a8c0a0"
local CREAM = "#fff4d6"

-- leaf behind (top), tip to the right, silvery underside curling up on the lower half
local la, lb = { 27, 22 }, { 55, 9 }
local lm, ln, LT, LS = X.cyl(la[1], la[2], lb[1], lb[2], function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 4.6 * sin(pi * min(1, t * 1.0 + 0.04)) ^ 0.75)
end)
local lv = X.light(ln, { amb = 0.12, wrap = 0.3 })
lm:each(function(x, y)
  local k = K(x, y)
  local s, t = LS[k], LT[k]
  local val = lv[k]
  if s > 0.45 and t > 0.25 and t < 0.85 then
    local i = val > 0.7 and 4 or (val > 0.5 and 3 or 2)
    c:put(x, y, SIL[i], { r = { name = "leaf" } })
  else
    local i = 1
    for j, tt in ipairs{ 0.2, 0.38, 0.55, 0.7, 0.86 } do if val >= tt then i = j + 1 end end
    c:put(x, y, LF[i], { r = { name = "leaf" } })
  end
  if abs(s) < 0.16 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and LF[6] or LF[3]) end
  -- side veins
  local len = sqrt((lb[1] - la[1]) ^ 2 + (lb[2] - la[2]) ^ 2)
  for _, vt in ipairs{ 6, 11, 16, 21 } do
    local d = t * len - (vt + abs(s) * 2.6)
    if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.75 and s < 0.45 then c:put(x, y, LF[5]) end
  end
end)
-- petiole
for _, p in ipairs{ { 26, 23 }, { 25, 24 }, { 24, 24 } } do c:put(p[1], p[2], SEP[3]) end

-- whole fruit: slim egg, tilted
local FX, FY = 23, 36
local fm, fn = G.oval(FX, FY, 8.5, 14, 0.28)
G.ao(c, lm, fm, LF[1], 1, 1)
local bias = {}
fm:each(function(x, y)
  local h = G.hash(x, y, 4)
  if h < 0.07 then bias[K(x, y)] = 1 elseif h > 0.93 then bias[K(x, y)] = -1 end
end)
local fidx = G.shade(c, fm, fn, SK, { bias = bias, amb = 0.06, wrap = 0.22 })
-- bumps: lit pixel with a shade pixel below-right
fm:each(function(x, y)
  local i = fidx[K(x, y)]
  if G.hash(x, y, 13) < 0.045 and i >= 3 and fm:has(x + 1, y + 1) then
    c:put(x, y, SK[min(6, i + 1)]) c:put(x + 1, y + 1, SK[max(1, i - 1)])
  end
end)
-- waxy bloom: dusty pale flecks on the lit upper-left
fm:each(function(x, y)
  local i = fidx[K(x, y)]
  if i >= 4 and G.hash(x, y, 21) < 0.16 then c:put(x, y, BLOOM) end
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(fn)
fm:edge():each(function(x, y) if rim[K(x, y)] > 0.62 then c:put(x, y, "#4f7a7a") end end)
-- specular
c:put(18, 28, "#e4f0c4") c:put(19, 28, "#e4f0c4") c:put(18, 29, CREAM)
-- dried sepal crown at the top end (axis tilted 0.28 rad)
local ux, uy = sin(0.28), -cos(0.28)
local tx, ty = floor(FX + ux * 14 + .5), floor(FY + uy * 14 + .5)
for _, p in ipairs{ { -1, 1 }, { 0, 1 }, { 1, 1 }, { 0, 0 }, { -2, 0 }, { 2, 0 }, { -3, -1 }, { 3, -1 }, { -1, -1 }, { 1, -2 } } do
  c:put(tx + p[1], ty + p[2], (p[2] < 0) and SEP[3] or SEP[2])
end
c:put(tx, ty + 1, SEP[1]) c:put(tx - 1, ty, SEP[1])
c:put(tx + 1, ty - 2, SEP[3]) c:put(tx + 2, ty - 3, SEP[2]) c:put(tx - 3, ty - 2, SEP[2])
-- stem stub at the bottom end
local bx2, by2 = floor(FX - ux * 14 + .5), floor(FY - uy * 14 + .5)
c:put(bx2, by2 + 1, SEP[2])

-- halved fruit (cut face toward the viewer, lower right)
local HX, HY = 42, 42
local hs = HP.ellipse(HX + 1, HY + 1, 10, 8)
local face = HP.ellipse(HX, HY, 9.5, 7.5)
G.ao(c, fm, hs:copy():add(face), SK[1], 0, 0)
G.shade(c, hs, X.sphere(HX + 1, HY + 1, 10, hs), SK, { amb = 0.05 })
-- cut face rings
face:each(function(x, y)
  local ex, ey = (x - HX) / 10, (y - HY) / 8
  local q = sqrt(ex * ex + ey * ey)
  local col
  if q > 0.9 then col = SK[3]
  elseif q > 0.82 then col = SK[5]
  elseif q > 0.5 then
    col = FLs[3]
    if ex + ey > 0.7 then col = FLs[2] end
    if ex + ey < -0.6 then col = FLs[4] end
    if G.hash(x, y, 31) < 0.08 then col = FLs[2] end
  else
    col = JEL[2]
  end
  c:put(x, y, col, { r = { name = "face" } })
end)
-- jelly: four locules in a cross with seeds, glassy rim
local jel = HP.ellipse(HX, HY, 4.6, 3.6)
jel:each(function(x, y)
  local dx, dy = x - HX, y - HY
  local col = JEL[2]
  if abs(dx) <= 0 or abs(dy) <= 0 then col = FLs[3] end      -- pale cross walls
  if (dx == -2 and dy == -1) or (dx == 2 and dy == -1) or (dx == -2 and dy == 1) or (dx == 2 and dy == 1) then col = "#4a3a24" end
  if (dx == -3 and dy == -1) or (dx == 3 and dy == 1) then col = JEL[4] end
  if dx + dy > 3 then col = JEL[1] end
  c:put(x, y, col)
end)
c:put(HX, HY, JEL[3])
HP.ellipse(HX, HY, 5.6, 4.6):cut(jel):each(function(x, y) if x + y < HX + HY then c:put(x, y, JEL[3]) end end)
c:put(HX - 4, HY - 4, CREAM) c:put(HX - 3, HY - 4, FLs[4])

-- quirk: teaspoon stuck in the jelly, handle out to the upper right
local sp = {}
for i = 0, 13 do sp[#sp + 1] = { HX + 2 + floor(i * 0.85 + .5), HY - 1 - i } end
local hm = HP.mask()
for _, p in ipairs(sp) do hm:set(p[1], p[2]) hm:set(p[1] + 1, p[2]) end
local tip = HP.ellipse(sp[#sp][1] + 0.5, sp[#sp][2] - 1, 1.5, 1.5)
hm:add(tip)
hm:each(function(x, y)
  local col = STL[3]
  if not hm:has(x - 1, y) then col = STL[5] end
  if not hm:has(x + 1, y) then col = STL[2] end
  c:put(x, y, col, { r = { name = "spoon" } })
end)
-- spoon neck enters the jelly: dark slot + bowl ghost under the jelly
c:put(HX + 2, HY, "#4a3a24") c:put(HX + 3, HY, JEL[1])
c:put(sp[#sp][1], sp[#sp][2] - 1, STL[5]) c:put(sp[#sp][1] + 1, sp[#sp][2] - 2, CREAM)

G.save(c, "feijoa")
