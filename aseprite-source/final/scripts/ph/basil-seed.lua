local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat pear sack: narrow shoulders up top, fat belly low
local body = c:ellipse(32, 41, 19, 15)
body:add(c:poly({ {23, 21}, {41, 21}, {47, 32}, {17, 32} }))
body:cut(c:rect(0, 56, 63, 63))
body:add(c:rrect(17, 48, 47, 56, 6))

-- flared ruffled mouth: three gathered lobes
local mouth = c:poly({ {26, 21}, {38, 21}, {44, 12}, {20, 12} })
mouth:add(c:ellipse(21.5, 13, 3.5, 3))
mouth:add(c:ellipse(32, 11, 4, 3))
mouth:add(c:ellipse(42.5, 13, 3.5, 3))

local twine = c:rrect(23, 19, 41, 22, 1)

local label = c:rrect(22, 29, 42, 50, 5)

local leaf = c:poly({ {32, 31}, {38, 36}, {39, 42}, {36, 47}, {32, 49}, {28, 47}, {25, 42}, {26, 36} })

local p = c:build{
  { "mouth", mouth, "#c9a96e" },
  { "body",  body,  "#c9a96e", { stitch = { side = "lit" } } },
  { "twine", twine, "#7a4a1f", { gloss = false } },
  { "label", label, "#f4f0e0", { gloss = false } },
  { "leaf",  leaf,  "#58a03e" },
}

-- burlap weave flecks on the lit belly
c:paint({ "w.w", ".w." }, 18, 38, { w = "#b5915a" })
c:paint({ "w.w" }, 44, 30, { w = "#b5915a" })

-- label border
c:fill(label:edge(), "#7a5cc0")

-- leaf midrib + veins

local vein = "#2e5a2c"
for y = 33, 48 do c:px(32, y, vein) end
c:paint({ "v....v", ".v..v." }, 29, 37, { v = vein })
c:paint({ "v....v", ".v..v." }, 29, 42, { v = vein })

-- seeds under the leaf
for _, x in ipairs({ 26, 31, 36 }) do
  c:paint({ ".s.", "sss", ".s." }, x, 51, { s = "#8c4a1a" })
end

-- twine knot and tails
c:paint({ "kkk", "kkk" }, 31, 20, { k = "#5a3415" })
c:paint({ "t.", "tt", ".t" }, 29, 23, { t = "#7a4a1f" })
c:paint({ ".t", "tt", "t." }, 34, 23, { t = "#7a4a1f" })

-- seam down the left side
c:seam({ {18, 29}, {16, 36}, {15, 44}, {17, 50} })

c:ground(32, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/basil-seed.aseprite", O .. "png/ph/basil-seed.png")
print(GV.report(t))
