local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = GV.ramp("#8c4a1a")
local cara = GV.ramp("#a5663a")

local P = {
  ".XXX......X",
  "XXXX.....XX",
  "XXXX....XXX",
  "XXXX....XXX",
  "XXXX...XXX.",
  "XXXXX.XXXX.",
  "XXXXXXXXXXX",
  "XXXXXXXXXXX",
  "XXXXXXXXXXX",
  ".XXXXXXXXXX",
  "..XXXXXXXX.",
  "...XXXXXX..",
}
local function mirror(rows) local r = {} for i, s in ipairs(rows) do r[i] = s:reverse() end return r end

local claws = c:ascii(P, 11, 13):add(c:ascii(mirror(P), 42, 13))
local arms = c:line({ {16, 24}, {16, 32}, {21, 39} }, 3):add(c:line({ {47, 24}, {47, 32}, {42, 39} }, 3))
claws:add(arms)
local tail = c:poly({ {44, 43}, {50, 40}, {53, 46}, {50, 52}, {44, 50} })

local p = c:build{
  { "tail",  tail, shell },
  { "claws", claws, shell },
  { "body",  c:ellipse(32, 42, 16, 9), shell },
  { "cara",  c:ellipse(32, 40, 12, 5), cara, { stitch = { side = "lit" } } },
  { "stalks", c:rect(25, 31, 26, 34):add(c:rect(37, 31, 38, 34)), shell, { flat = true } },
}
-- tail segment seams
c:seam({ {47, 42}, {48, 51} })
c:eye(23, 27); c:eye(35, 27)
c:paint({ "u...u", ".uuu." }, 30, 41, { u = "umber" })
c:ground(32, 56, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-mud-crayfish.aseprite", O .. "png/ph/creature-mud-crayfish.png")
print(GV.report(t))
