-- raspberry-jam (final, Sonnet high). A slim shouldered glass jar of translucent ruby jam (light glows through the lower-right
-- edge, pale seeds and a few dark ones, a bright meniscus, glass streaks and a thick glass base), a little cream label with a
-- berry glyph, and a gingham cloth pom tied over the neck with twine (twist, small bow, two tails) with a gold-stitched
-- scalloped hem. Contact shadows where the cloth hangs onto the glass.
-- quirk: a fresh raspberry has been set on top of the cloth pom like a cherry.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("raspberry-jam")
local GL = { "#34506f", "#5f86a6", "#98bdd2", "#c4e0e6", "#e4f4f0", "#f8fdf6" }
local JM = { "#35081f", "#5e1034", "#8c1840", "#b92a4c", "#dc4a5e", "#f77c7e" }
local CR = { "#8a7584", "#b4a0a4", "#d8c8c0", "#efe2d2", "#fbf1de", "#fffaf0" }
local PK = { "#7a3550", "#a8506a", "#cf7384", "#e898a0", "#f6bcbe", "#ffdcd6" }
local RD = { "#5a1838", "#88224a", "#b53358", "#d4506c", "#ea7886", "#f8a4a8" }
local TW = { "#5a3a22", "#8a5e34", "#b58a50", "#d6b176", "#ebd09a", "#f8e8c0" }
local PAP = { "#8a6a66", "#b29486", "#d6bfa2", "#ecdcba", "#f8ecd0", "#fff8e6" }
local RB = { "#43102e", "#7a1840", "#aa1f49", "#d02d52", "#ee5b6c", "#ff9aa0" }
local SEP = { "#1d4234", "#2c5f3e", "#417f44", "#5f9f4a", "#89bb58", "#b6d77c" }
local CUT = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local function idxOf(v, cuts) local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return i end

