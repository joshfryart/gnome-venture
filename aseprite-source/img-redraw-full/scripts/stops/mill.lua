local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon" }
local hx, hy = 23.5, 17.5
local sails = c:mask()
local s2 = 0.7071
for _, d in ipairs{ {-1,-1}, {1,-1}, {1,1}, {-1,1} } do
  local dx, dy = d[1]*s2, d[2]*s2
  local px, py = -dy, dx
  local function P(t, o) return { math.floor(hx + dx*t + px*o + 0.5), math.floor(hy + dy*t + py*o + 0.5) } end
  sails:add(c:line({ P(0,0), P(13,0) }, 3))
  sails:add(c:poly({ P(4,0), P(14,0), P(14,5), P(5,5) }))
end
local tower = c:poly({ {21,17}, {27,17}, {32,39}, {16,39} })
local p = c:build{
  { "sails", sails, GV.ramp("#d9a660") },
  { "tower", tower, "wood" },
  { "cap", c:poly({ {17,19}, {24,9}, {31,19} }), GV.ramp("#8a4f2a") },
  { "hub", c:ellipse(23.5, 17.5, 2.5, 2.5), "gold", { flat = true } },
  { "door", c:rrect(21, 31, 26, 38, 2), GV.ramp("#5e2f1e"), { gloss = false } },
}
local t = c:save(O .. "aseprite/stops/mill.aseprite", O .. "png/stops/mill.png")
print(GV.report(t))
