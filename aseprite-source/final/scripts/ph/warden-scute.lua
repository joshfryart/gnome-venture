local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Warden's Scute: one shed, slightly curled shell plate (pale bone, soil family
-- cream) lying tilted, its thick tan underside showing, three neat scratches.
local bone = GV.ramp("#f1ece0", { dot = "#fff8e0" })
local under = GV.ramp("#c9a96e")
local top = c:poly({ { 13, 17 }, { 47, 11 }, { 54, 37 }, { 33, 50 }, { 9, 41 } }):shrink(4):grow(4)
local side = top:shift(2, 4)
c:build{
  { "underside", side, under, { gloss = false } },
  { "plate", top, bone, { gloss = { 16, 21 } } },
}
-- three neat parallel scratches: umber groove with a lit lower lip
for i = 0, 2 do
  local x = 24 + i * 7
  c:fill(c:line({ { x, 22 }, { x + 4, 38 } }, 1), "#9a6b3f")
  c:fill(c:line({ { x + 1, 23 }, { x + 5, 39 } }, 1), "#fff3c8")
end
local t = c:save(D .. "final/aseprite/ph/warden-scute.aseprite", PNG .. "warden-scute.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
