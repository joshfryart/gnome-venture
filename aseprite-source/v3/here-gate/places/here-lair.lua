-- Gnome Venture "Hearth Pop" v3: here-lair (gate view of a beast lair). 480x270 native.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3"
local HP = dofile(ROOT .. "/lib/hp.lua")
local OUT = (app.params and app.params.out) or (ROOT .. "/here-gate/places/")
local W, H, HZ = 480, 270, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-lair" }

local function hash(x, y, s)
  local n = math.sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453
  return n - math.floor(n)
end
local function put(x, y, hex) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, hex) end end
local function fill(m, hex) m:each(function(x, y) put(x, y, hex) end) end
-- textured, lit object: ramp {e=edge,d=deep,s=shade,b=base,h=hi}
local function tex(m, r, o)
  o = o or {}
  local seed = o.seed or 1
  m:each(function(x, y)
    local col = r.b
    if not m:has(x - 2, y) or not m:has(x, y - 2) then col = r.h
    elseif not m:has(x + 3, y) or not m:has(x, y + 3) or not m:has(x + 2, y + 2) then col = r.s
    else
      local n = hash(x, y, seed)
      if n < (o.dark or 0.09) then col = r.s elseif n > (o.lite or 0.94) then col = r.h end
      if o.fn then col = o.fn(x, y, col) or col end
    end
    put(x, y, col)
  end)
  fill(m:edge(), r.e)
end
local function shadow(cx, cy, rx, ry) -- violet ground shadow, 2-tone
  local m = c:ellipse(cx, cy, rx, ry)
  fill(m, "#5a3346")
  fill(c:ellipse(cx, cy, math.max(1, rx - 4), math.max(1, ry - 2)), "#4a2a3e")
end

local ROCK = { e = "#2b1c26", d = "#362c40", s = "#4e4258", b = "#6e6070", h = "#8f8294" }
local ROCK2 = { e = "#2b1c26", d = "#3a2a3c", s = "#55405a", b = "#76586e", h = "#9a7a8c" }
local BONE = { e = "#5a4048", d = "#8a7468", s = "#b4a288", b = "#e2d5b6", h = "#f4ecd6" }
local GOLD = { e = "#6a3a1e", d = "#a8661e", s = "#d0902a", b = "#f0be48", h = "#fde69a" }
local WOOD = { e = "#2b1c26", d = "#3e2830", s = "#4f3434", b = "#6c4a42", h = "#8e6a58" }
local EGG = { e = "#3a2448", d = "#5a3a6e", s = "#7e5a96", b = "#a888c0", h = "#cdb8de" }

---------------------------------------------------------------- sky (stormy red-violet dusk)
c:stripes(0, HZ, { "#2e1a3c", "#3c1f46", "#4e2550", "#652a55", "#7e3156", "#9a3a52", "#b84a4c", "#d4664a", "#e88c52" },
  { 3, 3, 3, 3, 2, 2, 2, 1.5, 1 })
-- storm clouds: dark bodies with red undersides
local function storm(x, y, w)
  c:cloud(x, y, w, "#4a2648", "#8a3654")
  for i = 0, w - 1, 3 do put(x + i, y, "#b0485a") end
end
storm(60, 34, 70); storm(150, 24, 56); storm(300, 30, 80); storm(390, 46, 52); storm(200, 52, 40); storm(20, 62, 36)
-- lightning bolt (quirk) far right
c:fillMask(c:line({ { 352, 34 }, { 344, 50 }, { 352, 52 }, { 340, 74 } }, 2), "#fbe08a")
put(343, 50, "#fff4c2"); put(351, 51, "#fff4c2")

---------------------------------------------------------------- far mountains and hills
c:terrain(function(x)
  local v = 70 + 18 * math.sin(x * 0.031) + 10 * math.sin(x * 0.083 + 1.3)
  local saw = (x % 37) / 37; v = v - 10 * math.abs(saw - 0.5)
  return math.floor(v)
end, "#5b2d55", HZ)
c:terrain(function(x) return math.floor(92 + 8 * math.sin(x * 0.05 + 2) + 4 * math.sin(x * 0.15)) end, "#4a2846", HZ)
-- ruined far tower on a ridge (left)
fill(c:rect(92, 66, 99, 92), "#3e2240"); fill(c:poly{ { 92, 66 }, { 95, 61 }, { 97, 64 }, { 99, 60 }, { 99, 66 } }, "#3e2240")
put(95, 72, "#e88c52"); put(95, 73, "#e88c52")
-- tiny dead-tree silhouettes on the far hills
for _, t in ipairs({ { 132, 94 }, { 356, 92 }, { 404, 96 } }) do
  fill(c:line({ { t[1], t[2] }, { t[1], t[2] - 9 } }, 1), "#3a2040")
  fill(c:line({ { t[1], t[2] - 5 }, { t[1] - 4, t[2] - 9 } }, 1), "#3a2040")
  fill(c:line({ { t[1], t[2] - 6 }, { t[1] + 3, t[2] - 11 } }, 1), "#3a2040")
end
c:terrain(function(x) return math.floor(104 + 4 * math.sin(x * 0.07)) end, "#3e2a3c", HZ)

---------------------------------------------------------------- ground
local VPX = 240
for y = HZ, H - 1 do
  for x = 0, W - 1 do
    local n = hash(x, y, 3)
    local d = (y - HZ) / (H - HZ)
    local col = d < 0.15 and "#6e4048" or (d < 0.4 and "#7e4c4a" or "#8c5a4c")
    -- warm glow spilling from the lair mouth
    local gx, gy = (x - 240) / 70, (y - 150) / 26
    if gx * gx + gy * gy < 1 and y >= 140 then col = "#9a6250" end
    if n < 0.07 then col = "#6a3e44" elseif n > 0.95 then col = "#a87060" end
    put(x, y, col)
  end
end
-- ground ridges / dead grass tufts
for i = 1, 70 do
  local x = math.floor(hash(i, 1, 9) * 470) + 4
  local y = math.floor(hash(i, 2, 9) * (H - HZ - 14)) + HZ + 10
  if not (x > 375 and y > 226) then
    put(x, y, "#b0805a"); put(x + 1, y - 1, "#b0805a"); put(x - 1, y - 1, "#9a6a4a"); put(x + 2, y, "#6a3e44")
  end
end

---------------------------------------------------------------- broken flagstone path toward the mouth
local function pathHalf(y) return 100 * (y - 100) / 169 end
local path = HP.mask()
for y = 144, H - 1 do
  local hw = pathHalf(y)
  for x = math.floor(VPX - hw), math.ceil(VPX + hw) do path:set(x, y) end
end
local function cell(x, y)
  local u = 1000 / (y - 100)
  local row = math.floor(u / 1.15)
  local s = (x - VPX) / (y - 100)
  local col = math.floor(s * 11 + (row % 2) * 0.5)
  return row, col
