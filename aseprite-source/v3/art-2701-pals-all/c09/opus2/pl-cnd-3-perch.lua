-- Updraft Fluff (pl-cnd-3), perch sprite 36x36. Opus second pass (c09/opus2), hand-built at this size.
-- Cream downy puff with short combed tufts, strand texture, lilac shade; a lookout tuft curling off its crown.
-- quirk: riding the updraft for the view, open "wow" mouth, wind curls rising under it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-3-perch", 36)
local FLUFF = { "#7a5a78", "#a88a98", "#d0b4a8", "#ead6bc", "#f8ead2", "#fff6e6" }
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
O.tex(c, I, T, FLUFF, function(x, y, i) if (x < 11 or x > 23 or y < 13) and H((x + y) // 2, (x - y) // 2, 5) > .8 then return -1 end end)
c:eyeSmall(13, 15) c:eyeSmall(20, 15)
O.dot(c, 11, 19, P.petal.base) O.dot(c, 23, 19, P.petal.base)
O.flat(c, c:rect(16, 19, 18, 21), P.ink, "mouth") O.dot(c, 17, 20, "#5a2a4a") O.dot(c, 17, 21, P.petal.base)
O.done(c, "pl-cnd-3-perch", function(c)
  for _, w in ipairs({ { { 9, 30 }, { 7, 28 }, { 9, 26 }, { 11, 27 } }, { { 26, 30 }, { 28, 28 }, { 26, 26 }, { 24, 27 } } }) do
    for i = 0, 12 do local x, y = O.bez(w, i / 12) x, y = math.floor(x + .5), math.floor(y + .5) if not c:get(x, y) then c:put(x, y, i < 6 and WIND[1] or WIND[2]) end end
  end
  O.dots(c, { { 15, 28 }, { 15, 29 }, { 19, 29 }, { 19, 30 } }, WIND[1])
end)
