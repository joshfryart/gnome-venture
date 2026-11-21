-- harvest-spark.lua : gold twinkle at the basket as the count lands (harvest-art-spec group 5).
-- Strip 64x16 = 4 frames of 16x16: dot, small 4-point star, large 4-point star with 1 px
-- rim, fade crumbs. Gold family #e8a317 / #f5cf6a / #fff3c4; star shape = chest .cs-spark
-- (concave 4-point, drawn as an astroid). Scene mode: hand-placed pixels, no black border.
local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/extras-pixel/"
local F, N = 16, 4
local c = GV.canvas{ w = F * N, h = F, mode = "scene" }
local RIM, BODY, CORE, LOW = "#e8a317", "#f5cf6a", "#fff3c4", "#d0862a"

local function inStar(dx, dy, r) return math.sqrt(math.abs(dx)) + math.sqrt(math.abs(dy)) <= math.sqrt(r) + 0.01 end
-- star centred on pixel (ox+7, 7): rim on the outer pixel, core inside radius rc, lower-right tips warmer
local function star(ox, r, rc)
  local cx, cy = ox + 7, 7
  for y = 0, F - 1 do for x = ox, ox + F - 1 do
    local dx, dy = x - cx, y - cy
    if inStar(dx, dy, r) then
      local edge = not (inStar(dx + 1, dy, r) and inStar(dx - 1, dy, r) and inStar(dx, dy + 1, r) and inStar(dx, dy - 1, r))
      local col = BODY
      if edge then col = (dx + dy > 0) and LOW or RIM end
      if inStar(dx, dy, rc) then col = CORE end
      c:px(x, y, col)
    end
  end end
end

-- 1: dot
c:paint({ ".b.", "bcb", ".b." }, 6, 6, { b = BODY, c = CORE })
-- 2: small star
star(16, 3.2, 0.9)
-- 3: large star, 1 px rim
star(32, 6.2, 1.6)
-- 4: fade crumbs flung out on the diagonals and arms
local ox = 48
c:paint({ "bl" }, ox + 2, 3, { b = BODY, l = RIM })
c:paint({ "b", "l" }, ox + 12, 2, { b = BODY, l = RIM })
c:paint({ "lb" }, ox + 12, 12, { b = BODY, l = RIM })
c:px(ox + 3, 12, RIM); c:px(ox + 7, 7, CORE)

local t = c:save(nil, O .. "png/harvest-spark.png")
local strip = c:image()
local spr = Sprite(F, F, ColorMode.RGB)
for i = 1, N do
  if i > 1 then spr:newEmptyFrame(i) end
  local img = Image(F, F, ColorMode.RGB)
  img:drawImage(strip, Point(-(i - 1) * F, 0))
  spr:newCel(spr.layers[1], i, img, Point(0, 0))
  spr.frames[i].duration = 0.08
end
spr:saveAs(O .. "aseprite/harvest-spark.aseprite")
spr:close()
print("harvest-spark " .. GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.w == 64 and t.h == 16)
