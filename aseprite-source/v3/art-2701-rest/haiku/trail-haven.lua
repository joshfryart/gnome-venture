-- trail-haven (32x32 trail map marker, Haiku first pass). A cosy stone-chimneyed cottage with a red gable roof,
-- gold plaster walls, timber beam, a lit window and a wood door: the safe stop where a gnome rests by the fire.
-- quirk: a cat asleep on the lit windowsill.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-haven")

c:groundShadow(16, 27, 11, 2)
local walls = c:rect(7, 14, 24, 26)
c:part(walls, "gold", { pop = { x = 9, y = 15, horizontal = true } })
local beam = c:line({ { 7, 16 }, { 24, 16 } }, 1):clip(walls)
T.fill(c, beam, "#864c33")
c:part(c:poly{ { 3, 15 }, { 15, 4 }, { 28, 15 } }, "ember")
c:part(c:rect(19, 5, 22, 11), "stone")
c:part(c:ellipse(21, 2, 2, 1), "sky", { nopop = true })
c:part(c:ellipse(24, 1, 1, 1), "sky", { nopop = true })
c:part(c:rect(14, 19, 18, 26), "wood")
c:put(17, 23, "#ffe38a")
c:part(c:rect(9, 17, 12, 21), "gold", { nopop = true })
T.fill(c, c:ellipse(10.5, 20.5, 1.5, 1), "#51302b")
c:put(9, 19, "#51302b") c:put(12, 19, "#51302b")
T.done(c)
