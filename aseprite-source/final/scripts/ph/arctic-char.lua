local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {9, 33}, {12, 27}, {18, 22}, {26, 19}, {34, 20}, {41, 25}, {45, 31}, {45, 35}, {40, 40}, {32, 44}, {22, 44}, {14, 40} })
local belly = body:copy():cut(body:shift(0, -6)):cut(c:rect(41, 0, 63, 63))
local p = c:build{
  { "fin",   c:poly({ {27, 21}, {31, 14}, {35, 14}, {37, 22} }), "moss", { gloss = false } },
  { "tail",  c:poly({ {40, 30}, {53, 19}, {52, 26}, {47, 33}, {52, 40}, {53, 47}, {40, 37} }), "moss", { gloss = false } },
  { "body",  body, "moss", { gloss = { 18, 25 } } },
  { "belly", belly, "cream", { gloss = false, contact = false } },
  { "pect",  c:poly({ {22, 36}, {28, 37}, {25, 42}, {21, 40} }), "moss", { flat = true } },
}
-- parr bars on the flank (above the belly)
local flank = body:copy():cut(belly):shrink(1)
c:fill(c:line({ {29, 23}, {29, 35} }, 2):clip(flank), "#4a8a3e")
c:fill(c:line({ {35, 24}, {35, 35} }, 2):clip(flank), "#4a8a3e")
-- pale spots
for _, s in ipairs({ {24, 27}, {32, 30}, {39, 30}, {22, 33} }) do c:px(s[1], s[2], "#f6b8cf") end
-- gill line
c:fill(c:line({ {19, 26}, {18, 31}, {19, 36} }, 1):clip(body:shrink(1)), "#4a8a3e")
c:eye(13, 28, true)
local t = c:save(O .. "aseprite/ph/arctic-char.aseprite", O .. "png/ph/arctic-char.png")
print(GV.report(t))
