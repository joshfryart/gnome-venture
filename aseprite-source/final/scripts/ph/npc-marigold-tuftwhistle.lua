-- ph/npc-marigold-tuftwhistle : hedgehog bust, sunburst quills
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local R = GV.R

local cx, cy = 39.5, 52
local function spike(deg, r, hw, r0)
  local a = math.rad(deg)
  local function pt(ang, rad, sx) return { cx + rad * sx * math.cos(ang), cy - rad * math.sin(ang) } end
  return c:poly({ pt(a - math.rad(hw), r0, 1), pt(a, r, 0.86), pt(a + math.rad(hw), r0, 1) })
end

-- dark quills (behind), between the light ones
local dark = c:mask()
for i = 0, 8 do dark:add(spike(-14 + i * 26, 40, 9, 16)) end
-- light quills + solid base
local light = c:ellipse(39.5, 54, 21, 19)
for i = 0, 8 do light:add(spike(-27 + i * 26, 35, 9, 16)) end
light:cut(c:rect(0, 74, 79, 99))
dark:cut(c:rect(0, 74, 79, 99))

local body = c:ellipse(39.5, 104, 35, 30):clip(c:rect(0, 74, 79, 99))
local collar = c:poly({ {28, 74}, {40, 89}, {52, 74} })
local face = c:ellipse(39.5, 58, 17, 15):add(c:ellipse(39.5, 52, 18, 7))
local nose = c:ellipse(39.5, 62, 3, 2)
local cap = c:ellipse(39.5, 42, 22, 15):cut(c:ellipse(39.5, 60, 18, 22))
for _, x in ipairs({ 29, 39, 49 }) do
  cap:add(c:poly({ {x - 3, 38}, {x + 0.5, 43}, {x + 4, 38} }))
end

c:build{
  { "qdark",  dark,   GV.ramp("#5e2f1e"), { gloss = false } },
  { "qlight", light,  GV.ramp("#8c4a1a") },
  { "body",   body,   "red" },
  { "collar", collar, "cream", { gloss = false } },
  { "face",   face,   "cream" },
  { "cap",    cap,    "wood" },
}
c:fill(nose, "#3d2a1c"); c:fill(c:rect(38, 63, 41, 63), "#2a1a10")

c:seam({ {29, 76}, {40, 88}, {51, 76} })
c:button(38, 75)
c:eye(30, 48); c:eye(45, 48)
c:paint({ "u.....u", ".uu.uu.", "...u..." }, 36, 65, { u = "umber" })
c:px(38, 61, "#8a6a5a")

local t = c:save(O .. "aseprite/ph/npc-marigold-tuftwhistle.aseprite", O .. "png/ph/npc-marigold-tuftwhistle.png")
print(GV.report(t))
