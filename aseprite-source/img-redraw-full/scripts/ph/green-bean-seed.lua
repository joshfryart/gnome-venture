local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- bean pod, behind the frayed mouth
local bean = c:line({ {29, 25}, {30, 19}, {34, 12}, {40, 8}, {45, 7} }, 5)
-- frayed flared top
local top = c:poly({ {19,13},{24,18},{28,12},{32,18},{36,12},{40,18},{45,13},{40,26},{24,26} })
-- body: lumpy sack with cinched neck
local body = c:ellipse(31.5, 43, 17, 13.5)
body:add(c:ellipse(24, 47, 10, 9)):add(c:ellipse(39, 46, 10, 10))
body:add(c:poly({ {25,27},{39,27},{46,36},{17,36} }))
local p = c:build{
  { "bean", bean, "moss", { gloss = {31, 15} } },
  { "top", top, "#b07a45" },
  { "body", body, "#c9a96e", { stitch = false } },
  { "patch", c:rrect(24, 38, 37, 48, 1), "#a8582f", { flat = false, gloss = false } },
  { "twine", c:rect(23, 25, 40, 28), "#7a4a1f", { gloss = false } },
}
-- bean pod seam and tip
c:paint({ "..d", ".d.", "d.." }, 34, 12, { d = "#4a8a3e" }); c:px(38,10,"#4a8a3e"); c:px(40,9,"#4a8a3e")
c:px(32, 16, "#4a8a3e"); c:px(32, 17, "#4a8a3e")
c:paint({ "tt", ".t" }, 46, 7, { t = "#2f5a2a" })
-- knot and tails
c:part(c:ellipse(38.5, 26.5, 2.5, 2.5), "#7a4a1f", { flat = true })
c:part(c:line({ {37, 29}, {35, 34} }, 2), "#7a4a1f", { flat = true })
c:part(c:line({ {40, 29}, {42, 33} }, 2), "#7a4a1f", { flat = true })
-- patch weave
for x = 26, 35, 3 do c:px(x, 41, "#8a4f2a"); c:px(x + 1, 45, "#8a4f2a") end
-- burlap weave flecks
for _, f in ipairs({ {20, 40}, {43, 39}, {41, 51} }) do
  c:px(f[1], f[2], "#a8582f"); c:px(f[1], f[2] + 1, "#a8582f")
end
c:seam({ {48, 36}, {45, 53} })
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/green-bean-seed.aseprite", O .. "png/ph/green-bean-seed.png")
print(GV.report(t))
