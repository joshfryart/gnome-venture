-- _aC33_4.lua: private helpers for ph/picket-fence, picket-fence-corner, picket-fence-cross, picket-fence-end
-- (final pass, Opus). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
-- Oblique "iso" fence kit: slabs (pickets) whose bottoms follow a ground slope (0 = front-on, +-0.5 = receding run),
-- rails as sheared bands, posts as 45-degree boxes. Per-pixel pillow light via hpx, 6-tone ramps.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
-- painted picket (warm cream paint, cool violet shade)
A.PAINT = { "#4e3550", "#7f6378", "#b39a9c", "#d9c6b0", "#f0e2c4", "#fdf3da" }
-- raw wood rails / posts
A.WOOD = { "#3f2431", "#66382f", "#8e5434", "#b57843", "#d49b5a", "#efc585" }
A.METAL = { "#3c3d58", "#6b6c86", "#b8b7c8" }
A.MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function inRamp(r, hex) for i, h in ipairs(r) do if h == hex then return i end end end
A.inRamp = inRamp

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light a mask with pillow normals; bias = constant or per-key table; returns idx
function A.tone(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 1.6)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local b = o.bias or 0
    if o.fb then b = b + (o.fb(x, y) or 0) end
    bias[k] = b
  end)
  return X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = bias, tok = o.tok })
end

-- separation: pixels just outside m that are already painted get a darker line.
-- same-material (paint) -> PAINT[2] all round; wood behind -> contact shadow on the right and below only.
function A.sep(c, m)
  local bb = { m:bbox() }
  m:grow(1):cut(m):each(function(x, y)
    local h = c:get(x, y)
    if h then
      local ip, iw = inRamp(A.PAINT, h), inRamp(A.WOOD, h)
      if ip and ip > 2 then c:put(x, y, A.PAINT[2])
      elseif iw and (not m:has(x - 1, y) == false or m:has(x - 1, y) or m:has(x, y - 1)) then
        c:put(x, y, A.WOOD[max(1, min(2, iw - 2))])
      end
    end
  end)
end

-- picket slab: odd width w centred on cx; bottom(x) = gy + floor(slope*(x-cx)); pointed top
-- o: bias (face orientation), chip {dx,dy} (paint chipped to bare wood), grain dx, ramp
function A.picket(c, cx, gy, h, slope, o)
  o = o or {}
  local w = o.w or 5
  local hw = (w - 1) // 2
  local ramp = o.ramp or A.PAINT
  local m = HP.mask()
  local bot, top = {}, {}
  for x = cx - hw, cx + hw do
    local b = gy + floor(slope * (x - cx))
    local t = b - h + abs(x - cx)
    bot[x], top[x] = b, t
    for y = t, b do m:set(x, y) end
  end
  if o.sep ~= false then A.sep(c, m) end
  local tok = { r = { name = "picket" } }
  local idx = A.tone(c, m, ramp, { bias = o.bias, tok = tok, fb = function(x, y)
    if y >= bot[x] - 1 then return -1 end            -- AO at the foot
    if o.ao and o.ao(x, y) then return -1 end
  end })
  -- grain: broken vertical streaks one tone down
  local gx = cx + (o.grain or 1)
  for y = top[gx] + 5, bot[gx] - 3 do
    local hsh = X.hash(gx, y, 7)
    if hsh > 0.35 and (y % 7) ~= 3 then
      local i = idx[K(gx, y)] if i then c:put(gx, y, ramp[max(1, i - 1)], tok) end
    end
  end
  -- pop: lit 2px on the point's upper-left bevel
  local px = cx - 1
  c:put(px, top[px] + 1, ramp[6], tok) c:put(px, top[px] + 2, ramp[6], tok)
  -- paint chip showing bare wood
  if o.chip then
    local x, y = cx + o.chip[1], bot[cx + o.chip[1]] + o.chip[2]
    c:put(x, y, A.WOOD[5], tok) c:put(x + 1, y, A.WOOD[4], tok) c:put(x, y + 1, A.WOOD[3], tok)
  end
  return m, bot, top
end

