-- _aC15_1.lua: private helpers for ph/laterite-clay, ph/lavender-border, -corner, -cross (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- ramps (dark .. light)
A.PUR  = { "#2e1f4f", "#4b3488", "#6d4fbc", "#9273d8", "#bba0ee", "#e2d2ff" }
A.LAV  = { "#203a37", "#33584f", "#4f7b66", "#729e83", "#9cc19f", "#cbe2bb" }
A.STEM = { "#2d4f43", "#4c7a5c", "#78a873" }
A.WOOD = { "#3e2420", "#5a3426", "#7e4b31", "#a86a40", "#c98d58", "#e9b97f" }
A.SOIL = { "#24171b", "#3a2324", "#55322a", "#734634" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

function A.ellm(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / (rx + 0.4)) ^ 2 + ((y - cy) / (ry + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

-- lavender spike: stem from (x, yb) up h px; leans `lean` px at the top; head hd rows
function A.spike(c, x, yb, h, lean, hd)
  hd = hd or 7
  local P, S = A.PUR, A.STEM
  local function xo(y) return x + floor(lean * (yb - y) / h + 0.5) end
  local top = yb - h
  for y = top + hd, yb do
    local xx = xo(y)
    c:put(xx, y, (y > yb - 3) and S[1] or S[2])
  end
  -- one tiny paired leaf low on the stem
  local ly = yb - floor(h * 0.45)
  c:put(xo(ly) - 1, ly, S[3]) c:put(xo(ly) + 1, ly + 1, S[1])
  -- head: whorls (3 wide) separated by 1px necks, tapering tip
  local pat = { 1, 3, 3, 1, 3, 3, 1, 3, 3 }
  for i = 0, hd - 1 do
    local y = top + i
    local xx = xo(y)
    local w = pat[i + 1] or 3
    local low = (i >= hd - 2) and 1 or 0   -- lower whorl a step darker (closer to the foliage)
    if i == 0 then c:put(xx, y, P[5])
    elseif w == 1 then c:put(xx, y, P[2])
    else
      local first = (i <= 2)
      c:put(xx - 1, y, P[(first and 6 or 5) - low])
      c:put(xx, y, P[4 - low])
      c:put(xx + 1, y, P[(i % 3 == 2) and 2 or 3])
    end
  end
end

-- grey-green needle mound centred (cx, cy); returns mask
function A.mound(c, cx, cy, rx, ry, seed)
  local m = A.ellm(cx, cy, rx, ry)
  -- needle tips poking up along the top edge
  for x = floor(cx - rx) + 1, floor(cx + rx) - 1 do
    local ytop
    for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do if m:has(x, y) then ytop = y break end end
    if ytop and X.hash(x, 3, seed) > 0.45 then m:set(x, ytop - 1) end
  end
  local n = X.pillow(m, 2.6)
  local ns = X.sphere(cx, cy, max(rx, ry), m)
  for k, v in pairs(n) do local s = ns[k] n[k] = { G.norm(v[1] * 0.5 + s[1] * 0.5, v[2] * 0.5 + s[2] * 0.5, v[3] * 0.5 + s[3] * 0.5) } end
  local bias = {}
  m:each(function(x, y) if not m:has(x, y + 1) or not m:has(x, y + 2) then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, A.LAV, { bias = bias })
  -- needle strokes: short darker dashes with a lit tip above
  m:each(function(x, y) local k = K(x, y)
    if idx[k] >= 3 and m:has(x, y - 1) and m:has(x, y + 1) and X.hash(x, y, seed + 7) < 0.2 then
      c:put(x, y, A.LAV[idx[k] - 1]) c:put(x, y - 1, A.LAV[min(6, idx[k] + 1)])
    end
  end)
  return m
end

-- a clump: spikes behind, mound over their bases
function A.clump(c, cx, cy, o)
  o = o or {}
  local seed = o.seed or (cx * 7 + cy)
  local hs = o.hs or { 11, 14, 12 }
  local offs = o.offs or { -3, 0, 3 }
  local leans = o.leans or { -2, 0, 2 }
  for i = 1, #hs do
    A.spike(c, cx + offs[i], cy - 1, hs[i], leans[i], o.hd and o.hd[i] or (hs[i] > 12 and 8 or 7))
  end
  return A.mound(c, cx, cy, o.rx or 4, o.ry or 2.6, seed)
end

-- raised bed in 3/4 view. rects = top faces {x0,y0,x1,y1}; depth = front wall height.
-- returns top, soil, wall masks
function A.bed(c, rects, depth)
  local W, S = A.WOOD, A.SOIL
  local top = HP.mask()
  for _, r in ipairs(rects) do top:add(c:rect(r[1], r[2], r[3], r[4])) end
  local wall = HP.mask()
  for d = 1, depth do wall:add(top:shift(0, d)) end
  wall:cut(top)
  local soil = top:shrink(2)
  local frame = top:copy():cut(soil)
  -- wall: plank rows, end posts, nails, AO at inner corners and at the ground row
  wall:each(function(x, y)
    local d = 0
    while not top:has(x, y - d) and d <= depth + 1 do d = d + 1 end
    local t
    if d == 1 then t = 5
    elseif d == depth then t = 2
    else t = (d % 3 == 0) and 3 or 4 end
    if top:has(x - 1, y) or top:has(x - 2, y) then t = t - 1 end         -- shadow tucked under the arm beside it
    if not wall:has(x - 1, y) and d > 1 then t = min(6, t + 1) end       -- lit left end
    if not wall:has(x + 1, y) then t = max(1, t - 1) end                -- shade right end
    if d > 1 and d < depth and X.hash(x // 3, y, 11) < 0.22 and t >= 3 then t = t - 1 end  -- grain dashes
    c:put(x, y, W[max(1, min(6, t))])
  end)
  -- plank joints with a nail head
  wall:each(function(x, y)
    if (x % 13 == 0) and wall:has(x - 1, y) and wall:has(x + 1, y) then
      local d = 0 while not top:has(x, y - d) and d <= depth + 1 do d = d + 1 end
      if d > 1 and d < depth then c:put(x, y, W[2]) end
      if d == 2 then c:put(x + 1, y, "#d8d4e0") end
    end
  end)
  -- frame (top of the planks): lit outer top/left edges, shaded inner lip
  frame:each(function(x, y)
    local t = 4
    if not top:has(x, y - 1) or not top:has(x - 1, y) then t = 6
    elseif not top:has(x + 1, y) or not top:has(x, y + 1) then t = 4
    else t = 5 end
    if soil:has(x, y + 1) or soil:has(x + 1, y) then t = 3 end        -- inner lip falls into shadow
    if t == 5 and X.hash(x, y // 2, 5) < 0.18 then t = 4 end            -- grain
    c:put(x, y, W[t])
  end)
  -- end-grain squares at the outer corners
  for _, r in ipairs(rects) do
    for _, p in ipairs{ { r[1], r[2] }, { r[3] - 1, r[2] } } do
      if not top:has(p[1] - 1, p[2]) and not top:has(p[1], p[2] - 1) or not top:has(p[1] + 2, p[2]) and not top:has(p[1] + 1, p[2] - 1) then
        c:put(p[1], p[2], W[6]) c:put(p[1] + 1, p[2], W[5]) c:put(p[1], p[2] + 1, W[5]) c:put(p[1] + 1, p[2] + 1, W[4])
      end
    end
  end
  -- soil: AO under the far lip, crumbs
  soil:each(function(x, y)
    local t = 3
    if not soil:has(x, y - 1) then t = 1 elseif not soil:has(x, y - 2) or not soil:has(x - 1, y) then t = 2 end
    if t == 3 and X.hash(x, y, 9) < 0.12 then t = 4 end
    c:put(x, y, S[t])
  end)
  return top, soil, wall
end

-- tiny garden snail (shell spiral, cream body), (x,y) = shell top-left, faces left
function A.snail(c, x, y)
  local map = {
    ".kkk.",
    "kbhak",
    "kadbk",
    "kbaak",
  }
  local C = { k = A.INK, h = "#ffd38a", a = "#e3923a", b = "#b45f2a", d = "#6e3424" }
  for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if C[ch] then c:put(x + xx - 1, y + yy - 1, C[ch]) end end end
  -- foot + head + stalk eyes
  for i = -3, 5 do c:put(x + i, y + 4, (i < 0) and "#efe0c0" or "#cdb592") end
  c:put(x - 3, y + 3, "#efe0c0") c:put(x - 4, y + 2, "#cdb592") c:put(x - 2, y + 2, "#cdb592")
end

-- tiny bee (hover), (x,y) = left of body
function A.bee(c, x, y)
  local P = { "#f5b82e", A.INK, "#f5b82e", A.INK, "#d98322" }
  for i = 0, 4 do c:put(x + i, y, P[i + 1]) end
  c:put(x, y - 1, "#ffe38a") c:put(x + 1, y + 1, "#d98322") c:put(x + 3, y + 1, "#8f4a1f")
  c:put(x + 1, y - 1, "#e4f6ff") c:put(x + 2, y - 2, "#e4f6ff") c:put(x + 3, y - 2, "#b9e2f5") c:put(x + 2, y - 1, "#b9e2f5")
end

return A
