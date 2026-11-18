-- common.lua: helpers for the ESA (Thornacre Savanna) wearable concept icons.
-- Read-only reuse of ../../gnome-wear/_gw.lua (ramps, pillow lighting). Saves only into this folder.
-- Run: AppRun -b --script-param png=<this dir>/ --script <category>.lua [--script-param only=<n>]
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
local floor, sqrt, sin, cos, max, min, abs = math.floor, math.sqrt, math.sin, math.cos, math.max, math.min, math.abs
C.out = app.params.png or (DIR .. "/")
C.only = tonumber(app.params.only or "")

-- extra 6-tone ramps (dark -> light) for this region
C.R = setmetatable({
  coffee = { "#2e1a1c", "#46282a", "#5e3a31", "#7a4f3c", "#98694c", "#b88a64" }, -- coffee-brown suede
  sisal  = { "#6a5030", "#8e7044", "#b09258", "#ccb06e", "#e2cb8c", "#f4e4b2" }, -- pale sisal straw
  madder = { "#4e1a24", "#74242c", "#9a3232", "#bb4638", "#d4624a", "#e88a66" }, -- madder red dye
  indigo = { "#1a1c40", "#242c5e", "#2e3e7e", "#3e549c", "#5874b8", "#8aa2d6" },
  umber  = { "#261a20", "#35242a", "#463034", "#5a3e3e", "#70504a", "#8a6658" }, -- dark stripe felt
  bark   = { "#4a2420", "#6c3426", "#8e462e", "#ac5c36", "#c87a46", "#e09c62" }, -- terracotta barkcloth
  barkg  = { "#2e2426", "#463836", "#5e4c46", "#786256", "#927a6a", "#b09884" }, -- grey-brown tree bark
  gourd  = { "#5a3418", "#86501e", "#ae7228", "#cc9238", "#e2b452", "#f4d684" },
  wool   = { "#54443c", "#7a6656", "#a08a70", "#c2ae90", "#dccaa8", "#f0e4c6" }, -- undyed cream wool
  khaki  = { "#3e3a26", "#5a5434", "#787044", "#958c58", "#b0a872", "#cec694" },
  suede  = { "#5a3a26", "#7e5434", "#a07044", "#bc8c58", "#d4a874", "#e8c896" },
  ochre  = { "#5e3014", "#8a4a18", "#b06a20", "#cc8a2e", "#e2aa48", "#f2cc78" },
  banana = { "#183a24", "#205430", "#2c723a", "#3e9442", "#62b44c", "#9cd468" },
  sand   = { "#5a3e2c", "#7c5a3e", "#9e7a52", "#bc9a68", "#d4b682", "#ead2a4" },
  leafg  = { "#1d3a2a", "#245236", "#2f6c3c", "#428a44", "#64aa50", "#98ca6a" },
}, { __index = W.R })

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.bmap(m, b, into)
  into = into or {}
  if b and b ~= 0 then m:each(function(x, y) local k = K(x, y) into[k] = (into[k] or 0) + b end) end
  return into
end
-- pillow-lit part; o.b = uniform bias, o.bias = map
function C.lit(c, m, ramp, o)
  o = o or {}
  local bias = o.bias or {}
  if o.b then C.bmap(m, o.b, bias) end
  return W.lit(c, m, ramp, { R = o.R, hs = o.hs, amb = o.amb, wrap = o.wrap, cuts = o.cuts, bias = bias })
end
function C.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  local bias = o.bias or {}
  if o.b then C.bmap(m, o.b, bias) end
  return W.vcyl(c, m, ramp, x0, x1, { cuts = o.cuts, bias = bias, tilt = o.tilt })
end
-- horizontal cylinder (logs, rolls) between y0..y1
function C.hcyl(c, m, ramp, y0, y1, o)
  o = o or {}
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((y - y0) / (y1 - y0)) * 2 - 1))
    n[K(x, y)] = { -0.15, t * 0.95, sqrt(1 - t * t) }
  end)
  local bias = o.bias or {}
  if o.b then C.bmap(m, o.b, bias) end
  return W.toneN(c, m, n, ramp, { cuts = o.cuts, bias = bias })
end
-- rotated local frame: test(u, v) in a frame centred at cx,cy rotated by ang (radians).
-- returns mask and maps U, V of local coords
function C.rot(cx, cy, ang, test, R)
  R = R or 34
  local ca, sa = cos(ang), sin(ang)
  local m, U, V = HP.mask(), {}, {}
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if test(u, v) then m:set(x, y) U[K(x, y)] = u V[K(x, y)] = v end
  end end
  return m, U, V
end
function C.paint(c, m, f) m:each(function(x, y) local col = f(x, y) if col then c:put(x, y, col) end end) end
function C.dot(c, x, y, col) c:put(x, y, col) end
-- small lit bead / ball
function C.bead(c, cx, cy, r, ramp, spec)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .3, cy - .3, r, m)
  W.toneN(c, m, n, ramp, { cuts = { .2, .38, .55, .72, .88 } })
  if spec then c:put(floor(cx - r * .5 + .5), floor(cy - r * .5 + .5), spec) end
  return m
end

-- a pair (back one offset by dx,dy, one tone darker): make(dx, dy, b) -> { all = mask, paint = fn }
function C.pair(c, make, dx, dy)
  local back = make(dx, dy, -1)
  local front = make(0, 0, 0)
  back.paint()
  W.sep(c, front.all, back.all, W.ink)
  front.paint()
  return front, back
end

function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.out .. name .. ".png", scale = 1 }
end
-- run a list of {name, fn} honouring only=<n>
function C.run(list)
  for i, it in ipairs(list) do
    if not C.only or C.only == i then
      local c = C.new(it[1])
      it[2](c)
      C.save(c, it[1])
    end
  end
end
return C
