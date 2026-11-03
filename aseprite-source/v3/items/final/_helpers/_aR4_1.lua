-- _aR4_1.lua: private helpers for ph/beehive-2, beehive-3, beehive-lantern, beehive-painted (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- ramps, dark -> light (6 tones, cool-violet darks, warm-yellow lights)
A.STRAW = { "#5e2f2e", "#94522a", "#c47d2c", "#e6a536", "#f6ca55", "#ffe8a0" }
A.WOOD  = { "#3e2429", "#5c372e", "#83503a", "#a86f48", "#c9925e", "#e6ba86" }
A.HONEY = { "#7a2e22", "#b8501c", "#e07a1e", "#f6a42a", "#ffcf4e", "#fff0a8" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise to ramp with optional per-pixel bias; returns idx (k -> tone index)
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.28 })
  local cuts = o.cuts or A.CUTS
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local val, i = v[k] or 0, 1
    for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
    if o.bias and o.bias[k] then i = i + o.bias[k] end
    i = max(1, min(#ramp, i))
    idx[k] = i
    c:put(x, y, ramp[i])
  end)
  return idx
end
-- nudge one pixel of a toned part by d steps
function A.step(c, idx, ramp, x, y, d, lo, hi)
  local k = K(x, y)
  if not idx[k] then return end
  local i = max(lo or 1, min(hi or #ramp, idx[k] + d))
  idx[k] = i
  c:put(x, y, ramp[i])
end

-- straw skep: coiled rings bottom -> top. rings = {{w=halfwidth, h=height}, ...}; cx may be .5
-- returns whole mask, idx, ring list {y0,y1,w,m}, crown mask
function A.skep(c, cx, ybase, rings, o)
  o = o or {}
  local ramp = o.ramp or A.STRAW
  local all, n, bias, info = HP.mask(), {}, {}, {}
  local y = ybase
  local below
  for i, r in ipairs(rings) do
    local y1, y0 = y, y - r.h + 1
    local ym = (y0 + y1) / 2
    local m = HP.mask()
    for yy = y0, y1 do for x = floor(cx - r.w - 2), floor(cx + r.w + 2) do
      local sx = (x - cx) / (r.w + 0.5)
      local sy = (yy - ym) / (r.h / 2 + 0.15)
      if abs(sx) ^ 3.2 + abs(sy) ^ 2.4 <= 1 then
        m:set(x, yy)
        local nx, ny = sx * 0.92, sy * 0.95 - 0.12
        n[K(x, yy)] = { norm(nx, ny, sqrt(max(0.06, 1 - nx*nx - ny*ny))) }
      end
    end end
    -- the ring above sits on this one: ambient row just under it (set after next ring is known)
    info[i] = { y0 = y0, y1 = y1, ym = ym, w = r.w, m = m }
    all:add(m)
    y = y0 + (r.ov or 1)
  end
  -- AO where each upper ring rests on the lower one
  for i = 1, #info - 1 do
    local up = info[i + 1].m
    info[i].m:each(function(x, yy)
      if not up:has(x, yy) and (up:has(x, yy - 1) or up:has(x, yy - 2)) then
        local k = K(x, yy) bias[k] = (bias[k] or 0) - (up:has(x, yy - 1) and 2 or 1) end
    end)
    -- the visible part of the lower ring is what is not covered
    info[i].vis = info[i].m:copy():cut(up)
  end
  info[#info].vis = info[#info].m:copy()
  -- crown cap
  local cr = o.crown or 3
  local top = info[#info].y0
  local crown = HP.mask()
  local ccy = top + 1
  for yy = ccy - cr, ccy + 1 do for x = floor(cx - cr - 1), floor(cx + cr + 1) do
    local sx, sy = (x - cx) / (cr + 0.5), (yy - ccy) / (cr + 0.3)
    if sx*sx + sy*sy <= 1 then crown:set(x, yy)
      if not all:has(x, yy) then n[K(x, yy)] = { norm(sx * 0.9, sy * 0.9 - 0.1, sqrt(max(0.08, 1 - sx*sx - sy*sy))) } end end
  end end
  crown:cut(all)
  all:add(crown)
  local idx = A.tone(c, all, n, ramp, { bias = bias, amb = 0.06, wrap = 0.3 })
  -- straw twist: short diagonal strands across the middle of each coil (rope twist), lit straw beside each
  local tw = o.twist or 4
  for i, r in ipairs(info) do
    local mid = floor(r.ym + 0.5) - 1
    r.vis:each(function(x, yy)
      local inner = r.vis:has(x - 1, yy) and r.vis:has(x + 1, yy)
      local rel = yy - mid
      if inner and rel >= -1 and rel <= 1 then
        local u = (x - rel + i * 2) % tw
        if u == 0 then A.step(c, idx, ramp, x, yy, -1, 2)
        elseif u == 1 and rel <= 0 then A.step(c, idx, ramp, x, yy, 1, 1, 5) end
      end
    end)
    -- seam: darkest row right under the ring above; lit top lip on this coil's upper edge
    if info[i + 1] then
      local up = info[i + 1].m
      r.vis:each(function(x, yy) if up:has(x, yy - 1) and idx[K(x, yy)] then idx[K(x, yy)] = 1 c:put(x, yy, ramp[1]) end end)
    end
    r.vis:each(function(x, yy)
      if not all:has(x, yy - 1) or (info[i + 1] and false) then end
    end)
  end
  return all, idx, info, crown, n
end

-- cane binding stitches across the coils (dark wrapped strips), at given x offsets per seam
function A.bind(c, idx, info, cx, offs, ramp, col)
  ramp = ramp or A.STRAW
  for i = 1, #info - 1 do
    local seamY = info[i + 1].y1
    for j, dx in ipairs(offs) do
      local x = floor(cx + dx * (info[i + 1].w / info[2].w) + (i % 2) * 2 + .5)
      for yy = seamY - 1, seamY + 1 do
        if idx[K(x, yy)] then
          local dark = idx[K(x, yy)] <= 3
          c:put(x, yy, yy == seamY - 1 and (dark and col[2] or col[3]) or (dark and col[1] or col[2]))
          idx[K(x, yy)] = nil
        end
      end
    end
  end
end

-- arched entrance cut into the bottom coil: dark cave + lit straw lip above + inner deep floor
function A.entrance(c, cx, ybot, hw, hh, o)
  o = o or {}
  local m = HP.mask()
  for y = ybot - hh, ybot do for x = floor(cx - hw - 1), floor(cx + hw + 1) do
    local sx = (x - cx) / (hw + 0.5)
    local sy = (ybot - y) / (hh + 0.4)
    if sy <= 0.55 and abs(sx) <= 1 then m:set(x, y)
    elseif sy > 0.55 and sx*sx + ((sy - 0.55) / 0.45)^2 <= 1 then m:set(x, y) end
  end end
  m:each(function(x, y)
    local col = "#2a1520"
    if y == ybot then col = "#4a2626" end
    if x > cx + hw - 1.2 and y < ybot then col = "#3a1d24" end
    c:put(x, y, col)
  end)
  return m
end

-- plank stand with a top face, front face, grain, pale end grain on the right end, and two legs
function A.stand(c, x0, x1, y0, o)
  o = o or {}
  local W = o.ramp or A.WOOD
  local th = o.th or 4
  -- legs
  for _, lx in ipairs(o.legs or { x0 + 3, x1 - 6 }) do
    local lm = c:rect(lx, y0 + th, lx + 3, y0 + th + (o.lh or 3))
    lm:each(function(x, y)
      local i = (x == lx) and 4 or (x == lx + 3 and 2 or 3)
      if y == y0 + th then i = 1 end
      c:put(x, y, W[i])
    end)
  end
  -- top face (2 rows, lit) and front face
  for y = y0, y0 + th - 1 do for x = x0, x1 do
    local i
    if y == y0 then i = 5 elseif y == y0 + 1 then i = 4 else i = (y == y0 + th - 1) and 2 or 3 end
    if x == x0 and y > y0 then i = min(6, i + 1) end
    c:put(x, y, W[i])
  end end
  -- grain on the front face: broken long streaks
  for x = x0 + 2, x1 - 4 do
    local y = y0 + 2
    if X.hash(x, y, 7) > 0.35 and (x % 9) < 6 then c:put(x, y + ((x // 9) % 2 == 0 and 0 or 1), W[2]) end
    if X.hash(x, y0, 9) > 0.8 then c:put(x, y0 + 1, W[5]) end
  end
  -- end grain on the right end: pale square with ring arc
  for y = y0 + 1, y0 + th - 1 do c:put(x1, y, W[5]) c:put(x1 - 1, y, W[4]) end
  c:put(x1, y0 + th - 2, W[3])
  c:put(x1, y0, W[6])
  -- AO row under whatever sits on top is done by the caller (contact)
end

-- tiny bee (7x5), facing left unless flip; wings pale glass
function A.bee(c, x, y, flip)
  local rows = {
    "..ww.ww",
    "..wWwWw",
    ".KGKGKs",
    "eGgKgKs",
    ".KdKdK.",
  }
  local map = { w = "#c8ecf4", W = "#fff4d6", K = "#2b1c26", G = "#f6ca55", g = "#e6a536", d = "#b06a2a", e = "#2b1c26", s = "#5a3a2a" }
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if map[ch] then c:put(flip and (x + 7 - xx) or (x + xx - 1), y + yy - 1, map[ch]) end
  end end
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
