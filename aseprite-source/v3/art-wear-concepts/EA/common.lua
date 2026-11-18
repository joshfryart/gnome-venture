-- common.lua: EA "Blossomreach" wearable concepts. Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow
-- lighting) plus extra regional ramps; own save() that writes only into this folder.
-- Run: AppRun -b --script-param png=<this dir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local C = setmetatable({ DIR = DIR }, { __index = W })
local R = {}
for k, v in pairs(W.R) do R[k] = v end
-- regional ramps, dark -> light
R.hemp   = { "#5e4a30", "#86704a", "#a8925e", "#c6b076", "#dccb92", "#efe2b4" }
R.straw  = { "#5a3a1c", "#80561e", "#a87a28", "#cc9c36", "#e4bc52", "#f6dc86" }
R.lacq   = { "#3a1420", "#5e1c26", "#86262a", "#a83a30", "#c85a3e", "#e88a5a" }
R.indigo = { "#141c3a", "#1e2a56", "#283c74", "#344f92", "#4a68ae", "#7090c8" }
R.indigoL= { "#283c74", "#344f92", "#4a68ae", "#6a88c4", "#90acd8", "#b8ccea" }
R.fleece = { "#6a5a52", "#8e7c6c", "#b2a088", "#cebca0", "#e4d6ba", "#f6ecd4" }
R.jade   = { "#163a36", "#1e5a4c", "#2a7a5e", "#3c9a6e", "#62b882", "#a2d8a2" }
R.petal  = { "#6e2a52", "#9a3a68", "#c4587e", "#e07c98", "#f2a2b6", "#fccad6" }
R.plum   = { "#3c1a3c", "#5a2450", "#7a3060", "#98406c", "#b45a7a", "#d0848e" }
R.bamboo = { "#3a3a1c", "#5a5a22", "#7e7a2c", "#a29a3a", "#c4b852", "#e2d880" }
R.rattan = { "#4a2c1a", "#6e4222", "#94602e", "#b8803c", "#d4a052", "#ecc278" }
R.ramie  = { "#2e4a5e", "#46687a", "#64889a", "#88aab8", "#b0ccd4", "#dceaea" }
R.frost  = { "#3a4462", "#526088", "#7082a8", "#94a6c4", "#bccad8", "#e2eaf0" }
R.oat    = { "#4a3e3a", "#6a5c52", "#8c7c6c", "#ac9c86", "#c8baa0", "#e2d6bc" }
R.frog   = { "#1e4a2a", "#2e6a2e", "#4a8a34", "#6eab3c", "#98c84a", "#c8e47a" }
R.turq   = { "#1a4a5a", "#226a74", "#2e8c8a", "#46ae9e", "#72cab2", "#b0eace" }
R.moss   = { "#1e3a2e", "#24544a", "#3f9150", "#5aa854", "#7cc35a", "#c4e07a" }
R.snow   = { "#5a6a8c", "#7a8cac", "#a0b0ca", "#c4d2e2", "#e0eaf2", "#f4f8fa" }
C.R = R
C.png = app.params.png or (DIR .. "/")
local HP, X, K, G = W.HP, W.X, W.K, W.G

function C.canvas(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- bias map for a whole mask
function C.bias(m, b, into) into = into or {} m:each(function(x, y) into[K(x, y)] = (into[K(x, y)] or 0) + b end) return into end
-- lit part with constant bias
function C.part(c, m, ramp, o)
  o = o or {}
  if o.b then o.bias = C.bias(m, o.b, o.bias) end
  return W.lit(c, m, ramp, o)
end
-- tube along cubic bezier, toned
function C.tube(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(pts, type(wfn) == "number" and function() return wfn end or wfn)
  if o.clip then m:cut(o.clip) end
  if o.b then o.bias = C.bias(m, o.b, o.bias) end
  local idx = W.toneN(c, m, n, ramp, o)
  return m, idx, T, S
end
-- darken pixels along the bottom/right outside edge of a mask that fall on another painted part (contact shadow)
function C.shadowUnder(c, m, onto, col, dx, dy)
  m:shift(dx or 1, dy or 1):cut(m):clip(onto):each(function(x, y) c:put(x, y, col) end)
end
function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.png .. name .. ".png", scale = 1 }
end
return C
