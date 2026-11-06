-- hand-fork (final pass, Opus aC10_5). A slim garden hand fork on the diagonal: turned ash handle (grain lines, pale end
-- grain on the butt, a hang hole), brass ferrule with two rolled grooves, then a forged steel head whose shoulders sweep
-- out into three tapering tines. Steel: pillow bevel, bright edge on the lit side, specular streak on the middle tine,
-- AO where the tines leave the bridge and where wood meets brass.
-- quirk: a little loop of red-and-cream garden twine is tied through the hang hole.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("hand-fork")

local WOOD  = { "#4e2a26", "#7a4330", "#a5653e", "#c88a52", "#e2b273", "#f4d79e" }
local BRASS = { "#5e3420", "#94591f", "#c88a24", "#e8b434", "#f8d866", "#fff1b0" }
local STEEL = { "#33344f", "#4f5270", "#727793", "#9da2b8", "#c6cad8", "#eceef4" }
local TW    = { "#8f2c36", "#d04a3e", "#f6ead0" }

-- axis frame: handle at lower-left, tines to the upper-right
local OX, OY = 12.5, 52.5
local ux, uy = 1 / sqrt(2), -1 / sqrt(2)
local px, py = 1 / sqrt(2), 1 / sqrt(2)          -- +s = lower-right (shade side)
local function ts(x, y) local dx, dy = x - OX, y - OY return dx*ux + dy*uy, dx*px + dy*py end
local function at(t, s) return OX + ux*t + px*s, OY + uy*t + py*s end

-- handle half width: rounded butt, slim waist, slight swell toward the ferrule
local function hhw(t)
  if t < 2.6 then return sqrt(max(0, 2.6*2.6 - (2.6 - t)^2)) * (2.3 / 2.6) end
  if t < 9 then return 2.3 - (t - 2.6) * 0.06 end
  return 1.9 + (t - 9) * 0.04
end
local T_H, T_F, T_N, T_B, T_E = 23, 29, 32, 37, 55       -- handle end, ferrule end, neck end, bridge end, tine tips
local TINES = { -4.6, 0, 4.6 }
local function tineHW(t) local f = (t - T_B) / (T_E - T_B) return 1.25 - f * 0.75 end

