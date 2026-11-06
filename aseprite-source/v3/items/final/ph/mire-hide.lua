-- mire-hide (final, Opus single pass). A tanned swamp-beast pelt laid flat: irregular body with four leg lobes, a
-- neck lobe and a short tail; mossy olive skin lit per pixel from a height field (thin rolled edges, raised rows of
-- scutes down the back with lit tops and dark undersides, darker mottled patches), lacing holes near the lobe tips.
-- The lower-right corner is folded back to show the pale suede flesh side, with a cast shadow on the hide.
-- quirk: a small marsh snail is still riding on the upper-left leg.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("mire-hide")
local SKIN = { "#1c271e", "#2c3d24", "#435a2c", "#627436", "#88964a", "#b4b868" }
local SUEDE = { "#5a3424", "#7e4c30", "#a26a40", "#c48c56", "#deb07a", "#f2d4a2" }
local SPEC = "#f4f0c0"

-- silhouette
local H = A.ell(32, 33, 11.5, 15)
H:add(A.rell(32, 16, 0, 1, 4.6, 4.2))                         -- neck lobe
for _, L in ipairs{ { 20, 21, -0.8, -0.6, 7, 3.6 }, { 44, 22, 0.8, -0.55, 7, 3.4 },
                    { 19, 45, -0.75, 0.66, 7.2, 3.6 }, { 45, 44, 0.78, 0.62, 7, 3.6 } } do
  H:add(A.rell(L[1], L[2], L[3], L[4], L[5], L[6]))
end
H:add(A.rell(33, 51, 0.2, 1, 5.5, 2.2))                        -- tail
H:add(A.rell(34, 55, 0.35, 1, 2.8, 1.3))
-- ragged edge: nibble a few edge pixels
H:edge():each(function(x, y) if X.hash(x, y, 11) < 0.12 then H:cut(c:rect(x, y, x, y)) end end)

-- fold the lower-right corner over a line
local P1x, P1y, P2x, P2y = 38, 53, 52, 38
local fx, fy = P2x - P1x, P2y - P1y local fl = sqrt(fx*fx + fy*fy) fx, fy = fx / fl, fy / fl
local nx, ny = fy, -fx if nx + ny < 0 then nx, ny = -nx, -ny end -- outward (to the corner)
local function sd(x, y) return (x - P1x) * nx + (y - P1y) * ny end
local flap = HP.mask()
local x0, y0, x1, y1 = 0, 0, 63, 63
for y = y0, y1 do for x = x0, x1 do
  local d = sd(x, y)
  if d < 0 then
    local rx, ry = floor(x - 2 * d * nx + .5), floor(y - 2 * d * ny + .5)
    if H:has(rx, ry) then flap:set(x, y) end
  end
end end
local cut = HP.mask() H:each(function(x, y) if sd(x, y) > 0 then cut:set(x, y) end end)
H:cut(cut)

