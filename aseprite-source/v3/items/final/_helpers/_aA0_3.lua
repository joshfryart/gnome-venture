-- _aA0_3.lua: private helpers for ico/ico-activity, ico-ant, ico-apple, ico-arrow-down (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local T = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
T.HP, T.X, T.K = HP, X, K
T.INK, T.CREAM = "#2b1c26", "#fff4d6"
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
T.norm = norm
local CUT = {
  [3] = { 0.3, 0.62 },
  [4] = { 0.26, 0.5, 0.76 },
  [5] = { 0.22, 0.4, 0.6, 0.8 },
  [6] = { 0.2, 0.36, 0.52, 0.68, 0.84 },
}
function T.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- tone a mask from a normal field; returns idx (ramp index per key), v
function T.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUT[#ramp], bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
  return idx, v
end
-- pillow-lit part (R bevel)
function T.pil(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2, o and o.hs)
  local idx, v = T.shade(c, m, n, ramp, o)
  return idx, n, v
end
-- mix two normal fields (w weight of b)
function T.blend(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end
-- re-tone one pixel by d steps (uses idx table)
function T.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
-- hand pixel map: rows of chars, pal char -> hex
function T.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end end end
end
-- 1px line (Bresenham-ish via sampling), optional clip mask
function T.ln(c, x0, y0, x1, y1, hex, clip, tok)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end end
end
function T.save(c, name, folder)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../" .. (folder or "ico") .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return T
