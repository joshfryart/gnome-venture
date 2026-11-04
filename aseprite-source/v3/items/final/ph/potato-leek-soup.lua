-- potato-leek-soup (D10, single pass). A wide teal stoneware bowl seen from above-front: bevelled rim, speckled glaze,
-- curved cream band round the wall, small foot ring; creamy soup with a swirl of cream, leek rings (pale green outside,
-- white inside, holes showing soup), potato cubes, chive dashes, pepper; a spoon leaning on the back rim; one steam
-- curl. Per-pixel light on the wall, rim and soup; AO under the back rim, under the body and beside the leek rings.
-- quirk: a leek ring has slipped onto the spoon handle like a tiny hoop.
local NAME = "potato-leek-soup"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local TEAL = { "#16384a", "#21566a", "#2f7a88", "#46a0a4", "#78c8bc", "#b8ecd8" }
local SOUP = { "#a98a62", "#c9a678", "#e2c894", "#f2e0b0", "#fbefc9", "#fffaea" }
local LEEK = { "#3a6a3a", "#5c9444", "#8cba5a", "#b8d886", "#e0eeb0", "#f6fad4" }
local STONE = { "#444663", "#74758c", "#a0a0b4", "#c4c4d2", "#e2e0e6", "#f6f4f8" }
local STM = { "#8ea4bc", "#b4c6d8", "#d4e0ea", "#ecf3f6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local CX, CY, RX, RY = 32, 34, 22, 8.5
local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry - 1), math.ceil(cy + ry + 1) do for x = floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    if ((x + 0.5 - cx) / rx) ^ 2 + ((y + 0.5 - cy) / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

c:groundShadow(32, 56, 17, 2)
-- wall profile
local function bw(y)
  if y >= 52 then return 8.6 - (y - 52) * 0.15 end
  local t = (y - CY) / 19
  if t < 0 then return RX end
  return RX * max(0.3, (1 - t ^ 1.9)) ^ 0.55
end
local body = HP.mask()
for y = 34, 55 do local w = bw(y) for x = 0, 63 do if abs(x + 0.5 - CX) <= w then body:set(x, y) end end end
-- thin neck between body and foot (undercut)
for y = 50, 51 do for x = 0, 63 do if abs(x + 0.5 - CX) > 10.2 - (y - 50) * 0.8 then body:cut(HP.mask():set(x, y)) end end end
local bn = {}
body:each(function(x, y)
  local sx = max(-0.97, min(0.97, (x + 0.5 - CX) / (bw(min(y, 40)) + 0.5)))
  local t = max(0, (y - 34) / 19)
  if y >= 52 then t = 0.2 end
  bn[K(x, y)] = { G.nrm(sx, 0.15 + 0.85 * t, sqrt(max(0.05, 1 - sx * sx)) * (1 - 0.35 * t)) }
end)
local bbias = {}
body:each(function(x, y) if y == 51 or (y == 50 and abs(x + 0.5 - CX) > 8) then bbias[K(x, y)] = -1 end if y == 52 then bbias[K(x, y)] = -2 end end)
local btok = { r = { name = "bowl" } }
local bi = X.tone(c, body, X.light(bn, { amb = 0.1, wrap = 0.3 }), TEAL, { cuts = { 0.28, 0.44, 0.6, 0.74, 0.88 }, bias = bbias, tok = btok })
-- cream band following the rim's front arc (2 rows + a dotted row)
body:each(function(x, y)
  local dx = x + 0.5 - CX
  local yarc = CY + 5.2 + RY * sqrt(max(0, 1 - (dx / RX) ^ 2))
  local d = (y + 0.5) - yarc
  if abs(dx) < bw(y) - 1.2 and y < 50 then
    if d >= 0 and d < 2 then c:put(x, y, d < 1 and "#f7e0a0" or "#d6a860", btok)
    elseif d >= 2 and d < 3 and (x % 2 == 0) then c:put(x, y, "#d6a860", btok) end
  end
  -- glaze speckles
  local h = X.hash(x, y, 6)
  local i = bi[K(x, y)]
  if y < 50 and not (d >= 0 and d < 3) then
    if h > 0.94 then c:put(x, y, TEAL[min(6, i + 1)], btok) elseif h < 0.035 then c:put(x, y, TEAL[max(1, i - 1)], btok) end
    if h > 0.992 then c:put(x, y, "#d8f0e0", btok) end
  end
end)
-- wall specular streak (left) + cool bounce at the bottom edge
for y = 40, 46 do local x = floor(CX - bw(y) + 3.6 + (y - 40) * 0.35) c:px(x, y, TEAL[6]) end
c:px(floor(CX - bw(40) + 3.0), 39, TEAL[5])
body:edge():each(function(x, y) if y > 44 and x > 34 and y < 50 then c:px(x, y, TEAL[4]) end end)
for x = 24, 40 do if body:has(x, 55) then c:px(x, 55, TEAL[2]) end end

-- rim ring (torus-ish): outer ellipse minus inner
local outer = ell(CX, CY, RX, RY)
local inner = ell(CX, CY + 0.2, RX - 2.8, RY - 1.9)
local rim = outer:copy():cut(inner)
local rtok = { r = { name = "rim" } }
rim:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / RX, (y + 0.5 - CY) / RY
  local th = math.atan(dy, dx)
  local lit = -(0.55 * cos(th) + 0.7 * sin(th)) / 0.89          -- -1..1
  local v = 0.5 + 0.38 * lit
  local i = 1
  for j, t in ipairs{ 0.3, 0.45, 0.58, 0.72, 0.86 } do if v >= t then i = j + 1 end end
  -- bevel: the outermost pixel is a touch brighter, the inner edge a touch darker
  local o = not outer:has(x + (dx > 0 and 1 or -1), y) or not outer:has(x, y + (dy > 0 and 1 or -1))
  if o then i = min(6, i + 1) end
  if inner:grow(1):has(x, y) and not o then i = max(1, i - 1) end
  c:put(x, y, TEAL[i], rtok)
end)
-- rim sparkle
c:px(15, 30, TEAL[6]) c:px(16, 29, TEAL[6]) c:px(17, 28, TEAL[5])

