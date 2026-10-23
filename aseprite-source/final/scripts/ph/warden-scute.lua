local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- Warden's Scute: one shed shell plate (pale bone, soil-family cream) shaped like a
-- broad fan tapering to a rounded keel, thick tan underside showing, growth rings
-- round the rim and three neat parallel scratches across the raised centre.
local bone = GV.ramp("#f1ece0", { dot = "#fff8e0" })
local under = GV.ramp("#c9a96e")
local top = c:poly({ { 9, 22 }, { 20, 11 }, { 42, 9 }, { 56, 18 }, { 51, 33 }, { 38, 48 }, { 29, 50 }, { 17, 38 } }):shrink(3):grow(3)
local side = top:shift(1, 4)
c:build{
  { "underside", side, under, { gloss = false } },
  { "plate", top, bone, { gloss = { 15, 22 } } },
}
-- a growth ring parallel to the rim (lower-right two thirds, off the gloss)
local ring1 = top:shrink(4):edge()
local RC = "#c9a96e"
ring1:each(function(x, y) if (x - 32) + (y - 28) > -8 then c:px(x, y, RC) end end)
-- three neat parallel scratches: umber groove with a lit lower lip
for i = 0, 2 do
  local x, y = 22 + i * 6, 21 + i * 2
  c:fill(c:line({ { x, y }, { x + 6, y + 13 } }, 1), "#8a4f2a")
  c:fill(c:line({ { x + 1, y }, { x + 7, y + 13 } }, 1), "#fff3c8")
end
local t = c:save(D .. "final/aseprite/ph/warden-scute.aseprite", PNG .. "warden-scute.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
