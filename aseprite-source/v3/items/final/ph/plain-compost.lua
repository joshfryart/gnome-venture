-- plain-compost (aC35_1, Opus single pass). A tall, slim burlap sack standing open: slumped sides that bulge a
-- little toward the base, rolled-down cuff at the mouth, a twisted twine band under the cuff, burlap weave (thread
-- lines both ways), two slump folds, and a crumbly mound of dark compost heaped in the mouth (clumps, crumbs, a green
-- leaf fleck and a twig). Ambient dark row where compost meets the cuff and under the cuff roll; 2-tone ground shadow.
-- quirk: a little curved eggshell fragment sits on top of the compost.
local NAME = "plain-compost"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local BUR = { "#4e3226", "#74503a", "#9c7350", "#c19866", "#dcb983", "#f0d7a4" }
local SOIL = { "#1e1418", "#2e1f1e", "#432d24", "#5e402e", "#7c5a3e", "#9c7a56" }
local TW = { "#7a5a2a", "#c4983e", "#ecc870" }
local COOL = "#6e6a80"

local CX = 32
c:groundShadow(CX, 57, 16, 2)

-- body: half width per row, slim at the neck, bulging toward the base
local function hw(y)
  if y < 24 then return nil end
  local t = (y - 24) / 32
  return 10.5 + 3.5 * sin(pi * min(1, t * 0.8 + 0.1)) ^ 0.8 + (t > 0.9 and -(t - 0.9) * 20 or 0)
end
local body, bn = HP.mask(), {}
for y = 24, 56 do local w = hw(y)
  for x = floor(CX - w + 0.5), floor(CX + w + 0.5) do
    body:set(x, y)
    local u = (x - CX) / (w + 0.5)
    local t = (y - 24) / 32
    local ny = (t > 0.85) and (t - 0.85) * 4 or -0.08
    bn[K(x, y)] = { G.norm(u * 0.95, ny, sqrt(max(0.05, 1 - u * u))) }
  end
end
-- cuff: a wider rolled band at the top
local cuff, cn = HP.mask(), {}
for y = 18, 24 do for x = CX - 13, CX + 13 do
  local dy = (y - 21) / 3.6
  local u = (x - CX) / 13.5
  if u * u * 0.3 + dy * dy <= 1.05 then cuff:set(x, y) cn[K(x, y)] = { G.norm(u * 0.8, dy * 0.9, 0.6) } end
end end
body:cut(cuff)

local bias = {}
-- ambient row under the cuff roll
X.ao(bias, body, cuff, 2, -1)
-- slump folds: two diagonal creases near the base (dark crease, lit lip)
local fold = {}
body:each(function(x, y)
  for _, f in ipairs{ { 25, 44, 0.9 }, { 40, 47, -0.7 } } do
    local d = (y - f[2]) - f[3] * (x - f[1])
    local along = abs(x - f[1])
    if along < 5 and d >= 0 and d < 1 then fold[K(x, y)] = -1 end
    if along < 5 and d >= -1 and d < 0 then fold[K(x, y)] = 1 end
  end
end)
for k, v in pairs(fold) do bias[k] = (bias[k] or 0) + v end

local btok = { r = { name = "sack" } }
local bidx = X.tone(c, body, X.light(bn, { amb = 0.1, wrap = 0.3 }), BUR, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = btok })
-- burlap weave: vertical warp lines and dashed weft lines, one tone down
body:each(function(x, y) local k = K(x, y)
  local i = bidx[k]
  if (x % 3 == 0 and y % 2 == 0) or (y % 3 == 1 and (x + y) % 4 < 2) then c:put(x, y, BUR[max(1, i - 1)], btok) end
  if X.hash(x, y, 9) < 0.03 then c:put(x, y, BUR[min(6, i + 1)], btok) end
end)
-- cool reflected light on the right edge
body:edge():each(function(x, y) if x > CX + 8 and y > 30 and y < 52 then c:put(x, y, COOL, btok) end end)

-- cuff (rolled burlap) with its own lighting and a weave
local ctok = { r = { name = "cuff" } }
local cidx = X.tone(c, cuff, X.light(cn, { amb = 0.12, wrap = 0.3 }), BUR, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = ctok })
cuff:each(function(x, y) local k = K(x, y)
  if (x + floor(y / 2)) % 3 == 0 then c:put(x, y, BUR[max(1, cidx[k] - 1)], ctok) end end)
