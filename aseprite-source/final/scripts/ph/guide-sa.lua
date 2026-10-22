-- ph/guide-sa: rainforest field guide (REDO, unique): open book, toucan perched, leaf from spine
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- cover (amber, gold family) peeking around the pages
local cover = c:poly({ {12,34}, {31,38}, {33,38}, {53,34}, {53,52}, {33,55}, {31,55}, {12,52} })
-- two curved pages
local pageL = c:poly({ {14,31}, {18,29}, {24,29}, {29,31}, {32,35}, {32,52}, {27,49}, {20,48}, {14,50} })
local pageR = c:poly({ {32,35}, {35,31}, {40,29}, {46,29}, {50,31}, {50,50}, {44,48}, {37,49}, {32,52} })
-- leaf sprouting from the spine, rising up-left
local leaf = c:poly({ {31,36}, {29,30}, {26,24}, {21,18}, {15,13}, {13,19}, {15,25}, {20,30}, {26,34} })
-- toucan (facing left), perched on the right page's top edge
local tail = c:poly({ {46,27}, {50,27}, {52,38}, {48,38} })
local body = c:ellipse(45, 23.5, 4.5, 6.5)
body:add(c:ellipse(44, 15, 5, 4.5))
local bib = c:ellipse(41.5, 20.5, 2.5, 3)
local beak = c:poly({ {41,10}, {35,9}, {29,10}, {25,13}, {22,18}, {28,18}, {35,19}, {41,20} })

local amber = GV.ramp("#b07a10")
local black = GV.ramp("#3a3346")
local beakR = GV.ramp("#f7b520")
c:build{
  { "cover", cover, amber },
  { "pageL", pageL, "cream", { gloss = { 18, 33 } } },
  { "pageR", pageR, "cream", { gloss = { 37, 33 } } },
  { "leaf", leaf, "moss", { gloss = { 16, 17 } } },
  { "tail", tail, black, { gloss = false } },
  { "body", body, black, { gloss = { 41, 13 } } },
  { "bib", bib, "cream", { gloss = false, flat = true } },
  { "beak", beak, beakR, { gloss = { 32, 12 } } },
}

-- page lines (not text), following the page curve
local ln = GV.R.cream.shade
c:line({ {17,35}, {22,34}, {28,36} }, 1):cut(leaf):each(function(x, y) c:px(x, y, ln) end)
c:line({ {17,39}, {22,38}, {28,40} }, 1):cut(leaf):each(function(x, y) c:px(x, y, ln) end)
c:line({ {17,43}, {22,42}, {27,44} }, 1):each(function(x, y) c:px(x, y, ln) end)
c:line({ {36,35}, {41,34}, {47,35} }, 1):cut(tail):each(function(x, y) c:px(x, y, ln) end)
c:line({ {36,39}, {41,38}, {46,39} }, 1):cut(tail):each(function(x, y) c:px(x, y, ln) end)
c:line({ {37,43}, {42,42}, {47,43} }, 1):cut(tail):each(function(x, y) c:px(x, y, ln) end)

-- leaf midrib
c:line({ {30,35}, {26,29}, {21,23}, {16,16} }, 1):each(function(x, y) c:px(x, y, GV.R.moss.shade) end)

-- thread-gold stitched binding: cross stitches over the gutter + hem seam on the cover
for _, y in ipairs({ 39, 42, 45, 48 }) do
  c:px(30, y, "#f5cf6a"); c:px(31, y, "#f5cf6a"); c:px(32, y, "#e8a317"); c:px(33, y, "#e8a317")
end
c:seam({ {13,51}, {31,54} }); c:seam({ {33,54}, {52,51} })

-- beak: dark cutting line + red-orange tip
c:line({ {40,16}, {34,16}, {27,17} }, 1):each(function(x, y) c:px(x, y, beakR.deep) end)
c:paint({ "rr", "rrr" }, 22, 16, { r = "#dd3a2a" })
c:px(24, 15, "#dd3a2a")

-- feet gripping the page edge
c:paint({ "l.l", "lll" }, 43, 29, { l = "#54447f" })

-- locked eye
c:eye(42, 11)

local t = c:save(O .. "aseprite/ph/guide-sa.aseprite", O .. "png/ph/guide-sa.png")
print(GV.report(t))
