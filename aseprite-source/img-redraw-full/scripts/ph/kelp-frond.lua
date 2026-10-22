local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- holdfast roots
local hold = c:line({ {31, 50}, {25, 53} }, 2)
hold:add(c:line({ {32, 50}, {32, 53} }, 2))
hold:add(c:line({ {33, 50}, {39, 53} }, 2))
hold:add(c:ellipse(32, 50, 3, 1.5))
-- stipe
local stipe = c:line({ {32, 51}, {31, 45}, {30, 40} }, 3)
-- blade: S-curved ribbon with ruffled scallops
local spine = { {31, 42}, {38, 39}, {44, 34}, {45, 29}, {41, 26}, {33, 24}, {24, 22}, {19, 19}, {19, 15}, {24, 13}, {30, 13} }
local blade = c:line(spine, 7)
local ruff = { {42, 39}, {48, 34}, {49, 28}, {38, 21}, {29, 20}, {16, 22}, {15, 16}, {20, 10}, {27, 28}, {37, 30}, {33, 10} }
for i, p in ipairs(ruff) do blade:add(c:ellipse(p[1], p[2], 1.5, 1.5)) end
blade:add(c:ellipse(31.5, 13, 3, 3))
blade:cut(c:rect(0, 0, 63, 9))

local p = c:build{
  { "hold",  hold,  GV.ramp("#8a4f2a"), { flat = true } },
  { "stipe", stipe, GV.ramp("#4a8a3e", { base = "#2f5a2a" }), { flat = true } },
  { "blade", blade, GV.ramp("#4a8a3e", { rim = "#6a9a3a", shade = "#2f5a2a" }), { gloss = { 21, 16 } } },
}
-- midrib
local rib = { {32, 41}, {38, 38}, {43, 33}, {43, 29}, {40, 27}, {33, 25}, {24, 23}, {20, 19}, {21, 15}, {25, 14} }
for i = 1, #rib - 1 do
  c:line({ rib[i], rib[i + 1] }, 1):clip(p.blade.m):each(function(x, y) c:px(x, y, "#2f5a2a") end)
end
-- bladders
local bl = GV.ramp("#a4b86a")
for _, q in ipairs({ { 35.5, 40.5 }, { 46.5, 30.5 }, { 18.5, 20.5 } }) do
  c:part(c:ellipse(q[1], q[2], 2, 2), bl, { flat = true })
  c:px(math.floor(q[1]) + 1, math.floor(q[2]) + 2, "#6a9a3a")
  c:px(math.floor(q[1]) + 2, math.floor(q[2]) + 1, "#6a9a3a")
  c:px(math.floor(q[1]) - 1, math.floor(q[2]) - 1, "#c8d77a")
end
-- water droplet
c:part(c:ellipse(47.5, 17.5, 2, 2.5):add(c:rect(47, 13, 48, 15)), "water", { flat = true })
c:px(47, 16, "#c8ecdc")

local t = c:save(B .. "img-redraw-full/aseprite/ph/kelp-frond.aseprite", B .. "img-redraw-full/png/ph/kelp-frond.png")
print(GV.report(t))
