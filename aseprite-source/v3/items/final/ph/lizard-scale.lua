-- lizard-scale (final, Opus single pass). One shed keeled lizard scale: a slim pointed shield on the diagonal,
-- per-pixel lit with a strong central keel (bright lit ridge, dark shade groove), iridescent ramp (violet shade to
-- mint light), an inset growth ring, fine striations off the keel, a thin rainbow sheen streak and a specular.
-- quirk: a ragged scrap of pale shed skin still clings to the root end.
local NAME = "lizard-scale"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, sqrt, floor, sin, pi = math.abs, math.max, math.min, math.sqrt, math.floor, math.sin, math.pi
local c = A.new(NAME)

local IRI  = { "#24204a", "#363a82", "#3a68a2", "#3a9ea6", "#6fd0b2", "#c6f2d4" }
local SKIN = { "#9a8070", "#c9b098", "#ecdcc4" }
local SHEEN = { "#ffe38a", "#ffb0c8", "#b6f0e0" }

-- scale body along the diagonal: root lower-left, point upper-right
local m, n, T, S, len = A.blade(19, 53, 30, 34, 47, 11, function(t)
  if t > 0.995 then return -1 end
  if t < 0.32 then return 3.2 + 7.6 * (t / 0.32) ^ 0.55 end
  return 10.8 * ((1 - t) / 0.68) ^ 0.8
end, { fold = 0.75 })
-- distance to edge for a bevelled rim and growth ring
local d = X.dist(m)
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local dd = d[k]
  if dd < 0.7 then bias[k] = (S[k] < 0) and 1 or -1 end          -- bevel: lit rim up-left, deep rim down-right
  if dd >= 2.6 and dd < 3.5 and T[k] > 0.08 and T[k] < 0.86 then bias[k] = -1 end   -- growth ring groove
end)
local tok = { r = { name = "scale" } }
local idx = A.shade(c, m, n, IRI, { bias = bias, tok = tok, amb = 0.1, wrap = 0.35, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
  -- keel: bright ridge line on the lit side, dark groove on the shade side
  if t > 0.05 and t < 0.93 then
    if s > -0.12 and s <= 0 then c:put(x, y, IRI[6], tok)
    elseif s > 0 and s < 0.14 then c:put(x, y, IRI[2], tok) end
  end
  -- fine striations radiating off the keel toward the rim
  local ph = (t * len + abs(s) * 6) / 4
  if ph - floor(ph) < 0.18 and abs(s) > 0.22 and d[k] > 3.6 and t > 0.12 and t < 0.8 then
    c:put(x, y, A.step(IRI, idx[k], -1), tok) end
end)
-- rainbow sheen streak across the lit half (thin, three hues side by side)
for i = 0, 6 do
  local x, y = 23 + i, 35 + floor(i * 0.5)
  for j, col in ipairs(SHEEN) do
    local px, py = x, y + j - 1
    local k = K(px, py)
    if m:has(px, py) and S[k] and S[k] < -0.25 and d[k] > 1.2 and d[k] < 2.6 or (m:has(px, py) and S[k] and S[k] < -0.3 and d[k] > 3.6) then c:put(px, py, col, tok) end
  end
end
-- specular on the keel near the widest point + sparkle
c:put(33, 27, A.CREAM, tok) c:put(34, 26, A.CREAM, tok)
c:sparkle(41, 19)

-- quirk: ragged shed-skin scrap at the root
local ktok = { r = { name = "skin" } }
local skin = c:poly{ { 15, 52 }, { 19, 50 }, { 23, 54 }, { 22, 57 }, { 20, 56 }, { 19, 59 }, { 17, 56 }, { 15, 57 } }
skin:cut(m:copy():cut(c:rect(0, 54, 63, 63)))
skin:each(function(x, y)
  local i = 2
  if x + y < 69 then i = 3 end
  if x + y > 74 or y >= 57 then i = 1 end
  c:put(x, y, SKIN[i], ktok)
end)
-- AO where the skin tucks under the scale
m:each(function(x, y) if skin:has(x, y + 1) or skin:has(x + 1, y + 1) then if T[K(x, y)] and T[K(x, y)] < 0.12 then c:put(x, y, IRI[1], tok) end end end)

A.save(c, NAME)
