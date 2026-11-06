-- pickled-radishes (final, Opus C34-5). A squat wide-mouth glass jar in rosy brine, its mouth covered with a blue
-- gingham cloth tied with a twisted twine and a little bow; the skirt hangs in soft folds with a pinked hem.
-- Inside: whole red radishes with white tails and halved radishes showing white flesh, red rim and radial lines.
-- Material: per-pixel lit brine (surface of revolution), glass wall + thick base + streak + meniscus, cloth checks over
-- a pillow light with fold ridges, twine twist, radish waxy speculars, AO where radishes touch the glass base.
-- quirk: one radish bobs at the surface with its leafy top poking out of the brine.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, max, min, sqrt = math.floor, math.abs, math.sin, math.max, math.min, math.sqrt
local c = A.new("pickled-radishes")

local GL    = { "#2f4a6a", "#4e7a98", "#80aec0", "#b3dcd8", "#d8f2ea", "#f0fbf4" }
local BRINE = { "#8a3a5c", "#b25474", "#cf7290", "#e294aa", "#f0b6c4", "#f8d2d8" }
local AIR   = { "#7c8ea8", "#a0b4c6", "#c2d6dc", "#dbeae6", "#ebf5ef", "#f4faf4" }
local RED   = A.tint({ "#4e1230", "#7e1a36", "#b0263c", "#d83c46", "#f06a62", "#ff9e86" }, "#e090a8", 0.1)
local FLESH = A.tint({ "#9a6c88", "#c49cb0", "#e2c4ce", "#f2dee0", "#faeee8", "#fff6ee" }, "#f0b0c0", 0.12)
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local CL_D  = { "#1c2656", "#283a80", "#3650a8", "#4a6cc8", "#6890dc", "#8eb0ec" }
local CL_M  = { "#46507e", "#5e6ea6", "#7e90c6", "#9eb0de", "#bccdec", "#d6e2f6" }
local CL_C  = { "#867a8a", "#ada0a6", "#d2c6bc", "#e9dcc8", "#f6ecd8", "#fff4e2" }
local TW    = { "#4e3022", "#7c5032", "#a8784a", "#cfa266", "#e8c68a" }

c:groundShadow(32, 54, 15, 1)
-- jar: wide mouth, short shoulder, straight walls, rounded foot
local J = A.jar(32, 21, 53, function(y)
  if y <= 22 then return 10.5 end
  if y <= 26 then return 10.5 + (y - 22) * 0.8 end
  if y >= 51 then return 13.6 - (y - 50) ^ 1.5 * 0.7 end
  return 13.6
end)
A.back(c, J, BRINE, AIR, 31)
local IN = J.inner:copy()
local rtok = { r = { name = "radish" } }

-- tail: thin white root curling
local function tail(pts) local m = c:line(pts, 1) m:clip(IN) m:each(function(x, y) c:put(x, y, FLESH[4], rtok) end) end
-- whole radish
local function radish(cx, cy, r, tl)
  if tl then tail(tl) end
  local m, n = A.ball(c, cx, cy, r, RED, IN, { tok = rtok, bias = {} })
  -- white tip at the bottom where the tail starts
  m:each(function(x, y) if y >= cy + r - 1 and abs(x + 0.5 - cx) < 1.6 then c:put(x, y, FLESH[3], rtok) end end)
  -- cut leaf stub on top
  if IN:has(floor(cx), floor(cy - r)) then c:put(floor(cx), floor(cy - r), LEAF[3], rtok) c:put(floor(cx) - 1, floor(cy - r), LEAF[5], rtok) end
  -- waxy spec
  local sx, sy = floor(cx - r * 0.45 + 0.5), floor(cy - r * 0.45 + 0.5)
  if IN:has(sx, sy) then c:put(sx, sy, "#fff0e8", rtok) end
  return m
end
-- halved radish: white face, red rim, radial vascular lines
local function half(cx, cy, r)
  local m = c:ellipse(cx, cy, r, r - 0.6) m:clip(IN)
  local n = X.sphere(cx - 0.3, cy - 0.3, r, m)
  local v = X.light(n, { amb = 0.3, wrap = 0.5 })
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x + 0.5 - cx, (y + 0.5 - cy) * r / (r - 0.6)
    local d = sqrt(dx * dx + dy * dy)
    local i = v[k] > 0.75 and 5 or (v[k] > 0.5 and 4 or 3)
    if d > r - 0.6 then c:put(x, y, RED[v[k] > 0.6 and 4 or 3], rtok)
    elseif d > r - 1.6 then c:put(x, y, FLESH[i - 1], rtok)
    else
      local a = math.atan(dy, dx)
      local ray = abs(sin(a * 4)) < 0.22 and d > 1.2
      c:put(x, y, ray and FLESH[i - 2] or FLESH[i], rtok)
    end
  end)
  c:put(floor(cx), floor(cy), FLESH[3], rtok)
  return m
