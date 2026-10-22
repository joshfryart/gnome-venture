local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:ground(32, 53, 16, 2.5, "#6a4528")
local function spike(cx, y0, y1, tilt)
  local m = c:mask()
  local i = 0
  for y = y1, y0, -3 do
    local f = (y - y0) / math.max(1, y1 - y0)         -- 0 top .. 1 bottom
    local r = 1.5 + f * 1.2
    local dx = (i % 2 == 0) and -0.5 or 0.5
    m:add(c:ellipse(cx + dx + tilt * (y1 - y), y, r, 1.6))
    i = i + 1
  end
  return m
end
local stems = c:line({ {32, 32}, {32, 22} }, 2):add(c:line({ {29, 32}, {23, 22} }, 2)):add(c:line({ {35, 32}, {41, 22} }, 2))
local leaves = c:poly({ {31, 31}, {27, 25}, {21, 22}, {24, 27} }):add(c:poly({ {33, 31}, {37, 25}, {43, 22}, {40, 27} }))
local pot = c:poly({ {17, 35}, {48, 35}, {44, 53}, {21, 53} })
local rim = c:rrect(14, 30, 50, 37, 3)
local violet = GV.ramp("#7a5cc0", { rim = "#a894dc" })
local p = c:build{
  { "stems",  stems, GV.ramp("#58a03e"), { flat = true } },
  { "sl",     spike(22, 13, 23, -0.15), violet },
  { "sr",     spike(42, 13, 23, 0.15), violet },
  { "sc",     spike(32, 10, 23, 0), violet },
  { "leaves", leaves, GV.ramp("#58a03e"), { flat = true } },
  { "pot",    pot, GV.ramp("#e0501f") },
  { "rim",    rim, GV.ramp("#d6322b") },
}
c:seam({ {17, 37}, {47, 37} })
local t = c:save(O .. "aseprite/ph/lavender-border.aseprite", O .. "png/ph/lavender-border.png")
print(GV.report(t))
