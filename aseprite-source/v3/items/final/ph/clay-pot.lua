-- clay-pot (Opus single pass). Slim wheel-thrown terracotta pot: rolled flared lip seen a little from above (dark
-- mouth), narrow neck, high shoulder, long taper to a small turned foot. Lathe normals -> 6-tone terracotta, cool
-- reflected light on the right, throwing rings, an incised wave band on the shoulder, AO under the lip and above
-- the foot, twisted twine tied round the neck with a frayed tail. Ground shadow.
-- quirk: a tiny snail is climbing the shoulder.
local NAME = "clay-pot"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sin, abs, sqrt = math.floor, math.max, math.min, math.sin, math.abs, math.sqrt
local c = A.new2(NAME)
local CL = { "#4e2219", "#7c3524", "#a84d2e", "#c9683a", "#e08b55", "#f5b47e" }
local COOL = "#8a5a6a"
local CX = 32

c:groundShadow(CX, 56, 15, 1)
-- profile
local function R(y)
  if y < 15 then return 0 end
  if y <= 19 then return 5.6 + (y - 15) * 0.1 end                     -- neck
  if y <= 32 then local t = (y - 19) / 13 return 6 + 7.4 * sin(t * math.pi / 2) ^ 1.3 end -- shoulder
  if y <= 50 then local t = (y - 32) / 18 return 13.4 - 7.4 * t ^ 1.35 end -- taper
  if y <= 51 then return 5.2 end                                       -- waist above foot
  return 6.6                                                           -- foot ring 52..54
