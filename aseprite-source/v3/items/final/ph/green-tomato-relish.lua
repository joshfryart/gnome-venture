-- green-tomato-relish (aC10_1, Opus single pass). A tall slim glass jar of chunky relish: diced green tomato
-- (lit facets), onion dice, mustard seeds and red pepper flecks in a yellow-green brine, shaded per pixel as a
-- cylinder with AO at the glass walls and floor. Glass: bright left rim and a broken pale streak, cool reflected
-- light on the right edge, a thick base with a pale core, an empty headspace band. Top: green gingham cloth (weave
-- checks, puffed dome, radiating fold shadows, pinked hem) tied round the neck with twisted twine and a bow.
-- Ground shadow under the jar.
-- quirk: a little kraft paper tag dangles from the bow, its corner curled up, with a green tomato doodle.
local NAME = "green-tomato-relish"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local BRINE = { "#3a4418", "#56661c", "#768a24", "#98ac30", "#bccb4c", "#dfe684" }
local TOM   = { "#1f4626", "#2e6430", "#45843a", "#62a446", "#8cc45a", "#bce07c" }
local ONION = { "#8e8a6a", "#b4b08a", "#d6d4ae", "#f2f0d0" }
local MUST, PEPR = "#e8b83a", "#c8463a"
local GLE  = { "#284e48", "#467e70", "#86c2b0", "#dcf6ec" }
local GL   = { "#5e9a92", "#86bcb2", "#b2dccf", "#d8f0e6" }
local GCRM = { "#9a8e74", "#c9bc9a", "#eee3c2", "#fff6e0" }
local GMID = { "#2f5a34", "#3f7a40", "#5c9c4c", "#86be62" }
local GDRK = { "#1c3826", "#24502e", "#336c38", "#4c8a44" }
local TW   = { "#5a3c26", "#8c6438", "#bc9256", "#e2c486" }
local KR   = { "#6a4a2e", "#9a7046", "#c49a62", "#e4c48c", "#f6e2b0" }
local SPEC, BOUNCE = "#f6fff4", "#a6dcd4"
local CX = 32

c:groundShadow(32, 53.5, 13, 1.5)

-- glass body
local jar = c:rrect(21, 22, 43, 52, 4)
local gtok = { r = { name = "glass" } }
local ctok = { r = { name = "relish" } }
local function lightX(x) -- cylinder light across the jar
  local t = max(-0.97, min(0.97, (x - CX) / 11.5))
  local n = { t, 0, sqrt(1 - t * t) }
  local L = X.L
  local d = n[1] * L[1] + n[3] * L[3]
  return max(0, min(1, 0.1 + 0.9 * (d + 0.3) / 1.3))
end
local CUT6 = { 0.2, 0.35, 0.5, 0.64, 0.78 }
local function idx6(v) local i = 1 for j, t in ipairs(CUT6) do if v >= t then i = j + 1 end end return i end
-- contents
local fill = c:rect(22, 30, 42, 50)
fill:cut(c:rect(22, 50, 22, 50)):cut(c:rect(42, 50, 42, 50))
fill:each(function(x, y)
  local i = idx6(lightX(x) + (x < 26 and 0.06 or 0))
  if x == 22 or x == 42 or y == 50 then i = i - 1 end
  if y == 30 then i = i + 1 end
  i = max(1, min(6, i))
  local cx2, cy2 = floor((x + (floor(y / 2) % 2)) / 2), floor(y / 2)
  local h = X.hash(cx2, cy2, 21)
  local col = BRINE[i]
  if y > 30 then
    if h < 0.42 then
      local fx, fy = (x + (floor(y / 2) % 2)) % 2, y % 2
      local j = i + ((fx == 0 and fy == 0) and 1 or 0) - ((fx == 1 and fy == 1) and 1 or 0)
      col = TOM[max(1, min(6, j))]
    elseif h < 0.53 then col = ONION[max(1, min(4, i - 2))]
    elseif h < 0.56 then col = PEPR end
    if X.hash(x, y, 33) > 0.93 then col = MUST end
  end
  c:put(x, y, col, ctok)
end)
-- surface meniscus bumps
for _, x in ipairs{ 24, 25, 29, 33, 34, 38 } do c:put(x, 29, BRINE[max(2, idx6(lightX(x)) - 1)], ctok) end
-- headspace (empty glass) above the relish
for y = 25, 29 do for x = 22, 42 do
  if jar:has(x, y) and not c:get(x, y) then
    local v = lightX(x)
    local i = v > 0.7 and 4 or v > 0.5 and 3 or v > 0.3 and 2 or 1
    if y == 29 then i = max(1, i - 1) end
    c:put(x, y, GL[i], gtok)
  end
end end
-- glass walls and thick base
jar:each(function(x, y)
  if fill:has(x, y) or (y >= 25 and y <= 29 and x >= 22 and x <= 42) then return end
  local col
  if y >= 51 then col = (x > 24 and x < 36 and y == 51) and GLE[4] or (x < 32 and GLE[3] or GLE[2])
  elseif x <= 22 then col = GLE[3]
  elseif x >= 42 then col = GLE[2]
  else col = GL[2] end
  c:put(x, y, col, gtok)
end)
c:put(22, 50, GLE[2], gtok) c:put(42, 50, GLE[1], gtok)
-- glass highlights: bright rim left, broken pale streak, cool reflected light right
for y = 31, 48 do if y ~= 41 and y ~= 42 then c:put(24, y, GL[4], gtok) end end
for y = 32, 37 do c:put(25, y, GL[3], gtok) end
c:put(24, 31, SPEC, gtok) c:put(24, 32, SPEC, gtok)
for y = 33, 48 do c:put(41, y, BOUNCE, gtok) end

