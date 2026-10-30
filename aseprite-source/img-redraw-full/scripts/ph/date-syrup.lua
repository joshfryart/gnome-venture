-- ph/date-syrup (Pantry cordial): wide straight diner syrup dispenser, chrome ring cap with a hinged flap, dark date syrup with a rim drip, palm frond label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "date-syrup"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:rrect(15, 19, 49, 56, 4), "#d8ecf0", { pale = false } },
  { "syrup",  c:rrect(17, 27, 47, 54, 3), GV.ramp("#5a3a1f", { rim = "#7a4a1f", gloss = "#a8582f", dot = "#c98a4a" }), { contour = "#3d2a1c", gloss = false } },
}
c:fill(c:rect(19, 29, 20, 52), "#7a4a1f")
c:part(c:rect(21, 34, 43, 52), "cream", { gloss = false, contact = false })
-- chrome ring cap, hinged flap lid tipped up on the right
c:part(c:rrect(13, 12, 51, 20, 3), GV.ramp("#c9c5bc", { shade = "#8b8f96", deep = "#5b6470" }), { gloss = { 16, 14 } })
c:fill(c:rect(15, 19, 49, 19), "#8b8f96")
c:part(c:poly({ {38, 13}, {48, 7}, {51, 10}, {42, 15} }), GV.ramp("#8b8f96"), { gloss = false, cres = 2, deep = 0 })
c:fill(c:rect(37, 13, 39, 14), "#5b6470")
c:seam({ {15, 21}, {49, 21} }, { free = true })
-- syrup drip over the rim
c:part(c:rect(24, 21, 25, 27), "#5a3a1f", { flat = true, contact = false, rim = false })
c:px(24, 22, "#7a4a1f")
-- palm frond with two dates
c:fill(c:line({ {26, 50}, {39, 38} }, 1), "#4f9a45")
for i = 0, 4 do local x, y = 28 + i * 2.5, 48 - i * 2.4
  c:fill(c:line({ {x, y}, {x - 2, y - 2} }, 1):add(c:line({ {x, y}, {x + 2, y + 1} }, 1)), "#4f9a45")
end
c:paint({ "dd.dd", "dD.dD", "dd.dd" }, 29, 47, { d = "#5a3a1f", D = "#9a6b3f" })
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
