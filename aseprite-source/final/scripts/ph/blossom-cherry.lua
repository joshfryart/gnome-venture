local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pink  = GV.ramp("#e46a9b")
local light = GV.ramp("#f6b8cf")

-- forked trunk
local trunk = c:rrect(28, 34, 36, 51, 2)
trunk:add(c:line({ {30, 36}, {25, 30}, {22, 27} }, 3))
trunk:add(c:line({ {34, 36}, {39, 30}, {42, 27} }, 3))
-- scalloped canopy: ring of lobes around a core
local canopy = c:ellipse(32, 27, 17, 13)
local lobes = { {16, 27, 7}, {19, 18, 7}, {28, 13, 6.5}, {38, 13, 6.5}, {46, 19, 7}, {48, 28, 7},
                {43, 36, 6}, {32, 38, 5}, {21, 36, 6} }
for _, l in ipairs(lobes) do canopy:add(c:ellipse(l[1], l[2], l[3], l[3] - 0.5)) end
local grass = c:ellipse(32, 52, 10, 2.5):add(c:poly({ {24, 52}, {26, 47}, {28, 52} }))
grass:add(c:poly({ {36, 52}, {38, 47}, {40, 52} }))

local p = c:build{
  { "grass",  grass,  "moss", { gloss = false } },
  { "trunk",  trunk,  "wood" },
  { "canopy", canopy, pink },
}
-- lighter petal clusters, flat so the canopy keeps one crescent
for _, l in ipairs({ {21, 28, 6}, {40, 20, 6}, {29, 17, 5} }) do
  c:part(c:ellipse(l[1], l[2], l[3], l[3] - 1), light, { flat = true, contour = false, contact = false })
end
-- tiny blossom dots
for _, d in ipairs({ {35, 31}, {44, 29}, {26, 36}, {17, 22}, {38, 36} }) do
  c:paint({ ".l.", "lcl", ".l." }, d[1] - 1, d[2] - 1, { l = "#f6b8cf", c = "#fff3c8" })
end
-- drifting petals
for _, d in ipairs({ {8, 46}, {53, 41}, {49, 49} }) do
  c:part(c:rect(d[1], d[2], d[1] + 2, d[2] + 2), light, { flat = true })
end

local t = c:save(D .. "img-redraw-full/aseprite/ph/blossom-cherry.aseprite", D .. "img-redraw-full/png/ph/blossom-cherry.png")
print(GV.report(t))
