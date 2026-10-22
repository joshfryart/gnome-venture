local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- heart-cone berry, point down
local berry = c:ellipse(23, 29, 10, 9)
berry:add(c:ellipse(40, 29, 10, 9))
berry:add(c:poly({ {13, 30}, {51, 30}, {44, 44}, {34, 57}, {30, 57}, {20, 44} }))
berry = berry:closed(3)

-- crown: five pointed leaves fanning from the top centre
local crown = c:poly({ {31, 22}, {14, 21}, {22, 26} })
crown:add(c:poly({ {30, 23}, {19, 13}, {27, 26} }))
crown:add(c:poly({ {29, 24}, {32, 10}, {35, 24} }))
crown:add(c:poly({ {34, 23}, {45, 13}, {37, 26} }))
crown:add(c:poly({ {33, 22}, {50, 21}, {42, 26} }))
crown:add(c:ellipse(32, 23, 6, 3))

local stem = c:line({ {32, 17}, {32, 13}, {33, 9}, {36, 6} }, 3)

local p = c:build{
  { "stem", stem, "moss", { flat = true } },
  { "berry", berry, GV.ramp("#d6322b"), { gloss = { 18, 30 } } },
  { "crown", crown, GV.ramp("#58a03e", { rim = "#7ab55c", shade = "#2f5a2a" }) },
}

-- seeds: staggered diamonds
local seeds = { {21, 32}, {31, 31}, {41, 32}, {26, 38}, {36, 38}, {22, 44}, {31, 45}, {40, 44}, {31, 51} }
for _, s in ipairs(seeds) do
  c:paint({ ".y", "yy", "r." }, s[1], s[2], { y = "#f5cf6a", r = "#ae2a2a" })
end

local t = c:save(D .. "img-redraw-full/aseprite/ph/strawberry.aseprite",
                 D .. "img-redraw-full/png/ph/strawberry.png")
print(GV.report(t))
