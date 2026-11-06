-- fig-jam (Opus single pass, aB31_3). A slim glass preserve jar of dark fig jam: per-pixel cylinder light on the jam
-- (6-tone plum, golden fig-seed specks), glass wall with a bright rim, a pale headspace under the neck, a thick pale base,
-- tall specular streak on the left and cool bounce on the right. Kraft paper label (lit as a wrapped band) with a little
-- fig drawn on it. Red gingham cloth cover gathered over the lid with fold lines and a pinked hem, tied with twisted twine
-- in a bow. Ground shadow under the jar.  quirk: a slow drip of jam escapes from under the cloth and runs down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("fig-jam")
local PLUM  = { "#230d27", "#3a1538", "#56204c", "#762f62", "#9a457a", "#c46c9c" }
local GLASS = { "#3f5f7e", "#62889f", "#93bcc8", "#c6e4ea", "#eaf8f6" }
local KRAFT = { "#6e4e34", "#987248", "#bf9866", "#d8b884", "#ecd6a6", "#fbecc8" }
local RED   = { "#5e1a30", "#8e2338", "#c0353a", "#e5523f", "#f57d5c", "#ffab84" }
local PINK  = { "#7a3a4a", "#a8505a", "#d47468", "#ee9a84", "#fbbfa2", "#ffdcc4" }
local CRM   = { "#8a7680", "#b4a0a0", "#d6c6bc", "#ece0cc", "#f8efd8", "#fff4d6" }
local TWINE = { "#7a5530", "#b08850", "#e6c88a" }
local SEEDC = { "#b88444", "#e2b46a" }

