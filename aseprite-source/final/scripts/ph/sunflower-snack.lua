local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f4f0e0", { shade = "#d6c9b6" })
local band  = GV.ramp("#d6c9b6")
-- golden dome of seeds (back), wide half-moon bowl, rim band in front
local mound = c:ellipse(31.5, 29, 17, 15):cut(c:rect(0, 29, 63, 63))
mound:add(c:ellipse(22, 22, 6, 5)):add(c:ellipse(41, 21, 6, 6))
mound:cut(c:rect(0, 29, 63, 63))
local cup = c:ellipse(31.5, 30, 20, 20):cut(c:rect(0, 0, 63, 30))
local rim = c:rrect(11, 26, 52, 31, 2)
c:build{
  { "mound", mound, "gold" },
  { "cup",   cup,   cream, { gloss = { 19, 36 } } },
  { "rim",   rim,   band,  { gloss = false } },
}
-- seeds: bean shapes on the mound
local function bean(x, y, base, dark)
  c:paint({ ".bb.", "bbbd", "bbdd", ".dd." }, x, y, { b = base, d = dark })
end
bean(21, 19, "#b07a10", "#7a3a14")
bean(33, 17, "#7ab55c", "#2f5a2a")
bean(41, 21, "#f5cf6a", "#b8661a")
bean(27, 23, "#7a3a14", "#5e2f1e")
bean(37, 24, "#b07a10", "#7a3a14")
bean(16, 24, "#f5cf6a", "#b8661a")
bean(45, 16, "#b07a10", "#7a3a14")
c:seam({ { 13, 28 }, { 50, 28 } })
c:button(30, 27)
c:ground(31.5, 52, 15, 2)
local t = c:save(O .. "aseprite/ph/sunflower-snack.aseprite", O .. "png/ph/sunflower-snack.png")
print(GV.report(t))
