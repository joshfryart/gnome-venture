local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local function rell(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 99 do for x = 0, 79 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end

local wingR = GV.ramp("#e6f1ec")
local wUL = rell(15, 40, 10, 5, 25)
local wUR = rell(64, 40, 10, 5, -25)
local wLL = rell(15, 61, 10, 4.5, -15)
local wLR = rell(64, 61, 10, 4.5, 15)

local body = c:ellipse(39.5, 101, 33, 25)
local bib = c:poly({ {27, 82}, {53, 82}, {57, 100}, {23, 100} })
local head = c:ellipse(39.5, 54, 16, 18)
local hood = c:ellipse(39.5, 45, 24, 22):cut(c:rect(0, 60, 79, 99))
hood:cut(c:ellipse(39.5, 62, 13, 19))
local domeL = c:ellipse(26, 46, 10.5)
local domeR = c:ellipse(53, 46, 10.5)

local p = c:build{
  { "wUL", wUL, wingR }, { "wUR", wUR, wingR },
  { "wLL", wLL, wingR }, { "wLR", wLR, wingR },
  { "body", body, "wood", { stitch = { side = "lit" } } },
  { "bib", bib, "cream" },
  { "head", head, "water" },
  { "hood", hood, "petal" },
  { "domeL", domeL, "moss" },
  { "domeR", domeR, "moss" },
}

-- wing veins (only where wing still visible)
local front = c:mask():add(body):add(head):add(hood):add(domeL):add(domeR)
local veins = c:line({ {7, 37}, {22, 43} }, 1):add(c:line({ {72, 37}, {57, 43} }, 1))
veins:add(c:line({ {7, 62}, {22, 60} }, 1)):add(c:line({ {72, 62}, {57, 60} }, 1))
veins:clip(c:mask():add(wUL):add(wUR):add(wLL):add(wLR):shrink(1)):cut(front)
c:fill(veins, "#8fcbd8")


c:stitch(p.hood.m, { side = "lit" })
c:seam({ {22, 78}, {57, 78} })
c:button(38, 80)
c:eye(24, 45); c:eye(51, 45)
c:paint({ "u.........u", ".uuuuuuuuu." }, 34, 63, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-thistle-leafwhisker.aseprite", O .. "png/ph/npc-thistle-leafwhisker.png")
print(GV.report(t))
