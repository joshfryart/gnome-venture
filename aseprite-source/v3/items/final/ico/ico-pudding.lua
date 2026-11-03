-- ico-pudding (Opus single pass). A tall creme caramel turned out on a porcelain plate: slim truncated cone of
-- custard, glossy caramel cap with drips of varied length, a caramel pool round the base. Material: custard lit
-- per pixel as a tapered cylinder (6-tone, waxy sheen streak, cool bounce lower-right); caramel 6-tone with several
-- glints (glossy material), dark AO where caramel meets custard; plate with a bevelled lip, flat well and a
-- 2-tone ground shadow.
-- quirk: a spoonful has been scooped out of the top-right edge, showing the paler, softer inside.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-pudding")
local CU = { "#7a4030", "#b8722e", "#e0a43a", "#f5c64e", "#ffe07e", "#fff0b4" }
local IN = { "#9a5a2a", "#d08e3c", "#f2c466", "#fff0bc" }      -- soft inside of the scoop
local CA = { "#3a1420", "#5e2220", "#86341c", "#ac4e1a", "#d0741e", "#f4a444" }
local PL = { "#46476a", "#6e7098", "#9a9dc0", "#c2c6de", "#e2e5f2", "#f6f4f8" }
local SPEC, BOUNCE = "#fff6e0", "#c07a6a"
c:groundShadow(32, 56, 21, 2)

local cx = 32
-- plate: top well ellipse + a thin rim below it
local plate = A.oval(cx, 50, 23, 5.2, 0):add(A.oval(cx, 52, 21, 4, 0))
local pn = {}
plate:each(function(x, y)
  local u, v = (x - cx) / 23.5, (y - 50) / 5.7
  local q = u*u + v*v
  if y > 50 + 5.2 * sqrt(max(0, 1 - ((x - cx) / 23.2) ^ 2)) then
    pn[K(x, y)] = { A.norm(u * 0.6, 0.85, 0.5) }                 -- underside rim facing down-front
  elseif q > 0.7 then
    pn[K(x, y)] = { A.norm(u * 0.7, v * 0.7 - 0.45, 0.6) }       -- raised lip
  else
    pn[K(x, y)] = { A.norm(u * 0.08, -0.72, 0.7) }               -- flat well
  end
end)
local ptok = { r = { name = "plate" } }
local pidx = A.shade(plate, pn, PL, { amb = 0.15, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ptok })
c:put(cx - 18, 47, PL[6], ptok) c:put(cx - 17, 47, PL[6], ptok)

-- custard: truncated cone, top ellipse y=25, base y=48
local TOP, BOT, RT, RB, EY = 24, 47, 10.5, 15, 3.2
local function hw(y) return RT + (RB - RT) * (y - TOP) / (BOT - TOP) end
local body = A.fmask(cx - 17, TOP - 4, cx + 17, BOT + 5, function(x, y)
  local yy = max(TOP, min(BOT, y))
  local w = hw(yy)
  local u = (x - cx) / (w + 0.4)
  if abs(u) > 1 then return false end
  local e = sqrt(1 - u*u)
  return y >= TOP - EY * e and y <= BOT + EY * 1.1 * e
end)
local cn, cT = {}, {}
body:each(function(x, y)
  local w = hw(max(TOP, min(BOT, y)))
  local u = (x - cx) / (w + 0.6)
  local nz = sqrt(max(0.04, 1 - u*u))
  cn[K(x, y)] = { A.norm(u, -0.18, nz) }
end)
-- scoop (concave bite) on the top-right edge
local SX, SY, SR = cx + 7, TOP + 0.5, 5.2
local scoop = A.fmask(SX - 6, SY - 6, SX + 6, SY + 6, function(x, y) return (x - SX)^2 + ((y - SY) * 1.25)^2 <= SR * SR end)
-- the bite removes the silhouette above the cut line and leaves a hollow below it
local gone = A.fmask(SX - 6, SY - 7, SX + 6, SY + 1, function(x, y) return scoop:has(x, y) and y < SY - 1 end)
body:cut(gone)
local cbias = {}
body:each(function(x, y) local k = K(x, y)
  if y >= BOT + 1 then cbias[k] = -1 end                            -- tuck at the plate
end)
local ctok = { r = { name = "custard" } }
local cidx = A.shade(body, cn, CU, { amb = 0.05, wrap = 0.25, cuts = { 0.26, 0.42, 0.58, 0.74, 0.88 }, bias = cbias, tok = ctok })
-- waxy sheen streak down the lit flank
for y = 33, 43 do local x = floor(cx - hw(y) + 3.2) if y ~= 39 then c:put(x, y, CU[6], ctok) end end
A.bounce(body, cn, BOUNCE, 0.62, function(x, y) return y > 32 and y < BOT end)

