local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- body (green dress), bleeds off bottom
local body = c:ellipse(39.5, 101, 34, 24)
-- bib with collar flaps
local bib = c:poly({ {27,82}, {53,82}, {57,100}, {23,100} })
bib:add(c:line({ {28,79}, {33,85} }, 2)); bib:add(c:line({ {52,79}, {47,85} }, 2))
local head = c:ellipse(39.5, 52, 22, 20)
local muzzle = c:ellipse(39.5, 65, 12, 10)
-- beret: flat low cap with a brim
local beret = c:ellipse(39.5, 39, 24, 13):cut(c:rect(0, 40, 79, 99))
beret:add(c:rrect(15, 36, 64, 42, 3))
local bud = c:ellipse(39.5, 25, 2.5, 2.5)

local p = c:build{
  { "body",   body,   GV.ramp("#58a03e"), { stitch = { side = "lit" } } },
  { "bib",    bib,    "cream" },
  { "head",   head,   GV.ramp("#8f7060") },
  { "muzzle", muzzle, GV.ramp("#e6d2ae") },
  { "beret",  beret,  GV.ramp("#d9667f"), { stitch = { side = "lit" } } },
  { "bud",    bud,    GV.ramp("#d9667f"), { flat = true } },
}

-- collar V shade in the dress neckline
c:paint({ "d......d", ".d....d.", "..d..d..", "...dd..." }, 36, 79, { d = "#2e5a2c" })

-- star nose: 8 rays 2 px wide from (40,62)
local cx, cy = 39.5, 62
local rays = c:mask()
for i = 0, 7 do
  local a = i * math.pi / 4
  local ex, ey = cx + math.cos(a) * 8, cy + math.sin(a) * 8
  rays:add(c:line({ {math.floor(cx), math.floor(cy)}, {math.floor(ex + 0.5), math.floor(ey + 0.5)} }, 2))
end
c:part(rays, GV.ramp("#ee8fb4"), { flat = true })
c:part(c:ellipse(39.5, 62, 3, 3), GV.ramp("#c94f6e"), { gloss = { 38, 60 } })

-- tiny mouth
c:paint({ "m........m", ".mm....mm.", "...mmmm..." }, 35, 71, { m = "umber" })

-- dark leaf on beret
c:part(c:poly({ {43,36}, {50,33}, {57,35}, {52,39}, {45,39} }), GV.ramp("#9c2a1e"), { flat = true })
c:px(48, 36, "#6b1b2c"); c:px(51, 36, "#6b1b2c")

-- small mole eyes
c:eye(30, 47, true); c:eye(48, 47, true)

c:button(38, 82)

local t = c:save(O .. "aseprite/ph/npc-tansy-fernsway.aseprite", O .. "png/ph/npc-tansy-fernsway.png")
print(GV.report(t))
