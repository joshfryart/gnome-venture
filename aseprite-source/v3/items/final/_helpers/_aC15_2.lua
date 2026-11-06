-- _aC15_2.lua: private helpers for ph/lavender-border-end, -gate, -straight, -tee (final pass, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
-- Look: 3/4 view garden bed. Stone kerb (bevelled blocks, mortar joints, pits, one specular) round a crumbly soil top;
-- lavender bushes = grey-green needle-leaf mound (per-pixel light, 6 tones, leaf-tip comb, AO at the soil) with
-- slim violet spikes (1 px stem, whorled 3 px head, lit left / shade right, tip bud).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K, A.P = HP, X, K, G.P
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

A.SAGE  = { "#223c3a", "#335548", "#4b725d", "#6b9373", "#93b68f", "#c2d9ad" }
A.LAV   = { "#33265e", "#4f3b94", "#6c52bb", "#8f72d9", "#b59cf0", "#dccdff" }
A.STEM  = { "#2c4f43", "#4a7658", "#77a074" }
A.SOIL  = { "#341f26", "#4d2e2b", "#663e2f", "#7f5238", "#9a6a47", "#b9895f" }
A.STONE = { "#3b3a54", "#58586f", "#77778d", "#9b9aae", "#c3c1cf", "#e6e3ea" }
A.WOOD  = { "#4a2b2a", "#6b3d2f", "#8d5537", "#ae7046", "#cc905c", "#e8b982" }

local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.h(x, y, s) return X.hash(x, y, s or 0) end

-- 8-neighbour (square) dilation
function A.sqgrow(m, r)
  local cur = m:copy()
  for _ = 1, r or 1 do
    local nx = cur:copy()
    cur:each(function(x, y) for dy = -1, 1 do for dx = -1, 1 do nx:set(x + dx, y + dy) end end end)
    cur = nx
  end
  return cur
end

-- light a mask with a normal table, return idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
end

------------------------------------------------------------------ bed
-- soil: mask of the soil top. Builds kerb rim (2 px) + front face (FH px) extruded downward.
-- returns bed record {soil, rim, face, top, all, front (pixels to repaint over bushes), col = {k = hex}}
function A.bed(c, soil, o)
  o = o or {}
  local FH = o.fh or 4
  local rim = soil:grow(1)
  rim = A.sqgrow(rim, 1):cut(soil)
  local top = soil:copy():add(rim)
  local face = HP.mask()
  for d = 1, FH do face:add(top:shift(0, d)) end
  face:cut(top)
  local col, tok = {}, { r = { name = "bed" } }
  local function put(x, y, hex) col[K(x, y)] = hex c:put(x, y, hex, tok) end
  local SO, ST = A.SOIL, A.STONE
  local seed = o.seed or 1
  -- block joints: along x every `bw` px, offset by row band (rim vs face)
  local bw = o.bw or 7
  local function joint(x, off) return (x + off) % bw == 0 end
  -- soil
  soil:each(function(x, y)
    local i = 4
    if not soil:has(x, y - 1) then i = 2 elseif not soil:has(x, y - 2) then i = 3 end      -- shadow under back kerb
    if not soil:has(x - 1, y) and soil:has(x + 1, y) then i = min(i, 3) end
    local hh = A.h(x, y, seed)
    if hh < 0.10 then i = min(6, i + 2) elseif hh < 0.2 then i = max(1, i - 1) elseif hh > 0.93 then i = min(6, i + 1) end
    put(x, y, SO[i])
  end)
  -- kerb top
  rim:each(function(x, y)
    local i = 5
    local inner = soil:has(x, y + 1) or soil:has(x + 1, y) or soil:has(x - 1, y) or soil:has(x, y - 1)
    local outerTop = not top:has(x, y - 1)
    local outerLeft = not top:has(x - 1, y)
    local outerRight = not top:has(x + 1, y) and not face:has(x + 1, y)
    if inner then i = 4 end
    if outerTop or outerLeft then i = 6 end
    if outerRight then i = 3 end
    if soil:has(x, y + 1) and not soil:has(x, y - 1) then i = 4 end
    if joint(x, 0) then i = 2 elseif joint(x + 1, 0) and i < 6 then i = min(6, i + 1) end
    if A.h(x, y, seed + 7) < 0.07 then i = max(2, i - 1) end
    put(x, y, ST[i])
  end)
  -- face
  face:each(function(x, y)
    local dTop = 0
    while face:has(x, y - dTop - 1) do dTop = dTop + 1 end
    local below = face:has(x, y + 1)
    local i = 3
    if dTop == 0 then i = 4 end
    if not below then i = 1 elseif not face:has(x, y + 2) then i = 2 end
    if not face:has(x - 1, y) then i = min(6, i + 1) end
    if not face:has(x + 1, y) then i = max(1, i - 1) end
    local off = 3
    if joint(x, off) then i = 1 elseif joint(x + 1, off) and below then i = min(5, i + 1) elseif joint(x - 1, off) and below then i = max(1, i - 1) end
    if below and dTop > 0 and A.h(x, y, seed + 13) < 0.08 then i = max(1, i - 1) end
    put(x, y, ST[i])
  end)
  -- one specular glint on a kerb top block (left-most top-edge pixel pair that is lit)
  local best
  rim:each(function(x, y) if col[K(x, y)] == ST[6] and col[K(x + 1, y)] == ST[6] and (not best or x + y * 2 < best[1] + best[2] * 2) and x > (o.specMinX or 0) then best = { x, y } end end)
  if best and o.spec ~= false then c:put(best[1] + 1, best[2], A.CREAM, tok) col[K(best[1] + 1, best[2])] = A.CREAM end
  -- front = rim pixels directly under soil (2 rows) + whole face
  local front = HP.mask()
  rim:each(function(x, y) if soil:has(x, y - 1) or soil:has(x, y - 2) then front:set(x, y) end end)
  front:add(face)
  return { soil = soil, rim = rim, face = face, top = top, front = front, col = col, tok = tok }
end
-- repaint kerb front over anything drawn later (bushes tucked behind the front kerb)
function A.refront(c, bed, clip)
  bed.front:each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, bed.col[K(x, y)], bed.tok) end end)
