local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- leaves (behind root), angled outward
local leafL = c:poly({ {29,17}, {22,9}, {21,4}, {25,5}, {31,12}, {32,17} })
local leafR = c:poly({ {33,17}, {34,10}, {40,4}, {44,5}, {42,10}, {36,17} })
-- taproot: rounded shoulder tapering down behind crate
local root = c:ellipse(32.5, 18, 8.5, 4)
root:add(c:poly({ {24,18}, {42,18}, {35,40}, {31,40} }))

local body = c:rect(11, 31, 52, 55)
local postL = c:rect(11, 29, 16, 55)
local postR = c:rect(47, 29, 52, 55)
local rim = c:rect(9, 28, 54, 32)
local crate = body:copy(); crate:add(postL); crate:add(postR); crate:add(rim)

c:build{
  { "leafL", leafL, "#58a03e" },
  { "leafR", leafR, "#58a03e" },
  { "root",  root,  "petal" },
  { "body",  body,  "wood", { light = crate } },
  { "postL", postL, GV.ramp("#8a4f2a"), { light = crate, gloss = false } },
  { "postR", postR, GV.ramp("#8a4f2a"), { light = crate, gloss = false } },
  { "rim",   rim,   GV.ramp("#d9a660"), { light = crate } },
}
-- leaf veins
c:line({ {24,6}, {30,15} }, 1):each(function(x, y) c:px(x, y, "#3f7a2e") end)
c:line({ {42,6}, {35,15} }, 1):each(function(x, y) c:px(x, y, "#3f7a2e") end)
-- root marks
c:fill(c:rect(27, 21, 30, 22), "#a8241f")
c:fill(c:rect(33, 25, 36, 26), "#a8241f")
-- slat gaps
c:fill(c:rect(17, 39, 46, 40), "#5e2f1e")
c:fill(c:rect(17, 47, 46, 48), "#5e2f1e")
-- nails
for _, p in ipairs({ {13,35}, {13,50}, {49,35}, {49,50} }) do
  c:fill(c:rect(p[1], p[2], p[1]+1, p[2]+1), "#2a1a10")
end

local t = c:save(O .. "aseprite/ph/horseradish-seed.aseprite", O .. "png/ph/horseradish-seed.png")
print(GV.report(t))