end
-- back layer
radish(37.5, 45.5, 4.6, { { 40, 50 }, { 42, 51 }, { 44, 51 } })
half(25.5, 47.5, 4.6)
radish(27.5, 38.5, 4.3, { { 25, 43 }, { 23, 44 } })
half(39.5, 37.5, 4.4)
radish(33, 50.5, 3.4, { { 30, 51 }, { 28, 51 } })
-- quirk: floating radish, leafy top poking up through the surface
local fm = radish(30.5, 33.5, 3.4, { { 33, 36 }, { 35, 37 } })
-- AO: a dark row where radishes sit on the glass base
for x = 20, 44 do local y = 50 if IN:has(x, y) and c:get(x, y) and (c:get(x, y) == RED[3] or c:get(x, y) == RED[4] or c:get(x, y) == FLESH[3] or c:get(x, y) == FLESH[4]) then c:put(x, y, c:get(x, y) == RED[4] and RED[2] or RED[3], rtok) end end

local GT = A.front(c, J, GL, { menisc = { BRINE[6], BRINE[5] }, s0 = 30, s1 = 49, gaps = { [42] = true }, r0 = 33, r1 = 38 })
-- leafy top of the floating radish rises through the meniscus
local ltok = { r = { name = "leaf" } }
for _, p in ipairs{ { 30, 30, LEAF[2] }, { 30, 29, LEAF[3] }, { 29, 28, LEAF[4] }, { 28, 27, LEAF[5] }, { 27, 26, LEAF[4] }, { 28, 26, LEAF[6] },
  { 26, 26, LEAF[3] }, { 29, 27, LEAF[3] }, { 31, 28, LEAF[3] }, { 32, 27, LEAF[4] }, { 33, 27, LEAF[3] }, { 32, 26, LEAF[5] }, { 30, 28, LEAF[2] } } do
  c:put(p[1], p[2], p[3], ltok) end
c:put(29, 31, BRINE[6], GT) c:put(31, 31, BRINE[6], GT)

-- gingham cloth: dome over the mouth, tied, skirt in folds with a pinked hem
local cloth = HP.mask()
for y = 12, 29 do
  local h
  if y <= 18 then h = 11.8 * sqrt(max(0, 1 - ((18.6 - y) / 7) ^ 2)) + 0.2
  elseif y <= 21 then h = 12.2
  elseif y <= 23 then h = 11.4
  else h = 12 + (y - 23) * 0.62 end
  for x = floor(32 - h), floor(32 + h) do if abs(x + 0.5 - 32) <= h then cloth:set(x, y) end end
end
local cut = HP.mask()
cloth:each(function(x, y) if y == 29 and (x // 2) % 2 == 0 then cut:set(x, y) end end)
cloth:cut(cut)
-- contact shadow of the hem on the glass
J.m:each(function(x, y) if (y == 29 or y == 30) and not cloth:has(x, y) and cloth:has(x, y - 1) then c:put(x, y, y == 30 and AIR[1] or "#5c6a88", GT) end end)
local cn = X.pillow(cloth, 3.5)
local cv = X.light(cn, { amb = 0.1, wrap = 0.35 })
local cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 }
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs(cuts) do if cv[k] >= t then i = j + 1 end end
  if y >= 24 then -- folds: valley + lit ridge every 5 px, fanning out
    local f = (x - 32 + 50 + floor((y - 24) * (x < 32 and -0.35 or 0.35))) % 5
    if f == 0 then i = i - 2 elseif f == 1 then i = i + 1 end
    if y == 24 then i = i - 1 end -- under the tie
  end
  if y <= 13 then i = i + 1 end
  i = max(1, min(6, i))
  local a, b = (x // 3) % 2 == 0, ((y + 1) // 3) % 2 == 0
  local R = (a and b) and CL_D or ((a or b) and CL_M or CL_C)
  c:put(x, y, R[i], ctok)
end)
-- weave: faint diagonal ticks on the dome
cloth:each(function(x, y) if y < 21 and (x + y) % 4 == 0 and x % 2 == 0 then local h = c:get(x, y)
  for _, R in ipairs{ CL_D, CL_M, CL_C } do for j = 2, 6 do if R[j] == h then c:put(x, y, R[j - 1], ctok) end end end end end)
-- twisted twine round the neck + bow at front right
local ttok = { r = { name = "twine" } }
for y = 22, 23 do for x = 20, 44 do if cloth:has(x, y) then
  local s = (x + y) % 3
  local i = (s == 0) and 2 or ((s == 1) and 4 or 3)
  if x > 39 then i = i - 1 end
  if x < 25 and y == 22 then i = i + 1 end
  c:put(x, y, TW[max(1, min(5, i))], ttok)
end end end
c:paint({
  ".abb..bba.",
  "a.cbaabc.a",
  "abb.ab.bba",
  "....bb....",
  "...b..a...",
  "..b....b..",
  "..a.....a.",
}, 32, 20, { a = TW[2], b = TW[4], c = TW[5] })
c:put(36, 22, TW[1]) c:put(37, 22, TW[1])
-- one specular glint on the glass shoulder
c:put(21, 33, "#fbfff8")
A.fin(c)
