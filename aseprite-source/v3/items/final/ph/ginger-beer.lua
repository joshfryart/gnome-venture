-- ginger-beer (Opus single pass). A slim two-tone stoneware ginger-beer bottle: cream salt-glazed body, a dipped
-- brown shoulder whose glaze pools darker at its drippy edge, a swing-top porcelain stopper with a red rubber washer
-- and a wire bail, a small paper label with a ginger-knob print. Lathe normals, 6-tone ramps, vertical glaze specular,
-- AO under the stopper and lip, 2-tone ground shadow.
-- quirk: a string of fizz bubbles escapes from under the washer and drifts up to the right.
local NAME = "ginger-beer"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin = math.floor, math.abs, math.max, math.min, math.sin
local c = G.new2(NAME)
local BROWN = { "#2c1820", "#4a2626", "#6e3a2a", "#94552f", "#bb7740", "#e2a463" }
local CREAM = { "#5c4048", "#8c7064", "#b9a07e", "#dcc69a", "#f1e2b8", "#fff6dc" }
local PORC  = { "#4a4a66", "#76788e", "#a4a6b8", "#cfd0dc", "#e9e9f0", "#f8f7fb" }
local WIRE  = { "#444663", "#74758c", "#c8c8d6" }
local RUB   = { "#6e2038", "#b52e3f", "#e8493b" }
local FIZZ  = { "#3a86b0", "#8fd6d8", "#d8f6ee", "#fff4d6" }
local CX = 32

c:groundShadow(CX, 54, 11, 1)

local function rf(y)
  if y < 12 then return nil end
  if y <= 13 then return 3.4 end
  if y <= 20 then return 2.5 end
  if y <= 29 then local t = (y - 20) / 9 t = t * t * (3 - 2 * t) return 2.5 + (8.0 - 2.5) * t end
  if y <= 50 then return 8.0 - (y - 30) * 0.015 end
  if y == 51 then return 7.6 elseif y == 52 then return 6.9 elseif y == 53 then return 5.6 end
  return nil
end
local bm, bn, BS = G.lathe(CX, 12, 53, rf)
-- glaze line: dipped brown above, cream below, with drips
local function gl(x)
  local d = { [26] = 3, [27] = 4, [31] = 2, [35] = 5, [36] = 6, [37] = 4 }
  return 28 + (d[x] or 0) + floor(sin(x * 0.9) + 0.5)
end
local bias = {}
-- AO under the lip ring and at the neck/shoulder join
bm:each(function(x, y) local k = K(x, y)
  if y == 14 then bias[k] = -2 end
  if y == 15 then bias[k] = -1 end
  if y >= 52 then bias[k] = (bias[k] or 0) - 1 end
end)
local brown, cream = HP.mask(), HP.mask()
bm:each(function(x, y) if y < gl(x) then brown:set(x, y) else cream:set(x, y) end end)
local btok, ctok = { r = { name = "glaze" } }, { r = { name = "body" } }
local CUT = { 0.16, 0.32, 0.5, 0.68, 0.84 }
G.toneN(c, cream, bn, CREAM, { tok = ctok, bias = bias, cuts = CUT, amb = 0.12, wrap = 0.3 })
local bidx = G.toneN(c, brown, bn, BROWN, { tok = btok, bias = bias, cuts = CUT, amb = 0.12, wrap = 0.3 })
-- pooled glaze: the bottom 1 px of the brown dip is darker (thick drip edge)
brown:each(function(x, y) if y == gl(x) - 1 and y > 20 then c:put(x, y, BROWN[max(1, (bidx[K(x, y)] or 3) - 1)], btok) end end)
-- cool reflected light on the far right edge of the body
bm:edge():each(function(x, y) local k = K(x, y)
  if BS[k] > 0.85 and y > 31 and y < 50 then c:put(x, y, "#7b7f9e", ctok) end end)
-- glaze specular: broken vertical streak on the lit side, plus a short one on the shoulder
for y = 33, 48 do if y ~= 39 and y ~= 40 and y ~= 45 then c:put(CX - 5, y, CREAM[6], ctok) end end
for y = 34, 38 do c:put(CX - 4, y, CREAM[6], ctok) end
for _, p in ipairs{ { CX - 4, 24 }, { CX - 4, 25 }, { CX - 5, 26 }, { CX - 2, 16 }, { CX - 2, 17 } } do c:put(p[1], p[2], BROWN[6], btok) end
-- salt-glaze speckle on the cream body (sparse, deterministic)
cream:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 7) > 0.93 and BS[k] > -0.4 and BS[k] < 0.75 and y > gl(x) + 1 then c:put(x, y, CREAM[3], ctok) end end)

