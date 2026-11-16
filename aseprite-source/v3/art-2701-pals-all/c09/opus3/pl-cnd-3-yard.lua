-- Updraft Fluff (pl-cnd-3), yard sprite 64x64. Opus richness pass (c09/opus3), built on c09/opus2.
-- opus3: warmer hue-shifted ramp (plum shade -> peach mid -> cream light), a dark crease between neighbouring
-- tufts so each one reads, lit strand flecks, a pale down-ring round the face, a dark lip line on the open mouth
-- with a tongue, short lift streaks beside the curls, and (closer look) a loose wisp of down blowing
-- off behind it next to the caught seed, which has a tiny green sprout.
-- Seedkeeper, common, Condor's Crag. "A puff of cream neck fluff that rides the wind to see the view."
-- A round puff of the condor's cream neck ruff: a soft body ringed with pointed down tufts that all comb the same
-- way (blown up and to the right by the updraft), strand texture, warm cream lit side and lilac shade.
-- It rides two curls of pale updraft wind; its little shadow is far below.
-- quirk: it is up on the wind for the view: mouth open in a happy "wow", one long tuft on its crown pointing out
-- the way like a lookout's finger.
-- closer look: one brown seed caught in the fluff (it is a seedkeeper).
-- Fixes over haiku: peach blob with a lumpy cloud outline (now a downy puff with combed tufts and strand texture),
-- wind squiggles detached in the corners (now updraft curls it is sitting on).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-3-yard", 64)

local FLUFF = { "#6e4e70", "#a0808f", "#cfae9f", "#ebd2b4", "#f8e8cc", "#fdf4e2" }
local WIND = { "#8bc4ea", "#b9e2f5", "#e4f6ff" }

c:groundShadow(31, 58, 7, 1)

-- body + tufts
local cx, cy, R = 31, 30, 14
local puff = c:ellipse(cx, cy, R, R - 1)
local tufts = {}
for a = 0, 21 do
  local ang = a * math.pi * 2 / 22 + .15
  if not (ang > 1.2 and ang < 1.9) then -- leave the bottom fairly smooth where the wind holds it
    local bx, by = cx + math.cos(ang) * (R - 2), cy + math.sin(ang) * (R - 3)
    local len = 3.5 + H(a, 1, 3) * 2
    -- combed: tips bend toward up-right (the updraft)
    local tx, ty = cx + math.cos(ang) * (R + len) + 1.5, cy + math.sin(ang) * (R - 1 + len) - 1.5
    local mx, my = (bx + tx) / 2 + 1, (by + ty) / 2 - 1
    tufts[#tufts+1] = { { bx, by }, { mx, my }, { mx + (tx - mx) * .5, my + (ty - my) * .5 }, { tx, ty } }
  end
end
local tuftMask = HP.mask()
for _, t in ipairs(tufts) do
  local m = O.tube(t, function(u) return 2.6 * (1 - u) ^ .9 + .3 end)
  tuftMask:add(m)
end
-- lookout tuft on the crown, long and pointing right
local look = O.tube({ { 31, 17 }, { 31, 11 }, { 35, 8 }, { 41, 9 } }, function(u) return 1.6 * (1 - u) ^ .7 + .3 end)
tuftMask:add(look)
local whole = puff:copy():add(tuftMask)
local wI, wT = O.shade(c, whole, FLUFF, { sphere = { 27, 25, 19 }, amb = .3, wrap = .5, rim = true, bounce = "#8fb0d8", bmax = 2 })
-- strand texture: short streaks combed up-right, away from the face
local function face(x, y) return x >= 20 and x <= 42 and y >= 25 and y <= 40 end
O.tex(c, wI, wT, FLUFF, function(x, y, i)
  if face(x, y) then return 0 end
  local h = H((x + y) // 2, (x - y) // 3, 5)
  -- crease between tufts: near the rim, at the angle half-way between two tuft roots
  local r = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.07) ^ 2)
  local ang = (math.atan(y - cy, x - cx) - .15) % (math.pi * 2)
  local ph = (ang / (math.pi * 2 / 22)) % 1
  if r > R - 3 and r < R + 2 and math.abs(ph - .5) < .09 then return -2 end
  if h > .8 then return -1 end
  if h < .12 and i >= 3 then return 1 end
end)
-- a pale down-ring around the face (softer, finer fluff there)
O.tex(c, wI, wT, FLUFF, function(x, y, i)
  local d = ((x - 31) / 12) ^ 2 + ((y - 32) / 9) ^ 2
  if d > .85 and d < 1.05 and i <= 4 and (x + y) % 2 == 0 then return 1 end
end)
-- tuft roots: a darker crease where each tuft leaves the body
for _, t in ipairs(tufts) do
  local x, y = math.floor(t[1][1] + .5), math.floor(t[1][2] + .5)
  if not face(x, y) and c:get(x, y) then O.mark(c, { { x, y } }, FLUFF[3]) end
end

-- a seed caught in the fluff (it is a seedkeeper)
O.dots(c, { { 39, 20 }, { 40, 20 }, { 41, 21 }, { 39, 21 }, { 40, 21 } }, "#864c33")
O.dots(c, { { 38, 21 }, { 41, 22 }, { 40, 22 } }, "#51302b")
O.dot(c, 39, 20, "#d89c62")
O.dots(c, { { 38, 19 }, { 37, 18 } }, "#6a9a4a") O.dot(c, 37, 17, "#9ac85a") -- sprout

-- face: happy wow
c:eyeLocked(23, 27)
c:eyeLocked(34, 27)
c:cheek(22, 34) c:cheek(39, 34)
local mouth = c:ellipse(31, 35.5, 2, 2)
O.flat(c, mouth, "#5a2a4a", "mouth")
mouth:edge():each(function(x, y) c:put(x, y, P.ink, { r = { name = "lip" } }) end)
O.dots(c, { { 31, 36 }, { 30, 36 }, { 32, 36 } }, P.petal.base) O.dot(c, 31, 35, "#3a1e36")

O.done(c, "pl-cnd-3-yard", function(c)
  -- updraft: two wind curls rising under it, plus lift ticks (1 px, un-outlined)
  local function curl(x0, y0, dir)
    local pts = {}
    for i = 0, 30 do
      local t = i / 30
      local ang = t * math.pi * 1.6
      local r = 4 * (1 - t * .55)
      pts[#pts+1] = { x0 + dir * (t * 9 + math.sin(ang) * r), y0 - t * 4 - (1 - math.cos(ang)) * r * .7 }
    end
    for i, p in ipairs(pts) do
      local x, y = math.floor(p[1] + .5), math.floor(p[2] + .5)
      if not c:get(x, y) then c:put(x, y, i < 12 and WIND[1] or WIND[2]) end
    end
  end
  curl(14, 54, 1) curl(48, 54, -1)
  O.dots(c, { { 27, 50 }, { 27, 51 }, { 31, 52 }, { 31, 53 }, { 35, 50 }, { 35, 51 } }, WIND[1])
  -- short lift streaks rising past its flanks
  O.dots(c, { { 9, 40 }, { 9, 39 }, { 10, 37 }, { 10, 36 }, { 53, 40 }, { 53, 39 }, { 52, 37 }, { 52, 36 } }, WIND[2])
  -- a loose wisp of down blowing off behind (closer look)
  for _, p in ipairs({ { 8, 13 }, { 9, 12 }, { 10, 12 }, { 11, 13 }, { 7, 14 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], p[1] == 7 and FLUFF[3] or FLUFF[5]) end
  end
end)
