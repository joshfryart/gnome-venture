-- shared helpers for the hovel (slim home) decor layers. Hard pixels, ink outline via c:finish.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local H = {}
H.OUT = (app and app.params and app.params.out) or (SRC .. "/v3/hovel-decor/out/")
local floor, max, min = math.floor, math.max, math.min
function H.new(name, w, h)
  local c = HP.canvas{ w = w, h = h, scale = 1, name = name }
  local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
  return c, S
end
function H.save(c, n)
  c:finish{ outline = true }
  HP.assertClean(c)
  c:save{ aseprite = H.OUT .. n .. ".aseprite", png = H.OUT .. n .. ".png" }
end
local function pick(R, i) return R[max(1, min(#R, i))] end
H.pick = pick
-- per-pixel form shading on a mask: lit upper-left rim, shaded lower-right rim (band px), optional texture f(x,y,tone)->hex
function H.sh(c, m, R, b, o)
  o = o or {}
  local band = o.band or 1
  m:each(function(x, y)
    local br, tl = 99, 99
    for d = band, 1, -1 do
      if not (m:has(x + d, y) and m:has(x, y + d) and m:has(x + d, y + d)) then br = d end
    end
    if not (m:has(x - 1, y) and m:has(x, y - 1)) then tl = 1 end
    local t = b
    if br == 1 and o.deep then t = b - 2 elseif br <= band then t = b - 1 elseif tl == 1 and not o.nolit then t = b + 1 end
    local col = o.tex and o.tex(x, y, t) or pick(R, t)
    if col then c:put(x, y, col) end
  end)
  if o.pop then c:put(o.pop[1], o.pop[2], pick(R, b + 2)); c:put(o.pop[1] + 1, o.pop[2], pick(R, b + 2)) end
  return m
end
function H.hline(c, x0, x1, y, col) for x = x0, x1 do c:put(x, y, col) end end
function H.vline(c, x, y0, y1, col) for y = y0, y1 do c:put(x, y, col) end end
H.HP = HP
H.INK = "#2b1c26"
return H
