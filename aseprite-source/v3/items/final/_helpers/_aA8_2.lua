-- _aA8_2.lua: private helpers for ico-plate-cutlery, ico-play, ico-plus, ico-pointing (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs = math.sqrt,math.floor, math.max, math.min, math.abs
local A = setmetatable({}, { __index = G })
A.INK, A.CR = "#2b1c26", "#fff4d6"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) A.c = G.new2(name) A.name = name return A.c end
function A.done() G.save2(A.c, A.name) end
function A.px(x, y, hex, tok) A.c:put(x, y, hex, tok) end
function A.pts(list, hex, tok) for _, p in ipairs(list) do A.c:put(p[1], p[2], hex, tok) end end
function A.at(x, y) return A.c.pix[y * A.c.w + x] end
function A.bmp(rows, x0, y0, map, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then A.c:put(x0 + xx - 1, y0 + yy - 1, map[ch], tok) end end end
end
-- light a normal field to v[] (lambert + ambient + wrap)
function A.lightV(n, amb, wrap) return X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }) end
-- paint v[] quantised to ramp (dark..light) with bias; tok shared per part
function A.toneV(m, v, ramp, cuts, bias, tok)
  return X.tone(A.c, m, v, ramp, { cuts = cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = bias, tok = tok or { r = { name = tostring(ramp) } } })
end
-- pillow-lit part
function A.pil(m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.hs)
  local v = A.lightV(n, o.amb, o.wrap)
  if o.vmod then for k, val in pairs(v) do v[k] = o.vmod(k, val) end end
  local idx, tok = A.toneV(m, v, ramp, o.cuts, o.bias, o.tok)
  return idx, n, v, tok
end
-- capsule (stadium) from A to B, half-width w: mask + rounded normals (cylinder body, sphere caps)
function A.capsule(ax, ay, bx, by, w, m0)
  local m, n = HP.mask(), {}
  local vx, vy = bx - ax, by - ay
  local L2 = vx*vx + vy*vy
  for y = floor(min(ay, by) - w - 2), floor(max(ay, by) + w + 2) do
    for x = floor(min(ax, bx) - w - 2), floor(max(ax, bx) + w + 2) do
      local px, py = x + 0.5, y + 0.5
      local t = L2 > 0 and max(0, min(1, ((px - ax) * vx + (py - ay) * vy) / L2)) or 0
      local qx, qy = ax + vx * t, ay + vy * t
      local dx, dy = px - qx, py - qy
      local d = sqrt(dx*dx + dy*dy)
      if d <= w then
        m:set(x, y)
        local s = d / (w + 0.35)
        local nz = sqrt(max(0.03, 1 - s*s))
        n[K(x, y)] = { norm(dx / (w + 0.35), dy / (w + 0.35), nz) }
      end
    end
  end
  return m, n
end
-- merge normal tables (later wins)
function A.nmerge(...)
  local o = {}
  for _, t in ipairs({ ... }) do for k, v in pairs(t) do o[k] = v end end
  return o
end
-- AO: bias pixels of m within r px of other by amt (default -1)
function A.ao(bias, m, other, r, amt) return X.ao(bias, m, other, r, amt) end
-- 1px Bresenham polyline, optional clip mask
function A.ln(pts, hex, clip, tok)
  for i = 2, #pts do
    local x0, y0, x1, y1 = pts[i-1][1], pts[i-1][2], pts[i][1], pts[i][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      if not clip or clip:has(x0, y0) then A.c:put(x0, y0, hex, tok) end
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy x0 = x0 + sx end
      if e2 <= dx then err = err + dx y0 = y0 + sy end
    end
  end
end
-- mask from predicate over a box
function A.fmask(x0, y0, x1, y1, f)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end
-- shift ramp index of existing pixels in mask (ramp lookup by colour)
function A.retone(m, ramp, d, tok)
  local idx = {}
  for i, h in ipairs(ramp) do idx[h:lower()] = i end
  m:each(function(x, y) local h = A.at(x, y) local i = h and idx[h]
    if i then A.c:put(x, y, ramp[max(1, min(#ramp, i + d))], tok) end end)
end
return A
