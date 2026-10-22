local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(15, 13, 49, 57, 2)
local tab = c:poly({ {44, 7}, {50, 17}, {39, 17} })
local flap = c:poly({ {15, 13}, {50, 13}, {32.5, 29} })
local win = c:rrect(20, 31, 44, 53, 5)
local fruit = c:ellipse(32, 42, 7.5, 8)
local leaf = c:ellipse(36.5, 32.5, 3, 1.5)

local p = c:build{
  { "tab", tab, GV.ramp("#2e5a2c") },
  { "body", body, "cream" },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false } },
  { "fruit", fruit, GV.ramp("#b0bc66", { shade = "#58a03e" }) },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
}
-- window rim
c:fill(win:copy():cut(win:shrink(1)), "#8ea04e")
-- stem
c:fill(c:rect(31, 31, 32, 34), "#2e5a2c")
-- salak scale diamonds
for _, d in ipairs({ {29, 44}, {35, 41}, {32, 48}, {36, 46} }) do
  c:paint({ ".s.", "sss", ".s." }, d[1] - 1, d[2] - 1, { s = "#58a03e" })
end
-- seams along flap edges
c:seam({ {17, 15}, {32, 27} })
c:seam({ {48, 15}, {33, 27} })
c:button(31, 25)
-- dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 54, x + 1, 55), "#8c4a1a") end

local t = c:save(O .. "aseprite/ph/salak-seed.aseprite", O .. "png/ph/salak-seed.png")
print(GV.report(t))
