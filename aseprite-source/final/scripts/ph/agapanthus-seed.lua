local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local p = c:build{
  { "seed",  c:ellipse(32, 27, 9, 8.5), GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "body",  c:rect(16, 33, 48, 52), GV.ramp("#d9a660") },
  { "rim",   c:rrect(14, 30, 50, 35, 1), "wood" },
  { "label", c:rrect(25, 38, 39, 47, 1), GV.ramp("#f4f0e0"), { flat = true } },
  { "stem",  c:rect(31, 14, 33, 19), GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  c:poly({ {33, 15}, {36, 11}, {41, 10}, {44, 11}, {40, 15}, {36, 16} }), GV.ramp("#58a03e"), { flat = true } },
}
-- plank lines (around the label)
for x = 17, 47 do
  if x < 25 or x > 39 then c:px(x, 42, "#8a4f2a") end
  c:px(x, 49, "#8a4f2a")
end
-- label dots
for _, x in ipairs({ 28, 31, 34 }) do
  c:fill(c:rect(x, 42, x + 1, 43), "#8a4f2a")
end
-- seed ridge
c:seam({ {32, 21}, {32, 29} }, { on = 1, off = 1 })
c:seam({ {18, 32}, {46, 32} })
c:fill(c:rect(16, 32, 17, 33), GV.C.gold)
c:fill(c:rect(47, 32, 48, 33), GV.C.gold)

local t = c:save(O .. "aseprite/ph/agapanthus-seed.aseprite", O .. "png/ph/agapanthus-seed.png")
print(GV.report(t))
