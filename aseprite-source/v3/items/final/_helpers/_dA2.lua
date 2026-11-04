-- _dA2: helper for the chunk dA2 first drafts (ico-bulb .. ico-coffee). Thin layer over _dA1.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA1.lua")
local HP, H, B = D.HP, D.H, D.B
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
D.YEL  = { "#8f4a1f", "#c27a22", "#e8a92c", "#f8cc3e", "#ffe27a", "#fff6c0" }
D.GRY  = { "#33344f", "#4f5170", "#74758c", "#9798ac", "#c2c2d0", "#eeeef4" }
D.FUR  = { "#6a3a22", "#93562e", "#bd7d3e", "#dd9d52", "#f0b96e", "#ffd9a0" }
D.PINK = { "#7d2c5e", "#a83e70", "#d4608a", "#f5809f", "#ffa6bd", "#ffd6e2" }
D.SKY  = { "#4f7ab8", "#7aa6d6", "#a6cdea", "#c9e6f5", "#e6f6ff", "#ffffff" }
D.SKY[6] = "#fbfdff"
D.WOODR = { "#3b2224", "#5c3426", "#7e4a30", "#9e623a", "#be7f4a", "#dea06a" }
function D.leaf(...) return H.leaf(D.c, ...) end
function D.rect(x0, y0, x1, y1, hex) D.c:fillMask(D.c:rect(x0, y0, x1, y1), hex) end
function D.line(pts, w) return D.c:line(pts, w) end
-- jagged/regular star mask; rf(i) gives radius for vertex i (0-based)
function D.star(cx, cy, n, rot, rf)
  local pts = {}
  for i = 0, n * 2 - 1 do
    local a = rot + i * pi / n
    local r = rf(i)
    pts[#pts + 1] = { floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5) }
  end
  return D.c:poly(pts)
end
-- a dark row on m's pixels that touch front (contact line), in hex
function D.touch(m, front, hex) B.seam(D.c, m, front, hex) end
-- tiny ant (4x2) at x,y
function D.ant(x, y)
  local I = D.INK
  D.px(x, y, I) D.px(x + 1, y, I) D.px(x + 2, y + 1, I) D.px(x + 3, y + 1, I) D.px(x + 4, y, I)
  D.px(x, y + 1, I) D.px(x + 2, y + 2, I) D.px(x + 4, y + 2, I)
end
return D
