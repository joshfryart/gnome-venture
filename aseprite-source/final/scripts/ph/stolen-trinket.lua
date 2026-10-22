local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- drooping chain U
local chainPts = { {12, 8}, {16, 14}, {21, 19}, {26, 22}, {32, 23}, {38, 22}, {43, 19}, {48, 14}, {52, 8} }
local chain = c:line(chainPts, 3)

-- teardrop, point down
local drop = c:ellipse(31.5, 41, 12, 11)
drop:add(c:poly({ {20, 44}, {44, 44}, {33, 57}, {31, 57} }))
drop = drop:closed(2)

local bale = c:rrect(29, 23, 34, 28, 1)
local tag = c:poly({ {44, 38}, {52, 41}, {49, 49}, {41, 46} })

local p = c:build{
  { "chain", chain, "gold", { flat = true } },
  { "drop", drop, GV.ramp("#3f93b2"), { gloss = { 24, 34 } } },
  { "bale", bale, "gold", { flat = true } },
  { "tag", tag, "cream", { flat = true } },
}
-- chain links
for i, pt in ipairs({ {15, 12}, {19, 17}, {24, 21}, {29, 23}, {35, 23}, {40, 21}, {45, 17}, {49, 12} }) do
  c:px(pt[1], pt[2], "#b8661a")
  c:px(pt[1], pt[2] + 1, "#b8661a")
end
c:px(31, 25, "#8a4a1c"); c:px(32, 25, "#8a4a1c")

-- inner facets
local fc = "#256a80"
for y = 33, 53 do c:px(31, y, fc) end
c:paint({
  "..f.....f..",
  ".f.......f.",
  "f.........f",
  ".f.......f.",
  "..f.....f..",
  "...f...f...",
  "....f.f....",
}, 26, 40, { f = fc })

-- tag thread to the clasp
c:seam({ {35, 27}, {39, 31}, {43, 38} }, { free = true, on = 1, off = 1 })
-- scribble on the tag
c:paint({ "ss.s", ".ss.", "s.ss" }, 45, 42, { s = "#7a4a1f" })

local t = c:save(D .. "img-redraw-full/aseprite/ph/stolen-trinket.aseprite",
                 D .. "img-redraw-full/png/ph/stolen-trinket.png")
print(GV.report(t))
