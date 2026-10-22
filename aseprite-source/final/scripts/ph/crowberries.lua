local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ink  = GV.ramp("#2e2352", { rim = "#7b66b4", gloss = "#a894dc" })   -- dusk family, near-black berry
local dusk = GV.ramp("#4e3a8a", { gloss = "#a894dc" })                    -- dusk family, lighter berry
local R = 6.5
local function berry(x, y) return c:ellipse(x, y, R, R) end
c:build{
  { "leaf",  c:poly({ {33, 17}, {35, 12}, {39, 9}, {44, 9}, {43, 13}, {39, 17} }), "leaf", { flat = true } },
  { "stem",  c:rect(31, 15, 33, 21), "#2e5a2c", { flat = true } },
  { "top",   berry(32.5, 26), ink },
  { "midL",  berry(25.5, 36), dusk },
  { "midR",  berry(39.5, 37), ink },
  { "botL",  berry(18.5, 46), ink },
  { "botM",  berry(31.5, 47), dusk },
  { "botR",  berry(45, 46), ink },
}
-- small ripple glints (crowberry dimples)
c:paint({ "a.a", ".a." }, 35, 28, { a = "#a894dc" })
c:paint({ "a.a", ".a." }, 33, 49, { a = "#a894dc" })
c:paint({ "a.a", ".a." }, 20, 48, { a = "#7b66b4" })
c:paint({ "a.a", ".a." }, 42, 39, { a = "#7b66b4" })
c:ground(32, 53, 17, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/crowberries.aseprite", D .. "img-redraw-full/png/ph/crowberries.png")
print(GV.report(t))
