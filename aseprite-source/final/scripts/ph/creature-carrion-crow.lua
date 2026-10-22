local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted ellipse mask
local function tel(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u * u) / (rx * rx) + (v * v) / (ry * ry) <= 1 then m:set(x, y) end
  end end
  return m
end

local legs = c:line({ {26, 50}, {26, 56} }, 2):add(c:line({ {37, 50}, {37, 56} }, 2))
legs:add(c:rect(24, 56, 27, 57)):add(c:rect(36, 56, 39, 57))
local body = c:ellipse(31.5, 37, 15, 15)
-- ragged head tuft for a sinister silhouette
body:add(c:poly({ {27, 24}, {29, 17}, {32, 23} })):add(c:poly({ {31, 23}, {35, 18}, {36, 24} }))
local chest = c:ellipse(31.5, 46, 7.5, 6)
local wl = tel(17.5, 40, 4.5, 10, 14)
local wr = tel(45.5, 40, 4.5, 10, -14)
local beak = c:poly({ {27, 32}, {37, 32}, {32, 40} })

local whole = body:copy():add(wl):add(wr)
c:build{
  { "legs",  legs,  "gold", { flat = true } },
  { "body",  body,  GV.ramp("#30233a"), { light = whole } },
  { "chest", chest, GV.ramp("#8f7060"), { light = whole } },
  { "wingl", wl,    GV.ramp("#2c2142") },
  { "wingr", wr,    GV.ramp("#2c2142"), { gloss = false } },
  { "beak",  beak,  GV.ramp("#d4c4ae"), { gloss = { 29, 33 } } },
}
-- feather chevrons on chest
c:paint({ "d...d", ".d.d.", "..d.." }, 27, 44, { d = "#6e5248" })
c:paint({ "d...d", ".d.d.", "..d.." }, 31, 48, { d = "#6e5248" })
-- beak split line
c:px(32, 35, "#7d6a5e"); c:px(32, 36, "#7d6a5e")
c:eye(24, 26); c:eye(35, 26)
c:ground(31.5, 57.5, 11, 1.5)
local t = c:save(O .. "aseprite/ph/creature-carrion-crow.aseprite", O .. "png/ph/creature-carrion-crow.png")
print(GV.report(t))
