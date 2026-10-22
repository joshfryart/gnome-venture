local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- six curling tentacles (back), left three curl left, right three curl right
local t = c:mask()
t:add(c:line({ {19,38}, {14,43}, {11,47}, {11,51}, {14,52} }, 4))
t:add(c:line({ {24,41}, {21,46}, {19,50}, {20,53}, {23,52} }, 4))
t:add(c:line({ {29,42}, {28,47}, {27,51}, {29,53} }, 4))
t:add(c:line({ {34,42}, {35,47}, {36,51}, {34,53} }, 4))
t:add(c:line({ {39,41}, {42,46}, {44,50}, {43,53}, {40,52} }, 4))
t:add(c:line({ {44,38}, {49,43}, {52,47}, {52,51}, {49,52} }, 4))

-- domed mantle + lower mantle as one felt body
local body = c:ellipse(31.5, 26, 15.5, 14.5)
body:add(c:ellipse(31.5, 38, 13, 5.5))

local purple = GV.ramp("#7a5cc0")
c:build{
  { "tentacles", t, GV.ramp("#4e3a8a"), { gloss = false } },
  { "head", body, purple, { stitch = { side = "lit" } } },
}

-- pale lilac sheen dots on the dome
for _, d in ipairs({ {22,18}, {27,14}, {35,14}, {40,19} }) do
  c:paint({ ".l.", "lll", ".l." }, d[1] - 1, d[2] - 1, { l = "#c3b2ea" })
end

-- sucker dots under the tentacle tips
for _, s in ipairs({ {12,49}, {20,50}, {28,50}, {35,50}, {43,50}, {51,49} }) do
  c:px(s[1], s[2], "#3e2f66")
end

-- wide glassy eyes
c:eye(23, 27); c:eye(36, 27)
c:paint({ "u...u", ".uuu." }, 29, 34, { u = "#3e2f66" })

local r = c:save(O .. "aseprite/ph/creature-deep-octopus.aseprite", O .. "png/ph/creature-deep-octopus.png")
print(GV.report(r))