end
local bm, bn, BU = A.lathe(CX, 15, 54, R)
local bias = {}
for y = 15, 17 do for x = 20, 44 do if bm:has(x, y) then bias[K(x, y)] = (y == 15) and -2 or -1 end end end  -- AO under lip
for x = 20, 44 do if bm:has(x, 51) then bias[K(x, 51)] = -1 end if bm:has(x, 50) then bias[K(x, 50)] = (bias[K(x, 50)] or 0) end end
local btok = { r = { name = "clay" } }
local bidx = A.shade(c, bm, bn, CL, { bias = bias, tok = btok, rim = COOL, rimT = 0.5, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
-- foot ring separation line + pale turned edge
for x = 24, 40 do if bm:has(x, 52) then c:put(x, 52, (x < CX) and CL[5] or CL[3], btok) end end
for x = 24, 40 do if bm:has(x, 51) then c:put(x, 51, CL[1], btok) end end
-- throwing rings: faint darker rows, broken, only across the front
for _, y in ipairs{ 35, 39, 43, 47 } do
  for x = 18, 46 do local k = K(x, y)
    if bm:has(x, y) and abs(BU[k]) < 0.78 and (x + y) % 7 ~= 0 then c:put(x, y, CL[max(1, (bidx[k] or 3) - 1)], btok) end end
end
-- incised wave band on the shoulder (dark groove + lit lower lip of the groove)
for x = 20, 44 do
  local u = (x + 0.5 - CX) / 13
  if abs(u) < 0.86 then
    local y = 27 + floor(1.2 * sin(x * 0.9) + 0.5)
    local k = K(x, y)
    if bm:has(x, y) then c:put(x, y, CL[max(1, (bidx[k] or 3) - 2)], btok) end
    if bm:has(x, y + 1) and u < 0.4 then c:put(x, y + 1, CL[min(6, (bidx[K(x, y + 1)] or 3) + 1)], btok) end
  end
end
for x = 21, 43 do if bm:has(x, 24) and (x % 2 == 0) and abs(x + 0.5 - CX) < 10 then c:put(x, 24, CL[max(1, (bidx[K(x, 24)] or 3) - 1)], btok) end end
-- specular streak: vertical 1x4 on the lit belly + one on the shoulder
for y = 31, 35 do c:put(25, y, CL[6], btok) end
c:put(26, 22, CL[6], btok) c:put(26, 23, CL[6], btok)

-- lip: rolled rim (torus-ish ellipse) seen from slightly above
local lip = HP.mask()
local ln = {}
for y = 8, 16 do for x = 18, 46 do
  local dx, dy = (x + 0.5 - CX) / 10.6, (y + 0.5 - 12) / 3.6
  local q = dx * dx + dy * dy
  if q <= 1 then lip:set(x, y)
    local nz = sqrt(max(0.05, 1 - q)) ln[K(x, y)] = { dx * 0.9, dy * 1.2, nz } end
end end
for k, v in pairs(ln) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) ln[k] = { v[1]/l, v[2]/l, v[3]/l } end
local ltok = { r = { name = "lip" } }
A.shade(c, lip, ln, CL, { tok = ltok, rim = COOL, rimT = 0.6, cuts = { 0.18, 0.36, 0.52, 0.68, 0.84 } })
-- mouth: dark opening, deeper at back, lit inner wall at front-right
local mouth = HP.mask()
for y = 9, 13 do for x = 22, 42 do
  local dx, dy = (x + 0.5 - CX) / 7.6, (y + 0.5 - 11.4) / 1.9
  if dx * dx + dy * dy <= 1 then mouth:set(x, y) end end end
mouth:each(function(x, y)
  local col = "#2e1418"
  if y >= 12 then col = CL[1] end
  if y == 12 and x > CX + 1 then col = CL[2] end
  if y <= 10 then col = "#22101a" end
  c:put(x, y, col, ltok)
end)
-- rolled lip highlight along the front rim
for x = 23, 30 do c:put(x, 14, CL[6], ltok) end
c:put(20, 11, CL[6], ltok) c:put(20, 12, CL[6], ltok)

-- twine round the neck: two-ply twist (diagonal light/dark pairs) + tail with frayed end
local TW = { "#5a4030", "#9a7a50", "#d8b880", "#f2dca8" }
local ttok = { r = { name = "twine" } }
for x = 26, 38 do
  for dy = 0, 1 do
    local y = 17 + dy
    local ph = (x + dy) % 3
    local u = (x + 0.5 - CX) / 6.2
    local base = ph == 0 and 1 or (ph == 1 and 3 or 2)
    if u > 0.5 then base = max(1, base - 1) end
    if u < -0.3 and ph == 1 then base = 4 end
    c:put(x, y, TW[base], ttok)
  end
end
-- knot + tail hanging on the right
c:put(38, 16, TW[2], ttok) c:put(39, 17, TW[3], ttok) c:put(39, 18, TW[2], ttok) c:put(40, 17, TW[1], ttok)
local tail = { {40, 19}, {41, 20}, {41, 21}, {42, 22}, {42, 23}, {43, 24}, {43, 25} }
for i, p in ipairs(tail) do c:put(p[1], p[2], (i % 2 == 0) and TW[3] or TW[2], ttok) end
c:put(42, 26, TW[2], ttok) c:put(44, 26, TW[3], ttok) c:put(43, 27, TW[1], ttok)
-- contact shadow under the tail on the pot
for i, p in ipairs(tail) do local x, y = p[1] - 1, p[2] + 1 if bm:has(x, y) and i > 1 then c:put(x, y, CL[max(1, (bidx[K(x, y)] or 3) - 1)], btok) end end

-- quirk: snail on the left shoulder (shell spiral + soft body + eyestalks)
local SH = { "#4a2a40", "#8a5a3a", "#c88c4a", "#f0c070" }
local BO = { "#6a6a5a", "#b8b090", "#e0d8b0" }
local stok = { r = { name = "snail" } }
-- body along the pot edge going up
for _, p in ipairs{ {19, 33, 2}, {19, 32, 2}, {18, 31, 2}, {18, 30, 3}, {18, 29, 3}, {17, 28, 2} } do c:put(p[1], p[2], BO[p[3]], stok) end
c:put(16, 27, BO[1], stok) c:put(15, 26, BO[2], stok) c:put(17, 27, BO[2], stok)  -- stalks
c:put(18, 34, BO[1], stok)
-- shell disc
local sm = A.ellipse and nil
local shell = HP.mask()
for y = 29, 34 do for x = 14, 19 do local dx, dy = x + 0.5 - 16.8, y + 0.5 - 31.6 if dx*dx + dy*dy <= 7.2 then shell:set(x, y) end end end
shell:each(function(x, y)
  local dx, dy = x + 0.5 - 16.8, y + 0.5 - 31.6
  local i = (dx + dy < -1) and 4 or ((dx + dy < 1.5) and 3 or 2)
  c:put(x, y, SH[i], stok)
end)
c:put(17, 31, SH[1], stok) c:put(16, 32, SH[1], stok) c:put(16, 31, SH[2], stok) c:put(15, 30, SH[4], stok)

A.run(c, NAME)
