local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arching spine: thick in the middle, thin at ends
local spine = c:line({ {12, 42}, {18, 37}, {26, 32}, {36, 27}, {46, 23}, {53, 20} }, 4)
spine:add(c:line({ {20, 36}, {30, 30}, {42, 25} }, 6))
local stalk = c:line({ {13, 42}, {9, 46}, {7, 49} }, 3)

local body = GV.ramp("#a5663a")
local bead = GV.ramp("#8c4a1a")
local p = c:build{
  { "stalk", stalk, GV.ramp("#2e5a2c"), { flat = true } },
  { "spine", spine, body },
  { "beadA", c:ellipse(23, 34, 6.5, 6), bead, { gloss = { 20, 30 } } },
  { "beadB", c:ellipse(33, 29, 6.5, 6), bead, { gloss = { 30, 25 } } },
  { "beadC", c:ellipse(43, 24, 6.5, 6), bead, { gloss = { 40, 20 } } },
}
-- seed ridges (cumin seeds are ribbed)
for _, b in ipairs({ { 23, 34 }, { 33, 29 }, { 43, 24 } }) do
  c:px(b[1] + 1, b[2] + 1, "#5e2f1e"); c:px(b[1] + 2, b[2] + 2, "#5e2f1e")
end
-- spine tip lit bead
c:px(52, 20, body.rim)
local t = c:save(O .. "aseprite/ph/cumin.aseprite", O .. "png/ph/cumin.png")
print(GV.report(t))
