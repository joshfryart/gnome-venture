-- ph/iced-tea-concentrate (Pantry cordial): wicker-wrapped demijohn, woven basket lower half with rim and loop handles, amber iced tea, cork and tea-leaf tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "iced-tea-concentrate"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass",  c:ellipse(32, 36, 17, 14):add(c:rect(28, 12, 36, 24)), "#d8ecf0", { pale = false } },
  { "liquid", c:ellipse(32, 37, 14, 11), GV.ramp("#a8742f", { shade = "#7a4a1f" }), { contour = "#7a4a1f", gloss = { 22, 31 } } },
}
c:part(c:rect(28, 7, 36, 13), "#c9a96e", { gloss = false })
c:px(30, 9, "#9a6b3f"); c:px(34, 11, "#9a6b3f")
-- loop handles (behind the basket rim), basket, rim band
c:part(c:ellipse(12, 44, 4):cut(c:ellipse(12, 44, 2)), "#9a6b3f", { gloss = false, cres = 2, deep = 0 })
c:part(c:ellipse(52, 44, 4):cut(c:ellipse(52, 44, 2)), "#9a6b3f", { gloss = false, cres = 2, deep = 0 })
local basket = c:rrect(14, 39, 50, 56, 6)
c:part(basket, GV.ramp("#c9a96e", { shade = "#9a6b3f", deep = "#7a4a1f" }), { gloss = false })
for y = 43, 55, 3 do for x = 15, 49 do if (x + y) % 3 == 0 and basket:has(x, y) then c:px(x, y, "#9a6b3f") end end end
for x = 16, 48, 3 do for y = 42, 55 do if (x + y) % 2 == 0 and basket:has(x, y) then c:px(x, y, "#9a6b3f") end end end
c:part(c:rrect(13, 38, 51, 41, 1), "soil", { gloss = false, cres = 2 })
c:seam({ {15, 39}, {49, 39} }, { free = true })
-- tea tag hanging from the neck on a string
c:fill(c:line({ {35, 18}, {38, 26} }, 1), "#7a4a1f")
c:part(c:rrect(33, 26, 44, 34, 1), "cream", { gloss = false, contact = false })
c:paint({ "..gg..", ".gGgg.", "gkkkkg", ".gggg." }, 35, 28, { g = "#4f9a45", G = "#a4b86a", k = "#2f5a2a" })
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