-- caramel: top cap + collar + drips of different lengths, rounded ends
local drips = { { -9, 34 }, { -5, 30 }, { -1, 38 }, { 3, 32 }, { 7, 36 }, { 11, 31 } }
local car = HP.mask()
body:each(function(x, y)
  local w = hw(max(TOP, min(BOT, y)))
  local u = (x - cx) / (w + 0.4)
  local e = sqrt(max(0, 1 - u*u))
  local collar = TOP + EY * e + 2.2
  local yl = collar
  for _, d in ipairs(drips) do
    local dx = x - (cx + d[1])
    if abs(dx) <= 1.4 then
      local tip = d[2] + EY * e
      local r = abs(dx) <= 0.6 and tip or tip - 1
      yl = max(yl, r)
    end
  end
  if y <= yl then car:set(x, y) end
end)
-- the bite cuts the caramel too
car:cut(scoop)
local an, abias = {}, {}
car:each(function(x, y) local k = K(x, y)
  local u = (x - cx) / (hw(max(TOP, min(BOT, y))) + 0.6)
  local e = sqrt(max(0, 1 - u*u))
  if y < TOP + EY * e - 0.5 then
    an[k] = { A.norm(u * 0.35, -0.85, 0.5) }            -- top face
  else
    an[k] = { A.norm(u, -0.12, sqrt(max(0.04, 1 - u*u))) }
  end
end)
-- AO on custard just under each caramel edge
body:each(function(x, y) local k = K(x, y)
  if not car:has(x, y) and car:has(x, y - 1) and not scoop:has(x, y) then c:put(x, y, CU[max(1, (cidx[k] or 3) - 2)], ctok) end end)
local atok = { r = { name = "caramel" } }
local aidx = A.shade(car, an, CA, { amb = 0.06, wrap = 0.25, cuts = { 0.28, 0.46, 0.62, 0.78, 0.93 }, tok = atok })
-- glossy glints: top rim highlight arc + one per drip bulb on the lit side
for x = cx - 8, cx - 1 do
  local u = (x - cx) / (RT + 0.4)
  local y = floor(TOP - EY * sqrt(max(0, 1 - u*u)) + 1.5)
  if car:has(x, y) and x % 3 ~= 0 then c:put(x, y, CA[6], atok) end
end
c:put(cx - 6, TOP - 1, SPEC, atok) c:put(cx - 5, TOP - 1, SPEC, atok)
for _, d in ipairs{ drips[1], drips[3] } do
  local x = cx + d[1] - 1
  local y = d[2] + 1
  if car:has(x, y) then c:put(x, y, CA[6], atok) end
end

-- scoop hollow: concave, lit on the lower-right wall, shadowed upper-left
local hol = scoop:copy():clip(body)
local hn = {}
hol:each(function(x, y)
  local u, v = (x - SX) / (SR + 0.5), (y - SY) * 1.25 / (SR + 0.5)
  hn[K(x, y)] = { A.norm(-u, -v, sqrt(max(0.05, 1 - u*u - v*v))) }
end)
local itok = { r = { name = "inside" } }
A.shade(hol, hn, IN, { amb = 0.05, wrap = 0.2, cuts = { 0.3, 0.55, 0.78 }, tok = itok })
-- caramel rim lip round the hollow (thin, dark) where it meets the cap
hol:each(function(x, y) if car:has(x - 1, y) or car:has(x, y - 1) then c:put(x, y, CA[3], atok) end end)

-- caramel pool on the plate round the base
local pool = A.oval(cx + 1, 50.5, 18.5, 3.6, 0)
local pn2 = {}
pool:each(function(x, y) pn2[K(x, y)] = { A.norm((x - cx) / 40, -0.75, 0.66) } end)
local pm = HP.mask() pool:each(function(x, y) if not body:has(x, y) then pm:set(x, y) end end)
A.shade(pm, pn2, CA, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.6, 0.75, 0.9 }, tok = atok })
pm:each(function(x, y) if body:has(x, y - 1) or body:has(x - 1, y) or body:has(x + 1, y) then c:put(x, y, CA[1], atok) end end)
c:put(cx - 14, 50, CA[6], atok) c:put(cx - 13, 50, CA[6], atok) c:put(cx + 13, 52, CA[5], atok)
A.done()
