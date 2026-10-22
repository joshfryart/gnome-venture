local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local post = GV.ramp("#5e2f1e")
local p = c:build{
  { "band", c:rrect(18, 25, 55, 38, 2), "wood" },
  { "post", c:ellipse(17, 31.5, 8, 8.5), post },
}
-- weave: dark slashes and light withies across the band
local dark = c:mask()
for _, x in ipairs({ 30, 39, 48 }) do dark:add(c:line({ { x, 26 }, { x + 4, 37 } }, 2)) end
c:fill(dark:clip(p.band.m), "#5e2f1e")
local lite = c:mask()
for _, x in ipairs({ 34, 43, 52 }) do lite:add(c:line({ { x, 27 }, { x + 2, 33 } }, 1)) end
c:fill(lite:clip(p.band.m), "#ecc58a")
-- horizontal withy split
c:seam({ { 26, 31 }, { 54, 31 } }, { gap = "#8a4f2a" })
-- end-grain rings on the post face
c:fill(c:ellipse(16, 31, 5, 5.5):edge(), "#8a4f2a")
c:fill(c:ellipse(16, 31, 2, 2), "#b07a45")
c:px(15, 30, "#d9a660")
c:ground(36, 41, 20, 1.5)

local t = c:save(O .. "aseprite/ph/wattle-fence-end.aseprite", O .. "png/ph/wattle-fence-end.png")
print(GV.report(t))
