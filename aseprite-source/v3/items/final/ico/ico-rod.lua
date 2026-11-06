-- ico-rod (Opus artist pass). Slim cane fishing rod on the diagonal: cork grip lower-left, gold thread whipping, a
-- small steel reel hung under the rod, tapering cane with node rings and two eyelets; the line drops from the tip to a
-- red/cream float and a hook. Material: speckled cork, cylinder-lit cane (6 tones, raised nodes = dark groove + lit
-- lip), twisted thread wrap, bevelled steel reel with a dark hub and bright rim, glossy float with one glint.
-- quirk: a little pink worm on the hook is waving hello.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_0.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = D.new("ico-rod")
local CANE = { "#4e2c26", "#80502c", "#b0782e", "#d6a03e", "#efc866", "#fbe6a4" }
local LINE = "#efe8f4"
local AX, AY, BX, BY = 11, 54, 50, 9
local function at(t) return AX + (BX - AX) * t, AY + (BY - AY) * t end

-- fishing line first (rod tip painted over it), then float + hook
local tokL = { r = { name = "line" } }
for y = 10, 30 do c:put(51, y, LINE, tokL) end
c:put(50, 9, LINE, tokL)
for y = 40, 43 do c:put(51, y, LINE, tokL) end
-- hook (steel J)
local tokH = { r = { name = "hook" } }
for _, p in ipairs{ {51, 44, 4}, {51, 45, 3}, {51, 46, 3}, {52, 47, 2}, {53, 47, 3}, {54, 46, 4}, {54, 45, 5} } do c:put(p[1], p[2], D.STEEL[p[3]], tokH) end
-- quirk: pink worm curled on the hook, head up and waving
local tokW = { r = { name = "worm" } }
local WORM = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local wm = {
  "...hH.",
  "..hHHd",
  "..HHd.",
  ".hHd..",
  "hHd...",
  "HHd...",
  ".Hd...",
}
local WC = { h = WORM[4], H = WORM[3], d = WORM[2] }
for yy, row in ipairs(wm) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if WC[ch] then c:put(53 + xx - 1, 40 + yy - 1, WC[ch], tokW) end end end
c:put(57, 41, D.INK, tokW)
-- float: red cap, cream belly, little stem
local fm, fn = G.oval(51, 35, 4.4, 4.8, 0)
local fv = X.light(fn, { amb = 0.08, wrap = 0.25 })
local tokF = { r = { name = "float" } }
fm:each(function(x, y) local k = K(x, y)
  local rp = y <= 34 and D.RED or D.CRM
  local i = 1 for j, t in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.84 } do if fv[k] >= t then i = j + 1 end end
  if y == 35 then i = i - 1 end
  c:put(x, y, rp[max(1, min(6, i))], tokF)
end)
for x = 48, 54 do if fm:has(x, 35) then D.shift(c, x, 34, D.RED, -1) end end
c:put(48, 32, D.CREAM, tokF) c:put(49, 31, D.RED[6], tokF) c:put(50, 31, D.RED[6], tokF)
c:put(51, 29, D.RED[3], tokF) c:put(51, 30, D.RED[2], tokF)