end
path:each(function(x, y)
  local r, cc = cell(x, y)
  local r1, c1 = cell(x, y - 1)
  local r2, c2 = cell(x - 1, y)
  local h = hash(r, cc, 5)
  local col
  if h < 0.13 then
    col = (hash(x, y, 6) < 0.1) and "#6a3e44" or "#7a4a48" -- missing stone, dirt
  elseif r ~= r1 or cc ~= c2 then
    col = "#4a3448"
  else
    local r3, c3 = cell(x, y - 2); local r4, c4 = cell(x - 2, y)
    local base = h < 0.45 and "#9a8484" or (h < 0.75 and "#8a7680" or "#a69088")
    col = base
    if r3 ~= r or c4 ~= cc then col = "#bca8a0" end
    local r5, _ = cell(x, y + 1)
    if r5 ~= r then col = "#6e5a68" end
    if hash(x, y, 7) < 0.06 then col = "#6e5a68" end
  end
  put(x, y, col)
end)
fill(path:edge(), "#4a3448")

local trail = c:poly{ { 300, 170 }, { 330, 160 }, { 400, 156 }, { 479, 148 }, { 479, 166 }, { 404, 170 }, { 340, 176 }, { 306, 182 } }
trail:each(function(x, y) local n = hash(x, y, 60); put(x, y, n < 0.15 and "#7a4a48" or (n > 0.9 and "#b88a68" or "#a07058")) end)
---------------------------------------------------------------- MOUTH: rock mound + ruined arch + cave (hero)
local mound = c:poly{ { 168, 152 }, { 172, 118 }, { 182, 86 }, { 198, 62 }, { 216, 48 }, { 238, 42 }, { 262, 46 },
  { 284, 58 }, { 300, 80 }, { 308, 108 }, { 312, 152 } }
shadow(244, 154, 80, 7)
fill(mound:grow(1):cut(mound), "#2b1c26")
tex(mound, ROCK, { seed = 11, fn = function(x, y, col)
  if (y + math.floor(x / 9)) % 13 == 0 and hash(x, y, 4) < 0.8 then return ROCK.d end -- strata
  return col
end })
-- opening (rounded arch, flat floor) and stone arch ring
local open = c:poly{ { 208, 150 }, { 208, 108 }, { 212, 96 }, { 220, 86 }, { 232, 80 }, { 248, 80 }, { 260, 86 },
  { 268, 96 }, { 272, 108 }, { 272, 150 } }
local ring = open:grow(11):cut(open)
local keep = HP.mask(); ring:each(function(x, y) if y <= 150 then keep:set(x, y) end end); ring = keep
-- ruined: upper-right blocks lost
local lost = c:poly{ { 262, 62 }, { 290, 62 }, { 290, 96 }, { 270, 84 } }
ring:cut(lost)
fill(ring:grow(1):cut(ring):cut(open), "#2b1c26")
ring:each(function(x, y)
  local a = math.atan(y - 118, x - 240)
  local b = math.floor((a + math.pi) / 0.32)
  local b2 = math.floor((math.atan(y - 118, x - 241) + math.pi) / 0.32)
  local b3 = math.floor((math.atan(y - 119, x - 240) + math.pi) / 0.32)
  local vertical = x < 214 or x > 266
  local blk = vertical and math.floor((y - 60) / 12) or b
  local blkA = vertical and math.floor((y - 61) / 12) or b3
  local col = ROCK2.b
  local h = hash(blk, x < 240 and 1 or 2, 8)
  if h < 0.3 then col = "#6c5468" end
  if blk ~= blkA or (not vertical and b ~= b2) then col = ROCK2.e end
  if hash(x, y, 12) < 0.08 then col = ROCK2.s end
  put(x, y, col)
end)
-- cave interior: deep dark with warm hoard glow
open:each(function(x, y)
  local col = "#1e1226"
  local gx, gy = (x - 240) / 26, (y - 146) / 22
  local g = gx * gx + gy * gy
  if g < 1 then col = "#3a1e28" end
  if g < 0.55 then col = "#5a2a28" end
  if g < 0.25 then col = "#7a3a28" end
  if y < 96 and hash(x, y, 13) < 0.05 then col = "#2a1a32" end
  put(x, y, col)
end)
-- hoard heap deep inside
local heap = c:poly{ { 224, 150 }, { 230, 140 }, { 238, 134 }, { 246, 136 }, { 254, 142 }, { 258, 150 } }
tex(heap, GOLD, { seed = 14, dark = 0.2, lite = 0.8 })
c:sparkle(241, 137); c:sparkle(232, 145)
-- stalactite teeth on the arch rim
for _, t in ipairs({ { 222, 86, 7 }, { 234, 81, 10 }, { 248, 81, 8 }, { 259, 86, 6 } }) do
  local m = c:poly{ { t[1] - 3, t[2] }, { t[1] + 3, t[2] }, { t[1], t[2] + t[3] } }
  fill(m, "#c9b896"); fill(m:edge(), "#5a4048"); put(t[1] - 1, t[2] + 1, "#f4ecd6")
end
-- keystone plaque with claw icon (mouth spot sign)
local plaque = c:rect(229, 54, 251, 72)
fill(plaque:grow(1):cut(plaque), "#2b1c26")
tex(plaque, { e = "#3a2a3c", d = "#4e3a50", s = "#6a5068", b = "#8a7088", h = "#a890a4" }, { seed = 15 })
for i = 0, 2 do
  fill(c:line({ { 234 + i * 5, 58 }, { 240 + i * 5, 68 } }, 2), "#c43a3a")
  put(234 + i * 5, 58, "#e86a5a")
end
-- huge claw marks gouged in the rock (left and right flanks)
local function claws(x0, y0, dx, dy, n, sp)
  for i = 0, n - 1 do
    local a = { x0 + i * sp, y0 }; local b = { x0 + i * sp + dx, y0 + dy }
    fill(c:line({ a, b }, 3), "#241a2c")
    fill(c:line({ { a[1] + 2, a[2] + 1 }, { b[1] + 2, b[2] + 1 } }, 1), "#a898a8")
  end
end
claws(178, 92, 12, 34, 3, 7)
claws(282, 92, 10, 36, 3, 7)
-- fallen arch blocks (from the lost upper-right)
for _, b in ipairs({ { 284, 138, 298, 150 }, { 298, 143, 308, 151 } }) do
  local m = c:rect(b[1], b[2], b[3], b[4])
  fill(m:grow(1):cut(m), "#2b1c26"); tex(m, ROCK2, { seed = b[1] })
end
-- fur doormat at the threshold (quirk)
local mat = c:poly{ { 220, 151 }, { 260, 151 }, { 264, 158 }, { 216, 158 } }
fill(mat:grow(1):cut(mat), "#2b1c26")
tex(mat, { e = "#3e2830", d = "#5a3a30", s = "#7a5038", b = "#a07048", h = "#c8955e" }, { seed = 16, dark = 0.2 })
for x = 217, 263, 3 do put(x, 159, "#7a5038") end

