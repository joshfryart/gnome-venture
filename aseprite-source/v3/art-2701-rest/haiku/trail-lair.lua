-- trail-lair (32x32 trail map marker, Haiku first pass). A rocky mound with clawed scratches and a dark cave mouth,
-- a horned bone skull above it with empty eye sockets and a toothed jaw. The lair of the landscape's great beast.
-- quirk: a red ribbon is knotted round the left horn (a first win).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-lair")

c:groundShadow(16, 28, 13, 2)
c:part(c:ellipse(16, 23, 13, 7), "stone")
for _, l in ipairs{ { { 4, 25 }, { 8, 21 } }, { { 6, 27 }, { 10, 23 } }, { { 22, 22 }, { 26, 26 } } } do
  T.fill(c, c:line(l, 1), "#444663")
end
local mouth = c:rect(11, 20, 21, 27):add(c:ellipse(16, 20, 5, 4))
T.fill(c, mouth, "#35295f")
T.fill(c, c:rect(13, 22, 19, 24), "#5a459e")
c:part(c:poly{ { 8, 11 }, { 3, 3 }, { 7, 8 }, { 10, 9 } }, "sky", { nopop = true })
c:part(c:poly{ { 24, 11 }, { 29, 3 }, { 25, 8 }, { 22, 9 } }, "sky", { nopop = true })
c:part(c:ellipse(16, 12, 7, 5), "sky")
T.fill(c, c:ellipse(13, 12, 2, 2), "#35295f")
T.fill(c, c:ellipse(19, 12, 2, 2), "#35295f")
c:put(12, 11, "#fff4d6") c:put(18, 11, "#fff4d6")
c:part(c:rect(12, 16, 20, 18), "sky", { nopop = true })
for _, x in ipairs{ 13, 16, 19 } do c:put(x, 17, "#35295f") end
c:put(6, 7, "#e8493b") c:put(7, 7, "#ff8a5c") c:put(6, 8, "#b52e3f") c:put(7, 8, "#e8493b")
T.done(c)
