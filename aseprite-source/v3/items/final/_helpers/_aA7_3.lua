-- _aA7_3.lua: private helpers for ico-notepad, ico-olive, ico-onion, ico-orange (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUT6 = { 0.16, 0.32, 0.5, 0.68, 0.86 }
local CUT5 = { 0.2, 0.4, 0.6, 0.8 }
local CUT4 = { 0.25, 0.5, 0.75 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end
-- tone a mask from normals; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local cuts = o.cuts or (#ramp == 6 and CUT6 or #ramp == 5 and CUT5 or CUT4)
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok or A.tok(o.name or "p") })
  return idx, v
end
function A.blend(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end end end
end
function A.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end end
end
-- vertical profile body: hw(y) half width around cx(y); returns mask, normals, U (signed -1..1 across)
function A.lathe(y0, y1, cxf, hwf)
  local m, U = HP.mask(), {}
  for y = y0, y1 do
    local cx, w = cxf(y), hwf(y)
    if w > 0 then
      for x = floor(cx - w - 1), floor(cx + w + 1) do
        local u = (x + 0.5 - cx) / w
        if abs(u) <= 1 then m:set(x, y) U[K(x, y)] = u end
      end
    end
  end
  return m, U
end
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