local wood, brass, steel = HP.mask(), HP.mask(), HP.mask()
local S = {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = ts(x, y)
  local k = K(x, y)
  S[k] = { t, s }
  if t >= 0 and t < T_H and abs(s) <= hhw(t) then wood:set(x, y)
  elseif t >= T_H and t < T_F and abs(s) <= 2.45 then brass:set(x, y)
  elseif t >= T_F and t < T_N and abs(s) <= 1.6 then steel:set(x, y)
  elseif t >= T_N and t < T_B then
    local f = (t - T_N) / (T_B - T_N)
    local hw = 1.6 + 4.7 * (f * f * (3 - 2 * f))
    if abs(s) <= hw then steel:set(x, y) end
  elseif t >= T_B and t <= T_E then
    for _, sc in ipairs(TINES) do
      local tip = T_E - (sc == 0 and 0 or 1.5)
      if t <= tip and abs(s - sc) <= tineHW(t) then steel:set(x, y) end
    end
  end
end end
-- round off the bridge's top corners where it meets the outer tines (crotch gaps stay open)
local function cyln(x, y, hw, sc)
  local t, s = S[K(x, y)][1], S[K(x, y)][2]
  local sn = max(-0.95, min(0.95, (s - (sc or 0)) / (hw + 0.5)))
  return { px * sn, py * sn, sqrt(1 - sn * sn) }
end

-- wood: cylinder normals + grain
local tokW, tokB, tokS = A.tok("wood"), A.tok("brass"), A.tok("steel")
local nW, biasW = {}, {}
wood:each(function(x, y) local t = S[K(x, y)][1] nW[K(x, y)] = cyln(x, y, hhw(t))
  if t > T_H - 1.6 then biasW[K(x, y)] = -1 end end)
local idxW = A.shade(c, wood, nW, WOOD, { amb = 0.1, wrap = 0.3, bias = biasW, tok = tokW })
-- grain: thin darker streaks running along the handle, broken
wood:each(function(x, y) local k = K(x, y) local t, s = S[k][1], S[k][2]
  local g = (s + 0.6 * math.sin(t * 0.55)) % 1.9
  if t > 3.2 and t < T_H - 2 and g < 0.45 and X.hash(floor(t / 3), floor(s * 2), 3) > 0.35 then A.step(c, idxW, WOOD, x, y, -1, tokW) end
  -- pale end grain on the butt cap
  if t < 1.4 then c:put(x, y, (s < 0.5) and WOOD[6] or WOOD[5], tokW) end
end)
-- end grain rings
do local x, y = at(0.6, 0.4) c:put(floor(x + .5), floor(y + .5), WOOD[4], tokW) end
-- hang hole: dark eye with a lit lower lip
local hx, hy = at(5.2, 0)
hx, hy = floor(hx + .5), floor(hy + .5)
c:put(hx, hy, WOOD[1], tokW) c:put(hx + 1, hy, WOOD[1], tokW) c:put(hx, hy + 1, WOOD[2], tokW) c:put(hx + 1, hy + 1, WOOD[3], tokW)
c:put(hx - 1, hy, WOOD[2], tokW)
-- wood highlight streak (lit side)
for t = 8, 18, 1 do local x, y = at(t, -1.2) A.step(c, idxW, WOOD, floor(x + .5), floor(y + .5), 1, tokW) end
do local x, y = at(10.5, -1.3) c:put(floor(x + .5), floor(y + .5), WOOD[6], tokW) end

-- brass ferrule: cylinder + rolled grooves + bright edge
local nB = {}
brass:each(function(x, y) nB[K(x, y)] = cyln(x, y, 2.45) end)
local idxB = A.shade(c, brass, nB, BRASS, { amb = 0.12, wrap = 0.3, tok = tokB })
brass:each(function(x, y) local k = K(x, y) local t, s = S[k][1], S[k][2]
  local d1, d2 = t - (T_H + 1.8), t - (T_H + 4.2)
  if abs(d1) < 0.5 or abs(d2) < 0.5 then A.step(c, idxB, BRASS, x, y, -2, tokB)
  elseif (d1 > -1.5 and d1 <= -0.5) or (d2 > -1.5 and d2 <= -0.5) then A.step(c, idxB, BRASS, x, y, 1, tokB) end
end)
do local x, y = at(T_H + 0.6, -1.4) c:put(floor(x + .5), floor(y + .5), BRASS[6], tokB) end

-- steel head: pillow bevel blended with tine cylinders
local nP = X.pillow(steel, 1.6)
local biasS = {}
steel:each(function(x, y) local k = K(x, y) local t, s = S[k][1], S[k][2]
  local a = nP[k]
  local hw, sc
  if t < T_N then hw, sc = 1.6, 0
  elseif t >= T_B then
    sc = TINES[1] for _, q in ipairs(TINES) do if abs(s - q) < abs(s - sc) then sc = q end end
    hw = tineHW(t)
  end
  if sc then local b = cyln(x, y, hw, sc)
    nP[k] = { A.norm(a[1] * 0.4 + b[1] * 0.6, a[2] * 0.4 + b[2] * 0.6, a[3] * 0.4 + b[3] * 0.6) } end
  -- AO: where the steel leaves the brass, and in the crotches between tines
  if t < T_F + 1.2 then biasS[k] = -1 end
  if t >= T_B - 1 and t < T_B + 2.2 then
    local sc2 = TINES[1] for _, q in ipairs(TINES) do if abs(s - q) < abs(s - sc2) then sc2 = q end end
    if abs(s - sc2) > 0.7 then biasS[k] = -1 end
  end
end)
local idxS = A.shade(c, steel, nP, STEEL, { amb = 0.08, wrap = 0.2, bias = biasS, tok = tokS })
-- bright bevel edge on the lit (upper-left) border of the head
steel:each(function(x, y) local k = K(x, y)
  if not steel:has(x - 1, y) or not steel:has(x, y - 1) then
    if not steel:has(x + 1, y) or not steel:has(x, y + 1) then return end
    if (idxS[k] or 1) >= 3 then A.step(c, idxS, STEEL, x, y, 1, tokS) end
  end
end)
-- dark forging line across the bridge (where the neck was welded on)
for s = -1.4, 1.4, 0.5 do local x, y = at(T_N - 0.4, s) A.step(c, idxS, STEEL, floor(x + .5), floor(y + .5), -1, tokS) end
-- specular streak down the middle tine + one glint
for t = T_B + 2, T_B + 9 do local x, y = at(t, -0.6) local xi, yi = floor(x + .5), floor(y + .5)
  if steel:has(xi, yi) then c:put(xi, yi, STEEL[6], tokS) end end
do local x, y = at(T_B + 3, -0.6) c:put(floor(x + .5), floor(y + .5), A.CREAM, tokS) end
do local x, y = at(T_B - 1.5, -3.4) local xi, yi = floor(x + .5), floor(y + .5) if steel:has(xi, yi) then c:put(xi, yi, STEEL[6], tokS) end end
-- cool reflected light on the lower-right edge of each tine
steel:each(function(x, y) local k = K(x, y) local t = S[k][1]
  if t > T_B + 2 and t < T_E - 3 and not steel:has(x + 1, y + 1) and steel:has(x - 1, y - 1) and (idxS[k] or 1) <= 2 then
    c:put(x, y, "#5c7aa4", tokS) end end)

-- quirk: garden twine loop through the hang hole, a small tied knot, two short ends
local tok2 = A.tok("twine")
local loop = { { hx + 1, hy + 1 }, { hx + 3, hy + 3 }, { hx + 4, hy + 6 }, { hx + 2, hy + 8 }, { hx - 1, hy + 7 }, { hx - 2, hy + 4 }, { hx - 1, hy + 2 } }
local lm = HP.line(loop, 1):cut(wood)
lm:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and TW[2] or TW[3], tok2) end)
c:put(hx + 2, hy + 8, TW[1], tok2) c:put(hx + 3, hy + 9, TW[2], tok2) c:put(hx + 1, hy + 9, TW[3], tok2)
A.save(c, "hand-fork")
