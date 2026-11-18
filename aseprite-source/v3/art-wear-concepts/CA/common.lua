-- common.lua: Maizehollow (CA) wear concepts, shared helpers. Read-only reuse of v3/gnome-wear/_gw.lua.
-- Run: AppRun -b --script-param png=<outdir>/ --script <category>.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = { W = W, HP = HP, X = X, K = K, G = G, DIR = DIR }
C.png = app.params.png or (DIR .. "/")
C.ink, C.cream = W.ink, W.cream

local R = {
  cochi  = { "#4a1426", "#741c34", "#9e2440", "#c4304a", "#e05a5e", "#f4908a" }, -- cochineal crimson
  indigo = { "#1a1e44", "#232d66", "#2f4288", "#3f5ca8", "#5f80c4", "#94b0dc" },
  maize  = { "#6a4214", "#9a6418", "#c88c22", "#e8b234", "#f6d25a", "#fcec9a" },
  agave  = { "#1c3a40", "#285650", "#3a7462", "#56927a", "#7cb096", "#b0d4b6" },
  straw  = { "#5a3e22", "#7e5c32", "#a07c44", "#c09c5a", "#d8bc78", "#ecd8a0" }, -- palm / ixtle fibre
  clay   = { "#4e2018", "#76301e", "#9c4426", "#bc5c32", "#d47a46", "#e8a06a" },
  cotton = { "#7a6a5a", "#9c8a74", "#bcab90", "#d6c8aa", "#ebe0c4", "#f8f0dc" },
  sage   = { "#3a4234", "#56604a", "#76805e", "#97a078", "#b8be94", "#dadcb4" },
  marig  = { "#7a2c10", "#b04a10", "#dc6e14", "#f49422", "#fcb83a", "#ffdc78" },
  turq   = { "#14444c", "#1c6670", "#22888c", "#30aaa4", "#5ccaba", "#a0e8d6" },
  cacao  = { "#2e1a18", "#46261e", "#603426", "#7a4630", "#94603e", "#b07e54" },
  copper = { "#4a2018", "#743222", "#a04a2a", "#c46a38", "#e09050", "#f4bc7c" },
  jade   = { "#163a26", "#1e5630", "#2a743a", "#3c9446", "#5cb456", "#9cd67a" },
  bougain= { "#4a1240", "#701a5a", "#982474", "#bc3a8e", "#d862aa", "#f09ac8" },
}
C.R = setmetatable(R, { __index = W.R })

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
-- pillow-lit part with a flat bias (number) or bias table, optional texture f(x,y,i)->delta
function C.part(c, m, ramp, o)
  o = o or {}
  local b = o.b
  if type(b) == "number" then local t = {} m:each(function(x, y) t[K(x, y)] = b end) b = t end
  local idx, n = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = b, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx, n
end
function C.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local b = o.b
  if type(b) == "number" then local t = {} m:each(function(x, y) t[K(x, y)] = b end) b = t end
  local idx = W.vcyl(c, m, ramp, x0, x1, { bias = b, cuts = o.cuts, tilt = o.tilt })
  if o.tex then W.retone(c, m, idx, ramp, o.tex) end
  return idx
end
function C.ball(c, cx, cy, r, ramp)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .4, cy - .4, r, m)
  W.toneN(c, m, n, ramp, { cuts = { .2, .38, .55, .7, .86 } })
  return m
end
C.sep, C.put, C.hline, C.vline, C.retone = W.sep, W.put, W.hline, W.vline, W.retone
function C.fill(c, m, col) m:each(function(x, y) c:put(x, y, col) end) end
-- paint the bottom/right edge of m with a darker tone (inner rim shading)
function C.rimDark(c, m, col) m:each(function(x, y) if not m:has(x, y + 1) or not m:has(x + 1, y) then c:put(x, y, col) end end) end
function C.rimLit(c, m, col) m:each(function(x, y) if not m:has(x, y - 1) or not m:has(x - 1, y) then c:put(x, y, col) end end) end

-- small motifs reused across scripts
function C.flower(c, x, y, ramp, centre)
  C.put(c, { {x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1} }, ramp[4])
  c:put(x - 1, y - 1, ramp[5]) c:put(x, y, centre or R.maize[5])
end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.png .. name .. ".png", scale = 1 }
end
return C