-- gingham cloth top: puffed dome + flared skirt with pinked hem
local dome = c:ellipse(CX, 16.5, 10.5, 5)
local skirt = HP.mask()
for y = 20, 27 do
  local t = (y - 20) / 7
  local h = 10.5 + t * 3.4
  for x = floor(CX - h + 0.5), floor(CX + h + 0.5) do
    local hem = 26 + ((floor((x + 1) / 2) % 2 == 0) and 1 or 0)
    if y <= hem then skirt:set(x, y) end
  end
end
local cloth = dome:copy():add(skirt)
local cn = {}
cloth:each(function(x, y)
  local nx = (x - CX) / 14
  local ny = dome:has(x, y) and not skirt:has(x, y) and (y - 16.5) / 6 or 0.35
  if skirt:has(x, y) then ny = 0.25 + (y - 20) * 0.06 end
  cn[K(x, y)] = { G.norm(nx, ny, sqrt(max(0.08, 1 - nx * nx - ny * ny))) }
end)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
local cltok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local v = cv[k]
  local i = v > 0.78 and 4 or v > 0.55 and 3 or v > 0.32 and 2 or 1
  -- radiating fold shadows on the skirt, gather creases on the dome
  if skirt:has(x, y) and y > 21 then
    local fx = (x - CX) / (1 + (y - 20) * 0.45)
    if abs(fx - floor(fx / 2.6 + 0.5) * 2.6) < 0.35 and y > 22 then i = i - 1 end
  end
  if dome:has(x, y) and not skirt:has(x, y) and y > 17 and (x % 4 == 1) then i = i - 1 end
  i = max(1, min(4, i))
  local a = floor((x + 1) / 3) % 2
  local b = floor((y + 1) / 3) % 2
  local lv = a + b
  c:put(x, y, (lv == 0 and GCRM or lv == 1 and GMID or GDRK)[i], cltok)
end)
-- AO: under the skirt hem on the glass, under the dome on the skirt
skirt:shift(0, 1):each(function(x, y) if jar:has(x, y) and not skirt:has(x, y) then
  local v = lightX(x) c:put(x, y, v > 0.5 and GLE[2] or GLE[1], gtok) end end)
c:put(26, 13, GCRM[4], cltok) c:put(27, 13, GCRM[4], cltok)   -- sheen on the dome

-- twine round the neck (twisted)
local ttok = { r = { name = "twine" } }
for y = 20, 21 do for x = 22, 42 do
  local i = ({ 2, 3, 4 })[(x + y) % 3 + 1]
  if x > 37 then i = max(1, i - 1) end
  if y == 21 then i = max(1, i - 1) end
  c:put(x, y, TW[i], ttok)
end end
-- bow: two loops and twisted tails (right front)
local bow = { { 35, 19, 3 }, { 34, 18, 4 }, { 33, 18, 3 }, { 32, 19, 2 }, { 37, 19, 3 }, { 38, 18, 4 }, { 39, 18, 3 }, { 40, 19, 2 },
              { 36, 20, 4 }, { 36, 21, 2 } }
for _, p in ipairs(bow) do c:put(p[1], p[2], TW[p[3]], ttok) end
for _, p in ipairs{ { 35, 22, 3 }, { 35, 23, 2 }, { 34, 24, 3 }, { 34, 25, 1 }, { 37, 22, 3 }, { 37, 23, 2 }, { 38, 24, 3 }, { 38, 25, 2 }, { 39, 26, 3 } } do
  c:put(p[1], p[2], TW[p[3]], ttok)
end

-- quirk: kraft tag hanging from the right tail, curled corner, tomato doodle
local tag = c:rect(37, 27, 43, 34)
tag:cut(c:rect(37, 27, 37, 27)):cut(c:rect(43, 27, 43, 27))
local ktok = { r = { name = "tag" } }
tag:each(function(x, y)
  local i = (x < 40) and 4 or 3
  if y == 27 then i = 5 end
  if x == 43 then i = 2 end
  if y == 34 then i = 2 end
  c:put(x, y, KR[i], ktok)
end)
-- string hole
c:put(40, 28, KR[1], ktok)
c:put(39, 26, TW[3], ttok) c:put(40, 27, TW[2], ttok)
-- curled corner (bottom right lifts, showing the pale back)
c:put(43, 34, KR[5], ktok) c:put(42, 34, KR[4], ktok) c:put(43, 33, KR[5], ktok) c:put(42, 33, KR[2], ktok)
-- tomato doodle
c:put(39, 31, GMID[3], ktok) c:put(40, 31, GMID[4], ktok) c:put(39, 32, GMID[2], ktok) c:put(40, 32, GMID[2], ktok) c:put(40, 30, GDRK[2], ktok)
-- contact shadow of the tag on the glass
for y = 28, 35 do if jar:has(44, y) then c:put(44, y, GLE[1], gtok) end end
for x = 38, 43 do if jar:has(x, 35) then c:put(x, 35, GLE[1], gtok) end end

G.save2(c, NAME)
