-- sages-draught (final, Sonnet high single pass). A slim long-necked flask: thick pale glass (bright left rim, teal
-- shade rim, pale core) holding a murky sage-green brew (per-pixel lit, bright meniscus, cool bounce, rising
-- bubbles) with a pale sage leaf drifting inside, a granular cork stopper and a twist of twine knotted round the neck.
-- quirk: a furry grey-green sage leaf is stuck to the cork like a feather.
local NAME = "sages-draught"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local GLASS = { "#4a7f98", "#6fa8b8", "#98cccc", "#bfe6e2", "#def6ee", "#f4fffa" }
local SAGE  = { "#1d3a30", "#2b5640", "#3f7549", "#5d9456", "#84b46a", "#b2d28a" }
local LEAFW = { "#46705a", "#6a9378", "#8db596", "#b0d0b0", "#cfe4c4", "#e8f4d8" }
local CORK  = { "#4a2c24", "#6a4030", "#8a5c3c", "#ae7c4e", "#d0a06a", "#ecc890" }
local TW    = { "#5a3d22", "#8a6434", "#b88a48", "#dcb470", "#f2d496" }
local FUR   = { "#2f5848", "#4a7a62", "#6f9f82", "#98c0a0", "#bcd9b8", "#dcedcf" }
local SPEC  = "#f4fffa"
local CX = 31.5

c:groundShadow(31.5, 50, 10, 2)

local function hw(y)
  if y < 12 or y > 50 then return nil end
  if y <= 13 then return 4.8 end
  if y > 18 then y = y + 3 end
  if y <= 21 then return 3.5 end
  if y <= 31 then return 3.5 + 6.2 * sin(pi / 2 * (y - 21) / 10) end
  if y <= 42 then return 9.7 end
  local q = 1 - ((y - 42) / 11.95) ^ 2
  return q > 0 and 9.7 * sqrt(q) or nil
end
local glass = HP.mask()
for y = 12, 50 do local h = hw(y) if h then for x = 0, 63 do if abs(x - CX) <= h then glass:set(x, y) end end end end

-- glass body
local gtok = { r = { name = "glass" } }
local gn = X.pillow(glass, 3.2)
X.tone(c, glass, X.light(gn, { amb = 0.1, wrap = 0.25 }), GLASS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, tok = gtok })

-- liquid
local liq = glass:shrink(2)
liq:each(function(x, y) if y < 25 then liq.s[K(x, y)] = nil end end)
local ltok = { r = { name = "liquid" } }
local ln = X.pillow(liq, 5.5)
local lb = {}
liq:each(function(x, y) if y >= 45 then lb[K(x, y)] = -1 end end)
local li = G.toneN(c, liq, ln, SAGE, { tok = ltok, bias = lb, cuts = { 0.25, 0.42, 0.58, 0.7, 0.86 }, amb = 0.08, wrap = 0.3 })
liq:each(function(x, y)
  if not liq:has(x, y - 1) then c:put(x, y, "#d4eaa6", ltok)               -- bright meniscus
  elseif not liq:has(x, y - 2) then c:put(x, y, SAGE[5], ltok) end
end)
-- cool reflected light on the shade side + murky speckle
liq:edge():each(function(x, y) if (x > CX + 3 and y > 41 and not liq:has(x, y + 1)) or (x > CX + 6 and y > 33 and y < 45 and not liq:has(x + 1, y)) then c:put(x, y, "#4f8f8a", ltok) end end)
liq:each(function(x, y) if X.hash(x, y, 5) > 0.93 and (li[K(x, y)] or 3) >= 3 then c:put(x, y, SAGE[max(1, (li[K(x, y)] or 3) - 1)], ltok) end end)

-- drifting sage leaf inside
local fm, fn, FT, FS = G.blade(25, 44, 31, 35, 38, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 2.5 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.7)
end, { fold = 0.4 })
fm:clip(liq)
local fi = G.toneN(c, fm, fn, LEAFW, { tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.15, wrap = 0.3 })
fm:each(function(x, y) local k = K(x, y)
  if abs(FS[k]) < 0.17 and FT[k] > 0.08 and FT[k] < 0.95 then c:put(x, y, LEAFW[FS[k] <= 0 and 6 or 4], ltok)
  elseif abs(abs(FS[k]) - 0.6) < 0.1 and FT[k] > 0.2 and FT[k] < 0.85 and floor(FT[k] * 14) % 2 == 0 then c:put(x, y, LEAFW[max(1, (fi[k] or 3) - 1)], ltok) end
end)
-- leaf shadow on the brew
fm:shift(1, 1):each(function(x, y) if liq:has(x, y) and not fm:has(x, y) then c:put(x, y, SAGE[2], ltok) end end)

