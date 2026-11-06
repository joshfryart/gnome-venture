-- corn (batch2, Opus single pass). Slim upright ear: a narrow cob of glossy rounded kernels in straight columns
-- (kernels foreshorten toward the cob edges), husk blades peeled back in a loose four-leaf crown, a pale cut
-- shank below and a tuft of silk draping off the tip. Material: per-pixel cylinder light on the cob with a
-- per-kernel bump (lit top-left pixel, shade bottom-right, deep seams), one cream specular, cool bounce on the
-- shade edge; husk straps with parallel veins, V-fold, curled pale inner tip; AO + cast shadow where husk meets cob.
-- quirk: one lone purple heirloom kernel among the gold.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local NAME = "corn"
local c = G.new(NAME)

local GOLD  = { "#7a3f1c", "#b0661c", "#d9921f", "#f2bb2e", "#fcd85a", "#fff09a" }
local PURP  = { "#2e1a45", "#4a2463", "#6b3485", "#8e4fa6", "#b27cc4", "#d6aee0" }
local HUSK  = { "#18402f", "#245c3a", "#3a7c40", "#5e9c46", "#8dbb55", "#bed779" }
local INNER = { "#5d6a3a", "#879450", "#b2b96a", "#d6d68c", "#ecebb0" }
local SILK  = { "#fde79a", "#f3c46c", "#dc9550", "#b06a3c" }
local SPEC, BOUNCE = "#fffbe0", "#b39a86"

---------------------------------------------------------------- masks
-- cob: upright, centre x 32, rounded tip
local CX, YT, YB = 32, 9, 47
local function hw(y)
  if y < YT then return -1 end
  if y < YT + 6 then return 6.3 * sqrt(max(0, 1 - ((YT + 6 - y) / 6.6) ^ 2)) end
  return 6.3 - max(0, y - 34) * 0.06
end
local cob = HP.mask()
for y = YT, YB do local h = hw(y) for x = CX - 7, CX + 7 do if abs(x - CX) <= h + 0.1 then cob:set(x, y) end end end

-- husk blades (quadratic bezier straps): back pair flare out, front pair hug the cob base
local function strap(ax, ay, cx, cy, bx, by, w, fold)
  return { G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.55 * (1 - 0.15 * t))
  end, { fold = fold or 0.5 }) }
end
local backL  = strap(30, 52, 11, 47, 11, 21, 4.4, 0.45)
local backR  = strap(34, 52, 53, 48, 53, 26, 4.1, 0.45)
local frontL = strap(31, 55, 23, 47, 24, 29, 3.7, 0.55)
local frontR = strap(33, 55, 42, 48, 41, 33, 3.5, 0.55)
-- shank: short stalk under the husks with a pale cut end
local shank = HP.mask()
for y = 53, 57 do for x = 30, 34 do shank:set(x, y) end end
shank.s[K(30, 57)] = nil shank.s[K(34, 57)] = nil

---------------------------------------------------------------- back husks
local front = HP.mask():add(frontL[1]):add(frontR[1])
local function paintHusk(B, occl, curl, name)
  local m, n, T, S, len = B[1], B[2], B[3], B[4], B[5]
  local bias = {}
  for _, o in ipairs(occl) do X.ao(bias, m, o, 1, -1) G.cast(bias, m, o, 2, 1, -1) end
  local tok = { r = { name = name } }
  local idx = G.toneN(c, m, n, HUSK, { bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.25 })
  -- midrib (pale on the lit half), parallel veins
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.1 and T[k] > 0.06 and T[k] < 0.9 and not bias[k] then c:put(x, y, S[k] <= 0 and HUSK[6] or HUSK[3], tok) end
  end)
  G.parallelVeins(c, m, idx, S, T, HUSK, tok, { -0.55, 0.5 }, 0.1, 0.85, bias)
  -- curled tip: the inner (pale) face shows where the blade turns over
  if curl then
    m:each(function(x, y) local k = K(x, y)
      if T[k] > curl and S[k] * (curl < 0.8 and 1 or 1) > -0.2 then
        local i = max(1, min(#INNER, idx[k] - 1))
        c:put(x, y, INNER[i], tok)
      end
    end)
  end
  -- cool bounce on the lower-right edge
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.7 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, "#2f6a63", tok) end end)
  return idx
end
paintHusk(backL, { cob, front }, 0.8, "huskBL")
paintHusk(backR, { cob, front }, 0.82, "huskBR")

