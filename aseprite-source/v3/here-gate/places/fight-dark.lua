-- fight-dark: moonlit cave ruin battle stage (480x270). Ground band y>=180, centre third clear.
local K = dofile("/home/user/gnome-venture/aseprite-source/v3/here-gate/places/_fight-kit.lua")
local W, H, INK = K.W, K.H, K.INK
local GY = 180

-- cave back wall
local WALL = {"#151426","#1d1c34","#272744","#333457","#43466c","#585e86"}
local wall = K.rect(0, 0, W-1, GY + 4)
K.shade(wall, WALL, { rim = false, fn = function(x, y, v)
  return 0.42 + (K.fbm(x, y*1.6, 22, 11) - 0.5)*0.8 - math.abs(x - 240)/240*0.15 end })
K.clumps(wall, 18, 13, WALL[1], 0.5)

-- opening to the night sky (upper centre-right)
local hole = K.blob(282, 58, 70, 40, 21, 0.25)
K.cut(hole, K.rect(0, 0, W-1, 18))
local SKY = {"#16244a","#1d3060","#27407a","#335492"}
K.each(hole, function(x, y)
  local i = math.floor((y - 18)/80*4 + (K.noise(x, y, 20, 23) - 0.5)*0.4) + 1
  if i < 1 then i = 1 elseif i > 4 then i = 4 end
  K.set(x, y, SKY[i])
  if K.hash(x, y, 25) < 0.012 then K.set(x, y, "#c8d8f0") end
end)
for _, s in ipairs{{250, 40}, {312, 34}, {280, 70}} do
  K.set(s[1], s[2], "#eef4fa") K.set(s[1]-1, s[2], "#8fb0dc") K.set(s[1]+1, s[2], "#8fb0dc") K.set(s[1], s[2]-1, "#8fb0dc") K.set(s[1], s[2]+1, "#8fb0dc")
end
-- moonlit rim of the opening (moon is out of frame, upper left)
local ring = {}
K.each(hole, function(x, y) for _, d in ipairs{{-1,0},{1,0},{0,-1},{0,1},{-2,0},{0,2}} do
  local nx, ny = x + d[1], y + d[2] if not K.has(hole, nx, ny) and ny >= 0 then ring[ny*W+nx+1] = true end end end)
K.each(ring, function(x, y) K.set(x, y, (x > 282) and "#9ec4e6" or "#5a7aa8") end)
K.outline(hole, "#0f1630")

-- moonbeam falling to the ground (cold light)
local beam = K.poly{{232, 30}, {318, 30}, {372, GY + 70}, {214, GY + 70}}
K.tint(beam, "#a9d4f0", 0.18)
K.tint(K.poly{{256, 30}, {300, 30}, {340, GY + 70}, {238, GY + 70}}, "#a9d4f0", 0.14)

-- ceiling + stalactites
local CEIL = {"#100f1e","#1a1830","#26243f","#353655","#4a4e72"}
local ceil = K.terrain(function(x) return 0 end, 0)
K.add(ceil, K.terrain(function(x) return 0 end, 1))
K.add(ceil, K.filter(K.rect(0, 0, W-1, 40), function(x, y) return y < 10 + K.noise(x, 0, 18, 31)*16 end))
for i = 0, 25 do
  local x = 6 + i*18 + math.floor(K.hash(i, 0, 33)*10)
  local len = 18 + math.floor(K.hash(i, 1, 33)*46)
  if x > 210 and x < 360 then len = math.floor(len*0.5) end
  local w = 5 + math.floor(K.hash(i, 2, 33)*6)
  K.add(ceil, K.poly{{x - w, 10}, {x + w, 10}, {x + 2, 10 + len*0.7}, {x, 10 + len}, {x - 2, 10 + len*0.6}})
end
K.shade(ceil, CEIL, { base = 0.5, lx = 0.4, ly = 0.6, nz = 0.5, sc = 4, sx = 2, sy = 0.4, seed = 35,
  fn = function(x, y, v) if x > 240 and x < 380 and y > 14 then return v + 0.15 end return v end })
K.outline(ceil, INK)

-- ruins: broken columns + arch fragment
local STONE = {"#2a2640","#3f3a58","#575372","#73718e","#9496ae","#b8c0d2"}
local function column(x0, x1, top, jag)
  local m = K.rect(x0, top, x1, GY + 6)
  K.cut(m, K.filter(K.rect(x0, top, x1, top + 10), function(x, y) return y - top < K.noise(x, 0, 3, jag)*10 end))
  K.add(m, K.rect(x0 - 4, GY - 2, x1 + 4, GY + 8))
  return m
end
local cols = { column(28, 52, 70, 1), column(94, 114, 118, 2), column(388, 410, 92, 3), column(440, 466, 52, 4) }
local arch = K.poly{{20, 52}, {120, 46}, {124, 60}, {84, 62}, {60, 64}, {24, 66}}
for j, m in ipairs(cols) do
  K.shade(m, STONE, { base = 0.5, lx = 1.1, ly = 0.2, nz = 0.3, sc = 6, seed = 40 + j })
  local x0, y0, x1 = K.bbox(m)
  K.each(m, function(x, y)
    if (y - y0) % 16 == 15 and y < GY - 2 then K.set(x, y, STONE[1]) end
    if (x - x0) % 6 == 5 and x < x1 - 4 and x > x0 + 4 and y < GY - 2 then K.set(x, y, STONE[2]) end
  end)
  K.outline(m, INK)
