-- Silverback Spool (pl-sbs-6), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
-- Seedkeeper, rare, Hollow of the Silverback Spider (whimsy-spider). "The big spider's spare spool, still humming
-- its old web song."
-- Haiku weakness fixed: a sideways log with 1 px stick legs read as a bug on a barrel and the face was squashed
-- into a thin band. Now the spool stands upright on its bottom flange like a little body: a tall barrel of wound
-- silver silk (fine wind lines, a crossing wrap band) between two dark wood flanges with end grain and a peg on
-- top, and eight jointed spider legs (charcoal, silver knee bands) splaying out from behind it.
-- quirk: it is still humming: an "o" humming mouth and two notes and a fading third drifting up off the top left.
-- closer-look: the loose end of the silk trailing down and curling at the foot. Rare: sparkles.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-6-yard", 64)

local WOOD = { "#3a2018", "#5e3426", "#8a5232", "#b47844", "#d9a066", "#f2c890" }
local SILK = { "#3e3f58", "#5e6484", "#8b93b0", "#b6bfd4", "#dae1f0", "#f1f4fb" }
local LEG  = { "#1c1824", "#2c2838", "#433e58", "#5f5a7a", "#8a86a6" }

c:groundShadow(32, 57, 21, 2.5)
-- eight legs, behind the spool (left side mirrored to the right)
local legs = {
  { { 23, 22 }, { 15, 14 }, { 8, 16 }, { 4, 26 } },
  { { 23, 28 }, { 13, 19 }, { 6, 24 }, { 4, 36 } },
  { { 23, 35 }, { 14, 28 }, { 7, 35 }, { 6, 47 } },
  { { 23, 42 }, { 16, 38 }, { 10, 46 }, { 11, 56 } },
}
for side = -1, 1, 2 do
  for _, L in ipairs(legs) do
    local p = {}
    for i, q in ipairs(L) do p[i] = { side < 0 and q[1] or 63 - q[1], q[2] } end
    local m, n, T = O.tube(p, function(t) return 1.25 - t * .45 end)
    local I, Tk = O.shadeN(c, m, n, LEG, { amb = .3, wrap = .4, sep = LEG[1], rim = true })
    -- silver knee band and fur ticks
    O.tex(c, I, Tk, LEG, function(x, y, i)
      local t = T[K(x, y)]
      if t and math.abs(t - .42) < .035 then return 2 end
      if t and t > .9 then return 1 end
    end)
  end
end
-- barrel of wound silk (cylinder normals)
local barrel = c:rect(20, 15, 44, 50)
local bn = {}
barrel:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 32) / 13.5))
  bn[K(x, y)] = { sx, -.15, math.sqrt(1 - sx * sx) }
end)
local bI, bT = O.shadeN(c, barrel, bn, SILK, { amb = .28, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 3 })
O.tex(c, bI, bT, SILK, function(x, y, i)
  -- the crossing wrap band (a diagonal of brighter thread)
  local d = (y - 17) - (x - 20) * .55
  if d >= 0 and d < 2 and not (x >= 23 and x <= 41 and y >= 25 and y <= 40) then return 1 end
  if y % 2 == 0 and i >= 2 then return -1 end
end)
-- wood flanges: rim band + lit end face, end grain rings
local function flange(cy, top)
  local rimm = HP.mask()
  for dy = 0, 3 do rimm:add(c:ellipse(32, cy + dy, 17, 4)) end
  local I, T = O.shade(c, rimm, WOOD, { R = 3, amb = .3, wrap = .45, sep = WOOD[1], rim = true, bounce = "#7a5a7a", bmax = 2 })
  O.tex(c, I, T, WOOD, function(x, y, i) if (x + math.floor(y * .5)) % 5 == 0 and i >= 3 then return -1 end end)
  if top then
    local face = c:ellipse(32, cy, 17, 4)
    local fI, fT = O.shade(c, face, WOOD, { R = 2, amb = .45, wrap = .5, sep = WOOD[2] })
    O.tex(c, fI, fT, WOOD, function(x, y, i)
      local e = math.sqrt(((x - 32) / 17) ^ 2 + ((y - cy) / 4) ^ 2)
      if math.abs((e * 3) % 1 - .5) < .14 then return -1 end
    end)
  end
end
flange(47, false)
flange(11, true)
-- the peg on top
O.shade(c, c:rrect(30, 5, 34, 12, 1), WOOD, { R = 2, amb = .35, wrap = .45, sep = WOOD[1], rim = true })
O.shade(c, c:ellipse(32, 5, 2, 1), WOOD, { R = 1, amb = .5, sep = WOOD[2] })
-- loose silk end trailing down and curling at the foot
local tail = O.tube({ { 44, 44 }, { 51, 46 }, { 50, 55 }, { 56, 55 } }, function() return .55 end)
O.flat(c, tail, SILK[5], "loose")
local curl = O.tube({ { 56, 55 }, { 60, 55 }, { 60, 51 }, { 57, 52 } }, function() return .55 end)
O.flat(c, curl, SILK[5], "curl")

-- face: humming
c:eyeLocked(24, 26)
c:eyeLocked(35, 26)
c:cheek(22, 33) c:cheek(40, 33)
O.dots(c, { { 31, 35 }, { 32, 35 }, { 30, 36 }, { 33, 36 }, { 30, 37 }, { 33, 37 }, { 31, 38 }, { 32, 38 } }, P.ink)
O.dots(c, { { 31, 36 }, { 32, 36 }, { 31, 37 }, { 32, 37 } }, "#8a3a5a")

O.done(c, "pl-sbs-6-yard", function(c)
  -- two notes and a fading third drifting off the top right, each a little higher and smaller
  local function note(x, y, h, col)
    c:put(x, y, col) c:put(x + 1, y, col) c:put(x, y + 1, col) c:put(x + 1, y + 1, col)
    for k = 1, h do c:put(x + 2, y + 1 - k, col) end
    c:put(x + 3, y + 2 - h, col) c:put(x + 4, y + 3 - h, col)
  end
  note(3, 9, 5, P.ink)
  note(9, 3, 5, P.ink)
  c:put(15, 2, SILK[2]) c:put(16, 2, SILK[2]) c:put(17, 1, SILK[2]) c:put(17, 0, SILK[2])
  c:sparkle(52, 4)
  c:sparkle(59, 10)
end)
