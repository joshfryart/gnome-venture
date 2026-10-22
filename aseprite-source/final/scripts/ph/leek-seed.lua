local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc")
local jar = c:rrect(15, 21, 48, 56, 9)
local neck = c:rrect(23, 13, 40, 24, 2)
local cork = c:rrect(21, 6, 42, 15, 3)

-- diagonal pill seed, rotated -35 deg around (31.5, 40)
local function rot(cx, cy, w, h, a)
  local ca, sa = math.cos(a), math.sin(a)
  local pts = {}
  for _, q in ipairs({ {-w/2, -h/2}, {w/2, -h/2}, {w/2, h/2}, {-w/2, h/2} }) do
    pts[#pts + 1] = { cx + q[1] * ca - q[2] * sa, cy + q[1] * sa + q[2] * ca }
  end
  return pts
end
local a = math.rad(-35)
local seed = c:line({ {22, 47}, {39, 35} }, 8)
local tip = c:line({ {39, 35}, {43, 32} }, 7)

local p = c:build{
  { "jar", jar, glass },
  { "neck", neck, glass },
  { "cork", cork, GV.ramp("#d9a660", { shade = "#b07a45" }) },
  { "seed", seed, GV.ramp("#b0bc66") },
  { "tip", tip, GV.ramp("#2e5a2c") },
}
-- lower stripe along the pill
c:fill(c:line({ {23, 50}, {37, 40} }, 2), "#58a03e")
-- glass shine along the left
c:fill(c:rect(19, 29, 19, 46), "#fff3c8")
c:fill(c:rect(20, 27, 20, 28), "#fff3c8")
-- cork texture specks
c:px(27, 9, "#b07a45"); c:px(34, 11, "#b07a45"); c:px(38, 8, "#b07a45")
-- twine around the neck
c:seam({ {23, 21}, {40, 21} })
c:ground(31.5, 57, 14, 1.5)

local t = c:save(D .. "img-redraw-full/aseprite/ph/leek-seed.aseprite", D .. "img-redraw-full/png/ph/leek-seed.png")
print(GV.report(t))
