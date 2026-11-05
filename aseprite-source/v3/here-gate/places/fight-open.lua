-- fight-open: sunny open land battle stage (480x270). Ground band y>=180, centre third clear.
local K = dofile("/home/user/gnome-venture/aseprite-source/v3/here-gate/places/_fight-kit.lua")
local W, H, INK = K.W, K.H, K.INK
local GY = 180
local sin = math.sin

-- sky: stepped warm-at-horizon bands with wavy edges
local SKY = {"#3f5fa6","#5a7dc0","#7c9fd3","#a3c0df","#cddbe0","#f0dcae"}
for y = 0, GY do for x = 0, W-1 do
  local t = y/165 + (K.noise(x, y, 52, 3) - 0.5)*0.10
  local i = math.floor(t*6) + 1
  if i < 1 then i = 1 elseif i > 6 then i = 6 end
  K.set(x, y, SKY[i])
end end

-- clouds (flat-bottomed puffs)
local CL = {"#7d7fb3","#a3a9d0","#c9d0e6","#e9ecf0","#f8f3e6"}
local function cloud(cx, by, w, h, s)
  local m = K.blob(cx - w*0.25, by - h*0.42, w*0.28, h*0.5, s, 0.18)
  K.add(m, K.blob(cx + w*0.04, by - h*0.66, w*0.30, h*0.66, s+1, 0.18))
  K.add(m, K.blob(cx + w*0.30, by - h*0.38, w*0.24, h*0.42, s+2, 0.18))
  K.add(m, K.rect(cx - w*0.45, by - h*0.25, cx + w*0.48, by))
  K.cut(m, K.rect(0, by+1, W-1, H-1))
  K.shade(m, CL, { base = 0.66, lx = 0.4, ly = 0.8, nz = 0.3, sc = 6, seed = s,
    fn = function(x, y, v) if y >= by - 2 then return v - 0.3 end return v end })
  K.outline(m, "#6b6aa3")
end
cloud(250, 46, 150, 42, 11)
cloud(420, 74, 100, 30, 21)
cloud(330, 112, 70, 20, 31)
cloud(40, 130, 64, 18, 41)
cloud(170, 120, 54, 14, 51)

-- far hills
local function f1(x) return 126 + 10*sin(x/61) + 7*sin(x/27 + 2) + (K.noise(x, 0, 9, 5) - 0.5)*6 end
local far = K.terrain(f1, GY+4)
K.shade(far, {"#4f5a92","#636fa6","#7b88b8","#96a3c9","#b3bdd6"}, { base = 0.6, lx = 0.25, ly = 0.9, nz = 0.35, sc = 10, seed = 7 })
K.outline(far, "#454a80", true)
-- far cottage (tiny)
local cot = K.rect(352, f1(356) - 2, 364, f1(356) + 8)
local roof = K.poly{{349, f1(356) - 1}, {358, f1(356) - 9}, {367, f1(356) - 1}}
K.fill(cot, "#a3a2c4") K.fill(K.rect(360, f1(356)-2, 364, f1(356)+8), "#7f80aa")
K.fill(roof, "#8a6a90") K.outline(K.add(K.copy(cot), roof), "#454a80", true)
K.set(355, math.floor(f1(356)) + 3, "#f0dcae") K.set(356, math.floor(f1(356)) + 3, "#f0dcae")

-- mid hills + distant tree clumps
local function f2(x) return 154 + 9*sin(x/45 + 1) + 6*sin(x/19) + (K.noise(x, 0, 7, 9) - 0.5)*5 end
local mid = K.terrain(f2, GY+4)
K.shade(mid, {"#2f4f5e","#3d6a68","#4f8468","#6c9f6c","#93bd78"}, { base = 0.62, lx = 0.3, ly = 1.0, nz = 0.4, sc = 7, seed = 13 })
K.outline(mid, "#26394a", true)
for _, t in ipairs{{196,6,8},{208,5,7},{219,7,9},{292,5,7},{303,6,8},{430,7,9},{444,5,6},{150,5,7}} do
  local tx = t[1]
  local m = K.blob(tx, f2(tx) - t[3] + 2, t[2], t[3], tx, 0.2)
  K.shade(m, {"#24394a","#2f5050","#3f6a56","#58865c","#7aa266"}, { base = 0.6, lx = 0.7, ly = 0.7, nz = 0.4, sc = 4, seed = tx })
  K.outline(m, "#1f2f3c")
