-- ico-shrine (final, Opus). Front-on torii gate: black-lacquer kasagi cap with upswept ends over a vermilion
-- shimaki beam, a small gold-framed plaque on the centre strut, a nuki crossbeam that pokes past the pillars,
-- two slim leaning vermilion pillars on round stone kamebara feet, and a sagging twisted straw rope with paper shide.
-- Material: per-pixel cylinder light on the pillars (6-tone lacquer, specular streak, cool bounce on the right),
-- bevelled beams with a bright top lip, AO where pillars meet the beams and the stone, rope twist bands.
-- quirk: someone left a single acorn offering on the left stone foot.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-shrine")
local VERM  = { "#5e1a2e", "#8e2433", "#bd3430", "#e2502f", "#f57a45", "#ffb070" }
local CAP   = { "#262038", "#363052", "#4a456c", "#625f88", "#8482a8", "#b0b0cc" }
local STONE = { "#3a3c58", "#55576f", "#74758c", "#9294a8", "#b6b6c6", "#dcdce6" }
local ROPE  = { "#5e3e1e", "#87602a", "#b38838", "#d6ac52", "#ecce7c", "#fbeab0" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local BOUNCE = "#9a3a5e"

c:groundShadow(32, 56, 22, 2)

-- pillars: slim leaning cylinders (tops lean in)
local ptok = { r = { name = "pillar" } }
local pillars = {}
for i, P in ipairs{ { 19.5, 15, 18.5, 51 }, { 44.5, 15, 45.5, 51 } } do
  local m, n, T, S = X.cyl(P[1], P[2], P[3], P[4], function(t) return 2.2 end)
  pillars[i] = { m = m, n = n, T = T, S = S }
end

-- nuki crossbeam (behind the pillars), ends poke out
local ntok = { r = { name = "nuki" } }
local nuki = c:rect(11, 24, 52, 27)
local nb = {}
X.ao(nb, nuki, pillars[1].m:copy():add(pillars[2].m), 1, -1)
local nidx = A.pil(c, nuki, 1.6, VERM, { bias = nb, tok = ntok })
-- top lip highlight on nuki, dark underside row
for x = 12, 51 do A.step(c, nidx, VERM, x, 24, 1, ntok) end
for x = 11, 52 do A.step(c, nidx, VERM, x, 27, -1, ntok) end

-- rope (shimenawa) sagging between the pillars, twisted
local rtok = { r = { name = "rope" } }
local rope, rS = HP.mask(), {}
for x = 20, 44 do
  local t = (x - 20) / 24
  local yc = 31.2 + 2.6 * sin(pi * t)
  for y = floor(yc - 1.6), floor(yc + 1.6) do
    if abs(y - yc) <= 1.55 then rope:set(x, y) rS[K(x, y)] = (y - yc) / 1.6 end
  end
end
local rn = {}
rope:each(function(x, y) local s = rS[K(x, y)] rn[K(x, y)] = { 0, s * 0.95, sqrt(max(0.05, 1 - s * s * 0.9)) } end)
local ridx = A.shade(c, rope, rn, ROPE, { tok = rtok })
rope:each(function(x, y) local k = K(x, y)
  local ph = (x + (rS[k] * 1.6)) % 4
  if ph < 1 then A.step(c, ridx, ROPE, x, y, -2, rtok) elseif ph < 2 then A.step(c, ridx, ROPE, x, y, 1, rtok) end
end)
-- paper shide: zigzag strips hanging from the rope
local stok = { r = { name = "paper" } }
local PAPER = { s = "#c8bba8", b = "#efe4cc", h = "#fff4d6" }
for _, sx in ipairs{ 26, 36 } do
  local top = floor(31.2 + 2.6 * sin(pi * (sx - 20) / 24) + 2)
  A.map(c, {
    "hbb.",
    "hbbs",
    ".hbs",
    "hbb.",
    "hbbs",
    ".hbs",
  }, sx, top, PAPER, stok)
end

-- pillars painted over nuki and rope ends
for i, P in ipairs(pillars) do
  local bias = {}
  P.m:each(function(x, y) local k = K(x, y)
    if y == 28 or y == 22 or y >= 49 then bias[k] = -1 end
  end)
  local idx = A.shade(c, P.m, P.n, VERM, { bias = bias, tok = ptok, amb = 0.06, wrap = 0.2 })
  -- specular streak on the lit side of the lacquer
  P.m:each(function(x, y) local k = K(x, y)
    local s = P.S[k]
    if s > -0.62 and s < -0.25 and y >= 30 and y <= 44 and (y % 7 ~= 0) then c:put(x, y, VERM[6], ptok) end
    if not P.m:has(x + 1, y) and y > 29 and y < 48 then c:put(x, y, BOUNCE, ptok) end
  end)
end

-- gakuzuka strut + plaque
local gtok = { r = { name = "plaque" } }
local strut = c:rect(30, 17, 33, 23)
A.pil(c, strut, 1.2, VERM, { tok = gtok })
local frame = c:rect(27, 16, 36, 23)
local fidx = A.pil(c, frame, 1.2, { GOLD[1], GOLD[2], GOLD[2], GOLD[3], GOLD[3], GOLD[4] }, { tok = gtok })
local face = c:rect(29, 18, 34, 21)
c:fillMask(face, CAP[2])
for x = 29, 34 do c:put(x, 18, CAP[1], gtok) end
-- glyph
c:put(31, 19, GOLD[3], gtok) c:put(32, 19, GOLD[3], gtok) c:put(31, 20, GOLD[2], gtok) c:put(32, 21, GOLD[2], gtok) c:put(33, 20, GOLD[2], gtok)

-- shimaki (vermilion lower beam of the lintel), then kasagi cap with upswept ends
local function lift(x) local d = abs(x - 31.5) / 23.5 return 2.6 * d ^ 3 end
local stok2 = { r = { name = "shimaki" } }
local shim = A.fn(10, 8, 53, 20, function(x, y) local t = 13.5 - lift(x) return y >= floor(t + .5) and y <= floor(t + .5) + 2 end)
local sb = {}
shim:each(function(x, y) local t = floor(13.5 - lift(x) + .5) if y == t then sb[K(x, y)] = -1 end end)
local sidx = A.pil(c, shim, 1.4, VERM, { bias = sb, tok = stok2 })
local ctok = { r = { name = "cap" } }
local cap = A.fn(7, 4, 56, 16, function(x, y)
  local t = 10.5 - lift(x) * 1.25
  local yt = floor(t + .5)
  local bot = yt + 2
  if x <= 8 or x >= 55 then yt = yt - 1 bot = yt + 2 end
  return y >= yt and y <= bot
end)
local cidx, cn = A.pil(c, cap, 1.5, CAP, { tok = ctok })
-- bright top lip of the lacquer cap + specular glint
cap:each(function(x, y) if not cap:has(x, y - 1) and x > 9 and x < 54 then A.step(c, cidx, CAP, x, y, 1, ctok) end end)
for x = 14, 18 do c:put(x, floor(10.5 - lift(x) * 1.25 + .5), CAP[6], ctok) end
c:put(15, floor(10.5 - lift(15) * 1.25 + .5), A.SPEC, ctok)
-- AO line under the cap on the shimaki is the sb row; dark underside of the cap ends
cap:each(function(x, y) if not cap:has(x, y + 1) and not shim:has(x, y + 1) then A.step(c, cidx, CAP, x, y, -1, ctok) end end)

-- kamebara stone feet
local btok = { r = { name = "stone" } }
for _, cx in ipairs{ 18.5, 45.5 } do
  local bm = A.fn(floor(cx) - 6, 47, floor(cx) + 7, 55, function(x, y)
    local dx = abs(x - cx)
    if y < 49 then return false end
    if y == 49 then return dx <= 3.6 end
    if y == 50 then return dx <= 4.6 end
    return dx <= 5.1 and y <= 54
  end)
  local bb = {}
  bm:each(function(x, y) if y == 54 then bb[K(x, y)] = -1 end end)
  local bidx = A.pil(c, bm, 2, STONE, { bias = bb, tok = btok })
  -- chisel speckle
  bm:each(function(x, y) if X.hash(x, y, 5) > 0.88 and y > 50 then A.step(c, bidx, STONE, x, y, -1, btok) end end)
  -- contact shadow of the pillar foot
  for x = floor(cx) - 2, floor(cx) + 2 do if bm:has(x, 49) then A.step(c, bidx, STONE, x, 49, -2, btok) end end
end

-- quirk: acorn offering on the left foot
local atok = { r = { name = "acorn" } }
A.map(c, {
  ".KK.",
  "ccCC",
  "cCCd",
  ".nN.",
  ".NN.",
}, 8, 50, { K = "#51302b", c = "#d9a070", C = "#a8704a", d = "#6e4430", n = "#f5b82e", N = "#b97a4a" }, atok)

A.save(c, "ico-shrine")
