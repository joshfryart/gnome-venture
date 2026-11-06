-- sea-salt (D15, final pass, Sonnet). A stepped heap of coarse sea-salt crystals, built like bevelled dice: lit top
-- face, mid front face, cool-violet right side, bright edge bevel on the lit corners, dark seam where neighbours touch.
-- The big crystals are "hopper" salt: stair-stepped hollows (rings that darken toward the centre, lit lower/right lip).
-- Three tints (blue-white, teal, warm grey) so the pile does not read as one slab. Fine flecks and crack lines in the
-- faces, one cream sparkle, wet-looking ground shadow.
-- quirk: a little spiral seashell is tucked against the front of the pile.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("sea-salt")

local SB = { "#566a9c", "#7c92c0", "#a8bde0", "#cddff2", "#e8f3fb", "#fafdff" }
local ST = { "#44748a", "#689eb0", "#94c6d0", "#c0e2e2", "#e0f4f0", "#f8fdfa" }
local SW = { "#74668c", "#9e90a8", "#c6b8c0", "#e6dcd8", "#f6f0e8", "#fffaf2" }
local EDGE = { [SB] = "#4a5c8c", [ST] = "#3a6478", [SW] = "#665a7c" }
local tokN = 0

local function cube(x, y, w, d, R, hopper)
  tokN = tokN + 1
  local tok = { r = { name = "cube" .. tokN } }
  local sil = HP.mask()
  local front, top, side = HP.mask(), HP.mask(), HP.mask()
  for yy = y, y + w - 1 do for xx = x, x + w - 1 do front:set(xx, yy) end end
  for j = 1, d do for xx = x + j, x + j + w - 1 do top:set(xx, y - j) end end
  for i = 1, d do for yy = y - i, y + w - 1 - i do side:set(x + w - 1 + i, yy) end end
  -- top row of the side face fills the corner to the top face
  sil:add(front):add(top):add(side)
  -- seam with neighbours painted earlier: ring around silhouette over existing pixels
  sil:grow(1):cut(sil):each(function(xx, yy) if c:get(xx, yy) then c:put(xx, yy, EDGE[R], tok) end end)
  front:each(function(xx, yy)
    local dx, dy = xx - x, yy - y
    local t = (dx + dy) / (2 * w - 2)
    local i = t < 0.28 and 5 or (t < 0.68 and 4 or 3)
    if dy == 0 then i = 6 elseif dx == 0 then i = 5 end
    if dy == w - 1 then i = 2 end
    c:put(xx, yy, R[i], tok)
  end)
  top:each(function(xx, yy)
    local dx, dj = xx - x, y - yy          -- dj 1..d, dx j..j+w-1
    local t = (dx - dj) / (w - 1)           -- 0 left .. 1 right
    local i = t < 0.35 and 6 or (t < 0.75 and 5 or 4)
    if dj == d then i = 6 end
    if xx == x + dj then i = 6 end
    c:put(xx, yy, R[i], tok)
  end)
  side:each(function(xx, yy)
    local i0 = xx - (x + w - 1)             -- 1..d
    local dy = yy - (y - i0)
    local i = (dy < w * 0.45) and 3 or 2
    if i0 == d then i = max(1, i - 1) end
    if dy == w - 1 then i = 1 end
    if dy == 0 then i = 4 end
    c:put(xx, yy, R[i], tok)
  end)
  if hopper then
    -- stair-stepped hollow on the front face: rings darker toward the centre; lit lower/right lips
    local rings = floor((w - 1) / 3)
    for r = 1, rings do
      local a, b = x + r * 1.5, x + w - 1 - r * 1.5
      local ya, yb = y + r * 1.5, y + w - 1 - r * 1.5
      a, b, ya, yb = floor(a + 0.5), floor(b + 0.5), floor(ya + 0.5), floor(yb + 0.5)
      if b - a >= 1 and yb - ya >= 1 then
        for yy = ya, yb do for xx = a, b do
          local i = max(1, 4 - r)
          if yy == ya or xx == a then i = max(1, 3 - r) end      -- shaded upper/left wall
          if yy == yb or xx == b then i = min(6, 4 + 1) end      -- lit lower/right lip
          c:put(xx, yy, R[i], tok)
        end end
      end
    end
  end
  -- crystalline flecks and one hairline crack
  front:each(function(xx, yy)
    local h = X.hash(xx, yy, tokN * 3)
    if h > 0.93 and yy > y and xx > x and yy < y + w - 1 then c:put(xx, yy, R[6], tok)
    elseif h < 0.05 and yy > y + 1 and yy < y + w - 2 and xx > x + 1 then c:put(xx, yy, R[3], tok) end
  end)
  return sil
end

c:groundShadow(32, 55, 25, 2.4)
-- back to front
cube(27, 12, 11, 5, SB, true)
cube(15, 23, 9, 4, ST, true)
cube(29, 24, 10, 4, SW, true)
cube(7, 35, 9, 4, SW, false)
cube(20, 35, 10, 4, SB, true)
cube(36, 34, 9, 4, ST, false)
cube(6, 47, 8, 3, SB, false)
cube(16, 46, 10, 4, ST, false)
cube(31, 46, 9, 4, SB, true)
cube(44, 40, 6, 3, SW, false)
cube(11, 28, 5, 2, SB, false)

-- quirk: little spiral shell leaning on the front-right of the pile
local SH = { "#7a4252", "#a8626a", "#d98a78", "#f2b498", "#fcd4b4", "#fff2de" }
local shm = HP.mask()
local scx, scy, srx, sry = 50, 51, 5, 4.4
for y = scy - 6, scy + 6 do for x = scx - 7, scx + 7 do
  local dx, dy = (x - scx) / (srx + 0.5), (y - scy) / (sry + 0.5)
  if dx * dx + dy * dy <= 1 then shm:set(x, y) end
end end
-- rim seam against the cubes
shm:grow(1):cut(shm):each(function(x, y) if c:get(x, y) then c:put(x, y, "#4a5c8c") end end)
local shn = X.sphere(scx, scy, 4.6, shm)
local shv = X.light(shn, { amb = 0.06, wrap = 0.22 })
local shtok = { r = { name = "shell" } }
local shi = X.tone(c, shm, shv, SH, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = shtok })
shm:each(function(x, y)
  local k = K(x, y)
  local dx, dy = x - scx, y - scy
  local r = sqrt((dx / (srx + 0.5)) ^ 2 + (dy / (sry + 0.5)) ^ 2)
  local ang = atan2(dy, dx) / (2 * pi)
  local ph = (r * 2.0 - ang * 1.0) % 1
  if ph < 0.3 and r > 0.15 then c:put(x, y, SH[1], shtok)
  elseif ph > 0.74 and r > 0.15 then c:put(x, y, SH[min(6, (shi[k] or 3) + 2)], shtok) end
end)
-- aperture (mouth) lower-right with cream lip
for _, p in ipairs{ { 52, 53, 1 }, { 53, 53, 1 }, { 53, 52, 2 }, { 51, 54, 2 }, { 52, 54, 1 } } do if shm:has(p[1], p[2]) then c:put(p[1], p[2], p[3] == 1 and SH[1] or SH[2], shtok) end end
c:put(47, 49, SH[6], shtok) c:put(48, 48, SH[6], shtok)
-- apex nub
c:put(46, 50, SH[3], shtok)

c:sparkle(47, 14)
A.save(c, "sea-salt")