-- height field: thin rolled edge + scute bumps along the back
local dist = X.dist(H)
local h = {}
local scutes = {}
for row = 0, 6 do
  local yy = 21 + row * 4.2
  for _, off in ipairs{ -6, -2, 2, 6 } do
    local xx = 32 + off + ((row % 2 == 0) and 1 or -1)
    if abs(off) < 6 or (row > 0 and row < 6) then scutes[#scutes + 1] = { xx, yy } end
  end
end
H:each(function(x, y) local k = K(x, y)
  local d = dist[k] or 1
  local e = min(d, 3) / 3
  local hh = e * 1.2 + X.hash(x // 2, y // 2, 5) * 0.25
  for _, s in ipairs(scutes) do
    local a, b = (x - s[1]) / 1.9, (y - s[2]) / 1.5
    local q = a*a + b*b
    if q < 1 then hh = hh + (1 - q) * 1.6 end
  end
  h[k] = hh
end)
local n = A.hnorm(H, h, 1.1)
-- mottling + cast shadow from the flap
local bias = {}
H:each(function(x, y) local k = K(x, y)
  local mo = sin(x * 0.45 + y * 0.2) + cos(y * 0.5 - x * 0.15) + X.hash(x // 3, y // 3, 2)
  if mo > 1.35 then bias[k] = -1 end
end)
flap:shift(1, 1):each(function(x, y) if H:has(x, y) and not flap:has(x, y) then bias[K(x, y)] = (bias[K(x, y)] or 0) - 2 end end)
flap:shift(2, 2):each(function(x, y) if H:has(x, y) and not flap:has(x, y) then local k = K(x, y) bias[k] = min(bias[k] or 0, -1) end end)
local htok = { r = { name = "hide" } }
local idx = A.shade(c, H, n, SKIN, { tok = htok, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.4, 0.56, 0.7, 0.84 } })
-- scute crest glints + grain pores
for i, s in ipairs(scutes) do
  local x, y = floor(s[1] - 0.6), floor(s[2] - 0.8)
  if H:has(x, y) and not flap:has(x, y) and i % 2 == 1 then c:put(x, y, SKIN[6], htok) end
end
H:each(function(x, y) local k = K(x, y)
  if (dist[k] or 0) > 3 and X.hash(x, y, 9) < 0.06 then c:put(x, y, SKIN[max(1, (idx[k] or 3) - 1)], htok) end end)
-- rolled edge: darker rim on the shade side
H:edge():each(function(x, y) local k = K(x, y) local nn = n[k]
  if nn and nn[1] + nn[2] > 0.25 then c:put(x, y, SKIN[max(1, (idx[k] or 2) - 1)], htok) end end)
-- lacing holes near lobe tips
for _, hp in ipairs{ { 16, 18 }, { 48, 19 }, { 15, 48 }, { 32, 13 } } do
  if H:has(hp[1], hp[2]) then c:put(hp[1], hp[2], SKIN[1], htok) c:put(hp[1] + 1, hp[2], SKIN[2], htok) c:put(hp[1], hp[2] - 1, SKIN[3], htok) end
end

-- flap: suede flesh side, lit as a gently curled sheet
local fdist = X.dist(flap)
local fh = {}
flap:each(function(x, y) local k = K(x, y)
  fh[k] = min(fdist[k] or 1, 2.5) / 2.5 * 1.1 + (-sd(x, y)) * 0.08 + X.hash(x, y, 4) * 0.12 end)
local fn = A.hnorm(flap, fh, 1.0)
local fb = {}
flap:each(function(x, y) if sd(x, y) > -1.6 then fb[K(x, y)] = 1 end end) -- crease catches light
local stok = { r = { name = "suede" } }
local fidx = A.shade(c, flap, fn, SUEDE, { tok = stok, bias = fb, amb = 0.14, wrap = 0.35 })
-- suede nap: short diagonal strokes
flap:each(function(x, y) local k = K(x, y)
  if (x + y) % 4 == 0 and X.hash(x, y, 6) < 0.45 and sd(x, y) < -1.6 then c:put(x, y, SUEDE[max(1, (fidx[k] or 3) - 1)], stok) end end)
-- crease line
flap:each(function(x, y) local d = sd(x, y) if d > -0.6 then c:put(x, y, SUEDE[6], stok) end end)

-- glossy wet spec on a scute
c:put(29, 25, SPEC, htok)

-- quirk: marsh snail on the upper-left leg
A.map(c, {
  "..SSS...",
  ".SsoSs..",
  ".SoSos.a",
  ".SsssS.a",
  "bbbbbbbb",
  ".dddddd.",
}, 15, 17, { S = "#7a3e2a", s = "#c97e44", o = "#f0b870", b = "#d8c8a6", d = "#9a8a72", a = "#6a5a4a" }, { r = { name = "snail" } })

A.save(c, "mire-hide")
