-- ico-undo (final, Opus). Bold U-turn arrow: a rounded tail at the lower left runs right, swings up round a
-- half-loop on the right and returns left along the top into a broad arrowhead pointing left.
-- Material: glossy blue enamel tube; per-pixel pillow light (6-tone), an inner-edge AO row where the loop turns,
-- a long specular streak riding the top band, a cool reflected-light edge underneath and a bevelled arrowhead
-- (lit upper facet, shaded lower facet split by a ridge). Shadow where the head overlaps the band.
-- quirk: three little speed dashes puff out behind the tail, as if it is hurrying back.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_5.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = R.new("ico-undo")
local BLUE = { "#1e2a5a", "#2a4a8a", "#3a6ec0", "#5296e0", "#86c0f2", "#cfeaff" }
local BOUNCE = "#7a8ad8"
local DASH = { "#8bc4ea", "#b9e2f5" }
local bt = { r = { name = "enamel" } }

-- path: top band y 20..27 (centre 23.5) from x 22 to 38, loop centre (38, 34) radius 10.5 (mid), bottom band
-- y 41..48 (centre 44.5) from x 38 back to x 18 with a rounded end
local LX, LY, LR, HW = 38, 34, 10.5, 3.6
local band = HP.mask()
local n, S = {}, {}
for y = 12, 56 do for x = 4, 60 do
  local s, ok, nx, ny
  if x <= LX then
    -- straight runs
    local dt, db = y + .5 - (LY - LR), y + .5 - (LY + LR)
    if x >= 22 and abs(dt) <= HW then ok, s, nx, ny = true, dt / (HW + .5), 0, 1 end
    if x >= 18 and abs(db) <= HW then ok, s, nx, ny = true, db / (HW + .5), 0, 1 end
  else
    local dx, dy = x + .5 - LX, y + .5 - LY
    local r = sqrt(dx * dx + dy * dy)
    local d = r - LR
    if abs(d) <= HW then ok, s, nx, ny = true, d / (HW + .5), dx / r, dy / r end
  end
  if ok then
    band:set(x, y)
    local sn = max(-.96, min(.96, s))
    n[K(x, y)] = { R.norm(nx * sn, ny * sn, sqrt(1 - sn * sn)) } S[K(x, y)] = s
  end
end end
-- round tail end (half disc on the left of the bottom run)
local cap = c:ellipse(18.5, LY + LR, HW, HW):clip(HP.rect(0, 0, 18, 63))
cap:each(function(x, y) local dx, dy = (x + .5 - 18.5) / (HW + .5), (y + .5 - (LY + LR)) / (HW + .5)
  band:set(x, y) n[K(x, y)] = { R.norm(dx, dy, sqrt(max(.05, 1 - dx * dx - dy * dy))) } S[K(x, y)] = dy end)
local bias = {}
-- AO on the inner side of the loop (pixels facing the hole)
band:each(function(x, y) local k = K(x, y)
  if x > LX and S[k] < -0.55 then bias[k] = -1 end
  if x <= LX and y < LY and S[k] > 0.6 then bias[k] = -1 end
  if x <= LX and y > LY and S[k] < -0.6 then bias[k] = -1 end
end)
local idx = R.shade(c, band, n, BLUE, { amb = 0.08, wrap = 0.25, tok = bt, bias = bias })
-- cool reflected light along the outer underside of the loop and bottom run
local rim = X.rim(n)
band:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and S[k] > 0.7 then c:put(x, y, BOUNCE, bt) end end)

---------------------------------------------------------------- arrowhead (pointing left) at the top-left
local hx, hy = 8, LY - LR      -- tip
local head = c:poly{ { hx - 1, hy + .5 }, { 25.5, hy - 10.5 }, { 25.5, hy + 11.5 } }
local hn = {}
head:each(function(x, y) local up = (y + .5) < hy + .5
  hn[K(x, y)] = up and { R.norm(-0.2, -0.3, 0.9) } or { R.norm(0.05, 0.5, 0.8) } end)
-- bevel: edges of the head lean outward
local hd = X.dist(head)
head:each(function(x, y) local k = K(x, y) if hd[k] < 1.2 then local a = hn[k] hn[k] = { R.norm(a[1] * 1.8 - 0.3, a[2] * 1.5, a[3] * 0.6) } end end)
local hidx = R.shade(c, head, hn, BLUE, { amb = 0.1, wrap = 0.25, tok = bt })
-- ridge along the centre line (lit)
for x = hx + 1, 24 do c:put(x, floor(hy + .5), BLUE[5], bt) end
-- back edge of the head: dark seam where it meets the band + shadow it casts onto the band
for y = floor(hy - 11), floor(hy + 11) do if head:has(25, y) then c:put(25, y, BLUE[2], bt) end end
band:each(function(x, y) if x >= 26 and x <= 27 and y >= hy - 4 and y <= hy + 4 then R.step(c, idx, BLUE, x, y, -1, bt) end end)

---------------------------------------------------------------- specular streak along the top run + loop top
for x = 26, 39 do local y = floor(LY - LR - 1.7) if band:has(x, y) then c:put(x, y, (x > 28 and x < 33) and BLUE[6] or BLUE[5], bt) end end
for _, a in ipairs{ -80, -68, -56 } do local r = LR - 1.0
  local x, y = floor(LX + cos(a * pi / 180) * (LR + 0.2) - 1.2 + .5), floor(LY + sin(a * pi / 180) * (LR + 0.2) - 1.2 + .5)
  if band:has(x, y) then c:put(x, y, BLUE[5], bt) end end
c:put(30, floor(LY - LR - 2.6), R.CREAM, bt)

---------------------------------------------------------------- quirk: speed dashes behind the tail
for _, d in ipairs{ { 7, 41, 4 }, { 5, 44, 6 }, { 8, 47, 3 } } do
  for i = 0, d[3] - 1 do c:put(d[1] + i, d[2], i == d[3] - 1 and DASH[2] or DASH[1], bt) end
end
R.save(c, "ico-undo")
