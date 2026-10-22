local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local env = c:poly({ {17, 9}, {47, 9}, {50, 15}, {50, 56}, {14, 56}, {14, 15} })
local frame = c:rrect(19, 27, 45, 50, 5)
local win = c:rrect(21, 29, 43, 48, 4)
local leaf = c:poly({ {33, 30}, {37, 27}, {41, 27}, {38, 31}, {34, 32} })

c:build{
  { "env",   env, GV.ramp("#f1ece0"), { pale = true } },
  { "frame", frame:copy():cut(win), "gold", { flat = true, contour = false } },
  { "win",   win, GV.ramp("#f4f0e0"), { flat = true, gloss = false } },
  { "stem",  c:rect(31, 29, 32, 33), "#2e5a2c", { flat = true } },
  { "leaf",  leaf, "#58a03e", { flat = true } },
  { "hip",   c:ellipse(32, 40, 7), GV.ramp("#e8a317", { shade = "#b07a10" }) },
}
-- flap: V fold line from the top corners down to the tip
c:fill(c:line({ {15, 16}, {32, 25}, {49, 16} }, 2), "#dcb06a")
c:seam({ {16, 15}, {32, 23}, {48, 15} }, { free = true })
c:button(30, 22)
-- seeds
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 2, 54), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/bayahibe-rose-seed.aseprite", O .. "png/ph/bayahibe-rose-seed.png")
print(GV.report(t))
