-- meyer-lemon-marmalade (aC23_2, Opus single pass). A slim, tall glass jar of amber Meyer-lemon marmalade. Glass: per-
-- pixel cylinder light through the preserve (6-tone amber, cool-violet shade), a thin pale air gap under the lid, bright
-- vertical rim streak + glint, thick pale glass foot, peel shreds suspended in the jelly. Paper label with a tiny lemon.
-- Lid: lemon gingham cloth puffed over the neck (woven checks shaded by pillow light, fold creases, scalloped frill),
-- tied with twisted twine and a bow with hanging tails; AO band under the frill. 2-tone ground shadow.
-- quirk: a glossy marmalade drip has escaped under the cloth and runs down the glass.
local NAME = "meyer-lemon-marmalade"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local AMB  = { "#5e2232", "#9a3a2c", "#cc5e1e", "#ec8a1c", "#fbb63a", "#ffe08a" }
local AIR  = { "#4e6a80", "#7aa0ae", "#a8cfcf", "#d4eee4" }
local CLOTH = { "#6a5a72", "#a2909c", "#cfc0b8", "#ebe0cc", "#f8f0dc", "#fffaec" }
local CHK  = { "#7a4a36", "#b4742a", "#dc9e26", "#f2c43a", "#fbda68", "#fff0a4" }
local PAPER = { "#7a5a52", "#b8957a", "#dcc4a0", "#efdcb8", "#fbeed2", "#fff4d6" }
local TW   = { "#6a4636", "#9a7048", "#c8a066", "#ecd29a" }
local GLINT = "#fffbe6"

-- ground shadow (stands)
c:groundShadow(32, 57, 13, 1)

