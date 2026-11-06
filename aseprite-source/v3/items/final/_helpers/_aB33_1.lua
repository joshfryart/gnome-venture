-- _aB33_1.lua: private helpers for the garden-gate set (gate, corner, cross, end). Opus single pass.
-- Wraps hp.lua + hpx.lua (unchanged). Per-pixel light, 6-tone ramps, wood grain, contact shadow + 1px deep seam
-- where a later part overlaps an earlier one, 2:1 iso fence runs.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local A = { HP = HP, X = X, K = K }

-- 6-tone ramps, dark -> light (cool-violet shade, warm-yellow light)
A.PICK = { "#4a2a33", "#7a4634", "#a8683e", "#cc8d52", "#e8b674", "#f9dc9e" }   -- honey pine pickets
A.POST = { "#36202b", "#5c3431", "#844f3b", "#a96e48", "#cb9263", "#e8bb88" }   -- oak posts
A.RAIL = { "#3d2430", "#663b35", "#8d5a40", "#ad7a52", "#cd9f6e", "#ecc893" }   -- rails
A.IRON = { "#2e2a3c", "#454763", "#5f6381", "#848aa4", "#aeb3c7", "#e2e4ee" }
A.BRASS = { "#6b3a24", "#9a5a22", "#cf8a26", "#f0b42e", "#ffd76a", "#fff1bd" }
A.RED = { "#5e1d35", "#93283c", "#c63a3c", "#e8573f", "#ff8a5c", "#ffc09a" }
A.CREAM = "#fff4d6"
local CUTS = { 0.24, 0.42, 0.58, 0.73, 0.87 }

function A.new(name)
  A.name = name
  A.info = {}
  A.c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  return A.c
end
local function nrm(x, y, z) local l = sqrt(x*x + y*y + z*z) return { x/l, y/l, z/l } end
A.nrm = nrm

