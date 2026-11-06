-- jujube (final pass, Opus aC13_2). Two glossy oval jujubes (mahogany drupes; the right one still ripening, a
-- yellow-green shoulder blotched into red) hang on short stalks from a zigzag thorny twig. Glossy ovate leaves with
-- the jujube's three base-nerves. Waxy gloss, one specular per fruit, cool bounce light, AO under the twig.
-- quirk: someone has taken one crisp bite out of the left jujube, showing the pale apple-like flesh.
local NAME = "jujube"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#123a2e", "#1c5436", "#2a7040", "#408e48", "#64ae52", "#9ccc68" }
local TWIG = { "#2e1c1e", "#4a2c26", "#6a4030", "#8a583a", "#a8764e", "#c89a6c" }
local RED  = { "#36161e", "#5a1e26", "#84282a", "#ac3a2e", "#d0603a", "#f09a62" }
local GRN  = { "#3a4220", "#5a6626", "#7e8c2e", "#a4b03c", "#c8d460", "#ecf096" }
local STALK = { "#3a3020", "#5c4c2a", "#7e6c36", "#a08e4a" }
local FLESH = { "#b8a46e", "#dccc96", "#f2eac4", "#fbf6dc" }
local COOL_R, COOL_L = "#6a3c58", "#3c6a70"

