local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- body / coat (half ellipse bleeding off the bottom)
local body = c:ellipse(39.5, 101, 34, 25):clip(c:rect(0, 77, 79, 99))
-- scarf band + tail
local scarf = c:line({ {27, 79}, {39.5, 85}, {52, 79} }, 6)
local tail = c:poly({ {46, 82}, {53, 82}, {54, 97}, {44, 97} })
-- ears
local earL = c:ellipse(23, 33, 11, 11)
local earR = c:ellipse(56, 33, 11, 11)
local innL = c:ellipse(23.5, 33.5, 6.5, 6.5)
local innR = c:ellipse(55.5, 33.5, 6.5, 6.5)
-- face, muzzle, nose
local face = c:ellipse(39.5, 54, 22, 20)
local muzzle = c:ellipse(39.5, 63, 12, 8.5)
local nose = c:ellipse(39.5, 58.5, 3.5, 2.5)

local coat = GV.ramp("#a5663a", { shade = "#8c4a1a" })
local p = c:build{
  { "disc",   c:ellipse(39.5, 50, 36, 36), GV.ramp("#b8d8d2"), { solid = true } },
  { "body",   body,   coat, { stitch = { side = "lit" } } },
  { "tail",   tail,   GV.ramp("#c4925f") },
  { "scarf",  scarf,  GV.ramp("#c4925f") },
  { "earL",   earL,   "gold" },
  { "earR",   earR,   "gold" },
  { "innL",   innL,   GV.ramp("#f6b8cf"), { flat = true } },
  { "innR",   innR,   GV.ramp("#f6b8cf"), { flat = true } },
  { "face",   face,   "gold", { gloss = { 24, 40 } } },
  { "muzzle", muzzle, GV.ramp("#f5cf6a"), { gloss = false } },
  { "nose",   nose,   GV.ramp("#d9667f"), { flat = true } },
}
c:px(38, 57, "#f6b8cf"); c:px(39, 57, "#f6b8cf")

-- scarf hem seam on the tail
c:seam({ {45, 94}, {53, 94} })

-- whiskers
local wk = "#4a2c1a"
c:fill(c:line({ {27, 61}, {14, 60} }, 1), wk)
c:fill(c:line({ {27, 64}, {15, 67} }, 1), wk)
c:fill(c:line({ {52, 61}, {65, 60} }, 1), wk)
c:fill(c:line({ {52, 64}, {64, 67} }, 1), wk)

-- mouth: small sleepy smile
c:paint({ "..u..", "..u..", "u.u.u", ".u.u." }, 37, 61, { u = "#8a4234" })

-- eyes
c:eye(28, 49); c:eye(47, 49)

-- garland: vine + six blooms across the brow
c:fill(c:line({ {19, 43}, {29, 45}, {39, 46}, {49, 45}, {60, 43} }, 2), "#58a03e")
local blooms = {
  { 22, 42, "#d9667f" }, { 29, 40, "#f5cf6a" }, { 36, 42, "#f8eed2" },
  { 43, 40, "#c3b2ea" }, { 50, 42, "#d9667f" }, { 57, 40, "#f5cf6a" },
}
for _, b in ipairs(blooms) do
  local x, y, col = b[1], b[2], b[3]
  local r = GV.ramp(col)
  local m = c:ascii({ ".#.#.", "#####", ".###.", "#####", ".#.#." }, x - 2, y - 2)
  c:fill(m, r.base)
  c:px(x - 1, y - 2, r.gloss); c:px(x - 2, y - 1, r.rim)
  c:px(x + 1, y + 2, r.shade); c:px(x + 2, y + 1, r.shade)
  c:px(x, y, "#e8a317")
end

local t = c:save(O .. "aseprite/ph/npc-pebble-leafwhisker.aseprite", O .. "png/ph/npc-pebble-leafwhisker.png")
print(GV.report(t))
