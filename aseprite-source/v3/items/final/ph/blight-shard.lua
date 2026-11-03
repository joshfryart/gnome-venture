-- blight-shard (final, Opus single pass). A slim faceted shard of blight crystal, snapped off at a jagged base, with a
-- smaller splinter growing from its foot. Three-facet prism with a pyramid tip (flat facet light, bright bevel on the lit
-- facet edges, a broken specular streak), sickly green blight veins glowing in cracks across the facets, AO where the two
-- crystals meet.
-- quirk: a tiny blight toadstool has sprouted from the crack at the foot.
local NAME = "blight-shard"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local VIO = { "#1c1230", "#301e4c", "#4a2c6e", "#684292", "#8c64b8", "#b896de" }
local EDGE, SPEC = "#ddc8f6", "#f4ecff"
local GR = { "#2c4a2e", "#4a8034", "#84c244", "#ccf274" }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end

-- prism shard from base (ax,ay) to apex (bx,by); w = half width, tip = t where the pyramid starts
local function shard(ax, ay, bx, by, w, tip, seed)
  local vx, vy = bx - ax, by - ay
  local len = sqrt(vx * vx + vy * vy)
  local ux, uy = vx / len, vy / len
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, n, F, T, S = HP.mask(), {}, {}, {}, {}
  for y = floor(min(ay, by)) - 8, floor(max(ay, by)) + 8 do for x = floor(min(ax, bx)) - 8, floor(max(ax, bx)) + 8 do
    local rx, ry = x - ax, y - ay
    local t = (rx * ux + ry * uy) / len
    local s = rx * px + ry * py
    local ww = w * (t < tip and (1 + 0.08 * t) or (1 - (t - tip) / (1 - tip)))
    local jag = 0.03 + X.hash(floor(s), 1, seed) * 0.07
    if t >= jag and t <= 1 and abs(s) <= ww then
      m:set(x, y)
      local sn = s / max(ww, 0.6)
      local f, ax_ = 2, 0
      if sn < -0.38 then f, ax_ = 1, -0.8 elseif sn > 0.36 then f, ax_ = 3, 0.8 end
      local al = t > tip and 0.55 or 0
      local k = K(x, y)
      n[k] = { norm(px * ax_ + ux * al, py * ax_ + uy * al, 1) }
      F[k] = f + (t > tip and 3 or 0)
      T[k], S[k] = t, sn
    end
  end end
  return m, n, F, T, S, ux, uy, px, py, len
end

local mm, mn, MF, MT, MS, mux, muy, mpx, mpy, mlen = shard(27, 56, 37, 9, 5.4, 0.74, 3)
local sm, sn, SF, ST, SS = shard(25, 55, 14, 33, 3.0, 0.62, 9)
sm:cut(mm)

local function paint(m, n, F, T, S, tok, bias)
  local v = X.light(n, { amb = 0.1, wrap = 0.1 })
  for k, val in pairs(v) do v[k] = val + (T[k] - 0.5) * 0.12 end
  local idx = X.tone(c, m, v, VIO, { cuts = { 0.12, 0.3, 0.48, 0.64, 0.8 }, bias = bias, tok = tok })
  -- facet edges: bright bevel where a lit facet meets a darker one, dark seam otherwise
  m:each(function(x, y) local k = K(x, y)
    local kr, kd = K(x + 1, y), K(x, y + 1)
    for _, kk in ipairs{ kr, kd } do
      if F[kk] and F[kk] ~= F[k] and not (bias and bias[k]) then
        local a, b = idx[k], idx[kk]
        if a >= b then c:put(x, y, EDGE, tok) else c:put(x, y, VIO[max(1, a - 1)], tok) end
      end
    end
  end)
  return idx
end
local sb = {}
X.ao(sb, sm, mm, 1, -1)
local stok = { r = { name = "splinter" } }
paint(sm, sn, SF, ST, SS, stok, sb)
local mtok = { r = { name = "shard" } }
local midx = paint(mm, mn, MF, MT, MS, mtok)
-- broken specular streak on the lit facet
for t = 0.2, 0.7, 0.012 do
  if not (t > 0.42 and t < 0.48) then
    local x = 27 + (37 - 27) * t + mpx * (-0.62 * 5.4) local y = 56 + (9 - 56) * t + mpy * (-0.62 * 5.4)
    local xi, yi = floor(x + .5), floor(y + .5)
    if mm:has(xi, yi) then c:put(xi, yi, (t > 0.3 and t < 0.38) and SPEC or VIO[6], mtok) end
  end
end
-- lower facets: a darker jagged break line near the base
mm:each(function(x, y) local k = K(x, y) if MT[k] < 0.12 and MT[k] > 0.08 and MS[k] > -0.3 then c:put(x, y, VIO[1], mtok) end end)

-- blight veins: jagged cracks with a glowing core
local gtok = { r = { name = "vein" } }
local function vein(pts, mask)
  local core = c:line(pts, 1):clip(mask)
  core:each(function(x, y) if mask:has(x + 1, y) and not core:has(x + 1, y) then c:put(x + 1, y, GR[2], gtok) end end)
  core:each(function(x, y) c:put(x, y, GR[3], gtok) end)
  return core
end
vein({ { 29, 50 }, { 31, 44 }, { 30, 39 }, { 33, 33 }, { 32, 28 }, { 35, 22 } }, mm)
vein({ { 31, 44 }, { 34, 41 } }, mm)
vein({ { 21, 47 }, { 19, 42 }, { 18, 38 } }, sm)
for _, p in ipairs{ { 31, 40 }, { 33, 32 }, { 30, 47 } } do if mm:has(p[1], p[2]) then c:put(p[1], p[2], GR[4], gtok) end end
c:sparkle(34, 15)

-- quirk: tiny blight toadstool from the foot crack
local ttok = { r = { name = "toad" } }
for y = 50, 52 do c:put(34, y, y == 52 and "#9a8c8a" or "#e6dcc8", ttok) c:put(35, y, "#b8aaa0", ttok) end
local cap = c:ellipse(34.5, 48.5, 2.6, 1.3):cut(c:rect(0, 50, 63, 63))
local cn = X.sphere(34.5, 49.5, 2.6, cap)
X.tone(c, cap, X.light(cn, { amb = 0.1, wrap = 0.3 }), GR, { cuts = { 0.3, 0.55, 0.8 }, tok = ttok })
c:put(33, 48, "#f0f8c8", ttok) c:put(36, 48, "#d8f0a0", ttok)

A.save(c, NAME)
