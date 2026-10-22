local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan  = GV.ramp("#dcb06a")   -- wood family
local hoof = GV.ramp("#a5663a")   -- wood family
local crm  = "#f8eed2"            -- pale, cream-safe
local tail = c:line({ {43,45}, {49,45}, {52,43}, {53,39}, {52,36} }, 2)
local body = c:ellipse(29.5, 40, 16, 11)
local p = c:build{
  { "tail",  tail, tan, { flat = true } },
  { "tuftT", c:ellipse(52, 34, 2.5, 3), "wood" },
  { "earL",  c:ellipse(18, 16, 4.5, 4.5), tan },
  { "earR",  c:ellipse(41, 16, 4.5, 4.5), tan },
  { "inL",   c:ellipse(18, 16, 2, 2), crm, { flat = true } },
  { "inR",   c:ellipse(41, 16, 2, 2), crm, { flat = true } },
  { "hoofL", c:ellipse(21, 49.5, 5, 3), hoof },
  { "hoofR", c:ellipse(38, 49.5, 5, 3), hoof },
  { "body",  body, tan, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(29.5, 44, 7.5, 5.5), crm },
  { "legL",  c:ellipse(18.5, 42, 3.5, 6), tan },
  { "legR",  c:ellipse(40.5, 42, 3.5, 6), tan },
  { "head",  c:ellipse(29.5, 25, 12, 12), tan },
  { "tuft",  c:ellipse(29.5, 13.5, 4.5, 2.5):add(c:ellipse(25.5, 14.5, 2, 2)):add(c:ellipse(33.5, 14.5, 2, 2)), "wood", { flat = true } },
  { "muz",   c:ellipse(29.5, 32, 7.5, 5.5), crm },
}
c:eye(21, 21); c:eye(34, 21)
c:paint({ "dd...dd", ".d...d." }, 26, 30, { d = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/creature-desert-camel.aseprite", O .. "png/ph/creature-desert-camel.png")
print(GV.report(t))
