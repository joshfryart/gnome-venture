local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mud = GV.ramp("#8c4a1a", { shade = "#8a4f2a" })
local s1 = GV.ramp("#7ab55c")
local s2 = GV.ramp("#58a03e")
local s3 = GV.ramp("#4a8a3e")
local fluff = GV.ramp("#f08a24")

-- five stalks fanning out from one low base
local function stalk(x0, xm, ym, x1, y1)
  return c:line({ { x0, 52 }, { xm, ym }, { x1, y1 } }, 3)
end
local far = stalk(23, 14, 32, 10, 13):add(stalk(41, 50, 32, 54, 13))
local mid = stalk(27, 20, 30, 17, 11):add(stalk(36, 44, 30, 47, 11))
local ctr = stalk(31, 31, 34, 31, 16)

-- seed-head tips on the side stalks (small brown clubs)
local tips = c:rrect(8, 9, 12, 15, 2):add(c:rrect(52, 9, 56, 15, 2))
tips:add(c:rrect(15, 7, 19, 13, 2)):add(c:rrect(45, 7, 49, 13, 2))

local p = c:build{
  { "far", far, s3, { flat = true } },
  { "mid", mid, s2, { flat = true } },
  { "tips", tips, "wood", { flat = true } },
  { "ctr", ctr, s1, { flat = true } },
  { "mud", c:ellipse(31.5, 53, 15, 4), mud },
  { "fluff", c:ellipse(31.5, 12, 7, 6.5), fluff, { gloss = { 28, 8 } } },
}

-- cream flecks in the fluff
c:px(34, 9, "#fff3c8"); c:px(36, 12, "#fff3c8"); c:px(29, 14, "#fff3c8"); c:px(33, 15, "#fff3c8")
c:px(27, 11, "#fff3c8")

-- thread-gold wrap tie across the bundle
c:seam({ { 22, 44 }, { 42, 44 } }, { free = false })
c:seam({ { 23, 45 }, { 41, 45 } }, { free = false })

local t = c:save(O .. "aseprite/ph/cattail-fluff.aseprite", O .. "png/ph/cattail-fluff.png")
print(GV.report(t))
