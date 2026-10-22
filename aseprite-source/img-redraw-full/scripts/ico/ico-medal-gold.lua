local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- scalloped sunburst disc: base circle plus 12 bumps
local disc = c:ellipse(32, 40, 14)
for i = 0, 11 do
  local a = i * math.pi / 6
  disc:add(c:ellipse(32 + math.cos(a) * 14, 40 + math.sin(a) * 14, 2.5))
end
local star = c:poly({ {32,32},{34,37},{39,37},{35,40},{37,46},{32,42},{27,46},{29,40},{25,37},{30,37} })
local p = c:build{
  { "rl", c:poly({ {19,9},{30,9},{37,30},{26,30} }), "red" },
  { "rr", c:poly({ {45,9},{34,9},{27,30},{38,30} }), GV.ramp("#3f93b2") },
  { "disc", disc, "gold", { gloss = { 22, 31 } } },
  { "inner", c:ellipse(32, 40, 8.5), GV.ramp("#b8893f", { shade = "#b8661a", rim = "#f5cf6a" }), { gloss = false } },
  { "star", star, "gold", { flat = true } },
}
c:paint({ ".g.", "ggg", ".g." }, 20, 31, { g = "#fff1c8" })
local t = c:save(O .. "aseprite/ico/ico-medal-gold.aseprite", O .. "png/ico/ico-medal-gold.png")
print(GV.report(t))