end
K.shade(arch, STONE, { base = 0.55, lx = 0.5, ly = 0.8, nz = 0.4, sc = 5, seed = 49 })
K.each(arch, function(x, y) if x % 20 == 0 then K.set(x, y, STONE[1]) end end)
K.outline(arch, INK)

-- crystals with stepped cold glow
local CY = {"#173a58","#22668a","#3a9cbe","#76d0e4","#c8f2f8"}
local CV = {"#2e2260","#4a3594","#7458c4","#a88ce6","#dccdf8"}
local function cluster(x, y, s, ramp, glow, seed)
  local halo = K.blob(x, y - s*0.8, s*2.6, s*1.8, seed, 0.3)
  local halo2 = K.blob(x, y - s*0.8, s*1.7, s*1.2, seed + 1, 0.3)
  K.tint(halo, glow, 0.16) K.tint(halo2, glow, 0.16)
  local m = {}
  for k = -2, 2 do
    local h = s*(1.6 - math.abs(k)*0.35) * (0.8 + K.hash(k, 0, seed)*0.4)
    local bx, lean = x + k*s*0.35, k*s*0.25
    local w = s*0.22
    K.add(m, K.poly{{bx - w, y}, {bx - w + lean, y - h}, {bx + lean*1.1, y - h - w*1.6}, {bx + w + lean, y - h}, {bx + w, y}})
  end
  K.shade(m, ramp, { base = 0.62, lx = 1.0, ly = 0.6, nz = 0.2, sc = 3, seed = seed + 2 })
  K.clumps(m, 4, seed + 3, ramp[2], 0.6)
  K.outline(m, INK)
  local sx, sy = K.bbox(m)
  return m
end
cluster(170, 150, 6, CY, "#5ad0f0", 141)
cluster(452, 158, 7, CV, "#9a7ae8", 151)

-- floor: moonlit flagstones
local FL = {"#1c1a2e","#29273f","#363552","#47496a","#5c6084","#7a82a4"}
local function gtop(x) return GY + math.floor((K.noise(x, 0, 19, 61) - 0.5)*3 + 0.5) end
local floor = K.terrain(gtop, H-1)
-- keep crystals/columns in front: paint floor only where not already a near object
local keep = {}
for _, m in ipairs(cols) do K.add(keep, m) end
local floorOnly = K.filter(floor, function(x, y) return not keep[y*W+x+1] end)
K.shade(floorOnly, FL, { rim = false, fn = function(x, y, v)
  local base = 0.5 - (y - GY)/90*0.15 + (K.fbm(x*0.4, y, 8, 63) - 0.5)*0.45
  -- moonbeam pool
  local bx = 292 + (y - GY)*0.15
  local dx = math.abs(x - bx)/70
  if dx < 1 then base = base + 0.25*(1 - dx) end
  return base end })
-- flagstone joints (rows grow taller toward the viewer)
local rows, y = {}, GY + 4
local hgt = 8
while y < H do rows[#rows+1] = y y = y + hgt hgt = hgt + 3 end
K.each(floorOnly, function(x, y)
  for r, ry in ipairs(rows) do
    if y == ry then K.set(x, y, FL[1]) return end
    local nxt = rows[r+1] or H
    if y > ry and y < nxt then
      local wdt = 24 + r*8
      local off = (r % 2)*wdt/2
      local xx = math.floor((x - 240)*(1 - (r-1)*0.05) + 240 + off)
      if xx % wdt == 0 then K.set(x, y, FL[1]) end
      return
    end
  end
end)
for x = 0, W-1 do K.set(x, gtop(x), "#12111f") end
-- glow of crystals on the floor
K.tint(K.clip(K.blob(64, 222, 46, 9, 5, 0.3), floorOnly), "#5ad0f0", 0.14)
K.tint(K.clip(K.blob(420, 228, 50, 9, 6, 0.3), floorOnly), "#5ad0f0", 0.14)
K.tint(K.clip(K.blob(132, 230, 26, 6, 7, 0.3), floorOnly), "#9a7ae8", 0.14)
K.tint(K.clip(K.blob(360, 234, 22, 5, 8, 0.3), floorOnly), "#9a7ae8", 0.14)

-- redraw floor-level crystals over the floor
cluster(64, 214, 14, CY, "#5ad0f0", 101)
cluster(132, 226, 8, CV, "#9a7ae8", 111)
cluster(420, 220, 16, CY, "#5ad0f0", 121)
cluster(360, 230, 7, CV, "#9a7ae8", 131)

-- rubble + stalagmites on the flanks
local RUB = {"#26233a","#3a3654","#55526f","#76768f","#9c9fb6"}
local rubble = {}
for i = 0, 26 do
  local x = math.floor(K.hash(i, 0, 71)*150)
  if i % 2 == 1 then x = 330 + math.floor(K.hash(i, 1, 71)*150) end
  local yy = 236 + math.floor(K.hash(i, 2, 71)*30)
  local r = 3 + math.floor(K.hash(i, 3, 71)*7)
  K.add(rubble, K.cut(K.blob(x, yy, r*1.3, r*0.8, 720 + i, 0.3), K.rect(0, yy + r*0.5, W-1, H-1)))
end
K.add(rubble, K.poly{{0, 270}, {6, 214}, {14, 240}, {20, 226}, {30, 270}})
K.add(rubble, K.poly{{448, 270}, {460, 222}, {466, 244}, {474, 206}, {479, 230}, {479, 270}})
K.shade(rubble, RUB, { base = 0.55, lx = 0.8, ly = 0.8, nz = 0.4, sc = 4, seed = 77 })
K.clumps(rubble, 8, 79, RUB[1], 0.6)
K.outline(rubble, INK, true)

K.save("fight-dark")
