local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stakeR = GV.ramp("#8a4f2a")
local upLight = GV.ramp("#d9a660")
local upDark  = GV.ramp("#c4925f")
local loLight = GV.ramp("#d9a660")
local loDark  = GV.ramp("#c4925f")

-- wavy rods (6 px thick)
local upper = c:line({ {11, 23}, {17, 23}, {25, 26}, {32, 27}, {39, 26}, {47, 23}, {52, 23} }, 6)
local lower = c:line({ {11, 40}, {17, 40}, {25, 37}, {32, 36}, {39, 37}, {47, 40}, {52, 40} }, 6)
local function seg(m, x0, x1) return m:copy():clip(c:rect(x0, 0, x1, 63)) end

-- stakes: rounded, uneven tops
local s1 = c:rrect(14, 14, 20, 52, 3)
local s2 = c:rrect(29, 16, 35, 52, 3)
local s3 = c:rrect(44, 12, 50, 52, 3)
s1:del(14, 15); s3:add(c:rect(45, 11, 47, 12)); s3:del(50, 13)

c:build{
  { "upMid", seg(upper, 27, 37), upDark,  { light = upper, gloss = false } },
  { "loL",   seg(lower, 0, 24),  loDark,  { light = lower, gloss = false } },
  { "loR",   seg(lower, 40, 63), loDark,  { light = lower, gloss = false } },
  { "s1", s1, stakeR },
  { "s3", s3, stakeR },
  { "s2", s2, stakeR },
  { "loMid", seg(lower, 25, 39), loLight, { light = lower } },
  { "upL",   seg(upper, 0, 26),  upLight, { light = upper } },
  { "upR",   seg(upper, 38, 63), upLight, { light = upper } },
}
-- grass tufts at the feet
c:part(c:ascii({ "x.x..x", "xx.xx.", ".xxxx." }, 12, 50), "moss", { flat = true })
c:part(c:ascii({ "x..x.x", ".xx.xx", ".xxxx." }, 43, 50), "moss", { flat = true })

local t = c:save(O .. "aseprite/ph/wattle-fence.aseprite", O .. "png/ph/wattle-fence.png")
print(GV.report(t))
