local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pk = GV.ramp("#e46a9b")
local body = c:poly({ {32,9}, {51,24}, {32,56}, {13,24} })
local p = c:build{
  { "gem", body, pk, { gloss = false } },
}
-- crown facets
local ul = c:poly({ {32,10}, {14,24}, {24,24} })
c:fill(ul, "#f6b8cf")
local crownMid = c:poly({ {32,10}, {24,24}, {40,24} })
c:fill(crownMid, pk.base)
-- pavilion centre facet
c:fill(c:poly({ {24,25}, {41,25}, {32,55} }), pk.shade)
-- pavilion left facet lighter
c:fill(c:poly({ {13,25}, {24,25}, {31,53} }):clip(body), pk.base)
-- right pavilion facet deep-ish
c:fill(c:poly({ {41,25}, {52,25}, {33,53} }):clip(body), pk.deep)
-- right crown facet shade
c:fill(c:poly({ {32,10}, {40,24}, {52,24} }):clip(body), pk.shade)
local E = "#6b1b2c"
c:fill(c:line({ {13,24}, {51,24} }, 2):clip(body), E)
c:fill(c:line({ {32,10}, {24,24} }, 2):clip(body), E)
c:fill(c:line({ {32,10}, {40,24} }, 2):clip(body), E)
c:fill(c:line({ {24,25}, {32,54} }, 2):clip(body), E)
c:fill(c:line({ {40,25}, {32,54} }, 2):clip(body), E)
-- gloss comma on lit facet
c:paint({ ".gg", "gg.", "g.." }, 22, 16, { g = "#fff3c8" })
c:px(26, 15, "#ffffff")
c:px(20, 21, "#fff3c8")
local t = c:save(O .. "aseprite/ph/desert-gem.aseprite", O .. "png/ph/desert-gem.png")
print(GV.report(t))
