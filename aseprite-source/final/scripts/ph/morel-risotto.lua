local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bowl = c:ellipse(31.5, 28, 21, 21):cut(c:rect(0, 0, 63, 28))
bowl:add(c:rect(11, 29, 52, 30))
local lugs = c:rrect(6, 28, 13, 32, 1):add(c:rrect(50, 28, 57, 32, 1))
local rice = c:ellipse(31.5, 29, 18, 4.5)
local stemA = c:rrect(23, 24, 26, 31, 1)
local stemB = c:rrect(37, 25, 39, 31, 1)
-- pointed ovals: ellipse body + tapered tip
local function morel(cx, top, bot, rx)
  local midy = top + (bot - top) * 0.6
  local m = c:ellipse(cx, midy, rx, (bot - midy))
  m:add(c:poly({ { cx - rx + 1, midy }, { cx + 0.5, top }, { cx + 1.5, top }, { cx + rx + 1, midy } }))
  return m
end
local capA = morel(24.5, 9, 26, 6)
local capB = morel(38, 13, 27, 4.5)

local pale = GV.ramp("#e8d4a8")
local p = c:build{
  { "lugs", lugs, "stone", { flat = true } },
  { "bowl", bowl, GV.ramp("#8b8f96") },
  { "rice", rice, "cream" },
  { "stemA", stemA, pale, { flat = true } },
  { "stemB", stemB, pale, { flat = true } },
  { "capA", capA, GV.ramp("#7a4a1f"), { gloss = { 21, 15 } } },
  { "capB", capB, GV.ramp("#7a4a1f"), { gloss = { 35, 18 } } },
}
-- honeycomb pits
local function pits(m, ox)
  local inner = m:shrink(1)
  for y = 0, 63, 3 do
    local off = ((y // 3) % 2 == 0) and 0 or 2
    for x = ox + off - 12, 63, 4 do
      if inner:has(x, y) and inner:has(x + 1, y + 1) and inner:has(x + 1, y) and inner:has(x, y + 1) then
        local g = c:get(x, y)
        if g ~= "#ecc58a" then
          c:fill(c:rect(x, y, x + 1, y + 1), "#3d2a1c")
        end
      end
    end
  end
end
pits(c:mask():add(p.capA.m):cut(c:rect(20, 13, 23, 17)), 1)
pits(c:mask():add(p.capB.m):cut(c:rect(34, 16, 36, 20)), 0)
-- herb flecks
c:px(44, 29, "#7ab55c"); c:px(45, 29, "#4a8a3e")
c:px(18, 30, "#7ab55c"); c:px(19, 30, "#4a8a3e")
c:px(31, 31, "#7ab55c")
c:seam({ { 12, 36 }, { 51, 36 } })

local t = c:save(O .. "aseprite/ph/morel-risotto.aseprite", O .. "png/ph/morel-risotto.png")
print(GV.report(t))
