-- _wander-kit: private helpers for the wander-* banner strips (480x64). Not a shared lib.
-- A z-buffered pixel layer: every draw stamps an object id; edges() draws a 1px dark edge on the
-- lower object wherever a higher outlined object touches it (ink between groups, inner tone within one).
local floor, abs, sqrt, sin, cos, atan, max, min = math.floor, math.abs, math.sqrt, math.sin, math.cos, math.atan, math.max, math.min
local K = {}

function K.hash(x, y, s)
  local v = sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453
  return v - floor(v)
end
local hash = K.hash

local function hx(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function K.mix(a, b, t)
  local r1, g1, b1 = hx(a); local r2, g2, b2 = hx(b)
  local function m(p, q) return max(1, min(254, floor(p + (q - p) * t + 0.5))) end
  return string.format("#%02x%02x%02x", m(r1, r2), m(g1, g2), m(b1, b2))
end

function K.bez(p, t)
  local u = 1 - t
  local a, b, c, d = u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t
  return a * p[1][1] + b * p[2][1] + c * p[3][1] + d * p[4][1], a * p[1][2] + b * p[2][2] + c * p[3][2] + d * p[4][2]
end

local S = {}
S.__index = S

function K.new(W, H)
  local s = setmetatable({ W = W, H = H, col = {}, zid = {}, objs = { [0] = {} }, cur = 0 }, S)
  for i = 0, W * H - 1 do s.col[i] = "#7f7f7f"; s.zid[i] = 0 end
  return s
end

-- new object: ol = outline vs other groups, inner = outline vs same group
function S:obj(ol, inner, group)
  local id = #self.objs + 1
  self.objs[id] = { ol = ol, inner = inner or ol, group = group or id }
  self.cur = id
  return id
end

function S:put(x, y, hex)
  x, y = floor(x), floor(y)
  if x < 0 or y < 0 or x >= self.W or y >= self.H then return end
  local i = y * self.W + x
  self.col[i] = hex; self.zid[i] = self.cur
end
function S:get(x, y)
  x, y = floor(x), floor(y)
  if x < 0 or y < 0 or x >= self.W or y >= self.H then return nil end
  return self.col[y * self.W + x]
end

local function pick(ramp, v)
  local n = #ramp
  local i = floor(v * n) + 1
  if i < 1 then i = 1 elseif i > n then i = n end
  return ramp[i]
end
K.pick = pick

-- stepped sky bands: stops = {{y, hex}, ...} ascending y
function S:sky(stops)
  self:obj(nil)
  for y = 0, self.H - 1 do
    local h = stops[1][2]
    for _, st in ipairs(stops) do if y >= st[1] then h = st[2] end end
    for x = 0, self.W - 1 do self:put(x, y, h) end
  end
end

-- terrain: top(x) -> y; ramp dark->light; opts.tex(x,y,d,v)->v ; opts.ol
function S:terrain(top, ramp, opts)
  opts = opts or {}
  self:obj(opts.ol, opts.inner, opts.group)
  local ybot = opts.ybot or self.H - 1
  for x = 0, self.W - 1 do
    local t = floor(top(x))
    for y = max(0, t), ybot do
      local d = y - t
      local v = opts.base or 0.55
      if d <= (opts.lip or 1) then v = 0.9 end
      v = v - d * (opts.fall or 0.012)
      if opts.tex then v = opts.tex(x, y, d, v) end
      self:put(x, y, pick(ramp, v))
    end
  end
end

-- lumpy blob test (no true circles: radius wobbles with angle)
function K.lumpy(cx, cy, rx, ry, seed, amp)
  amp = amp or 0.18
  local p1, p2, k1 = hash(seed, 1) * 6.28, hash(seed, 2) * 6.28, 3 + floor(hash(seed, 3) * 4)
  return function(x, y)
    local nx, ny = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
    local a = atan(ny, nx)
    local r = 1 + amp * sin(k1 * a + p1) * 0.6 + amp * 0.5 * sin((k1 + 3) * a + p2)
    local d = sqrt(nx * nx + ny * ny)
    return d < r, nx / r, ny / r, d / r
  end
end

-- shaded leafy/rocky blob
function S:blob(cx, cy, rx, ry, seed, ramp, opts)
  opts = opts or {}
  self:obj(opts.ol, opts.inner, opts.group)
  local f = K.lumpy(cx, cy, rx, ry, seed, opts.amp)
  for y = floor(cy - ry * 1.4), floor(cy + ry * 1.4) do
    if opts.ycut and y > opts.ycut then break end
    for x = floor(cx - rx * 1.4), floor(cx + rx * 1.4) do
      local inside, nx, ny, d = f(x, y)
      if inside then
        local v = 0.5 - 0.42 * (nx * 0.6 + ny * 0.8) + 0.12 * (1 - d)
        if opts.leaf then
          v = v + (hash(floor(x / 2), y, seed) - 0.5) * 0.22
          local hh = hash(x, y, seed + 9)
          if hh > 0.9 then v = v + 0.2 elseif hh < 0.07 then v = v - 0.2 end
        elseif opts.tex then
          v = opts.tex(x, y, v)
        end
        self:put(x, y, pick(ramp, v))
      end
    end
  end
end

-- leafy canopy: several clumps painted back to front, inner edges between clumps
function S:canopy(cx, cy, w, h, seed, ramp, ink, opts)
  opts = opts or {}
  local g = #self.objs + 1000
  local n = opts.n or (3 + floor(w * h / 110))
  local cl = {}
  for i = 1, n do
    local a, r = hash(seed, i) * 6.28, sqrt(hash(i, seed)) * 0.62
    local rx = w * (0.26 + hash(seed + i, 7) * 0.12)
    cl[#cl + 1] = { cx + cos(a) * r * w * 0.5, cy + sin(a) * r * h * 0.5, rx, rx * (0.7 + hash(i, 3, seed) * 0.15) }
  end
  table.sort(cl, function(a, b) return a[2] < b[2] end)
  for i, k in ipairs(cl) do
    self:blob(k[1], k[2], k[3], k[4], seed * 13 + i, ramp, { ol = ink, inner = opts.inner or ramp[1], group = g, leaf = true, amp = 0.22 })
  end
end

-- tube along a cubic bezier: wfn(t)->width. opts.grain bark streaks.
function S:tube(pts, wfn, ramp, opts)
  opts = opts or {}
  self:obj(opts.ol, opts.inner, opts.group)
  local x0, y0 = K.bez(pts, 0)
  local len = 0
  for i = 1, 20 do local x1, y1 = K.bez(pts, i / 20); len = len + sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2); x0, y0 = x1, y1 end
  local steps = max(8, floor(len * 2.5))
  local best = {}
  for s = 0, steps do
    local t = s / steps
    local px, py = K.bez(pts, t)
    local r = max(0.5, wfn(t) / 2)
    for y = floor(py - r - 1), floor(py + r + 1) do
      for x = floor(px - r - 1), floor(px + r + 1) do
        local dx, dy = x + 0.5 - px, y + 0.5 - py
        local d = sqrt(dx * dx + dy * dy)
        if d <= r + 0.15 then
          local key = y * self.W + x
          local nd = d / r
          local b = best[key]
          if not b or nd < b[1] then best[key] = { nd, dx / r, dy / r, t, x, y } end
        end
      end
    end
  end
  for _, b in pairs(best) do
    local nx, ny, t, x, y = b[2], b[3], b[4], b[5], b[6]
    local v = 0.52 - 0.4 * (nx * (opts.lx or 0.7) + ny * (opts.ly or 0.6)) + 0.1 * (1 - b[1])
    if opts.grain then
      local band = floor((nx + 1) * (opts.grain))
      local hh = hash(band, floor(t * len / 3), opts.seed or 1)
      if hh > 0.72 then v = v - 0.22 elseif hh < 0.1 then v = v + 0.16 end
    end
    if opts.tex then v = opts.tex(x, y, v, t) end
    self:put(x, y, pick(ramp, v))
  end
end

-- thorny bramble: thin vine with spikes
function S:bramble(pts, col, thorn, seed, opts)
  opts = opts or {}
  self:obj(opts.ol, opts.inner, opts.group)
  local steps = 120
  local lx, ly
  for s = 0, steps do
    local x, y = K.bez(pts, s / steps)
    x, y = floor(x), floor(y)
    if x ~= lx or y ~= ly then
      self:put(x, y, col)
      if opts.thick then self:put(x, y + 1, col) end
      if hash(x, y, seed) > 0.8 then
        local dy = hash(y, x, seed) > 0.5 and -1 or 1
        self:put(x + 1, y + dy, thorn)
      end
      if opts.berry and hash(x, y, seed + 4) > 0.95 then
        self:put(x, y + 2, opts.berry); self:put(x + 1, y + 2, opts.berry2 or opts.berry)
      end
      lx, ly = x, y
    end
  end
end

function S:edges()
  local W, H, col, zid, objs = self.W, self.H, self.col, self.zid, self.objs
  local out = {}
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local i = y * W + x
      local a = zid[i]
      local bestb = -1
      local nb = { { x - 1, y }, { x + 1, y }, { x, y - 1 }, { x, y + 1 } }
      for _, p in ipairs(nb) do
        if p[1] >= 0 and p[2] >= 0 and p[1] < W and p[2] < H then
          local b = zid[p[2] * W + p[1]]
          if b > a and objs[b].ol and b > bestb then bestb = b end
        end
      end
      if bestb > 0 then
        local ob = objs[bestb]
        out[i] = (objs[a].group == ob.group) and ob.inner or ob.ol
      end
    end
  end
  for i, h in pairs(out) do col[i] = h end
end

-- post tint (after edges): test(x,y)->amount 0..1 (stepped by caller)
function S:tint(x0, y0, x1, y1, fn, hex)
  for y = max(0, y0), min(self.H - 1, y1) do
    for x = max(0, x0), min(self.W - 1, x1) do
      local a = fn(x, y)
      if a and a > 0 then
        local i = y * self.W + x
        self.col[i] = K.mix(self.col[i], hex, a)
      end
    end
  end
end

-- diamond glow (hard steps)
function S:glow(cx, cy, r, hex, amt)
  self:tint(cx - r, cy - r, cx + r, cy + r, function(x, y)
    local d = abs(x - cx) + abs(y - cy)
    if d <= r * 0.5 then return amt * 1.6 elseif d <= r then return amt end
  end, hex)
end

function S:flush(c)
  for y = 0, self.H - 1 do
    for x = 0, self.W - 1 do c:put(x, y, self.col[y * self.W + x]) end
  end
end

return K
