-- common.lua: shared helpers for the Mistmoor (NWE) wearable concepts.
-- Read-only reuse of ../../gnome-wear/_gw.lua (W.R ramps, pillow lighting, tube, centre).
-- Run: AppRun -b --script-param png=<outdir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
C.png = app.params.png or (DIR .. "/")

-- region ramps (dark -> light), same 6-tone style as W.R
local R = setmetatable({
  birch   = { "#4a3e44", "#6e6468", "#9a9096", "#c4bcb8", "#e2dccf", "#f6f0e0" },
  fleece  = { "#6c5848", "#8e7a64", "#b4a084", "#d2c2a2", "#eadcbc", "#fbf1d8" },
  heather = { "#3e1f45", "#5e2f63", "#83457f", "#a65f98", "#c784b2", "#e6b2d0" },
  tweed   = { "#33302a", "#4a4636", "#636044", "#7e7a54", "#9a966a", "#bdb88a" },
  wax     = { "#22281c", "#333c26", "#475230", "#5e6a3a", "#7a8648", "#a2ac66" },
  feltgrey= { "#3a3a4a", "#525466", "#6c6f80", "#8a8e9c", "#acb0ba", "#d0d4d8" },
  woad    = { "#1c2a48", "#26406a", "#335a88", "#4a78a4", "#6e9ac0", "#a4c4dc" },
  tanbark = { "#4e1e1c", "#702c22", "#94402a", "#b65a34", "#d27a44", "#eaa060" },
  straw   = { "#4e3a1c", "#74572a", "#9a7a36", "#bf9e48", "#dcc062", "#f2de90" },
  eider   = { "#2a3440", "#3c4a58", "#526474", "#6c8090", "#90a4b0", "#bccad0" },
  mustard = { "#4a3410", "#74501a", "#a07224", "#c8962e", "#e2b844", "#f4d872" },
  mist    = { "#2e3440", "#434c5a", "#5c6676", "#788294", "#9ca4b2", "#c6ccd4" },
  wicker  = { "#4a2e1a", "#6e4624", "#966232", "#b88244", "#d4a45a", "#ecc884" },
  peat    = { "#22161a", "#33221f", "#463026", "#5a3e2e", "#704e38", "#8a6446" },
  rope    = { "#4e3a26", "#6e5434", "#8e7046", "#ae8e5c", "#c8aa74", "#e2c896" },
  moss    = { "#24544a", "#2e6b45", "#3f9150", "#5eab55", "#7cc35a", "#c4e07a" },
  berry   = { "#5e1428", "#8a1e30", "#b82a34", "#d84038", "#ee6a4a", "#ff9a72" },
  frog    = { "#1e4430", "#2a6038", "#3c8040", "#58a048", "#80c058", "#b8e07a" },
}, { __index = W.R })
C.R = R

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.bmap(m, b, into)
  into = into or {}
  m:each(function(x, y) into[K(x, y)] = (into[K(x, y)] or 0) + b end)
  return into
end
-- lit part with a flat bias
function C.lit(c, m, ramp, o)
  o = o or {}
  if o.b then o.bias = C.bmap(m, o.b, o.bias) end
  return W.lit(c, m, ramp, o)
end
function C.colour(c, m, col) m:each(function(x, y) c:put(x, y, col) end) end
-- twisted rope along a polyline (2 px), alternating tones
function C.rope(c, pts, w, ramp)
  ramp = ramp or R.rope
  local m = c:line(pts, w or 2)
  m:each(function(x, y) c:put(x, y, ((x + y) % 3 == 0) and ramp[2] or (((x + y) % 3 == 1) and ramp[4] or ramp[5])) end)
  return m
end
-- dither-free weave: re-tone by function
C.retone, C.speckle, C.sep, C.put, C.hline, C.vline, C.vcyl, C.toneN = W.retone, W.speckle, W.sep, W.put, W.hline, W.vline, W.vcyl, W.toneN

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = C.png .. name .. ".png", scale = 1 }
end
return C
