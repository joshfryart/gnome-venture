-- fight-wood: forest/swamp clearing battle stage (480x270). Ground band y>=180, centre third clear.
local K = dofile("/home/user/gnome-venture/aseprite-source/v3/here-gate/places/_fight-kit.lua")
local W, H, INK = K.W, K.H, K.INK
local GY = 180
local sin = math.sin

-- misty depth backdrop
local BG = {"#16302e","#1f3d38","#2d5246","#406a52","#5f8a66","#86a97c","#aac493"}
for y = 0, GY do for x = 0, W-1 do
  local t = y/178 + (K.noise(x, y, 40, 3) - 0.5)*0.12
  local i = math.floor(t*7) + 1
  if i < 1 then i = 1 elseif i > 7 then i = 7 end
  K.set(x, y, BG[i])
end end

-- far trunk rows (misty, lighter with distance)
local function trunkRow(seed, n, wmin, wmax, ramp, edge, ytop)
  for i = 0, n-1 do
    local x = math.floor(K.hash(i, 0, seed)*W)
    local w = wmin + math.floor(K.hash(i, 1, seed)*(wmax - wmin))
    local m = K.poly{{x - w/2, ytop}, {x + w/2, ytop}, {x + w/2 + 2, GY + 2}, {x + w/2 + 6, GY + 4}, {x - w/2 - 6, GY + 4}, {x - w/2 - 2, GY + 2}}
    K.shade(m, ramp, { base = 0.55, lx = 0.9, ly = 0.2, nz = 0.4, sc = 3, sx = 2, sy = 0.25, seed = seed + i })
    K.outline(m, edge, true)
  end
end
trunkRow(101, 14, 6, 12, {"#6f9583","#80a690","#93b79c","#a8c6a8"}, "#5f8577", 0)
local fog = K.filter(K.rect(0, 120, W-1, GY+4), function(x, y) return y > 150 + (K.noise(x, 0, 30, 5) - 0.5)*24 end)
K.tint(fog, "#c4d8b6", 0.45)
trunkRow(103, 9, 12, 22, {"#3b5a4e","#4b6f5c","#5e8569","#759a78"}, "#2c463f", 0)

-- light shafts from upper left
for _, s in ipairs{{150, 40}, {236, 26}, {320, 18}} do
  local sh = K.poly{{s[1], 0}, {s[1] + s[2], 0}, {s[1] + s[2] + 120, GY + 10}, {s[1] + 120, GY + 10}}
  K.tint(sh, "#f2e6a8", 0.22)
  K.tint(K.poly{{s[1] + s[2]*0.3, 0}, {s[1] + s[2]*0.6, 0}, {s[1] + s[2]*0.6 + 120, GY + 10}, {s[1] + s[2]*0.3 + 120, GY + 10}}, "#f2e6a8", 0.15)
end

-- canopy mass across the top
local LEAF = {"#14261f","#1d3a2c","#2a5236","#3d6d3e","#5a8a44","#86ad57"}
local canopy = K.terrain(function(x) return 0 end, 0)
for i = 0, 22 do
  local cx = i*22 + math.floor(K.hash(i, 0, 7)*10)
  K.add(canopy, K.blob(cx, 10 + K.hash(i, 1, 7)*14, 22 + K.hash(i, 2, 7)*10, 14 + K.hash(i, 3, 7)*10, 200 + i, 0.3))
end
K.add(canopy, K.rect(0, 0, W-1, 6))
K.shade(canopy, LEAF, { base = 0.5, lx = 0.4, ly = 1.1, nz = 0.6, sc = 5, seed = 207 })
K.clumps(canopy, 6, 209, LEAF[1], 0.55)
K.outline(canopy, INK)

-- ground: mossy earth
local G = {"#1f3027","#2a4430","#36583a","#4a7240","#6a904a","#93b25c"}
local function gtop(x) return GY + math.floor((K.noise(x, 0, 21, 17) - 0.5)*3 + 0.5) end
local ground = K.terrain(gtop, H-1)
K.shade(ground, G, { rim = false, fn = function(x, y, v)
  return 0.58 - (y - GY)/90*0.2 + (K.fbm(x*0.3, y*1.3, 6, 221) - 0.5)*0.6 end })
