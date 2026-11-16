-- Updraft Fluff (pl-cnd-3), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- opus3: warmer plum -> peach -> cream ramp, dark creases between tufts, lit strand flecks, the caught seed,
-- a tongue in the wow. Fewer, bolder details than the yard (no streamlines, no loose wisp).
-- Cream downy puff with short combed tufts, strand texture, lilac shade; a lookout tuft curling off its crown.
-- quirk: riding the updraft for the view, open "wow" mouth, wind curls rising under it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-3-perch", 36)
local FLUFF = { "#6e4e70", "#a0808f", "#cfae9f", "#ebd2b4", "#f8e8cc", "#fdf4e2" }
local WIND = { "#8bc4ea", "#b9e2f5" }
c:groundShadow(18, 32, 4, 1)
local cx, cy, R = 17, 16, 8
local m = c:ellipse(cx, cy, R, R - .5)
for a = 0, 15 do
  local ang = a * math.pi * 2 / 16 + .2
  if not (ang > 1.2 and ang < 1.9) then
    local bx, by = cx + math.cos(ang) * (R - 1), cy + math.sin(ang) * (R - 1)
    local len = 2 + H(a, 2, 3) * 1.2
    local tx, ty = cx + math.cos(ang) * (R + len) + 1, cy + math.sin(ang) * (R + len) - 1
    m:add(O.tube({ { bx, by }, { (bx + tx) / 2, (by + ty) / 2 }, { (bx + tx) / 2 + .3, (by + ty) / 2 - .3 }, { tx, ty } }, function(u) return 1.6 * (1 - u) + .3 end))
  end
end
m:add(O.tube({ { 17, 8 }, { 17, 4 }, { 20, 3 }, { 23, 4 } }, function(u) return 1.1 * (1 - u) + .3 end))
local I, T = O.shade(c, m, FLUFF, { sphere = { 14, 13, 11 }, amb = .3, wrap = .5, rim = true, bounce = "#8fb0d8", bmax = 2 })
O.tex(c, I, T, FLUFF, function(x, y, i)
  local r = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
  local ph = (((math.atan(y - cy, x - cx) - .2) % (math.pi * 2)) / (math.pi * 2 / 16)) % 1
  if r > R - 1.5 and r < R + 2 and math.abs(ph - .5) < .12 then return -2 end
  if (x < 11 or x > 23 or y < 13) and H((x + y) // 2, (x - y) // 2, 5) > .8 then return -1 end
  if (x < 11 or x > 23 or y < 13) and H((x + y) // 2, (x - y) // 2, 5) < .1 and i >= 3 then return 1 end
end)
O.dots(c, { { 21, 10 }, { 22, 10 } }, "#864c33") O.dot(c, 21, 10, "#d89c62") O.dot(c, 22, 11, "#51302b")
c:eyeSmall(13, 15) c:eyeSmall(20, 15)
O.dot(c, 11, 19, P.petal.base) O.dot(c, 23, 19, P.petal.base)
O.flat(c, c:rect(16, 19, 18, 21), P.ink, "mouth") O.dot(c, 17, 20, "#5a2a4a") O.dot(c, 17, 21, P.petal.base)
O.done(c, "pl-cnd-3-perch", function(c)
  for _, w in ipairs({ { { 9, 30 }, { 7, 28 }, { 9, 26 }, { 11, 27 } }, { { 26, 30 }, { 28, 28 }, { 26, 26 }, { 24, 27 } } }) do
    for i = 0, 12 do local x, y = O.bez(w, i / 12) x, y = math.floor(x + .5), math.floor(y + .5) if not c:get(x, y) then c:put(x, y, i < 6 and WIND[1] or WIND[2]) end end
  end
  O.dots(c, { { 15, 28 }, { 15, 29 }, { 19, 29 }, { 19, 30 } }, WIND[1])
end)
