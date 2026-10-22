local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local jarM = c:rrect(13, 19, 51, 56, 6)
jarM:add(c:poly({ {17, 13}, {47, 13}, {52, 20}, {12, 20} }))
local corkM = c:rrect(19, 6, 45, 14, 2)
local labelM = c:rrect(18, 24, 46, 49, 5)
local appleM = c:ellipse(32, 38, 7.5, 7):add(c:ellipse(29, 36, 4, 4)):add(c:ellipse(35, 36, 4, 4))
appleM:del(32, 31)
local tagM = c:poly({ {46, 4}, {56, 15}, {46, 15} })

local p = c:build{
  { "jar",   jarM,   "#f1ece0" },
  { "cork",  corkM,  "wood", { stitch = false } },
  { "tag",   tagM,   "#2e5a2c", { flat = true } },
  { "label", labelM, "#d6322b", { gloss = false } },
}
-- label inner panel (2 px red border)
c:fill(c:rrect(20, 26, 44, 47, 4), "#f4f0e0")
c:fill(c:rrect(20, 26, 44, 47, 4):clip(c:rect(20, 45, 44, 47)), "#e3d8bc")
local ap = c:part(appleM, "#d6322b", { gloss = { 28, 34 }, contact = false })
-- stem and leaf
c:fill(c:rect(31, 28, 32, 31), "#5e2f1e")
c:paint({ ".lll.", "lllll", ".lll." }, 34, 27, { l = "#58a03e" })
c:px(35, 28, "#8cc85a")
-- seeds below the label
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a")
  c:px(x, 52, "#b8703a")
end
-- glass glint streak on jar left
c:fill(c:rect(15, 24, 16, 34), "#fff3c8")
c:px(15, 37, "#fff3c8"); c:px(15, 38, "#fff3c8")
c:seam({ { 20, 12 }, { 44, 12 } })

local t = c:save(O .. "aseprite/ph/apple-seed.aseprite", O .. "png/ph/apple-seed.png")
print(GV.report(t))
