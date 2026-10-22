local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local k, ox, oy = 0.78, 33, 37
local function X(x) return math.floor(ox + (x - 33) * k + 0.5) end
local function Y(y) return math.floor(oy + (y - 37) * k + 0.5) end
local function P(t) local r = {} for i, v in ipairs(t) do r[i] = { X(v[1]), Y(v[2]) } end return r end
local body = GV.ramp("#6f7f99")
local wing = c:mask()
local a = math.rad(-30)
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - X(30), y - Y(34)
  local u = dx * math.cos(a) + dy * math.sin(a)
  local v = -dx * math.sin(a) + dy * math.cos(a)
  if (u / (12.5 * k)) ^ 2 + (v / (7 * k)) ^ 2 <= 1 then wing:set(x, y) end
end end
local p = c:build{
  { "tail", c:poly(P{ {19, 33}, {7, 51}, {29, 47} }), body },
  { "body", c:ellipse(X(31), Y(39), 20 * k, 13 * k), body },
  { "head", c:ellipse(X(47), Y(25), 9 * k, 9 * k), body },
  { "beak", c:poly(P{ {54, 20}, {61, 25}, {54, 30} }), "gold", { gloss = false, flat = true } },
  { "wing", wing, GV.ramp("#f8eed2"), { contour = GV.C.umber } },
}
c:eye(X(47) - 2, Y(23) - 1, true)
local t = c:save(O .. "aseprite/ico/ico-dove.aseprite", O .. "png/ico/ico-dove.png")
print(GV.report(t))
