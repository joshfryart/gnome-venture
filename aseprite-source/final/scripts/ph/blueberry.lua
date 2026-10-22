local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return c:poly(pts)
end

local leaf = c:poly({ {5, 55}, {10, 48}, {17, 45}, {27, 46}, {24, 52}, {16, 57}, {7, 57} })
local small = c:ellipse(47, 46, 8, 8)
local big = c:ellipse(27.5, 31, 19, 19)

local blue = GV.ramp("#5a86b8", { shade = "#2f6290", deep = "#2a3c6c" })
local p = c:build{
  { "leaf",  leaf,  "moss", { flat = false } },
  { "small", small, GV.ramp("#3f8fb0", { shade = "#2f6290", deep = "#2a3c6c" }) },
  { "big",   big,   blue, { gloss = { 16, 22 } } },
}
-- bloom patch (dusty)
c:fill(c:ellipse(19, 24, 3, 2):cut(c:rect(16, 21, 18, 22)), "#8fcbd8")
-- leaf vein
c:paint({ "vvvvv.....", ".....vvvvv" }, 10, 52, { v = "#4a8a3e" })
-- crown star on big berry
local s = star(27.5, 16, 8, 3.2)
c:fill(s:copy():grow(1):clip(big), "#2a3c6c"); c:fill(s, "#291d4a")
c:fill(c:rect(27, 15, 28, 16), "#2a1a10")
c:px(26, 14, "#3e2f66")
-- small calyx
c:fill(star(47, 40, 3.5, 1.6), "#2a3c6c")
c:px(47, 40, "#2a1a10")

local t = c:save(D .. "img-redraw-full/aseprite/ph/blueberry.aseprite", D .. "img-redraw-full/png/ph/blueberry.png")
print(GV.report(t))
