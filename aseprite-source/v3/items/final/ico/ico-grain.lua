-- ico-grain (final, Opus). A small sheaf: three wheat stalks crossed and tied at the waist with twine, splaying
-- below to cut ends and above to three plump ears (centre upright, two leaning out), each ear a double row of
-- glossy kernels with a few fine awns at the tip.
-- Material: kernels lit per pixel as little ovals (6-tone gold) with a dark crease and AO where they overlap,
-- one specular per ear; hollow straw with a lit edge and pale end grain + dark hollow at each cut end; twine with
-- a twist pattern, a knot and two loose ends; AO on the straw above and below the band.
-- quirk: one kernel has dropped out and tumbles away to the lower right.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA5_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, cos, sin = math.floor, math.abs, math.max, math.min, math.sqrt, math.cos, math.sin
local c = A.new("ico-grain")
local GR = { "#6a3418", "#a65e1c", "#d98322", "#f0aa34", "#ffd060", "#fff0a8" }
local ST = { "#5a3a1e", "#86622a", "#b08a3a", "#d4ae52", "#ecd082", "#fbe8b0" }
local TW = { "#4a2430", "#7a3a34", "#a8563a", "#d07c4c", "#eca472" }
local ktok, stok, ttok = { r = { name = "kernel" } }, { r = { name = "straw" } }, { r = { name = "twine" } }

