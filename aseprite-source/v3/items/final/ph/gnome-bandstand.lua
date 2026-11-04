-- gnome-bandstand (B3, Opus single pass, replaces the Sonnet draft). Slim open pavilion: flared pagoda roof in
-- ember/cream stripes converging on a gold finial and a teal pennant, scalloped gold valance, four slim white posts
-- (round, gold capitals and plinths) with a gold rail and spindle balusters, a shadowed interior showing the back
-- posts, a raised wooden deck with a lattice skirt and two front steps.
-- Material: per-pixel cone light on the roof, cylinder light on the posts, wood grain + lit edges on deck and steps,
-- AO under the valance, the rail and the deck lip; 2-tone ground shadow.
-- quirk: a single gold music note has floated out from under the roof.
local NAME = "gnome-bandstand"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, asin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.asin, math.pi
local c = A.new(NAME)

local EMB = { "#5e1a34", "#8e2539", "#bf3440", "#e24e3f", "#f97b55", "#ffad7e" }
local CRM = { "#6e5470", "#a08494", "#cdb8b2", "#ecdcc4", "#fbeed6", "#fff8e6" }
local GLD = { "#6b3a1f", "#9a5420", "#d98322", "#f5b82e", "#ffd35e", "#ffeca6" }
local WD  = { "#3f2328", "#5e3530", "#864c33", "#a8683f", "#c98d55", "#e8b982" }
local TEA = { "#1f4a5e", "#2f7790", "#4fa8b8", "#86d4d4" }
local IN  = { "#241a3a", "#2f2449", "#3d2f5c", "#55457a" }
local CX = 32

c:groundShadow(CX, 56, 23, 1)

-- interior (dark) behind posts
local inside = c:rect(15, 28, 49, 44)
inside:each(function(x, y)
  local i = y < 31 and 1 or (y < 36 and 2 or 3)
  A.setp(c, x, y, IN, i)
end)
-- back posts + back rail (dim)
for _, bx in ipairs{ 19, 31, 44 } do
  for y = 30, 41 do A.setp(c, bx, y, IN, 4) A.setp(c, bx + 1, y, IN, 3) end
end
for x = 15, 49 do A.setp(c, x, 35, IN, 4) end

-- deck (lip + lattice skirt)
local deck = c:rect(10, 43, 54, 50)
deck:cut(c:rect(10, 50, 10, 50)):cut(c:rect(54, 50, 54, 50))
deck:each(function(x, y)
  local u = (x - CX) / 22
  if y == 43 then A.setp(c, x, y, WD, u < 0.6 and 6 or 5)
  elseif y == 44 then A.setp(c, x, y, WD, u < 0.5 and 4 or 3)
  elseif y == 45 then A.setp(c, x, y, WD, 1)                    -- AO under the lip
  elseif y == 50 then A.setp(c, x, y, WD, 2)
  else
    local on = ((x + y) % 4 == 0) or ((x - y) % 4 == 0)
    if on then A.setp(c, x, y, WD, (u < 0.55) and 5 or 4) else A.setp(c, x, y, WD, (u < 0.4) and 2 or 1) end
  end
end)
-- end-grain posts at the deck corners
for y = 44, 50 do A.setp(c, 10, y, WD, y == 44 and 6 or 4) A.setp(c, 54, y, WD, y == 44 and 3 or 2) end
-- deck plank seams on the lip
for _, sx in ipairs{ 17, 26, 38, 47 } do A.setp(c, sx, 44, WD, 2) end

-- steps
local function step(x0, x1, y0, y1)
  for y = y0, y1 do for x = x0, x1 do
    local u = (x - (x0 + x1) / 2) / ((x1 - x0) / 2)
    local i
    if y == y0 then i = u < 0.5 and 6 or 5
    elseif y == y0 + 1 then i = 2
    else i = u < 0.3 and 4 or 3 end
    if x == x1 then i = max(1, i - 1) end
    A.setp(c, x, y, WD, i)
  end end
  -- grain
  for x = x0 + 2, x1 - 2, 5 do A.setp(c, x, y1, WD, 2) A.setp(c, x + 1, y1, WD, 2) end
end
step(26, 38, 50, 52)
step(24, 40, 53, 55)

-- rail + balusters (between and behind the posts)
for x = 14, 50 do
  A.setp(c, x, 36, GLD, 5) A.setp(c, x, 37, GLD, 3) A.setp(c, x, 38, GLD, 1)
  if x % 2 == 0 then for y = 39, 42 do A.setp(c, x, y, GLD, y == 39 and 2 or (y == 42 and 2 or 3)) end end
end

