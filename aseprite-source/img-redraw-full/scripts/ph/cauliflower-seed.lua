local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- leaf: teardrop, pointed top, fanning above crate
local leaf = c:ellipse(31.5, 22, 11, 11):add(c:poly({ {24, 16}, {32, 5}, {40, 16} }))
local crate = c:rect(14, 30, 50, 54)
local slat1 = c:rect(19, 34, 45, 37)
local slat2 = c:rect(19, 44, 45, 47)
local postL = c:rect(14, 28, 18, 54)
local postR = c:rect(46, 28, 50, 54)
local rim = c:rrect(12, 26, 52, 31, 1)

local wood = "wood"
local p = c:build{
  { "leaf",  leaf,  GV.ramp("#58a03e") },
  { "crate", crate, GV.ramp("#8a5a34"), { gloss = false } },
  { "slat1", slat1, GV.ramp("#d9a660"), { gloss = false, cres = 1, deep = 0 } },
  { "slat2", slat2, GV.ramp("#d9a660"), { gloss = false, cres = 1, deep = 0 } },
  { "postL", postL, GV.ramp("#8a4f2a"), { gloss = false } },
  { "postR", postR, GV.ramp("#8a4f2a"), { gloss = false } },
  { "rim",   rim,   GV.ramp("#d9a660") },
}
-- leaf veins
local vein = "#2e5a2c"
for y = 10, 25 do c:px(31, y, vein); c:px(32, y, vein) end
c:paint({ "v.....", ".v....", "..v...", "...v.." }, 25, 15, { v = vein })
c:paint({ "..v", ".v.", "v.." }, 35, 17, { v = vein })
c:paint({ "...v", "..v.", ".v..", "v..." }, 34, 16, { v = vein })
-- nail dots
for _, q in ipairs({ {15, 35}, {47, 35}, {15, 45}, {47, 45} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#5e2f1e")
end

local t = c:save(O .. "aseprite/ph/cauliflower-seed.aseprite", O .. "png/ph/cauliflower-seed.png")
print(GV.report(t))
