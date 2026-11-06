-- ico-refresh (final pass, Opus). Two glossy enamel arrows chasing each other clockwise round a ring: each a 7-px
-- round tube (6-tone leaf green, lit per pixel across the tube so the outer upper-left and inner lower-right edges
-- turn), ending in a broad bevelled arrowhead (pillow-lit with a lit ridge, a dark ambient row where the head joins
-- its shaft). A long specular streak on the top arc, a cool bounce on the lower one, clear air between each head and
-- the next tail.
-- quirk: the lower arrow has a little nick patched with a sticking plaster.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new("ico-refresh")
local GRN = { "#163c34", "#1f5c44", "#2c8450", "#45a85a", "#76c868", "#bde888" }
local PL  = { "#8e4c44", "#d0946e", "#f2c69a", "#ffe6c6" }
local CX, CY, R, W = 32, 32, 17, 3
local function P(a, r) return CX + cos(a) * r, CY + sin(a) * r end

local function arrow(a0, a1, tok)
  local m, n, S = A.arc(CX, CY, R, W, a0, a1)
  local hb, ht = a1, a1 + 0.72
  local bx1, by1 = P(hb, R - W - 4)
  local bx2, by2 = P(hb, R + W + 4)
  local tx, ty = P(ht, R + 0.3)
  local hm = HP.poly{ { bx1, by1 }, { bx2, by2 }, { tx, ty } }
  hm:cut(m)
  local idx = A.shade(c, m, n, GRN, { amb = 0.03, wrap = 0.12, cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 }, tok = tok })
  local hn = X.pillow(hm, 2.5)
  local hidx = A.shade(c, hm, hn, GRN, { amb = 0.05, wrap = 0.15, cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 }, tok = tok })
  -- ridge along the circle line catches light; back edge of the barbs (next to the shaft end) falls dark
  hm:each(function(x, y)
    local r = sqrt((x - CX)^2 + (y - CY)^2)
    if abs(r - R) < 0.75 then A.step(c, hidx, GRN, x, y, 1, tok) end
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      if m:has(x + d[1], y + d[2]) then A.step(c, hidx, GRN, x, y, -1, tok) break end
    end
  end)
  m:each(function(x, y)
    for _, d in ipairs{ {1,0}, {-1,0}, {0,1}, {0,-1} } do
      if hm:has(x + d[1], y + d[2]) then A.step(c, idx, GRN, x, y, -2, tok) break end
    end
  end)
  return m, idx, hm
end
local t1, t2 = { r = { name = "a1" } }, { r = { name = "a2" } }
local SPAN, S0 = pi - 0.72 - 0.4, pi + 0.2
local m1 = arrow(S0, S0 + SPAN, t1)               -- upper arc, head on the right pointing down
local m2, i2 = arrow(S0 - pi, S0 - pi + SPAN, t2) -- lower arc, head on the left pointing up

-- specular streak on the top arc's lit outer shoulder + one cream glint
for s = 0, 40 do
  local a = S0 + 0.25 + s / 40 * 0.6
  local x, y = floor(CX + cos(a) * (R + 1.5) + .5), floor(CY + sin(a) * (R + 1.5) + .5)
  if m1:has(x, y) then c:put(x, y, GRN[6], t1) end
end
do local x, y = P(S0 + 0.45, R + 1.5) c:put(floor(x + .5), floor(y + .5), A.CREAM, t1) end
-- cool reflected light on the lower arc's outer lower-right edge
m2:edge():each(function(x, y)
  local a = atan(y - CY, x - CX)
  local r = sqrt((x - CX)^2 + (y - CY)^2)
  if r > R + 2 and a > 0.3 and a < 1.25 then c:put(x, y, "#4f8f88", t2) end
end)

-- quirk: sticking plaster across the lower arrow (a strip 5 px wide, 1 px proud of the tube each side)
local pa = 0.62 * pi
local ux, uy = cos(pa), sin(pa)
local vx, vy = -uy, ux
local ptok = { r = { name = "plaster" } }
for y = 30, 63 do for x = 0, 40 do
  local r = (x - CX) * ux + (y - CY) * uy
  local s = (x - CX) * vx + (y - CY) * vy
  if r >= R - W - 1.4 and r <= R + W + 1.4 and abs(s) <= 2.4 then
    local i = 3
    if s < -1.2 then i = 4 elseif s > 1.2 then i = 2 end
    if abs(r - R) <= 1.2 and abs(s) <= 1.3 then i = 2 end -- pad
    c:put(x, y, PL[i], ptok)
  end
end end
local mx, my = P(pa, R) c:put(floor(mx + .5), floor(my + .5), PL[1], ptok)
do local x, y = P(pa, R - 2) c:put(floor(x + .5), floor(y + .5), PL[1], ptok) end
A.save(c, "ico-refresh")
