-- _aC30_0 helper (chunk C3, Opus single pass): thin layer over batch2/_b2.lua (shared files not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local K = B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local A = { B = B, H = H, HP = HP, X = X, K = K, ell = B.ell, ln = B.ln }
A.CREAM, A.INK = "#fff4d6", "#2b1c26"
A.CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
A.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.WOOD  = { "#3a2420", "#51302b", "#864c33", "#b97a4a", "#d79e66", "#e8c08c" }
A.BRASS = { "#5a2e1c", "#8f4a1f", "#c27a22", "#e8a830", "#ffd25a", "#fff0b0" }
A.STONE = { "#32344f", "#444663", "#5f6079", "#85869b", "#aaa9b8", "#d6d4de" }
function A.new(name) return B.new(name) end
function A.fin() B.fin() end
local function tok(name) return { r = { name = name } } end
A.tok = tok
-- pillow-lit mask; o.bias table, o.R
function A.pil(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2.5)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or tok(tostring(m)) })
  return idx, n
end
-- cylinder A->B, half width w (number or fn)
function A.cyl(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local wf = type(w) == "function" and w or function() return w end
  local m, n, T, S = X.cyl(ax, ay, bx, by, wf)
  if o.cut then m:cut(o.cut) end
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or tok(tostring(m)) })
  return m, n, T, S, idx
end
-- sphere-lit mask
function A.sph(c, cx, cy, r, ramp, m, o)
  o = o or {}
  m = m or c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx, cy, r, m)
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.2 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or tok(tostring(m)) })
  return m, n, idx, v
end
-- vertical-cylinder lit mask (x0..x1 span)
function A.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, o.ny or 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or tok(tostring(m)) }), n
end
-- paint rows of chars with a map
function A.paint(c, rows, x0, y0, map)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then c:put(x0 + xx - 1, y0 + yy - 1, map[ch]) end end end
end
-- arc of radius r (centre cx,cy), angles a0..a1 (radians, 0 = right, y down), half width w; per-pixel tube light
function A.arc(c, cx, cy, r, a0, a1, w, ramp, o)
  o = o or {}
  local m, n = HP.mask(), {}
  for y = floor(cy - r - w - 1), floor(cy + r + w + 1) do for x = floor(cx - r - w - 1), floor(cx + r + w + 1) do
    local dx, dy = x - cx, y - cy
    local d = sqrt(dx * dx + dy * dy)
    local a = math.atan(dy, dx)
    local inA = false
    for _, off in ipairs{ 0, 2 * pi, -2 * pi } do if a + off >= a0 and a + off <= a1 then inA = true end end
    if inA and abs(d - r) <= w then
      m:set(x, y)
      local s = max(-.97, min(.97, (d - r) / (w + .5)))
      n[K(x, y)] = { dx / d * s, dy / d * s, sqrt(1 - s * s) }
    end
  end end
  if o.cut then m:cut(o.cut) for k in pairs(n) do if not m.s[k] then n[k] = nil end end end
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, tok = o.tok or tok(tostring(m)) })
  return m, n
end
return A
