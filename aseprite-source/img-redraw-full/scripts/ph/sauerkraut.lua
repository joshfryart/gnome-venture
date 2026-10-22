local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow glass jar with a short neck under the lid
local jar = c:rrect(18, 24, 45, 55, 6)
jar:add(c:rect(21, 21, 42, 26))
local fill = c:rrect(21, 30, 42, 52, 4)
local lid = c:rrect(17, 12, 46, 23, 3)
local label = c:rect(23, 37, 40, 46)

local p = c:build{
  { "jar", jar, "#a9d6ea" },
  { "fill", fill, "#d9d98a", { light = jar, gloss = false } },
  { "label", label, "#f1ece0", { light = jar, gloss = false } },
  { "lid", lid, "gold" },
}
-- curly cabbage strands above and below the label
local S = "#a4b86a"
c:paint({ "ss..ss", "..ss..ss" }, 24, 32, { s = S })
c:paint({ ".ss...ss", "s..ss.." }, 31, 33, { s = S })
c:paint({ "ss..ss..s", "..ss..ss." }, 24, 48, { s = S })
c:paint({ ".ss.", "s..s" }, 36, 48, { s = S })
-- lid ridges
for _, y in ipairs({ 16, 19 }) do
  for x = 21, 42 do
    if not (x >= 30 and x <= 33 and y <= 17) then c:px(x, y, "#b8661a") end
  end
end
-- glass glint strip on the lit side
c:fill(c:rect(20, 30, 20, 44), "#c8ecdc")
c:seam({ {20, 24}, {44, 24} }, { free = true })
c:button(30, 13)

local t = c:save(O .. "aseprite/ph/sauerkraut.aseprite", O .. "png/ph/sauerkraut.png")
print(GV.report(t))
