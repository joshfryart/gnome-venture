local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon", bleed = "lr" }
-- spiky holly mass: an oval with leaf-point spikes around it
local function holly(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  for a = 0, 330, 30 do
    local r = math.rad(a)
    local px, py = cx + math.cos(r) * (rx + 3), cy - math.sin(r) * (ry + 3)
    local bx, by = cx + math.cos(r + 0.25) * (rx - 1), cy - math.sin(r + 0.25) * (ry - 1)
    local qx, qy = cx + math.cos(r - 0.25) * (rx - 1), cy - math.sin(r - 0.25) * (ry - 1)
    m:add(c:poly({ {bx, by}, {px, py}, {qx, qy} }))
  end
  return m
end
local pick = c:mask()
for i = 0, 5 do
  local x = 19 + i * 5
  pick:add(c:rect(x, 22, x + 3, 45))
end
local hL = holly(4, 30, 11, 14):cut(c:rect(0, 46, 63, 63))
local hR = holly(59, 30, 11, 14):cut(c:rect(0, 46, 63, 63))
local p = c:build{
  { "ground", c:rect(0, 44, 63, 49), "soil" },
  { "rails", c:rect(17, 27, 47, 30):add(c:rect(17, 37, 47, 40)), "#c4925f", { gloss = false } },
  { "pickets", pick, "#dcb06a" },
  { "brace", c:line({ {20, 39}, {44, 29} }, 2), "#b07a45", { flat = true } },
  { "hedgeL", hL, "#58a03e" },
  { "hedgeR", hR, "#58a03e" },
  { "lobeL", holly(7, 34, 5, 6), "#2e5a2c", { gloss = false, rim = false } },
  { "lobeR", holly(57, 34, 5, 6), "#2e5a2c", { gloss = false, rim = false } },
}
local berry = { "rr", "rd" }
local leg = { r = "#d6322b", d = "#ae2a2a" }
for _, b in ipairs({ {3, 24}, {10, 42}, {13, 24}, {55, 23}, {60, 42}, {50, 26} }) do
  c:paint(berry, b[1], b[2], leg)
end
local t = c:save(B .. "img-redraw-full/aseprite/ph/holly-hedge-gate.aseprite", B .. "img-redraw-full/png/ph/holly-hedge-gate.png")
print(GV.report(t))
