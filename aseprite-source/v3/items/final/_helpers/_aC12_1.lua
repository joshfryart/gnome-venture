-- _aC12_1.lua: private helpers for holly-hedge-corner / -cross / -end / -gate (Opus single pass).
-- Read-only use of v3/lib (hp.lua, hpx.lua). 3/4 hedge = spiky plan (top face) extruded down into a
-- darker front face over a 2 px soil strip; per-pixel lumpy foliage light + stamped glossy holly leaves.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local A = { HP = HP, X = X, K = K }
A.INK = "#2b1c26"
A.CREAM = "#fff4d6"
A.GR = { "#0f2a2c", "#16413a", "#1e5a3e", "#2a7743", "#40964a", "#6fb757" }  -- holly, dark glossy
A.GSPEC = "#e2f5bc"
A.SOIL = { "#2a171c", "#432622", "#5e3828", "#7c4e30", "#9c6a3e", "#bf8e58" }
A.WOOD = { "#3e2422", "#5e3628", "#84502f", "#a86c3c", "#c98e52", "#e8b97a" }
A.BER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
A.STONE = { "#444663", "#5d5f7a", "#74758c", "#9696a8", "#bdbcca", "#e2e0e6" }
A.IRON = { "#262434", "#3a3c52", "#555a74", "#7a809a", "#a0a6bc", "#c8ccdc" }
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
local function h01(x, y, s) return X.hash(x + 300, y + 300, s or 0) end
A.h01 = h01

function A.new(name)
  A.name = name
  A.out = app.params.out or (DIR .. "/../")
  A.c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  return A.c
end
function A.union(...) local m = HP.mask() for _, q in ipairs{...} do m:add(q) end return m end

-- spikes: 1 px holly points pushed out of the edge. dirs: list of {dx,dy} allowed; skip(x,y) -> true to skip
function A.spikes(m, dirs, seed, rate, skip)
  local add = {}
  m:edge():each(function(x, y)
    if skip and skip(x, y) then return end
    for _, d in ipairs(dirs) do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) and h01(x, y, seed) < (rate or 0.3) then add[#add+1] = { nx, ny } break end
    end
  end)
  for _, p in ipairs(add) do m:set(p[1], p[2]) end
  return m
end

