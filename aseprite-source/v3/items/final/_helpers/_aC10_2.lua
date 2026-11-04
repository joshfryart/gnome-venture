-- _aC10_2: helper for ph/greenhouse-2, greenhouse-3, greenhouse-lantern, greenhouse-mossy (Opus artist pass).
-- Read-only use of batch2/_b2g1.lua. Glasshouse kit: glass panes (gradient + reflection streaks, bright rim, AO under bars),
-- painted frame bars, stone/brick plinths with mortar + bevel, behind-glass bushes, pillow-lit volumes.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, sin, cos, pi, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.abs
local D = { G = G, HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
-- 6-tone ramps, dark -> light
D.GL    = { "#4a6aa6", "#6a96c8", "#8cbde2", "#b0dcf0", "#d4eff8", "#f0fbff" }   -- clear glass
D.GLG   = { "#3a6a62", "#58907a", "#7cb08c", "#a2cc9e", "#c8e4b4", "#ecf6d6" }   -- old green glass
D.GLW   = { "#8a4a2a", "#c0702a", "#e89a36", "#f7c24e", "#ffe07e", "#fff4c0" }   -- lamp-lit glass
D.FR    = { "#45435f", "#6b6a88", "#9a9bb2", "#c6c8d8", "#e6e8f0", "#fbf8f0" }   -- white-painted frame
D.IRON  = { "#1f1a2c", "#2f2a42", "#433d5c", "#5c5778", "#7e7a9a", "#aeacc6" }
D.STONE = { "#3f4060", "#5c5d78", "#7d7e94", "#9fa0b2", "#c2c2cf", "#e2e1e8" }
D.WST   = { "#463a4a", "#665662", "#8a7a7e", "#ab9c96", "#cbbfb2", "#e8e0d2" }   -- warm stone
D.BRICK = { "#561d2c", "#7c2a30", "#a63c34", "#c9583e", "#e37e56", "#f6a87a" }
D.WOOD  = { "#3e2526", "#5a3529", "#7e4c33", "#a06a42", "#c48d58", "#e2b47e" }
D.LEAF  = { "#1d4a40", "#2a6648", "#3d8650", "#5ea85a", "#8cc96a", "#bfe28a" }
D.MOSS  = { "#24442e", "#35603a", "#4f8040", "#73a24a", "#9cc35a", "#cfe082" }
D.RED   = { "#5e1a30", "#9a2634", "#d23c34", "#f0623e", "#ff9a6a", "#ffd6b0" }
D.GOLD  = { "#6e3a1e", "#a35a1c", "#d9861e", "#f5b82e", "#ffdc6a", "#fff3b4" }

D.frames = {}  -- frame tokens (for glass rim / AO pass)
function D.tok(name, frame) local t = { r = { name = name } } if frame then D.frames[t] = true end return t end
function D.new(name) D.frames = {} return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function D.find(ramp, hex) for i, h in ipairs(ramp) do if h:lower() == (hex or ""):lower() then return i end end end
function D.shift(c, x, y, ramp, d)
  local i = D.find(ramp, c:get(x, y)) if i then c:put(x, y, ramp[max(1, min(#ramp, i + d))], c.own[y * c.w + x]) end
end
function D.own(c, x, y) if x < 0 or y < 0 or x >= c.w or y >= c.h then return nil end return c.own[y * c.w + x] end
function D.vol(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2)
  local tok = o.tok or D.tok(o.name or "vol", o.frame)
  local idx = G.toneN(c, m, n, ramp, { tok = tok, amb = o.amb or 0.1, wrap = o.wrap or 0.3, cuts = o.cuts, bias = o.bias })
  return tok, idx, n
end
function D.fill(c, m, hex, tok) m:each(function(x, y) c:put(x, y, hex, tok) end) end

-- glass: vertical/horizontal gradient + "/" reflection streaks. o.ramp, o.period, o.phase, o.base, o.tok
function D.glass(c, m, o)
  o = o or {}
  local R = o.ramp or D.GL
  local x0, y0, x1, y1 = m:bbox()
  local tok = o.tok or D.tok("glass")
  local P = o.period or 14
  m:each(function(x, y)
    local fy = (y - y0) / max(1, y1 - y0)
    local fx = (x - x0) / max(1, x1 - x0)
    local v = (o.base or 0.6) - 0.26 * fy - 0.2 * fx
    local s = (x + y + (o.phase or 0)) % P
    if s < 2 then v = v + 0.3 elseif s == 2 then v = v + 0.15 elseif s == 6 and o.thin ~= false then v = v + 0.17 end
    local i = max(1, min(#R, floor(v * #R) + 1))
    c:put(x, y, R[i], tok)
  end)
  return tok
end
-- bright rim (frame to the left), AO under bars (frame above), slight dark on right edge
function D.rims(c, gtok, R)
  local ch = {}
  for i, ow in pairs(c.own) do if ow == gtok then
    local x, y = i % c.w, i // c.w
    local d = 0
    if D.frames[D.own(c, x, y - 1)] then d = d - 1 end
    if D.frames[D.own(c, x - 1, y)] then d = d + 1 end
    if D.frames[D.own(c, x + 1, y)] and d == 0 then d = -1 end
    if d ~= 0 then ch[#ch + 1] = { x, y, d } end
  end end
  for _, q in ipairs(ch) do D.shift(c, q[1], q[2], R, q[3]) end
end
-- frame bars. vertical: w=1 -> FR[4] (+lit top), w=2 -> left FR[5], right FR[3]
function D.vbar(c, x, y0, y1, w, tok, R)
  R = R or D.FR tok = tok or D.tok("frame", true)
  for y = y0, y1 do
    if (w or 1) >= 2 then c:put(x, y, R[5], tok) c:put(x + 1, y, R[3], tok)
      if w >= 3 then c:put(x + 2, y, R[2], tok) end
    else c:put(x, y, R[4], tok) end
  end
  return tok
end
function D.hbar(c, x0, x1, y, h, tok, R)
  R = R or D.FR tok = tok or D.tok("frame", true)
  for x = x0, x1 do
    if (h or 1) >= 2 then c:put(x, y, R[5], tok) c:put(x, y + 1, R[3], tok)
      if h >= 3 then c:put(x, y + 2, R[2], tok) end
    else c:put(x, y, R[4], tok) end
  end
  return tok
end
-- slanted 1px bar from (ax,ay) to (bx,by)
function D.sbar(c, ax, ay, bx, by, tone, tok, R)
  R = R or D.FR tok = tok or D.tok("frame", true)
  local m = HP.line({ { ax, ay }, { bx, by } }, 1)
  m:each(function(x, y) c:put(x, y, R[tone or 4], tok) end)
  return tok, m
end
-- stone/brick wall block courses. o.bh (course height incl. mortar), o.bw {min,max}, o.seed, o.ao (dark top row)
function D.blocks(c, x0, y0, x1, y1, R, o)
  o = o or {}
  local tok = o.tok or D.tok(o.name or "stone")
  local bh = o.bh or 4
  local row = 0
  for yy = y0, y1, bh do
    local x = x0 - ((row % 2 == 1) and floor((o.bw and o.bw[1] or 6) / 2) or 0)
    local seedn = 0
    while x <= x1 do
      seedn = seedn + 1
      local wmin, wmax = (o.bw or { 6, 9 })[1], (o.bw or { 6, 9 })[2]
      local w = wmin + floor(X.hash(seedn, row, o.seed or 3) * (wmax - wmin + 1))
      local bx0, bx1 = x, x + w - 2
      local by0, by1 = yy, min(y1, yy + bh - 2)
      local tint = (X.hash(seedn, row, (o.seed or 3) + 9) < 0.3) and -1 or 0
      for py = yy, min(y1, yy + bh - 1) do for px = max(x0, x), min(x1, x + w - 1) do
        local hex
        if px == x + w - 1 or py == yy + bh - 1 then hex = R[2]                -- mortar
        else
          local i = 4 + tint
          if py == by0 or px == bx0 then i = i + 1 end                        -- lit bevel top/left
          if py == by1 or px == bx1 then i = i - 1 end                        -- shade bevel bottom/right
          if px == bx1 and py == by1 then i = i - 1 end
          if X.hash(px, py, o.seed or 3) < 0.07 then i = i - 1 end           -- pits
          hex = R[max(1, min(#R, i))]
        end
        c:put(px, py, hex, tok)
      end end
      x = x + w
    end
    row = row + 1
  end
  -- edge corner rounding (shade side) and AO under the ledge
  for y = y0, y1 do D.shift(c, x1, y, R, -1) end
  if o.ao ~= false then for x = x0, x1 do D.shift(c, x, y0, R, -1) end end
  return tok
end
-- ledge / sill: top row hi, second row base, then dark undercut
function D.ledge(c, x0, x1, y, R, tok)
  tok = tok or D.tok("ledge", true)
  for x = x0, x1 do
    c:put(x, y, R[6], tok) c:put(x, y + 1, R[4], tok)
  end
  c:put(x1, y, R[5], tok) c:put(x1, y + 1, R[3], tok) c:put(x0, y + 1, R[5], tok)
  return tok
end
-- behind-glass bush row: blobs, pillow lit, clipped. returns mask
function D.bush(c, x0, x1, yb, hmax, clip, o)
  o = o or {}
  local m = HP.mask()
  local i = 0
  local x = x0 + 1
  while x <= x1 - 1 do
    i = i + 1
    local h = hmax * (0.6 + 0.4 * X.hash(i, 7, o.seed or 1))
    local r = 2.2 + X.hash(i, 3, o.seed or 1) * 1.2
    m:add(G.rell(x, yb - h + r, 1, 0, r, r))
    m:add(HP.rect(floor(x - r), floor(yb - h + r), floor(x + r), yb))
    x = x + 3 + floor(X.hash(i, 5, o.seed or 1) * 2)
  end
  m:clip(HP.rect(x0, 0, x1, yb))
  if clip then m:clip(clip) end
  local bias = {}
  m:each(function(xx, yy) if yy >= yb - 1 then bias[K(xx, yy)] = -2 elseif yy >= yb - 3 then bias[K(xx, yy)] = -1 end end)
  local tok = D.tok("bush")
  local idx = D.vol(c, m, o.ramp or D.LEAF, 2.2, { tok = tok, amb = 0.12, wrap = 0.35, bias = bias })
  -- leaf clefts: tiny darker ticks
  m:each(function(xx, yy) if X.hash(xx, yy, 77) < 0.1 and m:has(xx, yy + 1) and yy < yb - 2 then D.shift(c, xx, yy, o.ramp or D.LEAF, -1) end end)
  -- fruit
  if o.fruit then
    local n = 0
    m:each(function(xx, yy)
      if X.hash(xx, yy, o.seed or 1) < (o.fdens or 0.05) and yy < yb - 2 and m:has(xx + 1, yy + 1) and m:has(xx - 1, yy) then
        n = n + 1
        local F = o.fruit
        c:put(xx, yy, F[5], tok) c:put(xx + 1, yy, F[4], tok)
        c:put(xx, yy + 1, F[3], tok) c:put(xx + 1, yy + 1, F[2], tok)
      end
    end)
  end
  return m, tok
end
function D.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return D