-- inner back wall (shadowed) then the soup surface
inner:each(function(x, y)
  local dy = (y + 0.5 - CY)
  c:put(x, y, dy < -2.5 and TEAL[1] or TEAL[2], rtok)
end)
local soup = ell(CX, CY + 1.0, RX - 3.5, RY - 2.7)
local stok = { r = { name = "soup" } }
local sbias = {}
soup:each(function(x, y)
  local k = K(x, y)
  local u, v = (x + 0.5 - CX) / (RX - 3.5), (y + 0.5 - CY - 1.0) / (RY - 2.7)
  local rho, th = sqrt(u * u + v * v), math.atan(v, u)
  local i = 4
  if u + v * 1.2 < -0.95 then i = 2 elseif u + v * 1.2 < -0.6 then i = 3 end        -- shade under the back-left rim
  if u + v > 1.15 then i = 5 end                                                      -- sheen toward the front-right
  -- cream swirl: pale spiral line with a shadow edge
  local s = (rho * 3.2 - th / (2 * pi)) % 1
  if rho < 0.88 and rho > 0.12 then
    if s < 0.17 then i = 6 elseif s < 0.3 then i = max(2, i - 1) end
  end
  local h = X.hash(x, y, 4)
  if h > 0.95 and rho < 0.9 then i = max(2, i - 1) end
  c:put(x, y, SOUP[i], stok)
end)
-- meniscus: soup edge lip against the rim, bright on the front half
soup:edge():each(function(x, y) if y > CY + 1 then c:put(x, y, SOUP[5], stok) elseif y > CY - 2 then c:put(x, y, SOUP[3], stok) end end)

-- floating things on the soup
local function ring(cx, cy, rx, ry)
  local mo = ell(cx, cy, rx, ry)
  local mi = ell(cx, cy - 0.1, rx - 1.35, ry - 0.8)
  local rm = mo:copy():cut(mi)
  local tok = { r = { name = "leek" } }
  -- soft contact shadow on the soup, right and below
  mo:shift(1, 1):each(function(x, y) if soup:has(x, y) and not mo:has(x, y) then c:put(x, y, SOUP[2], stok) end end)
  local n = X.pillow(rm, 1.4)
  local i = X.tone(c, rm, X.light(n, { amb = 0.2, wrap = 0.35 }), LEEK, { cuts = { 0.28, 0.46, 0.62, 0.78, 0.9 }, tok = tok })
  -- inner (white) layer: bright inside edge on the lit half
  mi:grow(1):cut(mi):clip(rm):each(function(x, y) if (x + 0.5 - cx) + (y + 0.5 - cy) < 0.2 then c:put(x, y, LEEK[6], tok) end end)
  mi:each(function(x, y) c:put(x, y, SOUP[(x + 0.5 - cx) + (y + 0.5 - cy) < 0 and 3 or 4], stok) end)
  return mo
