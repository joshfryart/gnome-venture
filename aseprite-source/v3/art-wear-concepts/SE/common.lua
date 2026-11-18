-- common.lua: shared helpers for the Olivewhistle Shore (SE) wear concepts.
-- Read-only reuse of gnome-wear/_gw.lua (W.R ramps, pillow lighting, vcyl, retone). Saves only into this folder.
-- Run: AppRun -b --script-param png=<dir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
C.out = app.params.png or (DIR .. "/")
local R = {}
for k, v in pairs(W.R) do R[k] = v end
R.olive  = { "#2c3320", "#3f4a26", "#56622e", "#717c36", "#929a48", "#b8bc6a" }
R.sage   = { "#2a3a34", "#3e5446", "#587058", "#768c6c", "#98a886", "#c2caa6" }
R.lemon  = { "#6e4a14", "#a0701a", "#d4a020", "#f0c830", "#fae25a", "#fff4a0" }
R.terra  = { "#5a2a22", "#82382a", "#a84c32", "#c8653c", "#de8650", "#eeac74" }
R.sea    = { "#1c2c5c", "#24467e", "#2e64a2", "#3e86c0", "#62aad6", "#9ad0e6" }
R.linen  = { "#5e5048", "#857464", "#a8977e", "#c8b898", "#e2d6b6", "#f4ecd2" }
R.jute   = { "#4a3420", "#6a4c2c", "#8c6838", "#ac8644", "#c8a45a", "#e2c47c" }
R.cork   = { "#4c2e22", "#6e4430", "#8e5c3c", "#ae7a4e", "#c89a66", "#e0ba84" }
R.grape  = { "#2e1a36", "#46224a", "#62305e", "#803e72", "#9e5a8a", "#c084a8" }
R.wine   = { "#3a1626", "#561e30", "#72283a", "#8e3644", "#aa4c50", "#c66e62" }
R.fleece = { "#6a5a4c", "#8c7a66", "#ae9c82", "#cabca0", "#e2d8bc", "#f4eed8" }
R.goat   = { "#3e3230", "#5a4842", "#786256", "#967e6a", "#b49c84", "#d0bca2" }
R.indigo = { "#1a1c40", "#262c5e", "#34407c", "#465a9a", "#6078b4", "#8ca0cc" }
R.coral  = { "#6a1e2a", "#962c34", "#c0403e", "#de5e4c", "#f08466", "#fab094" }
R.saffron= { "#7a3a14", "#a85618", "#d07a1e", "#ec9e2c", "#f8c04a", "#ffdc80" }
R.wicker = { "#4e3a22", "#70542e", "#94723c", "#b4904c", "#ceae66", "#e6cc8a" }
R.leaf   = { "#1e3a24", "#2a5230", "#3a6e38", "#4f8c40", "#72aa4e", "#a2cc6a" }
C.R = R

function C.canvas(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.bias(m, b, t) t = t or {} m:each(function(x, y) t[K(x, y)] = (t[K(x, y)] or 0) + b end) return t end
-- pillow-lit part: o.b constant bias, o.R bevel, o.cuts, o.tex retone fn, o.hs
function C.part(c, m, ramp, o)
  o = o or {}
  local bias = o.bias or {}
  if o.b then C.bias(m, o.b, bias) end
  local idx, n = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = bias, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx, n
end
-- vertical cylinder part with optional bias/texture
function C.vc(c, m, ramp, x0, x1, o)
  o = o or {}
  local bias = o.bias or {}
  if o.b then C.bias(m, o.b, bias) end
  local idx = W.vcyl(c, m, ramp, x0, x1, { bias = bias, cuts = o.cuts, tilt = o.tilt })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx
end
-- textures
C.weave = function(x, y) if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.6 then return -1 end end
C.linen = function(x, y) if (x % 3 == 0 and y % 2 == 0 and X.hash(x, y, 3) < .5) then return -1 end end
C.felt = function(x, y) local h = X.hash(x, y, 9) if h < .12 then return -1 elseif h > .94 then return 1 end end
-- outline of a mask as a drawn seam (inner edge) in col where pred(x,y)
function C.edge(c, m, f) m:edge():each(function(x, y) local col = f(x, y) if col then c:put(x, y, col) end end) end
-- dashed stitch along a polyline mask
function C.stitch(c, pts, col, on, off)
  local m = c:line(pts, 1)
  local list = {}
  m:each(function(x, y) list[#list + 1] = { x, y } end)
  table.sort(list, function(a, b) if a[1] ~= b[1] then return a[1] < b[1] end return a[2] < b[2] end)
  for i, p in ipairs(list) do if (i - 1) % ((on or 2) + (off or 1)) < (on or 2) then c:put(p[1], p[2], col) end end
end


function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.out .. name .. ".png", scale = 1 }
end
return C
