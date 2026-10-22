local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(32, 40, 18, 15)
local ruffle = c:rrect(24, 15, 40, 25, 3)
ruffle:add(c:ellipse(23.5, 17, 3.5, 3)); ruffle:add(c:ellipse(40.5, 17, 3.5, 3))
ruffle:add(c:ellipse(32, 15, 4, 3))

-- rolled stick: pill, centre (32,42), rotated up-right
local ax, ay, bx, by, rad = 19, 51, 45, 34, 4
local stick = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = bx - ax, by - ay
  local tt = math.max(0, math.min(1, ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy)))
  local ex, ey = x - (ax + tt * dx), y - (ay + tt * dy)
  if ex * ex + ey * ey <= rad * rad + 0.5 then stick:set(x, y) end
end end
local cap = c:ellipse(45, 34, 3.5, 4)

local p = c:build{
  { "body",   body,   "#f1ece0", { stitch = true } },
  { "ruffle", ruffle, "#f1ece0" },
  { "band",   c:rect(23, 25, 41, 27), "#a5663a", { flat = true } },
  { "cordL",  c:line({ {23,28}, {19,35} }, 2), "#a5663a", { flat = true } },
  { "cordR",  c:line({ {40,28}, {44,35} }, 2), "#a5663a", { flat = true } },
  { "knotL",  c:rect(17, 35, 19, 37), "#a5663a", { flat = true } },
  { "knotR",  c:rect(44, 35, 46, 37), "#a5663a", { flat = true } },
  { "stick",  stick,  "#a5663a" },
  { "cap",    cap,    "#c98d58", { gloss = false } },
}
-- inner curl stripe along the stick
c:fill(c:line({ {21,48}, {40,35} }, 1), "#c08a55")
-- rolled bark spiral on the end cap
c:paint({ ".ddd.", "d...d", "d.d.d", "d..dd", ".dd.." }, 43, 32, { d = "#6b3a1e" })
-- ruffle pleats
c:paint({ "c", "c", "c" }, 29, 19, { c = "#dcb06a" })
c:paint({ "c", "c", "c" }, 35, 19, { c = "#dcb06a" })
-- cloth crease
c:paint({ "...c", "..c.", ".c..", "c..." }, 40, 47, { c = "#dcb06a" })
c:seam({ {17,45}, {23,53} })
local t = c:save(O .. "aseprite/ph/cinnamon-seed.aseprite", O .. "png/ph/cinnamon-seed.png")
print(GV.report(t))