end

-- fence on the back edge of the ground (right side)
local WOOD = {"#3a2433","#5a3631","#7d4e36","#a06c40","#c89058"}
local fence = {}
for i = 0, 5 do local fx = 336 + i*28 K.add(fence, K.rect(fx, 166, fx+4, 188)) K.add(fence, K.poly{{fx, 166}, {fx+2, 163}, {fx+4, 166}}) end
K.add(fence, K.rect(330, 171, 479, 173)) K.add(fence, K.rect(330, 180, 479, 182))
K.shade(fence, WOOD, { base = 0.62, lx = 0.1, ly = 0.6, nz = 0.5, sc = 3, sx = 0.5, seed = 61 })
K.outline(fence, INK)

-- ground
local G = {"#264438","#2f5a45","#3f7a43","#5f9a3e","#8cbb4a","#c4d867"}
local function gtop(x) return GY + math.floor((K.noise(x, 0, 23, 17) - 0.5)*3 + 0.5) end
local ground = K.terrain(gtop, H-1)
K.shade(ground, G, { rim = false, fn = function(x, y, v)
  return 0.66 - (y - GY)/90*0.28 + (K.fbm(x*0.3, y*1.3, 6, 21) - 0.5)*0.6 end })
for x = 0, W-1 do K.set(x, gtop(x), "#2f4f3a") K.set(x, gtop(x)+1, G[5]) end

-- trodden earth patch (the stage)
local dirt = K.blob(240, 226, 178, 21, 9, 0.2)
K.clip(dirt, ground)
K.shade(dirt, {"#4a3530","#6b4b3b","#8c6849","#ae8a5c","#cfae7a"}, { base = 0.62, lx = 0.15, ly = 0.6, nz = 0.6, sc = 5, sx = 0.5, seed = 23 })
K.outline(dirt, "#3b3a2a")
-- grass blades: dark root + lit tip, thinner in the centre third
K.each(ground, function(x, y)
  if y > GY + 2 then
    local dens = (x > 160 and x < 320) and 0.012 or 0.04
    if dirt[y*W+x+1] then dens = (x > 160 and x < 320) and 0 or 0.004 end
    if K.hash(x, y, 5) < dens then
      K.set(x, y, G[1]) K.set(x, y-1, G[3]) K.set(x, y-2, (K.hash(x, y, 6) < 0.5) and G[6] or G[5])
    end
  end
end)
-- grass fringe over the dirt edge
K.each(dirt, function(x, y)
  if not K.has(dirt, x, y-1) and K.hash(x, y, 8) < 0.45 then K.set(x, y, G[4]) K.set(x, y+1, G[2]) end
end)

-- tree shadow, then the wind-bent tree (left)
K.tint(K.clip(K.blob(78, 229, 50, 6, 3, 0.2), ground), "#1c2f46", 0.4)
local trunk = K.stroke(K.bez({58, 230}, {52, 175}, {72, 132}, {106, 94}, 30), function(t) return 16 - 10*t end)
K.add(trunk, K.poly{{40, 231}, {50, 216}, {68, 216}, {84, 232}, {60, 229}})
K.stroke(K.bez({90, 110}, {110, 102}, {132, 98}, {156, 92}, 14), function(t) return 5 - 3*t end, trunk)
K.stroke(K.bez({76, 138}, {66, 126}, {58, 118}, {50, 112}, 10), function(t) return 4 - 2*t end, trunk)
K.stroke(K.bez({102, 98}, {114, 82}, {128, 72}, {146, 66}, 12), function(t) return 4 - 2*t end, trunk)
K.shade(trunk, WOOD, { base = 0.6, lx = 0.8, ly = 0.3, nz = 0.4, sc = 4, seed = 31,
  fn = function(x, y, v) return v + (K.noise(x*2.5, y*0.35, 3, 33) - 0.5)*0.5 end })