-- paint a lit part. o: n (normals), R bevel, tilt {x,y}, grain {dir="v"|"h", seed, dens}, bias, cuts,
-- nosep, noshadow, amb, wrap
function A.part(m, ramp, o)
  o = o or {}
  local c = A.c
  local n = o.n or X.pillow(m, o.R or 1.3)
  if o.tilt then
    local t = {}
    for k, v in pairs(n) do t[k] = nrm(v[1] + o.tilt[1], v[2] + o.tilt[2], v[3]) end
    n = t
  end
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = {}
  local cuts = o.cuts or CUTS
  m:each(function(x, y)
    local k = K(x, y)
    local i = 1
    for j, t in ipairs(cuts) do if (v[k] or 0) >= t then i = j + 1 end end
    if o.bias and o.bias[k] then i = i + o.bias[k] end
    idx[k] = i
  end)
  -- wood grain: broken streaks along the board, never on the rim pixels
  if o.grain then
    local g = o.grain
    local e = m:edge()
    m:each(function(x, y)
      if e:has(x, y) then return end
      local k = K(x, y)
      local a, b = x, y
      if g.dir == "h" then a, b = y, x end
      local off = floor(X.hash(a, 7, g.seed) * 9)
      local seg = floor((b + off) / 6)
      if X.hash(a, seg, g.seed) < (g.dens or 0.35) and X.hash(a, b, g.seed + 3) > 0.22 then idx[k] = idx[k] - 1 end
    end)
  end
  -- seam: deep line on own edge where it meets an earlier painted part
  if not o.nosep then
    m:edge():each(function(x, y)
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local q = K(x + d[1], y + d[2])
        if A.info[q] and not m:has(x + d[1], y + d[2]) then
          local k = K(x, y)
          idx[k] = min(idx[k], (d[1] < 0 or d[2] < 0) and 2 or 1)
          break
        end
      end
    end)
  end
  -- contact shadow cast lower-right onto earlier parts
  if not o.noshadow then
    local hit = {}
    m:each(function(x, y)
      for _, d in ipairs({ {1,0,2}, {0,1,2}, {1,1,2}, {2,0,1}, {2,1,1} }) do
        local xx, yy = x + d[1], y + d[2]
        local q = K(xx, yy)
        if A.info[q] and not m:has(xx, yy) then hit[q] = max(hit[q] or 0, d[3]) end
      end
    end)
    for q, amt in pairs(hit) do
      local f = A.info[q]
      local ni = max(1, f.i - amt)
      f.i = ni
      A.c:put(q % 1024 - 256, q // 1024 - 256, f.r[ni], f.tok)
    end
  end
  local tok = { r = { name = o.name or "part" } }
  for k, i in pairs(idx) do
    i = max(1, min(#ramp, i))
    local x, y = k % 1024 - 256, k // 1024 - 256
    c:put(x, y, ramp[i], tok)
    A.info[k] = { r = ramp, i = i, tok = tok }
  end
  return idx, n
end

-- direct set of a pixel with a ramp index (keeps info so later parts can shadow it)
function A.set(x, y, ramp, i)
  i = max(1, min(#ramp, i))
  local tok = { r = { name = "hand" } }
  A.c:put(x, y, ramp[i], tok)
  A.info[K(x, y)] = { r = ramp, i = i, tok = tok }
end
function A.px(x, y, hex) A.c:put(x, y, hex, { r = { name = "hand" } }) A.info[K(x, y)] = nil end

-- vertical picket: x0 left col, w width, ybot bottom row, h height (to shoulder), pointed top
function A.picketMask(x0, w, ybot, h, tip)
  local m = HP.mask()
  local ytop = ybot - h + 1
  for y = ytop, ybot do for x = x0, x0 + w - 1 do m:set(x, y) end end
  if tip ~= false then
    -- pointed top: shoulders cut, centre pixel(s) poke up
    local cx0, cx1 = x0 + floor((w - 1) / 2), x0 + floor(w / 2)
    for x = cx0, cx1 do m:set(x, ytop - 1) end
    if w >= 3 then m.s[K(x0, ytop)] = nil m.s[K(x0 + w - 1, ytop)] = nil end
  end
  return m
end
-- AO bias at the foot of a vertical part (bottom rows darker)
function A.footAO(m, rows)
  local bias = {}
  local _, _, _, y1 = m:bbox()
  m:each(function(x, y) if y > y1 - (rows or 2) then bias[K(x, y)] = -1 end end)
  return bias
end
-- iso rail: band of thickness th whose top follows y = y0 + (x - x0) * slope, x in [xa, xb]
function A.isoRail(xa, xb, x0, y0, slope, th)
  local m = HP.mask()
  for x = xa, xb do
    local yt = floor(y0 + (x - x0) * slope + 0.5)
    for y = yt, yt + th - 1 do m:set(x, y) end
  end
  return m
end
-- iso square post seen on its corner: front edge at column cx, ground y gy at the front edge, half width hw,
-- height h. returns mask, normals, topMask
function A.isoPost(cx, gy, hw, h)
  local m, n, top = HP.mask(), {}, HP.mask()
  for x = cx - hw, cx + hw - 1 do
    local dx = (x < cx) and (cx - x) or (x - cx + 1)
    local yb = gy - floor(dx / 2)
    local yt = gy - h - floor(dx / 2)
    for y = yt, yb do
      m:set(x, y)
      n[K(x, y)] = (x < cx) and nrm(-0.75, 0.05, 0.66) or nrm(0.8, 0.05, 0.6)
    end
  end
  -- top face diamond (end grain)
  local ty = gy - h
  for x = cx - hw, cx + hw - 1 do
    local dx = (x < cx) and (cx - x) or (x - cx + 1)
    for y = ty - hw + floor(dx / 2), ty - floor(dx / 2) - 1 do
      m:set(x, y) top:set(x, y)
      n[K(x, y)] = nrm(-0.1, -0.85, 0.5)
    end
  end
  return m, n, top
end

-- shift everything so the outlined bbox is centred (from batch2 _b2g1 pattern)
function A.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function A.save(c)
  A.recentre(c)
  c:finish{ outline = true }
  HP.assertClean(c)
  HP.report(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. A.name .. ".aseprite", png = out .. A.name .. ".png", scale = 1 }
end
return A
