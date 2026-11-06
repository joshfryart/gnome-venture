-- mackerel-rice (final pass, Opus aC21_5). A glazed indigo rice bowl (cream lip, tapering body, foot ring, a row of
-- cream glaze dots, specular streak, cool bounce on the shade side) heaped with a dome of rice (grain texture) and
-- topped with a grilled mackerel fillet laid on the diagonal: silver-blue skin with dark tiger bars and charred
-- grill stripes, crisp golden edge, warm cooked flesh showing on the cut side, an oily glint. A serrated shiso leaf
-- tucks under the left end, two scallion rings and sesame on top; a slim pair of chopsticks leans on the right rim.
-- AO where the fillet sits on the rice and where the rice meets the rim. Ground shadow under the bowl.
-- History: Sonnet draft (dC21) replaced.
-- quirk: a single curl of steam rises from the hot fillet.
local NAME = "mackerel-rice"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local BOWL  = { "#1a1e48", "#262f6e", "#334a96", "#4e6cb8", "#7c9ad6", "#b4caee" }
local LIP   = { "#a89a9a", "#d8ccbc", "#f2e8d0" }
local RICE  = { "#8a8296", "#b0aab6", "#d0ccd2", "#e6e2de", "#f4f0e6", "#fbf8ee" }
local SKIN  = { "#1c2440", "#2c4262", "#466684", "#6a8ea4", "#9cb8c4", "#d0e0e0" }
local FLESH = { "#7a3e2e", "#a85e3e", "#cc8452", "#e4a86c", "#f2c890", "#fae4b8" }
local CHAR, CRISP = "#3a2420", "#c88a3a"
local LEAF  = { "#16382e", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STICK = { "#5a3528", "#864c33", "#b97a4a", "#e2b480" }
local CREAM, STEAM = "#fff4d6", "#e4f6ff"

c:groundShadow(32, 56, 15, 2)

-- masks
local CX, RY = 32, 37
local bowl = HP.mask()
for y = RY, 53 do for x = 8, 56 do
  local nx, ny = (x - CX) / 22.5, (y - RY) / 16.5
  if nx * nx + ny * ny <= 1 then bowl:set(x, y) end end end
local foot = c:rect(24, 52, 40, 54):cut(bowl)
local rim = c:ellipse(CX, RY, 22, 3)
local rice = c:ellipse(CX, RY - 1, 19, 11)
rice:cut(rim:copy():cut(c:ellipse(CX, RY, 20, 2)))   -- rice sits inside the rim
rice:each(function() end)
local ricecut = HP.mask() rice:each(function(x, y) if y > RY + 1 then ricecut:set(x, y) end end) rice:cut(ricecut)

local fm, fn, FT, FS = A.blade(16, 31, 30, 22, 46, 27, function(t)
  if t > 0.98 then return -1 end
  return max(1.5, 4.4 * min(1, sin(pi * min(1, t * 0.94 + 0.06)) ^ 0.35))
end, { fold = 0.15 })
local shiso, sn, ST, SS, slen = A.blade(22, 30, 14, 25, 9, 31, function(t)
  if t > 0.98 then return -1 end
  return max(0.5, 3.8 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
end, { fold = 0.45 })
local scut = {}
shiso:each(function(x, y) local k = K(x, y) local ph = ST[k] * slen / 2.4 local f = ph - floor(ph)
  if abs(SS[k]) > 0.7 + 0.3 * f then scut[#scut + 1] = k end end)
for _, k in ipairs(scut) do shiso.s[k] = nil end
shiso:cut(fm)
local s1 = { { 42, 33 }, { 47, 25 }, { 52, 18 }, { 56, 12 } }
local s2 = { { 45, 35 }, { 50, 27 }, { 55, 20 }, { 59, 14 } }
local c1m, c1n = A.tube(s1, function(t) return 0.85 end)
local c2m, c2n = A.tube(s2, function(t) return 0.85 end)

-- bowl body
local btok = { r = { name = "bowl" } }
local bn = {}
bowl:each(function(x, y) local nx, ny = (x - CX) / 23, (y - RY) / 17
  bn[K(x, y)] = { A.norm(nx, ny * 0.6 + 0.15, sqrt(max(0.03, 1 - nx * nx - ny * ny))) } end)
local bb = {}
local bidx = A.shade(c, bowl, bn, BOWL, { bias = bb, tok = btok, amb = 0.1, wrap = 0.3 })
-- glaze dots row
for x = 12, 52, 3 do local nx = (x - CX) / 22.5 local y = floor(RY + 6 + 1.5 * (1 - nx * nx) + .5)
  if bowl:has(x, y) then c:put(x, y, (x < CX + 8) and LIP[3] or LIP[2], btok) end end
-- specular streak
for _, q in ipairs{ { 15, 41 }, { 15, 42 }, { 16, 43 }, { 16, 44 } } do c:put(q[1], q[2], BOWL[6], btok) end
c:put(15, 40, CREAM, btok)
-- cool bounce on the shade side, deep row under the rim
bowl:edge():each(function(x, y) if x > CX + 10 and y > RY + 4 then c:put(x, y, "#5a5ea8", btok) end end)
for x = 10, 54 do local y = RY + 2 if bowl:has(x, y) and not rim:has(x, y) then c:put(x, y, BOWL[1], btok) end end
-- foot ring
local ftok = { r = { name = "foot" } }
foot:each(function(x, y) local col = BOWL[3] if x < 28 then col = BOWL[4] elseif x > 36 then col = BOWL[2] end
  if y == 52 then col = BOWL[1] end c:put(x, y, col, ftok) end)
-- rim lip (front arc only; back hidden by rice)
local rtok = { r = { name = "rim" } }
rim:each(function(x, y) if y >= RY or not rice:has(x, y) then
  local col = LIP[3] if x > CX + 12 then col = LIP[2] end if y > RY + 1 then col = LIP[1] end
  if not rice:has(x, y) then c:put(x, y, col, rtok) end end end)

-- rice dome
local rtk = { r = { name = "rice" } }
local rn = X.sphere(CX, RY - 1, 19, rice)
local rb = {}
X.ao(rb, rice, fm, 1, -1) A.cast(rb, rice, fm, 1, 2, -1) X.ao(rb, rice, shiso, 1, -1)
X.ao(rb, rice, c1m, 1, -1)
rice:each(function(x, y) if y >= RY - 1 then rb[K(x, y)] = (rb[K(x, y)] or 0) - 1 end end)
local ridx = A.shade(c, rice, rn, RICE, { bias = rb, tok = rtk, amb = 0.25, wrap = 0.4, cuts = { 0.2, 0.36, 0.52, 0.66, 0.8 } })
-- grain texture: short 2x1 grains outlined by darker gaps
rice:each(function(x, y) local k = K(x, y)
  local g = (x + 2 * y + floor(y / 2)) % 4
  if g == 0 and X.hash(x, y, 2) > 0.25 and (ridx[k] or 1) > 1 then A.step(c, ridx, RICE, x, y, -1, rtk) end
  if g == 2 and X.hash(x, y, 4) > 0.8 and (ridx[k] or 1) >= 4 then A.step(c, ridx, RICE, x, y, 1, rtk) end end)
-- sesame
local sesame = { { 40, 30 }, { 26, 34 }, { 44, 33 } }
for _, q in ipairs(sesame) do if rice:has(q[1], q[2]) and not fm:has(q[1], q[2]) then
  c:put(q[1], q[2], "#f0dca8", rtk) c:put(q[1] + 1, q[2], "#c8a870", rtk) end end

-- shiso leaf
local stk = { r = { name = "shiso" } }
local sb = {} X.ao(sb, shiso, fm, 1, -1)
A.shade(c, shiso, sn, LEAF, { bias = sb, tok = stk, amb = 0.15, wrap = 0.3 })
shiso:each(function(x, y) local k = K(x, y)
  if sb[k] then return end
  if abs(SS[k]) < 0.16 and ST[k] < 0.93 then c:put(x, y, SS[k] <= 0 and LEAF[6] or LEAF[3], stk) end
  local ph = (ST[k] * slen - abs(SS[k]) * 2.5) / 2.6 local f = ph - floor(ph)
  if f > 0.85 and abs(SS[k]) > 0.25 and abs(SS[k]) < 0.6 then c:put(x, y, SS[k] < 0 and LEAF[5] or LEAF[2], stk) end end)

-- fillet
local ftk = { r = { name = "fillet" } }
local fb = {}
local fv = X.light(fn, { amb = 0.12, wrap = 0.3 })
fm:each(function(x, y) local k = K(x, y) local s, t = FS[k], FT[k]
  local i = A.q(fv[k])
  local col
  if s > 0.42 then
    -- cut side: cooked flesh, darker toward the bottom (AO onto rice side)
    i = (s > 0.75) and 2 or 4
    if (x + floor(y * 1.5)) % 5 == 0 then i = i - 1 end   -- flake lines
    col = FLESH[max(1, min(6, i + ((t < 0.15) and 1 or 0)))]
  else
    i = max(1, min(6, i))
    col = SKIN[i]
    local w = sin(x * 1.2 + 2.2 * sin(y * 0.8))
    if s < 0.1 and w > 0.7 then col = SKIN[max(1, i - 2)] end
    -- grill stripes: diagonal bands
    local g = (x + y) % 7
    if g == 0 then col = CHAR elseif g == 1 then col = "#6a4a3a" end
    if s > 0.22 then col = (x % 3 == 0) and FLESH[5] or CRISP end   -- crisp golden edge between skin and flesh
  end
  c:put(x, y, col, ftk)
end)
-- top edge char + oily glint
fm:edge():each(function(x, y) local k = K(x, y) if FS[k] < -0.6 and (x % 4 == 1) then c:put(x, y, "#5a4038", ftk) end end)
c:put(27, 24, CREAM, ftk) c:put(28, 24, SKIN[6], ftk) c:put(36, 23, SKIN[6], ftk)
-- tail-end (right) cut shows flesh ring
-- scallion rings
local gtk = { r = { name = "scallion" } }
for _, q in ipairs{ { 22, 26 }, { 39, 25 } } do
  local x, y = q[1], q[2]
  c:put(x, y - 1, LEAF[6], gtk) c:put(x - 1, y, LEAF[5], gtk) c:put(x + 1, y, LEAF[4], gtk) c:put(x, y + 1, LEAF[3], gtk)
  c:put(x, y, "#e8f0b0", gtk) c:put(x - 1, y - 1, LEAF[5], gtk) c:put(x + 1, y + 1, LEAF[3], gtk)
  c:put(x + 1, y - 1, LEAF[4], gtk) c:put(x - 1, y + 1, LEAF[4], gtk)
end

-- chopsticks (over the rice edge, resting on the rim)
for i, p in ipairs{ { c1m, c1n }, { c2m, c2n } } do
  local m = p[1]:copy()
  if i == 1 then m:cut(c2m) end
  local tk = { r = { name = "stick" .. i } }
  local idx = A.shade(c, m, p[2], STICK, { tok = tk, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
end
-- lacquer tip bands near the top
for _, q in ipairs{ { 54, 15 }, { 55, 14 }, { 57, 17 }, { 58, 16 } } do c:put(q[1], q[2], "#b52e3f", { r = { name = "stick1" } }) end

-- quirk: steam curl
local stm = { r = { name = "steam" } }
for _, q in ipairs{ { 31, 19 }, { 30, 18 }, { 30, 17 }, { 31, 16 }, { 32, 15 }, { 32, 14 }, { 31, 13 }, { 30, 12 } } do
  c:put(q[1], q[2], STEAM, stm) end
c:put(32, 15, "#b9e2f5", stm)

A.save(c, "ph", NAME)
