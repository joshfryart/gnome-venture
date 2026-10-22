local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- smoke puffs (back)
c:part(c:ellipse(50, 10, 3.5, 3):add(c:ellipse(46.5, 14, 2, 2)), GV.ramp("#d6c9b6"))
-- chimney
c:part(c:rect(40, 16, 47, 30), GV.ramp("#968f96"))
c:part(c:rrect(39, 14, 48, 17, 1), GV.ramp("#6a6070"), { flat = true })
-- flag
c:part(c:rect(31, 7, 32, 19), GV.ramp("#44281c"), { flat = true })
c:part(c:poly({ {33, 7}, {41, 10}, {33, 14} }), "red", { flat = true })
-- wall
local wall = c:rrect(11, 33, 53, 56, 2)
c:part(wall, GV.ramp("#dcb06a"))
c:fill(c:rect(13, 44, 51, 44), "#8a5a34")
c:fill(c:rect(13, 50, 51, 50), "#8a5a34")
-- roof + eave
c:part(c:poly({ {7, 36}, {32, 17}, {58, 36} }), "red")
c:part(c:rrect(8, 34, 57, 38, 2), GV.ramp("#c66b50"))
c:fill(c:rect(10, 34, 55, 34), "#f0d49a")
-- door (arch)
c:part(c:ellipse(21.5, 45.5, 4.5, 4):add(c:rect(17, 46, 26, 56)), GV.ramp("#44281c"))
c:px(24, 51, "#e8a317"); c:px(24, 52, "#b8661a")
-- window + cross
c:part(c:rrect(34, 40, 45, 49, 1), GV.ramp("#f5cf6a"))
c:fill(c:rect(39, 41, 40, 48), "#2a1a10")
c:fill(c:rect(35, 44, 44, 45), "#2a1a10")
-- flowerbox + blooms
c:part(c:rrect(33, 49, 46, 53, 1), GV.ramp("#b6814d"))
c:paint({ ".a.", "aaa", ".a." }, 34, 47, { a = "#e46a9b" })
c:paint({ ".a.", "aaa", ".a." }, 38, 47, { a = "#e8a317" })
c:paint({ ".a.", "aaa", ".a." }, 42, 47, { a = "#f6b8cf" })
-- lantern hanging from the eave
c:fill(c:rect(10, 39, 10, 40), "#44281c")
c:part(c:rrect(8, 41, 12, 47, 1), "gold")
c:fill(c:rect(9, 43, 11, 45), "#fff1c8")
-- seams
c:seam({ {9, 36}, {56, 36} })
c:seam({ {12, 55}, {52, 55} })
-- sparkle
c:paint({ ".s.", "sss", ".s." }, 52, 22, { s = "#f5cf6a" })
c:ground(32, 57, 25, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/kitchen-3.aseprite", O .. "png/ph/kitchen-3.png")
print(GV.report(t))
