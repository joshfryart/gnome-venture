local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#c9a96e")
local potato = c:ellipse(32, 34, 13, 18)
potato:add(c:ellipse(24, 22, 6, 6)); potato:add(c:ellipse(41, 45, 5, 6))
local cloth = c:rrect(13, 28, 51, 42, 4)
local leafL = c:poly({ {26, 11}, {29, 10}, {31, 13}, {31, 17}, {28, 16} })
local leafR = c:poly({ {37, 10}, {40, 11}, {39, 15}, {34, 18}, {34, 14} })
local p = c:build{
  { "leafL", leafL, "moss", { flat = true } },
  { "leafR", leafR, "moss", { flat = true } },
  { "potato", potato, tan },
  { "cloth", cloth, "cream", { stitch = true } },
}
local soil = "#7a4a1f"
local belt = c:rect(13, 32, 51, 33); belt:add(c:rect(13, 37, 51, 38)); belt:clip(cloth)
c:fill(belt, soil)
c:fill(c:line({ {30, 39}, {28, 44}, {26, 50} }, 2), soil)
c:fill(c:line({ {34, 39}, {36, 44}, {38, 50} }, 2), soil)
c:paint({ ".kk.", "kkkk", "kkkk", ".kk." }, 30, 34, { k = "#5e2f1e" })
c:px(31, 35, "#9a6b3f")
-- potato eyes
for _, e in ipairs({ {25, 21}, {35, 19}, {41, 24}, {30, 48} }) do
  c:paint({ "ee", "ee" }, e[1], e[2], { e = soil })
end
c:seam({ {16, 40}, {48, 40} })
local t = c:save(O .. "aseprite/ph/potato-seed.aseprite", O .. "png/ph/potato-seed.png")
print(GV.report(t))