end
ring(22.5, 36.6, 3.1, 1.7)
ring(31.5, 39.4, 3.4, 1.8)
ring(40.5, 34.6, 3.0, 1.6)
ring(43.5, 38.8, 2.6, 1.5)
ring(27.2, 33.1, 2.4, 1.3)
-- potato cubes (top face pale, front face golden)
for _, q in ipairs{ { 35, 36 }, { 25, 38 }, { 38, 40 } } do
  local x, y = q[1], q[2]
  for dx = 0, 2 do c:put(x + dx, y, dx == 0 and "#fff2c0" or "#f3dc98", stok) c:put(x + dx, y + 1, dx == 2 and "#b88a46" or "#d8b062", stok) end
  c:put(x + 3, y + 1, "#a87c3e", stok)
end
-- chives and pepper
for _, q in ipairs{ { 28, 36 }, { 33, 33 }, { 20, 34 }, { 36, 38 }, { 44, 36 }, { 30, 41 } } do
  c:put(q[1], q[2], "#78bb5c", stok) c:put(q[1] + 1, q[2], "#3f9150", stok)
end
for _, q in ipairs{ { 26, 35 }, { 38, 37 }, { 33, 37 }, { 42, 33 }, { 24, 40 }, { 29, 34 }, { 36, 35 } } do c:put(q[1], q[2], "#4a3a34", stok) end
-- gloss on the cream
c:put(24, 33, SOUP[6], stok) c:put(25, 33, SOUP[6], stok) c:put(23, 34, SOUP[5], stok)

-- spoon leaning on the back rim (bowl in the soup, handle over the rim), leek-ring hoop on the handle (quirk)
local hm, hn, HT = G.tube({ { 40, 31.5 }, { 46, 30 }, { 52, 27.5 }, { 58, 21.5 } }, function(t) return 1.05 end)
local sbowl = G.rell(37.6, 32.6, 0.92, -0.38, 4.2, 2.6)
local spoon = hm:copy():add(sbowl)
local sn = {}
hm:each(function(x, y) sn[K(x, y)] = hn[K(x, y)] end)
local bn2 = X.pillow(sbowl, 2.2)
sbowl:each(function(x, y) sn[K(x, y)] = bn2[K(x, y)] end)
-- contact shadow on the rim / soup under the handle
spoon:shift(1, 2):each(function(x, y) if (rim:has(x, y) or soup:has(x, y)) and not spoon:has(x, y) then c:put(x, y, TEAL[1]) end end)
local spt = { r = { name = "spoon" } }
X.tone(c, spoon, X.light(sn, { amb = 0.12, wrap = 0.3 }), STONE, { cuts = { 0.22, 0.4, 0.58, 0.75, 0.9 }, tok = spt })
-- spoon bowl dish with cream in it
local dish = sbowl:shrink(1)
dish:each(function(x, y) c:put(x, y, SOUP[((x + y) % 3 == 0) and 3 or 4], spt) end)
dish:edge():each(function(x, y) if x + y < 70 then c:put(x, y, STONE[2], spt) end end)
c:put(35, 31, SOUP[6], spt)
sbowl:edge():each(function(x, y) if x + y < 68 then c:put(x, y, STONE[5], spt) end end)
-- the leek hoop on the handle
do
  local cx, cy = 53.8, 26.4
  local mo, mi = ell(cx, cy, 3.1, 2.4), ell(cx, cy, 1.4, 0.9)
  local rm = mo:copy():cut(mi)
  local n = X.pillow(rm, 1.4)
  X.tone(c, rm, X.light(n, { amb = 0.2, wrap = 0.35 }), LEEK, { cuts = { 0.28, 0.46, 0.62, 0.78, 0.9 }, tok = { r = { name = "hoop" } } })
  c:put(floor(cx - 1.5), floor(cy - 2.0), LEEK[6])
end

-- steam: one fat S-curl, outlined with the rest
local sm, sn2, ST = G.tube({ { 26, 28.5 }, { 21, 23 }, { 30, 19.5 }, { 25, 12.5 } }, function(t) return 1.5 - 0.5 * t end)
X.tone(c, sm, X.light(sn2, { amb = 0.3, wrap = 0.4 }), STM, { cuts = { 0.35, 0.6, 0.82 }, tok = { r = { name = "steam" } } })
local sm2, sn3 = G.tube({ { 36, 27 }, { 40.5, 22 }, { 34, 18 }, { 38.5, 12 } }, function(t) return 1.2 - 0.4 * t end)
X.tone(c, sm2, X.light(sn3, { amb = 0.3, wrap = 0.4 }), STM, { cuts = { 0.35, 0.6, 0.82 }, tok = { r = { name = "steam" } } })
G.save2(c, NAME)
