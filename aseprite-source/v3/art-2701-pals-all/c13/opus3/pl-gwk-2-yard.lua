-- Pawprint Cuff (pl-gwk-2), yard sprite 64x64. Opus richness pass (c13/opus3), built on c13/opus2.
-- opus3: opus2's open middle read as a dark band. The hole is now deep: the far inner wall is lit at its top lip and
-- falls through grainy snow tones into a dark well, and a bright fluffed near lip overhangs the darkest pixels (the
-- strongest value jump on the sprite). Snow ramp hue-shifted (violet shade to warm cream top), frost glints in the
-- grain, ice-blue dents in the print. closer-look: four tiny claw pricks above the toes (a wolf's print, not a cat's).
-- Rootwarden, common, Lair of the Grey Wolf King. "A soft snow cuff with one perfect pawprint pressed into it."
-- Haiku weakness fixed: a flat pale-blue pillow (read as a marshmallow) with a grey blob for a print. Now a cuff:
-- a short wide ring of packed snow seen a little from above, with a dark open middle, lumpy fluffed-snow rims top and
-- bottom, cool blue shading and glinting snow crystals.
-- quirk: one perfect pawprint pressed into the front: big heel pad and four toes as real dents (shadowed top-left
-- wall, lit lower-right lip), crisp enough to hold at 25%. closer-look: a tiny snowflake caught on the rim.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-2-yard", 64)

local SNOW = { "#3a3c6c", "#566a9c", "#84a0c8", "#aec4e2", "#d2e2f2", "#f4f6f0" }
local HOLE = { "#221e3c", "#302e56", "#423f72", "#5a5e92" }

c:groundShadow(32, 55, 25, 2.5)
-- body: short wide cylinder, lumpy fluffed rims
local body = c:rect(8, 23, 56, 46)
body:add(c:ellipse(32, 46, 24, 6))
body:add(c:ellipse(32, 23, 24, 9.5))
for _, b in ipairs({ { 8, 27 }, { 7, 34 }, { 8, 41 }, { 56, 28 }, { 57, 35 }, { 56, 42 },
                     { 13, 49 }, { 21, 52 }, { 29, 53 }, { 37, 53 }, { 45, 52 }, { 52, 49 } }) do
  body:add(c:ellipse(b[1], b[2], 2.5, 2.5))
end
local bn = {}
body:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 32) / 25.5))
  local sy = (y < 23) and -.55 or ((y > 45) and .45 or 0)
  local l = math.sqrt(sx * sx + sy * sy + (1 - sx * sx))
  bn[K(x, y)] = { sx / l, sy / l, math.sqrt(1 - sx * sx) / l }
end)
local bI, bT = O.shadeN(c, body, bn, SNOW, { amb = .3, wrap = .5, rim = true, bounce = "#9a8ac8", bmax = 3 })
-- packed-snow grain: soft clumps
O.tex(c, bI, bT, SNOW, function(x, y, i)
  if x >= 11 and x <= 52 and y >= 29 and y <= 46 then
    if O.H(x, y, 3) > .93 and i >= 3 then return -1 end
    return 0
  end
  local h = O.H(x, y, 7)
  if h > .86 and i >= 2 then return -1 end
  if O.H(x, y, 11) > .985 and i >= 3 and i <= 5 then return 6 end -- frost glints
  if h < .06 and i <= 5 then return 1 end
end)
-- the open middle (top): a deep well, seen from above. Far inner wall lit at its top lip and falling through
-- grainy snow into a dark well; the near lip (bright body rim just below) overhangs the darkest pixels.
local HCX, HCY, HRX, HRY = 32, 21, 16.5, 7
local hole = c:ellipse(HCX, HCY, HRX, HRY)
hole:each(function(x, y)
  local u = (x - HCX) / HRX
  -- depth line: the near lip's shadow edge is an arc parallel to the hole's front edge, 4 px up
  local front = HCY + HRY * math.sqrt(math.max(0, 1 - u * u))
  local d = front - y            -- 0 at the near lip, grows towards the far wall
  local g = O.H(x, y, 5) > .78 and 1 or 0
  local col
  if d <= 1.5 then col = HOLE[1]
  elseif d <= 3.5 then col = HOLE[2]
  elseif d <= 5.5 then col = (u > .2) and HOLE[4] or HOLE[3]
  elseif d <= 8 then col = (u > .1) and SNOW[3 - g] or SNOW[2 + g]
  else col = (u > -.2) and SNOW[4 - g] or SNOW[3] end
  c:put(x, y, col, { r = { name = "hole" } })
end)
-- the near lip: one bright row hugging the front of the hole, a soft snow lump on it
hole:grow(1):each(function(x, y)
  if not hole:has(x, y) and y > HCY + 1 and c.own[y * 64 + x] == bT then c.pix[y * 64 + x] = (x < 36) and SNOW[6] or SNOW[5] end
end)
-- fluffed bumps on the top rim (lit)
for _, b in ipairs({ { 12, 18 }, { 20, 14 }, { 32, 13 }, { 44, 14 }, { 52, 18 } }) do
  local m = c:ellipse(b[1], b[2], 2.5, 2)
  O.shade(c, m, SNOW, { sphere = { b[1] - 1, b[2] - 1, 3.5 }, amb = .45, wrap = .5, cuts = { .1, .25, .45, .65, .8 } })
end

-- quirk: the pawprint, pressed in (right of the face)
local function press(m)
  m:each(function(x, y)
    local p = y * 64 + x
    local tl = not m:has(x - 1, y) or not m:has(x, y - 1)
    local br = not m:has(x + 1, y) or not m:has(x, y + 1)
    c.pix[p] = tl and SNOW[1] or (br and "#8ab8dc" or "#6c8cc0") -- ice-blue packed dents
  end)
  m:each(function(x, y)
    for _, d in ipairs({ { 1, 0 }, { 0, 1 } }) do
      local nx, ny = x + d[1], y + d[2]
      if not m:has(nx, ny) and c.own[ny * 64 + nx] == bT then c.pix[ny * 64 + nx] = SNOW[6] end
    end
  end)
end
local heel = c:ellipse(43, 42, 5, 3.5)
heel:add(c:ellipse(40, 40.5, 2.5, 2.5)) heel:add(c:ellipse(46, 40.5, 2.5, 2.5))
press(heel)
press(c:ellipse(36, 35, 2, 2.5))
press(c:ellipse(40.5, 32, 2, 2.5))
press(c:ellipse(46, 32, 2, 2.5))
press(c:ellipse(50, 35, 2, 2.5))

-- closer-look: claw pricks above the four toes
O.mark(c, { { 36, 31 }, { 40, 28 }, { 46, 28 }, { 51, 31 } }, SNOW[2])
-- face
c:eyeLocked(15, 32)
c:eyeLocked(25, 32)
c:cheek(13, 39) c:cheek(30, 39)
O.dots(c, { { 19, 40 }, { 20, 41 }, { 21, 41 }, { 22, 40 } }, P.ink)

O.done(c, "pl-gwk-2-yard", function(c)
  -- closer-look: a tiny snowflake caught on the rim (cool cream, un-outlined)
  for _, p in ipairs({ { 56, 18 }, { 56, 17 }, { 56, 19 }, { 55, 18 }, { 57, 18 }, { 55, 16 }, { 57, 16 }, { 55, 20 }, { 57, 20 } }) do c:put(p[1], p[2], SNOW[6]) end
  c:put(56, 18, "#9ad0ee")
  c:sparkle(5, 14)
  c:sparkle(60, 30)
end)
