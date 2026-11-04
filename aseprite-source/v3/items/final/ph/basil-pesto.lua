-- basil-pesto (ph, Opus single pass, aR3_5). A slim glass jar of bright basil pesto: thick glass with a bright rim, a
-- pale core streak and a cool reflected edge, a threaded neck, a heavy glass base; the pesto shows basil flecks, pale
-- pine-nut/cheese crumbs and a golden oil line at the top. Red gingham cloth cap (2 px checks, gathered folds, frilled
-- hem) tied with twisted twine and a bow; a sprig of two basil leaves tucked under the twine. Ground shadow.
-- quirk: a fat green drip of pesto has escaped from under the cloth and is sliding down the glass.
local NAME = "basil-pesto"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local PESTO = { "#173c22", "#235a2a", "#2f7a32", "#46993a", "#6cb846", "#a2d468" }
local OIL   = { "#6a6a1e", "#a09a2a", "#d4c650" }
local GLASS = { "#4e7f86", "#7fb2b0", "#b6dcd2", "#e4f6ee" }
local LEAF  = { "#17432f", "#1f5e38", "#2d7d3e", "#46a046", "#6fc256", "#a6e07a" }
local TW    = { "#6e4a26", "#9c6c34", "#c8984c", "#ecc77a" }
local CR    = { "#b8a49a", "#dccfc0", "#f4ead6", "#fff4d6" }   -- gingham white
local PK    = { "#a04454", "#cc6a6c", "#ec9488", "#ffbcaa" }   -- gingham mixed
local RD    = { "#6e2038", "#a02c3c", "#d0403e", "#ee6a52" }   -- gingham red
local FLK, NUT = "#123018", "#f0dc9a"

c:groundShadow(31.5, 56, 13, 1.6)

-- jar body ------------------------------------------------------------------------------------------------------------
local X0, X1, Y0, Y1 = 20, 43, 23, 55
local body = c:rrect(X0, Y0, X1, Y1, 4)
local neck = c:rect(X0 + 2, Y0 - 3, X1 - 2, Y0)
local gtok = { r = { name = "glass" } }
-- glass wall: 1 px all round, 2 px at the base
local inner = body:shrink(1)
inner:cut(c:rect(X0, Y1 - 2, X1, Y1))
local wall = body:copy():cut(inner)
-- pesto fill: cylinder shading across x, top at y = Y0+3 (headroom shows glass)
local TOP = Y0 + 3
local fill = inner:copy():clip(c:rect(X0, TOP, X1, Y1))
local head = inner:copy():cut(fill)
local ptok = { r = { name = "pesto" } }
local cx0, cx1 = X0 + 1, X1 - 1
fill:each(function(x, y)
  local tt = ((x - cx0) / (cx1 - cx0)) * 2 - 1
  local v = 0.5 - 0.45 * tt                -- lit on the left
  if y > Y1 - 6 then v = v - 0.12 end      -- deeper near the base (ambient)
  local i = v < 0.22 and 2 or v < 0.42 and 3 or v < 0.68 and 4 or v < 0.86 and 5 or 6
  -- texture: basil flecks and crumbs
  local hb = X.hash(floor(x / 2), floor((y + (floor(x / 2) % 2)) / 2), 3)
  if hb < 0.14 then i = i - 1 elseif hb > 0.9 and i < 5 then i = i + 1 end
  c:put(x, y, PESTO[max(1, min(6, i))], ptok)
  local h = X.hash(x, y, 7)
  if h < 0.035 and y > TOP + 1 then c:put(x, y, FLK, ptok) if fill:has(x + 1, y) then c:put(x + 1, y, PESTO[2], ptok) end end
  if h > 0.975 and tt < 0.5 and y > TOP + 1 then c:put(x, y, NUT, ptok) end
end)
-- oil line at the top of the pesto
for x = cx0, cx1 do c:put(x, TOP, x < 29 and OIL[3] or (x < 38 and OIL[2] or OIL[1]), ptok) end
-- headroom: empty glass, pale tint
head:each(function(x, y) c:put(x, y, (x < 26) and GLASS[3] or GLASS[2], gtok) end)
-- walls
wall:each(function(x, y)
  local col = GLASS[2]
  if x <= X0 + 1 then col = GLASS[3] elseif x >= X1 - 1 then col = GLASS[1] end
  if y >= Y1 - 2 then col = (x < 30) and GLASS[3] or GLASS[2] end
  if y == Y1 - 2 and x > X0 + 1 and x < X1 - 1 then col = GLASS[4] end
  c:put(x, y, col, gtok)
end)
-- ambient under the pesto line meets the base: a dark row
for x = X0 + 2, X1 - 2 do c:put(x, Y1 - 3, PESTO[1], ptok) end
-- glass specular streak (pale core) + bright rim + cool bounce on the right
for y = TOP + 2, Y1 - 6 do c:put(X0 + 3, y, GLASS[4], gtok) end
for y = TOP + 4, TOP + 9 do c:put(X0 + 5, y, GLASS[3], gtok) end
c:put(X0 + 3, TOP + 1, "#fff4d6", gtok)
for y = TOP + 6, Y1 - 7 do c:put(X1 - 2, y, GLASS[2], gtok) end
-- neck: threaded glass
neck:each(function(x, y)
  local col = ((y - (Y0 - 3)) % 2 == 0) and GLASS[2] or GLASS[1]
  if x < X0 + 6 then col = ((y % 2) == 0) and GLASS[3] or GLASS[2] end
  if x > X1 - 5 then col = GLASS[1] end
  c:put(x, y, col, gtok)
end)

