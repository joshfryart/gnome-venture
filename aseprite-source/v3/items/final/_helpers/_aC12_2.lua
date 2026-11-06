-- _aC12_2.lua: private helpers for ph/holly-hedge-straight, holly-hedge-tee, hollyhock-seed, honeydew (final, Opus single pass).
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

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- round body: pillow + sphere blend
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = A.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or A.CUTS), tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

-- plot a polyline of 1px points
function A.line(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      c:put(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5), hex, tok) end
  end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- 3/4-view holly hedge: top (lit, faces up) + front (faces viewer, darker) masks. Voronoi of cupped holly leaves,
-- spines poking out of the top/side silhouette, AO toward the base. o.ao = extra bias table, o.seed hash seed.
A.HLEAF = { "#0f2a26", "#173f32", "#1f5a3c", "#2d7845", "#4c9a4f", "#86c467" }
function A.hedge(c, top, front, o)
  o = o or {}
  local LEAF, SPEC = A.HLEAF, "#dff5c4"
  local ltok = o.tok or { r = { name = "leaf" } }
  local base = top:copy():add(front)
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  base:each(function(x, y) bx0, by0, bx1, by1 = min(bx0, x), min(by0, y), max(bx1, x), max(by1, y) end)
  local leaves, row = {}, 0
  for y = by0, by1 + 1, 3.4 do
    row = row + 1
    for x = bx0 - 1 + (row % 2) * 2.5, bx1 + 1, 5.0 do
      local i = #leaves + 1
      local s = o.seed or 0
      local a = (X.hash(i, row, 3 + s) - 0.5) * 2.4 + (row % 2) * 0.5
      leaves[i] = { x = x + (X.hash(i, row, 1 + s) - 0.5) * 1.6, y = y + (X.hash(i, row, 2 + s) - 0.5) * 1.2,
        ux = cos(a), uy = sin(a), tx = (X.hash(i, row, 4 + s) - 0.5) * 0.7, ty = (X.hash(i, row, 5 + s) - 0.5) * 0.6 }
    end
  end
  -- spines: only from leaves touching the top or side silhouette (not the base)
  local hedge = base:copy()
  local grow2 = base:grow(2)
  local spineMaxY = o.spineMaxY or (by1 - 4)
  for _, L in ipairs(leaves) do
    local cx, cy = floor(L.x + 0.5), floor(L.y + 0.5)
    if base:has(cx, cy) and cy < spineMaxY then
      local near = false
      for dy = -2, 2 do for dx = -2, 2 do if not base:has(cx + dx, cy + dy) then near = true end end end
      if near then
        for _, p in ipairs{ { 4.4, 0 }, { -4.4, 0 }, { 1.8, 2.9 }, { 1.8, -2.9 }, { -1.8, 2.9 }, { -1.8, -2.9 } } do
          local px, py = L.x + L.ux * p[1] - L.uy * p[2], L.y + L.uy * p[1] + L.ux * p[2]
          local xi, yi = floor(px + 0.5), floor(py + 0.5)
          if yi < spineMaxY and not base:has(xi, yi) and grow2:has(xi, yi) then
            hedge:set(xi, yi)
            local mx, my = floor(L.x + (px - L.x) * 0.72 + 0.5), floor(L.y + (py - L.y) * 0.72 + 0.5)
            if base:grow(1):has(mx, my) then hedge:set(mx, my) end
          end
        end
      end
    end
  end
  -- form normal: top tilts up/back, front faces viewer and slightly down; clipped edges rounded by pillows
  local nt = X.pillow(top:copy():add(hedge:copy():cut(front)), 3)
  local nf = X.pillow(front, 3)
  local isTop = {}
  hedge:each(function(x, y) if not front:has(x, y) then isTop[K(x, y)] = true end end)
  local nrm, bias, own, LU, LV = {}, {}, {}, {}, {}
  hedge:each(function(x, y) local k = K(x, y)
    local d1, d2, b1 = 1e9, 1e9, nil
    for i, L in ipairs(leaves) do
      local dx, dy = x + 0.5 - L.x, y + 0.5 - L.y
      if abs(dx) < 8 and abs(dy) < 8 then
        local u, v = dx * L.ux + dy * L.uy, -dx * L.uy + dy * L.ux
        local d = sqrt((u / 3.2) ^ 2 + (v / 1.9) ^ 2)
        if d < d1 then d2 = d1 d1, b1 = d, i elseif d < d2 then d2 = d end
      end
    end
    local L = leaves[b1]
    own[k] = b1
    local dx, dy = x + 0.5 - L.x, y + 0.5 - L.y
    local u, v = dx * L.ux + dy * L.uy, -dx * L.uy + dy * L.ux
    LU[k], LV[k] = u, v
    local g
    if isTop[k] then local q = nt[k] or { 0, 0, 1 } g = { q[1] * 0.8, q[2] * 0.8 - 0.85, q[3] }
    else local q = nf[k] or { 0, 0, 1 } g = { q[1] * 0.8, q[2] * 0.6 + 0.5, q[3] } end
    local px, py = -L.uy * v * 0.22, L.ux * v * 0.22
    nrm[k] = { norm(g[1] + L.tx + px, g[2] + L.ty + py, g[3]) }
    if d2 - d1 < 0.2 then bias[k] = -2 end
    if o.ao and o.ao[k] then bias[k] = (bias[k] or 0) + o.ao[k] end
  end)
  -- AO toward the base of each front face
  if o.baseAO then o.baseAO(bias, hedge) end
  local idx, val = A.shade(c, hedge, nrm, LEAF, { amb = 0.08, wrap = 0.22, bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.65, 0.8 } })
  hedge:each(function(x, y) local k = K(x, y)
    if (bias[k] or 0) <= -2 then return end
    local u, v = LU[k], LV[k]
    if abs(v) < 0.45 and abs(u) < 2.5 and idx[k] < 6 then c:put(x, y, LEAF[min(6, idx[k] + 1)], ltok)
    elseif val[k] > 0.78 and v < -0.4 and v > -1.5 and abs(u) < 1.4 and X.hash(own[k], 1, 9) > 0.45 then c:put(x, y, SPEC, ltok) end
  end)
  return hedge, ltok, idx