-- paper label with a printed ginger knob
local ltok = { r = { name = "label" } }
for y = 35, 43 do for x = CX - 5, CX + 4 do local k = K(x, y)
  local s = BS[k] or 0
  local col = s > 0.55 and "#d6c09a" or (s < -0.45 and "#fff4d6" or "#f6e8c4")
  if y == 35 or y == 43 or x == CX - 5 or x == CX + 4 then col = s > 0.55 and "#86283a" or "#b52e3f" end
  c:put(x, y, col, ltok)
end end
-- ginger knob print (gold) + tiny ember text dashes
for _, p in ipairs{ { -2, 38 }, { -1, 38 }, { 0, 38 }, { 1, 38 }, { -3, 39 }, { -2, 39 }, { -1, 39 }, { 0, 39 }, { 1, 39 }, { 2, 39 },
  { -1, 37 }, { 1, 37 }, { 2, 38 } } do c:put(CX + p[1], p[2], "#d98322", ltok) end
for _, p in ipairs{ { -2, 37 }, { 0, 37 }, { -1, 40 }, { 1, 40 } } do c:put(CX + p[1], p[2], "#8f4a1f", ltok) end
c:put(CX - 2, 38, "#f5b82e", ltok) c:put(CX - 1, 38, "#ffe38a", ltok)
for x = CX - 3, CX + 2 do if x ~= CX then c:put(x, 41, "#c94f84", ltok) end end
-- AO row under the label edge
for x = CX - 5, CX + 4 do local k = K(x, 44) if bm:has(x, 44) then c:put(x, 44, CREAM[max(1, 3 - (BS[k] > 0.4 and 1 or 0))], ctok) end end

-- wire bail: two wires from the stopper down to a collar under the lip
local wtok = { r = { name = "wire" } }
for y = 10, 17 do c:put(CX - 4, y, y < 13 and WIRE[3] or WIRE[2], wtok) c:put(CX + 4, y, WIRE[1], wtok) end
for x = CX - 3, CX + 3 do c:put(x, 18, x < CX - 1 and WIRE[3] or (x < CX + 2 and WIRE[2] or WIRE[1]), wtok) end
c:put(CX - 3, 17, WIRE[2], wtok) c:put(CX + 3, 17, WIRE[1], wtok)
-- red rubber washer (sits on the lip, shadowing it)
local rtok = { r = { name = "washer" } }
for x = CX - 3, CX + 3 do c:put(x, 11, x < CX - 1 and RUB[3] or (x < CX + 2 and RUB[2] or RUB[1]), rtok) end
for x = CX - 3, CX + 3 do if bm:has(x, 12) then c:put(x, 12, BROWN[x < CX and 2 or 1], btok) end end
-- porcelain swing-top stopper (dome)
local sm, sn = G.lathe(CX, 5, 10, function(y)
  if y == 5 then return 1.6 elseif y == 6 then return 2.6 elseif y <= 9 then return 3.3 else return 3.6 end end)
G.toneN(c, sm, sn, PORC, { tok = { r = { name = "stopper" } }, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.3 })
c:put(CX - 2, 6, PORC[6]) c:put(CX - 1, 6, "#fff4d6")

-- quirk: fizz bubbles escaping from under the washer, rising to the right
local ftok = { r = { name = "fizz" } }
local function bub(x, y, big)
  if big then
    for _, p in ipairs{ { 0, 0, 3 }, { 1, 0, 2 }, { 0, 1, 2 }, { 1, 1, 1 } } do c:put(x + p[1], y + p[2], FIZZ[p[3]], ftok) end
    c:put(x, y, FIZZ[4], ftok)
  else c:put(x, y, FIZZ[3], ftok) end
end
bub(CX + 5, 10, false) bub(CX + 6, 8, true) bub(CX + 8, 5, false) bub(CX + 10, 6, true)

G.save2(c, NAME)