-- lumpy foliage on mask m. o.mode "top" (faces viewer/up) or "front" (vertical face, tilted down),
-- o.R pillow radius, o.bias {k=int}, o.seed, o.step leaf spacing, o.amb, o.wrap, o.ramp
-- returns final index map (k -> 1..6)
function A.foliage(m, o)
  o = o or {}
  local c, R = A.c, o.R or 3
  local ramp = o.ramp or A.GR
  local seed = o.seed or 1
  local d = X.dist(m)
  -- bump blobs on a jittered grid
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y) x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end)
  local blobs = {}
  local sp = o.blob or 4
  for gy = y0 - 2, y1 + 2, sp do for gx = x0 - 2, x1 + 2, sp do
    local jx, jy = (h01(gx, gy, seed) - .5) * sp * .9, (h01(gx, gy, seed + 7) - .5) * sp * .9
    blobs[#blobs+1] = { gx + jx, gy + jy, 2.4 + h01(gx, gy, seed + 3) * 1.2 }
  end end
  local hb = {}
  local function bump(x, y)
    local k = K(x, y)
    if hb[k] then return hb[k] end
    local best = 0
    for _, b in ipairs(blobs) do
      local q = b[3]*b[3] - (x - b[1])^2 - (y - b[2])^2
      if q > 0 then local v = sqrt(q) if v > best then best = v end end
    end
    hb[k] = best
    return best
  end
  local function hgt(x, y)
    local v = d[K(x, y)]
    if not v then return 0 end
    local t = min(v + 0.5, R) / R
    local hp = R * sqrt(1 - (1 - t) ^ 2)
    return hp * (o.mode == "front" and 0.5 or 1) + 0.85 * bump(x, y)
  end
  local n = {}
  m:each(function(x, y)
    local gx = (hgt(x + 1, y) - hgt(x - 1, y)) / 2
    local gy = (hgt(x, y + 1) - hgt(x, y - 1)) / 2
    if o.mode == "front" then n[K(x, y)] = { norm(-gx * .6, -gy * .6 + 0.95, 1) }
    else n[K(x, y)] = { norm(-gx * .7, -gy * .7, 1) } end
  end)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or (o.mode == "front" and 0.5 or 0.25) })
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local i = 1
    for j, t in ipairs(A.CUTS) do if v[k] >= t then i = j + 1 end end
    i = i + ((o.bias and o.bias[k]) or 0)
    idx[k] = max(1, min(6, i))
  end)
  -- stamped holly leaves (sorted top to bottom so lower leaves overlap)
  local L = {}
  for k, i in pairs(idx) do L[k] = i end
  local base = {}
  for k, i in pairs(idx) do base[k] = i end
  local leaves = {}
  local st = o.step or 4
  for gy = y0, y1 + 1, st do for gx = x0 - 1, x1 + 1, st do
    local lx = gx + floor((h01(gx, gy, seed + 11) - .5) * st * .9 + .5)
    local ly = gy + floor((h01(gx, gy, seed + 13) - .5) * st * .9 + .5)
    if m:has(lx, ly) then leaves[#leaves+1] = { lx, ly, h01(gx, gy, seed + 17) * pi, 2.4 + h01(gx, gy, seed + 19) * 1.0 } end
  end end
  table.sort(leaves, function(a, b) return a[2] < b[2] or (a[2] == b[2] and a[1] < b[1]) end)
  local glints = {}
  for li, lf in ipairs(leaves) do
    local cx, cy, ang, a = lf[1], lf[2], lf[3], lf[4]
    local b = 1.25
    local ux, uy = cos(ang), sin(ang)
    local px, py = -uy, ux
    local litSide = (px * -1 + py * -1) >= 0 and 1 or -1
    local lm, lt = {}, {}
    local R2 = math.ceil(a) + 2
    for y = cy - R2, cy + R2 do for x = cx - R2, cx + R2 do
      local dx, dy = x - cx, y - cy
      local u, w = dx*ux + dy*uy, dx*px + dy*py
      if (u / (a + .35))^2 + (w / (b + .35))^2 <= 1 and m:has(x, y) then
        local sl = w * litSide / (b + .35)
        local k = K(x, y)
        local i0 = base[k] or 3
        local ti
        if sl > 0.3 then ti = i0 + 1 elseif sl < -0.3 then ti = i0 - 1 else ti = (abs(u) < a - 0.6) and i0 - 1 or i0 end
        lm[k] = { x, y, ti, sl, u }
      end
    end end
    -- contact shadow below-right
    for k, p in pairs(lm) do
      local sk = K(p[1] + 1, p[2] + 1)
      if not lm[sk] and L[sk] then L[sk] = max(1, (base[sk] or 3) - 2) end
    end
    for k, p in pairs(lm) do L[k] = max(1, min(6, p[3])) end
    -- spikes along the margin, tips
    local pts = { { -0.55 * a, 1 }, { 0, -1 }, { 0.55 * a, 1 }, { -0.55 * a, -1 }, { 0.55 * a, -1 } }
    for si, q in ipairs(pts) do
      if h01(cx, cy, seed + si) < 0.7 then
        local sx = floor(cx + ux * q[1] + px * q[2] * (b + 1.2) + .5)
        local sy = floor(cy + uy * q[1] + py * q[2] * (b + 1.2) + .5)
        local sk = K(sx, sy)
        if L[sk] and not lm[sk] then L[sk] = max(1, min(6, (base[sk] or 3) + ((q[2] * litSide > 0) and 1 or -1))) end
      end
    end
    -- glossy glint on bright leaves
    if (base[K(cx, cy)] or 0) >= (o.glintMin or 5) then
      for k, p in pairs(lm) do
        if p[4] > 0.3 and abs(p[5]) < 0.8 and not glints[li] then glints[li] = { p[1], p[2] } end
      end
    end
  end
  local tok = { r = { name = o.name or "holly" } }
  for k, i in pairs(L) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    c:put(x, y, ramp[i], tok)
  end
  local ng = 0
  for _, g in pairs(glints) do
    if h01(g[1], g[2], seed + 23) < (o.glintRate or 0.6) then
      c:put(g[1], g[2], (ng % 3 == 0) and A.GSPEC or ramp[6], tok) ng = ng + 1
    end
  end
  return L, idx
end

-- 3/4 hedge. plan = top-face mask (spikes already added), H front height.
-- o.cutL / o.cutR x columns that are clean-cut (connector ends), o.cutB = {x0,x1,ySouth} south cut end
function A.hedge3q(plan, H, o)
  o = o or {}
  local c = A.c
  local front, soil = HP.mask(), HP.mask()
  plan:each(function(x, y)
    for z = 1, H do if not plan:has(x, y + z) then front:set(x, y + z) end end
    for z = H + 1, H + 2 do if not plan:has(x, y + z) then soil:set(x, y + z) end end
  end)
  soil:cut(front)
  -- ragged lower edge of the front: leaf tips hang 1 px into the soil strip
  soil:each(function(x, y) if front:has(x, y - 1) and h01(x, y, 41) < 0.22 and not soil:has(x, y - 1) then front:set(x, y) end end)
  soil:cut(front)
  -- soil strip
  local stok = { r = { name = "soil" } }
  soil:each(function(x, y)
    local i = front:has(x, y - 1) and 2 or 3
    if not soil:has(x, y + 1) and not front:has(x, y + 1) then i = 2 end
    if i == 3 and h01(x, y, 43) < 0.25 then i = 4 end
    if i == 3 and h01(x, y, 47) < 0.07 then i = 5 end
    c:put(x, y, A.SOIL[i], stok)
  end)
  -- a few pebbles
  for _, p in ipairs(o.pebbles or {}) do
    if soil:has(p[1], p[2]) then c:put(p[1], p[2], A.STONE[4], stok) if soil:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], A.STONE[2], stok) end end
  end
  -- front face: AO where it meets soil, top faces beside it, and under the overhang
  local fb = {}
  front:each(function(x, y)
    local k = K(x, y)
    local b = 0
    if soil:has(x, y + 1) or not front:has(x, y + 1) then b = b - 1 end
    if plan:has(x - 1, y) or plan:has(x + 1, y) then b = b - 1 end
    if plan:has(x, y - 1) then b = b - 1 end
    fb[k] = b
  end)
  local south = HP.mask()
  if o.cutB then
    front:each(function(x, y) if x >= o.cutB[1] and x <= o.cutB[2] and y > o.cutB[3] then south:set(x, y) end end)
  end
  local fm = front:copy():cut(south)
  A.foliage(fm, { mode = "front", seed = (o.seed or 1) + 50, bias = fb, R = 2, glintMin = 9, step = 4 })
  -- top face
  local pb = o.planBias or {}
  A.foliage(plan, { mode = "top", seed = o.seed or 1, bias = pb, R = 3, step = 4 })
  -- clean-cut connector edges: trimmed column with pale twig ends
  local ttok = { r = { name = "twig" } }
  local function cutCol(x)
    A.union(plan, front):each(function(px, py)
      if px == x then
        if h01(px, py, 61) < 0.35 then c:put(px, py, A.WOOD[5], ttok)
        elseif h01(px, py, 67) < 0.5 then c:put(px, py, A.GR[2]) end
      end
    end)
  end
  if o.cutL then cutCol(o.cutL) end
  if o.cutR then cutCol(o.cutR) end
  -- south cross-section: dark packed interior with leaf flecks and cut stems (pale end grain + dark ring)
  if o.cutB then
    south:each(function(x, y)
      local i = 1 + ((h01(x, y, 71) < 0.45) and 1 or 0) + ((h01(x, y, 73) < 0.15) and 1 or 0)
      if not south:has(x, y - 1) then i = 3 end
      c:put(x, y, A.GR[i], ttok)
    end)
    for _, s in ipairs(o.stems or {}) do
      local x, y = s[1], s[2]
      c:put(x, y, A.WOOD[6], ttok) c:put(x + 1, y, A.WOOD[4], ttok)
      c:put(x, y + 1, A.WOOD[4], ttok) c:put(x + 1, y + 1, A.WOOD[2], ttok)
    end
  end
  return front, soil, south
