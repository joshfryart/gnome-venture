local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local feet = c:rrect(12, 46, 20, 56, 2)
feet:add(c:rrect(44, 46, 52, 56, 2))

-- tall rounded backrest: rounded top only
local back = c:rrect(16, 8, 48, 30, 9)
back:add(c:rect(16, 20, 48, 34))

local base = c:rrect(10, 38, 54, 50, 3)
local seat = c:rrect(8, 29, 56, 40, 4)
local mosscap = c:rrect(20, 7, 44, 14, 4)

local p = c:build{
  { "feet", feet, "#5e2f1e", { gloss = false } },
  { "back", back, "#a8582f", { light = back:copy():add(base) } },
  { "mosscap", mosscap, "#6a9a3a" },
  { "base", base, "wood" },
  { "seat", seat, "moss", { stitch = { side = "lit" } } },
}

-- carved diamond on the backrest
c:paint({
  "..dd..",
  ".dddd.",
  "dddddd",
  ".dddd.",
  "..dd..",
}, 29, 21, { d = "#5e2f1e" })

-- tufts on the seat top
for _, x in ipairs({ 14, 30, 46 }) do
  c:paint({ ".t.", "ttt" }, x, 27, { t = "#a4b86a" })
end

-- seam along the front seat lip, button on the backrest
c:seam({ { 11, 38 }, { 53, 38 } })
c:button(30, 15)

local t = c:save(O .. "aseprite/ph/mossy-throne.aseprite", O .. "png/ph/mossy-throne.png")
print(GV.report(t))
