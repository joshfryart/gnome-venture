-- ph/cheese-wheel (Pantry dairy): tall gold-waxed wheel with a wedge cut out showing cream cheese, red wax cord, goat stamp on top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "cheese-wheel"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wax = GV.ramp("#e8a317", { shade = "#b07a10", deep = "#7a4a10", bounce = "#c88a20" })
local face = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b07a10", rim = "#fbe08a", gloss = "#fff1c8", dot = "#fbf6e8", pale = false })
local inner = GV.ramp("#f4f0e0", { shade = "#e8d890", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
local CX, CY, RX, RY, H = 32, 27, 24, 8, 19
local A = math.rad(65)   -- wedge removed between angle 0 (right) and A (toward the front)
local function inWedge(x, y)
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  if dx <= 0 or dy < 0 then return false end
  return math.atan(dy, dx) <= A
end
local topE = c:ellipse(CX, CY, RX, RY)
local px, py = CX + RX * math.cos(A), CY + RY * math.sin(A)   -- front end of the cut on the rim
-- cut face (the radius plane toward the right), seen behind the front wall
local cut = c:rect(CX, CY, CX + RX, CY + H)
-- front wall that still stands: left of the cut line
local wall = c:rect(CX - RX, CY, math.floor(px), CY + H):add(c:ellipse(CX, CY + H, RX, RY):clip(c:rect(0, CY + H, math.floor(px), 63)))
local top = c:mask()
topE:each(function(x, y) if not inWedge(x, y) then top:set(x, y) end end)
cut:cut(wall):cut(top)
c:part(cut, inner, { gloss = false, contact = false })
for _, p in ipairs({ {44, 33}, {50, 39}, {45, 41}, {52, 31}, {48, 35} }) do c:paint({ "hh", "hs" }, p[1], p[2], { h = "#e8d890", s = "#c9b878" }) end
wall:cut(top)
c:part(wall, wax, { gloss = { 13, 37 } })
-- side face of the cut nearest us: thin cream strip down the cut line
c:part(c:rect(math.floor(px) - 1, math.floor(py), math.floor(px), CY + H + 5):clip(wall), inner, { flat = true, contact = false })
c:part(top, face, { gloss = { 17, 23 } })
-- red wax cord round the front wall
local cord = c:mask()
for x = CX - RX, math.floor(px) - 2 do
  local t = (x - CX) / RX
  local y = math.floor(CY + 11 + RY * math.sqrt(math.max(0, 1 - t * t)) * 0.9)
  cord:add(c:rect(x, y, x, y + 1))
end
c:part(cord:clip(wall), "red", { flat = true, contact = false, contour = false })
-- goat stamp on the top face
c:paint({
  "k.....k",
  ".k...k.",
  ".kkkkk.",
  "kkkkkkk",
  "..kkk..",
  "..kkk..",
  "...k...",
}, 19, 21, { k = "#b07a10" })
c:px(16, 21, "#fbf6e8")
c:ground(32, 55, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