end

-- berry cluster: three 5-px berries with air between, deep shadow tucked under
function A.berries(list, glintEvery)
  local c = A.c
  local btok = { r = { name = "berry" } }
  for ci, q in ipairs(list) do
    local offs = q[3] or { { 0, 0 }, { 3, 1 }, { 1, 3 } }
    for bi, o in ipairs(offs) do
      local x, y = q[1] + o[1], q[2] + o[2]
      c:put(x + 1, y + 1, A.BER[1], btok) c:put(x + 2, y, A.GR[1])
      c:put(x, y, A.BER[3], btok)
      c:put(x - 1, y, A.BER[4], btok) c:put(x, y - 1, A.BER[4], btok)
      c:put(x + 1, y, A.BER[2], btok) c:put(x, y + 1, A.BER[2], btok)
      if bi == 1 then c:put(x - 1, y, A.CREAM, btok) end
    end
  end
end

-- paint a hand map; map = {ch = hex}
function A.paint(rows, x0, y0, map, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if map[ch] then A.c:put(x0 + xx - 1, y0 + yy - 1, map[ch], tok) end
  end end
end

function A.recentre()
  local c = A.c
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i in pairs(c.pix) do local x, y = i % c.w, i // c.w x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local dx, dy = floor((63 - (x0 + x1)) / 2), floor((63 - (y0 + y1)) / 2 + 0.5)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d", dx, dy))
end

function A.fin()
  local c = A.c
  A.recentre()
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.out .. A.name .. ".aseprite", png = A.out .. A.name .. ".png", scale = 1 }
end
return A
