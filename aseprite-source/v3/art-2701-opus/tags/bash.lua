-- bash (Opus). Tag "bash" (Shield Bash: your guard becomes the hit). A round gnome buckler swung edge-first to the
-- right: the face is turned a little toward us so its rim thickness shows, the painted face is split blue and cream,
-- an iron boss sits in the middle, three swoosh arcs trail on the left and a jagged gold impact burst flares where
-- the rim lands. Material: domed iron boss with specular, bevelled iron rim with rivets, painted planks with seams.
-- quirk: a little sticking plaster patches an old crack on the cream half.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = O.new("bash")

local BLUE = { "#1c2a5a", "#273f86", "#3458b4", "#4a7ad6", "#78a8ee", "#b4d4ff" }
local CRM  = { "#8a6a54", "#b89874", "#d8bf94", "#efdcb2", "#fff0cf" }
local IRON = { "#2f3150", "#444663", "#62647e", "#8a8ba2", "#b8b8c8", "#e6e6ee" }
local EDGE = { "#3a221e", "#51302b", "#6e4234", "#864c33" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local PLA  = { "#8a4a34", "#d88c5c", "#ffc89a" }
local SWO  = { "#5f9ad0", "#8bc4ea", "#e4f6ff" }

local CX, CY, RX, RY, ANG = 29, 32, 15, 19, 0.1

-- impact burst (behind the shield, flaring out from the right rim)
do
  local tok = O.tok("burst")
  local bx, by = 47, 30
  local m = HP.mask()
  local inner = HP.mask()
  for y = by - 14, by + 14 do for x = bx - 14, bx + 14 do
    local dx, dy = x - bx, y - by
    local a = math.atan(dy, dx)
    local r = sqrt(dx * dx + dy * dy)
    local spike = 0.5 + 0.5 * cos(a * 7 + 0.4)
    local R = 5.5 + 7.5 * spike ^ 3
    if r <= R then m:set(x, y) end
    if r <= R * 0.55 then inner:set(x, y) end
  end end
  m:each(function(x, y) c:put(x, y, GOLD[3], tok) end)
  m:edge():each(function(x, y) c:put(x, y, GOLD[2], tok) end)
  inner:each(function(x, y) c:put(x, y, GOLD[4], tok) end)
  inner:shrink(2):each(function(x, y) c:put(x, y, GOLD[5], tok) end)
end

-- swoosh arcs behind (left)
do
  local tok = O.tok("swoosh")
  for i, a in ipairs{ { 27, 32, 19.5, 2.05, 2.6 }, { 26, 32, 20.5, 2.9, 3.4 }, { 27, 32, 19.5, 3.7, 4.2 } } do
    for t = a[4], a[5], 0.01 do
      local x, y = floor(a[1] + cos(t) * a[3] + .5), floor(a[2] + sin(t) * a[3] * 1.05 + .5)
      local f = (t - a[4]) / (a[5] - a[4])
      local col = (i == 2) and (f < 0.5 and SWO[3] or SWO[2]) or SWO[2]
      c:put(x, y, col, tok)
      if f > 0.25 and f < 0.75 then
        local x2, y2 = floor(a[1] + cos(t) * (a[3] + 1) + .5), floor(a[2] + sin(t) * (a[3] + 1) * 1.05 + .5)
        c:put(x2, y2, SWO[1], tok)
      end
    end
  end
end

-- rim thickness: the back edge shows on the left as the shield turns right
local face, fn = O.oval(CX, CY, RX, RY, ANG, 1.4)
local back = O.oval(CX - 2.5, CY + 0.5, RX, RY, ANG):cut(face)
do
  local tok = O.tok("edge")
  local n = {} back:each(function(x, y) n[K(x, y)] = { -0.7, 0.3, 0.6 } end)
  local idx = O.shade(c, back, n, EDGE, { tok = tok, amb = 0.3, cuts = { 0.35, 0.55, 0.75 } })
  back:each(function(x, y) if y % 4 == 0 then O.step(c, idx, EDGE, x, y, -1, tok) end end)
end

-- face: iron rim ring, painted planks, boss
local rim = face:copy():cut(face:shrink(2))
local inside = face:shrink(2)
do
  local tokB, tokC = O.tok("blue"), O.tok("cream")
  local blue, cream = HP.mask(), HP.mask()
  inside:each(function(x, y)
    -- diagonal split, upper-left blue / lower-right cream
    local u = (x - CX) * cos(ANG) + (y - CY) * sin(ANG)
    local v = -(x - CX) * sin(ANG) + (y - CY) * cos(ANG)
    if (u < 0) == (v < 0) then blue:set(x, y) else cream:set(x, y) end
  end)
  local function flatN(m) local n = {} m:each(function(x, y) local a = fn[K(x, y)] n[K(x, y)] = { a[1] * 0.45, a[2] * 0.45, 1 } end) return n end
  local b = {}
  inside:each(function(x, y) local k = K(x, y)
    local xx = (x - CX) * cos(ANG) + (y - CY) * sin(ANG)
    if floor(xx + 40) % 6 == 0 then b[k] = -1 end                      -- plank seams
  end)
  local bi = O.shade(c, blue, flatN(blue), BLUE, { tok = tokB, bias = b, amb = 0.1, wrap = 0.4 })
  local ci = O.shade(c, cream, flatN(cream), CRM, { tok = tokC, bias = b, amb = 0.1, wrap = 0.4 })
  -- AO inside the rim lower-right
  inside:each(function(x, y) if not inside:has(x + 1, y + 1) then
    if blue:has(x, y) then O.step(c, bi, BLUE, x, y, -1, tokB) else O.step(c, ci, CRM, x, y, -1, tokC) end end end)
  -- crack on the cream half + quirk plaster over it
  for _, p in ipairs{ { 33, 22 }, { 34, 21 }, { 35, 21 }, { 36, 20 }, { 37, 19 }, { 38, 18 }, { 39, 18 }, { 32, 23 } } do
    if cream:has(p[1], p[2]) then O.set(c, ci, CRM, p[1], p[2], 1, tokC) end
  end
  local tokP = O.tok("plaster")
  O.map(c, {
    "ba....ab",
    ".bab.ab.",
    "..bdab..",
    "..badb..",
    ".ab..bab",
    "ab....b.",
  }, 32, 17, { a = PLA[3], b = PLA[2], d = PLA[1] }, tokP)
end
do
  local tok = O.tok("rim")
  local idx = O.shade(c, rim, fn, IRON, { tok = tok, amb = 0.1, wrap = 0.2 })
  for i = 0, 7 do
    local a = i * pi / 4 + 0.4
    local x, y = floor(CX + cos(a) * (RX - 0.5) + .5), floor(CY + sin(a) * (RY - 0.5) + .5)
    if rim:has(x, y) then c:put(x, y, IRON[i < 4 and 2 or 6] , tok) end
  end
end
-- boss
do
  local tok = O.tok("boss")
  local m, n = O.oval(CX, CY, 3.5, 4, 0)
  local flange = O.oval(CX, CY, 5.5, 6, 0):cut(m)
  local fi = O.shade(c, flange, (function() local nn = {} flange:each(function(x, y) nn[K(x, y)] = { (x - CX) / 7, (y - CY) / 7, 1 } end) return nn end)(), { IRON[1], IRON[2], IRON[3], IRON[4] }, { tok = O.tok("flange"), amb = 0.05, cuts = { 0.4, 0.62, 0.82 } })
  local idx = O.shade(c, m, n, IRON, { tok = tok, amb = 0.05, wrap = 0.15 })
  c:put(CX - 1, CY - 2, IRON[6], tok) c:put(CX - 2, CY - 1, IRON[6], tok)
  for _, a in ipairs{ 0.8, 2.4, 3.9, 5.5 } do
    local x, y = floor(CX + cos(a) * 5 + .5), floor(CY + sin(a) * 5.5 + .5)
    if flange:has(x, y) then c:put(x, y, IRON[1], O.tok("flange")) end
  end
end

O.save(c, "bash")
