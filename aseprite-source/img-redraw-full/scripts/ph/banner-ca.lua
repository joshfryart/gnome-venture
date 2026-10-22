local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local W, H = 120, 40
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }
-- sky: hard bands, lighter at the top
c:bands(nil, { "#fbe7a8", "#f8dc8a", "#f5cf6a" }, { dir = "v" })
-- sun with inner ring
c:fill(c:ellipse(93.5, 10, 6, 6), "#f08a24")
c:fill(c:ellipse(93.5, 10, 4, 4), "#f6b85a")
c:fill(c:rect(91, 7, 92, 7), "#fde2a0")
-- ridge helper: mask under y = base + amp*sin
local function ridge(base, amp, freq, phase)
  local m = c:mask()
  for x = 0, W - 1 do
    local y0 = math.floor(base + amp * math.sin(x * freq + phase) + 0.5)
    for y = y0, H - 1 do m:set(x, y) end
  end
  return m
end
local far = ridge(20, 2.2, 0.075, 0.6)
c:fill(far, "#dcb06a")
c:fill(far:copy():cut(far:shift(0, 1)), "#c9945a")
local near = ridge(24.5, 1.8, 0.11, 2.4)
c:fill(near, "#e8a317")
c:fill(near:copy():cut(near:shift(0, 1)), "#b8661a")
c:fill(near:copy():cut(near:shift(0, 1)):shift(0, 1), "#f5cf6a")
-- field
local field = c:rect(0, 29, W - 1, H - 1)
c:fill(field, "#b0bc66")
c:fill(c:rect(0, 29, W - 1, 29), "#7ab55c")
c:fill(c:rect(0, 35, W - 1, 35), "#a4b86a")
local L = { s = "#4a8a3e", l = "#7ab55c", d = "#2f5a2a", c = "#f5cf6a", g = "#e8a317", o = "#7a3a14", h = "#c8d77a" }
-- back row: small stalks
local back = {
  "..h...",
  "l.s...",
  ".lsoo.",
  "..scgo",
  "..scgo",
  "..soo.",
  ".ds..l",
  "d.s.l.",
}
for i = 0, 9 do c:paint(back, 4 + i * 12, 25, L) end
-- front row: bigger stalks, offset, with a contact shadow on the field
local front = {
  "...h....",
  "...s....",
  "l..s....",
  ".l.s.oo.",
  "..lsocgo",
  "...socgo",
  "...socgo",
  "...s.oo.",
  "...s...l",
  ".d.s..l.",
  "..dss.l.",
}
for i = 0, 7 do
  local x = 6 + i * 17
  c:paint(front, x, 28, L)
  c:fill(c:rect(x + 2, 39, x + 5, 39), "#7a8a44")
end
-- hem stitch along top and bottom
c:seam({ {1, 1}, {W - 2, 1} }, { free = true })
c:seam({ {1, H - 2}, {W - 2, H - 2} }, { free = true })
local t = c:save(O .. "aseprite/ph/banner-ca.aseprite", O .. "png/ph/banner-ca.png")
print(GV.report(t))
