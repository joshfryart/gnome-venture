local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crate = c:rect(10, 14, 54, 56)
local p = c:build{
  { "body",  c:rect(14, 15, 50, 55), "wood", { light = crate } },
  { "postL", c:rect(10, 12, 16, 57), GV.ramp("#8a4f2a"), { light = crate } },
  { "postR", c:rect(48, 12, 54, 57), GV.ramp("#8a4f2a"), { light = crate } },
}
-- slat grooves between three planks
c:fill(c:rect(17, 27, 47, 28), "#5e2f1e")
c:fill(c:rect(17, 42, 47, 43), "#5e2f1e")
-- grain flecks
c:fill(c:rect(19, 20, 23, 20), "#8a4f2a"); c:fill(c:rect(38, 34, 43, 34), "#8a4f2a")
c:fill(c:rect(20, 49, 25, 49), "#8a4f2a"); c:fill(c:rect(40, 50, 44, 50), "#8a4f2a")

local plaque = c:rrect(22, 23, 42, 49, 6)
c:part(plaque, GV.ramp("#b0bc66"), { gloss = false })
c:part(c:rrect(24, 25, 40, 47, 5), "cream", { gloss = false, contact = false })
c:part(c:ellipse(32, 39, 6.5, 6.5), GV.ramp("#b0bc66", { shade = "#58a03e" }))
c:part(c:rect(31, 28, 32, 33), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:ellipse(36, 29, 3, 2), GV.ramp("#58a03e"), { flat = true })

-- nails
for _, n in ipairs({ {12, 14}, {50, 14}, {12, 53}, {50, 53} }) do
  c:fill(c:rect(n[1], n[2], n[1] + 1, n[2] + 1), "#d9a660")
end

local t = c:save(O .. "aseprite/ph/cosmos-seed.aseprite", O .. "png/ph/cosmos-seed.png")
print(GV.report(t))
