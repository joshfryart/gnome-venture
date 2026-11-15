-- Chilli Chime (sp-chilli-chime), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: bigger shapes, fewer details than the yard. Common, brewroot.
-- quirk: the garland's bells chime (two cream sound ticks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-chilli-chime-perch", 36)

c:part(c:ellipse(18, 23, 10, 9), "moss", { pop = { x = 12, y = 17, horizontal = true } })
c:part(c:line({ { 4, 9 }, { 18, 13 }, { 32, 9 } }, 1), "wood", { noshade = true })
for _, ch in ipairs({ { 6, 10, 8, 15 }, { 16, 13, 18, 19 }, { 26, 10, 28, 15 } }) do
  c:part(c:poly{ { ch[1], ch[2] }, { ch[1] + 2, ch[2] }, { ch[3], ch[4] }, { ch[3] - 1, ch[4] + 1 } }, "ember", { band = 1 })
end
H.dot(c, 12, 19, P.gold.base)
H.dot(c, 13, 20, P.gold.deep)
H.dots(c, { { 3, 16 }, { 33, 16 } }, P.cream)

c:eyeSmall(13, 21)
c:eyeSmall(21, 21)
H.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
H.done(c, "sp-chilli-chime-perch")
