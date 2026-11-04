-- dA0 helper: thin layer over batch2/_b2.lua (+ batch1/_h.lua). Not editing shared files.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new = B.new
D.lit = B.lit
D.ell = B.ell
D.ln = B.ln
D.polyline = B.polyline
D.seam = B.seam
D.leaf = H.leaf
D.disc = H.disc
D.cyl = H.cyl
D.sweep = H.sweep
D.ramp = H.ramp
function D.fin() H.fin(B.c) end
-- shift the tone of an existing pixel along a 6-ramp (delta steps)
function D.shift(c, x, y, ramp, delta)
  local cur = c:get(x, y) if not cur then return end
  for i, h in ipairs(ramp) do
    if h:lower() == cur:lower() then c:px(x, y, ramp[max(1, min(#ramp, i + delta))]) return end
  end
end
-- spiral of 1px dots; clip optional mask
function D.spiral(c, cx, cy, rmax, turns, hex, clip, a0)
  local n = floor(rmax * turns * 2 * pi * 1.3)
  for i = 0, n do
    local t = i / n
    local a = (a0 or 0) + t * turns * 2 * pi
    local r = rmax * t
    local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5)
    if not clip or clip:has(x, y) then c:px(x, y, hex) end
  end
end
-- eye stalk: 1px line from (x0,y0) up to (x1,y1) then a 2x3 ink eye with glint, top-left at (x1-1, y1-2)
function D.stalk(c, x0, y0, x1, y1, hex, closed)
  B.ln(c, x0, y0, x1, y1 + 1, hex)
  B.ln(c, x0 + 1, y0, x1 + 1, y1 + 1, hex)
  if closed then
    c:px(x1 - 1, y1 + 1, D.INK) c:px(x1, y1 + 1, D.INK) c:px(x1 + 1, y1 + 1, D.INK) c:px(x1 + 2, y1 + 1, D.INK)
  else
    c:eyeSmall(x1, y1 - 2)
  end
end
-- ring outline of radius r
function D.ring(c, cx, cy, r, hex)
  for a = 0, 63 do local t = a / 64 * 2 * pi
    c:px(floor(cx + cos(t) * r + .5), floor(cy + sin(t) * r + .5), hex) end
end
-- translate the whole drawing
function D.move(c, dx, dy)
  local np, no = {}, {}
  for k, v in pairs(c.pix) do
    local x, y = k % c.w, k // c.w
    local nx, ny = x + dx, y + dy
    if nx >= 0 and ny >= 0 and nx < c.w and ny < c.h then np[ny * c.w + nx] = v no[ny * c.w + nx] = c.own[k] end
  end
  c.pix, c.own = np, no
end
return D
