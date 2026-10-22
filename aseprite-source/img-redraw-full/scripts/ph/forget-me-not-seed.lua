local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local box = c:rect(12, 18, 52, 52)
local p = c:build{
  { "back",  c:rect(14, 20, 50, 52), "#8a4f2a", { light = box } },
  { "slat1", c:rect(12, 20, 52, 28), "wood", { light = box } },
  { "slat2", c:rect(12, 31, 52, 39), "wood", { light = box } },
  { "slat3", c:rect(12, 42, 52, 50), "wood", { light = box } },
  { "brace", c:line({ {19, 47}, {45, 25} }, 3):clip(c:rect(17, 20, 47, 50)), "#a8582f", { flat = true } },
  { "postL", c:rect(12, 18, 16, 52), "#d9a660", { light = box, gloss = false } },
  { "postR", c:rect(48, 18, 52, 52), "#d9a660", { light = box, gloss = false } },
  { "seed",  c:ellipse(32, 36, 7, 7), GV.ramp("#b0bc66", { shade = "#58a03e" }) },
  { "stem",  c:rect(31, 26, 32, 29), "#2e5a2c", { flat = true } },
  { "leaf",  c:ellipse(36.5, 26, 3, 1.5), "#58a03e", { flat = true } },
}
-- nails
for _, n in ipairs({ {13, 21}, {49, 21}, {13, 47}, {49, 47} }) do
  c:paint({ "gg", "gG" }, n[1], n[2], { g = "#f5cf6a", G = "#e8a317" })
end
c:ground(32, 55, 17, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/forget-me-not-seed.aseprite", O .. "png/ph/forget-me-not-seed.png")
print(GV.report(t))
