local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- eight bent legs, four per side, mirrored around x = 31.5
local L = {
  { {25,31}, {18,22}, {13,27} },
  { {24,36}, {15,31}, {11,38} },
  { {24,41}, {14,41}, {11,49} },
  { {25,47}, {18,50}, {15,55} },
}
local legs = c:mask()
for _, pts in ipairs(L) do
  legs:add(c:line(pts, 2))
  local m = {}
  for i, p in ipairs(pts) do m[i] = { 62 - p[1], p[2] } end
  legs:add(c:line(m, 2))
end

local legR = GV.ramp("#5e2f1e")
local p = c:build{
  { "legs", legs, legR, { flat = true } },
  { "abdomen", c:ellipse(31.5, 43, 11, 10), "#f08a24", { stitch = { side = "lit" } } },
  { "head", c:ellipse(31.5, 28, 10, 8.5), "#e0501f" },
}

-- three gold diamonds on the abdomen
local dia = { ".gg.", "gggg", "gggg", ".gg." }
c:spot(c:ascii(dia, 26, 42), "#e8a317", "#fff1c8")
c:spot(c:ascii(dia, 34, 42), "#e8a317", "#fff1c8")
c:spot(c:ascii(dia, 30, 47), "#e8a317", "#fff1c8")

-- face
c:eye(24, 25); c:eye(34, 25)
c:paint({ "u...u", ".uuu." }, 29, 31, { u = "#2a1a10" })

c:ground(31.5, 56, 18, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/creature-orb-spider.aseprite",
                 D .. "img-redraw-full/png/ph/creature-orb-spider.png")
print(GV.report(t))
