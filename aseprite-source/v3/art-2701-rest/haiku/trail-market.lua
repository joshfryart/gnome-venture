-- trail-market (32x32 trail map marker, Haiku first pass). A market stall: a red and cream striped awning on two posts,
-- a wooden counter with apples, a loaf and a cabbage on it.
-- quirk: a little cream price tag hangs off the awning edge on a string.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-market")

c:groundShadow(16, 28, 12, 2)
c:part(c:rect(5, 11, 7, 26), "wood")
c:part(c:rect(24, 11, 26, 26), "wood")
c:part(c:rect(4, 18, 27, 26), "wood")
local aw = c:poly{ { 3, 4 }, { 28, 4 }, { 30, 11 }, { 1, 11 } }
for x = 1, 30, 4 do
  local col = (x // 4) % 2 == 0 and "#e8493b" or "#fff4d6"
  T.fill(c, c:rect(x, 3, x + 3, 12):clip(aw), col)
end
for x = 1, 30, 4 do
  local col = (x // 4) % 2 == 0 and "#b52e3f" or "#e4d8b0"
  c:put(x + 1, 3, col) c:put(x + 2, 3, col)
end
T.fill(c, c:line({ { 2, 11 }, { 29, 11 } }, 1):clip(aw), "#864c33")
c:part(c:ellipse(10, 16, 2, 2), "ember", { nopop = true })
c:part(c:ellipse(16, 16, 2, 2), "gold", { nopop = true })
c:part(c:ellipse(22, 16, 2, 2), "moss", { nopop = true })
T.fill(c, c:line({ { 27, 12 }, { 27, 14 } }, 1), "#864c33")
c:part(c:rect(25, 14, 29, 17), "sky", { nopop = true })
c:put(27, 15, "#d98322")
T.done(c)
