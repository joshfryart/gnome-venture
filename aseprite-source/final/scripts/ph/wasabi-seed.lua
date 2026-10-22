local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { rim = "#e6f7ef", shade = "#8fcbd8", deep = "#5a9fb8", bounce = "#a8dce0" })
local body = c:rrect(16, 22, 47, 53, 8)
local neck = c:rrect(23, 15, 40, 24, 2)
local cork = c:rrect(21, 7, 42, 16, 3)
local label = c:rect(18, 29, 45, 35)

local p = c:build{
  { "body", body, glass, { gloss = false } },
  { "neck", neck, glass, { gloss = false } },
  { "cork", cork, "wood" },
  { "label", label, "#f1ece0", { gloss = false, pale = true } },
}

-- wasabi seeds in the glass
local seeds = { {24, 40}, {32, 39}, {38, 43}, {27, 46}, {34, 47}, {22, 48}, {40, 49} }
for _, s in ipairs(seeds) do
  local m = c:rrect(s[1], s[2], s[1] + 3, s[2] + 3, 1)
  c:fill(m, "#7ab55c")
  c:px(s[1] + 3, s[2] + 2, "#4a8a3e"); c:px(s[1] + 2, s[2] + 3, "#4a8a3e"); c:px(s[1] + 3, s[2] + 3, "#2f5a2a")
  c:px(s[1] + 1, s[2] + 1, "#c8d77a")
end

-- glass gloss streak
c:fill(c:rect(20, 24, 21, 27), "#fff1c8")
c:fill(c:rect(19, 37, 20, 42), "#fff1c8")
c:px(25, 18, "#fff1c8"); c:px(25, 19, "#fff1c8")

-- cork texture pores
c:px(30, 12, "#8a4f2a"); c:px(36, 10, "#8a4f2a"); c:px(27, 14, "#8a4f2a"); c:px(38, 13, "#8a4f2a")

-- label: little leaf mark
c:paint({ ".gg.", "gggg", ".g.." }, 30, 31, { g = "#4a8a3e" })

c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/wasabi-seed.aseprite", O .. "png/ph/wasabi-seed.png")
print(GV.report(t))
