-- ph/blackcurrant : a strig of five dark berries hanging in a zig-zag from a curved stem
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dusk = GV.ramp("#3e2f66", { rim = "#7b66b4", shade = "#291d4a", gloss = "#a894dc" })

local leaf = c:poly({ {14, 10}, {20, 9}, {27, 12}, {30, 16}, {24, 18}, {18, 16} })
local stem = c:line({ {28, 15}, {32, 12}, {35, 13}, {36, 16}, {34, 19}, {33, 24} }, 2)
local berries = { {28, 22}, {37, 28}, {27, 35}, {37, 41}, {30, 48} }
local peds = c:mask()
for _, b in ipairs(berries) do
  peds:add(c:line({ {33, 22}, {math.floor(b[1] + 0.5), b[2] - 4} }, 2))
end
peds:add(c:line({ {33, 20}, {33, 40} }, 2))

local parts = {
  { "leaf", leaf, "leaf" },
  { "stem", stem:add(peds), GV.ramp("#2f5a2a", { rim = "#6a9a3a" }), { flat = true } },
}
for i, b in ipairs(berries) do
  parts[#parts + 1] = { "b" .. i, c:ellipse(b[1], b[2], 5, 5), dusk }
end
c:build(parts)
-- leaf vein
c:fill(c:line({ {17, 12}, {28, 15} }, 1), "#2f5a2a")
-- calyx at each berry bottom
for _, b in ipairs(berries) do
  c:paint({ "u.u", ".u." }, b[1] - 1 + 1, b[2] + 3, { u = "#7b66b4" })
end

local t = c:save(O .. "aseprite/ph/blackcurrant.aseprite", O .. "png/ph/blackcurrant.png")
print(GV.report(t))
