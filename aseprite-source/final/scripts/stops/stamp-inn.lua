local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local disc = c:ellipse(31.5, 31.5, 24.5, 24.5)
local roof = c:poly({ {18, 32}, {32, 18}, {46, 32} })
local chim = c:rect(37, 17, 41, 25)
local body = c:rect(22, 31, 41, 44)

c:build{
  { "disc", disc, GV.ramp("#f5cf6a"), { gloss = { 15, 16 } } },
  { "chim", chim, GV.ramp("#8a4f2a"), { flat = true } },
  { "body", body, "wood", { gloss = false } },
  { "roof", roof, GV.ramp("#a8582f"), { gloss = { 28, 23 } } },
}

-- dashed outer ring (r 22.5..24.5), 2 on / 1 off by angle
local cx, cy = 31.5, 31.5
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - cx, y - cy
  local d = math.sqrt(dx * dx + dy * dy)
  if d >= 20.4 and d < 22.6 then
    local a = math.atan(dy, dx)
    local seg = math.floor((a + math.pi) / (2 * math.pi) * 36)
    if seg % 3 ~= 2 then c:px(x, y, "#b8661a") end
  elseif d >= 17.8 and d < 18.8 and not (body:has(x, y) or roof:has(x, y) or chim:has(x, y)) and y < 45 then
    c:px(x, y, "#d0862a")
  end
end end

-- door
c:fill(c:rect(29, 36, 34, 44), "#5e2f1e")
c:px(33, 40, "#e8a317")
-- windows
c:fill(c:rect(24, 34, 27, 37), "#fff1c8")
c:fill(c:rect(36, 34, 39, 37), "#fff1c8")
c:px(25, 34, "#f5cf6a"); c:px(37, 34, "#f5cf6a")
-- ground line
c:fill(c:rect(20, 45, 43, 46), "#8a4f2a")

local t = c:save(B .. "img-redraw-full/aseprite/stops/stamp-inn.aseprite", B .. "img-redraw-full/png/stops/stamp-inn.png")
print(GV.report(t))
