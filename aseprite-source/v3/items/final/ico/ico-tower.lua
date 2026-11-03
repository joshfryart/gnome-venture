-- ico-tower (final, Opus). Slim round stone watchtower: battered drum, corbelled parapet with three merlons
-- (the far parapet wall shows dark through the crenels), a warm-lit arched window, an arched oak door.
-- Material: per-pixel vertical-cylinder light (6-tone stone), ashlar courses whose joints foreshorten round the
-- drum, chipped/pale stone speckles, cap stones lit on top, corbel brackets casting AO on the drum, voussoirs
-- round the door, oak planks with grain and iron studs, ground shadow. quirk: a bluebird is perched on a merlon.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min, asin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.asin, math.pi
local c = R.new("ico-tower")
local STONE = { "#2e2a44", "#47425e", "#66617c", "#8a869c", "#b0adbe", "#d8d6e0" }
local WOOD  = { "#45282a", "#6a3c2c", "#8f5634", "#b47444", "#d39a5e", "#eec48a" }
local GLOW  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local st, wt = { r = { name = "stone" } }, { r = { name = "wood" } }

c:groundShadow(32, 54, 15, 1.5)

-- drum (battered: 1 px wider each side every ~14 rows going down)
local CX = 31.5
local body = HP.mask()
local function half(y) return 10.5 + max(0, (y - 26)) / 14 end
for y = 23, 53 do local h = half(y) for x = floor(CX - h + .5), floor(CX + h - .5) do body:set(x, y) end end
-- corbel band + parapet (wider)
local PH = 13.5
local band = c:rect(floor(CX - PH + .5), 17, floor(CX + PH - .5), 22)
local merl = HP.mask()
for _, m in ipairs{ { -PH, -PH + 6 }, { -3, 3 }, { PH - 6, PH } } do
  merl:add(c:rect(floor(CX + m[1] + .5), 10, floor(CX + m[2] - .5), 16))
end
-- far parapet wall seen through the crenels (lower, dark)
local far = c:rect(floor(CX - PH + 1.5), 15, floor(CX + PH - 1.5), 16):cut(merl)

local function cylN(m, hfun)
  local n, Tt = {}, {}
  m:each(function(x, y)
    local h = hfun(y)
    local t = max(-.97, min(.97, (x + 0.5 - CX) / h))
    n[K(x, y)] = { R.norm(t * 0.95, 0, sqrt(1 - t * t)) }
    Tt[K(x, y)] = t
  end)
  return n, Tt
end

-- far wall: flat dark, lit a little on its right (inside face faces left-ish)
local fidx = R.shade(c, far, cylN(far, function() return PH end), STONE, { amb = 0, wrap = 0, cuts = { 0.5, 2, 2, 2, 2 }, tok = st })

-- drum
local bn, BT = cylN(body, half)
local bb = {}
for x = 0, 63 do for y = 23, 25 do if body:has(x, y) then local k = K(x, y) bb[k] = (y == 23) and -2 or -1 end end end
local bidx = R.shade(c, body, bn, STONE, { amb = 0.06, wrap = 0.2, tok = st, bias = bb })

-- ashlar courses on the drum: horizontal joints every 4 rows, vertical joints at fixed angles (foreshortened)
local function joints(m, idx, Tt, y0, step, nb, phase0)
  m:each(function(x, y)
    local k = K(x, y)
    local row = floor((y - y0) / step)
    local ry = (y - y0) % step
    local th = asin(Tt[k]) / (pi / 2)                -- -1..1 round the drum
    local ph = ((th + 1) * nb + (row % 2) * 0.5 + (phase0 or 0)) % 1
    local th2 = asin(max(-.97, min(.97, Tt[k] + 1 / 11))) / (pi / 2)
    local ph2 = ((th2 + 1) * nb + (row % 2) * 0.5 + (phase0 or 0)) % 1
    if ry == step - 1 then R.step(c, idx, STONE, x, y, -2, st)
    elseif ph2 < ph then R.step(c, idx, STONE, x, y, -2, st)          -- joint crossing between x and x+1
    elseif ry == 0 and Tt[k] < 0.4 then R.step(c, idx, STONE, x, y, 1, st) end -- lit top arris of each stone
  end)
end
joints(body, bidx, BT, 26, 4, 2.6, 0)

-- stone speckles: chips (dark) and pale flecks
body:each(function(x, y) local h = X.hash(x, y, 7)
  if h > 0.965 then R.step(c, bidx, STONE, x, y, -1, st) elseif h < 0.03 then R.step(c, bidx, STONE, x, y, 1, st) end end)

-- corbel band
local cn, CT = cylN(band, function() return PH end)
local cb = {}
band:each(function(x, y) if y == 22 then cb[K(x, y)] = -2 elseif y == 17 then cb[K(x, y)] = 1 end end)
local cidx = R.shade(c, band, cn, STONE, { amb = 0.08, wrap = 0.22, tok = st, bias = cb })
-- corbel brackets: dark notches on the lower edge of the band, every ~5 px
band:each(function(x, y) local k = K(x, y)
  local th = asin(CT[k]) / (pi / 2)
  local ph = ((th + 1) * 3.2) % 1
  if y >= 21 and ph < 0.32 then R.step(c, cidx, STONE, x, y, -2, st) end
  if y == 19 then R.step(c, cidx, STONE, x, y, -1, st) end            -- string course joint
end)
-- AO on the drum just below the band
body:each(function(x, y) if y == 23 then
  local k = K(x, y) local th = asin(BT[k]) / (pi / 2) if (((th + 1) * 3.2) % 1) < 0.4 then R.step(c, bidx, STONE, x, y, -1, st) end end end)

