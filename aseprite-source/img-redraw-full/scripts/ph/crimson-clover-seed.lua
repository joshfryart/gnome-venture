-- ph/crimson-clover-seed : string-tied cloth bundle
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#c9a96e")
local crim = GV.ramp("#d6322b")

local belly = c:ellipse(32, 41, 18, 14):add(c:poly({ {25,26}, {39,26}, {44,34}, {20,34} }))
local top = c:poly({ {26,25}, {38,25}, {45,15}, {19,15} })
-- scalloped top edge
for _, x in ipairs({ 22, 28, 34, 40 }) do top:add(c:ellipse(x + 0.5, 15, 3, 2)) end
top:cut(c:rect(0, 0, 63, 12))

c:build{
  { "sprout", c:rect(31, 8, 32, 14), GV.ramp("#2f5a2a", { base = "#4a8a3e" }), { flat = true } },
  { "leaf",   c:ellipse(36, 9, 3, 2), GV.ramp("#58a03e"), { gloss = false } },
  { "top",    top, cloth, { gloss = false } },
  { "belly",  belly, cloth, { stitch = true } },
  { "seeds",  c:ellipse(32, 43, 9, 7), GV.ramp("#8c4a1a"), { stitch = false } },
  { "string", c:rect(22, 25, 42, 27), crim, { gloss = false } },
  { "loopL",  c:poly({ {30,26}, {16,20}, {15,31}, {30,27} }):cut(c:poly({ {25,25}, {19,23}, {19,28}, {25,26} })), crim, { flat = true } },
  { "loopR",  c:poly({ {34,26}, {48,20}, {49,31}, {34,27} }):cut(c:poly({ {39,25}, {45,23}, {45,28}, {39,26} })), crim, { flat = true } },
  { "tailL",  c:line({ {30,28}, {27,34} }, 2), crim, { flat = true } },
  { "tailR",  c:line({ {34,28}, {37,34} }, 2), crim, { flat = true } },
  { "knot",   c:rrect(30, 24, 34, 28, 1), crim, { gloss = false } },
}
-- seeds peeking through: little beans
for _, p in ipairs({ {28,40}, {34,39}, {31,45}, {37,44}, {26,45} }) do
  c:paint({ "ab", "bb" }, p[1], p[2], { a = "#c97a3a", b = "#5e2f1e" })
end
-- fold lines in the cloth
for _, p in ipairs({ {20,38}, {21,41}, {21,44}, {44,40}, {43,43}, {43,46} }) do c:px(p[1], p[2], "#8a4f2a") end
for _, p in ipairs({ {25,19}, {26,22}, {38,19}, {37,22} }) do c:px(p[1], p[2], "#8a4f2a") end
c:seam({ {24, 33}, {22, 37} })
c:ground(32, 57, 16, 2)

local t = c:save(O .. "aseprite/ph/crimson-clover-seed.aseprite", O .. "png/ph/crimson-clover-seed.png")
print(GV.report(t))