-- quirk: pesto drip down the left of the glass ------------------------------------------------------------------------
local dtok = { r = { name = "drip" } }
local drip = c:rect(X0 - 1, Y0 - 1, X0, Y0 + 6):add(c:ellipse(X0 - 0.5, Y0 + 8, 1.5, 1.9))
drip:each(function(x, y) c:put(x, y, (x == X0 - 1) and PESTO[5] or PESTO[4], dtok) end)
drip:each(function(x, y) if not drip:has(x, y + 1) or not drip:has(x + 1, y) then c:put(x, y, PESTO[3], dtok) end end)
c:put(X0 - 1, Y0 + 7, "#fff4d6", dtok) c:put(X0 - 1, Y0 + 8, PESTO[6], dtok)
-- its wet trail on the glass
for y = Y0 + 1, Y0 + 5 do c:put(X0 + 1, y, GLASS[4], gtok) end

-- gingham cloth cap ---------------------------------------------------------------------------------------------------
local cap = c:ellipse(31.5, 14.5, 12.5, 5.5):add(c:rect(X0 - 1, 15, X1 + 1, 19))
-- frilled hem below the twine: wavy edge
for x = X0 - 3, X1 + 3 do
  local d = 22 + ((x % 4 < 2) and 1 or 0)
  for y = 19, d do cap:set(x, y) end
end
cap:cut(c:rect(0, 0, X0 - 4, 63)):cut(c:rect(X1 + 4, 0, 63, 63))
local cn = X.pillow(cap, 3.2)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
local ctok = { r = { name = "cloth" } }
cap:each(function(x, y) local k = K(x, y)
  local v = cv[k]
  -- vertical cylinder term on the skirt, so the right side shades
  v = v * 0.55 + (0.5 - 0.5 * ((x - 31.5) / 14)) * 0.45
  -- gathered folds: radiate down from the twine, darker crease lines
  local fold = (y >= 19) and ((x + floor((y - 19) / 2)) % 5 == 0) or (y < 19 and (x - floor((19 - y) * 0.5)) % 6 == 0 and y > 11)
  local i = v < 0.32 and 1 or v < 0.5 and 2 or v < 0.72 and 3 or 4
  if fold then i = i - 1 end
  if y == 18 or y == 19 then i = i - 1 end                       -- ambient right under the twine
  i = max(1, min(4, i))
  local g = (floor(x / 2) % 2) + (floor(y / 2) % 2)
  c:put(x, y, (g == 0 and CR or g == 1 and PK or RD)[i], ctok)
end)
-- hem: darker underside row of the frill
cap:each(function(x, y) if not cap:has(x, y + 1) and y >= 21 then c:put(x, y, RD[1], ctok) end end)

-- twine with twist + bow ----------------------------------------------------------------------------------------------
local ttok = { r = { name = "twine" } }
for x = X0 - 1, X1 + 1 do
  c:put(x, 19, (x % 3 == 0) and TW[2] or (x < 30 and TW[4] or TW[3]), ttok)
  c:put(x, 20, (x % 3 == 1) and TW[1] or TW[2], ttok)
end
-- bow on the right: two loops and two tails
G.map(c, X1 - 4, 16, {
  ".ab..ab.",
  "abbcabbc",
  "bcddddcb",
  ".cddddc.",
  "..d..d..",
  "..d...d.",
  ".d....d.",
}, { a = TW[4], b = TW[3], c = TW[2], d = TW[1] }, ttok)

-- basil sprig tucked under the twine on the left, clear of the bow ------------------------------------------------------
local lt = { r = { name = "basil" } }
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, w * sin(pi * (t * 0.92 + 0.05) ^ 0.75) ^ 0.8)
  end, { fold = 0.45 })
  m:cut(c:rect(0, 19, 63, 20))
  G.toneN(c, m, n, LEAF, { tok = lt, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, amb = 0.12, wrap = 0.28 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.13 and T[k] > 0.06 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and "#c6ec96" or LEAF[2], lt) end end)
  return m
end
leaf(25, 19, 23, 13, 18, 7, 3.0)
leaf(26, 19, 30, 13, 34, 8, 2.6)
-- stem stub under the twine
c:put(25, 18, LEAF[3], lt) c:put(26, 18, LEAF[2], lt)

G.save2(c, NAME)
