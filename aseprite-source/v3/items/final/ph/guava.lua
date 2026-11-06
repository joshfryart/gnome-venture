-- guava (final, Opus single pass). One slightly pear-shaped guava, yellow-green with a rosy blush on the sunny
-- shoulder, freckled with pale lenticels, a dry five-point crown at the blossom end and a short woody stalk
-- carrying one oblong guava leaf (sunken parallel veins, V-fold light, cool edge).
-- Material: sphere/pillow light on a 6-tone ramp, waxy bloom band, one specular, cool reflected rim lower-right,
-- AO under the stalk. Draft by Sonnet replaced.
-- quirk: a bite out of the right flank shows coral-pink flesh and two tiny cream seeds.
local NAME = "guava"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new(NAME)

local SKIN  = { "#34502c", "#557a30", "#7fa23a", "#a9c64a", "#d0e06a", "#eef3a6" }
local BLUSH = { "#5c2a3a", "#8c3646", "#bc5050", "#dc7458", "#f09c72", "#ffd2a4" }
local FLESH = { "#7a2440", "#b83a52", "#e05a64", "#f68478", "#ffb09a" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD  = { "#3a2622", "#5b3e2e", "#81603f", "#a8844f" }
local CROWN = { "#2e2226", "#4a3428", "#6e5034" }
local COOL  = "#5e8a7e"

-- body: round base + narrower shoulder toward the stalk (pear-ish, slim)
local CX, CY, R = 31, 38, 12.5
local body = c:ellipse(CX, CY, 12.5, 13):add(c:ellipse(CX + 0.5, 28.5, 8, 7.5))
-- quirk bite: scalloped notch on the right flank (three tooth arcs)
local bite = HP.mask()
for _, b in ipairs{ { 44.2, 33.5, 2.6 }, { 45, 38, 3.0 }, { 44.2, 42.5, 2.6 } } do bite:add(c:ellipse(b[1], b[2], b[3], b[3])) end
body:cut(bite)

-- stalk + leaf first (behind the shoulder)
local stok = { r = { name = "stalk" } }
local sm = A.stem(c, { { 32, 23 }, { 32, 19 }, { 33, 16 }, { 35, 13 } }, function(t) return 1.1 - 0.25 * t end, WOOD, { tok = stok })
c:put(35, 12, WOOD[3], stok) c:put(36, 12, WOOD[4], stok)       -- snapped end, paler wood
local ltok = { r = { name = "leaf" } }
local lm = A.leaf(c, 35, 14, 45, 4, 55, 10, 4.2, LEAF, { tok = ltok, vs = 2.6, cut = sm })
-- cool reflected edge on the leaf underside
lm:edge():each(function(x, y) if x + y > 59 and x > 40 and x < 53 then c:put(x, y, "#3a6c72", ltok) end end)

-- body light
local n = A.body(body, CX - 0.5, CY - 1, 13, 5, 0.65)
local bias = {}
X.ao(bias, body, sm, 2, -1)
local btok = { r = { name = "guava" } }
local v = X.light(n, { amb = 0.06, wrap = 0.24 })
local idx = {}
body:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.83 } do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0))) idx[k] = i
  -- rosy blush on the upper-right shoulder, ragged boundary (hard pixels)
  local bx, by = x - 37, y - 30
  local d = sqrt(bx * bx * 0.8 + by * by)
  local blush = d < 7.5 + X.hash(x, y, 3) * 2.2
  c:put(x, y, (blush and BLUSH or SKIN)[i], btok)
end)
-- lenticels: sparse pale freckles, one tone up (not on the darkest rim)
body:shrink(1):each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 11) > 0.93 and idx[k] >= 2 and idx[k] <= 5 then
    local bx, by = x - 37, y - 30
    c:put(x, y, (sqrt(bx * bx * 0.8 + by * by) < 7.5 and BLUSH or SKIN)[idx[k] + 1], btok) end end)
-- waxy bloom: a pale band hugging the lit upper-left, just inside the rim
body:each(function(x, y) local k = K(x, y)
  if idx[k] == 5 and not body:has(x - 2, y - 2) then c:put(x, y, SKIN[6], btok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and y > CY and not bite:grow(1):has(x, y) then c:put(x, y, COOL, btok) end end)

-- bite face: cut flesh next to the notch, pale rind line between flesh and skin
local near1, near3 = bite:grow(2), bite:grow(3)
body:each(function(x, y)
  if near1:has(x, y) then
    local lit = (x + y) < 78 and 4 or ((x + y) < 82 and 3 or 2)
    if bite:grow(1):has(x, y) then lit = lit - 1 end
    c:put(x, y, FLESH[max(1, lit)], btok)
  elseif near3:has(x, y) then c:put(x, y, "#f2eebc", btok) end
end)
c:put(41, 37, "#fff4d6", btok) c:put(41, 40, "#e8d6a0", btok)  -- two tiny seeds in the flesh
c:put(42, 35, FLESH[5], btok)                                     -- wet glint on the cut

-- crown at the blossom end: dark five-point star with lit tips
local crown = { {30,50,2},{31,50,1},{32,50,2},{31,49,3},{29,49,2},{33,49,2},{31,51,1},{30,51,2},{32,51,2},{28,48,3},{34,48,3},{31,48,3} }
for _, p in ipairs(crown) do c:put(p[1], p[2], CROWN[p[3]], btok) end
-- AO under stalk foot
c:put(31, 24, SKIN[2], btok) c:put(32, 24, SKIN[1], btok) c:put(33, 24, SKIN[2], btok)

-- specular + small bloom halo
local sx, sy = G.specAt(body, n, 40)
c:put(sx, sy, "#fff4d6", btok) c:put(sx + 1, sy, "#fff4d6", btok) c:put(sx, sy + 1, SKIN[6], btok)

A.save(c, NAME)