for x = 0, W-1 do K.set(x, gtop(x), "#1c2f28") end
-- low mist on the back of the ground
K.tint(K.filter(ground, function(x, y) return y < GY + 8 + K.noise(x, 0, 18, 9)*6 end), "#b9cfae", 0.35)
-- dappled light patches on the ground
for i = 0, 11 do
  local x = 40 + math.floor(K.hash(i, 0, 31)*400)
  local y = 196 + math.floor(K.hash(i, 1, 31)*60)
  local d = K.clip(K.blob(x, y, 10 + K.hash(i, 2, 31)*14, 3 + K.hash(i, 3, 31)*3, 300 + i, 0.3), ground)
  K.tint(d, "#f2e6a8", 0.3)
end
-- moss specks + leaf litter (flanks dense, centre sparse)
K.each(ground, function(x, y)
  if y > GY + 3 then
    local dens = (x > 160 and x < 320) and 0.008 or 0.03
    local h = K.hash(x, y, 55)
    if h < dens then K.set(x, y, G[1]) K.set(x, y-1, G[5]) end
    if h > 1 - dens*0.4 then K.set(x, y, "#9a6a3a") K.set(x+1, y, "#6a4430") end
  end
end)

-- swamp pools on the flanks
local WAT = {"#1a2f3a","#24434c","#2f5a5c","#4a7c72","#80aa96"}
for _, p in ipairs{{70, 246, 66, 12, 401}, {422, 252, 64, 11, 403}} do
  local pool = K.clip(K.blob(p[1], p[2], p[3], p[4], p[5], 0.18), ground)
  K.shade(pool, WAT, { base = 0.4, lx = 0.1, ly = -0.6, nz = 0.3, sc = 10, sx = 0.4, seed = p[5], rim = false })
  K.each(pool, function(x, y) if K.hash(x // 6, y, p[5]) < 0.12 then K.set(x, y, WAT[5]) end end)
  K.outline(pool, "#152520")
end

-- huge near trunks with flaring roots
local BARK = {"#251c28","#3a2a34","#523a3c","#6d4f46","#8c6a54","#ad8a68"}
local left = K.poly{{0, 0}, {74, 0}, {70, 140}, {78, 190}, {108, 214}, {128, 222}, {84, 220}, {60, 206}, {44, 226}, {20, 214}, {0, 222}}
local right = K.poly{{414, 0}, {479, 0}, {479, 216}, {470, 220}, {446, 206}, {418, 228}, {398, 222}, {378, 230}, {404, 204}, {418, 170}}
K.tint(K.clip(K.blob(70, 222, 70, 7, 5, 0.2), ground), "#0f1f20", 0.35)
K.tint(K.clip(K.blob(430, 226, 70, 7, 6, 0.2), ground), "#0f1f20", 0.35)
for j, t in ipairs{left, right} do
  K.shade(t, BARK, { base = 0.55, lx = 0.9, ly = 0.25, nz = 0.4, sc = 5, seed = 500 + j,
    fn = function(x, y, v) return v + (K.noise(x*3, y*0.22, 4, 510 + j) - 0.5)*0.7 end })
  -- grooves
  K.each(t, function(x, y) if K.noise(x*3, y*0.2, 5, 520 + j) > 0.78 then K.set(x, y, BARK[1]) end end)
  -- moss on the lit upper-left side
  local moss = K.filter(t, function(x, y) return K.fbm(x, y, 9, 530 + j) > 0.58 and (y > 150 or K.noise(x, y, 14, 540 + j) > 0.55) end)
  K.shade(moss, {"#2a4430","#3e6438","#5e8a44","#8fb25a"}, { base = 0.6, lx = 0.6, ly = 0.6, nz = 0.6, sc = 3, seed = 550 + j })
  K.outline(t, INK)
end
-- shelf fungi on the right trunk
local FUN = {"#5a2e2a","#8a4a2e","#b8743a","#dca456","#f2d08a"}
for i, f in ipairs{{420, 120, 13}, {428, 132, 10}, {418, 150, 9}} do
  local m = K.poly{{f[1] - f[3], f[2]}, {f[1] - f[3] + 3, f[2] - 4}, {f[1] + 2, f[2] - 6}, {f[1] + 4, f[2] - 2}, {f[1] + 4, f[2] + 1}}
  K.shade(m, FUN, { base = 0.6, lx = 0.5, ly = 1.0, nz = 0.3, sc = 3, seed = 600 + i })
  K.outline(m, INK)
end

-- hanging moss drapes
local MOSS = {"#3a4a36","#56684a","#77885a","#9aa96c","#c0c88a"}
for i, d in ipairs{{30,0,46},{56,10,30},{102,18,38},{140,12,26},{196,20,34},{262,14,24},{300,22,40},{352,16,30},{396,8,44},{440,4,36},{466,10,28}} do
  local m = {}
  for k = 0, 2 do
    local x = d[1] + (k - 1)*5
    local len = d[3] - k*7 + math.floor(K.hash(i, k, 61)*8)
    K.add(m, K.stroke(K.bez({x, d[2]}, {x + 3, d[2] + len*0.3}, {x - 3, d[2] + len*0.7}, {x + 1, d[2] + len}, 12), function(t) return 4 - 3*t end))
  end
  K.shade(m, MOSS, { base = 0.6, lx = 0.8, ly = 0.6, nz = 0.6, sc = 2, seed = 620 + i })
  K.outline(m, INK)
end

-- mushrooms + ferns near the trunk bases (flanks only)
local CAP1 = {"#5a1e2a","#8e2e34","#c0473c","#e06a4a","#f29a6a"}
local CAP2 = {"#4a3030","#6e4a3a","#946a4a","#b88c5c","#d8b07a"}
local STEM = {"#8a7a7a","#b8a894","#ddd0b4","#f0e6cc"}
local function shroom(x, y, h, w, cap, spots)
  local stem = K.rect(x - 1, y - h, x + 1, y)
  local c = K.poly{{x - w, y - h + 1}, {x - w + 1, y - h - 2}, {x - w/2, y - h - w*0.6}, {x + w/2, y - h - w*0.6}, {x + w - 1, y - h - 2}, {x + w, y - h + 1}}
  K.shade(stem, STEM, { base = 0.6, lx = 1.0, ly = 0.6, nz = 0.2, sc = 2, seed = x })
  K.shade(c, cap, { base = 0.6, lx = 0.7, ly = 0.9, nz = 0.3, sc = 3, seed = x + 1 })
  if spots then
    K.set(x - w/2 + 1, y - h - 2, "#f0e6cc") K.set(x + 1, y - h - 3, "#f0e6cc") K.set(x + 2, y - h - 3, "#f0e6cc")
  end
  K.outline(K.add(stem, c), INK)
end
shroom(96, 226, 7, 6, CAP1, true) shroom(108, 230, 5, 4, CAP1, true) shroom(118, 228, 4, 3, CAP2)
shroom(372, 236, 8, 7, CAP2) shroom(386, 240, 5, 4, CAP1, true) shroom(30, 232, 6, 5, CAP2)
shroom(456, 232, 6, 5, CAP1, true)
local fern = {}
local function frond(x, y, dx, h) K.stroke(K.bez({x, y}, {x + dx*0.2, y - h*0.7}, {x + dx*0.6, y - h}, {x + dx, y - h*0.6}, 10), 2, fern)
  for k = 1, 4 do local t = k/5 local px, py = x + dx*0.5*t, y - h*0.9*t
    K.stroke({{px, py}, {px + 3*(dx > 0 and 1 or -1), py - 2}}, 1, fern) K.stroke({{px, py}, {px - 2*(dx > 0 and 1 or -1), py - 3}}, 1, fern) end end
frond(140, 236, 16, 18) frond(140, 236, -10, 16) frond(146, 238, 20, 12)
frond(340, 240, -16, 18) frond(342, 240, 10, 14) frond(16, 262, 18, 20) frond(462, 266, -18, 22)
K.shade(fern, {"#24402c","#355e34","#4f8040","#78a650"}, { base = 0.6, lx = 0.6, ly = 0.8, nz = 0.3, sc = 2, seed = 700, rim = false })
K.outline(fern, INK)
-- reeds by the pools
local reed = {}
for i = 0, 7 do local x = 20 + i*13 + math.floor(K.hash(i, 0, 81)*6) K.stroke({{x, 250}, {x + 2, 228 - (i % 3)*6}}, 2, reed) end
for i = 0, 6 do local x = 378 + i*14 + math.floor(K.hash(i, 1, 81)*6) K.stroke({{x, 256}, {x - 2, 232 - (i % 3)*6}}, 2, reed) end
K.shade(reed, {"#3a4a2a","#5a6e34","#7f9440","#a8b85a"}, { base = 0.6, lx = 1.0, ly = 0.5, nz = 0.3, sc = 2, seed = 800 })
K.outline(reed, INK)

K.save("fight-wood")
