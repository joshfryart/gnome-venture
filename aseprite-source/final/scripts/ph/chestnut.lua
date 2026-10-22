local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- nut: onion/teardrop shape with a point at the top
local nut = c:ellipse(32, 31, 14, 13)
nut:add(c:poly({ {24, 22}, {40, 22}, {34, 13}, {30, 13} }))
local tuft = c:rrect(30, 10, 33, 14, 1)

-- husk bowl with zigzag spine crown
local husk = c:ellipse(32, 44, 20, 10):cut(c:rect(0, 0, 63, 39))
husk:add(c:rect(13, 40, 51, 44))
local crown = c:mask()
for x = 13, 46, 5 do
  crown:add(c:poly({ {x, 42}, {x + 5, 42}, {x + 3, 33}, {x + 2, 33} }))
end
husk:add(crown)
husk:add(c:poly({ {11, 44}, {15, 41}, {7, 36}, {6, 36} }))
husk:add(c:poly({ {49, 41}, {53, 44}, {58, 36}, {57, 36} }))
husk:add(c:poly({ {12, 49}, {15, 47}, {8, 46} }))
husk:add(c:poly({ {49, 47}, {52, 49}, {56, 46} }))

local p = c:build{
  { "tuft", tuft, "#5e2f1e", { flat = true } },
  { "nut", nut, "wood", { gloss = { 23, 22 } } },
  { "husk", husk, "moss", { gloss = { 18, 44 } } },
}
-- scar patch peeking above husk (pale tan)
local scar = c:ellipse(32, 38, 8, 3):clip(nut):cut(husk)
c:fill(scar, "#d9a660")
-- grain line
for _, q in ipairs({ {27, 18}, {26, 19}, {26, 20}, {25, 21}, {25, 22}, {24, 23}, {24, 24}, {24, 25}, {24, 26} }) do
  c:px(q[1], q[2], "#5e2f1e")
end
for _, q in ipairs({ {38, 19}, {39, 21}, {40, 23}, {40, 25} }) do c:px(q[1], q[2], "#5e2f1e") end
-- spine shading: dark tick on each spine tip's right side + bumps on husk
for x = 13, 46, 5 do c:px(x + 3, 38, "#4a8a3e"); c:px(x + 4, 40, "#4a8a3e") end
for _, q in ipairs({ {20, 47}, {28, 49}, {36, 49}, {44, 47}, {24, 51}, {40, 51} }) do
  c:paint({ ".s.", "sss" }, q[1], q[2], { s = "#4a8a3e" })
end

c:ground(32, 56, 17, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/chestnut.aseprite", D .. "img-redraw-full/png/ph/chestnut.png")
print(GV.report(t))
