local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local seed = c:ellipse(32, 23, 9, 9)
local sprout = c:rect(31, 7, 33, 15)
local leaf = c:poly({ {34, 11}, {37, 7}, {42, 6}, {41, 9}, {36, 12} })
local crate = c:rrect(14, 30, 50, 54, 2)
local p = c:build{
  { "stem",  sprout, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "seed",  seed, GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "crate", crate, "wood", { gloss = { 20, 38 } } },
  { "rim",   c:rrect(12, 26, 52, 31, 1), GV.ramp("#d9a660") },
  { "postL", c:rect(14, 31, 17, 54), GV.ramp("#a8582f"), { gloss = false } },
  { "postR", c:rect(47, 31, 50, 54), GV.ramp("#a8582f"), { gloss = false } },
}
c:fill(c:rect(18, 38, 46, 39), "#8a4f2a")
c:fill(c:rect(18, 46, 46, 47), "#8a4f2a")
for _, y in ipairs({ 34, 49 }) do
  c:fill(c:rect(15, y, 16, y + 1), "#5e2f1e")
  c:fill(c:rect(48, y, 49, y + 1), "#5e2f1e")
end
c:ground(32, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/night-jasmine-seed.aseprite", O .. "png/ph/night-jasmine-seed.png")
print(GV.report(t))