-- leaves (behind the twig)
local ltok = { r = { name = "leaf" } }
local twig = { { 8, 21 }, { 18, 16 }, { 28, 21 }, { 38, 16 }, { 48, 20 }, { 57, 15 } }
-- twig mask first (to shade the leaves around it)
local tm, tn = HP.mask(), {}
for i = 1, #twig - 1 do
  local a, b = twig[i], twig[i + 1]
  local m, n = X.cyl(a[1], a[2], b[1], b[2], function(t) return 1.25 - 0.25 * (i / #twig) end)
  for k, v in pairs(n) do if not tn[k] then tn[k] = v end end
  tm:add(m)
end
for i = 2, #twig - 1 do local p = twig[i]
  for dy = -1, 1 do for dx = -1, 1 do if abs(dx) + abs(dy) < 2 then tm:set(p[1] + dx, p[2] + dy)
    tn[K(p[1] + dx, p[2] + dy)] = tn[K(p[1] + dx, p[2] + dy)] or { A.norm(dx * .5, dy * .5, 1) } end end end
end
local lb = {}
local leaves = {
  { 18, 15, 10, 11, 7, 4, 3.7 },
  { 38, 15, 46, 7, 54, 5, 3.9 },
  { 28, 19, 27, 12, 32, 6, 2.9 },
}
local lms = {}
for i, L in ipairs(leaves) do
  local bias = {}
  local m = A.leaf(c, L[1], L[2], L[3], L[4], L[5], L[6], L[7], LEAF, { tri = true, tok = ltok, cool = COOL_L, pw = 0.7, fold = 0.5 })
  lms[i] = m
end
-- AO on leaves next to the twig (1 px darker ring)
local leafAll = HP.mask() for _, m in ipairs(lms) do leafAll:add(m) end
tm:grow(1):cut(tm):each(function(x, y) if leafAll:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
-- twig
local ttok = { r = { name = "twig" } }
local tidx = A.shade(c, tm, tn, TWIG, { amb = 0.1, wrap = 0.3, tok = ttok })
-- bark flecks and node knuckles
tm:each(function(x, y) if X.hash(x, y, 3) > 0.86 and (tidx[K(x, y)] or 3) > 2 then c:put(x, y, TWIG[(tidx[K(x, y)] or 3) - 1], ttok) end end)
-- thorns at two nodes (paired spines, pale tips)
for _, th in ipairs{ { 28, 22, { { 27, 23 }, { 26, 24 } } }, { 48, 21, { { 49, 22 }, { 50, 23 } } }, { 18, 15, { { 17, 14 }, { 16, 13 } } } } do
  for j, q in ipairs(th[3]) do c:put(q[1], q[2], j == #th[3] and TWIG[6] or TWIG[4], ttok) end
end
-- broken twig ends: pale end grain
c:put(8, 21, TWIG[6], ttok) c:put(57, 15, TWIG[5], ttok)

-- fruit: cx, cy, long radius, short radius, angle (long axis), stalk pts, ripe-blotch flag
local fruits = {
  { 21, 36, 9.0, 6.0, pi / 2 + 0.16, { { 18, 17 }, { 19, 21 }, { 20, 24 }, { 21, 27 } }, false },
  { 41, 39, 9.4, 6.3, pi / 2 - 0.14, { { 38, 17 }, { 38, 22 }, { 39, 26 }, { 40, 30 } }, true },
}
local stok = { r = { name = "stalk" } }
for _, f in ipairs(fruits) do
  A.stem(c, f[6], function(t) return 0.85 end, STALK, { tok = stok })
end
for fi, f in ipairs(fruits) do
  local m, n = A.oval(f[1], f[2], f[3], f[4], f[5], 0.85)
  local bite = HP.mask()
  if fi == 1 then
    bite:add(A.rell(13.0, 38.5, 1, 0, 3.6, 3.6)):add(A.rell(13.6, 43.2, 1, 0, 3.3, 3.3))
    bite:clip(m)
    m:cut(bite)
  end
  local tok = { r = { name = "fruit" .. fi } }
  local bias = {}
  -- dimple + AO at the stalk end
  local top = { floor(f[1] + cos(f[5]) * -f[3] + 0.5), floor(f[2] + sin(f[5]) * -f[3] + 0.5) }
  X.ao(bias, m, HP.mask():set(top[1], top[2] - 1), 2, -1)
  local idx = A.shade(c, m, n, RED, { amb = 0.06, wrap = 0.24, tok = tok, bias = bias, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- ripening blotch: yellow-green shoulder with ragged red boundary
  if f[7] then
    local ca, sa = cos(f[5]), sin(f[5])
    m:each(function(x, y) local k = K(x, y)
      local u = ((x - f[1]) * ca + (y - f[2]) * sa) / f[3]          -- -1 at stalk end
      local v = (-(x - f[1]) * sa + (y - f[2]) * ca) / f[4]
      local edge = -0.25 + 0.35 * v + (X.hash(floor(x / 2), floor(y / 2), 7) - 0.5) * 0.55
      if u < edge then c:put(x, y, GRN[idx[k]], tok) end
    end)
  end
  -- lenticel flecks (tiny pale dots) on the mid tones
  m:each(function(x, y) local k = K(x, y) local i = idx[k]
    if i >= 3 and i <= 4 and X.hash(x, y, 11 + fi) > 0.93 then c:put(x, y, RED[i + 1], tok) end end)
  -- cool reflected light on the lower-right rim
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.55 and not bite:grow(1):has(x, y) then c:put(x, y, COOL_R, tok) end end)
  -- waxy gloss: specular streak + one cream glint
  local sx, sy = A.specAt(m, n, 30)
  c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, RED[6], tok) c:put(sx, sy + 1, RED[6], tok) c:put(sx + 1, sy + 2, RED[5], tok)
  -- bite: pale flesh band against the cut, darker skin lip
  if fi == 1 then
    local band1 = bite:grow(1):clip(m)
    local band2 = bite:grow(2):clip(m):cut(band1)
    local band3 = bite:grow(3):clip(m):cut(band1):cut(band2)
    band3:each(function(x, y) c:put(x, y, RED[2], tok) end)
    band2:each(function(x, y) c:put(x, y, FLESH[2], tok) end)
    band1:each(function(x, y) c:put(x, y, (y < 40) and FLESH[4] or FLESH[3], tok) end)
    -- tooth ridge between the two bite scoops
    c:put(16, 41, FLESH[1], tok) c:put(17, 41, FLESH[2], tok)
  end
end
A.save(c, NAME)
