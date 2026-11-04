-- _aC14_2.lua: private helpers for ph/king-protea-seed, ph/kitchen-1, ph/kitchen-2, ph/kitchen-3 (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
-- House kit: 3/4 cottage (lit front gable + shaded right side wall + right roof slope running back up-right).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.HP, A.X, A.K = HP, X, K

A.WALL  = { "#4e2a26", "#7a4630", "#a3663e", "#c98a52", "#e4ad6c", "#f6cf8e" }
A.TRIM  = { "#3a1f22", "#5a2f2a", "#7e4430", "#a35f3a", "#c47e4c", "#e2a468" }
A.ROOF  = { "#5e1c34", "#8e2a3a", "#bb3a3c", "#de5a44", "#f4845a", "#ffb486" }
A.STONE = { "#3e3a52", "#5c5a72", "#7e7d94", "#a3a2b4", "#c6c4d0", "#e6e2e6" }
A.BRICK = { "#4a1e26", "#72302e", "#9c4434", "#c05c3c", "#dc7c4e", "#f2a470" }
A.GLASS = { "#8a4a1c", "#c27622", "#e8a22e", "#f7c94a", "#ffe486", "#fff4c4" }
A.METAL = { "#2e2c40", "#46465e", "#64667e", "#8c8ea4", "#b8bacb", "#e4e4ee" }
A.SMOKE = { "#8e8aa0", "#b4b0c2", "#d6d2de", "#f0ecf0" }
A.CREAM = "#fff4d6"

local function cl(i) return max(1, min(6, i)) end
A.cl = cl
function A.new(name) return G.new2(name) end
function A.put(c, x, y, ramp, i) c:px(x, y, ramp[cl(i)]) end

-- parallelogram mask: pixel centres P = Pa + u*U + w*V, 0<=u<1, 0<=w<1. returns mask, UV[k]={u,w}
function A.pg(ax, ay, ux, uy, vx, vy)
  local m, UV = HP.mask(), {}
  local det = ux * vy - uy * vx
  local xs = { ax, ax + ux, ax + vx, ax + ux + vx }
  local ys = { ay, ay + uy, ay + vy, ay + uy + vy }
  for y = floor(min(table.unpack(ys))) - 1, floor(max(table.unpack(ys))) + 1 do
    for x = floor(min(table.unpack(xs))) - 1, floor(max(table.unpack(xs))) + 1 do
      local dx, dy = x + 0.5 - ax, y + 0.5 - ay
      local u = (dx * vy - dy * vx) / det
      local w = (ux * dy - uy * dx) / det
      if u >= 0 and u < 1 and w >= 0 and w < 1 then m:set(x, y) UV[K(x, y)] = { u, w } end
    end
  end
  return m, UV
end

-- stone blocks over a mask; skew: y offset per x (side faces); off: tone offset
function A.stones(c, m, x0, y0, skew, off, seed)
  skew, off = skew or 0, off or 0
  m:each(function(x, y)
    local yy = y + floor((x - x0) * skew + 0.5) - y0
    local row = floor(yy / 3)
    local p = yy % 3
    local bw = 4 + floor(X.hash(row, 3, seed or 1) * 2)
    local bx = (x - x0 + row * 3) % bw
    local i = 4
    if p == 2 or bx == bw - 1 then i = 2
    elseif p == 0 then i = 5
    elseif bx == bw - 2 then i = 3 end
    if i > 2 and X.hash(x, y, seed or 5) > 0.88 then i = i - 1 end
    c:px(x, y, A.STONE[cl(i + off)])
  end)
end

-- horizontal planks. skew = y shift per x (side wall: -0.5). base tone, AO mask (pixels to darken)
function A.planks(c, m, x0, ybase, o)
  o = o or {}
  local base, skew = o.base or 4, o.skew or 0
  m:each(function(x, y)
    local yy = y - ybase + floor((x - x0) * -skew + 0.5)
    local row = floor(yy / 4)
    local p = yy % 4
    local i = base
    if p == 3 then i = base - 2 elseif p == 0 then i = base + 1 end
    local jx = (x - x0 + row * 7 + floor(X.hash(row, 7, 2) * 5)) % (o.joint or 13)
    if jx == 0 and p ~= 3 then i = base - 2 end
    if p == 1 or p == 2 then
      if X.hash(floor((x + row) / 3), row, 9) > 0.72 and (x + row) % 3 ~= 0 then i = i - 1 end   -- grain streak
      if X.hash(x, y, 4) > 0.965 then i = base - 2 end                                         -- knot
    end
    if o.bias and o.bias[K(x, y)] then i = i + o.bias[K(x, y)] end
    c:px(x, y, (o.ramp or A.WALL)[cl(i)])
  end)
end

-- bricks on a mask (front faces); off tone offset
function A.bricks(c, m, x0, y0, off, skew)
  off, skew = off or 0, skew or 0
  m:each(function(x, y)
    local yy = y - y0 + floor((x - x0) * -skew + 0.5)
    local row = floor(yy / 3)
    local p = yy % 3
    local bx = (x - x0 + (row % 2) * 2) % 4
    local i = 4
    if p == 2 then i = 2 elseif bx == 3 then i = 2 elseif p == 0 then i = 5 end
    if i == 4 and X.hash(x, y, 13) > 0.8 then i = 3 end
    c:px(x, y, A.BRICK[cl(i + off)])
  end)
end

-- lit window: x,y top-left of frame, w,h outer size; mull = cross bars; returns mask
function A.window(c, x, y, w, h, o)
  o = o or {}
  local fr = c:rect(x, y, x + w - 1, y + h - 1)
  fr:each(function(px, py)
    local i = 4
    if py == y or px == x then i = 5 end
    if py == y + h - 1 or px == x + w - 1 then i = 3 end
    c:px(px, py, A.TRIM[i])
  end)
  local gx0, gy0, gx1, gy1 = x + 1, y + 1, x + w - 2, y + h - 2
  for py = gy0, gy1 do for px = gx0, gx1 do
    local t = ((px - gx0) / max(1, gx1 - gx0) + (py - gy0) / max(1, gy1 - gy0)) / 2
    local i = t < 0.3 and 5 or (t < 0.62 and 4 or 3)
    if py == gy0 then i = 6 end
    if px == gx1 or py == gy1 then i = 2 end                -- inner shadow of the frame
    if py == gy0 and px == gx1 then i = 3 end
    c:px(px, py, A.GLASS[i])
  end end
  if o.mull ~= false then
    local mx, my = x + floor(w / 2), y + floor(h / 2)
    for py = gy0, gy1 do c:px(mx, py, A.TRIM[3]) end
    for px = gx0, gx1 do c:px(px, my, A.TRIM[3]) end
    c:px(mx, my, A.TRIM[4])
  end
  c:px(gx0, gy0, A.CREAM)  -- glass glint
  if o.sill ~= false then
    for px = x - 1, x + w do c:px(px, y + h, A.TRIM[px == x - 1 and 5 or 4]) end
    c:px(x + w, y + h, A.TRIM[3])
  end
  return fr
end

-- round-top plank door; x0..x1, y0 top, y1 bottom
function A.door(c, x0, x1, y0, y1, o)
  o = o or {}
  local r = floor((x1 - x0 + 1) / 2)
  local m = c:rrect(x0, y0, x1, y1 + r, r):clip(c:rect(x0, y0, x1, y1))
  m:each(function(x, y)
    local i = (x - x0) < (x1 - x0) / 2 and 4 or 3
    if (x - x0) % 3 == 2 then i = 2 end
    if not m:has(x, y - 1) then i = 1 end          -- deep reveal under the arch
    if x == x0 and m:has(x, y - 1) then i = 5 end
    c:px(x, y, (o.ramp or A.TRIM)[i])
  end)
  for _, hy in ipairs{ y0 + r + 1, y1 - 2 } do
    for x = x0, x1 - 1 do c:px(x, hy, A.METAL[x == x0 and 4 or 3]) end
  end
  local kx, ky = x1 - 1, floor((y0 + r + 1 + y1) / 2) + 1
  c:px(kx, ky, "#f5b82e") c:px(kx, ky + 1, "#8f4a1f")
  return m
end

-- small shaded puff of smoke
function A.puff(c, cx, cy, r)
  local m = c:ellipse(cx, cy, r, r * 0.85)
  local n = X.sphere(cx - 0.3, cy - 0.3, r + 0.4, m)
  X.tone(c, m, X.light(n, { amb = 0.2, wrap = 0.4 }), A.SMOKE, { cuts = { 0.35, 0.62, 0.86 }, tok = { r = { name = "smoke" } } })
  return m
end

-- the cottage body. o: x0,x1 (front wall, odd width), yt (eave), yb (ground row), ya (apex), d (side depth),
-- ov (overhang), found (stone rows). returns geometry table.
function A.house(c, o)
  local x0, x1, yt, yb, ya, d, ov = o.x0, o.x1, o.yt, o.yb, o.ya, o.d, o.ov or 2
  local xm = (x0 + x1) / 2
  local found = o.found or 3
  local Gm = { xm = xm }
  -- masks
  local front = c:rect(x0, yt, x1, yb):add(c:poly{ { x0, yt + 1 }, { xm + 0.5, ya + 0.5 }, { x1 + 1, yt + 1 } })
  local side = HP.mask()
  for i = 0, d - 1 do local x = x1 + 1 + i local s = floor((i + 1) / 2)
    for y = yt - s, yb - s do side:set(x, y) end end
  local Pa = { xm + 0.5, ya - 1.2 }
  local Pe = { x1 + ov + 1.2, yt + 1.6 }
  local U = { Pe[1] - Pa[1], Pe[2] - Pa[2] }
  local V = { d + ov * 0.5, -(d + ov * 0.5) / 2 }
  local roof, RUV = A.pg(Pa[1], Pa[2], U[1], U[2], V[1], V[2])
  local Ls, Ld = sqrt(U[1]^2 + U[2]^2), sqrt(V[1]^2 + V[2]^2)
  local barge = c:line({ { x0 - ov, yt + 1 }, { xm, ya - 1 }, { x1 + ov, yt + 1 } }, 2)
  barge:cut(roof)
  Gm.front, Gm.side, Gm.roof, Gm.barge, Gm.RUV, Gm.Ls, Gm.Ld = front, side, roof, barge, RUV, Ls, Ld
  -- ground shadow first
  c:groundShadow(floor((x0 + x1 + d) / 2) + 1, yb + 1, floor((x1 - x0 + d) / 2) + 5, 2)
  -- walls with AO under barge/roof
  local fb, sb = {}, {}
  front:each(function(x, y)
    if barge:has(x, y - 1) or roof:has(x, y - 1) then fb[K(x, y)] = -2
    elseif barge:has(x, y - 2) or roof:has(x, y - 2) then fb[K(x, y)] = -1 end
    if x == x1 then fb[K(x, y)] = (fb[K(x, y)] or 0) - 1 end
    if x == x0 then fb[K(x, y)] = (fb[K(x, y)] or 0) + 1 end
  end)
  side:each(function(x, y)
    if roof:has(x, y - 1) or roof:has(x, y - 2) then sb[K(x, y)] = -1 end
    if x == x1 + 1 then sb[K(x, y)] = (sb[K(x, y)] or 0) + 1 end    -- corner board catches a little light
  end)
  local wf = front:copy():cut(c:rect(x0, yb - found + 1, x1, yb))
  local ws = HP.mask() side:each(function(x, y) local s = floor((x - x1) / 2) if y <= yb - s - found then ws:set(x, y) end end)
  A.planks(c, wf, x0, yb - found + 1, { base = 4, bias = fb, ramp = o.wall })
  A.planks(c, ws, x1 + 1, yb - found + 1 - 1, { base = 2, skew = -0.5, bias = sb, ramp = o.wall })
  local sf = front:copy():cut(wf)
  local ss = side:copy():cut(ws)
  A.stones(c, sf, x0, yb - found + 1, 0, 0, 3)
  A.stones(c, ss, x1 + 1, yb - found, 0.5, -1, 4)
  -- AO row where planks sit on the stone
  wf:each(function(x, y) if sf:has(x, y + 1) and X.hash(x, y, 2) > 0.3 then c:px(x, y, (o.wall or A.WALL)[2]) end end)
  -- roof tiles
  local R = o.roof or A.ROOF
  roof:each(function(x, y)
    local uv = RUV[K(x, y)]
    local su, sw = uv[1] * Ls, uv[2] * Ld
    local i
    if su < 1.3 then
      i = (floor(sw) % 2 == 0) and 5 or 4                                   -- ridge cap
      if su >= 0.9 then i = 2 end
    else
      local rp = (su - 1.3) / 3
      local row = floor(rp) local f = rp - row
      i = 4
      if f > 0.66 then i = 2 elseif f < 0.3 then i = 5 end
      local q = (sw / 3.2 + row * 0.5) % 1
      if q < 0.22 and f > 0.2 then i = 3 end                                 -- tile split
      if q > 0.5 and q < 0.78 and f > 0.3 and f < 0.66 and i == 4 then i = 4 + (uv[2] < 0.5 and 1 or 0) end
      if uv[2] > 0.72 then i = i - 1 end                                      -- far end turns away
      if su > Ls - 1.2 then i = 1 end                                         -- eave lip shadow
      if row % 3 == 1 and X.hash(x, y, 21) > 0.93 then i = 6 end             -- glaze glint
    end
    c:px(x, y, R[cl(i)])
  end)
  -- barge boards: lit top edge on the left slope, shaded on the right
  barge:each(function(x, y)
    local i
    local left = x <= xm
    local top = not barge:has(x, y - 1)
    if left then i = top and 6 or 4 else i = top and 4 or 3 end
    if not barge:has(x, y + 1) then i = i - 1 end
    c:px(x, y, A.TRIM[cl(i)])
  end)
  -- eave ends: little end-grain caps
  c:px(x0 - ov, yt + 2, A.TRIM[5]) c:px(x1 + ov + 1, yt + 2, A.TRIM[3])
  Gm.x0, Gm.x1, Gm.yt, Gm.yb, Gm.ya, Gm.d, Gm.ov = x0, x1, yt, yb, ya, d, ov
  -- roof surface y at column x along the top (for chimneys): first roof pixel from the top
  function Gm.roofTop(x) for y = 0, 63 do if roof:has(x, y) then return y end end return nil end
  return Gm
end

-- brick chimney stack: front face x0..x1 from ytop down to ybot, side face 2 px skewed; cap + pots
function A.chimney(c, x0, x1, ytop, ybot, o)
  o = o or {}
  local front = c:rect(x0, ytop, x1, ybot)
  local side = HP.mask()
  for i = 1, 2 do local s = floor(i / 2) for y = ytop - s, ybot - s do side:set(x1 + i, y) end end
  A.bricks(c, front, x0, ytop, 0)
  A.bricks(c, side, x1 + 1, ytop, -2, -0.5)
  -- AO at the roof line
  for x = x0, x1 + 2 do c:px(x, ybot - (x > x1 and 1 or 0), A.BRICK[1]) end
  -- cap slab
  for x = x0 - 1, x1 + 3 do
    local yy = ytop - 1 - (x > x1 + 1 and 1 or 0)
    c:px(x, yy, A.STONE[x <= x1 and 5 or 3]) c:px(x, yy - 1, A.STONE[x <= x1 and 6 or 4])
  end
  return front:add(side)
end
return A
