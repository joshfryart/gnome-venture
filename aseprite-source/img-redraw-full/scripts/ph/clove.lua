local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered stalk: 4 px wide at the bottom, 3 px at the top
local function stalk(x0, y0, x1, y1)
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  return c:poly({
    { x0 - nx * 2.2, y0 - ny * 2.2 }, { x1 - nx * 1.6, y1 - ny * 1.6 },
    { x1 + nx * 1.6, y1 + ny * 1.6 }, { x0 + nx * 2.2, y0 + ny * 2.2 },
  })
end

-- sepal crown: a flared cup with two pointed tips under each ball
local function crown(cx, cy, w)
  return c:poly({
    { cx - w, cy - 2 }, { cx - w + 2, cy + 1 }, { cx, cy + 5 },
    { cx + w - 2, cy + 1 }, { cx + w, cy - 2 }, { cx + w - 2, cy + 3 },
    { cx, cy + 6 }, { cx - w + 2, cy + 3 },
  }):add(c:poly({ { cx - w + 1, cy - 1 }, { cx + w, cy - 1 }, { cx + 2, cy + 6 }, { cx - 1, cy + 6 } }))
end

local sL = stalk(31.5, 56, 17, 27)
local sR = stalk(32.5, 56, 47, 27)
local sM = stalk(32, 56, 32, 21)
local cL, cR, cM = crown(16.5, 23, 6), crown(47.5, 23, 6), crown(32, 17, 7)
local hL = c:ellipse(16.5, 18.5, 4.5, 4.5)
local hR = c:ellipse(47.5, 18.5, 4.5, 4.5)
local hM = c:ellipse(32, 11.5, 5.5, 5.5)

local dark = GV.ramp("#5e2f1e")
local mid = GV.ramp("#8a4f2a")
local bud = GV.ramp("#b07a45")
c:build{
  { "sL", sL, dark, { flat = true } },
  { "sR", sR, dark, { flat = true } },
  { "sM", sM, mid, { gloss = false } },
  { "cL", cL, mid, { gloss = false } },
  { "cR", cR, mid, { gloss = false } },
  { "cM", cM, mid, { gloss = false } },
  { "hL", hL, bud },
  { "hR", hR, bud },
  { "hM", hM, bud },
}

-- four-point cross on each bud
local function cross(x, y)
  c:paint({ ".d.", "d.d", ".d." }, x - 1, y - 1, { d = "#5e2f1e" })
end
cross(17, 19); cross(48, 19); cross(33, 12)

local t = c:save(O .. "aseprite/ph/clove.aseprite", O .. "png/ph/clove.png")
print(GV.report(t))
