-- _opus.lua: shared helpers (unchanged copy of c00/opus3/_opus.lua, itself from art-2701-batch3/pals/opus3). Tools only.
-- (<pal>-yard.lua, <pal>-perch.lua) draws its own shapes; this file only holds the tools.
--   local O = dofile(dir .. "/_opus.lua"); local c = O.canvas("name", 64)
--   O.shade(c, mask, ramp6, {R=, amb=, wrap=, sphere={cx,cy,r}, bias=, sep=deepHex})  pillow/sphere light -> 6 tones
--   O.tube(pts4, wfn) bezier tube mask + normals; O.shadeN(c, mask, normals, ramp, o)
--   O.done(c, file)  rim light + bounce on registered parts, finish outline, report, assertClean, save
--   richness pass additions:
--     O.shade/O.shadeN opts: rim=true (1 tone up on the silhouette edge facing the upper-left light),
--       bounce="#hex" (cool reflected light on silhouette pixels facing lower-right that sit in the dark tones)
--     O.tex(c, idx, tok, ramp, f)  re-tone a lit part: f(x, y, i) -> tone offset (texture: fur, grain, flecks)
--     O.H(x, y, s) deterministic hash noise 0..1
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local X = dofile(dir .. "/../../../lib/hpx.lua").init(HP)
local P = HP.P
local O = { HP = HP, X = X, P = P, K = X.K }
local K = X.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
O.out = app.params.out or (dir .. "/")
O.CUTS = { .2, .38, .55, .71, .86 }

function O.canvas(name, size) return HP.canvas{ w = size, h = size, scale = 1, name = name } end

-- paint pixels of mask m with tones from ramp (dark..light) using normals n; o.sep: line colour on
-- pixels that touch an earlier painted solid pixel outside m (part separation, rule 2)
function O.shadeN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or .18, wrap = o.wrap or .35 })
  local sepPx = {}
  if o.sep then
    m:each(function(x, y)
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local nx, ny = x + d[1], y + d[2]
        if not m:has(nx, ny) and nx >= 0 and ny >= 0 and nx < c.w and ny < c.h then
          local ow = c.own[ny * c.w + nx]
          if type(ow) == "table" and ow.r then sepPx[#sepPx+1] = { x, y } break end
        end
      end
    end)
  end
  local tok = { r = { name = o.name or "part" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or (#ramp == 6 and O.CUTS or nil), bias = o.bias, tok = tok })
  for _, p in ipairs(sepPx) do c:put(p[1], p[2], o.sep, tok) end
  if o.rim or o.bounce then
    c._lit = c._lit or {}
    c._lit[#c._lit+1] = { idx = idx, tok = tok, ramp = ramp, rim = o.rim, bounce = o.bounce, bmax = o.bmax or 3 }
  end
  return idx, tok
end
function O.shade(c, m, ramp, o)
  o = o or {}
  local n
  if o.sphere then n = X.sphere(o.sphere[1], o.sphere[2], o.sphere[3], m) else n = X.pillow(m, o.R or 4) end
  return O.shadeN(c, m, n, ramp, o)
end
-- flat fill that still counts as a solid part (outlined, separates later parts)
function O.flat(c, m, hex, name)
  local tok = { r = { name = name or "flat" } }
  m:each(function(x, y) c:put(x, y, hex, tok) end)
  return tok
end
function O.dot(c, x, y, hex) c:put(x, y, hex, { r = { name = "dot" } }) end
function O.dots(c, list, hex) for _, p in ipairs(list) do O.dot(c, p[1], p[2], hex) end end
-- recolour existing painted pixels of mask m from one ramp index to another (texture marks)
function O.mark(c, list, hex) for _, p in ipairs(list) do if c:get(p[1], p[2]) then c.pix[p[2] * c.w + p[1]] = hex end end end

function O.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier p (4 points); half width wfn(t). Returns mask, normals, T
function O.tube(p, wfn)
  local sm, N = {}, 120
  for i = 0, N do
    local t = i / N
    local x, y = O.bez(p, t)
    local x2, y2 = O.bez(p, min(1, t + .003))
    local x1, y1 = O.bez(p, max(0, t - .003))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) if l == 0 then l = 1 end
    tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm+1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do x0 = min(x0, s.x) y0 = min(y0, s.y) x1 = max(x1, s.x) y1 = max(y1, s.y) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(y0) - 8, floor(y1) + 8 do for x = floor(x0) - 8, floor(x1) + 8 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x + .5 - s.x - .5)^2 + (y - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-.95, min(.95, sd / (bs.w + .5)))
      m:set(x, y)
      n[K(x, y)] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[K(x, y)] = bs.t
      S[K(x, y)] = sd / math.max(bs.w, .5)
    end
  end end
  return m, n, T, S
end
function O.unionCircles(list) -- {{cx,cy,r},..}
  local m = HP.mask()
  for _, q in ipairs(list) do m:add(HP.ellipse(q[1], q[2], q[3], q[4] or q[3])) end
  return m
end

-- move the whole drawing (before O.done) to centre it
function O.shift(c, dx, dy)
  local np, no = {}, {}
  for y = 0, c.h - 1 do for x = 0, c.w - 1 do
    local i = y * c.w + x
    if c.pix[i] then
      local nx, ny = x + dx, y + dy
      if nx >= 0 and ny >= 0 and nx < c.w and ny < c.h then np[ny * c.w + nx] = c.pix[i]; no[ny * c.w + nx] = c.own[i] end
    end
  end end
  c.pix, c.own = np, no
  c._ox, c._oy = (c._ox or 0) + dx, (c._oy or 0) + dy
end
O.H = X.hash
function O.tex(c, idx, tok, ramp, f)
  for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local p = y * c.w + x
    if x >= 0 and y >= 0 and x < c.w and y < c.h and c.own[p] == tok then
      local d = f(x, y, i)
      if d and d ~= 0 then c.pix[p] = ramp[max(1, min(#ramp, i + d))]:lower() end
    end
  end
end
local function clear(c, x, y)
  if x < 0 or y < 0 or x >= c.w or y >= c.h then return true end
  local ow = c.own[y * c.w + x]
  return ow == nil or (type(ow) == "table" and not ow.r)
end
-- rim light (upper-left silhouette) and bounce (lower-right silhouette) for parts registered with rim/bounce
function O.light(c)
  local set = {}
  for _, L in ipairs(c._lit or {}) do
    for k, i in pairs(L.idx) do
      local x, y = k % 1024 - 256 + (c._ox or 0), k // 1024 - 256 + (c._oy or 0)
      local p = y * c.w + x
      if x >= 0 and y >= 0 and x < c.w and y < c.h and c.own[p] == L.tok then
        local ul = clear(c, x - 1, y) or clear(c, x, y - 1)
        local lr = clear(c, x + 1, y) or clear(c, x, y + 1)
        if L.rim and ul and not lr and i >= 2 then set[#set+1] = { p, L.ramp[min(#L.ramp, i + 1)] }
        elseif L.bounce and lr and not ul and i <= L.bmax then set[#set+1] = { p, L.bounce } end
      end
    end
  end
  for _, s in ipairs(set) do c.pix[s[1]] = s[2]:lower() end
end
-- post(c): optional, runs after the outline (motion arcs and other un-outlined effects)
function O.done(c, file, post)
  O.light(c)
  c:finish{ outline = true }
  if post then post(c) end
  HP.report(c)
  HP.assertClean(c)
  c:save{ aseprite = O.out .. file .. ".aseprite", png = O.out .. file .. ".png", scale = 1 }
end
return O