-- reel hung under the rod (lower-right of the shaft)
local tokR = { r = { name = "reel" } }
local rx, ry = 27, 45
for _, p in ipairs{ {23, 41}, {24, 42}, {25, 42} } do c:put(p[1], p[2], D.STEEL[2], tokR) end
local reel, rn = G.oval(rx, ry, 4.6, 4.6, 0)
local rb = {}
reel:each(function(x, y) local d = sqrt((x - rx)^2 + (y - ry)^2) if d < 1.6 then rb[K(x, y)] = -3 elseif d < 2.6 then rb[K(x, y)] = 1 end end)
D.tone(c, reel, rn, D.STEEL, { bias = rb, tok = tokR, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
c:put(25, 42, D.STEEL[6], tokR)
-- crank knob
for _, p in ipairs{ {32, 48, 3}, {33, 49, 2} } do c:put(p[1], p[2], D.STEEL[p[3]], tokR) end
for _, p in ipairs{ {33, 50, 5}, {34, 50, 4}, {33, 51, 3}, {34, 51, 2}, {35, 50, 3}, {35, 51, 2} } do c:put(p[1], p[2], D.WOOD[p[3]], tokR) end
-- spool line wound on the reel (cream arc)
for _, p in ipairs{ {25, 44}, {26, 43}, {27, 43}, {28, 43} } do c:put(p[1], p[2], "#e3d8ea", tokR) end

-- rod: tapered cylinder
local function hw(t)
  if t < 0.22 then return 3.1 end
  if t < 0.27 then return 2.5 end
  return 2.15 - (t - 0.27) / 0.73 * 0.95
end
local rod, rnrm, RT, RS = X.cyl(AX, AY, BX, BY, hw)
local LEN = sqrt((BX - AX)^2 + (BY - AY)^2)
local v = X.light(rnrm, { amb = 0.08, wrap = 0.25 })
local tokC = { r = { name = "rod" } }
local cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }
local bias = {}
rod:each(function(x, y) local k = K(x, y) local t = RT[k]
  if t > 0.27 and t < 0.31 then bias[k] = -1 end   -- AO where the cane leaves the whipping
end)
local function tix(k) local i = 1 for j, tt in ipairs(cuts) do if v[k] >= tt then i = j + 1 end end return max(1, min(6, i + (bias[k] or 0))) end
rod:each(function(x, y) local k = K(x, y) local t = RT[k]
  local i = tix(k)
  if t < 0.22 then
    -- cork: speckled pits, rounded butt cap
    local col = D.CORK[i]
    if X.hash(x, y, 3) < 0.2 then col = D.CORK[max(1, i - 2)] end
    if t < 0.035 then col = D.WOOD[max(1, i - 1)] end
    c:put(x, y, col, tokC)
  elseif t < 0.27 then
    -- gold thread whipping: twist lines across
    local ph = (t * LEN + RS[k] * 1.2) % 2
    local gi = ph < 1 and i or i - 2
    c:put(x, y, D.AMBER[max(1, min(6, gi))], tokC)
  else
    c:put(x, y, CANE[i], tokC)
  end
end)
-- cane nodes: dark groove + lit lip toward the tip
for _, tn in ipairs{ 0.42, 0.58, 0.74, 0.88 } do
  rod:each(function(x, y) local k = K(x, y) local d = (RT[k] - tn) * LEN
    if d > -0.5 and d < 0.5 then D.set(c, x, y, CANE[max(1, tix(k) - 2)])
    elseif d >= 0.5 and d < 1.5 and RS[k] < 0.3 then D.set(c, x, y, CANE[min(6, tix(k) + 1)]) end end)
end
-- eyelets: steel loops under the cane
for _, te in ipairs{ 0.52, 0.8 } do
  local x, y = at(te)
  local ex, ey = floor(x + 2.4 + .5), floor(y + 2.2 + .5)
  c:put(ex, ey, D.STEEL[4], tokC) c:put(ex + 1, ey, D.STEEL[2], tokC) c:put(ex, ey + 1, D.STEEL[2], tokC)
end
-- specular streak on the cane's lit side
rod:each(function(x, y) local k = K(x, y) if RT[k] > 0.33 and RT[k] < 0.5 and RS[k] < -0.4 and RS[k] > -0.8 then D.set(c, x, y, CANE[6]) end end)
local gx, gy = at(0.36) c:put(floor(gx - 1 + .5), floor(gy - 1 + .5), D.CREAM, tokC)
-- tip ferrule
c:put(BX, BY, D.STEEL[4], tokC) c:put(BX - 1, BY + 1, D.STEEL[3], tokC)

D.save(c, "ico-rod")
