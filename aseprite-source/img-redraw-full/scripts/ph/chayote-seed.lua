local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { rim = "#e6f7ef" })
local seed = c:mask()
local a = math.rad(35); local ca, sa = math.cos(a), math.sin(a)
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - 31.5, y - 38.5
  local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
  local uu = math.max(0, math.abs(u) - 7)
  if (uu / 5.2) ^ 2 + (v / 5.2) ^ 2 <= 1 then seed:set(x, y) end
end end
local p = c:build{
  { "jar",  c:rrect(16, 22, 48, 54, 8), glass },
  { "neck", c:rect(22, 15, 42, 23), glass, { gloss = false } },
  { "lip",  c:rrect(20, 17, 44, 21, 1), GV.ramp("#8fcbd8"), { gloss = false } },
  { "cork", c:rrect(24, 7, 40, 16, 2), "wood" },
  { "seed", seed, GV.ramp("#f08a24", { shade = "#e0501f" }) },
}
c:fill(c:rect(43, 46, 45, 48), "#4a8a3e"); c:px(43, 46, "#7ab55c")
c:paint({ "gg..g", "....." , ".g.gg" }, 28, 10, { g = "#8a4f2a" })
c:fill(c:rect(20, 27, 21, 37), "#f4fbf7")
c:seam({ {22, 19}, {42, 19} })
local t = c:save(O .. "aseprite/ph/chayote-seed.aseprite", O .. "png/ph/chayote-seed.png")
print(GV.report(t))
