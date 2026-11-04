-- gooseberry-jam (B3, Opus single pass aB35_3). A slim glass jar of golden-green gooseberry jam: cylinder-lit glass with a
-- bright left rim, a broken specular streak, cool teal reflected edge, empty headspace and a thick pale glass base. Whole
-- striped gooseberries float in the jam. Red gingham cloth cover gathered by twisted twine (pinched waist, pointed hem,
-- fold lines), a cream label wrapped round the curve with a tiny gooseberry and hand-written lines. Ground shadow.
-- quirk: one fresh gooseberry dangles from the loose twine end like a gift tag.
local NAME = "gooseberry-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local JAM = { "#2a3a22", "#41592a", "#5f7d2e", "#86a236", "#b2c649", "#dde57e" }
local BER = { "#4f7a2c", "#78a43c", "#a8cc5c", "#d2ea8e", "#f0f8c4" }
local GL = { "#46708a", "#73a3b8", "#a2cdd8", "#cceaee", "#ecfaf6" }
local CRM = { "#8a6e54", "#b39672", "#d8bf98", "#efdcb6", "#fff4d6" }
local TW = { "#6a4630", "#9a6c44", "#c69a62", "#e6c48a" }
local G_BOTH = { "#6a1c32", "#99283c", "#c43e48", "#de5a54" }
local G_ONE = { "#a83e4a", "#d0605e", "#ee867a", "#ffae98" }
local G_NONE = { "#b89a86", "#dcc4aa", "#f2e4c6", "#fff4d6" }
local TEAL = "#4e8a7c"

c:groundShadow(31.5, 57, 15, 2)

-- jar body (slim cylinder) ------------------------------------------------------------
local body = HP.rrect(20, 22, 43, 56, 6)
body:add(HP.rect(22, 20, 41, 24))
local cx, hw = 31.5, 12
local np = X.pillow(body, 4)
local jn = {}
body:each(function(x, y) local k = K(x, y)
  local nx = max(-0.96, min(0.96, (x - cx) / (hw + 0.5)))
  local p = np[k]
  jn[k] = { A.norm(nx * 0.85 + p[1] * 0.15, p[2] * 0.9, sqrt(1 - nx * nx)) }
end)
local jv = X.light(jn, { amb = 0.1, wrap = 0.3 })

-- regions: glass wall (1px), headspace (y<27), thick base (y>=53), jam elsewhere
local wall = body:edge()
local bias = {}
-- skirt of the cloth casts on the glass shoulder
for x = 19, 44 do for y = 24, 26 do if body:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - (y == 24 and 2 or 1) end end end
local function ti(v, n, b) local cuts = n == 6 and { 0.2, 0.36, 0.52, 0.68, 0.84 } or { 0.24, 0.46, 0.66, 0.84 }
  local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return max(1, min(n, i + (b or 0))) end
local gtok, jtok = { r = { name = "glass" } }, { r = { name = "jam" } }
body:each(function(x, y) local k = K(x, y) local v = jv[k]
  if y < 27 or y >= 53 or wall:has(x, y) then
    c:put(x, y, GL[ti(v, 5, bias[k])], gtok)
  else
    c:put(x, y, JAM[ti(v, 6, bias[k])], jtok)
  end
end)
-- jam surface meniscus
for x = 22, 41 do c:put(x, 27, (x < 26 or x > 38) and JAM[4] or JAM[5], jtok) end
for x = 23, 40 do c:put(x, 28, JAM[3], jtok) end
-- thick base: dark seam above the glass foot, bright foot edge
for x = 22, 41 do c:put(x, 52, JAM[1], jtok) end
for x = 23, 34 do c:put(x, 54, GL[5], gtok) end

-- floating gooseberries (striped, translucent) ----------------------------------------
local berries = { { 26, 32, 3.2 }, { 37, 31, 2.8 }, { 24, 48, 3.0 }, { 38, 49, 3.3 }, { 31, 50, 2.6 } }
for i, b in ipairs(berries) do
  local m, n = A.oval(b[1], b[2], b[3], b[3] * 0.85, 0.3, 0.8)
  m:clip(body):cut(wall)
  local idx = A.shade(c, m, n, BER, { cuts = { 0.24, 0.46, 0.66, 0.84 }, amb = 0.05 })
  m:each(function(x, y) local k = K(x, y)
    if (x - b[1] + floor((y - b[2]) * 0.4)) % 3 == 0 and idx[k] > 1 then c:put(x, y, BER[max(1, idx[k] - 1)]) end end)
  -- jam AO ring below-right
  m:shift(1, 1):each(function(x, y) if not m:has(x, y) and body:has(x, y) and not wall:has(x, y) and y < 52 and y > 28 then c:put(x, y, JAM[1], jtok) end end)
  local sx, sy = A.specAt(m, n, 30) if sx then c:put(sx, sy, GL[5]) end
end

-- label wrapped round the cylinder ------------------------------------------------------
local lab = HP.rect(24, 34, 39, 45)
lab:set(24, 46):set(25, 46) for x = 27, 39 do if x % 3 ~= 1 then lab:set(x, 46) end end -- torn-ish bottom
lab:shift(1, 1):each(function(x, y) if not lab:has(x, y) and body:has(x, y) then c:put(x, y, JAM[1], jtok) end end)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) local k = K(x, y) local v = jv[k]
  local i = ti(v + 0.12, 5) if y == 34 then i = min(5, i + 1) end
  c:put(x, y, CRM[i], ltok) end)
