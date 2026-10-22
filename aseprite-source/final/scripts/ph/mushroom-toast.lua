local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- bread slice: classic toast silhouette, two shoulder lobes over a square base
local toast = c:rrect(12, 28, 52, 52, 5)
toast:add(c:ellipse(21, 26, 10, 8))
toast:add(c:ellipse(43, 26, 10, 8))
toast:add(c:ellipse(32, 25, 14, 9))
local crumb = toast:shrink(3)

local p = c:build{
  { "crust", toast, "#a8582f" },
}
c:part(crumb, GV.ramp("#d9a660", { shade = "#b07a45" }), { contour = false, contact = false, gloss = false })

-- mushroom slices: domed cap + short stem, cream-safe
local function slice(cx, cy, rx, ry)
  local cap = c:ellipse(cx, cy, rx, ry):cut(c:rect(0, cy + 1, 63, 63))
  cap:add(c:rect(cx - rx + 1, cy, cx + rx - 1, cy + 1))
  cap:add(c:rrect(cx - 2, cy, cx + 2, cy + 5, 1))
  return cap
end
local cream = GV.ramp("#ecc58a")
local sA = slice(21, 35, 7, 5)
local sB = slice(36.5, 31, 7.5, 5)
local sC = slice(43, 43, 6, 4)
c:build{
  { "A", sA, cream, { gloss = { 17, 32 } } },
  { "B", sB, cream, { gloss = { 32, 28 } } },
  { "C", sC, cream, { gloss = { 39, 41 } } },
}
-- gills under each cap
for _, g in ipairs({ { 21, 35, 7 }, { 36, 31, 7 }, { 43, 43, 6 } }) do
  for x = g[1] - g[3] + 2, g[1] + g[3] - 2 do
    if math.abs(x - g[1]) > 2 then c:px(x, g[2] + 1, "#c4925f") end
  end
end

local t = c:save(O .. "aseprite/ph/mushroom-toast.aseprite", O .. "png/ph/mushroom-toast.png")
print(GV.report(t))
