local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local PX, PY = 32, 36
-- frond: oval of half-width hw, length L, from pivot along angle (deg from up, + = right)
local function frond(deg, hw, L)
  local a = math.rad(deg)
  local dx, dy = math.sin(a), -math.cos(a)
  local cx, cy = PX + dx * L / 2, PY + dy * L / 2
  local pts = {}
  for i = 0, 31 do
    local t = i / 32 * 2 * math.pi
    local u, v = math.cos(t) * L / 2, math.sin(t) * hw
    pts[#pts + 1] = { cx + u * dx - v * dy, cy + u * dy + v * dx }
  end
  local kx, ky = PX + dx * (L - 4), PY + dy * (L - 4)
  local m = c:poly(pts); m:add(c:ellipse(kx, ky, 5, 5))
  return m, kx, ky
end
local function curl(x, y, deg, flip)
  local pts = {}
  for i = 0, 18 do
    local t = i / 18
    local a = math.rad(deg) + (flip and -1 or 1) * t * 1.6 * 2 * math.pi
    local r = 3.6 * (1 - t) + 0.4
    pts[#pts + 1] = { math.floor(x + r * math.cos(a) + 0.5), math.floor(y + r * math.sin(a) + 0.5) }
  end
  return c:line(pts, 1)
end

local stem = c:rrect(30, 36, 34, 55, 1)
local oL, oLx, oLy = frond(-66, 3.5, 23)
local oR, oRx, oRy = frond(66, 3.5, 23)
local mL, mLx, mLy = frond(-33, 3.5, 25)
local mR, mRx, mRy = frond(33, 3.5, 25)
local cC, cCx, cCy = frond(0, 3.5, 27)
local hub = c:ellipse(32, 36, 4.5, 4.5)

local leaf = "moss"
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { gloss = false } },
  { "oL", oL, leaf, { gloss = false } },
  { "oR", oR, leaf, { gloss = false } },
  { "mL", mL, leaf, { gloss = false } },
  { "mR", mR, leaf, { gloss = false } },
  { "cC", cC, GV.ramp("#4a8a3e"), { gloss = { 30, 9 } } },
  { "hub", hub, GV.ramp("#d9a660"), { gloss = false } },
}
local dk = "#2f5a2a"
local tips = { { oLx, oLy, -68, p.oL.m, true }, { oRx, oRy, 68, p.oR.m }, { mLx, mLy, -34, p.mL.m, true },
               { mRx, mRy, 34, p.mR.m }, { cCx, cCy, 0, p.cC.m } }
for _, tp in ipairs(tips) do
  local m = curl(tp[1], tp[2], tp[3], tp[5]); m:clip(tp[4]); c:fill(m, tp[3] == 0 and "#24461f" or dk)
end
-- curl on the hub
c:paint({ ".dd.", "d..d", "d.d.", ".d.." }, 30, 34, { d = "#8a4f2a" })
c:px(30, 33, GV.R.wood.gloss)
c:seam({ { 30, 46 }, { 34, 46 } })
c:ground(32, 56, 9, 1.5)

local t = c:save(O .. "aseprite/ph/fiddleheads.aseprite", O .. "png/ph/fiddleheads.png")
print(GV.report(t))