-- bubbles
for _, b in ipairs{ { 36, 28 }, { 35, 44 } } do
  c:put(b[1], b[2], "#c8e6a8") c:put(b[1] + 1, b[2], "#a4cc86") c:put(b[1], b[2] + 1, "#a4cc86") c:put(b[1] + 1, b[2] + 1, "#6aa066")
  c:put(b[1], b[2], "#eefad0")
end
c:put(27, 31, "#c8e6a8") c:put(37, 33, "#a4cc86")

-- glass highlights: long streak on the body, short streak on the shoulder, faint teal return on the right
for y = 29, 44 do
  if y ~= 36 and y ~= 37 and y ~= 38 then local x = floor(CX - hw(y)) + 3 if glass:has(x, y) then c:put(x, y, "#e4f6e0", gtok) end end
end
for y = 20, 24 do local x = floor(CX - hw(y)) + 1 + (y > 22 and 1 or 0) if glass:has(x, y) then c:put(x, y, SPEC, gtok) end end
for y = 33, 45 do local x = floor(CX + hw(y)) - 3 if glass:has(x, y) then c:put(x, y, "#7cc0bc", gtok) end end
-- glass lip: bright top row, darker underside
for x = 0, 63 do if glass:has(x, 12) then c:put(x, 12, x < CX and GLASS[6] or GLASS[4], gtok) end end
for x = 0, 63 do if glass:has(x, 14) and not glass:has(x, 13) then c:put(x, 14, GLASS[2], gtok) end end

-- cork stopper: granular, rounded top
local cm = HP.mask()
for y = 5, 14 do local h = (y <= 12) and 4 or 3 for x = 0, 63 do if abs(x - CX) <= h then cm:set(x, y) end end end
cm.s[K(28, 5)] = nil cm.s[K(35, 5)] = nil
local ctok = { r = { name = "cork" } }
local cn = X.pillow(cm, 3)
local cb = {}
cm:each(function(x, y) if y >= 12 then cb[K(x, y)] = -1 end end)
local ci = G.toneN(c, cm, cn, CORK, { tok = ctok, bias = cb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
cm:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 9)
  if h < 0.14 then c:put(x, y, CORK[max(1, (ci[k] or 3) - 1)], ctok)
  elseif h > 0.93 then c:put(x, y, CORK[min(6, (ci[k] or 3) + 1)], ctok) end
end)
c:put(29, 6, CORK[6], ctok) c:put(30, 6, CORK[6], ctok) c:put(29, 7, CORK[5], ctok)

-- twine: three twisted rows round the neck, knot and frayed tails on the right
for x = 27, 36 do
  c:put(x, 15, ((x + 0) % 2 == 0) and TW[4] or TW[3], gtok)
  c:put(x, 16, ((x + 1) % 2 == 0) and TW[3] or TW[2], gtok)
  c:put(x, 17, ((x + 0) % 2 == 0) and TW[2] or TW[1], gtok)
end
for _, p in ipairs{ { 37, 15, 4 }, { 38, 16, 3 }, { 37, 17, 2 }, { 38, 17, 2 }, { 37, 16, 3 } } do c:put(p[1], p[2], TW[p[3]], gtok) end
for _, p in ipairs{ { 38, 18, 3 }, { 38, 19, 2 }, { 39, 20, 2 }, { 37, 18, 2 }, { 36, 19, 3 }, { 36, 20, 2 }, { 35, 21, 4 } } do c:put(p[1], p[2], TW[p[3]], gtok) end

-- quirk: furry sage leaf stuck to the cork, drawn over the cork's right edge
local lm, ln2, T, S = G.blade(33, 9, 39, 2, 48, 5, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 3.4 * sin(pi * min(1, t * 0.92 + 0.07)) ^ 0.7)
end, { fold = 0.4 })
local ftok = { r = { name = "furleaf" } }
local fi2 = G.toneN(c, lm, ln2, FUR, { tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local d = fi2[k] or 3
  if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.95 then c:put(x, y, S[k] <= 0 and FUR[6] or FUR[4], ftok)
  elseif abs(abs(S[k]) - 0.55) < 0.12 and T[k] > 0.15 and T[k] < 0.85 and floor(T[k] * 16 + (S[k] > 0 and 1 or 0)) % 3 == 0 then c:put(x, y, FUR[max(1, d - 1)], ftok)
  elseif X.hash(x, y, 3) > 0.72 then c:put(x, y, FUR[min(6, d + 1)], ftok) end   -- fuzz
end)
-- contact shadow of the leaf base on the cork
for _, p in ipairs{ { 33, 10 }, { 33, 11 }, { 34, 11 } } do if cm:has(p[1], p[2]) then c:put(p[1], p[2], CORK[2], ctok) end end

G.save2(c, NAME)
