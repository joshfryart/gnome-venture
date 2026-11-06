-- quail-egg-toast (D10_5, redraw): a flat slice of toast seen from above with a 3 px cut edge below it, a bite out of
-- the top-right shoulder, two small fried quail eggs (frilled brown-gold lace, glossy yolks), chopped chive rings and
-- cracked pepper. Material: crust ring with grain, crumb pores and toasted rim, torn-crumb bite, butter sheen,
-- contact shadow of the eggs on the crumb, waxy white with lavender shade, specular on each yolk.
-- quirk: one yolk has broken and a thin drip runs down over the white onto the toast, ending in a fat drop.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_5.lua")
local B, HP, X, K, H = D.B, D.HP, D.X, D.K, D.H
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = D.new("quail-egg-toast")
local hash = D.hash

local CR = { "#8e5222", "#bf7f36", "#dca24a", "#f0c466", "#fbe08e", "#fff2c2" }   -- crumb
local CU = { "#46200e", "#69351a", "#8a4a24", "#a8642c", "#c58236", "#dea052" }   -- crust
local WH = { "#8f88ac", "#b9b3cc", "#dcd8e4", "#f4f0f0", "#fffaf0", "#fffdf8" }   -- white
local YK = { "#b84a10", "#d9680f", "#f08a1c", "#ffaa2c", "#ffc84c", "#ffe58c" }   -- yolk
local CH = { "#1f5a3a", "#2f7a46", "#4f9a4e", "#7cc35a", "#a8dc78", "#d4f0a0" }

-- silhouette: slice with mushroom shoulders
local T = c:rrect(15, 28, 49, 52, 4)
T:add(B.ell(24, 25, 11, 9, 0)):add(B.ell(40, 25, 11, 9, 0)):add(c:rect(22, 20, 42, 30))
local bite = B.ell(49.5, 20, 5.2, 5, 0):add(B.ell(52.5, 26.5, 3.8, 3.8, 0)):add(B.ell(44.5, 16.5, 3.6, 3.4, 0))
bite:add(B.ell(52, 15, 3.4, 3.4, 0))
T:cut(bite)

-- cut edge (thickness) below the top face
local side = T:copy():shift(0, 3):cut(T)
local biteNear = bite:grow(3)
side:each(function(x, y)
  local k = (y - 0)
  local lowest = not T:has(x, y - 3)
  if biteNear:has(x, y) then
    c:px(x, y, (T:has(x, y - 1)) and CR[3] or CR[2])
  else
    local depth = 0
    if T:has(x, y - 1) then depth = 1 elseif T:has(x, y - 2) then depth = 2 else depth = 3 end
    local right = x > 32 and 1 or 0
    c:px(x, y, CU[max(1, 4 - depth - right)])
  end
end)
-- the slice's own lower-right edge row of the side gets a hard shade
side:each(function(x, y) if not side:has(x, y + 1) and not biteNear:has(x, y) then c:px(x, y, CU[1]) end end)

-- top face
local ring = T:copy():cut(T:shrink(2))
local torn = bite:grow(2):clip(T)
local crustM = ring:copy():cut(torn)
local crumbM = T:copy():cut(crustM)
local n, d = X.pillow(T, 4)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local bias = {}
crumbM:each(function(x, y)
  local kk = K(x, y)
  if d[kk] < 3.5 and not torn:has(x, y) and hash(x, y, 3) > 0.15 then bias[kk] = -1 end
end)
X.tone(c, crumbM, v, CR, { bias = bias })
X.tone(c, crustM, v, CU, {})
-- crust grain
crustM:each(function(x, y)
  local h = hash(x, y, 5)
  if h < 0.18 then c:px(x, y, CU[3]) elseif h > 0.86 then c:px(x, y, CU[5]) end
  if (x + 2 * y) % 5 == 0 and h > 0.4 and d[K(x, y)] > 0.9 then c:px(x, y, CU[3]) end
end)
-- crumb pores + golden freckles
crumbM:shrink(1):each(function(x, y)
  local h = hash(x, y, 9)
  if torn:has(x, y) then
    if h < 0.1 then c:px(x, y, CR[5]) end
  elseif h < 0.06 then c:px(x, y, CR[2]) if hash(x, y, 4) > 0.5 then c:px(x + 1, y, CR[3]) end
  elseif h > 0.93 then c:px(x, y, CR[5]) end
end)
-- torn bite edge: fresh pale crumb with a darker toasted row on the inside edge
bite:grow(1):cut(bite):clip(T):each(function(x, y) c:px(x, y, hash(x, y, 2) > 0.5 and CR[6] or CR[5]) end)
bite:grow(2):cut(bite:grow(1)):clip(T):each(function(x, y) if hash(x, y, 8) > 0.6 then c:px(x, y, CR[4]) end end)
-- butter sheen (upper-left shoulder)
c:px(19, 22, CR[6]) c:px(20, 22, CR[6]) c:px(18, 23, CR[5]) c:px(21, 21, CR[6])
-- a faint crease where the shoulders meet the body
for x = 17, 28 do if (x % 3) ~= 0 and T:has(x, 29) and not crustM:has(x, 29) then c:px(x, 29, CR[3]) end end

