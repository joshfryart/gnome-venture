local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan   = GV.ramp("#dcb06a", { rim = "#d9a660" })
local brown = GV.ramp("#a5663a")
local horn  = GV.ramp("#6e4530")

local function mir(pts) local r = {} for i, p in ipairs(pts) do r[i] = { 63 - p[1], p[2] } end return r end
-- horn: a fat curl (disc) with a root sweeping up over the head
local function hornMask(m)
  local hm = c:ellipse(16, 23, 5.5, 6)
  hm:add(c:line({ {16,17}, {20,14}, {25,13} }, 4))
  if m then hm = hm:shift(0,0) end
  return hm
end
local hL = c:ellipse(16, 23, 5.5, 6):add(c:line({ {15,18}, {19,14}, {25,13} }, 4))
local hR = c:ellipse(47, 23, 5.5, 6):add(c:line({ {48,18}, {44,14}, {38,13} }, 4))

local p = c:build{
  { "tail",  c:ellipse(46, 45, 3.5), brown },
  { "feet",  c:ellipse(24, 49, 5, 3):add(c:ellipse(39, 49, 5, 3)), brown },
  { "body",  c:ellipse(31.5, 39, 14, 11), tan },
  { "chest", c:ellipse(31.5, 42, 8, 7), "cream", { contact = false } },
  { "ears",  c:ellipse(16, 31.5, 4, 2.5):add(c:ellipse(47, 31.5, 4, 2.5)), tan, { gloss = false } },
  { "head",  c:ellipse(31.5, 25, 11, 10.5), tan },
  { "hornL", hL, horn, { gloss = { 13, 19 } } },
  { "hornR", hR, horn, { gloss = { 44, 19 } } },
  { "muzzle", c:ellipse(31.5, 30, 5.5, 4), "cream" },
}
-- ear insides
c:paint({ "ccc" }, 14, 31, { c = "#f8eed2" }); c:paint({ "ccc" }, 47, 31, { c = "#f8eed2" })
-- spiral grooves
local g = horn.deep
c:paint({ ".gg..", "g..g.", "g.g.g", "g...g", ".ggg." }, 14, 21, { g = g })
c:paint({ "..gg.", ".g..g", "g.g.g", "g...g", ".ggg." }, 45, 21, { g = g })
-- nose and mouth
c:paint({ ".nnnn.", "nnnnnn", "..nn.." }, 29, 27, { n = "#2a1a10" })
c:px(30, 27, "#5e2a3a")
c:paint({ "m....m", ".mmmm." }, 29, 31, { m = "#2a1a10" })
c:eye(22, 20); c:eye(37, 20)
local t = c:save(O .. "aseprite/ph/creature-cliff-ram.aseprite", O .. "png/ph/creature-cliff-ram.png")
print(GV.report(t))