---------------------------------------------------------------- left far: twisted dead tree (with a sock)
shadow(112, 152, 30, 4)
local tree = c:line({ { 108, 152 }, { 104, 132 }, { 112, 112 }, { 106, 92 }, { 112, 74 } }, 9)
tree:add(c:line({ { 106, 96 }, { 86, 82 }, { 70, 84 }, { 56, 70 } }, 5))
tree:add(c:line({ { 110, 84 }, { 132, 70 }, { 142, 54 } }, 5))
tree:add(c:line({ { 112, 74 }, { 104, 56 }, { 112, 42 } }, 4))
tree:add(c:line({ { 86, 82 }, { 82, 64 }, { 90, 52 } }, 3))
tree:add(c:line({ { 132, 70 }, { 150, 72 } }, 3))
tree:add(c:line({ { 70, 84 }, { 60, 96 }, { 50, 100 } }, 3))
tree:add(c:line({ { 142, 54 }, { 136, 44 } }, 2))
tree:add(c:poly{ { 96, 152 }, { 120, 152 }, { 112, 140 }, { 104, 140 } }) -- root flare
fill(tree:grow(1):cut(tree), "#2b1c26")
tex(tree, WOOD, { seed = 17, fn = function(x, y, col) if x % 4 == 0 and hash(x, y, 2) < 0.5 then return WOOD.s end end })
-- knot hole
fill(c:rect(107, 118, 110, 123), "#241a2c"); put(107, 118, WOOD.h)
-- striped sock on a branch (quirk)
local sock = c:poly{ { 60, 96 }, { 64, 96 }, { 64, 106 }, { 69, 108 }, { 69, 112 }, { 60, 112 } }
fill(sock:grow(1):cut(sock), "#2b1c26")
sock:each(function(x, y) put(x, y, (y % 4 < 2) and "#e0c060" or "#5a8a7a") end)

---------------------------------------------------------------- left near: bone pile + crowned skull + teacup
shadow(80, 214, 54, 6)
-- ribcage arches
for i = 0, 3 do
  local x = 34 + i * 11
  local rib = c:line({ { x, 212 }, { x + 2, 186 - i * 2 }, { x + 9, 178 - i * 2 }, { x + 14, 182 } }, 3)
  fill(rib:grow(1):cut(rib), BONE.e); tex(rib, BONE, { seed = 20 + i })
end
local spine = c:line({ { 32, 212 }, { 80, 212 } }, 3)
fill(spine:grow(1):cut(spine), BONE.e); tex(spine, BONE, { seed = 25 })
-- crossed long bones
for _, b in ipairs({ { { 84, 210 }, { 124, 196 } }, { { 88, 196 }, { 122, 212 } } }) do
  local m = c:line(b, 4)
  m:add(c:rect(b[1][1] - 3, b[1][2] - 3, b[1][1] + 2, b[1][2] + 2)); m:add(c:rect(b[2][1] - 2, b[2][2] - 3, b[2][1] + 3, b[2][2] + 2))
  fill(m:grow(1):cut(m), BONE.e); tex(m, BONE, { seed = b[1][1] })
end
-- horned skull
local sk = c:poly{ { 58, 196 }, { 60, 180 }, { 70, 170 }, { 86, 168 }, { 98, 174 }, { 116, 182 }, { 120, 190 }, { 112, 196 },
  { 96, 196 }, { 92, 202 }, { 70, 202 } }
local horn = c:line({ { 70, 172 }, { 62, 160 }, { 64, 148 }, { 72, 144 } }, 4)
horn:add(c:line({ { 86, 170 }, { 92, 156 }, { 102, 152 } }, 3))
fill(horn:grow(1):cut(horn), BONE.e); tex(horn, { e = BONE.e, d = "#7a6458", s = "#9a8670", b = "#c9b896", h = "#e2d5b6" }, { seed = 31 })
fill(sk:grow(1):cut(sk), BONE.e); tex(sk, BONE, { seed = 30 })
local eye = c:poly{ { 76, 178 }, { 84, 177 }, { 86, 183 }, { 78, 185 } }; fill(eye, "#2b1c26"); put(78, 180, "#e86a5a")
local nost = c:poly{ { 108, 184 }, { 112, 185 }, { 110, 188 } }; fill(nost, "#2b1c26")
for x = 96, 112, 4 do fill(c:poly{ { x, 196 }, { x + 3, 196 }, { x + 1, 200 } }, BONE.b); put(x + 1, 200, BONE.e) end
-- tiny crown on the skull (quirk: stolen)
local crown = c:poly{ { 72, 170 }, { 72, 162 }, { 75, 166 }, { 78, 160 }, { 81, 166 }, { 84, 160 }, { 86, 166 }, { 88, 162 }, { 88, 170 } }
fill(crown:grow(1):cut(crown), GOLD.e); tex(crown, GOLD, { seed = 32 }); put(80, 167, "#c43a5a"); c:sparkle(76, 163)
-- teacup among the bones (quirk)
local cup = c:poly{ { 38, 198 }, { 50, 198 }, { 48, 206 }, { 40, 206 } }
fill(cup:grow(1):cut(cup), "#2b1c26"); tex(cup, { e = "#4a5a8a", d = "#6a7ab0", s = "#8a9ac8", b = "#c8d4ec", h = "#e8eef8" }, { seed = 33 })
fill(c:rect(51, 200, 52, 203), "#4a5a8a"); fill(c:rect(36, 207, 52, 208), "#c8d4ec"); put(42, 201, "#d06a8a"); put(45, 202, "#d06a8a")

---------------------------------------------------------------- right far: stolen hoard heap
shadow(358, 151, 36, 4)
local hoard = c:poly{ { 326, 150 }, { 332, 136 }, { 342, 126 }, { 354, 120 }, { 366, 122 }, { 378, 132 }, { 386, 142 }, { 390, 150 } }
fill(hoard:grow(1):cut(hoard), GOLD.e)
tex(hoard, GOLD, { seed = 40, dark = 0.18, lite = 0.84, fn = function(x, y, col) if (x + y * 3) % 7 == 0 then return GOLD.s end end })
-- goblet
local gob = c:poly{ { 344, 112 }, { 354, 112 }, { 352, 120 }, { 350, 122 }, { 350, 126 }, { 354, 128 }, { 344, 128 }, { 348, 126 }, { 348, 122 }, { 346, 120 } }
fill(gob:grow(1):cut(gob), GOLD.e); tex(gob, { e = GOLD.e, d = "#8a8aa8", s = "#a8a8c4", b = "#d4d4e6", h = "#eef0f8" }, { seed = 41 })
put(346, 114, "#c43a5a"); put(347, 114, "#c43a5a")
-- open chest with gems
local chest = c:rect(362, 132, 384, 146)
fill(chest:grow(1):cut(chest), "#2b1c26"); tex(chest, WOOD, { seed = 42 })
local lid = c:poly{ { 362, 131 }, { 366, 120 }, { 386, 118 }, { 384, 131 } }
fill(lid:grow(1):cut(lid), "#2b1c26"); tex(lid, { e = "#2b1c26", d = "#3e2830", s = "#5a3a3a", b = "#7a5048", h = "#9a6a58" }, { seed = 43 })
fill(c:rect(362, 138, 384, 139), GOLD.s); fill(c:rect(372, 136, 374, 141), GOLD.b)
for _, g in ipairs({ { 365, 133, "#4ab07a" }, { 369, 133, "#d04a6a" }, { 377, 133, "#5a8ad8" }, { 381, 133, "#4ab07a" } }) do
  fill(c:rect(g[1], g[2], g[1] + 2, g[2] + 1), g[3]); put(g[1], g[2], "#f4ecd6")
end
c:sparkle(358, 124); c:sparkle(336, 138); c:sparkle(380, 146)
-- loose coins near the path
for _, p in ipairs({ { 300, 166 }, { 306, 170 }, { 176, 172 }, { 150, 186 } }) do fill(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), GOLD.b); put(p[1], p[2], GOLD.h); put(p[1] + 2, p[2] + 1, GOLD.d) end

