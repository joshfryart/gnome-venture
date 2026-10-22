local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pelt body: rect with wavy top and notched sides
local body = c:rect(10, 17, 56, 51)
body:add(c:ellipse(18, 17, 7, 3)); body:add(c:ellipse(32, 16, 8, 3)); body:add(c:ellipse(47.5, 17, 7, 3))
body:cut(c:poly({ {9, 22}, {15, 26}, {9, 30} })); body:cut(c:poly({ {9, 31}, {15, 35}, {9, 39} }))
body:cut(c:poly({ {58, 22}, {52, 26}, {58, 30} })); body:cut(c:poly({ {58, 31}, {52, 35}, {58, 39} }))

-- jagged fringe hem
local fr = c:rect(12, 48, 54, 52)
for i = 0, 6 do
  local x = 12 + i * 6
  fr:add(c:poly({ {x, 52}, {x + 6, 52}, {x + 3, 57} }))
end

local p = c:build{
  { "fringe", fr, "#6a9a3a" },
  { "body", body, "moss", { stitch = true } },
  { "patch", c:ellipse(20, 21, 6, 3), "#a4b86a" },
  { "spine", c:rect(30, 17, 34, 51), "#4a8a3e", { flat = true } },
}

-- curled fur tufts
local tuft = GV.R.moss.shade
c:fill(c:line({ {17, 30}, {19, 28}, {22, 28}, {23, 31} }, 2), tuft)
c:fill(c:line({ {40, 28}, {42, 26}, {45, 26}, {46, 29} }, 2), tuft)
c:fill(c:line({ {20, 41}, {22, 39}, {25, 39}, {26, 42} }, 2), tuft)
c:fill(c:line({ {41, 41}, {43, 39}, {46, 39}, {47, 42} }, 2), tuft)

c:seam({ {32, 20}, {32, 50} })
c:button(30, 15)

local t = c:save(O .. "aseprite/ph/elder-pelt.aseprite", O .. "png/ph/elder-pelt.png")
print(GV.report(t))
