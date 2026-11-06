-- goat-cheese (B3, Opus single pass, replaces the Sonnet draft). A slim log of fresh chevre lying on the diagonal
-- (cut end upper-left, rounded closed end lower-right) with a white bloomy rind, plus one cut round lying flat in front.
-- Material: per-pixel cylinder light (6 cool-cream tones), crinkly bloom texture, chalky ivory paste on the cut face
-- with a darker cream line under the rind, crumb pits, a moist sheen glint, a thyme sprig with a cast shadow.
-- quirk: someone has taken a tiny bite out of the round (crumb left behind).
local NAME = "goat-cheese"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new(NAME)

local RIND = { "#5f5578", "#8e86a2", "#b8b1c2", "#d9d3d6", "#efe9de", "#fffaee" }
local PASTE = { "#a8907e", "#cdb79e", "#e4d3b6", "#f3e7cd", "#fdf5e2", "#fffbf0" }
local CREAMLINE = "#dcc49a"
local THY = { "#24544a", "#3f8a4c", "#6cb052", "#a8d872" }

-- log axis: cut face at A (upper-left), closed end at B (lower-right)
local Ax, Ay, Bx, By = 14, 21, 49, 35
local dx, dy = Bx - Ax, By - Ay
local L = sqrt(dx * dx + dy * dy)
local ux, uy = dx / L, dy / L
local px, py = -uy, ux                      -- perpendicular (lower-left side positive)
local HW = 7
local p = { { Ax, Ay }, { Ax + dx / 3, Ay + dy / 3 }, { Ax + 2 * dx / 3, Ay + 2 * dy / 3 }, { Bx, By } }
local lm, ln, LT, LS = A.tube(p, function() return HW end)
-- flatten the closed end into a half ellipse (log end seen at an angle) and cut the far side of the cut face
local capB = A.rell(Bx, By, px, py, HW + 0.3, 3.2)
local capA = A.rell(Ax, Ay, px, py, HW + 0.3, 4.4)
lm:each(function(x, y)
  local a = (x - Ax) * ux + (y - Ay) * uy
  if a > L and not capB:has(x, y) then lm.s[K(x, y)] = nil end
  if a < 0 then lm.s[K(x, y)] = nil end
end)
capB:each(function(x, y)
  local a = (x - Ax) * ux + (y - Ay) * uy
  if a >= L and not lm:has(x, y) then
    lm:set(x, y)
    local s = ((x - Bx) * px + (y - By) * py) / (HW + 0.5)
    s = max(-0.97, min(0.97, s))
    local e = ((x - Bx) * ux + (y - By) * uy) / 3.7
    ln[K(x, y)] = A.norm(px * s + ux * e * 0.8, py * s + uy * e * 0.8, sqrt(max(0.05, 1 - s * s)))
  end
end)
-- bloom texture: crinkles shift the light up/down by one tone
local bias = {}
lm:each(function(x, y)
  local h = X.hash(floor(x / 2) + floor(y / 1), floor(y / 2) - floor(x / 3), 4)
  if h > 0.86 then bias[K(x, y)] = -1 elseif h < 0.07 then bias[K(x, y)] = 1 end
end)
local ltok = { r = { name = "rind" } }
A.tone(c, lm, ln, RIND, { bias = bias, tok = ltok, cuts = { 0.22, 0.4, 0.57, 0.73, 0.88 }, amb = 0.1, wrap = 0.3 })
-- cool reflected light on the lower-left underside edge
local rim = X.rim(ln, { A.norm(-0.2, 0.9, 0.1)[1], A.norm(-0.2, 0.9, 0.1)[2], A.norm(-0.2, 0.9, 0.1)[3] })
lm:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.75 then A.setp(c, x, y, RIND, 3) end end)