---------------------------------------------------------------- right near: twig nest with a giant cracked egg
shadow(368, 212, 36, 5)
local egg = HP.mask()
for y = 158, 206 do
  local t = (y - 158) / 48
  local hw = 17 * math.sqrt(math.max(0, 1 - ((t - 0.58) / (t < 0.58 and 0.58 or 0.42)) ^ 2))
  for x = math.floor(366 - hw + 0.5), math.floor(366 + hw + 0.5) do egg:set(x, y) end
end
fill(egg:grow(1):cut(egg), EGG.e)
tex(egg, EGG, { seed = 50 })
for _, s in ipairs({ { 358, 170 }, { 372, 166 }, { 362, 190 }, { 376, 184 }, { 368, 176 }, { 356, 182 } }) do
  fill(c:rect(s[1], s[2], s[1] + 2, s[2] + 1), "#5a3a6e")
end
fill(c:line({ { 368, 159 }, { 364, 165 }, { 370, 169 }, { 366, 175 } }, 1), "#2b1c26")
local nest = c:poly{ { 334, 196 }, { 400, 196 }, { 394, 210 }, { 340, 210 } }
fill(nest:grow(1):cut(nest), "#2b1c26")
tex(nest, { e = "#2b1c26", d = "#3e2830", s = "#5a3c30", b = "#7e5838", h = "#a87a4a" }, { seed = 51, dark = 0.25, fn = function(x, y, col)
  if (x - y * 2) % 6 == 0 then return "#5a3c30" end; if (x + y * 2) % 7 == 0 then return "#a87a4a" end end })
for _, t in ipairs({ { 332, 194, 340, 199 }, { 398, 193, 404, 199 }, { 338, 208, 330, 212 } }) do fill(c:line({ { t[1], t[2] }, { t[3], t[4] } }, 1), "#5a3c30") end

---------------------------------------------------------------- WILD trail leaving right edge + signpost
-- grass tufts of the living wild along the trail
for i = 0, 7 do
  local x = 410 + i * 9; local y = 150 + (i % 2) * 22 - math.floor(i * 0.6)
  fill(c:line({ { x, y }, { x - 1, y - 4 } }, 1), "#6aa05a"); fill(c:line({ { x + 1, y }, { x + 3, y - 5 } }, 1), "#8ac06a"); put(x + 2, y, "#3a6a4a")
end
-- overhanging boulder framing the gap
local boulder = c:poly{ { 404, 136 }, { 410, 112 }, { 428, 100 }, { 452, 98 }, { 470, 106 }, { 479, 112 }, { 479, 142 }, { 450, 146 }, { 420, 144 } }
shadow(444, 146, 34, 3)
fill(boulder:grow(1):cut(boulder), "#2b1c26"); tex(boulder, ROCK, { seed = 61 })
-- green moss/ivy on the boulder: the wild side
for x = 412, 476, 3 do local y = 112 + math.floor(4 * math.sin(x * 0.3)); fill(c:line({ { x, y }, { x, y + 3 + (x % 5) } }, 1), "#5a9a5a"); put(x, y, "#8ac06a") end
-- signpost
shadow(436, 206, 14, 3)
local post = c:rect(432, 160, 437, 206)
fill(post:grow(1):cut(post), "#2b1c26"); tex(post, WOOD, { seed = 62 })
local arrow = c:poly{ { 416, 166 }, { 456, 166 }, { 466, 175 }, { 456, 184 }, { 416, 184 } }
fill(arrow:grow(1):cut(arrow), "#2b1c26")
tex(arrow, { e = "#2b1c26", d = "#5a3c30", s = "#8a6040", b = "#b8884e", h = "#d8aa6a" }, { seed = 63, fn = function(x, y, col) if y % 4 == 0 then return "#a07444" end end })
-- leaf icon on the arrow (to the wild)
local leaf = c:poly{ { 428, 175 }, { 436, 169 }, { 446, 170 }, { 440, 179 }, { 430, 180 } }
fill(leaf, "#5aa05a"); fill(leaf:edge(), "#2e5a3e"); fill(c:line({ { 430, 179 }, { 443, 171 } }, 1), "#8ad06a")
fill(c:rect(424, 178, 427, 180), "#2e5a3e")

