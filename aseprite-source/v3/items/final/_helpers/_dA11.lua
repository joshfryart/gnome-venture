-- _dA11: helper for chunk dA11 first drafts (ico-thermometer .. ico-wolf). Layer over _dA9 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA9.lua")
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
D.PURP  = { "#2a1a4a", "#4a2a7a", "#6a3aa6", "#8a58c8", "#ae82e6", "#d4b4f8" }
D.SKIN  = { "#7a3a30", "#b86a4c", "#e8946a", "#f5b890", "#ffd2ae", "#ffe8d0" }
D.WOOD  = { "#3a2030", "#5e3a2a", "#84552f", "#a87240", "#cc9c5e", "#ecc98e" }
D.FUR   = { "#3a3d56", "#5a5e7c", "#7e829e", "#a4a8c0", "#cdd0e2", "#eef0fa" }
D.TERRA = { "#5e2a22", "#8e3e2a", "#bd5a34", "#d9784a", "#ee9a68", "#ffc49a" }
-- n-point star polygon mask
function D.star(c, cx, cy, R, r, n, rot)
  n = n or 5 rot = rot or -pi / 2
  local p = {}
  for i = 0, 2 * n - 1 do
    local a = rot + i * pi / n local rr = (i % 2 == 0) and R or r
    p[#p + 1] = { floor(cx + cos(a) * rr + .5), floor(cy + sin(a) * rr + .5) }
  end
  return c:poly(p)
end
-- sample points {x,y,t} along a circular arc (degrees, y down)
function D.arc(cx, cy, r, a0, a1, n)
  local o = {}
  for i = 0, n do local t = i / n local a = (a0 + (a1 - a0) * t) * pi / 180
    o[#o + 1] = { cx + cos(a) * r, cy + sin(a) * r, t } end
  return o
end
return D
