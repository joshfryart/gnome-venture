-- common.lua: shared helpers for the WCA "Greatcanopy" wearable concepts (Hearth Pop v3).
-- Read-only reuse of v3/gnome-wear/_gw.lua (ramps, pillow lighting) and its batch helpers.
-- Saves only into this folder (or the png= param), never into gnome-wear/.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, G = W.HP, W.X, W.K, W.G
local C = setmetatable({ DIR = DIR }, { __index = W })
C.OUT = app.params.png or (DIR .. "/")
C.only = app.params.only

-- region ramps, dark -> light
C.R = setmetatable({
  indigo    = { "#1a1d4a", "#22306e", "#2c4890", "#3a64ae", "#5a8acb", "#94bce4" },
  ochre     = { "#6a3418", "#94501f", "#b86e28", "#d48d36", "#e8ae4e", "#f6d27c" },
  raffia    = { "#5e4424", "#866434", "#ab8846", "#c9a75a", "#e0c477", "#f3e0a0" },
  redleather= { "#4e1a22", "#74242a", "#9a3430", "#bc4a36", "#d66a44", "#ec9460" },
  plantain  = { "#163e2a", "#1f5e30", "#2f8236", "#4ea43c", "#7cc44a", "#b6e270" },
  mahogany  = { "#341a1a", "#4e2420", "#6c3226", "#8a442c", "#a85a36", "#c67a48" },
  calabash  = { "#6a4a1e", "#946a28", "#bc8e34", "#d8ad46", "#ecc962", "#f8e496" },
  cotton    = { "#6a5a4e", "#8e7e6c", "#b0a28c", "#cdc1a8", "#e4dac2", "#f6efdc" },
  kente     = { "#6e4210", "#9a6014", "#c88418", "#e8a820", "#f8c840", "#ffe48a" },
  forest    = { "#11302a", "#18463a", "#215c42", "#2e744a", "#418e52", "#64aa60" },
  palm      = { "#6a2410", "#9a3a12", "#c85618", "#e87420", "#f89a36", "#ffc66a" },
  mud       = { "#24161a", "#36221f", "#4a3026", "#5e3e2e", "#745038", "#8c6646" },
  grey      = { "#3a3a4a", "#55566a", "#727488", "#9294a6", "#b4b6c4", "#d8dae2" },
}, { __index = W.R })

function C.bias(m, b) local t = {} if b and b ~= 0 then m:each(function(x, y) t[K(x, y)] = b end) end return t end
-- pillow-lit part with a flat bias; returns idx
function C.lay(c, m, ramp, o)
  o = o or {}
  local idx = W.lit(c, m, ramp, { R = o.R or 3, hs = o.hs, bias = o.biasmap or C.bias(m, o.bias), cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  return idx
end
-- tube along a cubic bezier, toned
function C.tube(c, pts, w, ramp, o)
  o = o or {}
  local wf = type(w) == "function" and w or function() return w end
  local m, n, T, S = G.tube(pts, wf, o)
  local idx = W.toneN(c, m, n, ramp, { bias = o.biasmap or C.bias(m, o.bias), cuts = o.cuts })
  return m, idx, T, S
end
function C.oval(cx, cy, rx, ry, ang) return G.oval(cx, cy, rx, ry, ang or 0) end
function C.ovalLit(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m, n = G.oval(cx, cy, rx, ry, ang or 0, o.flat)
  local idx = W.toneN(c, m, n, ramp, { bias = o.biasmap or C.bias(m, o.bias), cuts = o.cuts })
  return m, idx
end
-- set pixels of mask m to ramp tone j where f(x,y) true
function C.paintIf(c, m, col, f) m:each(function(x, y) if f(x, y) then c:put(x, y, col) end end) end
-- bottom / right edge pixels of a mask darkened (form shadow line)
function C.underline(c, m, col) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, col) end end) end
function C.topline(c, m, col) m:each(function(x, y) if not m:has(x, y - 1) then c:put(x, y, col) end end) end

function C.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function C.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ png = C.OUT .. name .. ".png", scale = 1 }
end
-- run a category list { {name, fn}, ... }; params: only=<name substring>
function C.run(list)
  for _, it in ipairs(list) do
    if not C.only or it[1]:find(C.only, 1, true) then
      local c = C.new(it[1])
      it[2](c)
      C.save(c, it[1])
    end
  end
end
return C
