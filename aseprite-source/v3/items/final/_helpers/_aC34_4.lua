-- _aC34_4: private jar/pickle helper for chunk C34 (Opus artist pass). Read-only use of batch2/_b2g1.lua (-> batch1).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local A = { G = G, HP = HP, X = X, K = K }
A.GL = { "#3c6a9c", "#5f94c4", "#8cc0e2", "#b6e0f2", "#dcf3fb", "#f6fdff" }
A.SPEC = "#fffbea"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name)
  A.name = name
  A.c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  A.occ = HP.mask()
  A.info = {}
  return A.c
end

-- record + paint tone indices
local function paint(m, idx, ramp, tok)
  local c = A.c
  for k, i in pairs(idx) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    if m:has(x, y) then c:put(x, y, ramp[i], tok) A.info[k] = { ramp = ramp, i = i } end
  end
end
function A.darken(x, y, n)
  local inf = A.info[K(x, y)]
  if not inf then return end
  inf.i = max(1, inf.i - (n or 1))
  A.c:put(x, y, inf.ramp[inf.i])
end
function A.set(x, y, i)
  local inf = A.info[K(x, y)]
  if not inf then return end
  inf.i = max(1, min(#inf.ramp, i))
  A.c:put(x, y, inf.ramp[inf.i])
end

-- shade mask m with normals n (or pillow radius) using 6-tone ramp. o: amb, wrap, cuts, bias, clip, nocontact, spec
function A.part(m, n, ramp, o)
  o = o or {}
  if o.clip then m:clip(o.clip) end
  if m:count() == 0 then return m, {} end
  if type(n) == "number" or n == nil then n = X.pillow(m, n or 2.5) end
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local bias = o.bias or {}
  if o.ao then for _, a in ipairs(o.ao) do X.ao(bias, m, a[1], a[2] or 1, a[3] or -1) end end
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0
    local i = 1
    for j, t in ipairs(o.cuts or A.CUTS) do if val >= t then i = j + 1 end end
    if bias[k] then i = i + bias[k] end
    idx[k] = max(1, min(#ramp, i))
  end)
  paint(m, idx, ramp, o.tok)
  if o.edge then
    -- 1px separation line in the part's own dark tones: deep on the shade side, shade on the lit side
    m:edge():each(function(x, y)
      local k = K(x, y)
      local lit = (not m:has(x - 1, y)) or (not m:has(x, y - 1))
      local shd = (not m:has(x + 1, y)) or (not m:has(x, y + 1))
      local tgt = shd and 1 or (lit and (o.edge == 2 and 3 or 2) or 2)
      if idx[k] > tgt then A.set(x, y, tgt) idx[k] = tgt end
    end)
  end
  if not o.nocontact then
    -- contact shadow on what is behind (lower/right of the new part), separation line where same ramp touches
    local front = m
    front:edge():each(function(x, y)
      for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 }, { -1, 0 }, { 0, -1 } } do
        local qx, qy = x + d[1], y + d[2]
        if not front:has(qx, qy) and A.occ:has(qx, qy) then
          local back = A.info[K(qx, qy)]
          if d[1] >= 0 and d[2] >= 0 then A.darken(qx, qy, 2) end
          if back and back.ramp == ramp then A.set(x, y, min(idx[K(x, y)], 2)) end
        end
      end
    end)
  end
  if o.spec then
    local s = X.spec(n, o.spec)
    local bk, bv = nil, -1
    for k, sv in pairs(s) do if m.s[k] and sv > bv then bk, bv = k, sv end end
    if bk then local x, y = bk % 1024 - 256, bk // 1024 - 256 A.c:put(x, y, o.specHex or A.SPEC) end
  end
  A.occ:add(m)
  return m, idx, n
end

-- jar: o.pts = {{y, halfwidth}, ...}, o.cx, o.level, o.brine (6 ramp, dark->light). Paints glass back + brine.
function A.jar(o)
  local c, cx, pts = A.c, o.cx or 32, o.pts
  local function hw(y)
    for i = 1, #pts - 1 do
      local a, b = pts[i], pts[i + 1]
      if y >= a[1] and y <= b[1] then
        local t = (y - a[1]) / max(1, b[1] - a[1])
        if o.smooth ~= false then t = t * t * (3 - 2 * t) end
        return a[2] + (b[2] - a[2]) * t
      end
    end
    return pts[#pts][2]
  end
  local y0, y1 = pts[1][1], pts[#pts][1]
  local body = HP.mask()
  for y = y0, y1 do local w = floor(hw(y) + .5) for x = cx - w, cx + w - 1 do body:set(x, y) end end
  local inside = body:shrink(1)
  local base = HP.mask() -- thick glass foot
  inside:each(function(x, y) if y >= y1 - 2 then base:set(x, y) end end)
  inside:cut(base)
  local GL = A.GL
  local J = { body = body, inside = inside, y0 = y0, y1 = y1, cx = cx, hw = hw, level = o.level or (y0 + 6), base = base }
  local wall = body:copy():cut(inside):cut(base)
  wall:each(function(x, y)
    local col = x < cx and GL[4] or GL[2]
    if x >= cx + floor(hw(y) + .5) - 1 then col = GL[2] end
    if x == cx - floor(hw(y) + .5) then col = GL[4] end
    if y == y1 then col = x < cx - 2 and GL[3] or GL[2] end
    c:put(x, y, col)
  end)
  base:each(function(x, y)
    local col = (y == y1 - 2) and GL[5] or (x < cx and GL[4] or GL[3])
    if y == y1 - 1 and x > cx + 2 then col = GL[2] end
    c:put(x, y, col)
  end)
  local br = o.brine
  local air, liq = HP.mask(), HP.mask()
  inside:each(function(x, y) if y < J.level then air:set(x, y) else liq:set(x, y) end end)
  air:each(function(x, y) c:put(x, y, x < cx - 1 and "#eaf8fc" or (x < cx + hw(y) - 3 and "#d4eef7" or "#b0d8ea")) end)
  local n = {}
  liq:each(function(x, y)
    local w = max(1, hw(y) - 1)
    local t = max(-.95, min(.95, (x - cx + .5) / w))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = 0.3, wrap = 0.5 })
  X.tone(c, liq, v, br, { cuts = { 0.25, 0.4, 0.55, 0.72, 0.88 }, bias = (function()
    local b = {} liq:each(function(x, y) if y >= y1 - 5 then b[K(x, y)] = -1 end end) return b end)() })
  -- meniscus
  liq:each(function(x, y)
    if y == J.level then c:put(x, y, br[6]) end
    if y == J.level + 1 then c:put(x, y, x < cx + 2 and br[5] or br[4]) end
  end)
  J.liq, J.air, J.brine = liq, air, br
  A.occ = HP.mask()
  A.info = {}
  return J
end

-- glass front: left specular streak (broken), second faint streak, right cool bounce, bottom glint
function A.glassFront(J, o)
  o = o or {}
  local c = A.c
  local function leftIn(y) for x = J.cx - 40, J.cx do if J.inside:has(x, y) then return x end end end
  local function rightIn(y) for x = J.cx + 40, J.cx, -1 do if J.inside:has(x, y) then return x end end end
  local gaps = o.gaps or {}
  for y = J.y0 + (o.top or 3), J.y1 - 5 do
    local x = leftIn(y)
    local gap = false
    for _, g in ipairs(gaps) do if y >= g[1] and y <= g[2] then gap = true end end
    if x and not gap then
      c:put(x + 1, y, A.SPEC)
      if o.wide and y > J.y0 + (o.top or 3) + 2 and y < J.y0 + (o.top or 3) + o.wide then c:put(x + 2, y, "#e4f6ff") end
    end
    local xr = rightIn(y)
    if xr and y > J.level + 2 and y % 4 ~= 1 then c:put(xr, y, o.bounce or "#9ad6e8") end
  end
  if o.dot then c:put(o.dot[1], o.dot[2], A.SPEC) end
end

-- vertical cylinder band (lids, collars) with 6 ramp; o.ridges spacing
function A.vband(m, x0, x1, ramp, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.95, min(.95, ((x + .5 - x0) / (x1 - x0 + 1)) * 2 - 1))
    local ny = 0
    if o.round then ny = o.round(x, y) end
    n[K(x, y)] = { t, ny, sqrt(max(0.05, 1 - t * t - ny * ny)) }
  end)
  return A.part(m, n, ramp, { amb = o.amb or 0.1, wrap = o.wrap or 0.3, cuts = o.cuts, nocontact = o.nocontact, bias = o.bias })
end

function A.ln(x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then A.c:put(x, y, hex) end
  end
end
function A.ell(cx, cy, rx, ry, ang)
  local m = HP.mask() ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local R = math.ceil(max(rx, ry)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- ellipsoid normals for an ellipse mask
function A.ellN(m, cx, cy, rx, ry, ang)
  ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local n = {}
  m:each(function(x, y)
    local dx, dy = x + .0 - cx, y + .0 - cy
    local u, v = (dx * ca + dy * sa) / (rx + .5), (-dx * sa + dy * ca) / (ry + .5)
    local q = max(0.03, 1 - u * u - v * v)
    -- rotate back
    local nx, ny = u * ca - v * sa, u * sa + v * ca
    local l = sqrt(nx * nx + ny * ny + q)
    n[K(x, y)] = { nx / l, ny / l, sqrt(q) / l }
  end)
  return n
end
-- generic pixel map: rows of chars with a colour table, (x0,y0) top-left
function A.map(rows, x0, y0, cols, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cols[ch] then A.c:put(x0 + xx - 1, y0 + yy - 1, cols[ch], tok) end end end
end
function A.shadow(cx, cy, rx, ry) A.c:groundShadow(cx, cy, rx, ry) end
function A.fin()
  local c = A.c
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c)
  HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. A.name .. ".aseprite", png = out .. A.name .. ".png", scale = 1 }
end
return A
