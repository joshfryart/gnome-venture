local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan = GV.ramp("#dcb06a")
local brown = GV.ramp("#a5663a")

-- shell spiral
local shellC = { 61, 51 }
local coat = c:ellipse(40, 104, 35, 28):cut(c:rect(0, 0, 79, 76))
local stalkL = c:line({ {27, 52}, {19, 40}, {15, 30} }, 3)
local stalkR = c:line({ {52, 52}, {61, 40}, {64, 30} }, 3)
local cone = c:poly({ {23, 47}, {46, 10}, {50, 10}, {59, 47} })
local p = c:build{
  { "back",  c:ellipse(39.5, 50, 36, 36), GV.ramp("#b0bc66"), { gloss = false } },
  { "shell", c:ellipse(shellC[1], shellC[2], 15, 15), brown },
  { "coat",  coat, brown, { stitch = { side = "lit" } } },
  { "scarf", c:line({ {22, 78}, {30, 83}, {40, 84}, {50, 78} }, 3):add(c:rect(43, 81, 46, 94)), "#d6322b", { flat = true } },
  { "head",  c:ellipse(35.5, 61, 17, 16), tan },
  { "muzzle",c:ellipse(35.5, 68, 10, 6), GV.ramp("#f8eed2"), { gloss = false } },
  { "stalkL", stalkL, tan, { flat = true } },
  { "stalkR", stalkR, tan, { flat = true } },
  { "eyeL",  c:ellipse(15, 27, 4.5, 4.5), "cream", { gloss = false } },
  { "eyeR",  c:ellipse(64, 27, 4.5, 4.5), "cream", { gloss = false } },
  { "hat",   cone, GV.ramp("#d6322b") },
  { "brim",  c:ellipse(41, 47, 22, 4), GV.ramp("#9c2a1e"), { gloss = false } },
  { "nub",   c:ellipse(48, 9, 2.5, 2.5), GV.ramp("#d6322b"), { flat = true } },
}
-- spiral on shell (visible right of head / under brim)
local pts = {}
for i = 0, 60 do
  local t = i / 60
  local a = t * 2.5 * 2 * math.pi + 0.6
  local r = 1.5 + t * 11
  pts[#pts + 1] = { math.floor(shellC[1] + r * math.cos(a) + 0.5), math.floor(shellC[2] + r * math.sin(a) + 0.5) }
end
local sp = c:line(pts, 2):clip(c:ellipse(shellC[1], shellC[2], 13, 13))
for _, k in ipairs{"coat","scarf","head","muzzle","stalkR","eyeR","hat","brim"} do sp:cut(p[k].m) end
c:fill(sp, "#2a1a10")
-- re-cover spiral where front parts sit
-- (spiral is clipped to shell; front parts drawn earlier would be overpainted, so mask them)
c:seam({ {21, 47}, {61, 47} })
c:button(33, 81)
c:eye(13, 25); c:eye(62, 25)
c:paint({ "u.......u", ".uuuuuuu." }, 31, 69, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-clover-thornwhistle.aseprite", O .. "png/ph/npc-clover-thornwhistle.png")
print(GV.report(t))
