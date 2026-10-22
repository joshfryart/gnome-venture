local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- legs (behind)
c:limb({ {14, 48}, {12, 53} })
c:limb({ {22, 49}, {20, 54} })
c:limb({ {31, 49}, {33, 54} })
c:limb({ {38, 48}, {41, 53} })
-- shell: long low dome, flat underside
local shell = c:ellipse(27, 44, 18, 14):cut(c:rect(0, 49, 63, 63))
shell:add(c:rrect(10, 44, 44, 49, 3))
-- head
local head = c:ellipse(47.5, 44, 5.5, 5.5)
local p = c:build{
  { "antA", c:line({ {50, 40}, {53, 36}, {56, 34} }, 2), "stone", { flat = true } },
  { "antB", c:line({ {52, 46}, {56, 47} }, 2), "stone", { flat = true } },
  { "head", head, GV.ramp("#8b8f96") },
  { "shell", shell, GV.ramp("#5b6470") },
}
-- segment bands (curved vertical plates)
local bands = c:mask()
for _, x in ipairs({ 15, 21, 27, 33, 39 }) do
  local b = (x < 27) and -1 or ((x > 27) and 1 or 0)
  bands:add(c:line({ {x + b, 31}, {x, 40}, {x + b, 49} }, 1))
end
bands:clip(shell:shrink(1))
c:fill(bands, "#3a4250")
-- plate lighting: lit highlight arc
local arc = c:mask()
for x = 11, 43 do
  local dx = (x - 27) / 18
  local y = math.floor(44 - 12 * math.sqrt(math.max(0, 1 - dx * dx)) + 0.5)
  arc:set(x, y)
end
arc:clip(shell:shrink(1)):cut(bands)
c:fill(arc, "#8f7fc9")
c:gloss(shell, GV.ramp("#5b6470"), { 16, 35 })
-- seam on middle band
c:seam({ {28, 33}, {27, 40}, {28, 47} })
-- eye
c:eye(47, 41, true)
c:ground(28, 54, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-shale-slater.aseprite", O .. "png/ph/creature-shale-slater.png")
print(GV.report(t))
