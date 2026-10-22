-- ph/foxtail-lily-seed (redo, unique): tall envelope + foxtail lily spike + winged seeds
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- envelope geometry (tall, narrow)
local env = c:rrect(24, 34, 39, 55, 1)
local flap = c:poly({ {24, 34}, {40, 34}, {32, 44} })
local stem = c:line({ {31, 35}, {31, 27} }, 2)
local leaf = c:poly({ {32, 35}, {36, 30}, {41, 25}, {39, 31}, {34, 35} })
local spike = c:poly({ {31, 9}, {33, 9}, {35, 14}, {37, 21}, {37, 28}, {35, 32}, {28, 32}, {26, 28}, {26, 21}, {28, 14} })
local tip = c:ellipse(32, 9, 1.5, 2.5)

-- winged seeds
local wingL = c:ellipse(18, 53, 3.5, 2.5)
local wingR = c:ellipse(45.5, 53, 3.5, 2.5)
local wingR2 = c:ellipse(48, 47.5, 2.5, 2)

local p = c:build{
  { "wingL",  wingL,  "#c9a96e", { flat = true } },
  { "wingR",  wingR,  "#c9a96e", { flat = true } },
  { "wingR2", wingR2, "#c9a96e", { flat = true } },
  { "stem",   stem,   "moss",  { flat = true } },
  { "leaf",   leaf,   "moss",  { flat = true } },
  { "spike",  spike,  GV.ramp("#f08a24"), { gloss = { 29, 16 } } },
  { "tip",    tip,    "moss",  { flat = true } },
  { "env",    env,    "cream" },
  { "flap",   flap,   GV.ramp("#e6d3a4"), { light = env, gloss = false } },
  { "seal",   c:ellipse(32, 44, 3, 3), "red", { gloss = { 31, 42 } } },
}

-- seed cores on wings
c:fill(c:ellipse(18, 53, 1.5, 1), "#8a4f2a")
c:fill(c:ellipse(45.5, 53, 1.5, 1), "#8a4f2a")
c:fill(c:rect(47, 47, 48, 48), "#8a4f2a")

-- starry blooms on the spike (yellow stars with orange hearts)
local Y, H = "#ffd36a", "#c84a1a"
local stars = { {32,13}, {30,16}, {34,18}, {29,21}, {33,22}, {35,25}, {28,26}, {31,27}, {34,29}, {29,30} }
for _, s in ipairs(stars) do
  local x, y = s[1], s[2]
  if p.spike.m:has(x-1,y) and p.spike.m:has(x+1,y) then
    c:px(x, y-1, Y); c:px(x-1, y, Y); c:px(x+1, y, Y); c:px(x, y+1, Y); c:px(x, y, H)
  end
end
-- small buds near top
c:px(32, 11, Y); c:px(31, 13, "#fff1c8")

-- envelope details: edge stitch on body, seal emboss
c:stitch(p.env.m:copy():cut(flap:grow(1)))
c:paint({ ".g.", "g.g", ".g." }, 31, 43, { g = "#6b1b2c" })
c:px(32, 44, "#f2793a")

local t = c:save(O .. "aseprite/ph/foxtail-lily-seed.aseprite", O .. "png/ph/foxtail-lily-seed.png")
print(GV.report(t))
