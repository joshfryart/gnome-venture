-- ico-milk (final pass, Opus single pass). Bold icon: a slim glass milk bottle standing on a small ground shadow.
-- Lathe profile: crimped blue foil cap, thick glass lip, narrow neck, soft shoulder, straight body, rounded heel.
-- Glass: per-pixel cylinder light, a pale cool wall rim round the milk, clear tinted glass in the empty neck, a tall
-- bright specular streak plus a cream glint, darker heel where the glass is thickest. Milk: 6-tone cool cream ramp
-- with a bright meniscus row. Label: red paper band wrapped round the body (cylinder light, dark top/bottom edge)
-- carrying a cream milk-drop mark. Foil: 6-tone blue, crimp ribs, bright dome.
-- quirk: a single milk drip has escaped under the cap and is running down the neck.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, sqrt, max, min, abs = math.floor, math.sin, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-milk")
local CAP  = { "#1b2858", "#263f88", "#345fb6", "#4e86d8", "#7eb2ee", "#c2e2ff" }
local MILK = { "#6e7296", "#9a9dbd", "#c3c6dc", "#e1e3ee", "#f3f2f2", "#fffaf0" }
local GL   = { "#3e6a8a", "#5f8fae", "#86b4c8", "#b2d8e0", "#d6f0ee", "#f0fdf8" }
local LAB  = { "#5a1a30", "#8e2438", "#c03a3c", "#e4583e", "#ff8a5c", "#ffb98a" }
local CX = 31.5
local Y0, Y1 = 9, 53
local function hw(y)
  if y <= 10 then return 5.6 end          -- foil dome
  if y <= 14 then return 6.6 end          -- crimped skirt
  if y <= 16 then return 6.0 end          -- glass lip
  if y <= 21 then return 4.6 end          -- neck
  if y <= 31 then local t = (y - 21) / 10 return 4.6 + 5.4 * (0.5 - 0.5 * math.cos(t * math.pi)) end
  if y <= 50 then return 10 end
  return 10 - (y - 50) * 0.9               -- heel
end
local function slope(y)
  if y <= 10 then return -0.9 end
  if y > 21 and y <= 31 then return -0.7 * sin((y - 21) / 10 * math.pi) end
  if y >= 51 then return 0.6 end
  return 0
end
c:groundShadow(32, 54, 13, 2)
local m, n, S = A.lathe(CX, Y0, Y1, hw, slope)
local cap, glass = HP.mask(), HP.mask()
m:each(function(x, y) if y <= 14 then cap:set(x, y) else glass:set(x, y) end end)
local ctok, gtok, mtok, ltok = { r = { name = "cap" } }, { r = { name = "glass" } }, { r = { name = "milk" } }, { r = { name = "label" } }

-- glass shell first (whole glass), then milk inside
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local gidx = X.tone(c, glass, v, GL, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = gtok })
local MILKY = 28
local inner = glass:shrink(1)
local milk = HP.mask()
inner:each(function(x, y) if y >= MILKY and y <= Y1 - 2 then milk:set(x, y) end end)
local vm = X.light(n, { amb = 0.02, wrap = 0.08 })
local midx = X.tone(c, milk, vm, MILK, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 }, tok = mtok })
-- empty neck: lighter, clearer glass (pale core)
inner:each(function(x, y) if y < MILKY and y >= 16 then
  local i = gidx[K(x, y)] or 3
  c:put(x, y, GL[max(2, min(4, i))], gtok) end end)
-- meniscus row
milk:each(function(x, y) if y == MILKY then c:put(x, y, abs(S[K(x, y)]) < 0.75 and MILK[6] or MILK[4], mtok) end end)
-- thick heel
glass:each(function(x, y) if y >= Y1 - 1 then c:put(x, y, GL[max(1, (gidx[K(x, y)] or 3) - 1)], gtok) end end)
-- glass lip ring: bright top row, dark under-row
for x = 25, 38 do
  if glass:has(x, 15) then c:put(x, 15, x < 33 and GL[6] or GL[3], gtok) end
  if glass:has(x, 16) then c:put(x, 16, GL[2], gtok) end
end

-- label band (wraps the body)
local LY0, LY1 = 36, 45
local lidx = {}
glass:each(function(x, y) if y >= LY0 and y <= LY1 then
  local k = K(x, y)
  local i = floor(v[k] * 6 + 0.6)
  if y == LY0 or y == LY1 then i = i - 2 end
  i = max(1, min(6, i)) lidx[k] = i
  c:put(x, y, LAB[i], ltok)
end end)
-- milk-drop mark on the label (cream, shaded side)
A.map(c, {
  "..c..",
  "..c..",
  ".hcc.",
  ".hcck",
  "cccck",
  ".ckk.",
}, 28, LY0 + 2, { c = "#fff4d6", h = "#ffffee", k = "#e8c9a8" }, ltok)

-- foil cap
local cidx = X.tone(c, cap, v, CAP, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, tok = ctok })
cap:each(function(x, y) if y >= 11 then
  if (x % 2 == 0) then A.step(c, cidx, CAP, x, y, -1, ctok) end
  if y == 14 then A.step(c, cidx, CAP, x, y, -1, ctok) end
end end)
c:put(28, 9, CAP[6], ctok) c:put(29, 9, CAP[6], ctok) c:put(27, 10, CAP[6], ctok)

-- specular streak on the glass + glint
for y = 30, 50 do if y < LY0 - 1 or y > LY1 + 1 then c:put(24, y, MILK[6], mtok) end end
for y = 33, 34 do c:put(25, y, MILK[6], mtok) end
c:put(24, 32, A.CREAM, mtok)
for y = 18, 22 do c:put(28, y, GL[6], gtok) end
-- cool bounce on the right edge of the body
glass:edge():each(function(x, y) if x > CX + 7 and y > 32 and y < 50 and (y < LY0 or y > LY1) then c:put(x, y, "#8a9ad0", gtok) end end)

-- quirk: milk drip running down the neck from under the cap
local DX = 35
for y = 15, 21 do c:put(DX, y, MILK[6], mtok) if y > 16 then c:put(DX + 1, y, GL[2], gtok) end end
c:put(DX, 22, MILK[6], mtok) c:put(DX + 1, 22, MILK[4], mtok)
c:put(DX, 23, MILK[4], mtok) c:put(DX + 1, 23, MILK[3], mtok) c:put(DX + 2, 22, GL[2], gtok)
c:put(DX - 1, 16, MILK[5], mtok)
A.save(c, "ico-milk")
