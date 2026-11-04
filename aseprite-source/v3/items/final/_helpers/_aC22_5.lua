-- _aC22_5.lua: private helpers for ph/masterwork-rain-wand, -secateurs, -stirrup-hoe, -wheel-hoe (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS

-- 6-tone ramps, dark -> light
A.WOOD  = { "#4b2a2b", "#6f3d2f", "#94573a", "#b8784a", "#d79c62", "#f0c487" }
A.ASH   = { "#553326", "#7d4c32", "#a46a42", "#c78d58", "#e2b277", "#f6d9a0" }
A.STEEL = { "#30324c", "#4c506e", "#6f7592", "#979fb8", "#c2c9da", "#eef1f6" }
A.BRASS = { "#5e331d", "#8e521f", "#c07e26", "#e5a936", "#f8d064", "#fff2b0" }
A.RED   = { "#4a1730", "#781f38", "#a8303d", "#d44a40", "#f0714f", "#ffa47a" }
A.TEAL  = { "#1d3d4e", "#265e66", "#2f8580", "#47a896", "#78ccab", "#b7ebcd" }
A.GLASS = { "#233c78", "#2c62a6", "#3d8fcb", "#62b9df", "#a3e0ef", "#e2fbf8" }
A.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.PINK  = { "#5a2040", "#8a2e5a", "#c04878", "#e86c94", "#ff9cb6", "#ffd0dc" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
end

-- per-pixel ramp choice: sel(k, x, y) -> ramp
function A.toneSel(c, m, n, sel, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts, idx = o.cuts or CUTS, {}
  m:each(function(x, y)
    local k = K(x, y)
    local i = 1
    for j, t in ipairs(cuts) do if (v[k] or 0) >= t then i = j + 1 end end
    if o.bias and o.bias[k] then i = i + o.bias[k] end
    i = max(1, min(6, i)) idx[k] = i
    c:put(x, y, sel(k, x, y)[i], o.tok)
  end)
  return idx
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- straight lit rod A->B, w = number or fn(t); o.round trims end corners; o.biasf(t, s) adds tone steps
function A.rod(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local wfn = type(w) == "function" and w or function() return w end
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  if o.round then
    local cut = HP.mask()
    m:each(function(x, y) local k = K(x, y)
      local u = T[k] * len
      if (u < 0.9 or u > len - 0.9) and abs(S[k]) > 0.55 then cut:set(x, y) end end)
    m:cut(cut)
  end
  if o.cut then m:cut(o.cut) end
  local bias = o.bias or {}
  if o.biasf then m:each(function(x, y) local k = K(x, y) bias[k] = (bias[k] or 0) + o.biasf(T[k], S[k], x, y) end) end
  local idx = A.tone(c, m, n, ramp, { amb = o.amb or 0.1, wrap = o.wrap or 0.28, bias = bias, tok = o.tok, cuts = o.cuts })
  return m, T, S, idx, n, len
end

-- wood grain: broken dark dashes along the length in alternate lanes, sparse pale flecks on the lit lane
function A.grain(c, m, T, S, idx, ramp, len, seed, o)
  o = o or {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if t > (o.t0 or 0.02) and t < (o.t1 or 0.98) then
      local u = t * len
      local lane = floor((s + 1) * 1.6)
      local hsh = X.hash(floor((u + lane * 1.3) / 2.6), lane, seed)
      if lane % 2 == 1 and hsh > 0.42 then A.step(c, idx, ramp, x, y, -1, o.tok)
      elseif lane == 0 and hsh > 0.8 and idx[k] >= 4 then A.step(c, idx, ramp, x, y, 1, o.tok) end
    end
  end)
end

-- bevelled flat metal plate: pillow normals, bright top-left edge
function A.plate(c, m, ramp, o)
  o = o or {}
  local n = X.pillow(m, o.R or 1.5)
  local idx = A.tone(c, m, n, ramp, { amb = o.amb or 0.1, wrap = o.wrap or 0.3, bias = o.bias, tok = o.tok, cuts = o.cuts })
  if o.edge ~= false then
    m:edge():each(function(x, y) local k = K(x, y)
      if (not m:has(x - 1, y) or not m:has(x, y - 1)) and m:has(x + 1, y) and m:has(x, y + 1) and idx[k] >= 3 then
        A.step(c, idx, ramp, x, y, 1, o.tok) end end)
  end
  return idx, n
end

function A.ball(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = HP.mask()
  for y = floor(cy - r - 1), floor(cy + r + 1) do for x = floor(cx - r - 1), floor(cx + r + 1) do
    if (x - cx) ^ 2 + (y - cy) ^ 2 <= r * r + 0.3 then m:set(x, y) end end end
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local idx = A.tone(c, m, n, ramp, { amb = o.amb or 0.08, wrap = o.wrap or 0.22, bias = o.bias, tok = o.tok })
  return m, idx, n
end

-- teardrop mask: round end centre (cx,cy) radius r, tip L px along unit (ux,uy)
function A.dropMask(cx, cy, r, L, ux, uy)
  local m = HP.mask()
  local R = r + L + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local a = dx * ux + dy * uy
    local b = -dx * uy + dy * ux
    local w
    if a <= 0 then w = r * r - a * a >= 0 and sqrt(r * r - a * a) or -1
    else w = a < L and r * (1 - a / L) ^ 1.25 or -1 end
    if w >= 0 and abs(b) <= w + 0.2 then m:set(x, y) end
  end end
  return m
end

-- glass/water drop: bright rim on the lit side, deep rim on the shade side, pale core lower right, cream glint
function A.drop(c, cx, cy, r, L, ux, uy, ramp, o)
  o = o or {}
  ramp = ramp or A.GLASS
  local m = A.dropMask(cx, cy, r, L, ux, uy)
  local d = X.dist(m)
  m:each(function(x, y) local k = K(x, y)
    local dd = d[k]
    local lit = (x - cx) + (y - cy) < 0
    local i
    if dd < 0.6 then i = lit and 5 or 2
    elseif dd < 1.6 then i = lit and 3 or 3
    else i = 4 end
    -- pale core (refracted light) toward the lower right of centre
    if r > 1.8 and (x - cx - r * 0.3) ^ 2 + (y - cy - r * 0.3) ^ 2 <= (r * 0.42) ^ 2 + 0.2 and dd >= 1 then i = 5 end
    c:put(x, y, ramp[i], o.tok)
  end)
  local gx, gy = floor(cx - r * 0.45 + 0.5), floor(cy - r * 0.45 + 0.5)
  if m:has(gx, gy) then c:put(gx, gy, A.CREAM, o.tok) if r > 2.5 and m:has(gx + 1, gy) then c:put(gx + 1, gy, ramp[6], o.tok) end end
  return m
end

-- 1px polyline painted with a fixed hex (or per-step fn)
function A.wire(c, pts, col, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local nst = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, nst do
      local t = nst == 0 and 0 or j / nst
      local x, y = floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5)
      c:put(x, y, type(col) == "function" and col(i, j, nst) or col, tok)
    end
  end
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- darken pixels already painted (any owner) inside mask m by stepping toward a darker ramp entry
local LOOK = {}
for _, r in ipairs{ A.WOOD, A.ASH, A.STEEL, A.BRASS, A.RED, A.TEAL, A.GLASS, A.LEAF, A.PINK } do
  for i, h in ipairs(r) do LOOK[h:lower()] = { r, i } end end
function A.darkenOn(c, m, steps)
  m:each(function(x, y)
    local cur = c:get(x, y)
    local e = cur and LOOK[cur]
    if e then c:put(x, y, e[1][max(1, e[2] - (steps or 1))]) end
  end)
end
-- contact shadow: pixels of earlier paint just below-right of mask `top` (and its 1px ring) darken
function A.contact(c, top, steps)
  local sh = top:shift(1, 1):add(top:shift(1, 0)):add(top:shift(0, 1)):cut(top)
  A.darkenOn(c, sh, steps or 1)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
