-- _aB10_1.lua: private helpers for box-hedge-cross / -end / -gate / -straight (final pass, Opus).
-- Read-only use of _aA10_1.lua pattern via batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
-- Adds an oblique-projection prism renderer (plan shape S(x,z) extruded to height H) and clipped-boxwood foliage
-- shading: per-pixel normals = face normal + rounded clipped edges + small leaf-cluster bumps, gaps sink a tone.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
-- boxwood: 6 tones dark -> light, plus a waxy leaf glint
A.BOX = { "#14382f", "#1d5139", "#2a6c40", "#3f8a45", "#62a94c", "#94c862" }
A.GLINT = "#d6efa0"
A.WOOD = { "#4a2a26", "#6e3f2e", "#925a38", "#b57a48", "#d39e62", "#ecc78c" }
A.TWIG = "#5a3a2a"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- prism in oblique view: screen y = oy + z*f - yh.  S(x,z) plan test, x in [x0,x1], z in [z0,z1], height H.
-- returns mask, face[k] ("top"|"front"), Z[k] (plan depth of the visible point), YH[k]
function A.prism(S, x0, x1, z0, z1, H, f, oy)
  local m, face, Z, YH = HP.mask(), {}, {}, {}
  local sy0, sy1 = floor(oy + z0 * f - H) - 1, floor(oy + z1 * f) + 1
  for sy = sy0, sy1 do for sx = x0, x1 do
    local px, py = sx + 0.5, sy + 0.5
    local zt = (py + H - oy) / f
    local k = K(sx, sy)
    if zt >= z0 and zt <= z1 and S(px, zt) then
      m:set(sx, sy) face[k] = "top" Z[k] = zt YH[k] = H
    else
      local zb = (py - oy) / f
      local z = min(zt, z1)
      while z >= max(zb, z0) do
        if S(px, z) then m:set(sx, sy) face[k] = "front" Z[k] = z YH[k] = z * f + oy - py break end
        z = z - 0.2
      end
    end
  end end
  return m, face, Z, YH
end