-- merlons with lit cap stones
local mn = cylN(merl, function() return PH end)
local mb = {}
merl:each(function(x, y) if y == 10 then mb[K(x, y)] = 2 elseif y == 11 then mb[K(x, y)] = 1 elseif y == 12 then mb[K(x, y)] = -1 end end)
local midx = R.shade(c, merl, mn, STONE, { amb = 0.08, wrap = 0.22, tok = st, bias = mb })
-- dark inner separation where merlons meet the dark far wall
R.sepLine(c, merl, far, STONE[2], st)
-- AO on the band where the crenel floor meets it
band:each(function(x, y) if y == 17 and far:has(x, y - 1) then R.step(c, cidx, STONE, x, y, -2, st) end end)

-- door: arched oak door with voussoirs round it
local dx0, dx1, dy0, dy1 = 28, 35, 42, 53
local door = c:rect(dx0, dy0 + 3, dx1, dy1):add(c:ellipse(31.5, dy0 + 3, 3.5, 3.4)):clip(c:rect(dx0, dy0 - 1, dx1, dy1))
local arch = door:grow(1):cut(door):clip(c:rect(0, 0, 63, dy1))
arch:each(function(x, y) local k = K(x, y) local i = (bidx[k] or 4)
  local seg = floor(math.atan(y - (dy0 + 3), x - 31.5) * 2.2) % 2
  c:put(x, y, STONE[min(6, max(2, i + (seg == 0 and 1 or 0)))], st) end)
local dn = R.vcylN(door, dx0, dx1)
local db = {}
door:each(function(x, y) if y <= dy0 + 1 then db[K(x, y)] = -1 end end)
local didx = R.shade(c, door, dn, WOOD, { amb = 0.1, wrap = 0.3, tok = wt, bias = db })
door:each(function(x, y) if x == 30 or x == 33 then R.step(c, didx, WOOD, x, y, -2, wt)            -- plank joints
  elseif X.hash(x, y, 11) > 0.8 and y > dy0 + 2 then R.step(c, didx, WOOD, x, y, -1, wt) end end)  -- grain flecks
for _, s in ipairs{ { 29, 46 }, { 34, 46 }, { 29, 50 }, { 34, 50 } } do c:put(s[1], s[2], STONE[1], wt) c:put(s[1] - 1, s[2] - 1, STONE[5], wt) end
c:put(32, 48, "#f5b82e", wt) c:put(31, 48, "#8f4a1f", wt)     -- brass ring pull
-- doorstep
local step = c:rect(dx0 - 1, dy1, dx1 + 1, dy1)
step:each(function(x, y) c:put(x, y, x < 32 and STONE[5] or STONE[4], st) end)

-- arched window with warm lamplight
local wx0, wx1, wy0, wy1 = 30, 33, 28, 35
local win = c:rect(wx0, wy0 + 1, wx1, wy1):add(c:rect(wx0 + 1, wy0, wx1 - 1, wy0))
win:grow(1):cut(win):each(function(x, y) c:put(x, y, y > wy1 and STONE[5] or STONE[2], st) end)   -- deep reveal, lit sill
win:each(function(x, y)
  local col = GLOW[3]
  if x == wx0 or y == wy0 + 1 and x == wx0 + 1 then col = GLOW[2] end
  if y <= wy0 + 1 and x == wx0 then col = GLOW[1] end
  if x == wx0 + 2 and y >= wy0 + 3 and y <= wy0 + 5 then col = GLOW[4] end
  c:put(x, y, col, st)
end)
-- mullion cross
for y = wy0 + 1, wy1 do c:put(wx0 + 1, y, WOOD[2], st) end
c:put(wx0, wy0 + 4, WOOD[2], st) c:put(wx0 + 2, wy0 + 4, WOOD[2], st) c:put(wx0 + 3, wy0 + 4, WOOD[1], st)
-- sill pop and spec
c:put(wx0 - 1, wy1 + 1, STONE[6], st) c:put(wx0, wy1 + 1, STONE[6], st)
-- one cream glint on the left merlon cap
c:put(floor(CX - PH + 1.5), 10, R.CREAM, st)

-- quirk: a bluebird perched on the middle merlon (head right, tail left)
local BIRD = { K = R.INK, b = "#5fc4c8", h = "#b6f0e0", s = "#3a86b0", d = "#2a4a7a", o = "#f5b82e", c = R.CREAM, r = "#e8493b" }
R.map(c, {
  "....hbK.",
  "...hbcbo",
  "dsbbbbb.",
  ".dssrb..",
  "...K.K..",
}, floor(CX) - 3, 5, BIRD, { r = { name = "bird" } })

R.save(c, "ico-tower")
