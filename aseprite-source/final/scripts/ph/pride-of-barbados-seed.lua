local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local packet = c:rrect(14, 12, 50, 52, 2)
local flap = c:rrect(14, 12, 50, 22, 3)
flap:add(c:ellipse(32, 22, 18, 5):clip(c:rect(14, 0, 50, 63)))
local cx, cy = 32, 41
local back, front = c:mask(), c:mask()
for i = 0, 4 do
  local a = math.rad(-90 + 72 * i)
  local m = c:ellipse(cx + 6 * math.cos(a), cy + 6 * math.sin(a), 5, 5)
  if i == 2 or i == 3 then back:add(m) else front:add(m) end
end
local p = c:build{
  { "packet", packet, "cream" },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "petalsB", back, GV.ramp("#e0501f"), { gloss = false } },
  { "petalsF", front, GV.ramp("#f08a24") },
  { "centre", c:ellipse(32, 41, 2.5, 2.5), "gold", { flat = true } },
}
local st = "#d6322b"
c:fill(c:line({ {30, 39}, {24, 37}, {19, 32} }, 1), st)
c:fill(c:line({ {32, 38}, {31, 32}, {29, 28} }, 1), st)
c:fill(c:line({ {34, 39}, {40, 37}, {45, 32} }, 1), st)
c:paint({ "tt", "tt" }, 18, 30, { t = "#7a3a14" })
c:paint({ "tt", "tt" }, 28, 26, { t = "#7a3a14" })
c:paint({ "tt", "tt" }, 45, 30, { t = "#7a3a14" })
c:seam({ {16, 22}, {20, 24}, {26, 26}, {32, 27}, {38, 26}, {44, 24}, {48, 22} })
c:button(30, 17)
local t = c:save(O .. "aseprite/ph/pride-of-barbados-seed.aseprite", O .. "png/ph/pride-of-barbados-seed.png")
print(GV.report(t))
