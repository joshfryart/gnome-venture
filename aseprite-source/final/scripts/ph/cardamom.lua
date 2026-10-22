local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered pod from (x0,y0) to (x1,y1), max width w; fattest at 55% along
local function pod(x0, y0, x1, y1, w)
  local m = c:mask()
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x + 0.5 - x0, y + 0.5 - y0
    local t = (px * ux + py * uy) / L
    local d = math.abs(-px * uy + py * ux)
    if t >= 0 and t <= 1 then
      local s = t < 0.55 and math.sin(t / 0.55 * math.pi / 2) or math.cos((t - 0.55) / 0.45 * math.pi / 2)
      local hw = (w / 2) * (0.25 + 0.75 * math.sqrt(math.max(s, 0)))
      if d <= hw then m:set(x, y) end
    end
  end end
  return m
end
local function ridge(x0, y0, x1, y1, off, a, b, col)
  local dx, dy = x1 - x0, y1 - y0
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  for i = math.floor(a * L), math.floor(b * L) do
    local t = i / L
    c:px(math.floor(x0 + dx * t + nx * off + 0.5), math.floor(y0 + dy * t + ny * off + 0.5), col)
  end
end

local S = { 14, 47 }
local A = { 44, 12 }   -- back pod, steep
local B = { 55, 28 }   -- middle pod
local Cc = { 53, 47 }  -- front pod, near flat
local pa = pod(S[1], S[2], A[1], A[2], 11)
local pb = pod(S[1], S[2], B[1], B[2], 12)
local pc = pod(S[1], S[2], Cc[1], Cc[2], 12)

local p = c:build{
  { "back",  pa, GV.ramp("#a4b86a"), { gloss = { 27, 27 } } },
  { "mid",   pb, GV.ramp("#b6c474") },
  { "front", pc, GV.ramp("#7ab55c") },
}
local rc = "#4a8a3e"
ridge(S[1], S[2], A[1], A[2], -1.5, 0.3, 0.85, rc); ridge(S[1], S[2], A[1], A[2], 2, 0.3, 0.85, rc)
ridge(S[1], S[2], B[1], B[2], -1.5, 0.35, 0.85, rc); ridge(S[1], S[2], B[1], B[2], 2, 0.35, 0.85, rc)
ridge(S[1], S[2], Cc[1], Cc[2], -1.5, 0.35, 0.85, rc); ridge(S[1], S[2], Cc[1], Cc[2], 2, 0.35, 0.85, rc)
-- pod tips
c:paint({ "ttt", "ttt" }, A[1] - 2, A[2] + 1, { t = rc })
c:paint({ "tt", "tt", "tt" }, B[1] - 3, B[2] - 1, { t = rc })
c:paint({ "tt", "tt", "tt" }, Cc[1] - 3, Cc[2] - 1, { t = rc })
-- stem knot and stalk
c:part(c:line({ {12, 50}, {8, 55} }, 2), GV.ramp("#5e2f1e"), { flat = true })
c:part(c:rrect(10, 45, 15, 50, 1), GV.ramp("#5e2f1e"), { gloss = false })

local t = c:save(O .. "aseprite/ph/cardamom.aseprite", O .. "png/ph/cardamom.png")
print(GV.report(t))
