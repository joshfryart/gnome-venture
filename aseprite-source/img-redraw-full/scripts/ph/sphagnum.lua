local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local hx, hy = 31.5, 33
-- rotated ellipse as polygon; angle in degrees from straight up, clockwise
local function frond(deg, dist, rx, ry)
  local a = math.rad(deg)
  local ux, uy = math.sin(a), -math.cos(a)      -- along frond
  local vx, vy = -uy, ux                         -- across
  local cx, cy = hx + ux * dist, hy + uy * dist
  local pts = {}
  for i = 0, 31 do
    local t = i / 32 * 2 * math.pi
    local s, k = math.cos(t) * ry, math.sin(t) * rx
    pts[#pts + 1] = { math.floor(cx + ux * s + vx * k + 0.5), math.floor(cy + uy * s + vy * k + 0.5) }
  end
  local tip = { cx + ux * (ry - 1.5), cy + uy * (ry - 1.5) }
  return c:poly(pts), tip
end

local stalk = c:rrect(30, 38, 33, 56, 1)
local fl, tl = frond(-68, 11, 4, 9)
local fr, tr = frond(68, 11, 4, 9)
local fl2, tl2 = frond(-34, 12, 4.5, 10)
local fr2, tr2 = frond(34, 12, 4.5, 10)
local fc, tc = frond(0, 12, 5, 11)
local bud = c:ellipse(31.5, 33, 5, 5)

local p = c:build{
  { "stalk", stalk, "moss", { flat = true } },
  { "fl",  fl,  "moss" },
  { "fr",  fr,  "moss" },
  { "fl2", fl2, "moss", { gloss = false } },
  { "fr2", fr2, "moss", { gloss = false } },
  { "fc",  fc,  GV.ramp("#6a9a3a"), { gloss = false } },
  { "bud", bud, "gold", { gloss = { 29, 30 } } },
}
-- pale frond tips
for _, f in ipairs({ { fl, tl }, { fr, tr }, { fl2, tl2 }, { fr2, tr2 }, { fc, tc } }) do
  local tipm = c:ellipse(f[2][1], f[2][2], 2, 2):clip(f[1]:shrink(1))
  c:fill(tipm, "#c8d77a")
end
c:gloss(p.fl2.m, GV.R.moss, { 24, 22 })

local t = c:save(D .. "img-redraw-full/aseprite/ph/sphagnum.aseprite",
                 D .. "img-redraw-full/png/ph/sphagnum.png")
print(GV.report(t))
