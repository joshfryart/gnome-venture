-- common.lua: helpers for the EE (Birchbramble Steppe) wearable concepts.
-- Read-only reuse of gnome-wear/_gw.lua (ramps, lighting). Saves into this folder, never into gnome-wear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
C.png = app.params.png or (DIR .. "/")
C.only = app.params.only

-- region ramps (dark -> light), plus all of W.R
C.R = setmetatable({
  birch  = { "#4a4048", "#6e6466", "#9a8e88", "#c2b8a8", "#ddd4c0", "#f2ecd8" },
  linen  = { "#6a5a5a", "#8e8078", "#b2a696", "#d0c6b0", "#e6dec8", "#f6f0dc" },
  fgrey  = { "#34303e", "#4e4a58", "#6a6672", "#878290", "#a6a0aa", "#c6c0c4" },
  straw  = { "#5e3e1e", "#86602a", "#ae8836", "#cead4e", "#e6cc6e", "#f6e6a2" },
  wicker = { "#4e2a1c", "#723e22", "#98582c", "#bc7838", "#d89a4c", "#eec070" },
  fleece = { "#6a5650", "#8e7a6c", "#b0a08a", "#ccbea2", "#e2d8bc", "#f4eed8" },
  plum   = { "#2a1a32", "#3e2646", "#55345a", "#6c4670", "#865c86", "#a87aa2" },
  redl   = { "#4e1a22", "#741f2a", "#9a2c30", "#b8443a", "#d0604a", "#e88a64" },
  storm  = { "#262e46", "#36425e", "#4a5a78", "#627692", "#8496ae", "#b0c2d4" },
  leaf   = { "#1e3a2a", "#2a5634", "#3a7440", "#4f924a", "#72b05a", "#a8d27c" },
}, { __index = W.R })
local R = C.R

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function bmap(m, b) local t = {} if b and b ~= 0 then m:each(function(x, y) t[K(x, y)] = b end) end return t end
C.bmap = bmap
-- lit part with uniform bias + optional texture fn(x,y,i)->delta
function C.part(c, m, ramp, o)
  o = o or {}
  local b = o.bmap or bmap(m, o.bias)
  local idx = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = b, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx
end
function C.cylv(c, m, ramp, x0, x1, o)
  o = o or {}
  local idx = W.vcyl(c, m, ramp, x0, x1, { bias = o.bmap or bmap(m, o.bias), cuts = o.cuts, tilt = o.tilt })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx
end
-- tube along a bezier, lit
function C.tube(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  local idx = W.toneN(c, m, n, ramp, { bias = o.bmap or bmap(m, o.bias), cuts = o.cuts })
  return m, idx, T, S
end
function C.fill(c, m, col) m:each(function(x, y) c:put(x, y, col) end) end
-- outline a mask's outer ring onto the canvas, only where `where` (optional) holds
function C.ring(c, m, col, where)
  m:grow(1):cut(m):each(function(x, y) if not where or where:has(x, y) then c:put(x, y, col) end end)
end
function C.dots(c, pts, col) for _, p in ipairs(pts) do c:put(p[1], p[2], col) end end
-- textures
C.hash = X.hash
function C.knit(x, y, i) if (x % 2 == 0) and (y % 3 == 0) then return -1 end end
function C.curl(seed) return function(x, y, i)
  local h = X.hash(x, y, seed or 3)
  if (x + 2 * y) % 5 == 0 then return -1 end
  if h > 0.86 and i < 5 then return 1 end
end end

function C.save(c, name)
  c:finish{ outline = true }
  if not app.params.nocentre then G.centre(c) end
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = DIR .. "/" .. name .. ".aseprite", png = C.png .. name .. ".png", scale = 1 }
end
function C.want(name) return not C.only or name:find(C.only, 1, true) end
return C
