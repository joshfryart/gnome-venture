local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- blade: pointed top, widest mid-height, ruffled scallops along both edges
local blade = c:poly({ {32, 7}, {40, 16}, {46, 28}, {46, 38}, {40, 48}, {34, 53}, {30, 53}, {24, 48}, {18, 38}, {18, 28}, {24, 16} })
local bumps = { {22, 19, 3}, {18, 27, 3.5}, {16, 35, 3.5}, {19, 43, 3}, {24, 49, 2.5},
                {42, 19, 3}, {46, 27, 3.5}, {48, 35, 3.5}, {45, 43, 3}, {40, 49, 2.5} }
for _, b in ipairs(bumps) do blade:add(c:ellipse(b[1], b[2], b[3])) end
-- notches between scallops
local notches = { {19, 23}, {15, 31}, {15, 39}, {20, 47}, {45, 23}, {49, 31}, {49, 39}, {44, 47} }
for _, n in ipairs(notches) do blade:cut(c:ellipse(n[1], n[2], 1.5)) end

local stem = c:rect(30, 50, 33, 57)
c:build{
  { "stem", stem, GV.ramp("#a4b86a") },
  { "blade", blade, "moss", { gloss = { 23, 22 } } },
}
-- veins (dark) then rib (pale) on top
local veins = c:line({ {32, 32}, {23, 26} }, 2)
veins:add(c:line({ {32, 24}, {40, 18} }, 2))
veins:add(c:line({ {32, 40}, {24, 36} }, 2))
veins:add(c:line({ {32, 34}, {41, 29} }, 2))
c:fill(veins, "#2f5a2a")
c:fill(c:line({ {33, 14}, {33, 52} }, 1), "#2f5a2a")
c:fill(c:line({ {31, 14}, {31, 52} }, 2), "#c8d77a")
local t = c:save(O .. "aseprite/ph/kale.aseprite", O .. "png/ph/kale.png")
print(GV.report(t))
