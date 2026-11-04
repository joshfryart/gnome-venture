-- _dB11.lua: private helpers for ph/broken-* tools chunk dB11 (first draft). Wraps batch1/_h.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/../../batch1/_h.lua")
local D = setmetatable({}, { __index = H })
local HP, X, K = H.HP, H.X, H.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
D.WOOD   = { "#3e2420", "#5e3828", "#85522f", "#a96e3d", "#c98c52", "#e8b982" }
D.STEEL  = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#e2e4ee" }
D.BRASS  = { "#6a3418", "#9a5220", "#cc7e2a", "#eeab3a", "#ffd15e", "#fff0b4" }
D.COPPER = { "#5a2418", "#8a3a22", "#b85a30", "#d97e44", "#f0a468", "#ffd2a0" }
D.STRAW  = { "#6a4a24", "#94683a", "#c08c48", "#dcaa5c", "#f0c878", "#fce2a4" }
D.CANVAS = { "#5a4a30", "#7e6a46", "#a48a5c", "#c8ae7a", "#e4cc98", "#fcecc0" }
D.LEATHER= { "#3a2220", "#5a3430", "#7e4a3a", "#a2644a", "#c4825c", "#e0a47c" }
D.MINT   = { "#1f5a52", "#2f8a6e", "#52c090", "#8ae0b0", "#c0f4d0", "#effff0" }
D.GREEN  = { "#1e3f34", "#2c5e3e", "#3f8a48", "#5fae52", "#8fcf6c", "#c4e88c" }
D.OLIVE  = { "#2e3a24", "#47552e", "#677a3a", "#8a9c4a", "#aebe66", "#d4e08c" }
D.RED    = { "#5a1a2c", "#8e2a38", "#c0403a", "#e8603c", "#ff8a5c", "#ffc09a" }
D.SOIL   = { "#2e1c1c", "#4a2c26", "#6a4030", "#8a5a3c" }
D.BLUE   = { "#2a3a7a", "#3a62a8", "#4a8cd0", "#7ac0ea", "#b6e4f6", "#effcff" }
D.WATER  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
D.SOIL6 = { "#2e1c1c", "#3c2420", "#4a2c26", "#6a4030", "#8a5a3c", "#a87650" }
D.INK, D.CREAM = "#2b1c26", "#fff4d6"

function D.start(src)
  local name = src:match("([^/\\]+)%.lua$")
  local _, _, c = H.new(name)
  return HP, X, c, name
end
function D.lit(c, m, ramp, o) return H.lit(c, m, ramp, o or { R = 2 }) end
-- tapered rod A->B, half width w (number or fn(t)); grain streaks optional
function D.rod(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  local wf = type(w) == "function" and w or function() return w end
  local m, T, S = H.cyl(c, ax, ay, bx, by, wf, ramp, o)
  if o.grain then
    local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
    local r = H.ramp(ramp)
    m:each(function(x, y) local k = K(x, y)
      local s, t = S[k], T[k]
      if s and abs(s - 0.1) < 0.18 and X.hash(floor(t * len / 5), floor(s * 3), o.grain) > 0.55 and X.hash(x, y, 7) > 0.3 then c:px(x, y, r[2]) end
    end)
  end
  return m, T, S
end
-- erase pixels along a polyline: a real gap (the outline closes round it at finish)
function D.gap(c, pts, w)
  local m = c:line(pts, w or 1)
  m:each(function(x, y) local k = y * c.w + x c.pix[k] = nil c.own[k] = nil end)
  return m
end
function D.erase(c, m) m:each(function(x, y) local k = y * c.w + x c.pix[k] = nil c.own[k] = nil end) end
-- pale sliver: line with lit top and darker underside
function D.sliver(c, x0, y0, x1, y1, hi, lo)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, 1)
  m:each(function(x, y) c:px(x, y, lo) end)
  m:each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, hi) end end)
end
-- weave / wicker texture over a mask painted already
function D.weave(c, m, ramp, ph)
  ramp = H.ramp(ramp) ph = ph or 0
  m:each(function(x, y)
    local u = (x + 2 * floor(y / 2) + ph) % 4
    if u == 0 then c:px(x, y, ramp[2]) elseif u == 2 and y % 2 == 0 then c:px(x, y, ramp[5]) end
  end)
end
function D.rows(c, x, y, rows, map) c:paint(rows, x, y, map) end
return D