-- rail: band of thickness th; left end x0, right end x1; top row y at x = ya + floor(slope*(x - xa))
function A.rail(c, x0, x1, xa, ya, slope, o)
  o = o or {}
  local th = o.th or 3
  local m = HP.mask()
  for x = x0, x1 do
    local y = ya + floor(slope * (x - xa))
    for d = 0, th - 1 do m:set(x, y + d) end
  end
  local tok = { r = { name = "rail" } }
  local idx = A.tone(c, m, A.WOOD, { R = 1.2, bias = o.bias, tok = tok })
  -- grain dashes along the rail (middle row)
  for x = x0 + 1, x1 - 1 do
    local y = ya + floor(slope * (x - xa)) + 1
    if X.hash(x, y, 3) > 0.62 then local i = idx[K(x, y)] if i then c:put(x, y, A.WOOD[max(1, i - 1)], tok) end end
  end
  -- pale end grain on cut ends
  for _, e in ipairs(o.ends or {}) do
    local x = e == "l" and x0 or x1
    local y = ya + floor(slope * (x - xa))
    c:put(x, y, A.WOOD[6], tok) c:put(x, y + 1, A.WOOD[5], tok) if th > 2 then c:put(x, y + 2, A.WOOD[4], tok) end
  end
  return m
end

-- nail head (metal): dark eye + bright edge
function A.nail(c, x, y) c:put(x, y, A.METAL[1]) c:put(x, y - 1, A.METAL[3]) end

-- 45-degree post box. ground front vertex (cx, gy); half diagonal hd; height H.
-- left face (lit) x = cx-hd .. cx-1, right face x = cx .. cx+hd-1. returns topY(x) table, masks
function A.post(c, cx, gy, hd, H, o)
  o = o or {}
  local L, R, T = HP.mask(), HP.mask(), HP.mask()
  local bot, top = {}, {}
  for x = cx - hd, cx + hd - 1 do
    local b = x < cx and gy - floor((cx - x + 1) / 2) or gy - floor((x - cx) / 2)
    bot[x] = b top[x] = b - H
    for y = top[x], b do (x < cx and L or R):set(x, y) end
  end
  -- top rhombus: from each column's top up to mirrored back edge
  local th = floor(hd / 2)
  for x = cx - hd, cx + hd - 1 do
    local d = x < cx and (cx - x) or (x - cx + 1)
    local back = top[x] - (2 * th - floor((d) / 2)) + floor(d / 2) - th
    -- back edge rises toward the centre: apex at cx is top - 2*th
    local yb = top[cx] - hd + floor(d / 2) + (x < cx and 0 or 0)
    for y = min(yb, top[x] - 1), top[x] - 1 do T:set(x, y) end
  end
  local all = HP.mask():add(L):add(R):add(T)
  A.sep(c, all)
  local tok = { r = { name = "post" } }
  local ramp = o.ramp or A.WOOD
  local li = A.tone(c, L, ramp, { R = 1.4, bias = 0, tok = tok, fb = function(x, y) if y >= bot[x] - 1 then return -1 end end })
  local ri = A.tone(c, R, ramp, { R = 1.4, bias = -2, tok = tok, fb = function(x, y) if y >= bot[x] - 1 then return -1 end end })
  -- vertical grain on both faces
  for _, f in ipairs{ { cx - hd + 1, li, 0 }, { cx + 1, ri, 0 }, { cx - 2, li, 0 } } do
    local x = f[1]
    for y = top[x] + 3, bot[x] - 3 do
      if X.hash(x, y, 11) > 0.4 and y % 5 ~= 0 then local i = f[2][K(x, y)] if i then c:put(x, y, ramp[max(1, i - 1)], tok) end end
    end
  end
  -- corner arris: bright edge on the front vertical edge (left of cx)
  for y = top[cx - 1] + 1, bot[cx - 1] - 3 do c:put(cx - 1, y, ramp[6], tok) end
  if o.top ~= false then
    -- end grain: pale top with a ring
    T:each(function(x, y) c:put(x, y, ramp[6], tok) end)
    local tb = { T:bbox() }
    local mx, my = floor((tb[1] + tb[3]) / 2), floor((tb[2] + tb[4]) / 2)
    T:each(function(x, y)
      local d = abs(x - mx) / 2 + abs(y - my)
      if d >= 1.4 and d < 2.1 then c:put(x, y, ramp[5], tok) end
    end)
    c:put(mx, my, ramp[4], tok)
    T:edge():each(function(x, y) if not T:has(x, y + 1) and y >= my then c:put(x, y, ramp[5], tok) end end)
  end
  return { top = top, bot = bot, L = L, R = R, T = T, all = all, apex = top[cx] - hd }
end

-- moss tuft at the foot (3 blades)
function A.tuft(c, x, y)
  local M = A.MOSS
  c:put(x, y, M[1]) c:put(x + 1, y, M[2]) c:put(x + 2, y, M[1])
  c:put(x, y - 1, M[2]) c:put(x + 1, y - 1, M[3]) c:put(x + 2, y - 2, M[3])
  c:put(x - 1, y - 2, M[3]) c:put(x + 1, y - 2, M[4]) c:put(x + 2, y - 1, M[2])
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
