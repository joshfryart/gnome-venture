local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local NX, NY = 32, 39
-- curved pod: a slightly bent lens shape along angle a (deg from vertical)
local function pod(a, d, len, w, bend)
  local r = math.rad(a)
  local ux, uy = math.sin(r), -math.cos(r)   -- along pod
  local vx, vy = -uy, ux                      -- across
  local cx, cy = NX + ux * d, NY + uy * d
  local L, R = {}, {}
  for i = 0, 16 do
    local t = -1 + i / 8
    local half = w * math.sqrt(math.max(0, 1 - t * t)) ^ 0.8
    local off = bend * (1 - t * t)
    local px, py = cx + ux * t * len, cy + uy * t * len
    L[#L+1] = { px + vx * (off - half), py + vy * (off - half) }
    R[#R+1] = { px + vx * (off + half), py + vy * (off + half) }
  end
  local pts = {}
  for i = 1, #L do pts[#pts+1] = L[i] end
  for i = #R, 1, -1 do pts[#pts+1] = R[i] end
  return c:poly(pts), function(t)
    local off = bend * (1 - t * t)
    return math.floor(cx + ux * t * len + vx * off + 0.5), math.floor(cy + uy * t * len + vy * off + 0.5)
  end
end
local fl, fbL = pod(-56, 15, 12, 3.6, 1.5)
local fr, fbR = pod(56, 15, 12, 3.6, -1.5)
local l, bL = pod(-28, 16, 12, 3.8, 1)
local r, bR = pod(28, 16, 12, 3.8, -1)
local m, bM = pod(0, 16, 13, 4.3, 0)
local all = fl:copy():add(fr):add(l):add(r):add(m)
local p = c:build{
  { "stem", c:line({ {32,55}, {32,40} }, 3), "#4a8a3e", { flat = true } },
  { "fl", fl, "#d9a660", { light = all } },
  { "fr", fr, "#d9a660", { light = all } },
  { "l",  l,  "#e0b870", { light = all } },
  { "r",  r,  "#e0b870", { light = all } },
  { "m",  m,  "#ecc58a", { light = all } },
  { "node", c:ellipse(32, 39, 5, 4.5), "#7ab55c" },
}
for _, f in ipairs({ fbL, fbR, bL, bR, bM }) do
  for _, t in ipairs({ 0.55, 0.05, -0.45 }) do
    local x, y = f(t); c:px(x, y, "#a8582f")
  end
end
c:seam({ {28, 39}, {37, 39} })
local t = c:save(O .. "aseprite/ph/mesquite-pods.aseprite", O .. "png/ph/mesquite-pods.png")
print(GV.report(t))
