local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- spike rings around head centre
local hx, hy = 40, 54
local function ring(n, a0, a1, rb, rt, hw, offset)
  local m = c:mask()
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * (i + offset) / (n - 1))
    local w = math.rad(hw)
    local p1 = { hx + rb * math.cos(a - w), hy - rb * math.sin(a - w) }
    local p2 = { hx + rt * math.cos(a), hy - rt * math.sin(a) }
    local p3 = { hx + rb * math.cos(a + w), hy - rb * math.sin(a + w) }
    m:add(c:poly({ { hx, hy }, p1, p2, p3 }))
  end
  return m
end
local dark = ring(11, 195, -15, 19, 31, 11, 0)
local light = ring(10, 195, -15, 19, 28, 10, 0.5)

local vest = c:ellipse(40, 100, 32, 26):cut(c:rect(0, 100, 79, 120))
local head = c:ellipse(hx, hy, 22, 20)
local face = c:ellipse(40, 58, 16, 13)
face:add(c:poly({ { 26, 52 }, { 36, 45 }, { 40, 41 }, { 44, 45 }, { 55, 52 }, { 40, 60 } }))
face:add(c:ellipse(40, 51, 13, 6))

c:build{
  { "back",  c:ellipse(40, 50, 33), GV.ramp("#c3b2ea"), { gloss = false } },
  { "vest",  vest, "gold" },
  { "dark",  dark, GV.ramp("#44281c"), { gloss = false } },
  { "light", light, GV.ramp("#8c4a1a"), { gloss = false } },
  { "head",  head, GV.ramp("#8c4a1a"), { gloss = false } },
  { "face",  face, GV.ramp("#f8eed2") },
}

-- vest collar V and seam, buttons
c:fill(c:poly({ { 30, 76 }, { 40, 87 }, { 51, 76 } }), "#b07a10")
c:seam({ { 40, 88 }, { 40, 99 } })
c:button(38, 88); c:button(38, 94)

-- face
c:eye(30, 50); c:eye(46, 50)
local nose = c:ellipse(40, 63, 4, 3)
c:fill(nose, "#2a1a10")
c:px(38, 61, "#7b66b4")
c:paint({ "u.....u", ".uuuuu." }, 37, 68, { u = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/npc-juniper-kettleby.aseprite", O .. "png/ph/npc-juniper-kettleby.png")
print(GV.report(t))
