local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 120, h = 40, mode = "scene", out = 2, ol = 1, olx = 1 }
local W, H = 119, 39
c:fill(c:rect(0, 0, W, H), "#b0bc66")
c:bands(c:rect(0, 0, W, 12), { "#8fcbd8", "#a9d6ea", "#c2e2ee" }, { dir = "v" })
c:fill(c:rect(0, 12, W, 14), "#c4c97e")
local xs = { 14, 45, 77, 108 }
local trunkR = GV.ramp("#8c4a1a")
local canR = GV.ramp("#2e5a2c")
for i, x in ipairs(xs) do
  c:part(c:rect(x - 2, 10, x + 1, H), trunkR, { gloss = false, cres = 1 })
  -- small side branch
  c:part(c:line({ {x + 1, 20}, {x + 4, 17} }, 2), trunkR, { flat = true })
end
for i, x in ipairs(xs) do
  local can = c:ellipse(x - 0.5, 9, 13, 6.5):add(c:ellipse(x - 7.5, 12, 5, 3.5)):add(c:ellipse(x + 7.5, 12, 5, 3.5))
  c:part(can, canR, { gloss = false, cres = 3, deep = 1 })
  c:fill(c:ellipse(x - 4.5, 7, 6, 2.5):clip(can:shrink(1)), "#58a03e")
  c:fill(c:ellipse(x - 6.5, 6, 2.5, 1):clip(can:shrink(1)), "#7ab55c")
  c:px(x - 7, 5, "#c8d77a")
  -- hanging vine
  c:fill(c:line({ {x + 3, 14}, {x + 4, 18}, {x + 3, 22}, {x + 4, 25} }, 1), "#7ab55c")
  c:px(x + 4, 26, "#c8d77a")
end
local ground = c:rect(0, 35, W, H)
for bx = 0, 120, 20 do ground:add(c:ellipse(bx + 10, 35, 10, 2)) end
c:part(ground, GV.ramp("#58a03e"), { gloss = false, cres = 2, deep = 1 })
for bx = 0, 120, 20 do c:fill(c:ellipse(bx + 8, 34, 5, 0.6):clip(ground), "#7ab55c") end
for _, f in ipairs({ { 30, 32, "#e46a9b" }, { 60, 33, "#e8a317" }, { 94, 32, "#d6322b" } }) do
  c:fill(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), f[3])
  c:px(f[1], f[2], "#fff1c8")
  c:fill(c:rect(f[1], f[2] + 2, f[1], 34), "#4a8a3e")
end
-- corner vignette
local vig = c:ellipse(0, 0, 5, 3):add(c:ellipse(W, 0, 5, 3)):add(c:ellipse(0, H, 5, 3)):add(c:ellipse(W, H, 5, 3))
c:fill(vig, "#17361c")
c:seam({ {0, 1}, {W, 1} }, { free = true })
c:seam({ {0, H - 1}, {W, H - 1} }, { free = true })
local t = c:save(O .. "aseprite/ph/banner-wca.aseprite", O .. "png/ph/banner-wca.png")
print(GV.report(t))