end

------------------------------------------------------------------ lavender
-- spike from base (bx,by) to tip (tx,ty); head = top hl rows. tok shared per bush.
function A.spike(c, bx, by, tx, ty, hl, tok, cover)
  local L, S = A.LAV, A.STEM
  local n = max(1, by - ty)
  local headPix = HP.mask()
  for y = ty, by do
    local t = (y - ty) / n
    local x = floor(tx + (bx - tx) * t + 0.5)
    local r = y - ty
    local function p(xx, yy, hex) if not (cover and cover:has(xx, yy)) then c:put(xx, yy, hex, tok) headPix:set(xx, yy) end end
    if r < hl then
      if r == 0 then p(x, y, L[6])
      elseif r == 1 then p(x, y, L[5]) p(x + 1, y, L[3])
      else
        local lower = r > hl * 0.55
        local ph = r % 3
        if lower and ph == 0 then
          p(x, y, L[2])                                             -- neck between whorls
        else
          local top = (ph == 1)
          p(x - 1, y, top and L[5] or L[4])
          p(x, y, top and L[4] or L[3])
          p(x + 1, y, top and L[2] or L[1])
          if r == 2 then p(x - 1, y, L[6]) end
        end
      end
    else
      p(x, y, (r == hl) and S[1] or S[2])
      if r > hl and r < hl + 3 then p(x, y, S[3]) end
    end
  end
  return headPix
end

