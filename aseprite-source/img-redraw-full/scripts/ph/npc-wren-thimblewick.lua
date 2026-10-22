local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local brown = GV.ramp("#a5663a")
local dkbrown = GV.ramp("#8c4a1a")
local pink = GV.ramp("#d9667f")
local berry = GV.ramp("#9c2a1e")
local cream = GV.ramp("#f8eed2")

-- body / shoulders
local body = c:ellipse(39.5, 98, 33, 22):clip(c:rect(0, 76, 79, 99))
-- scarf: arc + hanging tail
local scarf = c:line({ {26, 79}, {33, 83}, {40, 85}, {47, 83}, {54, 79} }, 6)
scarf:add(c:poly({ {45, 82}, {53, 82}, {52, 97}, {44, 95} }))
-- tail-feather tuft, sticking out left of the head
local tuft = c:poly({ {22, 36}, {3, 22}, {4, 30}, {9, 38}, {20, 46} })
-- head
local head = c:ellipse(40, 50, 24, 23)
-- cream belly/face patch
local patch = c:ellipse(40, 63, 15, 10):clip(head)
-- cap dome + knit brim + pom
local dome = c:ellipse(40, 35, 26, 23):cut(c:rect(0, 36, 79, 99))
local brim = c:rrect(14, 32, 66, 38, 3)
local pom = c:ellipse(40, 11, 5, 5)

local p = c:build{
  { "disc", c:ellipse(40, 50, 36), "moss", { solid = false, gloss = false } },
  { "body", body, brown },
  { "scarf", scarf, pink },
  { "tuft", tuft, dkbrown },
  { "head", head, brown },
  { "patch", patch, cream, { gloss = false } },
  { "dome", dome, pink, { stitch = { side = "lit" } } },
  { "brim", brim, berry, { gloss = false } },
  { "pom", pom, berry },
}

-- knit ribs on the brim
for x = 18, 63, 3 do c:px(x, 34, berry.shade); c:px(x, 35, berry.shade) end
c:seam({ {17, 38}, {63, 38} })
c:button(38, 18)

-- collar V
c:line({ {32, 79}, {40, 86} }, 1); c:line({ {48, 79}, {40, 86} }, 1)
for _, q in ipairs({ {32,79},{33,80},{34,81},{35,82},{36,83},{37,84},{38,85},{39,86},{40,86},{41,85},{42,84},{43,83},{44,82},{45,81},{46,80},{47,79},{48,79} }) do
  if p.body.m:has(q[1], q[2]) and not p.scarf.m:has(q[1], q[2]) then c:px(q[1], q[2], "#8c4a1a") end
end

-- stern brows
c:line({ {25, 39}, {32, 42} }, 2)
c:line({ {55, 39}, {48, 42} }, 2)
c:fill(c:line({ {25, 39}, {32, 42} }, 2):add(c:line({ {55, 39}, {48, 42} }, 2)), "#2a1a10")

-- eyes, set wide
c:eye(27, 44); c:eye(49, 44)

-- gold diamond beak between the eyes
c:paint({
  "....d....",
  "...ggd...",
  "..gggod..",
  ".ggggood.",
  "gggggooos",
  ".gggooos.",
  "..gooos..",
  "...oos...",
  "....s....",
}, 36, 48, { g = "#f5cf6a", d = "#fff1c8", o = "#e8a317", s = "#b8661a" })

-- little frown under the beak
c:paint({ ".uuu.", "u...u" }, 38, 59, { u = "#4a2c1a" })

local t = c:save(B .. "img-redraw-full/aseprite/ph/npc-wren-thimblewick.aseprite",
                 B .. "img-redraw-full/png/ph/npc-wren-thimblewick.png")
print(GV.report(t))