-- posts: slim round, white paint
local posts = { 13, 23, 39, 49 }
for _, px in ipairs(posts) do
  local m = c:rect(px, 30, px + 2, 42)
  local n = A.vnorm(m, px, px + 2, 0)
  local bias = {}
  for x = px, px + 2 do bias[K(x, 30)] = -1 bias[K(x, 31)] = -1 end   -- AO under the valance
  A.tone(c, m, n, CRM, { bias = bias, cuts = { 0.15, 0.3, 0.5, 0.68, 0.84 }, amb = 0.15 })
  -- capital and plinth blocks (gold), 1px wider
  for x = px - 1, px + 3 do
    local u = (x - px - 1) / 2
    A.setp(c, x, 32, GLD, u < 0 and 5 or (u > 0.6 and 3 or 4))
    A.setp(c, x, 33, GLD, 2)
    A.setp(c, x, 42, GLD, u < 0 and 4 or 3)
  end
end

-- roof: flared cone, 8 stripes converging on the apex
local TOP, EAVE = 13, 27
local function hw(y) return 1.2 + 20.5 * (max(0, y - TOP) / (EAVE - TOP)) ^ 1.6 end
local roof, rn, stripe = HP.mask(), {}, {}
for y = TOP, EAVE do for x = 8, 56 do
  local w = hw(y)
  local u = (x - CX) / (w + 0.5)
  if abs(u) <= 1 then
    local yb = 24 + 3 * sqrt(max(0, 1 - u * u))
    if y <= yb then
      roof:set(x, y)
      local k = K(x, y)
      local th = asin(max(-1, min(1, u)))
      stripe[k] = floor((th + pi / 2) / (pi / 8))
      local steep = 0.9 - 0.5 * (y - TOP) / (EAVE - TOP)    -- flatter near the eave (flare)
      rn[k] = A.norm(u * 1.0, -steep, sqrt(max(0.05, 1 - u * u)) * 0.9)
    end
  end
end end
local v = X.light(rn, { amb = 0.08, wrap = 0.3 })
roof:each(function(x, y)
  local k = K(x, y)
  local val = v[k]
  local i = 1
  for j, t in ipairs{ 0.2, 0.36, 0.52, 0.68, 0.84 } do if val >= t then i = j + 1 end end
  local R = (stripe[k] % 2 == 0) and EMB or CRM
  A.setp(c, x, y, R, i)
end)
-- eave lip: 1px darker row along the bottom of the roof
for x = 8, 56 do
  local yb
  for y = EAVE, TOP, -1 do if roof:has(x, y) then yb = y break end end
  if yb then A.shift(c, x, yb, -1) end
end
-- valance: gold band with scallops under the eave
for x = 11, 53 do
  local u = (x - CX) / 21.5
  if abs(u) <= 1 then
    local yb = floor(24 + 3 * sqrt(max(0, 1 - u * u))) + 1
    local base = u < -0.3 and 5 or (u > 0.5 and 3 or 4)
    A.setp(c, x, yb, GLD, base)
    A.setp(c, x, yb + 1, GLD, base - 1)
    local ph = (x - 11) % 4
    if ph == 1 or ph == 2 then A.setp(c, x, yb + 2, GLD, base - 2) end
    if not roof:has(x, yb - 1) and yb - 1 >= 24 then end
  end
end
-- glint on the lit left stripe
c:put(21, 22, "#fff4d6") c:put(22, 21, "#fff4d6")

-- finial + flagpole + pennant
for y = 7, 12 do A.setp(c, CX, y, WD, y < 9 and 4 or 3) end
A.setp(c, CX - 1, 11, GLD, 5) A.setp(c, CX, 11, GLD, 4) A.setp(c, CX + 1, 11, GLD, 3)
A.setp(c, CX - 1, 12, GLD, 4) A.setp(c, CX, 12, GLD, 3) A.setp(c, CX + 1, 12, GLD, 2)
A.setp(c, CX, 10, GLD, 6)
local pen = { { 33, 7, 39 }, { 33, 8, 37 }, { 33, 9, 35 } }
for r, s in ipairs(pen) do for x = s[1], s[3] do
  local i = r == 1 and 4 or (r == 2 and 3 or 2)
  if x == s[3] then i = max(1, i - 1) end
  c:put(x, s[2], TEA[i])
end end

-- quirk: a floating music note (gold) drifting off to the upper right
local nx, ny = 50, 9
for y = ny, ny + 4 do A.setp(c, nx + 1, y, GLD, 3) end
A.setp(c, nx + 2, ny, GLD, 4) A.setp(c, nx + 3, ny + 1, GLD, 3)
A.setp(c, nx - 1, ny + 4, GLD, 5) A.setp(c, nx, ny + 4, GLD, 4)
A.setp(c, nx - 1, ny + 5, GLD, 3) A.setp(c, nx, ny + 5, GLD, 2) A.setp(c, nx + 1, ny + 5, GLD, 2)
c:put(nx - 1, ny + 4, "#ffeca6")

A.save(c, NAME)
