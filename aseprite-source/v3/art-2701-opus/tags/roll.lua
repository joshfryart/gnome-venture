-- roll (Opus). Tag "evade" (Roll: its next hit misses). A woodlouse curled into an armoured ball and rolling away to
-- the right: slate-blue plates fan out in overlapping arcs from where its head and tail tuck together, a little face
-- with antennae and tucked legs peeks out at the front, two spin arcs ride over the top and dust puffs kick up
-- behind it. Material: 6-tone glossy chitin, each plate with a dark seam and a lit overlapping lip, one specular.
-- quirk: it winks as it rolls clear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = O.new("roll")

local PL   = { "#1f2440", "#2c3458", "#3e4a78", "#566a9c", "#7a90bf", "#b4c4e4" }
local BELLY= { "#6e4a5a", "#a87a86", "#d4a8ac", "#f4d4cc" }
local DUST = { "#a89e94", "#cfc5b6", "#efe6d6" }
local SWO  = { "#5f9ad0", "#8bc4ea", "#e4f6ff" }
local GRND = { "#74758c", "#aaa9b8" }

local CX, CY, R = 32, 30, 16

-- ground shadow
c:groundShadow(CX + 1, 48, 13, 1.6)

-- dust puffs behind (left, low)
do
  local tok = O.tok("dust")
  for _, d in ipairs{ { 13, 44, 4 }, { 7, 41, 2.6 }, { 17, 39, 2 } } do
    local m = O.oval(d[1], d[2], d[3], d[3] * 0.8)
    local inner = O.oval(d[1] - 0.6, d[2] - 0.6, d[3] - 1.2, d[3] * 0.8 - 1.2)
    m:each(function(x, y) c:put(x, y, inner:has(x, y) and DUST[3] or DUST[2], tok) end)
    m:each(function(x, y) if not m:has(x + 1, y + 1) then c:put(x, y, DUST[1], tok) end end)
  end
end

-- spin arcs riding over the top-left of the ball (behind it)
do
  local tok = O.tok("spin")
  for i, a in ipairs{ { R + 4, 3.5, 4.35 }, { R + 4, 2.75, 3.25 } } do
    for t = a[2], a[3], 0.008 do
      local x, y = floor(CX + cos(t) * a[1] + .5), floor(CY + sin(t) * a[1] + .5)
      local f = (t - a[2]) / (a[3] - a[2])
      c:put(x, y, f > 0.6 and SWO[3] or SWO[2], tok)
      if f > 0.3 then
        local x2, y2 = floor(CX + cos(t) * (a[1] + 1) + .5), floor(CY + sin(t) * (a[1] + 1) + .5)
        c:put(x2, y2, SWO[1], tok)
      end
    end
    -- arrow head at the leading end
    local t = a[3]
    local hx, hy = floor(CX + cos(t) * a[1] + .5), floor(CY + sin(t) * a[1] + .5)
    c:put(hx + 1, hy, SWO[3], tok) c:put(hx, hy - 1, SWO[2], tok) c:put(hx, hy + 1, SWO[2], tok)
  end
end

-- the ball
local ball, bn = O.oval(CX, CY, R, R - 0.5)
-- pole where head and tail tuck together: lower right, on the rim
local PA = 0.75
local PX, PY = CX + cos(PA) * (R + 7), CY + sin(PA) * (R + 7)
local plates = {}
do
  local tok = O.tok("plates")
  local idx = O.shade(c, ball, bn, PL, { tok = tok, amb = 0.08, wrap = 0.2 })
  local W = 4.7
  ball:each(function(x, y) local k = K(x, y)
    local d = sqrt((x - PX) ^ 2 + (y - PY) ^ 2)
    local band = floor((d - 9) / W)
    local f = (d - 9) / W - band
    plates[k] = band
    if f < 0.2 then O.step(c, idx, PL, x, y, -3, tok)          -- seam (dark, under the next plate's lip)
    elseif f < 0.42 then O.step(c, idx, PL, x, y, 1, tok)      -- lit lip of the overlapping plate
    elseif f > 0.8 then O.step(c, idx, PL, x, y, -1, tok) end  -- plate rolls under toward the next seam
  end)
  -- specular on the upper-left of the dome
  local sp = X.spec(bn, 50)
  ball:each(function(x, y) local k = K(x, y) if sp[k] > 0.8 then c:put(x, y, PL[6], tok) end end)
  -- tiny side notches along the plate edges on the rim (the plate ends)
  ball:edge():each(function(x, y) local k = K(x, y)
    local d = sqrt((x - PX) ^ 2 + (y - PY) ^ 2)
    if ((d - 9) / W) % 1 < 0.22 then c:put(x, y, PL[1], tok) end
  end)
end

-- face + belly tucked at the pole (front, lower right)
do
  local tok = O.tok("face")
  local face = O.oval(CX + 10, CY + 8.5, 6, 5, 0.75):clip(ball)
  local fnrm = {} face:each(function(x, y) local a = bn[K(x, y)] fnrm[K(x, y)] = { a[1] * 0.5, a[2] * 0.5, 1 } end)
  O.shade(c, face, fnrm, BELLY, { tok = tok, amb = 0.25, cuts = { 0.25, 0.5, 0.75 } })
  -- tucked legs: little dark ticks along the belly rim
  for _, p in ipairs{ { CX + 4, CY + 14 }, { CX + 6, CY + 13 }, { CX + 8, CY + 12 } } do c:put(p[1], p[2], BELLY[1], tok) c:put(p[1] + 1, p[2], BELLY[3], tok) end
  -- quirk: winking face. open eye (pill + glint) and a closed ^ wink
  local ex, ey = CX + 7, CY + 5
  c:put(ex, ey, "#2b1c26", tok) c:put(ex, ey + 1, "#2b1c26", tok) c:put(ex + 1, ey, "#2b1c26", tok) c:put(ex + 1, ey + 1, "#2b1c26", tok)
  c:put(ex, ey, "#fff4d6", tok)
  O.map(c, { ".i.", "i.i" }, ex + 4, ey, { i = "#2b1c26" }, tok)
  -- small smile
  O.map(c, { "i...i", ".iii." }, ex + 1, ey + 4, { i = "#7a3a4a" }, tok)
  c:put(ex - 1, ey + 3, "#f5809f", tok) c:put(ex - 2, ey + 3, "#f5809f", tok)
end

-- antennae poking out ahead (to the right)
do
  local tok = O.tok("ant")
  for _, A in ipairs{ { { CX + 14, CY + 4 }, { CX + 18, CY + 1 }, { CX + 21, CY - 3 }, { CX + 22, CY - 6 } },
                       { { CX + 15, CY + 7 }, { CX + 19, CY + 6 }, { CX + 22, CY + 4 }, { CX + 24, CY + 1 } } } do
    for t = 0, 1, 0.02 do
      local x, y = O.bez(A, t)
      c:put(floor(x + .5), floor(y + .5), t > 0.8 and PL[5] or PL[3], tok)
    end
  end
end

O.save(c, "roll")
