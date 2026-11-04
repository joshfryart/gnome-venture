-- fermented-hot-sauce (B31, Opus single pass). A slim "woozy" glass bottle: long neck with a round shoulder ring,
-- straight body, deep red fermented chili sauce with pale seed flecks and a few rising bubbles in the neck.
-- Ribbed dark cap over a shrink band, a cream paper label wrapped round the body (cylinder-shaded, gold rule lines)
-- with a red chili and green stem printed on it. Glass: bright left rim, vertical specular streak, cool right edge,
-- thick base. Ground shadow.
-- quirk: a drip of sauce has run from under the cap down the neck and hangs as a fat droplet on the shoulder ring.
local NAME = "fermented-hot-sauce"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_1.lua")
local HP, X, K, P = G.HP, G.X, G.K, G.P
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local SAUCE = { "#3e0f22", "#661428", "#8f1c2a", "#b8292c", "#dc4436", "#f57650" }
local GLASS = { "#3a4a78", "#6a8aa8", "#a8cad6", "#d4ecea", "#f4fffc" }
local CAP   = { "#1e1820", "#36262e", "#54383c", "#7a5450", "#a8807a", "#d0aca0" }
local LABEL = { "#8a6a5a", "#b8987e", "#dcc4a2", "#f0dfbe", "#fbf0d8", "#fff8ea" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e" }
local CHILI = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local STEMG = { "#24544a", "#3f9150", "#7cc35a" }
local SPEC, FLECK = "#fff4d6", "#f5c86a"

local cx = 31.5
-- half width profile by row
local function hw(y)
  if y < 13 then return -1 end
  if y <= 15 then return 3.0 end                      -- lip under the cap
  if y <= 24 then return 2.4 end                      -- neck
  if y <= 26 then return 3.4 end                      -- woozy ring
  if y <= 27 then return 2.7 end
  if y <= 34 then local t = (y - 27) / 7 return 2.7 + 4.6 * sin(t * pi / 2) end  -- shoulder
  if y <= 52 then return 7.3 end
  if y <= 55 then return 7.3 - (y - 52) * 0.7 end    -- rounded heel
  return -1
end
local body = HP.mask()
for y = 10, 56 do local w = hw(y) if w > 0 then for x = floor(cx - w + .5), floor(cx + w - .5) do body:set(x, y) end end end
local n = {}
body:each(function(x, y) local w = hw(y) local t = max(-.96, min(.96, (x + .5 - cx) / (w + .3)))
  n[K(x, y)] = { G.norm(t, 0, sqrt(1 - t * t)) } end)

c:groundShadow(31, 57, 12, 1)

local inner = body:shrink(1)
local sauce = inner:copy():clip(HP.rect(0, 18, 63, 63))
local air = inner:copy():cut(sauce)
local gtok = { r = { name = "glass" } }
G.shade(c, sauce, n, SAUCE, { tok = gtok, amb = 0.08, wrap = 0.35, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
G.shade(c, air, n, GLASS, { tok = gtok, amb = 0.3, wrap = 0.4, cuts = { 0.3, 0.5, 0.7, 0.85 } })
-- glass rim
body:copy():cut(inner):each(function(x, y)
  local t = (x + .5 - cx) / (hw(y) + .3)
  c:put(x, y, t < -0.3 and GLASS[5] or (t > 0.3 and GLASS[1] or GLASS[3]), gtok) end)
-- thick base
for x = 24, 39 do if inner:has(x, 54) then c:put(x, 54, x < cx and GLASS[3] or GLASS[2], gtok) end
                   if inner:has(x, 53) then c:put(x, 53, SAUCE[1], gtok) end end
-- seed flecks and bubbles
for _, f in ipairs{ { 28, 51 }, { 33, 50 }, { 36, 52 }, { 30, 31 }, { 35, 33 } } do c:put(f[1], f[2], FLECK, gtok) end
c:put(31, 21, SAUCE[6], gtok) c:put(32, 23, SAUCE[5], gtok) c:put(30, 25, SAUCE[6], gtok)
-- meniscus
c:put(30, 18, SAUCE[5], gtok) c:put(31, 18, SAUCE[5], gtok) c:put(32, 18, SAUCE[4], gtok)
-- shade under the woozy ring (ambient)
for x = 29, 34 do if inner:has(x, 27) then c:put(x, 27, SAUCE[1], gtok) end end
-- specular streak on the shoulder and body
for y = 29, 33 do c:put(floor(cx - 4 + (33 - y) * 0.45), y, SPEC, gtok) end
for y = 49, 51 do c:put(26, y, SPEC, gtok) end
c:put(30, 25, SPEC, gtok)

-- label wrapped around the body
local lab = HP.rect(25, 36, 38, 47):clip(body)
local ltok = { r = { name = "label" } }
G.shade(c, lab, n, LABEL, { tok = ltok, amb = 0.2, wrap = 0.45 })
for x = 25, 38 do
  if lab:has(x, 36) then c:put(x, 36, GOLD[x < 33 and 3 or 2], ltok) end
  if lab:has(x, 47) then c:put(x, 47, GOLD[x < 33 and 2 or 1], ltok) end
  if body:has(x, 48) then c:put(x, 48, SAUCE[1], gtok) end    -- contact shade under the label
end
-- chili print on the label
local chm = HP.poly{ { 28.5, 40 }, { 31.5, 39 }, { 34, 40.5 }, { 35.5, 43.5 }, { 34.5, 44.5 }, { 32, 42.5 }, { 29, 42 } }
local chn = X.pillow(chm, 1.4)
local ctok = { r = { name = "chili" } }
G.shade(c, chm, chn, CHILI, { tok = ctok, amb = 0.2, wrap = 0.3, cuts = { 0.35, 0.6, 0.82 } })
c:put(30, 40, CHILI[4], ctok) c:put(31, 40, CHILI[4], ctok)
c:put(28, 40, STEMG[2], ctok) c:put(27, 39, STEMG[3], ctok) c:put(28, 39, STEMG[1], ctok) c:put(27, 38, STEMG[2], ctok)

-- cap with vertical ribs, shrink band
local cap = HP.rrect(28, 7, 35, 13, 1)
local cn = G.vcylN(cap, 28, 35, -0.15)
local captok = { r = { name = "cap" } }
local idx = G.shade(c, cap, cn, CAP, { tok = captok, amb = 0.1, wrap = 0.35 })
cap:each(function(x, y) if (x % 2 == 0) and y > 8 and y < 13 then c:put(x, y, CAP[max(1, (idx[K(x, y)] or 3) - 1)], captok) end end)
for x = 28, 35 do c:put(x, 7, x < 32 and CAP[6] or CAP[4], captok) end
for x = 28, 35 do c:put(x, 13, CAP[1], captok) end
-- shrink band: red sleeve with a perforation
local band = HP.rect(28, 14, 35, 16)
local btok = { r = { name = "band" } }
band:each(function(x, y) local t = (x - 28) / 7
  local col = t < 0.25 and CHILI[4] or (t > 0.7 and CHILI[1] or CHILI[2])
  if y == 16 then col = CHILI[1] end
  c:put(x, y, col, btok) end)
for x = 29, 35, 2 do c:put(x, 15, CHILI[1], btok) end

-- quirk: a drip running from under the band down the neck, a fat drop on the ring
local dtok = { r = { name = "drip" } }
for y = 17, 23 do c:put(34, y, y < 20 and SAUCE[4] or SAUCE[3], dtok) end
local drop = HP.ellipse(35, 25.5, 1.2, 1.6)
drop:each(function(x, y) c:put(x, y, (x + y < 60) and SAUCE[5] or SAUCE[2], dtok) end)
c:put(34, 25, SAUCE[6], dtok)

G.save(c, NAME)