-- ===== geometry
local CX = 32
c:groundShadow(CX, 56, 13, 1)
local body = c:rrect(21, 31, 43, 55, 5)
local neck = c:rect(25, 27, 39, 33)
local lip = c:rect(24, 26, 40, 28)
local J = body:copy():add(neck):add(lip)
local jam = c:rrect(23, 33, 41, 52, 3)
local cloth = HP.mask()
local hwTab = { { 15, 0.5 }, { 16, 3.5 }, { 17.5, 6.5 }, { 19, 8.2 }, { 21, 9.2 }, { 24, 9.0 }, { 26, 7.4 }, { 27, 7.4 }, { 28, 9 }, { 30, 12.2 }, { 32, 13.2 }, { 34, 13.5 } }
local function hw(y)
  if y <= hwTab[1][1] then return hwTab[1][2] end
  for i = 2, #hwTab do
    local a, b = hwTab[i - 1], hwTab[i]
    if y <= b[1] then return a[2] + (b[2] - a[2]) * (y - a[1]) / (b[1] - a[1]) end
  end
  return hwTab[#hwTab][2]
end
local function botY(x) return 30 + 2.3 * abs(sin((x - 19) * pi / 4.4)) end
for y = 15, 34 do for x = 17, 47 do
  if abs(x + 0.5 - CX) <= hw(y) and (y < 30 or y <= botY(x)) then cloth:set(x, y) end
end end

-- ===== glass + jam
local jb = {}
G.cast(jb, J, cloth, 0, 1, -1) G.cast(jb, J, cloth, 1, 2, -1) X.ao(jb, J, cloth, 1, -1)
local gtok = { r = { name = "glass" } }
J:each(function(x, y) local k = K(x, y)
  if jam:has(x, y) or cloth:has(x, y) then return end
  local u = (x + 0.5 - CX) / 11.5
  local i
  if y >= 53 then i = (y == 53) and 4 or ((y == 54) and 3 or 2)
    if x < 25 then i = i + 1 end
    if x > 39 then i = i - 1 end
  elseif u < -0.6 then i = (x <= 21) and 3 or 5
  elseif u > 0.62 then i = (x >= 43) and 2 or 3
  else i = 4 end
  if y < 33 and y >= 29 then i = max(i, 4) end
  i = max(1, min(6, i + (jb[k] or 0)))
  c:put(x, y, GL[i], gtok)
end)
-- jam: cylinder light, translucent glow on the lower-right
local jtok = { r = { name = "jam" } }
local jmin = jam:bbox()
jam:each(function(x, y) local k = K(x, y)
  local u = (x + 0.5 - CX) / 9.6
  local nz = sqrt(max(0.04, 1 - u * u))
  local nx, ny = u * 0.95, 0.12 * ((y - 43) / 10)
  local nn = { G.norm(nx, ny, nz) }
  local v = X.light({ [k] = nn }, { amb = 0.1, wrap = 0.25 })[k]
  local i = idxOf(v, { 0.3, 0.5, 0.66, 0.8, 0.92 })
  if u > 0.55 then i = (u > 0.85) and 5 or 4 end                  -- light glowing through
  if u > 0.97 then i = 3 end
  if y >= 50 and u > 0.1 then i = max(i, 4) end                  -- base caustic
  if y <= 34 then i = min(6, i + 1) end
  i = max(1, min(6, i + (jb[k] or 0)))
  local h = X.hash(x, y, 71)
  local col = JM[i]
  if h > 0.935 then col = "#e9c27c" elseif h < 0.035 and i < 5 then col = JM[1] end
  c:put(x, y, col, jtok)
end)
-- meniscus: bright line along the jam surface, dark crescent below
for x = 24, 40 do c:put(x, 33, (x < 30) and JM[6] or JM[5], jtok) end
for x = 24, 40 do c:put(x, 34, JM[2], jtok) end
c:put(25, 33, "#fff2ea") c:put(26, 33, "#fff2ea") c:put(36, 33, JM[4])
-- inner glass edge: the thin dark line where jam meets glass on the shade side
for y = 36, 51 do c:put(41, y, JM[2], jtok) end
-- glass streaks (over the jam, upper-left)
for y = 36, 46 do c:put(23, y, GL[5], gtok) end for y = 37, 42 do c:put(23, y, GL[6], gtok) end
for y = 48, 50 do c:put(23, y, GL[5], gtok) end
c:put(22, 34, GL[6]) c:put(22, 35, GL[5]) c:put(24, 34, GL[5])
-- shoulder highlight
c:put(25, 31, GL[6]) c:put(26, 31, GL[5]) c:put(22, 32, GL[5])
-- cool reflected light on the lower right glass
for y = 45, 51 do c:put(43, y, "#7fb0c6", gtok) end

-- ===== label
local lab = c:rrect(25, 40, 39, 50, 1)
local ln = X.pillow(lab, 1.5)
G.toneN(c, lab, ln, PAP, { cuts = { 0.3, 0.5, 0.68, 0.82, 0.93 }, amb = 0.25, wrap = 0.4 })
for x = 25, 39 do c:put(x, 50, PAP[2]) end                          -- paper edge shadow
for x = 26, 40 do if not lab:has(x, 51) then c:put(x, 51, JM[1]) end end   -- drop shadow on jam
for y = 41, 51 do if not lab:has(40, y) then c:put(40, y, JM[1]) end end
-- curled lower-right corner
c:put(38, 49, PAP[6]) c:put(39, 49, PAP[5]) c:put(39, 48, PAP[4])
-- berry glyph
A.map(c, {
  "..gG..",
  ".rRrR.",
  "rRrRrd",
  ".rRrd.",
  "..rd..",
}, 29, 42, { g = SEP[3], G = SEP[5], r = RB[4], R = RB[5], d = RB[2] })
c:put(30, 43, "#fff2ea") c:put(31, 44, "#fff2ea")
for x = 27, 37 do if x % 3 ~= 0 then c:put(x, 47, "#8a5e48") end end

-- ===== cloth pom
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local h = hw(y)
  local u = max(-0.97, min(0.97, (x + 0.5 - CX) / h))
  local nz = sqrt(1 - u * u)
  local nx, ny = u * 0.8, 0
  if y < 26 then ny = (y - 21) / 9 * 0.45 end
  if y >= 28 then nx = nx + sin((x - CX) * 0.72 + 0.4) * 0.5 ny = -0.15 end
  if y < 26 then nx = nx + sin((x - CX) * 0.9 + 1.7) * 0.18 end
  local v = X.light({ [k] = { G.norm(nx, ny, nz) } }, { amb = 0.1, wrap = 0.3 })[k]
  local i = idxOf(v, { 0.28, 0.46, 0.62, 0.77, 0.9 })
  -- scalloped hem edge sits in shade
  if y >= 30 and y >= botY(x) - 0.9 then i = max(1, i - 1) end
  local sx = floor((x - 17) / 4) % 2 == 0
  local sy = floor((y - 12) / 4) % 2 == 0
  local R = (sx and sy) and RD or ((sx or sy) and PK or CR)
  c:put(x, y, R[i], ctok)
end)
-- under-cloth shadow line on the hem and the first skirt fold darkening is done by the normals; add scallop separators
for x = 19, 45 do
  local ph = ((x - 19) / 4.4) % 1
  if ph < 0.12 or ph > 0.9 then for y = 29, 33 do if cloth:has(x, y) then c:put(x, y, CR[1], ctok) end end end
