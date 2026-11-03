-- _aR4_2.lua: private helpers for ph/beeswax, ph/beeswax-candles, ph/beet, ph/beet-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- ramps dark -> light (6 tones)
A.WAX   = { "#6b3420", "#a5561e", "#d68a24", "#efb43a", "#fad46a", "#fff0b0" }
A.BEET  = { "#33102e", "#561338", "#811c49", "#ab2b5a", "#d0527a", "#ee8ea6" }
A.LEAF  = { "#173a36", "#21553f", "#2e7246", "#43914c", "#68b057", "#9acb6a" }
A.RIB   = { "#4a1232", "#7a1c46", "#a52f5c", "#cf5c84" }      -- red stems / veins
A.CORK  = { "#3e2624", "#5f3b2c", "#86583a", "#a97a4e", "#c99e6a", "#e6c592" }
A.TWINE = { "#5a3a2c", "#8a6040", "#b88f5e", "#dcbd8a" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise to ramp with per-pixel bias; returns idx (k -> tone index), v
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.28 })
  local cuts = o.cuts or A.CUTS
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local val, i = v[k] or 0, 1
    for j, t in ipairs(cuts) do if val >= t then i = j + 1 end end
    if o.bias and o.bias[k] then i = i + o.bias[k] end
    i = max(o.lo or 1, min(o.hi or #ramp, i))
    idx[k] = i
    c:put(x, y, ramp[i])
  end)
  return idx, v
end
function A.step(c, idx, ramp, x, y, d, lo, hi)
  local k = K(x, y)
  if not idx[k] then return end
  local i = max(lo or 1, min(hi or #ramp, idx[k] + d))
  idx[k] = i
  c:put(x, y, ramp[i])
end
function A.set(c, idx, ramp, x, y, i)
  if not idx[K(x, y)] then return end
  idx[K(x, y)] = i c:put(x, y, ramp[i])
end

-- vertical cylinder with elliptical top: body from y0 (top-ellipse centre) to y1 (bottom-ellipse centre)
-- returns side mask, top mask, side normals, top normals
function A.drum(cx, rx, ry, y0, y1)
  local side, top, ns, nt = HP.mask(), HP.mask(), {}, {}
  for y = floor(y0 - ry - 1), floor(y1 + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local sx = (x - cx) / (rx + 0.5)
    if abs(sx) <= 1 then
      local tq = sx*sx + ((y - y0) / (ry + 0.5))^2
      local bq = sx*sx + ((y - y1) / (ry + 0.5))^2
      if tq <= 1 then top:set(x, y)
        nt[K(x, y)] = { norm(sx * 0.35, (y - y0) / (ry + 0.5) * 0.35 - 0.25, 1) }
      elseif (y >= y0 and y <= y1) or bq <= 1 then side:set(x, y)
        ns[K(x, y)] = { norm(sx, 0.18, sqrt(max(0.04, 1 - sx*sx))) }
      end
    end
  end end
  return side, top, ns, nt
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A