-- ---------------------------------------------------------------- eggs
local eggA = B.ell(27, 36, 9, 7.5, 0.15):add(B.ell(21, 40, 4.6, 3.8, 0)):add(B.ell(31, 29.5, 4, 3.4, 0)):add(B.ell(33, 42, 3.6, 3.2, 0))
local eggB = B.ell(41, 42, 6, 4.8, -0.2):add(B.ell(45, 38.5, 3, 2.8, 0)):add(B.ell(38, 46, 3, 2.2, 0))
local both = eggA:copy():add(eggB)
-- contact shadow on the crumb (under-right of each egg)
local shadow = both:shift(1, 2):add(both:shift(0, 1)):cut(both):clip(T)
shadow:each(function(x, y) c:px(x, y, CR[1]) end)
shadow:copy():cut(both:shift(1, 1)):each(function(x, y) c:px(x, y, hash(x, y, 6) > 0.5 and CR[2] or CR[1]) end)
local function egg(m, cx, cy)
  local nn, dd = X.pillow(m, 2.6)
  local vv = X.light(nn, { amb = 0.2, wrap = 0.35 })
  X.tone(c, m, vv, WH, { cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 } })
  -- fried frill: lacy gold-brown on the rim, more on the lower-right
  m:edge():each(function(x, y)
    local h = hash(x, y, 12)
    local lower = (x - cx) + (y - cy)
    if h < (lower > 0 and 0.75 or 0.4) then c:px(x, y, h < 0.3 and "#c98a3c" or "#e6b668") end
  end)
  m:shrink(1):edge():each(function(x, y) if hash(x, y, 14) > 0.7 and (x - cx) + (y - cy) > 1 then c:px(x, y, "#f2dca0") end end)
  return nn
end
egg(eggA, 27, 36) egg(eggB, 41, 42)
-- ambient under the yolks and egg-to-egg seam
-- yolks
local function yolk(cx, cy, r, spx, spy)
  local m = B.ell(cx, cy, r, r * 0.95, 0)
  -- darker ambient ring on the white
  m:grow(1):cut(m):each(function(x, y) c:px(x, y, WH[2]) end)
  local nn = X.sphere(cx - 0.3, cy - 0.3, r, m)
  X.tone(c, m, X.light(nn, { amb = 0.08, wrap = 0.2 }), YK, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.9 } })
  c:px(spx, spy, "#fff4c8") c:px(spx + 1, spy, "#fff4c8") c:px(spx, spy + 1, "#ffe08a")
  return m
end
local yA = yolk(28, 35, 4.2, 25, 32)
local yB = yolk(41, 42, 3, 39, 40)
-- yolk drip: from the broken yolk A, down-right across the white to the toast, ending in a drop
local drip = { { 30, 38 }, { 31, 39 }, { 31, 40 }, { 31, 41 }, { 32, 42 }, { 32, 43 } }
for i, p in ipairs(drip) do
  c:px(p[1], p[2], YK[3]) c:px(p[1] - 1, p[2], YK[4])
  if i % 2 == 0 then c:px(p[1] + 1, p[2], YK[2]) end
end
-- the drip pools over the lower white lobe and runs off onto the toast
for _, p in ipairs({ { 32, 44 }, { 32, 45 }, { 33, 46 } }) do c:px(p[1], p[2], YK[3]) c:px(p[1] - 1, p[2], YK[4]) c:px(p[1] + 1, p[2], YK[2]) end
c:fillMask(B.ell(33, 48, 2, 2.1, 0), YK[3])
c:px(33, 49, YK[1]) c:px(34, 49, YK[1]) c:px(34, 48, YK[2]) c:px(32, 47, YK[4]) c:px(32, 48, YK[5]) c:px(33, 47, YK[5])

-- chopped chive rings + pepper
local function ring3(x, y)
  c:px(x, y, CH[5]) c:px(x + 1, y, CH[4]) c:px(x, y + 1, CH[3]) c:px(x + 1, y + 1, CH[2])
end
ring3(36, 31) ring3(22, 33) ring3(44, 44) ring3(30, 46) ring3(38, 37) ring3(24, 42)
for _, p in ipairs({ { 33, 32 }, { 21, 37 }, { 43, 40 }, { 26, 43 }, { 38, 44 }, { 29, 31 }, { 35, 34 }, { 36, 46 } }) do c:px(p[1], p[2], "#3a2630") end
D.fin(c)