end
-- gold stitched hem
local pts = {}
for x = 21, 43 do pts[#pts + 1] = { x, floor(botY(x) - 1.6 + 0.5) } end
for i = 2, #pts - 1 do if not cloth:has(pts[i][1], pts[i][2]) then pts[i][2] = pts[i][2] - 1 end end
c:stitch(pts)

-- ===== twine: band over the cinched neck, bow, tails
local ttok = { r = { name = "twine" } }
for x = 24, 40 do
  local u = (x - CX) / 8
  local y = 26 + floor(1.2 * (1 - u * u) + 0.4)
  c:put(x, y, ((x % 3) == 0) and TW[5] or TW[4], ttok)
  c:put(x, y + 1, ((x % 3) == 0) and TW[3] or TW[2], ttok)
end
-- bow at front right: two open loops, a knot, two tails
local function loop(rows, x0, y0)
  A.map(c, rows, x0, y0, { a = TW[5], b = TW[4], d = TW[3], e = TW[2], f = TW[1] }, ttok)
end
loop({ ".aab", "ad.db", "be.ee" }, 31, 24)       -- left loop
loop({ "baa.", "bd.da", "ee.eb" }, 38, 24)       -- right loop
c:fillMask(c:rect(35, 26, 37, 28), TW[3], ttok) c:put(35, 26, TW[5]) c:put(36, 26, TW[5]) c:put(37, 28, TW[1]) c:put(36, 28, TW[2]) c:put(35, 28, TW[2])
-- tails
A.pline(c, { { 35, 29 }, { 34, 31 }, { 33, 33 } }, TW[3], ttok)
A.pline(c, { { 34, 29 }, { 33, 31 }, { 32, 33 } }, TW[2], ttok)
A.pline(c, { { 37, 29 }, { 38, 31 }, { 40, 33 } }, TW[3], ttok)
A.pline(c, { { 36, 29 }, { 37, 31 }, { 39, 33 } }, TW[2], ttok)
c:put(33, 33, TW[5]) c:put(40, 33, TW[5])

-- ===== the quirk: a fresh raspberry perched on top of the pom
local bx, by = 32, 14
for _, p in ipairs{ { -3, 0 }, { 3, 0 }, { -1.6, 2.8 }, { 1.6, 2.8 }, { -1.6, -2.4 }, { 1.6, -2.4 }, { 0, 0.4 } } do
  A.bead(c, bx + p[1], by + p[2], 1.9, RB, { spec = "#fff2ea" })
end
-- calyx star on top
A.pline(c, { { bx, by - 4 }, { bx - 3, by - 5 } }, SEP[4]) A.pline(c, { { bx, by - 4 }, { bx + 3, by - 5 } }, SEP[4])
A.pline(c, { { bx, by - 4 }, { bx, by - 6 } }, SEP[5])
c:put(bx, by - 3, SEP[3]) c:put(bx - 2, by - 4, SEP[2]) c:put(bx + 2, by - 4, SEP[2])
-- contact shadow of the berry on the cloth
for x = bx - 3, bx + 4 do if cloth:has(x, by + 4) then c:put(x, by + 5, RD[1]) end end

A.save(c, "raspberry-jam")
