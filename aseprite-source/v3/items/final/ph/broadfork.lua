-- broadfork (Opus single pass, aB10_4). Front view, symmetric and slim: a bevelled steel toolbar with five long
-- pointed tines (air between them), two thin ash handles splaying up and out from tapered steel sockets.
-- Material: steel 6-tone per-pixel cylinders with a bright lit edge, a specular streak and a dark bolt eye on each
-- socket; wood with grain streaks, one knot and pale end grain on the handle tops; AO rows where tines leave the bar
-- and where the handles enter the sockets.
-- quirk: a twist of garden twine lashed round the left handle, its frayed end dangling.
local NAME = "broadfork"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local STEEL = { "#2a2c46", "#454866", "#6f7290", "#a3a6bc", "#d2d4e2", "#f4f4fa" }
local WOOD  = { "#3e2420", "#5e3826", "#864c33", "#b47848", "#d6a066", "#f0c890" }
local ENDG  = { "#c08a58", "#f4d8a6" }
local TWINE = { "#6a4420", "#a87232", "#d8a64e", "#f4d488" }
local CUTS = { 0.2, 0.38, 0.55, 0.71, 0.86 }

local stok = { r = { name = "steel" } }
local wtok = { r = { name = "wood" } }

-- handles (wood), drawn first; sockets and bar over them
local H = { { 19, 35, 13, 8 }, { 45, 35, 51, 8 } }
local hm = {}
for i, h in ipairs(H) do
  local m, n, T, S = X.cyl(h[1], h[2], h[3], h[4], function(t) return 1.45 end)
  local len = sqrt((h[3] - h[1]) ^ 2 + (h[4] - h[2]) ^ 2)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    -- grain: broken dark streaks on the shade half, a light streak on the lit half
    local seg = floor(t * len / 4.5)
    local hsh = X.hash(seg, i, 7)
    if s > 0.1 and s < 0.6 and hsh > 0.42 then bias[k] = -1 end
    if s < -0.25 and s > -0.6 and X.hash(seg, i, 3) > 0.55 then bias[k] = 1 end
    if t < 0.36 and t > 0.28 then bias[k] = (bias[k] or 0) - 1 end   -- AO where it enters the socket
  end)
  G.toneN(c, m, n, WOOD, { bias = bias, tok = wtok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
  -- pale end grain on top with a ring
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.955 then c:put(x, y, abs(S[k]) < 0.3 and ENDG[1] or ENDG[2], wtok) end end)
  hm[i] = { m = m, T = T, S = S, len = len }
end
-- knot on the right handle
do local h = H[2] local x, y = floor(h[1] + (h[3] - h[1]) * 0.62 + 0.5), floor(h[2] + (h[4] - h[2]) * 0.62 + 0.5)
  c:put(x, y, WOOD[1], wtok) c:put(x, y - 1, WOOD[5], wtok) end

-- sockets: tapered steel sleeves
for i, h in ipairs(H) do
  local bx, by = h[1] + (h[3] - h[1]) * 0.3, h[2] + (h[4] - h[2]) * 0.3
  local m, n, T, S = X.cyl(h[1], h[2] + 1, bx, by, function(t) return 2.3 - 0.5 * t end)
  local idx = G.toneN(c, m, n, STEEL, { tok = stok, cuts = CUTS, amb = 0.1, wrap = 0.25 })
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.93 then c:put(x, y, STEEL[2], stok) end                 -- lip shadow
    if S[k] < -0.35 and S[k] > -0.7 and T[k] > 0.2 and T[k] < 0.8 then c:put(x, y, STEEL[6], stok) end  -- bright edge
  end)
  -- bolt eye
  local ex, ey = floor(h[1] + (bx - h[1]) * 0.55 + 0.5), floor(h[2] + (by - h[2]) * 0.55 + 0.5)
  c:put(ex, ey, STEEL[1], stok) c:put(ex - 1, ey - 1, STEEL[5], stok)
end

-- tines: tapered steel spikes
local tines = HP.mask()
for i, tx in ipairs{ 18, 25, 32, 39, 46 } do
  local m, n, T, S = X.cyl(tx, 36, tx + (tx - 32) * 0.03, 56, function(t) return 1.55 * (1 - t) ^ 0.75 + 0.2 end)
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if y <= 38 then bias[k] = -1 end end)
  G.toneN(c, m, n, STEEL, { bias = bias, tok = { r = { name = "tine" .. i } }, cuts = CUTS, amb = 0.1, wrap = 0.25 })
  -- specular streak down the lit flank
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.3 and S[k] > -0.75 and T[k] > 0.12 and T[k] < 0.55 then c:put(x, y, STEEL[5], stok) end end)
  tines:add(m)
end

-- toolbar: bevelled rectangle with a lit top edge, specular and a dark underside row
local bar = c:rrect(14, 33, 50, 37, 1)
local bn = X.pillow(bar, 1.6)
local bv = X.light(bn, { amb = 0.12, wrap = 0.25 })
X.tone(c, bar, bv, STEEL, { cuts = CUTS, tok = stok })
for x = 16, 48 do c:put(x, 34, STEEL[5], stok) end
for x = 15, 49 do c:put(x, 37, STEEL[2], stok) end
c:put(19, 34, "#fffaf0", stok) c:put(20, 34, STEEL[6], stok)      -- specular
-- weld fillets where the tines meet the bar
for _, tx in ipairs{ 18, 25, 32, 39, 46 } do c:put(tx + 1, 37, STEEL[1], stok) end

-- quirk: twine lashing round the left handle + frayed loose end
do
  local h = hm[1]
  local tw = HP.mask()
  h.m:each(function(x, y) local k = K(x, y)
    if h.T[k] > 0.47 and h.T[k] < 0.62 then tw:set(x, y) tw:set(x - 1, y) tw:set(x + 1, y) end end)
  local ttok = { r = { name = "twine" } }
  local x0, y0, x1, y1 = tw:bbox()
  tw:each(function(x, y)
    local ph = (y * 2 + x) % 4
    local i = (ph == 0) and 1 or (ph == 1 and 2 or 3)
    if x == x0 or (not tw:has(x - 1, y)) then i = min(4, i + 1) end      -- lit left side
    if not tw:has(x + 1, y) then i = max(1, i - 1) end                 -- shade right side
    c:put(x, y, TWINE[i], ttok)
  end)
  -- loose end
  local rx, ry = 0, 0
  tw:each(function(x, y) if y == y1 and x > rx then rx, ry = x, y end end)
  local pts = { { 1, 1 }, { 1, 2 }, { 2, 3 }, { 2, 4 }, { 3, 5 }, { 2, 6 } }
  for j, p in ipairs(pts) do c:put(rx + p[1], ry + p[2], TWINE[(j % 2 == 0) and 2 or 3], ttok) end
  c:put(rx + 4, ry + 6, TWINE[4], ttok)  -- fray
end

G.save2(c, NAME)
