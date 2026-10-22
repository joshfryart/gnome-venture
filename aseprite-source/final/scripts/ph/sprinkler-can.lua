local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mid  = GV.ramp("#8b8f96")
local pale = GV.ramp("#c9c5bc")
local dark = GV.ramp("#5b6470")

-- arched handle over the top (behind the body)
local handle = c:ellipse(21.5, 31, 11, 18):cut(c:ellipse(21.5, 31, 8, 15)):cut(c:rect(0, 30, 63, 63))
-- tapered can body
local body = c:poly({ {11, 30}, {33, 30}, {30, 54}, {14, 54} })
-- long diagonal spout rising to upper right
local spout = c:line({ {30, 44}, {43, 30} }, 4)
-- sprinkler rose
local rose = c:ellipse(46.5, 26.5, 4.5, 4.5)
-- lip ring on top of the body
local lip = c:rrect(10, 28, 34, 31, 1)
-- band round the body
local band = c:rect(11, 39, 33, 40):clip(body)

local p = c:build{
  { "handle", handle, mid, { gloss = false } },
  { "spout", spout, mid, { gloss = false } },
  { "body", body, pale, { gloss = { 15, 34 } } },
  { "band", band, mid, { flat = true, contact = false } },
  { "lip", lip, mid, { gloss = false } },
  { "rose", rose, dark, { gloss = { 44, 24 } } },
}
-- holes in the rose face
c:px(46, 27, GV.C.ol2); c:px(48, 26, GV.C.ol2); c:px(47, 29, GV.C.ol2); c:px(49, 28, GV.C.ol2)

-- three falling water drops
local drops = { { 48, 34 }, { 41, 38 }, { 48, 41 } }
for _, d in ipairs(drops) do
  local m = c:ascii({ ".ww.", "wwww", "wwww", ".ww." }, d[1], d[2])
  c:part(m, "water", { flat = true, contact = false })
end

local t = c:save(O .. "aseprite/ph/sprinkler-can.aseprite", O .. "png/ph/sprinkler-can.png")
print(GV.report(t))