K.outline(trunk, INK)
local C = {"#22403a","#2f5e45","#477f44","#6ba14a","#9cc456","#cfe07a"}
local canopy = {}
for i, b in ipairs{{78,80,30,20},{112,64,36,24},{152,72,30,18},{182,86,18,10},{124,96,32,14},{88,104,24,12},{58,96,16,10},{206,94,10,6}} do
  K.add(canopy, K.blob(b[1], b[2], b[3], b[4], 40 + i, 0.28))
end
K.shade(canopy, C, { base = 0.6, lx = 0.55, ly = 0.75, nz = 0.6, sc = 5, seed = 71 })
K.clumps(canopy, 7, 73, C[1], 0.52)
K.outline(canopy, INK)
-- blown leaves
for i = 0, 15 do
  local lx = 200 + math.floor(K.hash(i, 1, 90)*110)
  local ly = 50 + math.floor(K.hash(i, 2, 90)*80)
  K.set(lx, ly, C[5]) K.set(lx+1, ly, C[3]) K.set(lx+1, ly+1, INK) K.set(lx, ly+1, C[2])
end

-- boulders (right)
local ROCK = {"#3b3550","#544f6c","#736f88","#9792a6","#bdb6c0","#e0d6c6"}
local rock = K.cut(K.blob(432, 200, 46, 30, 81, 0.16), K.rect(0, 226, W-1, H-1))
local rock2 = K.cut(K.blob(378, 214, 20, 12, 83, 0.2), K.rect(0, 224, W-1, H-1))
K.tint(K.clip(K.blob(420, 227, 64, 6, 4, 0.2), ground), "#1c2f46", 0.4)
for _, r in ipairs{rock2, rock} do
  K.shade(r, ROCK, { base = 0.6, lx = 0.6, ly = 0.6, nz = 0.5, sc = 9, seed = 85 })
  K.clumps(r, 14, 87, ROCK[1], 0.55)
  local _, ry0 = K.bbox(r)
  local moss = K.filter(r, function(x, y) return y < ry0 + 5 + K.noise(x, 0, 6, 89)*8 end)
  K.shade(moss, C, { base = 0.7, lx = 0.5, ly = 0.5, nz = 0.5, sc = 3, seed = 91 })
  K.outline(r, INK)
end

-- foreground framing tufts (corners), leaning with the wind
local tuft = {}
local function blade(bx, h, lean, w) K.add(tuft, K.poly{{bx - w, H}, {bx + lean, H - h}, {bx + w, H}}) end
for i = 0, 9 do blade(4 + i*7, 22 + math.floor(K.hash(i, 0, 3)*22), 8 + i % 3 * 3, 3) end
for i = 0, 9 do blade(412 + i*7, 20 + math.floor(K.hash(i, 1, 3)*24), 9 + i % 4 * 2, 3) end
K.shade(tuft, C, { base = 0.55, lx = 0.6, ly = 0.9, nz = 0.3, sc = 3, seed = 95 })
K.outline(tuft, INK, true)

-- flowers on the flanks only
local FL = {{"#f6d36a","#d99a2e","#a8462e"},{"#f08aa8","#c45478","#f6d36a"},{"#a98ae0","#6e52b0","#f6d36a"},
            {"#f4efe0","#c9b9c9","#e8a23a"},{"#f06a4a","#b8402e","#f6d36a"}}
local function flower(x, y, f)
  for k = 0, 3 do K.set(x, y-k, "#2f5a45") end
  K.set(x+1, y-1, "#477f44")
  K.set(x, y-5, f[3]) K.set(x, y-6, f[1]) K.set(x-1, y-5, f[1]) K.set(x+1, y-5, f[2]) K.set(x, y-4, f[2])
  K.set(x+1, y-6, INK) K.set(x+2, y-5, INK) K.set(x+1, y-4, INK)
end
for i = 0, 70 do
  local x = math.floor(K.hash(i, 7, 77)*150)
  if i % 2 == 1 then x = 330 + math.floor(K.hash(i, 8, 77)*148) end
  local y = 192 + math.floor(K.hash(i, 9, 77)*74)
  local ok = not (x > 150 and x < 330) and not (rock[(y-6)*W+x+1] or rock2[(y-6)*W+x+1] or trunk[(y-6)*W+x+1])
  if ok then flower(x, y, FL[i % #FL + 1]) end
end

K.save("fight-open")