local TIE = { 32, 40 }
-- stalks: base of ear -> through tie -> cut end
local stalks = {
  { ear = { 23, 26 }, tip = { 15.5, 13 }, cut = { 36.5, 51 } },
  { ear = { 41, 26 }, tip = { 48.5, 13 }, cut = { 27.5, 51 } },
  { ear = { 32, 25 }, tip = { 32, 10 }, cut = { 32, 52 } },
}
local strawM = HP.mask()
local sidx = {}
for _, s in ipairs(stalks) do
  local m, n = X.cyl(s.ear[1], s.ear[2], s.cut[1], s.cut[2], function(t) return 1.45 - 0.2 * t end)
  local idx = A.shade(c, m, n, ST, { tok = stok, amb = 0.1, wrap = 0.35, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  -- node (joint) on the straw: one dark ring row
  local nt = 0.32
  local nx, ny = s.ear[1] + (s.cut[1] - s.ear[1]) * nt, s.ear[2] + (s.cut[2] - s.ear[2]) * nt
  for dx = -2, 2 do local x, y = floor(nx + dx + .5), floor(ny + .5) if m:has(x, y) then A.step(c, idx, ST, x, y, -2, stok) if m:has(x, y - 1) then A.step(c, idx, ST, x, y - 1, 1, stok) end end end
  for k, v in pairs(idx) do sidx[k] = v end
  strawM:add(m)
  s.m = m
end
-- cut ends: pale end grain with a dark hollow
for _, s in ipairs(stalks) do
  local x, y = floor(s.cut[1] + .5), floor(s.cut[2] + .5)
  A.map(c, { "lhl", "hdh" }, x - 1, y - 1, { h = ST[6], l = ST[5], d = ST[1] }, stok)
end

-- ears: double row of kernels along base->tip, painted tip first so lower kernels sit in front
local earM = HP.mask()
local function ear(s)
  local bx, by, tx, ty = s.ear[1], s.ear[2], s.tip[1], s.tip[2]
  local vx, vy = tx - bx, ty - by
  local L = sqrt(vx * vx + vy * vy)
  local ux, uy = vx / L, vy / L
  local px, py = -uy, ux
  local ang = math.atan(uy, ux)
  local placed = HP.mask()
  local kern = {}
  local N = 5
  for i = N, 1, -1 do
    local t = (i - 0.6) / N
    for side = -1, 1, 2 do
      local w = 1.7 * (1 - 0.3 * t)
      local cx, cy = bx + ux * (t * L + side * 0.8) + px * side * w, by + uy * (t * L + side * 0.8) + py * side * w
      local km, kn = A.oval(cx, cy, 2.2 - 0.4 * t, 1.45 - 0.15 * t, ang + side * 0.38)
      kern[#kern + 1] = { m = km, n = kn, cx = cx, cy = cy, side = side }
    end
  end
  -- terminal kernel
  local km, kn = A.oval(tx - ux * 0.5, ty - uy * 0.5, 1.7, 1.3, ang)
  table.insert(kern, 1, { m = km, n = kn, cx = tx, cy = ty, side = 0 })
  local bestSpec
  for _, kk in ipairs(kern) do
    local bias = {}
    local idx = A.shade(c, kk.m, kk.n, GR, { tok = ktok, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.85 } })
    -- AO where this kernel overlaps the ones above it
    kk.m:each(function(x, y)
      for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
        if placed:has(x + d[1], y + d[2]) and not kk.m:has(x + d[1], y + d[2]) and (d[1] + d[2]) < 0 then
          c:put(x + d[1], y + d[2], (abs(ux) > 0.2) and GR[2] or GR[1], ktok)
        end
      end
    end)
    -- crease: one dark pixel on the inner (axis) side
    local ix, iy = floor(kk.cx - px * kk.side * 1.0 + .5), floor(kk.cy - py * kk.side * 1.0 + .5)
    if kk.side ~= 0 and kk.m:has(ix, iy) then c:put(ix, iy, GR[2], ktok) end
    placed:add(kk.m)
  end
  -- awns: a few fine whiskers off the upper kernels
  for _, a in ipairs{ { 0.0, -1, 0.9 }, { 0.0, 1, 0.9 }, { 0.0, 0, 1 } } do
    local sx, sy = tx, ty
    local dx, dy = A.rot(ux, uy, a[2] * 0.6)
    for j = 1, (a[2] == 0 and 4 or 5) do
      local x, y = floor(sx + dx * (j + 1.2) + .5), floor(sy + dy * (j + 1.2) + .5)
      if not placed:has(x, y) then c:put(x, y, j < 3 and GR[3] or GR[4], ktok) end
    end
  end
  earM:add(placed)
  return placed
end
for _, s in ipairs(stalks) do s.e = ear(s) end
-- one specular glint per ear (upper-left kernel of the lower half)
c:put(19, 20, A.CREAM)
c:put(30, 19, A.CREAM)
c:put(43, 21, GR[6])

-- twine band at the tie: 3 rows, twisted, knot + two loose ends (left)
local band = HP.mask()
for y = 39, 41 do
  local x0, x1 = 27, 37
  for x = x0, x1 do if strawM:has(x, y) or strawM:has(x, y - 1) or strawM:has(x, y + 1) or (x >= 28 and x <= 36) then band:set(x, y) end end
end
-- AO on straw just above/below the band
band:shift(0, -1):add(band:shift(0, 1)):each(function(x, y) if strawM:has(x, y) and not band:has(x, y) then A.step(c, sidx, ST, x, y, -2, stok) end end)
band:each(function(x, y)
  local r = (x + y * 2) % 4
  local i = (r == 0) and 2 or ((r == 1) and 3 or 4)
  if y == 39 and i < 4 then i = i + 1 end
  if y == 41 then i = i - 1 end
  if x >= 36 then i = i - 1 end
  c:put(x, y, TW[max(1, min(5, i))], ttok)
end)
-- knot and loose ends
A.map(c, {
  ".hb.",
  "hbbd",
  ".dd.",
}, 24, 39, { h = TW[5], b = TW[4], d = TW[2] }, ttok)
A.map(c, {
  "b..",
  "bd.",
  ".b.",
  ".bd",
  "..d",
}, 24, 42, { b = TW[3], d = TW[2] }, ttok)
A.map(c, {
  "b.",
  "b.",
  "d.",
}, 27, 42, { b = TW[4], d = TW[2] }, ttok)

-- quirk: a loose kernel tumbling away
local lk, lkn = A.oval(45.5, 47.5, 2.3, 1.6, 0.9)
A.shade(c, lk, lkn, GR, { tok = ktok, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.85 } })
c:put(45, 46, GR[6]) c:put(46, 48, GR[2])

A.save(c, "ico-grain")