-- cut face at A: flat ellipse facing upper-left
local face = capA:copy()
local fe1 = face:edge()
local fe2 = face:copy():cut(fe1):edge()
face:each(function(x, y)
  local s = ((x - Ax) * px + (y - Ay) * py) / HW            -- -1 top-right .. +1 bottom-left
  local e = ((x - Ax) * ux + (y - Ay) * uy) / 4.4
  if fe1:has(x, y) then A.setp(c, x, y, RIND, s < -0.2 and 5 or 4)
  elseif fe2:has(x, y) then c:put(x, y, CREAMLINE) A.store[K(x, y)] = { PASTE, 2 }
  else
    local i = 5
    if s > 0.45 then i = 4 end
    if s < -0.55 and e > 0 then i = 4 end
    if X.hash(x, y, 21) > 0.88 then i = i - 1 end            -- crumbly pits
    A.setp(c, x, y, PASTE, i)
  end
end)
-- moist sheen
c:put(floor(Ax - 2), floor(Ay - 2), PASTE[6]) c:put(floor(Ax - 1), floor(Ay - 2), PASTE[6])
c:put(floor(Ax - 2), floor(Ay - 1), "#fffdf6")

-- thyme sprig lying across the top of the log, with cast shadow on the rind
local sprig = { { 24, 19 }, { 27, 19 }, { 30, 19 }, { 33, 20 }, { 36, 21 }, { 39, 22 }, { 41, 23 } }
local sm = HP.mask()
for i = 1, #sprig - 1 do
  local a, b = sprig[i], sprig[i + 1]
  for t = 0, 1, 0.2 do sm:set(floor(a[1] + (b[1] - a[1]) * t + .5), floor(a[2] + (b[2] - a[2]) * t + .5)) end
end
local leaves = { { 25, 18 }, { 28, 20 }, { 31, 18 }, { 34, 21 }, { 36, 20 }, { 39, 21 }, { 41, 22 } }
local lfm = HP.mask()
for _, q in ipairs(leaves) do lfm:set(q[1], q[2]) lfm:set(q[1] + 1, q[2]) end
local all = sm:copy():add(lfm)
A.contact(c, all, 0, 1, 2)
sm:each(function(x, y) A.setp(c, x, y, THY, 2) end)
lfm:each(function(x, y) A.setp(c, x, y, THY, (x % 2 == 0) and 4 or 3) end)

-- the cut round lying flat in front: top face + 2px rind side
local RX, RY, RCX, RCY = 8, 3.6, 20, 42
local top = c:ellipse(RCX, RCY, RX, RY)
local side = c:ellipse(RCX, RCY + 2, RX, RY):cut(top)
-- the bite (quirk)
local bite = c:ellipse(RCX + 6.5, RCY - 1.5, 2.2, 1.8):add(c:ellipse(RCX + 7.5, RCY + 1, 1.6, 1.6))
top:cut(bite) side:cut(bite)
side:each(function(x, y)
  local u = (x - RCX) / RX
  A.setp(c, x, y, RIND, u < -0.5 and 4 or (u < 0.4 and 3 or 2))
end)
for x = RCX - RX, RCX + RX do if side:has(x, RCY + 2 + floor(RY)) or side:has(x, RCY + 5) then
  local y = side:has(x, RCY + 5) and RCY + 5 or RCY + 2 + floor(RY) A.shift(c, x, y, -1) end end
local te1 = top:edge()
local te2 = top:copy():cut(te1):edge()
top:each(function(x, y)
  local u, v = (x - RCX) / RX, (y - RCY) / RY
  if te1:has(x, y) and not bite:grow(1):has(x, y) then A.setp(c, x, y, RIND, (u + v < -0.3) and 6 or 5)
  elseif te2:has(x, y) and not bite:grow(1):has(x, y) then c:put(x, y, CREAMLINE) A.store[K(x, y)] = { PASTE, 2 }
  else
    local i = (u + v < -0.2) and 5 or 4
    if X.hash(x, y, 33) > 0.86 then i = i - 1 end
    A.setp(c, x, y, PASTE, i)
  end
end)
-- bite edge: crumbly paste wall, darker
bite:grow(1):each(function(x, y) if top:has(x, y) then A.setp(c, x, y, PASTE, 3) end
  if side:has(x, y) then A.setp(c, x, y, PASTE, 2) end end)
c:put(RCX - 3, RCY - 1, "#fffdf6") c:put(RCX - 2, RCY - 1, PASTE[6])
-- crumb
A.setp(c, RCX + 10, RCY + 3, PASTE, 4) A.setp(c, RCX + 11, RCY + 3, PASTE, 3)

A.save(c, NAME)
