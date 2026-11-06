-- _aB21_3.lua: private helpers for ph/compost_bin-mossy, compost_bin-painted, coneflower-seed, congo-cockatoo-seed
-- (final pass, Opus single pass). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib). No shared file edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.OUT = DIR .. "/../ph/"
A.INK = "#2b1c26"
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- rect mask
function A.rect(x0, y0, x1, y1) local m = HP.mask() for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end return m end
-- polygon mask (even-odd, pixel centres)
function A.poly(pts)
  local m = HP.mask()
  local y0, y1 = 1e9, -1e9
  for _, p in ipairs(pts) do y0, y1 = min(y0, p[2]), max(y1, p[2]) end
  for y = floor(y0), math.ceil(y1) do
    local xs = {}
    for i = 1, #pts do local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= y + .5) ~= (b[2] <= y + .5) then xs[#xs + 1] = a[1] + (y + .5 - a[2]) / (b[2] - a[2]) * (b[1] - a[1]) end end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do for x = math.ceil(xs[i] - .5), floor(xs[i + 1] - .5) do m:set(x, y) end end
  end
  return m
end
-- plank: bevelled board, per-pixel light, grain along axis ("h" or "v"), end grain optional
-- o: R, bias, grain (ramp index offset for grain lines), seed, knots {{x,y}}, amb, cuts, tok
function A.plank(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 1.6)
  local v = X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 })
  local bias = o.bias or {}
  local tok = o.tok or { r = { name = o.name or "plank" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.86 }, bias = bias, tok = tok })
  local sd = o.seed or 1
  if o.grain ~= false then
    m:each(function(x, y) local k = K(x, y)
      local a, b = (o.dir == "v") and y or x, (o.dir == "v") and x or y
      -- streaks: run along the axis, broken by hash
      local lane = X.hash(b, 7, sd)
      local h = X.hash(floor(a / (3 + floor(lane * 4))), b, sd + 3)
      if lane > 0.55 and h > 0.45 and idx[k] > 1 and idx[k] < #ramp then
        c:put(x, y, ramp[idx[k] - 1], tok)
      end
    end)
  end
  for _, kn in ipairs(o.knots or {}) do
    c:put(kn[1], kn[2], ramp[1], tok) c:put(kn[1] + 1, kn[2], ramp[2], tok) c:put(kn[1] - 1, kn[2], ramp[3], tok)
  end
  return idx, n, tok
end
-- bumpy cushion (moss, compost): pillow + noise normals
function A.bumpy(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 2.5)
  local sd = o.seed or 5
  for k, nn in pairs(n) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local jx, jy = (X.hash(x, y, sd) - .5) * (o.rough or 0.9), (X.hash(x, y, sd + 1) - .5) * (o.rough or 0.9)
    local lx, ly, lz = nn[1] + jx, nn[2] + jy, nn[3]
    local l = sqrt(lx * lx + ly * ly + lz * lz)
    n[k] = { lx / l, ly / l, lz / l }
  end
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = o.bias, tok = o.tok or { r = { name = o.name or "bumpy" } } }), n
end
-- torn edge: remove pixels of m beyond a jagged line through (x0,y0)->(x1,y1) on side `sgn`
function A.tear(m, x0, y0, x1, y1, sgn, seed)
  local dx, dy = x1 - x0, y1 - y0
  local l = sqrt(dx * dx + dy * dy)
  local cut = {}
  m:each(function(x, y)
    local s = ((x - x0) * dy - (y - y0) * dx) / l
    local t = ((x - x0) * dx + (y - y0) * dy) / l
    local j = (X.hash(floor(t), 3, seed or 9) - .5) * 2.6 + ((floor(t) % 3 == 0) and 1 or 0)
    if s * sgn > j then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
