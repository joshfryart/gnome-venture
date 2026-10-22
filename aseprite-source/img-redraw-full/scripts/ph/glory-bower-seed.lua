local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local seed = c:ellipse(31.5, 22, 9, 9)
local body = c:rrect(12, 29, 51, 56, 2)
local rim = c:rect(10, 24, 53, 30)
c:build{
  { "seed", seed, GV.ramp("#3f93b2", { shade = "#2f6290" }) },
  { "body", body, "wood" },
  { "postL", c:rect(12, 31, 16, 56), GV.ramp("#a8582f"), { gloss = false } },
  { "postR", c:rect(47, 31, 51, 56), GV.ramp("#a8582f"), { gloss = false } },
  { "rim", rim, GV.ramp("#d9a660") },
}
-- seam under rim and slat gaps
c:fill(c:rect(12, 31, 51, 31), "#5e2f1e")
c:fill(c:rect(17, 39, 46, 40), "#5e2f1e")
c:fill(c:rect(17, 47, 46, 48), "#5e2f1e")
-- sprout
c:fill(c:rect(32, 8, 33, 13), "#2e5a2a")
c:fill(c:ascii({ "..xxx", ".xxxx", "xxxx." }, 34, 6), "#58a03e")
c:px(37, 6, "#8cc85a")
-- nails
for _, q in ipairs({ { 13, 33 }, { 49, 33 }, { 13, 53 }, { 49, 53 } }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#2a1a10")
end

local t = c:save(O .. "aseprite/ph/glory-bower-seed.aseprite", O .. "png/ph/glory-bower-seed.png")
print(GV.report(t))
