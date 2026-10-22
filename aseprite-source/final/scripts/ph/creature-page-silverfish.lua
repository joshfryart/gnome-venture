local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tick = "#a38f80"

-- legs and antennae (behind the body)
c:limb({ {22, 41}, {20, 46} })
c:limb({ {31, 42}, {30, 47} })
c:limb({ {40, 42}, {41, 47} })
c:limb({ {47, 31}, {49, 25}, {52, 22} })
-- cerci at the tail
local cerci = c:line({ {16, 38}, {11, 33} }, 2):add(c:line({ {16, 40}, {11, 45} }, 2))

-- body: tapering wedge, thick at the head end
local body = c:poly({ {14, 38}, {22, 34}, {30, 31}, {40, 29}, {47, 29},
                      {47, 45}, {40, 45}, {30, 44}, {22, 42}, {14, 41} })
local head = c:ellipse(47.5, 37, 5, 6.5)
-- paper page tilted on the back
local page = c:poly({ {25, 22}, {37, 19}, {40, 31}, {28, 34} })

local p = c:build{
  { "cerci", cerci, GV.ramp(tick), { flat = true } },
  { "body",  body,  GV.ramp("#e6d2ae"), { light = body:copy():add(head) } },
  { "head",  head,  GV.ramp("#e6d2ae") },
  { "page",  page,  GV.ramp("#f8eed2"), { gloss = { 27, 24 } } },
}

-- segment ticks across the body (inside, below the page)
local inner = p.body.m:shrink(1):cut(page:grow(1))
for _, x in ipairs({ 21, 28, 35 }) do
  for y = 0, 63 do if inner:has(x, y) then c:px(x, y, tick) end end
end
-- ink lines on the page (tilted with it)
c:line({ {28, 25}, {35, 23} }, 1):clip(page:shrink(2)):each(function(x, y) c:px(x, y, tick) end)
c:line({ {29, 28}, {36, 26} }, 1):clip(page:shrink(2)):each(function(x, y) c:px(x, y, tick) end)
c:line({ {30, 31}, {34, 30} }, 1):clip(page:shrink(2)):each(function(x, y) c:px(x, y, tick) end)

c:eye(46, 33)
c:ground(31, 48.5, 16, 1.5)

local t = c:save(D .. "test100/aseprite/ph/creature-page-silverfish.aseprite",
                 D .. "test100/png/ph/creature-page-silverfish.png")
print(GV.report(t))