c:groundShadow(32, 59, 14, 1.4)
-- glass jar
local body = HP.rrect(21, 26, 43, 58, 5)
local neck = HP.rect(24, 23, 40, 27)
local jar = body:copy():add(neck)
local gtok = A.tok("glass")
local gn = A.vcylN(jar, 21, 43, 0)
A.tone(c, jar, gn, GLASS, { tok = gtok, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.5, 0.7, 0.88 } })
-- jam fill (inside the glass wall, below the headspace, above the thick base)
local jam = body:shrink(1):clip(HP.rect(0, 31, 63, 55))
local jtok = A.tok("jam")
local jn = A.vcylN(jam, 22, 42, 0)
local jb = {}
jam:each(function(x, y) if y == 31 then jb[K(x, y)] = 1 end if y >= 54 then jb[K(x, y)] = -1 end end)
local jidx = A.tone(c, jam, jn, PLUM, { tok = jtok, amb = 0.04, wrap = 0.2, bias = jb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
-- fig-seed specks suspended in the jam
jam:each(function(x, y) local k = K(x, y)
  if y > 32 and y < 54 and X.hash(x, y, 3) < 0.045 then c:put(x, y, (jidx[k] or 3) >= 4 and SEEDC[2] or SEEDC[1], jtok) end end)
-- jam surface meniscus line (lit) under the headspace
for x = 23, 41 do c:put(x, 31, (x < 32) and PLUM[6] or PLUM[5], jtok) end
-- glass highlights: tall streak left, short streak, cool bounce right
for y = 30, 52 do c:put(23, y, GLASS[5], gtok) end
for y = 32, 46 do c:put(24, y, GLASS[4], gtok) end
for y = 34, 38 do c:put(26, y, GLASS[4], gtok) end
for y = 33, 53 do c:put(42, y, GLASS[3], gtok) end
for x = 25, 39 do c:put(x, 57, x < 30 and GLASS[4] or GLASS[3], gtok) end   -- thick base rim

-- kraft label wrapped around the jar
local lab = HP.rect(26, 38, 38, 50)
local ltok = A.tok("label")
local lidx = A.tone(c, lab, A.vcylN(lab, 21, 43, 0), KRAFT, { tok = ltok, amb = 0.15, wrap = 0.3 })
for x = 26, 38 do c:put(x, 38, KRAFT[lidx[K(x, 38)] >= 4 and 6 or 4], ltok) c:put(x, 50, KRAFT[2], ltok) end
-- ambient shade on the jam just below the label (paper stands off the glass)
for x = 26, 38 do c:put(x, 51, PLUM[1], jtok) end
-- little fig drawn on the label + a hand-written line
local fig = {
  "...g.",
  "..g..",
  ".pPp.",
  "pPPpd",
  "pPppd",
  ".pdd.",
}
local FC = { g = "#3f9150", p = "#6a3a86", P = "#9a6ac0", d = "#3a2252" }
for j, row in ipairs(fig) do for i = 1, #row do local ch = row:sub(i, i)
  if FC[ch] then c:put(29 + i, 40 + j, FC[ch], ltok) end end end
for x = 29, 35 do if x ~= 31 then c:put(x, 48, KRAFT[2], ltok) end end

-- gingham cloth cover gathered over the lid
local dome = HP.ellipse(32, 21, 10, 6):clip(HP.rect(0, 0, 63, 25))
local skirt = HP.poly({ { 22, 21 }, { 42, 21 }, { 46, 30 }, { 18, 30 } })
local cloth = dome:copy():add(skirt)
-- pinked hem: bottom row zig-zag
for x = 14, 50 do if x % 2 == 1 then cloth.s[K(x, 30)] = nil end end
local cn = X.pillow(cloth, 3)
-- skirt hangs down: tilt its normals outward from the centre line
for k, n in pairs(cn) do local x, y = k % 1024 - 256, k // 1024 - 256
  if y >= 24 then cn[k] = { A.norm(n[1] + (x - 32) / 18, n[2] + 0.15, n[3]) } end end
local cidx = X.tone(c, cloth, X.light(cn, { amb = 0.1, wrap = 0.3 }), RED, { cuts = A.CUTS })
local ctok = A.tok("cloth")
cloth:each(function(x, y) local k = K(x, y)
  local i = cidx[k] or 3
  -- fold lines on the skirt
  if y >= 25 and (x == 24 or x == 29 or x == 35 or x == 40) then i = i - 1 end
  if y >= 27 and (x == 25 or x == 36) then i = i + 1 end
  i = max(1, min(6, i))
  local a, b = floor((x - 1) / 3) % 2 == 0, floor(y / 3) % 2 == 0
  local r = (a and b) and RED or ((a or b) and PINK or CRM)
  c:put(x, y, r[i], ctok)
end)
-- ambient under the hem on the glass
for x = 19, 45 do if not cloth:has(x, 31) and jar:has(x, 31) then c:put(x, 31, GLASS[1], gtok) end
  if jar:has(x, 31) and cloth:has(x, 30) then c:put(x, 31, GLASS[1], gtok) end end

-- twisted twine round the gather + a bow
local ttok = A.tok("twine")
for x = 22, 42 do
  local y = 24 + (abs(x - 32) > 8 and 1 or 0)
  c:put(x, y, (x % 2 == 0) and TWINE[3] or TWINE[2], ttok)
  c:put(x, y + 1, (x % 2 == 0) and TWINE[2] or TWINE[1], ttok)
end
local bow = {
  "aaa.aaa",
  "a.bkb.a",
  ".aab aa",
  "..a.b..",
  ".a...b.",
}
local TB = { a = TWINE[3], b = TWINE[2], k = TWINE[1] }
for j, row in ipairs(bow) do for i = 1, #row do local ch = row:sub(i, i)
  if TB[ch] then c:put(24 + i, 22 + j, TB[ch], ttok) end end end

-- quirk: a drip of jam running down the glass from under the cloth
local dtok = A.tok("drip")
local drip = HP.rect(39, 30, 40, 35):add(HP.ellipse(39.5, 37, 1.6, 1.8))
local dn = X.pillow(drip, 1.5)
A.tone(c, drip, dn, PLUM, { tok = dtok, amb = 0.12, wrap = 0.3 })
c:put(39, 36, PLUM[6], dtok) c:put(38, 37, "#f2c8dc", dtok)
A.save(c, "fig-jam")