-- glass body
local X0, X1 = 22, 42
local gm = HP.rrect(X0, 26, X1, 55, 5)
local gn = {}
gm:each(function(x, y) local t = max(-.97, min(.97, ((x - X0) / (X1 - X0)) * 2 - 1)) gn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local gv = X.light(gn, { amb = 0.08, wrap = 0.3 })
-- cloth frill + puff (masks first for AO)
local puff = HP.ellipse(32, 18, 10, 5.5):add(HP.rect(23, 18, 41, 22))
local frill = HP.mask()
for y = 25, 31 do
  local f = (y - 25) / 6
  local xa, xb = floor(23 - 4 * f + .5), floor(41 + 4 * f + .5)
  for x = xa, xb do
    local ok = true
    if y >= 30 then local ph = (x - 19) % 4 ok = (y == 30) and ph ~= 0 or (ph == 1 or ph == 2) end
    if ok then frill:set(x, y) end
  end
end
local gbias = {}
A.cast(gbias, gm, frill, 0, 1, -1)
A.cast(gbias, gm, frill, 0, 2, -1)
local gtok = { r = { name = "glass" } }
local FILL = 33
local inner = gm:copy()
gm:each(function(x, y) local k = K(x, y)
  local v = gv[k]
  if y >= 52 then -- thick glass foot, pale
    local i = v > 0.6 and 6 or v > 0.35 and 5 or 4
    if y == 52 then i = i - 2 end
    c:put(x, y, AMB[max(1, i)], gtok)
  elseif y < FILL then
    local i = v > 0.75 and 4 or v > 0.5 and 3 or v > 0.3 and 2 or 1
    i = max(1, i + (gbias[k] or 0))
    c:put(x, y, AIR[i], gtok)
  else
    local i = 1
    for j, t in ipairs{ 0.2, 0.36, 0.52, 0.68, 0.9 } do if v >= t then i = j + 1 end end
    if y == FILL then i = i + 1 end -- meniscus catches light
    i = max(1, min(6, i + (gbias[k] or 0)))
    c:put(x, y, AMB[i], gtok)
  end
end)
-- peel shreds suspended in the jelly (2 px diagonal slivers)
for y = FILL + 2, 50 do for x = X0 + 2, X1 - 2 do
  local h = X.hash(x, y, 11)
  if h > 0.955 and not (x >= 26 and x <= 38 and y >= 37 and y <= 46) then
    local light = X.hash(x, y, 5) > 0.4
    c:put(x, y, light and "#ffe48a" or "#b8501e", gtok)
    if gm:has(x + 1, y - 1) then c:put(x + 1, y - 1, light and "#fbc84a" or "#9a3a2c", gtok) end
  end
end end
-- glass side walls: thin darker wall on the right, pale wall on the left
for y = 27, 51 do
  if gm:has(X1, y) then c:put(X1, y, y < FILL and AIR[1] or AMB[1], gtok) end
  if gm:has(X0, y) then c:put(X0, y, y < FILL and AIR[3] or AMB[4], gtok) end
end
-- rim streak (bright glass edge) and glint
for y = 34, 50 do if (y < 44 or y > 46) then c:put(24, y, y % 7 == 0 and AMB[5] or "#ffeeb0", gtok) end end
for y = 36, 41 do c:put(25, y, AMB[6], gtok) end
c:put(24, 35, GLINT, gtok) c:put(24, 36, GLINT, gtok)
-- cool reflected light in the foot
for x = 36, 41 do c:put(x, 54, "#c49a8a", gtok) end

-- label: paper wrapped on the cylinder
local lab = HP.rect(26, 38, 38, 46)
local labn = {}
lab:each(function(x, y) local t = max(-.97, min(.97, ((x - X0) / (X1 - X0)) * 2 - 1)) labn[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local ptok = { r = { name = "label" } }
X.tone(c, lab, X.light(labn, { amb = 0.2, wrap = 0.4 }), PAPER, { cuts = { 0.2, 0.36, 0.52, 0.72, 0.9 }, tok = ptok })
for x = 26, 38 do c:put(x, 38, PAPER[3], ptok) c:put(x, 46, PAPER[2], ptok) end
c:put(38, 39, PAPER[2], ptok) c:put(37, 38, PAPER[2], ptok) -- curled corner
-- tiny lemon + leaf on the label
local lem = {
  "....gg.",
  "..yyg..",
  ".yhyyo.",
  "yyyyyoo",
  ".oyyoo.",
  "..ooo..",
}
local LC = { y = "#f6b623", h = "#fff09a", o = "#d07a22", g = "#3c8e44" }
for yy, row in ipairs(lem) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if LC[ch] then c:put(28 + xx, 38 + yy, LC[ch], ptok) end end end

-- cloth: gingham checks with pillow light; puff then frill
local ctok = { r = { name = "cloth" } }
local function gingham(m, n, bias, crease)
  local v = X.light(n, { amb = 0.12, wrap = 0.35 })
  m:each(function(x, y) local k = K(x, y)
    local i = 1
    for j, t in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.84 } do if v[k] >= t then i = j + 1 end end
    i = max(1, i + (bias and bias[k] or 0) + (crease and crease(x, y) or 0))
    local a, b = floor(x / 2) % 2, floor(y / 2) % 2
    local n2 = a + b
    if n2 == 0 then c:put(x, y, CLOTH[min(6, i)], ctok)
    elseif n2 == 1 then c:put(x, y, CHK[min(6, i + 1)], ctok)
    else c:put(x, y, CHK[min(6, i)], ctok) end
  end)
end
gingham(puff, X.pillow(puff, 4), nil, function(x, y) if y >= 19 and (x == 27 or x == 36) then return -1 end return 0 end)
local fb = {}
local fn = X.pillow(frill, 2)
gingham(frill, fn, fb, function(x, y) if (x == 24 or x == 31 or x == 39) and y > 26 then return -1 end if y == 25 then return -1 end return 0 end)

-- twine band with twist, and a bow with tails on the front-right
local wtok = { r = { name = "twine" } }
for y = 23, 24 do for x = 22, 42 do
  local i = ((x + y) % 3 == 0) and 4 or ((x + y) % 3 == 1) and 3 or 2
  if x <= 23 then i = i + 1 end
  if x >= 41 then i = i - 1 end
  c:put(x, y, TW[max(1, min(4, i))], wtok)
end end
local bow = {
  ".ab..ba.",
  "a.cKKc.a",
  ".bbKKbb.",
  "...bc...",
  "...a.c..",
  "..b...b.",
  "..a...c.",
  ".......b",
}
local WC = { a = TW[2], b = TW[3], c = TW[4], K = TW[1] }
for yy, row in ipairs(bow) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if WC[ch] then c:put(33 + xx, 20 + yy, WC[ch], wtok) end end end

-- quirk: marmalade drip escaping under the frill and running down the glass (right side, shade)
local dtok = { r = { name = "drip" } }
local drip = { { 38, 32, 3 }, { 39, 32, 4 }, { 38, 33, 3 }, { 39, 33, 4 }, { 39, 34, 4 }, { 39, 35, 3 }, { 39, 36, 4 },
  { 38, 37, 4 }, { 39, 37, 3 }, { 40, 37, 2 }, { 38, 38, 3 }, { 39, 38, 3 }, { 40, 38, 2 }, { 39, 39, 2 } }
for _, q in ipairs(drip) do c:put(q[1], q[2], AMB[q[3] + 1], dtok) end
c:put(38, 37, GLINT, dtok) c:put(38, 32, AMB[6], dtok)

A.save2(c, NAME)