-- tiny gooseberry on the label
local lm, ln = A.oval(31, 39, 2.6, 2.2, 0, 0.8)
A.shade(c, lm, ln, BER, { cuts = { 0.24, 0.46, 0.66, 0.84 } })
c:put(30, 38, GL[5]) c:put(31, 40, BER[2]) c:put(32, 39, BER[2]) c:put(29, 39, BER[2])
c:put(33, 36, TW[1]) c:put(34, 35, TW[2]) c:put(32, 37, "#4a6a2a")
-- hand-written lines
for x = 26, 37 do if x % 4 ~= 3 then c:put(x, 43, CRM[1], ltok) end end
for x = 28, 35 do if x % 3 ~= 2 then c:put(x, 45, CRM[2], ltok) end end

-- glass cues: bright left rim, broken specular streak, cool reflected right edge
local x0, x1 = {}, {}
body:each(function(x, y) if not x0[y] or x < x0[y] then x0[y] = x end if not x1[y] or x > x1[y] then x1[y] = x end end)
for y = 27, 51 do if not lab:has(x0[y], y) then c:put(x0[y], y, GL[4], gtok) end end
for y = 29, 51 do if not lab:has(23, y) and (y < 33 or y > 46) and y ~= 31 then c:put(22, y, GL[5], gtok) end end
for y = 29, 32 do c:put(24, y, GL[4], gtok) end
for y = 47, 51 do c:put(24, y, GL[4], gtok) end
for y = 30, 51 do c:put(x1[y], y, TEAL, gtok) end

-- cloth cover: dome, twine pinch, flared pointed skirt ----------------------------------
local cloth = HP.ellipse(31.5, 15.5, 13, 6)
cloth:cut(HP.rect(0, 19, 63, 63))
cloth:add(HP.rect(21, 18, 42, 20))
for y = 21, 24 do
  local e = 22 - (y - 21) * 1.0
  for x = floor(e), floor(63 - e) do
    local ph = (x - 18) % 4
    local hem = 24 - ((ph == 0 or ph == 3) and 1 or 0)
    if y <= hem then cloth:set(x, y) end
  end
end
local cn = X.pillow(cloth, 3)
-- puckered folds: perturb normals in vertical bands
cloth:each(function(x, y) local k = K(x, y)
  local f = sin((x - 18) * pi / 2.5) * (y > 20 and 0.45 or 0.18)
  local p = cn[k] cn[k] = { A.norm(p[1] + f, p[2], p[3]) } end)
local cvv = X.light(cn, { amb = 0.08, wrap = 0.3 })
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local i = ti(cvv[k], 4, (y >= 18 and y <= 20) and -1 or 0)
  local sx = (x % 4) < 2
  local sy = (y % 4) < 2
  local pal = (sx and sy) and G_BOTH or ((sx or sy) and G_ONE or G_NONE)
  c:put(x, y, pal[i], ctok)
end)

-- twine (twisted) + bow + loose ends ---------------------------------------------------
local ttok = { r = { name = "twine" } }
for x = 21, 42 do
  c:put(x, 19, ((x) % 2 == 0) and TW[4] or TW[3], ttok)
  c:put(x, 20, ((x) % 2 == 0) and TW[2] or TW[1], ttok)
end
-- bow loops right of centre
local loops = {
  { 34, 15, "..aab.aab.." },
  { 34, 16, ".a..cbb..c." },
  { 34, 17, "a...bcb...c" },
  { 34, 18, ".acc.b.acc." },
}
local map = { a = TW[4], b = TW[2], c = TW[3] }
for _, r in ipairs(loops) do for i = 1, #r[3] do local ch = r[3]:sub(i, i)
  if map[ch] then c:put(r[1] + i - 1, r[2], map[ch], ttok) end end end
-- loose ends: one short, one long trailing over the right shoulder down to the berry
for _, p in ipairs{ { 38, 21, 3 }, { 37, 22, 2 }, { 37, 23, 1 } } do c:put(p[1], p[2], TW[p[3] + 1], ttok) end
local tail = { { 42, 20 }, { 44, 21 }, { 45, 22 }, { 46, 23 }, { 47, 24 }, { 48, 25 }, { 48, 26 } }
for i, p in ipairs(tail) do c:put(p[1], p[2], i % 2 == 0 and TW[2] or TW[3], ttok) end

-- quirk: a gooseberry tied to the twine end
local qm, qn = A.oval(48.5, 31, 3.4, 4.3, 0, 0.85)
local qidx = A.shade(c, qm, qn, BER, { cuts = { 0.22, 0.44, 0.64, 0.84 }, amb = 0.05 })
qm:each(function(x, y) local k = K(x, y)
  if (abs(x - 48.5) > 0.6 and abs(x - 48.5) < 1.6 or abs(x - 48.5) > 2.4 and abs(x - 48.5) < 3.1) and y > 28 and y < 34 then
    c:put(x, y, BER[max(1, qidx[k] - 1)]) end end)
c:put(47, 29, GL[5]) c:put(46, 30, BER[5])
-- calyx tail at the bottom and stalk knot at top
c:put(48, 27, TW[1]) c:put(49, 27, "#4a6a2a")
c:put(48, 36, TW[2]) c:put(49, 36, TW[1])
-- jar shadow from the hanging berry
qm:shift(-2, 1):each(function(x, y) if not qm:has(x, y) and body:has(x, y) and x == x1[y] then c:put(x, y, JAM[1], jtok) end end)

A.save(c, NAME)
