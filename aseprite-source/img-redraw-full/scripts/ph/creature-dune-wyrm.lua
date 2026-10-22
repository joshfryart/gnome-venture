local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tan = GV.ramp("#dcb06a")         -- wood family
local sunO = GV.ramp("#f0bf56")
local sunI = "#f8db8c"

-- sun disc behind (flat bands)
local sun = c:ellipse(38, 26, 12, 12)

-- coil ring body
local coil = c:ellipse(31.5, 46, 19.5, 8):cut(c:ellipse(32, 45.5, 9, 2.5))
-- neck rising from the left of the coil
local neck = c:line({ {16, 46}, {16, 40}, {18, 34}, {20, 29} }, 7)
-- head + snout
local head = c:ellipse(20, 23, 7.5, 7):add(c:poly({ {24, 20}, {33, 24}, {33, 29}, {22, 30} }))
-- tail rising on the right with a spade tip
local tail = c:line({ {47, 45}, {49, 40}, {50, 35} }, 4)
local spade = c:poly({ {43, 31}, {50, 22}, {57, 31}, {50, 36} })
tail:add(spade)
-- crown on top of head
local crown = c:poly({ {13, 18}, {13, 10}, {16, 14}, {19, 8}, {22, 14}, {25, 10}, {26, 18} })
local band = c:rect(13, 15, 26, 18)

local p = c:build{
  { "sun",   sun,   sunO, { flat = true, contour = false } },
  { "tail",  tail,  tan },
  { "coil",  coil,  tan, { stitch = { side = "lit" } } },
  { "neck",  neck,  tan, { light = neck:copy():add(head) } },
  { "head",  head,  tan },
  { "crown", crown, "gold", { cres = 2, deep = 1 } },
  { "band",  band,  GV.ramp("#b07a10"), { flat = true } },
}
-- inner sun band (only on exposed sun pixels)
c:ellipse(38, 26, 7.5, 7.5):each(function(x, y)
  if c:get(x, y) == sunO.base then c:px(x, y, sunI) end
end)

-- pale top stripe on the coil back
c:line({ {18, 40}, {24, 39}, {32, 38.5}, {40, 39}, {45, 40} }, 2):clip(p.coil.m):each(function(x, y)
  if c:get(x, y) == tan.base then c:px(x, y, "#f8eed2") end
end)

-- six diamond scale marks around the coil
local function dia(x, y)
  return c:ascii({ ".x.", "xxx", ".x." }, x - 1, y - 1)
end
for _, d in ipairs({ {19, 50}, {27, 52}, {36, 52}, {44, 49}, {39, 42}, {26, 42} }) do
  c:spot(dia(d[1], d[2]), "#a5663a")
end
-- seam along the coil centre
c:seam({ {14, 46}, {18, 49}, {25, 51}, {32, 51.5} })
c:seam({ {33, 51.5}, {40, 51}, {46, 49}, {50, 46} })

-- crown jewel + button
c:paint({ ".r.", "rrr", ".r." }, 18, 11, { r = "#d6322b" })
c:px(18, 12, "#ff9158")

-- face: small eyes on the ~15 px head
c:eye(16, 21, true); c:eye(23, 21, true)
c:px(28, 27, GV.C.ol2); c:px(29, 27, GV.C.ol2)
-- forked tongue
c:paint({ "rr...", "..rr.", "...rr", "....r" }, 32, 27, { r = "#d6322b" })
c:px(36, 31, "#d6322b")

c:ground(31.5, 54.5, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-dune-wyrm.aseprite", O .. "png/ph/creature-dune-wyrm.png")
print(GV.report(t))
