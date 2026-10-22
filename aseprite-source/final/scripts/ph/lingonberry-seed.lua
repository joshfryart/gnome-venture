local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pouch = c:ellipse(32, 41, 19, 16)
local neck = c:rrect(23, 15, 41, 26, 3)
neck:add(c:poly({ {18, 12}, {25, 15}, {24, 20} }))
neck:add(c:poly({ {46, 12}, {39, 15}, {40, 20} }))
neck:add(c:poly({ {28, 13}, {32, 11}, {36, 13}, {36, 16}, {28, 16} }))
local cord = c:rect(22, 24, 42, 26)
local tails = c:line({ {37, 26}, {36, 33} }, 2):add(c:line({ {41, 26}, {42, 32} }, 2))

local parts = {
  { "pouch", pouch, GV.ramp("#f1ece0"), { stitch = { side = "lit" } } },
  { "neck", neck, GV.ramp("#f4f0e0") },
  { "cord", cord, GV.ramp("#dcb06a"), { flat = true } },
  { "tails", tails, GV.ramp("#dcb06a"), { flat = true } },
}
local bt = { {28, 37, "#d6322b"}, {37, 37, "#d6322b"}, {32.5, 31, "#d6322b"},
             {24, 45, "#a8241f"}, {32.5, 45, "#a8241f"}, {41, 45, "#a8241f"} }
for i, b in ipairs(bt) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 4.5, 4.5), GV.ramp(b[3]), { cres = 2, deep = 1 } }
end
local leaf = c:poly({ {33, 27}, {38, 22}, {44, 21}, {41, 26}, {35, 28} })
parts[#parts + 1] = { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } }
local p = c:build(parts)

c:seam({ {24, 20}, {40, 20} })
c:fill(c:line({ {33, 27}, {34, 30} }, 2), "#2e5a2c")
for i = 1, 6 do
  local b = bt[i]
  c:px(math.floor(b[1]) - 2, b[2] - 2, "#ff9158"); c:px(math.floor(b[1]) - 1, b[2] - 3, "#ffc27a")
end

local t = c:save(O .. "aseprite/ph/lingonberry-seed.aseprite", O .. "png/ph/lingonberry-seed.png")
print(GV.report(t))