-- clipped boxwood shading for a prism (or any mask with a face table). o: seed, tok, bias, ground (bottom AO rows)
function A.foliage(c, m, face, o)
  o = o or {}
  local seed = o.seed or 1
  local NT, NF = { norm(0, -0.85, 0.55) }, { norm(0, 0.28, 0.96) }
  local pn = X.pillow(m, o.R or 3)
  -- separate pillow per face so the top/front crease rounds over
  local top = HP.mask() m:each(function(x, y) if face[K(x, y)] == "top" then top:set(x, y) end end)
  local n, bias = {}, o.bias or {}
  -- leaf clusters on a jittered grid
  local blobs = {}
  local x0, y0, x1, y1 = m:bbox()
  local sp = o.sp or 3.1
  for gy = y0 - 2, y1 + 2, sp do for gx = x0 - 2, x1 + 2, sp do
    local jx = (X.hash(floor(gx * 3), floor(gy * 3), seed) - 0.5) * 2.0
    local jy = (X.hash(floor(gx * 3), floor(gy * 3), seed + 7) - 0.5) * 2.0
    blobs[#blobs + 1] = { gx + jx, gy + jy, 1.6 + X.hash(floor(gx), floor(gy), seed + 3) * 0.6 }
  end end
  m:each(function(x, y)
    local k = K(x, y)
    local b = (o.base and o.base[k]) or ((face[k] == "top") and NT or NF)
    local p = pn[k]
    local pk = o.base and 0 or 0.9
    local bx, by = p[1] * pk, p[2] * pk
    -- crease: top pixels just above front face tilt down, front pixels just below top tilt up
    if face[k] == "top" and (face[K(x, y + 1)] == "front") then by = by + 0.55 end
    if face[k] == "top" and (face[K(x, y + 2)] == "front") then by = by + 0.25 end
    if face[k] == "front" and (face[K(x, y - 1)] == "top") then by = by - 0.45 end
    -- nearest leaf cluster
    local best, bb = 1e9
    for _, q in ipairs(blobs) do
      local d = (x + 0.5 - q[1])^2 + (y + 0.5 - q[2])^2
      if d < best then best, bb = d, q end
    end
    local d = sqrt(best)
    local lx, ly = (x + 0.5 - bb[1]) / bb[3], (y + 0.5 - bb[2]) / bb[3]
    lx, ly = max(-1, min(1, lx)), max(-1, min(1, ly))
    local la = o.leaf or 0.38
    n[k] = { norm(b[1] + bx + lx * la, b[2] + by + ly * la, b[3]) }
    if d > bb[3] * 1.1 then bias[k] = (bias[k] or 0) - 1 end
  end)
  -- contact AO: pixels sitting just above a nearer surface (inner corners) and the ground row
  local Z = o.Z
  if Z then
    m:each(function(x, y)
      local k = K(x, y)
      for dy = 1, 2 do
        local kb = K(x, y + dy)
        if Z[kb] and Z[k] and Z[kb] > Z[k] + 1.5 and face[k] == "front" then bias[k] = (bias[k] or 0) - (dy == 1 and 2 or 1) break end
      end
    end)
  end
  if o.ground then
    m:each(function(x, y)
      local k = K(x, y)
      if not m:has(x, y + 1) and face[k] == "front" then bias[k] = (bias[k] or 0) - 2
        if m:has(x, y - 1) then local k2 = K(x, y - 1) bias[k2] = (bias[k2] or 0) - 1 end end
    end)
  end
  local v = X.light(n, { amb = 0.05, wrap = 0.3 })
  local tok = o.tok or { r = { name = "box" .. seed } }
  local idx = X.tone(c, m, v, A.BOX, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
  -- waxy glints: a few brightest pixels on the top face (spaced)
  local sp2 = X.spec(n, 24)
  local cand = {}
  m:each(function(x, y) local k = K(x, y) if idx[k] == 6 and sp2[k] > 0.5 then cand[#cand + 1] = { x, y, sp2[k] + X.hash(x, y, seed + 11) * 0.3 } end end)
  table.sort(cand, function(a, b) return a[3] > b[3] end)
  local placed = {}
  for _, p in ipairs(cand) do
    if #placed >= (o.glints or 5) then break end
    local ok = true
    for _, q in ipairs(placed) do if abs(q[1] - p[1]) + abs(q[2] - p[2]) < 7 then ok = false break end end
    if ok then placed[#placed + 1] = p c:put(p[1], p[2], A.GLINT, tok) end
  end
  return idx, tok, n
end

-- ragged clipped silhouette: nibble 1px notches and add 1px leaf tufts on the upper edge
function A.ragged(m, face, Z, seed, amount)
  amount = amount or 0.22
  local add = {}
  m:each(function(x, y)
    if not m:has(x, y - 1) and m:has(x - 2, y) and m:has(x + 3, y) and not m:has(x - 2, y - 1) and X.hash(x, y, seed + 21) < amount * 0.35 then
      for i = 0, 1 + floor(X.hash(x, y, seed + 22) * 2) do if m:has(x + i, y) and not m:has(x + i, y - 1) then add[#add + 1] = { x + i, y - 1, K(x + i, y) } end end
    end
  end)
  for _, p in ipairs(add) do m:set(p[1], p[2]) local k = K(p[1], p[2]) face[k] = face[p[3]] Z[k] = Z[p[3]] end
end
-- round the screen-space corners of a mask's bbox (radius r) for a clipped, softened look
function A.roundCorners(m, r)
  local x0, y0, x1, y1 = m:bbox()
  local keep = HP.rrect(x0, y0, x1, y1, r)
  m:clip(keep)
end

-- woody stems glimpsed in the darkest gaps near the base
function A.twigs(c, m, idx, seed, tok)
  m:each(function(x, y)
    local k = K(x, y)
    if idx[k] == 1 and not m:has(x, y + 3) and X.hash(x, y, seed + 31) < 0.45 then c:put(x, y, A.TWIG, tok) end
  end)
end

-- shaded wood plank (rect) with grain; vertical=true runs grain down
function A.plank(c, x0, y0, x1, y1, o)
  o = o or {}
  local m = HP.rect(x0, y0, x1, y1)
  local n = X.pillow(m, o.R or 1.2)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  local tok = o.tok or { r = { name = "plank" } }
  local idx = X.tone(c, m, v, A.WOOD, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, bias = o.bias, tok = tok })
  -- grain: a broken dark line down the middle-ish + a lighter fleck
  local seed = o.seed or 5
  if o.vertical then
    local gx = x0 + floor((x1 - x0) / 2 + 0.5)
    for y = y0 + 1, y1 - 1 do
      if X.hash(gx, y, seed) < 0.75 and idx[K(gx, y)] and idx[K(gx, y)] > 2 then
        c:put(gx, y, A.WOOD[max(1, idx[K(gx, y)] - 1)], tok) end
    end
  else
    local gy = y0 + floor((y1 - y0) / 2 + 0.5)
    for x = x0 + 1, x1 - 1 do
      if X.hash(x, gy, seed) < 0.75 and idx[K(x, gy)] and idx[K(x, gy)] > 2 then
        c:put(x, gy, A.WOOD[max(1, idx[K(x, gy)] - 1)], tok) end
    end
  end
  return m, idx, tok
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
