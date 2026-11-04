-- cloudberry-jam (final, Opus single pass). Slim glass jar (rounded shoulders, short neck) full of glowing amber
-- jam: per-pixel cylinder light through the glass, darker core toward the base, whole drupelets and seed specks
-- suspended in it, a pale air gap under the lid. Glass: bright left rim streak, pale core reflection, cool right
-- edge, thick base. Lid: gingham cloth cover (diagonal weave, pinked hem flaring out) tied with twisted twine and a
-- small bow; cream paper label with a tiny cloudberry. Ground shadow (stands).
-- quirk: one drip of jam has escaped from under the cloth and runs down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local NAME = "cloudberry-jam"
local c = A.new(NAME)
local JAM   = { "#5e1f1e", "#8e3418", "#c45a18", "#e58421", "#f8ab34", "#ffd06a" }
local GLASS = { "#3a6a86", "#6aa4b8", "#a6d6da", "#d8f2ee", "#f2fbf6" }
local CLOTH = { "#6e2038", "#a3343c", "#d4503f", "#ee7a5a" }   -- red check
local CREAMR = { "#b8a68e", "#dccbb0", "#f2e6cc", "#fff4d6" }
local TW    = { "#6b4a2a", "#a0763e", "#d0a860" }
local LAB   = { "#c8b694", "#e8dcbc", "#fbf0d6" }

local CX = 31.5
c:groundShadow(32, 56, 14, 2)

