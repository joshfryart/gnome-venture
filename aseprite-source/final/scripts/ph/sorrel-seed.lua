local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- frilly top: fan of three lobes above the waist
local top = c:poly({ {26, 33}, {38, 33}, {45, 20}, {19, 20} })
top:add(c:ellipse(21, 21, 4, 3.5)):add(c:ellipse(32, 19, 5, 4)):add(c:ellipse(43, 21, 4, 3.5))
local body = c:ellipse(32, 44, 17, 12):add(top)
local leaf = c:ellipse(32, 19, 4, 8):add(c:poly({ {30, 12}, {35, 12}, {32, 9} }))
local p = c:build{
  { "cloth", body, "cream" },
  { "leaf", leaf, "moss" },
}
-- frill pleats and waist folds
c:fill(c:line({ {27, 21}, {28, 30} }, 1):clip(body), "#c9a96e")
c:fill(c:line({ {37, 21}, {36, 30} }, 1):clip(body), "#c9a96e")
c:fill(c:line({ {22, 36}, {26, 40} }, 2):clip(body), "#c9a96e")
c:fill(c:line({ {42, 36}, {38, 40} }, 2):clip(body), "#c9a96e")
-- seed bumps on the belly
c:fill(c:ellipse(24, 47, 4, 3):edge():cut(c:rect(0, 0, 63, 46)), "#c9a96e")
c:fill(c:ellipse(32, 50, 4, 3):edge():cut(c:rect(0, 0, 63, 49)), "#c9a96e")
c:fill(c:ellipse(40, 47, 4, 3):edge():cut(c:rect(0, 0, 63, 46)), "#c9a96e")
c:seam({ {20, 53}, {26, 55}, {38, 55}, {44, 53} })
-- string band and bow
c:part(c:rrect(23, 32, 41, 35, 1), "#8c4a1a", { flat = true })
c:part(c:ellipse(27, 31, 3, 2.5):cut(c:ellipse(27, 31, 1, 0.5)), "#8c4a1a", { flat = true })
c:part(c:ellipse(37, 31, 3, 2.5):cut(c:ellipse(37, 31, 1, 0.5)), "#8c4a1a", { flat = true })
c:part(c:rect(31, 30, 33, 33), "#8c4a1a", { flat = true })
c:fill(c:line({ {32, 27}, {32, 14} }, 1), "#2f5a2a")
local t = c:save(O .. "aseprite/ph/sorrel-seed.aseprite", O .. "png/ph/sorrel-seed.png")
print(GV.report(t))