-- frayed threads at the cuff's left end
local fr = { r = { name = "fray" } }
c:put(CX - 14, 22, BUR[4], fr) c:put(CX - 15, 23, BUR[3], fr)

-- twine band under the cuff: twisted rope, two plies alternating on the diagonal
local twtok = { r = { name = "twine" } }
local TY = 27
for x = CX - floor(hw(TY) + 0.5), CX + floor(hw(TY) + 0.5) do
  for dy = 0, 1 do
    local p = (x + dy * 2) % 4
    local col = (p < 2) and TW[2] or TW[1]
    if p == 0 and dy == 0 and x < CX + 6 then col = TW[3] end
    if x > CX + 7 then col = (p < 2) and TW[1] or BUR[1] end
    c:put(x, TY + dy, col, twtok)
  end
end
-- twine ends with a little knot, hanging on the left
for _, q in ipairs{ { CX - 9, 29, 2 }, { CX - 9, 30, 1 }, { CX - 8, 31, 2 }, { CX - 8, 32, 1 }, { CX - 10, 29, 1 } } do c:put(q[1], q[2], TW[q[3]], twtok) end
c:put(CX - 10, 31, TW[2], twtok) c:put(CX - 10, 32, TW[1], twtok) c:put(CX - 11, 33, TW[2], twtok)

-- compost mound heaped in the mouth
local soil, sn = HP.mask(), {}
for x = CX - 11, CX + 11 do
  local u = (x - CX) / 11.5
  local topy = 20 - 8 * (1 - u * u) ^ 1.2 + 0.9 * sin(x * 1.7) + 0.6 * cos(x * 0.8)
  for y = floor(topy + 0.5), 21 do soil:set(x, y) end
end
local sbias = {}
soil:each(function(x, y) local k = K(x, y)
  local u = (x - CX) / 11.5
  sn[k] = { G.norm(u * 0.8, -0.6, 0.6) }
  if y >= 20 then sbias[k] = -1 end
end)
local cuffFront = HP.mask() cuff:each(function(x, y) if y >= 20 then cuffFront:set(x, y) end end)
soil:cut(cuffFront)
-- crumbly clumps: low-freq lumps add light/dark
local lump = {}
soil:each(function(x, y) local k = K(x, y)
  local h = sin(x * 1.3 + y * 0.7) + cos(x * 0.6 - y * 1.9)
  if h > 1.1 then sbias[k] = (sbias[k] or 0) + 1 elseif h < -1.2 then sbias[k] = (sbias[k] or 0) - 1 end
end)
local stok = { r = { name = "soil" } }
local sidx = X.tone(c, soil, X.light(sn, { amb = 0.12, wrap = 0.3 }), SOIL, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = sbias, tok = stok })
soil:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 21)
  if h < 0.12 then c:put(x, y, SOIL[max(1, sidx[k] - 2)], stok) elseif h > 0.9 then c:put(x, y, SOIL[min(6, sidx[k] + 1)], stok) end
end)
-- dark ambient row where compost meets the cuff
for x = CX - 11, CX + 11 do if soil:has(x, 19) and not soil:has(x, 20) then c:put(x, 19, SOIL[1], stok) end end
-- leaf fleck and twig
c:put(CX + 4, 15, "#7cc35a", stok) c:put(CX + 5, 15, "#3f9150", stok) c:put(CX + 5, 14, "#c4e07a", stok)
local twg = { r = { name = "twig" } }
for _, q in ipairs{ { CX + 8, 14, "#b97a4a" }, { CX + 9, 13, "#b97a4a" }, { CX + 10, 12, "#e8b982" }, { CX + 11, 11, "#b97a4a" }, { CX + 9, 14, "#864c33" } } do c:put(q[1], q[2], q[3], twg) end
-- quirk: curved eggshell fragment
local etok = { r = { name = "eggshell" } }
for _, q in ipairs{ { CX - 5, 13, "#fff4d6" }, { CX - 4, 13, "#fff4d6" }, { CX - 3, 13, "#efe2c4" }, { CX - 6, 14, "#efe2c4" }, { CX - 5, 14, "#d8c8a8" }, { CX - 4, 14, "#c2b090" }, { CX - 3, 14, "#d8c8a8" } } do c:put(q[1], q[2], q[3], etok) end

G.save2(c, NAME)