-- mound of needle-leaf foliage centred cx, base row by, half-width hw, height h
function A.mound(c, cx, by, hw, h, seed, o)
  o = o or {}
  local m = HP.mask()
  m:add(c:ellipse(cx, by, hw, h))
  m:add(c:ellipse(cx - hw * 0.45, by - 0.5, hw * 0.55, h * 0.78))
  m:add(c:ellipse(cx + hw * 0.5, by, hw * 0.5, h * 0.7))
  m:clip(c:rect(cx - 40, by - 40, cx + 40, by))
  -- leaf-tip comb along the top edge
  local x0, y0, x1, y1 = m:bbox()
  for x = x0 + 1, x1 - 1 do
    local top
    for y = y0, y1 do if m:has(x, y) then top = y break end end
    if top and (x + seed) % 3 == 0 then
      m:set(x, top - 1)
      if A.h(x, seed) > 0.5 then m:set(x, top - 2) end
    end
  end
  if o.cut then m:cut(o.cut) end
  local np = X.pillow(m, 2.5)
  local ns = X.sphere(cx - 0.5, by - h * 0.35, max(hw, h) + 1, m)
  local n = {}
  for k, a in pairs(np) do local b = ns[k] n[k] = { norm(a[1] * 0.45 + b[1] * 0.55, a[2] * 0.45 + b[2] * 0.55, a[3] * 0.45 + b[3] * 0.55) } end
  local bias = {}
  m:each(function(x, y) if y >= by then bias[K(x, y)] = -1 end end)
  local tok = { r = { name = "sage" } }
  local idx = A.shade(c, m, n, A.SAGE, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })
  -- needle strokes: lit leaf over a dark gap, short upright pairs
  m:each(function(x, y) local k = K(x, y)
    local i = idx[k]
    if i and i >= 2 and i <= 5 and y < by and m:has(x, y + 1) then
      local hh = A.h(x, y, seed + 3)
      if hh < 0.17 then c:put(x, y, A.SAGE[i + 1], tok) c:put(x, y + 1, A.SAGE[max(1, i - 1)], tok)
      elseif hh > 0.9 and i >= 4 then c:put(x, y, A.SAGE[6], tok) end              -- silvery bloom
    end
  end)
  return m, tok, idx
end

-- full bush: spikes (behind) then mound over their bases. sp = { {dx, lean, height, headLen}, ... }
function A.bush(c, cx, by, hw, h, sp, seed, o)
  o = o or {}
  local stok = { r = { name = "lav" } }
  local heads = HP.mask()
  for _, s in ipairs(sp) do
    local bx = cx + s[1]
    heads:add(A.spike(c, bx, by - h + 2, bx + s[2], by - s[3], s[4] or 7, stok, o.cover))
  end
  local m, tok = A.mound(c, cx, by, hw, h, seed, o)
  -- dark socket where each stem enters the mound
  for _, s in ipairs(sp) do
    local bx = cx + s[1]
    for y = by - h - 3, by do
      local t = (y - (by - s[3])) / max(1, (by - h + 2) - (by - s[3]))
      local x = floor(bx + s[2] + (bx - (bx + s[2])) * t + 0.5)
      if m:has(x, y) and not m:has(x, y - 1) then c:put(x, y, A.SAGE[2], tok) break end
    end
  end
  return m, heads
end

-- darken soil/kerb pixels just under a foliage mask (contact shadow)
function A.contact(c, bed, m)
  m:each(function(x, y)
    for d = 1, 1 do
      if not m:has(x, y + d) and bed.soil:has(x, y + d) then c:put(x, y + d, A.SOIL[1], bed.tok) end
    end
  end)
end

-- bee resting (x,y = body left), wings up
function A.bee(c, x, y)
  local P = A.P
  c:put(x + 1, y - 2, A.CREAM) c:put(x + 2, y - 2, "#e4f6ff") c:put(x + 1, y - 1, "#e4f6ff") c:put(x + 2, y - 1, "#b9e2f5")
  c:put(x, y, P.gold.hi) c:put(x + 1, y, A.INK) c:put(x + 2, y, P.gold.base) c:put(x + 3, y, A.INK)
  c:put(x, y + 1, P.gold.base) c:put(x + 1, y + 1, A.INK) c:put(x + 2, y + 1, P.gold.shade) c:put(x + 3, y + 1, "#8f4a1f")
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