---------------------------------------------------------------- frame: rock arch (left pillar, right pillar, top lintel)
local fr = c:poly{ { 0, 0 }, { 26, 0 }, { 22, 30 }, { 26, 70 }, { 20, 120 }, { 24, 170 }, { 18, 220 }, { 22, 269 }, { 0, 269 } }
fr:add(c:poly{ { 0, 0 }, { 479, 0 }, { 479, 12 }, { 420, 16 }, { 360, 12 }, { 300, 18 }, { 240, 13 }, { 180, 17 }, { 120, 12 }, { 60, 18 }, { 0, 14 } })
fr:add(c:poly{ { 479, 0 }, { 458, 0 }, { 462, 40 }, { 456, 80 }, { 464, 112 }, { 479, 112 } })
fill(fr:grow(1):cut(fr), "#2b1c26")
tex(fr, ROCK, { seed = 70, fn = function(x, y, col) if (y + math.floor(x / 6)) % 17 == 0 then return ROCK.d end end })
-- claw marks on the left pillar too
claws(3, 140, 6, 26, 3, 5)
-- dangling dead roots
for i, x in ipairs({ 40, 96, 150, 196, 286, 318, 380, 412 }) do
  local len = 10 + math.floor(hash(i, 3, 71) * 14)
  fill(c:line({ { x, 14 }, { x + 2, 14 + len // 2 }, { x - 1, 14 + len } }, 1), "#3e2830")
end
-- hanging lantern (left) with warm glow
fill(c:line({ { 52, 16 }, { 52, 26 } }, 1), "#2b1c26")
local lan = c:rect(46, 28, 58, 44)
fill(lan:grow(1):cut(lan), "#2b1c26")
fill(lan, "#3e2830"); fill(c:rect(48, 30, 56, 42), "#f0a040"); fill(c:rect(50, 32, 54, 40), "#fcd070"); put(52, 34, "#fff0b0")
fill(c:rect(47, 35, 57, 36), "#3e2830"); fill(c:poly{ { 45, 28 }, { 52, 23 }, { 59, 28 } }, "#3e2830")
-- bone wind chime (right)
fill(c:line({ { 430, 14 }, { 430, 22 } }, 1), "#2b1c26")
fill(c:rect(420, 22, 440, 24), WOOD.b); fill(c:rect(420, 24, 440, 24), WOOD.e)
for i, x in ipairs({ 422, 428, 434, 439 }) do
  local l = 10 + (i % 2) * 6
  fill(c:line({ { x, 25 }, { x, 27 } }, 1), "#2b1c26")
  local b = c:rect(x - 1, 28, x + 1, 28 + l)
  fill(b, BONE.b); fill(c:rect(x + 1, 28, x + 1, 28 + l), BONE.s); fill(c:rect(x - 2, 28 + l, x + 2, 29 + l), BONE.b)
  put(x - 2, 29 + l, BONE.s)
end

-- v2.5.40 polish helpers (guarded: never touch stand points / compass corner)
local STANDS = { { 200, 205 }, { 285, 205 }, { 240, 178 }, { 240, 245 }, { 140, 248 }, { 340, 248 } }
local function guarded(x, y)
  for _, s in ipairs(STANDS) do if math.abs(x - s[1]) <= 16 and math.abs(y - s[2]) <= 16 then return true end end
  return x >= 378 and x < 480 and y >= 228 and y < 270
end
local function pp(x, y, hex) if x >= 0 and y >= 0 and x < W and y < H and not guarded(x, y) then c:put(x, y, hex) end end
local GROUND = { ["#6e4048"] = 1, ["#7e4c4a"] = 1, ["#8c5a4c"] = 1, ["#9a6250"] = 1, ["#6a3e44"] = 1, ["#a87060"] = 1,
  ["#b0805a"] = 1, ["#9a6a4a"] = 1, ["#7a4a48"] = 1, ["#b88a68"] = 1, ["#a07058"] = 1 }
local function gp(x, y, hex)
  if x < 0 or y < 0 or x >= W or y >= H or y < HZ + 2 or guarded(x, y) then return end
  local cur = c:get(x, y)
  if cur and GROUND[cur] then c:put(x, y, hex) end
end
local function gfill(m, hex) m:each(function(x, y) gp(x, y, hex) end) end
local function pfill(m, hex) m:each(function(x, y) pp(x, y, hex) end) end

-- v2.5.40 polish pass 1: ground variety, worn path edge, pebbles, leaves, flowers
-- dithered band seams between the three ground tones
for x = 0, W - 1 do
  for _, sy in ipairs({ 135, 175 }) do
    for k = -3, 3 do
      local y = sy + k
      if (x + y) % 2 == 0 and math.abs(k) <= 2 then gp(x, y, sy == 135 and "#7e4c4a" or "#8c5a4c") end
      if (x + y) % 2 == 1 and k == 3 then gp(x, y, sy == 135 and "#6e4048" or "#7e4c4a") end
    end
  end
end
-- soft earth blotches (2-tone dither): darker hollows and lighter dry crust
local blots = { { 60, 240, 26, 8, "#7a4a46", "#6a3e44" }, { 110, 224, 20, 6, "#9a6858", "#7e4c4a" }, { 190, 250, 16, 6, "#7a4a46", "#6a3e44" },
  { 300, 252, 22, 7, "#9a6858", "#7e4c4a" }, { 372, 226, 22, 6, "#7a4a46", "#6a3e44" }, { 430, 214, 26, 7, "#9a6858", "#7e4c4a" },
  { 24, 232, 16, 6, "#9a6858", "#7e4c4a" }, { 156, 200, 12, 5, "#7a4a46", "#6a3e44" }, { 330, 190, 18, 5, "#7a4a46", "#6a3e44" },
  { 130, 168, 22, 5, "#7e4c4a", "#6e4048" }, { 190, 166, 14, 4, "#9a6858", "#8c5a4c" } }
for _, b in ipairs(blots) do
  local m = c:ellipse(b[1], b[2], b[3], b[4])
  m:each(function(x, y)
    local inner = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / b[4]) ^ 2
    if inner < 0.55 or (x + y) % 2 == 0 then gp(x, y, b[5]) end
    if inner < 0.2 and hash(x, y, 81) < 0.3 then gp(x, y, b[6]) end
  end)
end
-- worn path edges: dirt and gravel spilling off the flagstones, scuffs leading down to the road
for y = 150, H - 1 do
  local hw = pathHalf(y)
  for _, side in ipairs({ -1, 1 }) do
    local ex = math.floor(VPX + side * (hw + 2))
    local n = hash(y, side, 82)
    if n < 0.55 then gp(ex + side * math.floor(n * 8), y, (n < 0.2) and "#b88a68" or "#7a4a48") end
    if n > 0.9 then gp(ex + side * 5, y, "#a07058"); gp(ex + side * 6, y, "#b88a68") end
  end
end
-- dirt ruts: tracks fan out of the road at the bottom
for _, side in ipairs({ -1, 1 }) do
  for y = 236, H - 1 do
    local x = math.floor(VPX + side * (pathHalf(y) + 6 + (y - 236) * 0.5))
    if (y % 3) ~= 0 then gp(x, y, "#6a3e44"); gp(x + side, y, "#7e4c4a") end
  end
end
-- pebbles (lit top-left, dark under)
local pebs = { { 70, 228 }, { 96, 244 }, { 150, 226 }, { 164, 218 }, { 182, 234 }, { 214, 258 }, { 268, 262 }, { 304, 234 }, { 322, 214 },
  { 356, 256 }, { 396, 220 }, { 420, 196 }, { 448, 224 }, { 18, 250 }, { 128, 190 }, { 330, 182 }, { 150, 166 }, { 196, 168 } }
for _, p in ipairs(pebs) do
  gp(p[1], p[2], "#a89088"); gp(p[1] + 1, p[2], "#8a7480"); gp(p[1], p[2] + 1, "#6e5a68"); gp(p[1] + 1, p[2] + 1, "#4a3448")
  if hash(p[1], p[2], 83) < 0.5 then gp(p[1] + 2, p[2] + 1, "#6e5a68") end
end
-- dead leaves drifting from the dead tree and the wind
for i = 1, 26 do
  local x = math.floor(hash(i, 5, 84) * 460) + 8
  local y = math.floor(hash(i, 6, 84) * 112) + 156
  local col = (i % 3 == 0) and "#c4783c" or ((i % 3 == 1) and "#9a5a34" or "#b8964a")
  gp(x, y, col); gp(x + 1, y, col); gp(x + 1, y + 1, "#6a3e44")
end
-- wild-side flowers beside the trail (muted dusk blooms with green stems)
local fl = { { 408, 186, "#d890c0" }, { 418, 208, "#e8c060" }, { 436, 196, "#c890e0" }, { 452, 212, "#d890c0" }, { 462, 190, "#e8c060" },
  { 444, 222, "#c890e0" }, { 404, 218, "#e8c060" }, { 468, 176, "#d890c0" }, { 396, 196, "#c890e0" } }
for _, f in ipairs(fl) do
  gp(f[1], f[2] + 1, "#4a8a4a"); gp(f[1], f[2] + 2, "#3a6a4a"); gp(f[1] - 1, f[2] + 2, "#5aa05a")
  gp(f[1], f[2], f[3]); gp(f[1] - 1, f[2], "#f4ecd6"); gp(f[1] + 1, f[2], f[3]); gp(f[1], f[2] - 1, f[3])
end

-- v2.5.40 polish pass 2: material cues (strata chips, cracks, moss, lichen, roots, scorch)
local function crack(pts, dark, lite)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
    for k = 0, n do
      local x = math.floor(a[1] + (b[1] - a[1]) * k / n + 0.5); local y = math.floor(a[2] + (b[2] - a[2]) * k / n + 0.5)
      pp(x, y, dark); pp(x + 1, y + 1, lite)
    end
  end
end
local solid = mound:copy():cut(open):cut(ring):cut(ring:grow(1)):cut(plaque:grow(1))
local function onSolid(m) return m:copy():clip(solid) end
-- mound: three deliberate cracks, chipped notches, a mossy north crown
crack({ { 196, 96 }, { 200, 104 }, { 197, 112 }, { 203, 122 } }, "#241a2c", "#8f8294")
crack({ { 292, 70 }, { 288, 78 }, { 291, 86 } }, "#241a2c", "#8f8294")
crack({ { 218, 54 }, { 213, 62 }, { 216, 68 } }, "#241a2c", "#8f8294")
for _, ch in ipairs({ { 186, 132 }, { 300, 120 }, { 204, 70 }, { 276, 52 } }) do
  pp(ch[1], ch[2], "#241a2c"); pp(ch[1] + 1, ch[2], "#241a2c"); pp(ch[1], ch[2] + 1, "#362c40")
  pp(ch[1] - 1, ch[2] - 1, "#8f8294"); pp(ch[1] + 1, ch[2] - 1, "#8f8294"); pp(ch[1] + 2, ch[2] + 1, "#4e4258")
end
solid:each(function(x, y)
  if not mound:has(x, y - 5) or (not mound:has(x - 1, y - 3) and hash(x, y, 90) < 0.7) then
    if y < 100 and hash(x, y, 91) < 0.8 then pp(x, y, (hash(x, y, 92) < 0.5) and "#5a7a48" or "#7a9a58") end
  end
end)
solid:each(function(x, y) -- moss tongues creeping down the cracks on the left flank
  if y < 80 and x < 232 and hash(x, y, 93) < 0.07 then pp(x, y, "#5a7a48"); pp(x, y + 1, "#46663e") end
end)
-- orange lichen speckles on the mound
for i = 1, 14 do
  local x = 176 + math.floor(hash(i, 1, 94) * 128); local y = 100 + math.floor(hash(i, 2, 94) * 46)
  if solid:has(x, y) and solid:has(x + 1, y) then pp(x, y, "#d8a048"); pp(x + 1, y, "#f0c868") end
end
-- extra strata ledges lit on their upper lip
for _, st in ipairs({ { 180, 120, 20 }, { 262, 132, 28 }, { 184, 140, 24 } }) do
  for k = 0, st[3] do
    local x = st[1] + k; local y = st[2] + ((k % 7 == 3) and 1 or 0)
    if solid:has(x, y) then pp(x, y, "#2e2438"); pp(x, y - 1, "#8f8294") end
  end
end
-- scorch soot licking up the arch ring and onto the keystone shadow
local soot = c:ellipse(240, 72, 20, 7):clip(ring)
soot:each(function(x, y) if (x + y) % 2 == 0 or hash(x, y, 95) < 0.3 then pp(x, y, "#3e2e44") end end)
for _, sx in ipairs({ 222, 233, 247, 258 }) do
  for k = 0, 5 do if (k + sx) % 3 ~= 0 then pp(sx, 80 - k, "#33283c") end end
end
-- scorched mouth floor and ground in front (soot fan)
local scorch = c:ellipse(240, 154, 36, 4)
scorch:each(function(x, y) if y > 150 and ((x + y) % 2 == 0) and hash(x, y, 96) < 0.7 then gp(x, y, "#5a3346") end end)
-- left pillar and lintel: crack + moss, strata chips
crack({ { 12, 40 }, { 15, 52 }, { 11, 62 } }, "#241a2c", "#8f8294")
crack({ { 14, 190 }, { 10, 200 }, { 13, 212 } }, "#241a2c", "#8f8294")
crack({ { 78, 12 }, { 80, 8 } }, "#241a2c", "#8f8294")
crack({ { 340, 10 }, { 344, 5 }, { 341, 2 } }, "#241a2c", "#8f8294")
for y = 20, 110 do
  if fr:has(3, y) and hash(3, y, 97) < 0.35 then pp(2 + math.floor(hash(y, 1, 97) * 14), y, "#5a7a48"); pp(2 + math.floor(hash(y, 2, 97) * 12), y, "#7a9a58") end
end
for x = 6, 470, 1 do
  if hash(x, 7, 98) < 0.18 and fr:has(x, 10) then pp(x, 9, "#5a7a48"); pp(x, 8, "#7a9a58") end
end
-- right pillar chips and lichen
for _, ch in ipairs({ { 466, 20 }, { 462, 60 }, { 468, 94 } }) do
  pp(ch[1], ch[2], "#241a2c"); pp(ch[1] + 1, ch[2], "#241a2c"); pp(ch[1] - 1, ch[2] - 1, "#8f8294"); pp(ch[1] + 1, ch[2] + 1, "#4e4258")
  pp(ch[1] - 3, ch[2] + 4, "#d8a048"); pp(ch[1] - 2, ch[2] + 4, "#f0c868")
end
-- boulder (wild): bedding lines, split crack, lichen, moss on the north crown
for _, ly in ipairs({ 120, 128, 136 }) do
  for x = 410, 478 do
    if boulder:has(x, ly) and ((x + ly) % 9 < 6) then pp(x, ly, "#4e4258") end
  end
end
crack({ { 452, 100 }, { 448, 108 }, { 452, 116 }, { 447, 124 } }, "#241a2c", "#8f8294")
for _, lp in ipairs({ { 420, 130 }, { 466, 126 }, { 436, 118 }, { 472, 138 } }) do
  pp(lp[1], lp[2], "#d8a048"); pp(lp[1] + 1, lp[2], "#f0c868"); pp(lp[1], lp[2] + 1, "#a87a38")
end
-- dead tree: bark fissures, flaring roots clawing the ground, a snapped branch stub
crack({ { 105, 130 }, { 107, 120 }, { 104, 108 } }, "#2b1c26", "#8e6a58")
crack({ { 110, 98 }, { 108, 88 } }, "#2b1c26", "#8e6a58")
for _, rt in ipairs({ { { 98, 150 }, { 90, 154 }, { 82, 153 } }, { { 118, 150 }, { 128, 155 }, { 136, 154 } }, { { 104, 152 }, { 100, 158 }, { 104, 162 } } }) do
  for i = 1, #rt - 1 do
    pfill(c:line({ rt[i], rt[i + 1] }, 2), "#4f3434")
  end
  pfill(c:line({ { rt[1][1], rt[1][2] - 1 }, { rt[2][1], rt[2][2] - 1 } }, 1), "#6c4a42")
end
pfill(c:rect(131, 69, 135, 72), "#c9b896"); pp(132, 70, "#f4ecd6")
pp(94, 120, "#5a7a48"); pp(95, 121, "#7a9a58"); pp(96, 119, "#5a7a48")

-- v2.5.40 polish pass 3: lived-in props (nest, stake+rag, crate, bones, gnawed sticks, fungus, tracks)
local INK = "#2b1c26"
local function pshadow(cx, cy, rx, ry) -- violet drop shadow, falls lower-right
  c:ellipse(cx + 2, cy + 1, rx, ry):each(function(x, y) if (x + y) % 2 == 0 or ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 < 0.6 then gp(x, y, "#5a3346") end end)
end
local function prop(m, r, o) -- inked, lit object painted through the guard
  pfill(m:copy():grow(1):cut(m), INK)
  m:each(function(x, y)
    local col = r.b
    if not m:has(x - 1, y) or not m:has(x, y - 1) then col = r.h
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then col = r.s end
    if o and o.fn then col = o.fn(x, y, col) or col end
    pp(x, y, col)
  end)
end
local STRAW = { b = "#d0a850", h = "#f0d078", s = "#a07a38" }
local STICK = { b = "#7e5838", h = "#a87a4a", s = "#4f3434" }
-- 1. straw-and-stick nest at the mouth (lower-left of the opening), with a worn hollow
pshadow(188, 164, 22, 3)
local nst = c:ellipse(188, 160, 20, 6)
prop(nst, STRAW, { fn = function(x, y, col)
  if (x * 2 + y) % 5 == 0 then return STRAW.s end
  if (x - y * 2) % 7 == 0 then return STRAW.h end
end })
c:ellipse(188, 160, 11, 3):each(function(x, y) pp(x, y, ((x + y) % 2 == 0) and "#7e5838" or "#5a3c30") end)
for _, t in ipairs({ { 166, 164, 180, 154 }, { 208, 156, 196, 148 }, { 174, 150, 190, 156 }, { 202, 163, 210, 158 } }) do
  pfill(c:line({ { t[1], t[2] }, { t[3], t[4] } }, 1), "#7e5838"); pp(t[1], t[2], "#a87a4a")
end
for i = 0, 6 do pp(168 + i * 6, 166 + (i % 2), STRAW.b) end -- stray straw trail
-- 2. toppled crate with spilled planks (right of path)
pshadow(316, 187, 18, 3)
local crate = c:poly{ { 304, 186 }, { 306, 174 }, { 322, 172 }, { 328, 183 }, { 326, 188 } }
prop(crate, STICK, { fn = function(x, y, col)
  if y % 5 == 0 then return STICK.s end
  if (x - 304) % 11 == 0 then return STICK.h end
end })
pfill(c:rect(309, 177, 322, 184), "#241a2c"); pfill(c:rect(311, 179, 322, 184), "#3a1e28") -- open dark mouth of crate
pfill(c:line({ { 308, 178 }, { 321, 183 } }, 1), STICK.h)
local plank = c:poly{ { 326, 190 }, { 342, 186 }, { 343, 189 }, { 327, 193 } }
prop(plank, STICK); pp(332, 189, STICK.s); pp(338, 188, STICK.s)
-- 3. warning stake with a tattered rag (left of path)
pshadow(198, 174, 8, 2)
local stake = c:poly{ { 196, 144 }, { 199, 144 }, { 199, 174 }, { 196, 174 } }
prop(stake, STICK, { fn = function(x, y, col) if y % 6 == 0 then return STICK.s end end })
pfill(c:poly{ { 200, 148 }, { 212, 150 }, { 208, 154 }, { 213, 158 }, { 205, 157 }, { 200, 160 } }, "#b83a3a")
pfill(c:line({ { 200, 148 }, { 211, 150 } }, 1), "#e86a5a")
pp(207, 156, "#8a2a34"); pp(210, 157, "#8a2a34"); pp(203, 152, "#8a2a34")
pfill(c:line({ { 200, 160 }, { 205, 157 } }, 1), "#8a2a34")
pfill(c:rect(194, 143, 200, 143), STICK.h)
for _, b in ipairs({ { 194, 150 }, { 201, 166 } }) do pp(b[1], b[2], "#c9b896"); pp(b[1] + 1, b[2], "#e2d5b6") end
-- 4. scattered bones (no skulls): femur, rib splinter, vertebra string, gnawed knuckle
local function femur(x, y, dx, dy)
  local m = c:line({ { x, y }, { x + dx, y + dy } }, 2)
  prop(m, { b = "#e2d5b6", h = "#f4ecd6", s = "#b4a288" })
  prop(c:ellipse(x, y, 2, 2), { b = "#e2d5b6", h = "#f4ecd6", s = "#b4a288" })
  prop(c:ellipse(x + dx, y + dy, 2, 2), { b = "#e2d5b6", h = "#f4ecd6", s = "#b4a288" })
end
femur(154, 214, 14, 5); femur(318, 228, 12, -4); femur(88, 252, 10, 4)
local rib = c:line({ { 334, 242 }, { 338, 236 }, { 346, 234 }, { 350, 238 } }, 2)
prop(rib, { b = "#e2d5b6", h = "#f4ecd6", s = "#b4a288" })
for i = 0, 3 do prop(c:rect(168 + i * 4, 232 + (i % 2), 170 + i * 4, 233 + (i % 2)), { b = "#d9ccae", h = "#f4ecd6", s = "#b4a288" }) end
-- 5. gnawed branches with bite notches
local function gnaw(x, y, dx, dy)
  prop(c:line({ { x, y }, { x + dx, y + dy } }, 2), STICK)
  pp(x + dx, y + dy, "#d8c090"); pp(x + dx - 1, y + dy, "#e8d8a8")
  pp(x + dx // 2, y + dy // 2 - 1, "#241a2c"); pp(x + dx // 2 + 2, y + dy // 2 + 1, "#241a2c")
end
gnaw(120, 176, 16, 6); gnaw(366, 222, 18, -5); gnaw(146, 232, 12, -6)
-- 6. glowing cave fungus (dithered cool halo; casts onto rock and ground)
local function fungus(x, y, n)
  local halo = c:ellipse(x + 2, y, 10, 5)
  halo:each(function(px, py) if (px + py) % 2 == 0 and ((px - x - 2) / 10) ^ 2 + ((py - y) / 5) ^ 2 > 0.3 then gp(px, py, "#6a6a70") end end)
  for i = 0, n - 1 do
    local fx = x + i * 4 - (i % 2); local fh = 4 + (i * 3) % 4
    prop(c:rect(fx, y - fh, fx + 2, y), { b = "#4ac8a8", h = "#b8f8e0", s = "#2a8a80" })
    pfill(c:rect(fx - 1, y - fh - 1, fx + 3, y - fh), "#58d8b8"); pp(fx, y - fh - 1, "#d8fff0")
    pfill(c:rect(fx, y, fx + 1, y + 1), "#2a8a80")
  end
end
fungus(174, 156, 3); fungus(296, 162, 2); fungus(16, 262, 3); fungus(458, 246, 2); fungus(126, 150, 2)
-- 7. tracks in the dirt: three-toe prints heading from the mouth toward the wild trail (no creature shown)
local function print3(x, y)
  pp(x, y, "#3a1e30"); pp(x + 1, y, "#3a1e30"); pp(x, y + 1, "#3a1e30"); pp(x + 1, y + 1, "#3a1e30")
  pp(x - 2, y - 2, "#3a1e30"); pp(x + 1, y - 3, "#3a1e30"); pp(x + 4, y - 2, "#3a1e30")
  pp(x - 1, y + 2, "#9a6858"); pp(x + 2, y + 2, "#9a6858")
end
for _, pt in ipairs({ { 252, 154 }, { 270, 162 }, { 292, 168 }, { 312, 156 }, { 346, 176 }, { 386, 166 }, { 120, 196 }, { 134, 206 }, { 112, 186 } }) do print3(pt[1], pt[2]) end
-- drag mark of a hauled bone across the dirt
for x = 100, 150 do local y = 202 + math.floor((x - 100) * 0.08) + ((x % 9 == 0) and 1 or 0); if x % 3 ~= 2 then gp(x, y, "#6a3e44") end end

-- v2.5.40 polish pass 4: light and depth (key light top-left, shadows lower-right, rim light, mouth glow, haze, plants)
-- cast shadows: each big prop throws a dithered violet wedge to the lower right (ground pixels only)
local function cast(m, dx, dy)
  local sh = m:copy():shift(dx, dy):cut(m)
  sh:each(function(x, y) if (x + y) % 2 == 0 or m:has(x - dx // 2, y - dy // 2) then gp(x, y, "#5a3346") end end)
  m:copy():shift(dx // 2, dy // 2):cut(m):each(function(x, y) gp(x, y, "#4a2a3e") end)
end
cast(tree:copy():clip(c:rect(90, 138, 140, 154)), 8, 3); cast(hoard, 8, 3); cast(egg, 9, 3); cast(post, 8, 3)
cast(mound:copy():clip(c:rect(150, 140, 330, 154)), 10, 4); cast(boulder, 7, 3); cast(crate, 5, 2); cast(stake, 5, 2); cast(nst, 5, 2)
-- rim light: bright top-left edge on the main props
local function rimlight(m, hex, clipm)
  m:each(function(x, y) if (not m:has(x - 1, y) and m:has(x + 1, y)) or (not m:has(x, y - 1) and m:has(x, y + 1)) then if not clipm or clipm:has(x, y) then pp(x, y, hex) end end end)
end
rimlight(tree, "#b08a70"); rimlight(egg, "#e6d8f4", c:rect(340, 156, 366, 180)); rimlight(post, "#c09870"); rimlight(hoard, "#fff0b0", c:rect(326, 118, 350, 150)); rimlight(boulder, "#a898aa")
rimlight(mound, "#a090a4", solid:copy():clip(c:rect(168, 40, 240, 150))); rimlight(sk, "#fbf4e0"); rimlight(chest, "#b08060")
-- warm hoard glow spilling out of the mouth onto the arch ring, fallen blocks, mat and nearby rock
ring:each(function(x, y)
  local d = math.sqrt(((x - 240) / 1.0) ^ 2 + ((y - 146) * 1.2) ^ 2)
  if d < 62 and ((x + y) % 2 == 0 or d < 40) and hash(x, y, 101) < 0.85 then pp(x, y, d < 40 and "#c08a68" or "#a8705e") end
end)
for _, b in ipairs({ { 284, 138, 298, 150 }, { 298, 143, 308, 151 } }) do
  for x = b[1], b[3] do for y = b[2], b[4] do if (x + y) % 2 == 0 and x - b[1] < 6 then pp(x, y, "#a8705e") end end end
end
-- cool fungus-light on the left flank rock and the dead-tree roots
for _, g in ipairs({ { 176, 146 }, { 128, 148 } }) do
  for dy = -8, 6 do for dx = -10, 10 do
    if (dx + dy) % 2 == 0 and dx * dx / 100 + dy * dy / 49 < 1 then
      local x, y = g[1] + dx, g[2] + dy
      if solid:has(x, y) then pp(x, y, "#6a7a8a") end
    end
  end end
end
-- atmospheric haze: far ridges are lighter and cooler near the horizon (dithered bands)
for y = HZ - 16, HZ - 1 do
  for x = 0, W - 1 do
    local cur = c:get(x, y)
    if cur == "#5b2d55" or cur == "#4a2846" or cur == "#3e2a3c" then
      local t = (y - (HZ - 16)) / 16
      if (x + y) % 2 == 0 and t > 0.45 and hash(x, y, 105) < 0.8 then c:put(x, y, "#6e4064") end
    end
  end
end
for y = 88, HZ - 17 do -- high ridgeline top catches a little cool light
  for x = 0, W - 1 do
    local cur = c:get(x, y); local up = c:get(x, y - 1)
    if (cur == "#5b2d55") and up and not (up == "#5b2d55" or up == "#4a2846" or up == "#3e2a3c") and x % 2 == 0 then c:put(x, y, "#7a4a6a") end
  end
end
-- the lintel throws a dithered shadow down onto the sky; pillars onto the ground
for x = 24, 458 do
  for y = 17, 22 do
    local cur = c:get(x, y)
    if cur and not fr:has(x, y) and (x + y) % 2 == 0 and y - 17 < 5 - (hash(x, 1, 102) * 2) then
      if cur ~= "#2b1c26" then pp(x, y, "#2e1a3c") end
    end
  end
end
for y = 124, 262 do
  for dx = 0, 5 do
    local x = 24 + dx
    if not fr:has(x, y) and (x + y) % 2 == 0 and dx < 4 then gp(x, y, "#5a3346") end
  end
end
-- far dead trees: break the copy-paste (one snapped, one with an extra fork)
fill(c:line({ { 356, 86 }, { 361, 82 } }, 1), "#3a2040"); put(404, 88, "#3a2040"); put(405, 87, "#3a2040"); put(406, 86, "#3a2040")
-- more plant kinds: thorn bramble, ferns, tall dry reeds, wild green shrub
local function fern(x, y, n)
  for i = -n, n do
    local len = n + 2 - math.abs(i)
    for k = 1, len do
      local fx = x + i * 2 + (i > 0 and k // 2 or -(k // 2)); local fy = y - k - (math.abs(i) == 0 and 2 or 0)
      gp(fx, fy, (k % 2 == 0) and "#4a8a4a" or "#3a6a4a"); pp(fx, fy, (k % 2 == 0) and "#5aa05a" or "#3a6a4a")
    end
  end
  for i = 0, 4 do pp(x, y - i, "#7ac06a") end
end
fern(34, 172, 2); fern(172, 192, 2); fern(60, 150, 1); fern(300, 262, 2)
local function bramble(x, y, w)
  local m = c:ellipse(x, y, w, 6); m:add(c:ellipse(x + 4, y - 4, w - 5, 5))
  prop(m, { b = "#4a3a42", h = "#6a5a58", s = "#33242e" }, { fn = function(px, py, col)
    if hash(px, py, 103) < 0.25 then return "#4a8a4a" end
    if (px * 3 + py) % 7 == 0 then return "#9a8a70" end end })
  for i = 0, w, 3 do pp(x - w + i * 2, y - 6 - (i % 2), "#9a8a70"); pp(x - w + i * 2 + 1, y - 7 - (i % 2), "#d8c8a0") end
  pp(x + 2, y - 2, "#d04a6a"); pp(x - 5, y + 1, "#d04a6a")
end
bramble(150, 164, 12)
local function reeds(x, y, n)
  for i = 0, n - 1 do
    local rx = x + i * 3; local h = 9 + (i * 5) % 6
    for k = 0, h do pp(rx + ((k > h - 4) and 1 or 0), y - k, (k > h - 3) and "#c8a860" or "#a08850") end
    pp(rx + 1, y - h, "#e8d098"); pp(rx - 1, y - 3, "#7a6a44")
  end
end
reeds(24, 200, 4); reeds(334, 160, 3); reeds(380, 156, 3)
local shrub = c:ellipse(398, 152, 8, 5)
prop(shrub, { b = "#4a8a4a", h = "#8ac06a", s = "#2e5a3e" }, { fn = function(x, y, col) if hash(x, y, 104) < 0.2 then return "#6aa05a" end end })
pp(396, 150, "#e8c060"); pp(401, 153, "#d890c0")

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. "here-lair.aseprite", png = OUT .. "here-lair.png", scale = 1 }
print("ok")
