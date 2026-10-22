local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pale = GV.ramp("#e6dcf0")
local lilac = GV.ramp("#c9b8e0")

c:build{
  { "handle", c:rrect(7, 40, 17, 45, 2), "wood", { gloss = false } },
  { "bowl", c:ellipse(32, 36, 18, 16):cut(c:rect(0, 0, 63, 35)), "wood" },
}
-- pyramid of pearls, back (top) to front (bottom)
local rows = {
  { y = 13, xs = { 32 } },
  { y = 20, xs = { 28, 36 } },
  { y = 27, xs = { 24, 32, 40 } },
  { y = 34, xs = { 20, 28, 36, 44 } },
}
local accent = { ["36,20"] = true, ["24,27"] = true, ["44,34"] = true }
for _, r in ipairs(rows) do
  for _, x in ipairs(r.xs) do
    local ramp = accent[x .. "," .. r.y] and lilac or pale
    c:part(c:ellipse(x, r.y, 4, 4), ramp, { gloss = { x - 2, r.y - 2 } })
  end
end
c:part(c:rect(13, 35, 51, 38), "#d9a660", { gloss = false })
c:seam({ {16, 36}, {48, 36} })

local t = c:save(O .. "aseprite/ph/sago.aseprite", O .. "png/ph/sago.png")
print(GV.report(t))
