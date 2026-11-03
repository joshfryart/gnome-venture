-- ico-bread (final, Opus). A slim bloomer loaf on the diagonal (heel lower-left, nose upper-right), domed top
-- and a flat baked base, four slanted scores opened into lifted ears.
-- Material: per-pixel ellipsoid light (6-tone glazed crust, cool-violet shade), egg-wash specular streak and glint,
-- pale matte crumb inside each score with a lit ear above and a shadowed wall below, flour dust on the crown,
-- darker caramelised base with AO, cool reflected light along the lower edge.
-- quirk: someone could not wait - a bite out of the nose shows the airy crumb, two crumbs falling.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-bread")
local CRUST = { "#5a2a26", "#88402a", "#b4602e", "#d6843a", "#eeaa52", "#ffd184" }
local CRUMB = { "#b98a56", "#e6c890", "#f6e2b6", "#fff0cc" }
local FLOUR, SPEC, BOUNCE = "#f6e8cc", "#fff4d6", "#8a4a5a"

local CX, CY, RX, RY, ANG = 31.5, 32, 23.5, 10.5, -0.52
local ux, uy = cos(ANG), sin(ANG)
local vx, vy = -uy, ux                           -- across the loaf, +v = lower-right (base side)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ux + dy * uy, dx * vx + dy * vy end
local function scr(u, v) return CX + u * ux + v * vx, CY + u * uy + v * vy end

local loaf, ln = A.oval(CX, CY, RX, RY, ANG, 0.9)
local BASEV = RY * 0.62
-- flat base: trim the bottom of the ellipse
loaf:each(function(x, y) local u, v = loc(x, y) if v > BASEV + 0.5 then loaf.s[K(x, y)] = nil ln[K(x, y)] = nil end end)

-- bite out of the nose
local bite = HP.mask()
for _, b in ipairs{ { RX - 5.5, -RY + 0.2, 3.8 }, { RX - 11.5, -RY + 0.6, 3.4 } } do
  local bx, by = scr(b[1], b[2])
  bite:add(A.ellM(bx, by, b[3], b[3]))
end
local face = loaf:copy():clip(bite:grow(3)):cut(bite)
loaf:cut(bite)

local ctok = { r = { name = "crust" } }
local bias = {}
loaf:each(function(x, y) local u, v = loc(x, y) local k = K(x, y)
  if v > BASEV - 0.8 then bias[k] = -1 end end)
local idx = A.shade(c, loaf, ln, CRUST, { tok = ctok, bias = bias, amb = 0.06, wrap = 0.32, cuts = { 0.1, 0.28, 0.5, 0.7, 0.88 } })

-- scores: slanted slashes across the crown
local mtok = { r = { name = "crumb" } }
local SC = { -15, -7.5, 0, 7.5 }
loaf:each(function(x, y) local u, v = loc(x, y)
  if v < -RY * 0.85 or v > 4.6 then return end
  for _, t in ipairs(SC) do
    local d = (u - t) - 0.45 * v
    local half = 1.15 - max(0, abs(v + 1.8) - 3.6) * 0.4
    if half > 0.05 then
      if abs(d) <= half then c:put(x, y, (v < -2 and CRUMB[4]) or (v < 1.5 and CRUMB[3]) or CRUMB[2], mtok) idx[K(x, y)] = nil
      elseif d > half and d <= half + 1.1 then A.step(c, idx, CRUST, x, y, -3, ctok)
      elseif d < -half and d >= -half - 1.1 then A.step(c, idx, CRUST, x, y, 1, ctok) end
    end
  end
end)

-- flour dust on the crown (sparse, only on lit crust)
loaf:each(function(x, y) local u, v = loc(x, y) local k = K(x, y)
  if v < -3 and idx[k] and idx[k] >= 4 and X.hash(x, y, 11) > 0.9 then c:put(x, y, FLOUR, ctok) end end)

-- cool reflected light along the lower-right edge (above the base)
loaf:each(function(x, y) local u, v = loc(x, y) local k = K(x, y)
  if idx[k] and not loaf:has(x + 1, y + 1) and not loaf:has(x + 1, y) and v > 1 and v < BASEV - 1 and u > -RX + 5 and u < RX - 7 then c:put(x, y, BOUNCE, ctok) end end)

-- egg-wash streak + one glint on the shoulder
for _, p in ipairs{ { -18, -6.2 }, { -17, -6.6 }, { -16, -7 }, { -9, -7.8 }, { -8, -8 } } do
  local x, y = scr(p[1], p[2]) x, y = floor(x + .5), floor(y + .5)
  if loaf:has(x, y) and idx[K(x, y)] then c:put(x, y, CRUST[6], ctok) end
end
do local x, y = scr(-17, -6.6) c:put(floor(x + .5), floor(y + .5) - 1, SPEC, ctok) end

-- bite face: airy crumb with holes, crust shell kept 1 px
local shell = loaf:copy():add(face):edge()
face:each(function(x, y)
  local k = K(x, y)
  local nearBite = bite:has(x + 1, y) or bite:has(x - 1, y) or bite:has(x, y + 1) or bite:has(x, y - 1)
  if shell:has(x, y) and not nearBite then return end
  if bite:grow(3):has(x, y) and not bite:grow(2):has(x, y) then c:put(x, y, CRUST[3], ctok) return end
  local u, v = loc(x, y)
  local tone = (v > 3.5) and CRUMB[2] or ((u + v * 0.3 < RX - 5.5) and CRUMB[3] or CRUMB[4])
  c:put(x, y, tone, mtok)
  if X.hash(x, y, 4) > 0.8 and not nearBite then c:put(x, y, CRUMB[1], mtok) end
end)
-- crust lip around the bite rim reads as a darker edge
face:each(function(x, y) if not face:has(x - 1, y) and loaf:has(x - 1, y) then A.step(c, idx, CRUST, x - 1, y, -1, ctok) end end)

-- quirk: two crumbs falling from the bite
do local x, y = scr(RX + 0.5, 6.5) x, y = floor(x + .5), floor(y + .5)
  A.map(c, { "hc", "cd" }, x, y + 1, { h = CRUMB[4], c = CRUMB[3], d = CRUST[4] }, mtok)
  A.map(c, { "hd" }, x + 4, y + 2, { h = CRUMB[3], d = CRUST[4] }, mtok)
end

A.save(c, "ico-bread")
