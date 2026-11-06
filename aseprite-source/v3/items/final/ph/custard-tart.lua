-- custard-tart (final, Opus single pass). A pastel-de-nata style tart in 3/4 view: tapered fluted pastry cup with
-- laminated flaky layers on the wall, a rounded crust rim with scorched crests, and a glossy domed yellow custard
-- with leopard-spot caramelised blisters, a lit specular and an ambient ring where custard meets crust. Ground shadow.
-- quirk: a single curl of steam rises from the custard, coiling like a question mark.
local NAME = "custard-tart"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, asin = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.asin
local c = A.new(NAME)

local PA  = { "#5a2a16", "#8a4a1e", "#b8702a", "#d9973e", "#efbf68", "#fbe0a0" }
local CU  = { "#a0601a", "#cc8a22", "#eab032", "#f8cf4e", "#ffe684", "#fff6c4" }
local BURN = { "#3a1a14", "#64301a", "#9a5220" }
local STEAM = { "#c9c2da", "#ece6f0", "#fbf6f2" }

c:groundShadow(32, 50, 17, 1)

local CX, CY, RX, RY = 32, 31, 18, 7.5
local rimM = c:ellipse(CX, CY, RX, RY)
local side = c:poly{ {CX - RX, CY}, {CX + RX + 1, CY}, {CX + 14, CY + 13}, {CX - 13, CY + 13} }:add(c:ellipse(CX, CY + 13, 13, 4))
local cus  = c:ellipse(CX, CY + 0.5, RX - 4, RY - 2.5)

-- wall: tapered cylinder with flutes (12 ridges) and laminated layers
local ptok = { r = { name = "wall" } }
local n = {}
side:each(function(x, y)
  local t = (y - CY) / 13
  local r = RX + 0.5 - 4.5 * max(0, min(1, t))
  local a = max(-0.97, min(0.97, (x - CX) / r))
  local th = asin(a)
  local fl = sin(th * 11) * 0.45
  local nx = a + fl * sqrt(1 - a * a) * 0.8
  n[K(x, y)] = { A.norm(nx, 0.25, sqrt(max(0.05, 1 - nx * nx))) }
end)
local widx = A.shade(c, side, n, PA, { tok = ptok, amb = 0.08, wrap = 0.25 })
side:each(function(x, y)
  -- flaky layers: broken paler rows (spiral lamination)
  if (y - CY) % 3 == 1 and X.hash(x, y, 2) > 0.35 then A.step(c, widx, PA, x, y, 1, ptok) end
  -- scorched base and darker underside
  if y >= CY + 14 then A.step(c, widx, PA, x, y, -1, ptok) end
end)

-- rim: rounded crust ring (torus), crests scorched
local rtok = { r = { name = "rim" } }
local rn = A.mix(X.pillow(rimM:copy():cut(cus), 2.2), A.ellN(rimM, CX, CY, RX, RY, 1.4), 0.35)
local ring = rimM:copy():cut(cus)
local ridx = A.shade(c, ring, rn, PA, { tok = rtok, amb = 0.1, wrap = 0.3 })
ring:each(function(x, y) local h = X.hash(x, y, 9)
  if (ridx[K(x, y)] or 1) >= 4 and h < 0.13 then c:put(x, y, BURN[3], rtok)
  elseif h > 0.965 then c:put(x, y, BURN[2], rtok) end end)
-- inner back wall of the crust (the custard sits a little lower)
for x = CX - 10, CX + 10 do local y0
  for y = CY - 6, CY + 2 do if cus:has(x, y) then y0 = y break end end
  if y0 then c:put(x, y0, PA[2], rtok) end
end

-- custard: domed, glossy, leopard spots
local ctok = { r = { name = "custard" } }
local cm = HP.mask()
cus:each(function(x, y) if cus:has(x, y - 1) then cm:set(x, y) end end)
local cn = A.ellN(cm, CX - 1, CY, RX - 4, RY - 1.5, 0.7)
local cidx = A.shade(c, cm, cn, CU, { tok = ctok, amb = 0.15, wrap = 0.3 })
-- ambient ring where custard meets crust (front edge)
cm:edge():each(function(x, y) if y >= CY then A.step(c, cidx, CU, x, y, -1, ctok) end end)
-- caramelised blisters: irregular blotches, darkest in the core
local spots = { { 37, 29, 2.6 }, { 41, 32, 2.0 }, { 30, 33, 1.8 }, { 34, 34, 1.2 }, { 25, 31, 1.3 }, { 38, 34, 1.1 }, { 31, 28, 1.0 }, { 44, 30, 1.2 } }
for si, s in ipairs(spots) do
  for y = floor(s[2] - 3), floor(s[2] + 3) do for x = floor(s[1] - 4), floor(s[1] + 4) do
    if cm:has(x, y) then
      local d = sqrt(((x - s[1]) / 1.3) ^ 2 + (y - s[2]) ^ 2) + (X.hash(x, y, si) - 0.5) * 0.9
      if d < s[3] * 0.45 then c:put(x, y, BURN[1], ctok)
      elseif d < s[3] * 0.8 then c:put(x, y, BURN[2], ctok)
      elseif d < s[3] then c:put(x, y, BURN[3], ctok)
      elseif d < s[3] + 0.6 then A.step(c, cidx, CU, x, y, -1, ctok) end
    end
  end end
end
-- specular on the glossy custard (upper-left)
c:put(26, 29, CU[6], ctok) c:put(27, 29, A.CREAM, ctok) c:put(25, 30, CU[6], ctok)

-- quirk: steam curl
local stok = { r = { name = "steam" } }
local sp = { { 31, 25 }, { 26, 21 }, { 33, 17 }, { 30, 12 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return t < 0.06 and -1 or (0.95 - 0.25 * t) end)
sm:each(function(x, y) local k = K(x, y)
  c:put(x, y, SS[k] < -0.1 and STEAM[3] or (SS[k] < 0.4 and STEAM[2] or STEAM[1]), stok) end)
-- curl hook at the top
for _, p in ipairs{ {31, 11, 2}, {32, 11, 2}, {33, 12, 1}, {33, 13, 1} } do c:put(p[1], p[2], STEAM[p[3]], stok) end

A.save(c, NAME)
