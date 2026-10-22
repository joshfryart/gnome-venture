local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local skin = GV.ramp("#8f7060")
local gill = GV.ramp("#3f93b2")
local legc = GV.ramp("#5e2f1e")

-- wavy tapered body: circles along an S path, tail tip at left
local body = c:mask()
local function cy(x) return 36.5 + 2.4 * math.sin((x - 10) * math.pi / 15) end
for x = 10, 40 do
  local t = (x - 10) / 22
  if t > 1 then t = 1 end
  local r = 1.2 + 3.8 * t
  body:add(c:ellipse(x, cy(x), r, r))
end
-- neck rising into the head
body:add(c:ellipse(39.5, 33, 4.5, 4.5))

-- legs (behind body), slanting down
local legs = c:line({ {17, 38}, {15, 43} }, 2)
legs:add(c:line({ {26, 38}, {24, 43} }, 2))
legs:add(c:line({ {35, 37}, {37, 43} }, 2))
legs:add(c:rect(13, 43, 16, 44)); legs:add(c:rect(22, 43, 25, 44)); legs:add(c:rect(37, 43, 40, 44))

-- feathery gills behind the head
local g = c:line({ {46, 23}, {49, 15} }, 3)
g:add(c:line({ {48, 25}, {52, 19} }, 3))
g:add(c:line({ {49, 28}, {52, 26} }, 2))

local head = c:ellipse(44, 29, 6, 6)

local p = c:build{
  { "legs", legs, legc, { flat = true } },
  { "gills", g, gill, { flat = true } },
  { "body", body, skin },
  { "head", head, skin, { contour = false, contact = false } },
}

-- pale aqua sheen along the back ridge
local sheen = c:mask()
for x = 13, 40 do
  local t = (x - 10) / 22; if t > 1 then t = 1 end
  local r = 1.2 + 3.8 * t
  local y = math.floor(cy(x) - r + 1.5)
  if x < 39 then sheen:set(x, y) end
end
sheen:clip(p.body.m)
sheen:cut(head)
c:fill(sheen, "#b8d8d2")

c:eye(44, 26, true)
c:paint({ "uu.", "..u" }, 46, 31, { u = "#4a2c1a" })
c:ground(29, 45, 14, 1.5)

local t = c:save(O .. "aseprite/ph/creature-cistern-newt.aseprite", O .. "png/ph/creature-cistern-newt.png")
print(GV.report(t))
