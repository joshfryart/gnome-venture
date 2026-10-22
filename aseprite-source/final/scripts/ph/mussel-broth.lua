local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stone = GV.ramp("#8b8f96", { shade = "#5b6470" })
local slate = GV.ramp("#5b6470")
local navy = GV.ramp("#2a3c6c", { rim = "#5a86b8", gloss = "#8fcbd8" })

-- handles (ears) behind the bowl
local ears = c:rrect(7, 23, 15, 30, 3):cut(c:rrect(10, 26, 15, 27, 0))
ears:add(c:rrect(48, 23, 56, 30, 3):cut(c:rrect(48, 26, 53, 27, 0)))

local body = c:ellipse(31.5, 26, 20, 23):clip(c:rect(0, 26, 63, 50))
local rim = c:ellipse(31.5, 26, 21, 7)
local broth = c:ellipse(31.5, 26, 18, 4.5)

local p = c:build{
  { "ears", ears, slate },
  { "body", body, stone },
  { "rim", rim, slate, { cres = 2, deep = 1 } },
  { "broth", broth, "#a4b86a", { gloss = false, contact = false } },
}
-- herb flecks
c:paint({ ".h.", "hhh", ".h." }, 23, 24, { h = "#6a9a3a" })
c:paint({ ".g.", "ggg", ".g." }, 30, 26, { g = "#4a8a3e" })
c:paint({ "h" }, 31, 24, { h = "#6a9a3a" })

-- mussel shells perched on the rim
local s1 = c:poly({ {13, 25}, {14, 20}, {18, 16}, {22, 16}, {23, 19}, {20, 24}, {16, 27} })
local s2 = c:poly({ {35, 27}, {38, 24}, {43, 23}, {47, 24}, {46, 27}, {41, 29} })
c:part(s1, navy, { cres = 2, deep = 1, gloss = { 17, 19 } })
c:part(s2, navy, { cres = 2, deep = 1, gloss = { 40, 25 } })
c:seam({ {15, 24}, {21, 17} }, { free = true, on = 1, off = 1, gap = "#2a3c6c" })
c:ground(31.5, 51, 15, 1.5)
local t = c:save(O .. "aseprite/ph/mussel-broth.aseprite", O .. "png/ph/mussel-broth.png")
print(GV.report(t))
