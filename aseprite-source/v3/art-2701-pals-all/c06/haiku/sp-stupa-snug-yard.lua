-- Stupa Snug (sp-stupa-snug), yard sprite 64x64. Haiku pass, c06.
-- Uncommon, rootwarden. A plump dusk-violet pal tucked under a white stupa dome, with a
-- string of prayer flags across its shoulders.
-- quirk: the prayer flags are pegged out in a straight line, one flag per knob.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-stupa-snug-yard", 64)

-- body under the dome
local body = c:ellipse(32, 43, 16, 14)
c:part(body, "dusk", { pop = { x = 22, y = 36, horizontal = true } })

-- plinth band where the dome sits
local plinth = c:rrect(18, 28, 46, 33, 2)
c:part(plinth, "gold", { band = 2 })

-- white stupa dome, with a tall spire on top
local dome = c:ellipse(32, 25, 13, 10)
dome:cut(c:rect(0, 27, 63, 63))
c:part(dome, "sky", { pop = { x = 24, y = 19, horizontal = true } })
c:part(c:poly{ { 30, 15 }, { 34, 15 }, { 33, 6 }, { 31, 6 } }, "gold", { band = 1 })
H.dot(c, 32, 4, P.gold.hi)
H.dot(c, 32, 3, P.gold.hi)

-- prayer flag string across the dome
local flagLine = c:line({ { 6, 33 }, { 18, 36 }, { 32, 37 }, { 46, 36 }, { 58, 33 } }, 1)
c:part(flagLine, "wood", { noshade = true })
local flags = {
  { 9, 33, "ember" }, { 17, 35, "gold" }, { 25, 37, "moss" }, { 38, 37, "sea" }, { 47, 36, "petal" }, { 55, 34, "ember" },
}
for _, f in ipairs(flags) do
  local x, y, ramp = f[1], f[2], f[3]
  local m = c:poly{ { x, y }, { x + 4, y + 1 }, { x + 3, y + 4 }, { x, y + 5 } }
  c:part(m, ramp, { band = 1 })
end

-- face
c:eyeLocked(23, 44)
c:eyeLocked(37, 44)
c:cheek(19, 50)
c:cheek(42, 50)
H.dots(c, { { 30, 50 }, { 31, 51 }, { 32, 51 }, { 33, 50 } }, P.ink)

-- feet
c:part(c:ellipse(23, 56, 4, 2), "dusk", { band = 1 })
c:part(c:ellipse(41, 56, 4, 2), "dusk", { band = 1 })

H.done(c, "sp-stupa-snug-yard")
