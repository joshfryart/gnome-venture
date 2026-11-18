-- common.lua: shared helpers for the CB (Sunsprinkle Isles) wearable concept icons.
-- Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow lighting); saves into THIS folder only.
-- Run: AppRun -b --script-param png=<this dir>/ --script footwear.lua   (likewise backpack/coat/cloak)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
C.png = app.params.png or (DIR .. "/")
local max, min = math.max, math.min

-- island ramps, dark -> light
C.R = setmetatable({
  straw  = { "#5a3f22", "#7e5a2c", "#a67c3a", "#c9a04e", "#e2c06e", "#f4dc98" }, -- palm plait
  mahog  = { "#3a1a1e", "#5c2622", "#7e3828", "#9e4e30", "#bc6a3c", "#d88c52" }, -- mahogany
  hibis  = { "#5e1430", "#8c1e3c", "#b82a48", "#da4058", "#f06a72", "#ffa0a0" }, -- hibiscus red
  turq   = { "#16405a", "#1e6a7e", "#24909a", "#36b4ac", "#68d4c0", "#b0f0dc" }, -- lagoon
  indigo = { "#1a1a48", "#232c6c", "#2e4290", "#3e5cae", "#5a80c8", "#8cb0e0" },
  cotton = { "#6e5a5a", "#968278", "#b8a694", "#d6c8b0", "#ecdfc6", "#faf2de" }, -- sea cotton
  coral  = { "#6a2030", "#9a3440", "#c8504c", "#e6745c", "#f69a78", "#ffc4a0" },
  sunset = { "#7a2a1c", "#b0441e", "#de6a26", "#f4922e", "#fcb848", "#ffdc80" },
  palm   = { "#16382c", "#1e5434", "#2a7238", "#3e9440", "#68b84a", "#a8dc6c" },
  gourd  = { "#4a2c14", "#6e461c", "#966424", "#b8862e", "#d4a842", "#ecca6a" },
  sisal  = { "#5a4a30", "#7c6840", "#a08a56", "#c0aa6e", "#d8c68a", "#ece0b0" },
  bamboo = { "#4a4a1c", "#6c6a24", "#908a2e", "#b2aa3c", "#d0c858", "#eae48c" },
  shell  = { "#7a4a50", "#a46a68", "#c88c80", "#e2ae98", "#f2ccb4", "#fce6d4" },
  check  = { "#5a2410", "#8a3a14", "#c05a1a", "#e47e24", "#f4a43a", "#fcc86a" },
  seaglass = { "#1e5040", "#2a7a58", "#3aa070", "#5cc48a", "#94e0aa", "#d0f6d4" },
  flam   = { "#7a2a50", "#a83e68", "#d05a80", "#ec7e98", "#f8a8b8", "#ffd4dc" },
}, { __index = W.R })
local R = C.R

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.bias(m, b, into)
  into = into or {}
  m:each(function(x, y) into[K(x, y)] = (into[K(x, y)] or 0) + b end)
  return into
end
-- pillow-lit layer with uniform bias and optional texture f(x,y,i)
function C.lay(c, m, ramp, o)
  o = o or {}
  local b = o.biasmap or {}
  if o.b then C.bias(m, o.b, b) end
  local i = W.lit(c, m, ramp, { R = o.R or 3, bias = b, cuts = o.cuts, hs = o.hs })
  if o.tex then W.retone(c, m, i, ramp, o.tex) end
  return i
end
-- tube along cubic bezier, lit, returns mask
function C.tube(c, pts, w, ramp, o)
  o = o or {}
  local m, n, T, S = G.tube(pts, type(w) == "function" and w or function() return w end)
  local b = o.b and C.bias(m, o.b) or nil
  local i = W.toneN(c, m, n, ramp, { bias = b, cuts = o.cuts })
  if o.tex then
    m:each(function(x, y)
      local d = o.tex(x, y, T[K(x, y)], S[K(x, y)])
      if d and d ~= 0 then local k = K(x, y) local j = max(1, min(#ramp, i[k] + d)) c:put(x, y, ramp[j]) end
    end)
  end
  return m, T, S
end
function C.ball(c, cx, cy, r, ramp, spec)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .3, cy - .3, r, m)
  W.toneN(c, m, n, ramp, { cuts = { .2, .38, .55, .72, .88 } })
  if spec then c:put(math.floor(cx - r * .45 + .5), math.floor(cy - r * .45 + .5), W.cream) end
  return m
end
-- dark contact line on pixels of `back` touching `front`
function C.sep(c, front, back, col) W.sep(c, front, back, col or W.ink) end
-- textures
C.plait = function(sd) return function(x, y, i)
  local u = (x + y) % 6 local v = (x - y) % 6
  if u == 0 then return -1 elseif v == 0 and X.hash(x, y, sd or 3) < .7 then return -1 elseif u == 3 and v == 3 then return 1 end
end end
C.basket = function(x, y, i)
  local cell = (x // 3 + y // 3) % 2
  if cell == 0 and y % 3 == 2 then return -1 elseif cell == 1 and x % 3 == 2 then return -1
  elseif cell == 0 and y % 3 == 0 and x % 3 == 1 then return 1 end
end
C.twist = function(x, y, i) if (x + y) % 3 == 0 then return -1 end end
C.weave = function(x, y, i) if (x % 3 == 0 and y % 2 == 0) then return -1 end end
C.grain = function(x, y, i) if y % 3 == 0 and X.hash(x // 4, y, 7) < .55 then return -1 end end

-- tiny 5-petal flower centred at (x, y)
function C.flower(c, x, y, ramp, eye)
  W.put(c, { {x,y-1}, {x-1,y}, {x+1,y}, {x,y+1}, {x-1,y-1}, {x+1,y+1} }, ramp[4])
  W.put(c, { {x+1,y-1}, {x-1,y+1} }, ramp[3])
  c:put(x - 1, y - 1, ramp[6])
  c:put(x, y, eye or "#f5b82e")
end

-- bigger 5-petal flower (about 5x5)
function C.flower2(c, x, y, ramp, eye)
  local m = HP.mask()
  for _, d in ipairs({ {0,-2}, {-2,-1}, {2,-1}, {-1,2}, {1,2} }) do
    m:add(c:ellipse(x + d[1] * .8, y + d[2] * .8, 1, 1))
  end
  W.lit(c, m, ramp, { R = 1 })
  c:put(x, y, eye or "#f5b82e") c:put(x + 1, y, eye or "#f5b82e")
  c:put(x - 1, y - 2, ramp[6])
  return m
end
function C.save(c, name, o)
  o = o or {}
  c:finish{ outline = true }
  if o.centre ~= false then G.centre(c) end
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.png .. name .. ".png", scale = 1 }
end
return C
