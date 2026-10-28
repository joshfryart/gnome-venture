local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"

-- twigs fanning up from the bow
local twigs = c:line({ {31, 48}, {15, 30} }, 3)
twigs:add(c:line({ {32, 48}, {32, 30} }, 3))
twigs:add(c:line({ {33, 48}, {49, 31} }, 3))
local wood = GV.ramp("#8a4f2a", { rim = "#b07a45", shade = "#5e2f1e", deep = "#5e2f1e" })

-- leaves: pointed ovals poking out on both sides
local leaves = c:poly({ {8, 33}, {11, 29}, {17, 29}, {19, 32}, {13, 36}, {10, 36} })
leaves:add(c:poly({ {56, 31}, {53, 27}, {47, 28}, {45, 31}, {51, 34}, {54, 34} }))
leaves:add(c:poly({ {13, 44}, {16, 39}, {22, 37}, {25, 39}, {21, 43}, {16, 45} }))
leaves:add(c:poly({ {51, 44}, {48, 39}, {42, 37}, {39, 39}, {43, 43}, {48, 45} }))
local moss = GV.ramp("#6a9a3a", { shade = "#4a8a3e", rim = "#a4b86a" })

-- bloom
local bloom = c:ellipse(31.5, 20, 11.5, 11)
for k = 0, 6 do
  local a = k * 2 * math.pi / 7 - math.pi / 2
  bloom:add(c:ellipse(31.5 + math.cos(a) * 8.5, 20 + math.sin(a) * 8, 5.5, 5))
end
local cream = GV.ramp("#f1ece0", { shade = "#dcb06a", deep = "#b07a45", bounce = "#f5b860",
  gloss = "#fff3c8", dot = "#ffffff", rim = "#f5b860" })

-- thread bow
local bow = c:ellipse(26, 47, 4.5, 3.5):cut(c:ellipse(25.5, 47, 1.5, 1))
bow:add(c:ellipse(38, 47, 4.5, 3.5):cut(c:ellipse(38.5, 47, 1.5, 1)))
bow:add(c:poly({ {29, 49}, {32, 49}, {27, 56}, {24, 55} }))
bow:add(c:poly({ {32, 49}, {35, 49}, {40, 55}, {37, 56} }))
local gold = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b8661a" })

local p = c:build{
  { "twigs", twigs, wood, { gloss = false } },
  { "leaves", leaves, moss, { gloss = false } },
  { "bloom", bloom, cream, { cres = 3, deep = 1, gloss = { 22, 11 } } },
  { "bow", bow, gold, { gloss = false } },
}

-- spiral petals: curled arcs into the centre
local L = "#dcb06a"
local D = "#c08a4a"
local cx, cy = 32, 20
local function arc(r, a0, a1, col, sy)
  for i = 0, 200 do
    local a = math.rad(a0 + (a1 - a0) * i / 200)
    local x = math.floor(cx + math.cos(a) * r + 0.5)
    local y = math.floor(cy + math.sin(a) * r * (sy or 1) + 0.5)
    if bloom:shrink(2):has(x, y) then c:px(x, y, col) end
  end
end
arc(3, 150, 420, D)
arc(6, 200, 400, D, 0.9)
arc(6, 30, 140, L, 0.9)
arc(9.5, 230, 330, L, 0.85)
arc(9.5, 350, 470, L, 0.85)
arc(10, 160, 210, L, 0.9)
-- gold heart
c:fill(c:rect(31, 19, 32, 20), "#f5cf6a")
c:px(31, 19, "#fff1c8")

-- leaf veins
c:fill(c:line({ {10, 33}, {17, 31} }, 1), "#4a8a3e")
c:fill(c:line({ {54, 31}, {47, 30} }, 1), "#4a8a3e")
c:fill(c:line({ {16, 42}, {23, 39} }, 1), "#4a8a3e")
c:fill(c:line({ {48, 42}, {41, 39} }, 1), "#4a8a3e")

c:button(30, 46)

local t = c:save(O .. "aseprite/ph/white-rose-of-york.aseprite", O .. "png/ph/white-rose-of-york.png")
print(GV.report(t))