---------------------------------------------------------------- cob
-- normals: cylinder across, rounded over the tip
local n, CI, RI = {}, {}, {}
local COLW = pi / 6            -- 30 degrees per kernel column
cob:each(function(x, y)
  local h = max(hw(y), 0.5)
  local s = max(-0.97, min(0.97, (x - CX) / (h + 0.7)))
  local ny = 0
  if y < YT + 6 then ny = -((YT + 6 - y) / 6.6) * 0.9 end
  local nx = s * sqrt(max(0.05, 1 - ny * ny))
  n[K(x, y)] = { G.norm(nx, ny, sqrt(max(0.03, 1 - nx * nx - ny * ny))) }
  local th = asin(s)
  local a = th / COLW + 0.5
  local ci = floor(a + 0.001)
  CI[K(x, y)] = ci
  local ph = ({ 0, 1.6, 0.5, 2.2, 1.1, 2.7, 0.3 })[(ci % 7) + 1]
  RI[K(x, y)] = floor((y - YT + ph) / 3.4)
end)
local bias, seam = {}, {}
cob:each(function(x, y) local k = K(x, y)
  local L, U = K(x - 1, y), K(x, y - 1)
  local sx = (x > CX) and CI[L] and CI[L] ~= CI[k]
  local sxl = (x <= CX) and CI[K(x + 1, y)] and CI[K(x + 1, y)] ~= CI[k]
  local sy = RI[U] and CI[U] == CI[k] and RI[U] ~= RI[k]
  if sx or sxl or sy then seam[k] = true end
end)
cob:each(function(x, y) local k = K(x, y)
  if seam[k] then bias[k] = -3 return end
  local up, lf = K(x, y - 1), K(x - 1, y)
  local dn, rt = K(x, y + 1), K(x + 1, y)
  local tl = (seam[up] or not cob:has(x, y - 1)) and (seam[lf] or not cob:has(x - 1, y))
  local br = (seam[dn] or not cob:has(x, y + 1)) and (seam[rt] or not cob:has(x + 1, y))
  if tl and not br then bias[k] = 1 elseif br and not tl then bias[k] = -1 end
end)
X.ao(bias, cob, front, 1, -1)
G.cast(bias, cob, front, 1, 1, -1)
local v = X.light(n, { amb = 0.05, wrap = 0.12 })
local ctok = { r = { name = "cob" } }
local cidx = X.tone(c, cob, v, GOLD, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = ctok })
-- quirk: the purple kernel (one cell, a little left of centre)
local qc, qr = 0, 7
cob:each(function(x, y) local k = K(x, y)
  if CI[k] == qc and RI[k] == qr and not seam[k] then c:put(x, y, PURP[max(2, min(6, cidx[k]))], ctok) end
end)
-- cool bounce down the shade edge (kernel faces only)
local rim = X.rim(n)
cob:edge():each(function(x, y) local k = K(x, y)
  if x > CX and rim[k] > 0.55 and not seam[k] and y > YT + 5 and y < 44 then c:put(x, y, BOUNCE, ctok) end end)
-- specular on an upper-left kernel + one bloom glint
c:put(28, 17, SPEC, ctok) c:put(29, 17, SPEC, ctok)
c:put(27, 24, GOLD[6], ctok)

---------------------------------------------------------------- silk: tuft out of the tip, draping off to the right
local stok = { r = { name = "silk" } }
G.strand(c, { {32, 9}, {33, 7}, {37, 6}, {41, 7}, {44, 9}, {46, 13}, {46, 18} }, { SILK[1], SILK[1], SILK[2], SILK[2], SILK[3], SILK[4] }, stok)
G.strand(c, { {33, 9}, {35, 8}, {39, 8}, {42, 10}, {43, 13}, {43, 15} }, { SILK[1], SILK[2], SILK[2], SILK[3], SILK[4] }, stok)
G.strand(c, { {34, 9}, {37, 9}, {39, 10}, {40, 12} }, { SILK[2], SILK[3], SILK[4] }, stok)
G.strand(c, { {31, 8}, {30, 6}, {27, 6}, {25, 8}, {25, 10} }, { SILK[1], SILK[2], SILK[3], SILK[4] }, stok)
c:put(31, 7, SILK[2], stok) c:put(32, 7, SILK[3], stok) c:put(32, 8, SILK[2], stok) c:put(33, 6, SILK[1], stok)
c:put(34, 6, SILK[1], stok) c:put(35, 6, SILK[2], stok) c:put(36, 7, SILK[3], stok)

---------------------------------------------------------------- shank
local ktok = { r = { name = "shank" } }
local SH = { "#3b5a34", "#5f8040", "#86a552", "#b2c873" }
shank:each(function(x, y)
  local i = x <= 30 and 4 or (x == 31 and 3 or (x == 32 and 3 or (x == 33 and 2 or 1)))
  c:put(x, y, SH[i], ktok)
end)
-- cut end: pale disc with a ring
for x = 31, 33 do c:put(x, 57, "#e6dfa0", ktok) end
c:put(32, 57, "#c9c47e", ktok)

---------------------------------------------------------------- front husks
paintHusk(frontL, { frontR[1] }, nil, "huskFL")
paintHusk(frontR, {}, nil, "huskFR")
-- AO where the husk blades gather at the shank
for _, p in ipairs{ {31, 55}, {32, 55}, {33, 55}, {32, 54} } do c:put(p[1], p[2], HUSK[1]) end

G.save(c, NAME)