-- jar body: rounded rect with rounded shoulders; neck
local jar = HP.mask()
jar:add(c:rrect(19, 24, 44, 55, 6))
jar:add(c:rect(23, 19, 40, 26))
local jtok, gtok = A.tok("jam"), A.tok("glass")
-- normals: cylinder across x, bottom rounding from pillow
local np = X.pillow(jar, 4)
local n = {}
jar:each(function(x, y) local k = K(x, y)
  local hw = (y <= 22) and 9 or 13
  local u = max(-0.97, min(0.97, (x - CX) / (hw + 0.5)))
  n[k] = { A.norm(u * 0.9 + np[k][1] * 0.3, np[k][2] * 0.8, sqrt(1 - u*u)) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local JTOP = 27
local inner = jar:shrink(1)
local jamM = HP.mask()
inner:each(function(x, y) if y >= JTOP and y <= 53 then jamM:set(x, y) end end)
local bias = {}
-- jam gets darker toward the core/bottom (thick), lighter near the lit wall
jamM:each(function(x, y) local k = K(x, y) if y > 47 then bias[k] = -1 end end)
local jidx = X.tone(c, jamM, v, JAM, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, bias = bias, tok = jtok })
-- meniscus: lighter row at the jam top, dark row under it
jamM:each(function(x, y) if y == JTOP then c:put(x, y, JAM[5], jtok) elseif y == JTOP + 1 then c:put(x, y, JAM[3], jtok) end end)
-- suspended drupelets: small round beads with a lit top-left pixel and a dark lower rim
for _, b in ipairs{ { 25, 34 }, { 36, 31 }, { 31, 42 }, { 39, 46 }, { 24, 48 }, { 34, 51 } } do
  local bx, by = b[1], b[2]
  local m = A.ell(bx, by, 1.6, 1.6)
  m:each(function(x, y) if jamM:has(x, y) then
    local d = (x - bx) + (y - by)
    c:put(x, y, d < -1 and JAM[6] or (d > 1 and JAM[2] or JAM[4]), jtok) end end)
end
-- seed specks
for _, s in ipairs{ { 28, 31 }, { 33, 36 }, { 22, 40 }, { 41, 38 }, { 28, 46 }, { 37, 41 }, { 30, 53 } } do
  if jamM:has(s[1], s[2]) then c:put(s[1], s[2], JAM[1], jtok) end end
-- empty glass above the jam (air gap) and the glass wall
local air = HP.mask()
inner:each(function(x, y) if y < JTOP then air:set(x, y) end end)
air:each(function(x, y) local k = K(x, y)
  local val = v[k] c:put(x, y, val > 0.7 and GLASS[4] or (val > 0.4 and GLASS[3] or GLASS[2]), gtok) end)
jar:edge():each(function(x, y) local k = K(x, y)
  local col = GLASS[2]
  if x < CX - 4 then col = GLASS[3] end
  if x > CX + 4 or y >= 54 then col = GLASS[1] end
  c:put(x, y, col, gtok) end)
-- thick glass base: 2 rows
for x = 21, 42 do if jar:has(x, 54) then c:put(x, 54, x < 30 and GLASS[2] or GLASS[1], gtok) end end
for x = 23, 40 do if jar:has(x, 53) then c:put(x, 53, x < 28 and GLASS[3] or GLASS[2], gtok) end end
-- glass reflections: bright streak on the lit shoulder + side, pale core strip right of centre
for y = 29, 47 do c:put(21, y, GLASS[5], gtok) if y > 31 and y < 44 then c:put(22, y, GLASS[4], gtok) end end
c:put(22, 27, GLASS[5], gtok) c:put(23, 26, GLASS[5], gtok) c:put(22, 28, GLASS[4], gtok)
for y = 33, 46 do if y % 7 ~= 3 then c:put(38, y, JAM[6], jtok) end end
c:put(21, 30, A.CREAM, gtok)
-- cool reflected light lower right wall
for y = 40, 51 do c:put(43, y, GLASS[2], gtok) end

-- label: cream paper, 1 px darker frame row on the bottom/right, tiny cloudberry
local lab = c:rect(24, 37, 38, 45)
local ltok = A.tok("label")
lab:each(function(x, y)
  local col = LAB[2]
  if y == 37 or x == 24 then col = LAB[3] end
  if y == 45 or x == 38 then col = LAB[1] end
  c:put(x, y, col, ltok) end)
-- curl of the label edge: a 1 px darker strip between label and glass on the right (ambient)
for y = 38, 45 do c:put(39, y, JAM[2], jtok) end
local pic = { "..g.", ".gG.", "oOOo", "OOOh", "oOOo", ".oo." }
local PC = { g = "#6ab455", G = "#2e7646", o = "#d4691c", O = "#f5a234", h = "#ffe28e" }
for j, row in ipairs(pic) do for i = 1, #row do local ch = row:sub(i, i)
  if PC[ch] then c:put(28 + i, 37 + j, PC[ch], ltok) end end end
-- two ink-brown writing dashes
for _, x in ipairs{ 26, 27, 34, 35, 36 } do c:put(x, 43, "#8a6a52", ltok) end

-- quirk: jam drip from under the cloth down the glass (painted before the cloth so the cloth hem overlaps)
local dtok = A.tok("drip")
for y = 21, 29 do c:put(36, y, y < 27 and JAM[4] or JAM[3], dtok) c:put(37, y, JAM[2], dtok) end
c:put(36, 30, JAM[3], dtok) c:put(37, 30, JAM[2], dtok) c:put(36, 31, JAM[2], dtok) c:put(37, 31, JAM[1], dtok)
c:put(36, 25, JAM[6], dtok)

-- cloth cover: dome over the lid, flaring pinked hem
local ctok = A.tok("cloth")
local cl = HP.mask()
cl:add(A.ell(CX, 16, 11, 5))
cl:add(c:poly{ { 21, 16 }, { 42, 16 }, { 46, 23 }, { 17, 23 } })
-- pinked hem: notch every 3rd pixel on the bottom row
for x = 15, 48 do if x % 3 == 0 then cl.s[K(x, 23)] = nil end end
local cn = X.pillow(cl, 3)
local cv = X.light(cn, { amb = 0.1, wrap = 0.25 })
cl:each(function(x, y) local k = K(x, y)
  local val = cv[k]
  -- gingham: 3 px checks on the diagonal weave
  local a, b = floor((x + y) / 3) % 2, floor((x - y + 64) / 3) % 2
  local ch = a + b
  local col
  if ch == 2 then col = CLOTH[val > 0.6 and 3 or 2]
  elseif ch == 1 then col = (val > 0.6) and CLOTH[4] or CLOTH[3]
  else col = (val > 0.6) and CREAMR[4] or (val > 0.35 and CREAMR[3] or CREAMR[2]) end
  if val < 0.25 then col = (ch == 0) and CREAMR[1] or CLOTH[1] end
  c:put(x, y, col, ctok) end)
-- fold lines down the flare
for _, f in ipairs{ { 20, 19, 18, 22 }, { 27, 19, 26, 22 }, { 36, 19, 37, 22 }, { 43, 19, 45, 22 } } do
  A.stroke(c, { { f[1], f[2] }, { f[1], f[2] + 1 }, { f[3], f[4] - 1 }, { f[3], f[4] } }, function() return CLOTH[1] end, ctok, 8)
end
-- twine: twisted band at y 19..20 across the neck, alternating lit/dark pixels
local ttok = A.tok("twine")
for x = 20, 43 do
  if cl:has(x, 19) then c:put(x, 19, (x % 2 == 0) and TW[3] or TW[2], ttok) c:put(x, 20, (x % 2 == 0) and TW[1] or TW[2], ttok) end
end
-- bow on the right with two hanging tails
local bow = { "aB.Ba", "bBkBb", "aB.Ba" }
local BC = { a = TW[3], B = TW[2], b = TW[1], k = TW[1] }
for j, row in ipairs(bow) do for i = 1, #row do local ch = row:sub(i, i)
  if BC[ch] then c:put(41 + i, 17 + j, BC[ch], ttok) end end end
for _, p in ipairs{ { 44, 21, 2 }, { 44, 22, 1 }, { 45, 23, 2 }, { 46, 21, 2 }, { 47, 22, 1 }, { 47, 23, 3 } } do
  c:put(p[1], p[2], TW[p[3]], ttok) end
-- AO under the cloth hem on the glass
for x = 18, 45 do if jar:has(x, 24) and not cl:has(x, 24) then c:put(x, 24, GLASS[1], gtok) end end

A.save(c, NAME)
