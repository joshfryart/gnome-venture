local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
-- 120x30 half grid, written 2x -> 240x60
local c = GV.canvas{ w = 120, h = 30, mode = "sticker", out = 2, ol = 1, olx = 1, cx = 30, cy = 15 }

-- leaf polygon: pivot, angle from vertical, length, half width, curl (bend of the tip to the right)
local function leaf(px, py, a, L, hw, curl)
  local r = math.rad(a)
  local pts = {}
  local N = 26
  for i = 0, N - 1 do
    local t = i / N * 2 * math.pi
    local f = (1 - math.cos(t)) / 2
    local u = f * L
    local w = math.sin(t) * hw * math.sin(math.pi * math.min(1, f * 1.15))
    local ax = math.sin(r) * u + curl * f * f
    local ay = -math.cos(r) * u
    pts[#pts + 1] = { px + ax + w * math.cos(r) + 0.5, py + ay + w * math.sin(r) + 0.5 }
  end
  return c:poly(pts)
end

-- mushroom
local cap = c:ellipse(17.5, 16, 12, 9):cut(c:rect(0, 16, 119, 29))
cap:add(c:rrect(6, 13, 29, 17, 2))
local stem = c:rrect(13, 16, 21, 22, 2)
-- leaf
local lf = leaf(38, 22, 4, 16, 6.5, -4)
local lstem = c:line({ { 38, 20 }, { 39, 23 } }, 2)

local p = c:build{
  { "stem",  stem, GV.ramp("#f1ece0"), { cres = 2, deep = 1 } },
  { "cap",   cap, "red", { cres = 2, deep = 1, gloss = { 10, 9 } } },
  { "lstem", lstem, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  lf, "#6a9a3a", { cres = 2, deep = 1, gloss = { 35, 12 } } },
  { "berry", c:ellipse(45, 9, 1.5, 1.5), "gold", { flat = true } },
}
c:spot(c:ellipse(13, 12.5, 1.5, 1), "#fff3c8")
c:spot(c:ellipse(21, 10, 1.5, 1), "#fff3c8")
c:spot(c:ellipse(26, 14, 1, 1), "#fff3c8")
-- leaf midrib
c:fill(c:line({ { 38, 20 }, { 38, 15 }, { 37, 10 } }, 1), "#4a8a3e")
c:seam({ { 7, 17 }, { 28, 17 } }, { on = 2, off = 1 })

-- wordmark "Gnome Venture", ink #5e2f1e, caps y 11..17, lowercase y 13..17
local G = {
  G = { ".###.", "#...#", "#....", "#..##", "#...#", "#...#", ".###." },
  V = { "##.##", "#...#", "#...#", "#...#", ".#.#.", ".#.#.", "..#.." },
  n = { "###.", "#..#", "#..#", "#..#", "#..#" },
  o = { ".##.", "#..#", "#..#", "#..#", ".##." },
  m = { "##.#.", "#.#.#", "#.#.#", "#.#.#", "#.#.#" },
  e = { ".##.", "#..#", "####", "#...", ".###" },
  t = { ".#.", "###", ".#.", ".#.", ".#.", ".##" },
  u = { "#..#", "#..#", "#..#", "#..#", ".###" },
  r = { "#.#", "##.", "#..", "#..", "#.." },
}
local x = 50
for ch in ("Gnome Venture"):gmatch(".") do
  if ch == " " then x = x + 3 else
    local g = G[ch]
    c:paint(g, x, 18 - #g, { ["#"] = "#5e2f1e" })
    x = x + #g[1] + 1
  end
end
-- hem stitch under the wordmark
c:seam({ { 50, 20 }, { 111, 20 } }, { on = 2, off = 1, free = true })

c:ground(17, 23, 10, 1, "#5e2f1e")
c:ground(38, 23, 8, 1, "#2f5a2a")
local t = c:save(D .. "img-redraw-full/aseprite/ph/logo.aseprite", D .. "img-redraw-full/png/ph/logo.png")
print(GV.report(t))
