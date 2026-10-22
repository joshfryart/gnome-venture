local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local trunkR = GV.ramp("#dcb06a")
local branchR = GV.ramp("#8a4f2a")

-- branch stubs (behind the trunk)
local branches = c:line({ {30,24}, {15,13} }, 3)
branches:add(c:line({ {32,24}, {32,11} }, 3))
branches:add(c:line({ {34,24}, {49,13} }, 3))

-- leaf pairs at each tip
local leaves = c:mask()
local tips = { {15,13}, {32,11}, {49,13} }
for _, tp in ipairs(tips) do
  leaves:add(c:ellipse(tp[1] - 3, tp[2] - 2, 2.5, 2))
  leaves:add(c:ellipse(tp[1] + 3, tp[2] - 2, 2.5, 2))
end

-- root lumps (behind trunk)
local roots = c:ellipse(15, 53, 5, 3):add(c:ellipse(49, 53, 5, 3))

-- bottle trunk: narrow neck, swollen belly
local trunk = c:rrect(24, 20, 40, 36, 3)
trunk:add(c:ellipse(32, 43, 18, 11))
trunk:add(c:poly({ {24,30}, {40,30}, {46,36}, {18,36} }))

local p = c:build{
  { "branches", branches, branchR, { flat = true } },
  { "leaves", leaves, "moss", { gloss = false } },
  { "roots", roots, branchR },
  { "trunk", trunk, trunkR, { gloss = { 21, 36 } } },
}
-- bark grooves
c:fill(c:line({ {27,33}, {26,40}, {27,48} }, 1), "#5e2f1e")
c:fill(c:line({ {37,33}, {38,40}, {37,48} }, 1), "#5e2f1e")
c:fill(c:line({ {32,24}, {32,30} }, 1), "#8a4f2a")

c:ground(31.5, 56, 18, 1.5)
local t = c:save(O .. "aseprite/ph/baobab.aseprite", O .. "png/ph/baobab.png")
print(GV.report(t))
