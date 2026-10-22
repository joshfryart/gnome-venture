local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local CX, CY = 31.5, 32.5
local R = GV.ramp("#e46a9b")

-- pointed lens petal: u along axis (0 = petal centre), half length L, half width HW
local function petal(ang)
  local m = c:mask()
  local dx, dy = math.sin(ang), -math.cos(ang)
  local DIST, L, HW = 11.5, 11, 5
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x - CX, y - CY
    local a = px * dx + py * dy          -- along
    local b = -px * dy + py * dx         -- across
    local u = (a - DIST) / L
    if u >= -1 and u <= 1 then
      local w
      if u < 0 then w = HW * math.sqrt(1 - u * u) else w = HW * (1 - u ^ 1.6) end
      if math.abs(b) <= w then m:set(x, y) end
    end
  end end
  return m
end

local petals = c:mask()
local angs = {}
for i = 0, 4 do
  angs[i + 1] = math.rad(i * 72)
  petals:add(petal(angs[i + 1]))
end
c:part(petals, R, { gloss = false })

-- crease: 2 px darker line down the inner half of each petal
for _, a in ipairs(angs) do
  local dx, dy = math.sin(a), -math.cos(a)
  local pts = { { math.floor(CX + dx * 7 + 0.5), math.floor(CY + dy * 7 + 0.5) },
                { math.floor(CX + dx * 14 + 0.5), math.floor(CY + dy * 14 + 0.5) } }
  c:fill(c:line(pts, 2):clip(petals), R.shade)
end
-- highlight: 1x3 dash near each tip, on the lit side of the petal axis
for _, a in ipairs(angs) do
  local dx, dy = math.sin(a), -math.cos(a)
  local ox, oy = -dy * -2, dx * -2
  if (ox + oy) > 0 then ox, oy = -ox, -oy end
  for k = 15, 17 do
    local x = math.floor(CX + dx * k + ox + 0.5)
    local y = math.floor(CY + dy * k + oy + 0.5)
    if petals:has(x, y) then c:px(x, y, "#f6b8cf") end
  end
end

c:part(c:ellipse(CX, CY, 6, 6), GV.ramp("#f5cf6a", { rim = "#e8a317" }), { gloss = false })
c:paint({ "gg", "gg" }, 29, 30, { g = "#fff1c8" })

local t = c:save(D .. "img-redraw-full/aseprite/flowers/star.aseprite", D .. "img-redraw-full/png/flowers/star.png")
print(GV.report(t))
