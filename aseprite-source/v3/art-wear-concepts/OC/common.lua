-- common.lua: shared helpers for the OC (Coralscatter) wear concept icons.
-- Read-only reuse of v3/gnome-wear/_gw.lua (which loads batch1/_h.lua + batch2/_bbg.lua).
-- Saves only into this folder (png=<dir>/ param, default this folder).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local C = setmetatable({ DIR = DIR }, { __index = W })
local HP, X, K = W.HP, W.X, W.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
C.png = app.params.png or (DIR .. "/")

-- region ramps, dark -> light (6 tones)
C.R = setmetatable({
  pandanus = { "#5a3f22", "#80602e", "#a6823c", "#c6a250", "#dcc070", "#efdc9c" },
  coir     = { "#3a2219", "#56331f", "#744627", "#915c31", "#ac7640", "#c8965a" },
  fleece   = { "#6a5444", "#8e7660", "#b09a80", "#cdbb9e", "#e4d6bc", "#f4ecd8" },
  suede    = { "#5a3a26", "#7c5232", "#9e6c40", "#bc8a52", "#d4a868", "#e8c88c" },
  flax     = { "#33361c", "#4e5424", "#6c742c", "#8c9236", "#b0ac4a", "#d4cc78" },
  turtle   = { "#1e3a34", "#2a5a48", "#3a7a58", "#529a62", "#78b870", "#acd890" },
  ochre    = { "#4e1e1a", "#74301f", "#9a4426", "#bc5a2e", "#d67a3c", "#ecaa5e" },
  tapa     = { "#6a5038", "#8e7050", "#b09468", "#ccb486", "#e2d0a6", "#f2e6c8" },
  sea      = { "#1a2a4a", "#1e4466", "#246282", "#2f84a0", "#4aa8ba", "#86d0d0" },
  hibiscus = { "#5a1638", "#8a2048", "#b83058", "#dc4a68", "#f07a84", "#fcb0a8" },
  coral    = { "#6a2424", "#9a3a2e", "#c85a3a", "#e87a48", "#f6a060", "#fccc8c" },
  gum      = { "#2e3a36", "#44564c", "#5e7462", "#7a9278", "#9cb294", "#c4d4b4" },
  charcoal = { "#2e2830", "#3e3640", "#504652", "#645a64", "#7a7078", "#968c90" },
  oilskin  = { "#2e2018", "#44301e", "#5c4224", "#76562e", "#92703c", "#b08c52" },
  bamboo   = { "#4a4220", "#6a6026", "#8c8030", "#ae9e3e", "#ccbc5a", "#e6d888" },
  leafwrap = { "#203a26", "#2c5430", "#3c6e36", "#548a40", "#74a84c", "#a2c86a" },
  coconut  = { "#2e1c16", "#45291c", "#5e3a24", "#7a4e2e", "#96663a", "#b2824c" },
  paua     = { "#1e3a5a", "#2a6a8a", "#3aa0a0", "#62c8a8", "#9a7ad0", "#c8f0e0" },
}, { __index = W.R })

function C.canvas(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- constant bias map
function C.bias(m, b, t)
  t = t or {}
  m:each(function(x, y) local k = K(x, y) t[k] = (t[k] or 0) + b end)
  return t
end
-- pillow-lit part with a scalar bias
function C.part(c, m, ramp, o)
  o = o or {}
  local bm = o.bmap or {}
  if o.b and o.b ~= 0 then C.bias(m, o.b, bm) end
  return W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, cuts = o.cuts, bias = bm, amb = o.amb, wrap = o.wrap })
end
function C.vcylb(c, m, ramp, x0, x1, b, o)
  o = o or {}
  o.bias = b and C.bias(m, b) or o.bias
  return W.vcyl(c, m, ramp, x0, x1, o)
end
-- textures (for W.retone)
function C.plait(x, y, i) -- diagonal over-under plait
  local a, b = floor((x + y) / 3), floor((x - y + 300) / 3)
  if (a + b) % 2 == 0 and (x + y) % 3 == 0 then return -1 end
  if (a + b) % 2 == 1 and (x - y) % 3 == 0 then return -1 end
end
function C.check(x, y, i) -- square basket check, 4 px
  local a, b = floor(x / 4) % 2, floor(y / 4) % 2
  if a ~= b then if x % 4 == 0 then return -1 end else if y % 4 == 0 then return -1 end end
end
function C.weave(x, y, i) if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.7 then return -1 end end
function C.knit(x, y, i) if (x % 3 == 1 and y % 2 == 0) then return -1 end end
-- dashed stitch along mask pixels picked by f(x,y)
function C.dash(c, pts, col, on, off)
  on, off = on or 2, off or 1
  for i, p in ipairs(pts) do if (i - 1) % (on + off) < on then c:put(p[1], p[2], col) end end
end
-- small lit ball (beads, buttons, puffs)
function C.ball(c, cx, cy, r, ramp, hi)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .3, cy - .3, r, m)
  W.toneN(c, m, n, ramp, { cuts = { .2, .36, .52, .7, .88 } })
  if hi then c:put(floor(cx - r * .5 + .5), floor(cy - r * .5 + .5), hi) end
  return m
end
-- paint mask pixels a single colour unless masked by `keep`
function C.fill(c, m, col, keep) m:each(function(x, y) if not (keep and keep:has(x, y)) then c:put(x, y, col) end end) end
-- pixels of m whose (dx,dy) neighbour is outside m
function C.side(m, dx, dy) local n = HP.mask() m:each(function(x, y) if not m:has(x + dx, y + dy) then n:set(x, y) end end) return n end

function C.save(c, name)
  c:finish{ outline = true }
  W.G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.png .. name .. ".png", scale = 1 }
end
return C
