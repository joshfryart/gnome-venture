-- ph/pickled-lotus-root (Pantry pickle): low wide jar, red lacquer lid with a gold stripe and knob, cream lotus slices with rings of holes
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-lotus-root"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(10, 26, 54, 56, 8), "glass" },
  { "brine", c:rrect(12, 31, 52, 54, 6), "#f8ecd0", { contour = "#c9a878", gloss = false } },
}
-- lotus slices: cream discs with a ring of 6 holes and a centre hole
local lotus = GV.ramp("#f5e0c0", { shade = "#d8b890", deep = "#a8885a" })
local function slice(x, y, r)
  c:part(c:ellipse(x, y, r, r), lotus, { cres = 2, deep = 1, gloss = false, contact = false, contour = "#8a5a2a" })
  local k = r * 0.55
  for i = 0, 5 do
    local a = i * math.pi / 3 + 0.3
    local hx, hy = math.floor(x + k * math.cos(a) + 0.5), math.floor(y + k * math.sin(a) + 0.5)
    c:fill(c:rect(hx, hy, hx + 1, hy + 1), "#c9a878"); c:px(hx, hy, "#a8885a")
  end
  c:fill(c:rect(x, y, x + 1, y + 1), "#c9a878")
end
slice(21, 40, 7); slice(43, 40, 7); slice(32, 39, 7)
-- painted emblem on the glass: one big slice with 7 holes
c:part(c:ellipse(32, 48.5, 6.5, 5.5), "cream", { gloss = false, contact = false, contour = "#8a5a2a" })
c:paint({
  "..h.h..",
  ".h...h.",
  "h..h..h",
  ".h...h.",
}, 29, 46, { h = "#a8885a" })
-- red lacquer lid with a gold stripe and a knob
c:part(c:rrect(9, 16, 55, 27, 4), "#a8241f", { contour = "#6b1b2c", gloss = { 13, 18 } })
c:fill(c:rect(14, 18, 34, 18), "#d6322b")
c:fill(c:rect(10, 22, 54, 23), "#e8a317"); c:fill(c:rect(10, 22, 30, 22), "#f5cf6a")
c:part(c:ellipse(32, 14, 4, 2.5), "#a8241f", { flat = true, contour = "#6b1b2c" })
c:px(30, 13, "#ff9158")
c:gloss(c:rrect(10, 26, 54, 56, 8), "glass", { 13, 31 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
