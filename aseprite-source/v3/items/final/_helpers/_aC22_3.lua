-- _aC22_3.lua: private helpers for marigold-seed, marsh-marigold-seed, marsh-pearl, martagon-lily-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- torn end: drop pixels of a blade whose T is below t0 + a jagged offset that varies with S (zig-zag tear)
function A.tear(m, T, S, t0, amp, seed, fromEnd)
  local drop = {}
  m:each(function(x, y) local k = K(x, y)
    local s = S[k] or 0
    local z = abs(((s * 3.1 + (seed or 0)) % 1) - 0.5) * 2         -- zig-zag 0..1
    local j = t0 + amp * (z + 0.6 * X.hash(floor(s * 7), 3, seed or 1))
    local t = fromEnd and (1 - T[k]) or T[k]
    if t < j then drop[#drop + 1] = k end
  end)
  for _, k in ipairs(drop) do m.s[k] = nil end
  return m
end

-- shaded rotated ellipsoid seed. returns mask, normals, idx
function A.seed(c, cx, cy, rx, ry, ang, ramp, tok, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang, o.flat or 0.8)
  if o.under then m:cut(o.under) end
  local idx = X.tone(c, m, X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 }), ramp,
    { cuts = o.cuts or A.CUTS6, bias = o.bias, tok = tok })
  return m, n, idx
end

-- contact shadow + AO onto `target` (bias table) from caster
function A.shadow(bias, target, caster, dx, dy)
  X.ao(bias, target, caster, 1, -1)
  G.cast(bias, target, caster, dx or 1, dy or 2, -1)
  return bias
end

-- paint a bezier polyline at 1px
function A.bline(c, p, hexf, tok, steps)
  steps = steps or 40
  for i = 0, steps do local x, y = G.bez(p, i / steps)
    c:put(floor(x + .5), floor(y + .5), type(hexf) == "function" and hexf(i / steps) or hexf, tok) end
end

-- save into final/ph (or out param)
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