end

-- 4 px holly berry with glint + contact shadow on the leaves
local RB = { d = "#5c0f22", s = "#9a1a2c", b = "#d42a35", h = "#ff6a5a", g = "#fff0d8" }
local BER = { ".hb.", "hgbs", "bbsd", ".sd." }
A.rtok = { r = { name = "berry" } }
function A.berry(c, hedge, ltok, x0, y0)
  for _, p in ipairs{ { 4, 2 }, { 4, 3 }, { 3, 4 }, { 2, 4 } } do
    local x, y = x0 + p[1], y0 + p[2]
    if hedge:has(x, y) and c.own[y * 64 + x] ~= A.rtok then c:put(x, y, A.HLEAF[1], ltok) end
  end
  for r, rowS in ipairs(BER) do for i = 1, 4 do local ch = rowS:sub(i, i)
    if RB[ch] then c:put(x0 + i - 1, y0 + r - 1, RB[ch], A.rtok) end end end
end
function A.cluster(c, hedge, ltok, x, y) A.berry(c, hedge, ltok, x, y) A.berry(c, hedge, ltok, x + 5, y + 1) A.berry(c, hedge, ltok, x + 2, y + 4) end

-- paint a char map
function A.paint(c, rows, x0, y0, map, tok)
  for r, rowS in ipairs(rows) do for i = 1, #rowS do local ch = rowS:sub(i, i)
    if map[ch] then c:put(x0 + i - 1, y0 + r - 1, map[ch], tok) end end end
end
return A
