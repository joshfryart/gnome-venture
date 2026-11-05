-- here-haven: Haven gate view (safe campsite at dusk). Hearth Pop v3, 480x270 native.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-haven" }
local INK = "#2b1c26"
local floor_, sin, abs = math.floor, math.sin, math.abs

local function h(x, y, s)
  local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return v - floor_(v)
end
local function put(x, y, col) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, col) end end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function PL(p) return c:poly(p) end
local function bb(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y)
    if x < x0 then x0 = x end; if y < y0 then y0 = y end
    if x > x1 then x1 = x end; if y > y1 then y1 = y end
  end)
  return x0, y0, x1, y1
end
-- ramp = {deep, shade, base, hi, light}; tex(x,y,lx,ly) -> offset
local function obj(m, ramp, tex, o)
  o = o or {}
  local x0, y0, x1, y1 = bb(m)
  local w, hh = math.max(1, x1 - x0), math.max(1, y1 - y0)
  local cut = o.cut or 0.74
  m:each(function(x, y)
    local t = (x - x0) / w * 0.6 + (y - y0) / hh * 0.4
    local i = 3
    if t > cut then i = 2 end
    if o.lit and t < 0.18 then i = 4 end
    if tex then i = i + (tex(x, y, x - x0, y - y0) or 0) end
    if i < 1 then i = 1 end
    if i > #ramp then i = #ramp end
    put(x, y, ramp[i])
  end)
  if o.rim then c:rim(m, o.rim) end
  if not o.noedge then c:edgeIn(m, ramp[1]) end
end
local function stoneTex(bw, bh, seed)
  return function(x, y, lx, ly)
    local row = floor_(ly / bh)
    local xx = lx + (row % 2) * floor_(bw / 2)
    if ly % bh == 0 or xx % bw == 0 then return -2 end
    local v = h(floor_(xx / bw), row, seed or 1)
    if (ly % bh == 1 or xx % bw == 1) and v > 0.3 then return 1 end
    if v > 0.75 then return 1 elseif v < 0.25 then return -1 end
    return 0
  end
end
local function plankV(pw, seed)
  return function(x, y, lx, ly)
    if lx % pw == 0 then return -2 end
    if lx % pw == 1 then return 1 end
    if h(lx, floor_(ly / 4), seed or 2) > 0.86 then return -1 end
    return 0
  end
end
local function plankH(ph, seed)
  return function(x, y, lx, ly)
    if ly % ph == 0 then return -2 end
    if ly % ph == 1 then return 1 end
    if h(floor_(lx / 5), ly, seed or 3) > 0.85 then return -1 end
    return 0
  end
end

-- palettes
local ROCK  = { "#3b3048", "#5a4a63", "#7a6676", "#9c8790", "#c0a3a0" }
local STONE = { "#4a3f4c", "#6c5f6c", "#8c7f88", "#ab9ea4", "#c9bcbc" }
local TIMB  = { "#3e2619", "#5f3a24", "#7e5232", "#a06d42", "#c18c58" }
local DARKW = { "#2e1d1e", "#3e2828", "#4f3431", "#64443a", "#7a5644" }
local TEAL  = { "#1f3f46", "#2c5c63", "#3f7f86", "#5ea3a6", "#86c4bf" }

------------------------------------------------------------------ sky
c:stripes(0, 111, { "#3a2d5c", "#4c3868", "#664574", "#8a5379", "#b4627a", "#d87f6e", "#ee9f6a", "#f6c27c" },
  { 14, 14, 14, 14, 13, 13, 12, 18 })
for i = 1, 26 do
  local sx, sy = floor_(h(i, 1, 9) * 460) + 10, floor_(h(i, 2, 9) * 40) + 14
  put(sx, sy, "#fbe9c6")
  if i % 5 == 0 then put(sx - 1, sy, "#d9c3d8"); put(sx + 1, sy, "#d9c3d8"); put(sx, sy - 1, "#d9c3d8"); put(sx, sy + 1, "#d9c3d8") end
end
c:cloud(30, 70, 64, "#f0a88e", "#a45e78")
c:cloud(300, 52, 80, "#eea08c", "#9a5876")
c:cloud(170, 40, 44, "#e2948e", "#8e5276")
c:cloud(400, 82, 50, "#f6b88c", "#b06a78")

------------------------------------------------------------------ far mountains + hills + pines
local mtn = c:terrain(function(x) return floor_(76 + 8 * sin(x / 41) + 5 * sin(x / 17 + 1)) end, "#6a5280", 111)
for x = 0, W - 1 do
  local y = floor_(76 + 8 * sin(x / 41) + 5 * sin(x / 17 + 1))
  if (floor_(76 + 8 * sin((x - 1) / 41) + 5 * sin((x - 1) / 17 + 1))) >= y then put(x, y, "#a77a92"); put(x, y + 1, "#8a6690") end
end
c:terrain(function(x) return floor_(95 + 5 * sin(x / 29 + 2) + 3 * sin(x / 11)) end, "#475262", 111)
local function pine(px, by, ht, wd, body, lit)
  for tier = 0, 2 do
    local ty = by - ht + floor_(tier * ht / 3.2)
    local hw = floor_(wd * (0.55 + tier * 0.25))
    local bot = ty + floor_(ht * 0.5)
    local m = PL{ { px, ty }, { px + hw, bot }, { px - hw, bot } }
    m:each(function(x, y) put(x, y, x < px - 1 and lit or body) end)
  end
  c:fillMask(R(px - 1, by - 3, px + 1, by), "#2a2a30")
end
local pines = { { 18, 108, 34, 9 }, { 40, 104, 26, 7 }, { 66, 106, 30, 8 }, { 96, 102, 22, 6 }, { 128, 104, 26, 7 },
  { 352, 104, 24, 7 }, { 368, 108, 30, 8 }, { 470, 104, 28, 8 }, { 140, 108, 20, 6 } }
for _, p in ipairs(pines) do pine(p[1], p[2], p[3], p[4], "#2c4040", "#3f5a52") end

------------------------------------------------------------------ cliff with cosy cave (far, centre)
local cliff = PL{ { 152, 111 }, { 160, 84 }, { 176, 64 }, { 204, 50 }, { 236, 44 }, { 268, 48 }, { 298, 60 }, { 322, 80 }, { 338, 111 } }
obj(cliff, ROCK, function(x, y, lx, ly)
  local v = stoneTex(14, 9, 4)(x, y, lx, ly)
  if v == -2 and h(x, y, 5) > 0.5 then v = -1 end
  if x < 196 + ly * 0.3 and v == 0 then v = 1 end -- warm west face
  return v
end, { cut = 0.7 })
-- moss + vines on cliff top
for x = 170, 320 do
  local top
  for y = 40, 111 do if cliff:has(x, y) then top = y break end end
  if top then
    put(x, top, "#5f7a48"); put(x, top + 1, "#4a6440")
    if h(x, 1, 7) > 0.8 then for k = 2, 4 + floor_(h(x, 2, 7) * 8) do put(x, top + k, k % 2 == 0 and "#4a6440" or "#5f7a48") end end
  end
end
local cave = PL{ { 212, 111 }, { 214, 88 }, { 222, 76 }, { 232, 70 }, { 248, 70 }, { 258, 76 }, { 266, 88 }, { 268, 111 } }
c:rim(cave, "#3b3048")
cave:each(function(x, y)
  local col = "#2e1d26"
  if y > 92 then col = "#4a2a2a" end
  if y > 100 then col = "#6e3a2c" end
  if y > 106 then col = "#9a5530" end
  put(x, y, col)
end)
c:edgeIn(cave, "#24171f")
-- cave lantern + cot + rug
c:fillMask(R(240, 71, 240, 79), "#3a2a22")
c:fillMask(R(236, 80, 244, 81), "#3a2a22")
c:fillMask(R(237, 82, 243, 89), "#f2c75c"); c:fillMask(R(239, 83, 240, 86), "#fff0a8")
c:fillMask(R(236, 90, 244, 90), "#3a2a22")
c:fillMask(R(218, 99, 236, 103), "#c0473f"); c:fillMask(R(218, 99, 222, 101), "#efe0c0"); c:fillMask(R(218, 104, 236, 106), "#5f3a24")
c:fillMask(R(246, 106, 262, 109), "#d08a3a"); for x = 246, 262, 3 do put(x, 107, "#8a4a2a") end
for x = 214, 266 do put(x, 111, "#b06a34") end

------------------------------------------------------------------ ground
local GR = { { 112, "#3f4b3c" }, { 122, "#4a573e" }, { 140, "#55633f" }, { 170, "#5e6c41" }, { 210, "#667444" } }
local FX, FY = 136, 210
for y = 112, H - 1 do
  local col = GR[1][2]
  for _, g in ipairs(GR) do if y >= g[1] then col = g[2] end end
  for x = 0, W - 1 do
    local cc = col
    local d = ((x - FX) / 120) ^ 2 + ((y - FY) / 50) ^ 2
    if d < 1 then cc = (d < 0.45) and "#7c7a44" or "#717443" end
    local r = h(x, y, 11)
    if r > 0.94 and y > 120 then cc = "#7f8d50" elseif r < 0.05 then cc = "#3d4834" end
    put(x, y, cc)
  end
end
-- grass tufts (V shapes) sparsely, away from the path centre
for i = 1, 140 do
  local tx, ty = floor_(h(i, 3, 12) * 470) + 5, floor_(h(i, 4, 12) * 150) + 118
  local s = ty > 200 and 3 or 2
  put(tx, ty, "#3d4834"); put(tx - 1, ty - s + 1, "#82904f"); put(tx + 1, ty - s, "#82904f"); put(tx, ty - 1, "#6a7a46")
end

------------------------------------------------------------------ side trail to the wild (behind main path)
local trail = PL{ { 248, 114 }, { 380, 116 }, { 420, 120 }, { 420, 126 }, { 380, 125 }, { 256, 126 } }
obj(trail, { "#5a4232", "#7d5a40", "#8f6d4f", "#a8845e" }, function(x, y) local v = h(x, y, 13); return v > 0.85 and 1 or (v < 0.12 and -1 or 0) end, { noedge = true })

------------------------------------------------------------------ main flagstone path
local function xl(y) return 150 + 78 * (269 - y) / 157 end
local function xr(y) return 360 - 108 * (269 - y) / 157 end
local K = 1785
local SC = { "#a88f78", "#b39a80", "#9c836e", "#bfa588", "#a7937e" }
for y = 112, H - 1 do
  local a, b = xl(y), xr(y)
  local z, z2 = K / (y - 100), K / (y + 1 - 100)
  local row = floor_(z)
  local rowH = (y - 100) ^ 2 / K
  for x = floor_(a), floor_(b) do
    local u = (x - a) / (b - a)
    local cols = 6
    local cu = u * cols + (row % 2) * 0.5
    local col = floor_(cu)
    local cu2 = (x + 1 - a) / (b - a) * cols + (row % 2) * 0.5
    local cc = SC[1 + floor_(h(col, row, 14) * 5)]
    local jointH = rowH >= 3 and floor_(z2) ~= row
    local jointV = rowH >= 3 and floor_(cu2) ~= col
    if x == floor_(a) or x == floor_(b) then cc = "#5a4636"
    elseif jointH or jointV then cc = "#6b5547"
    elseif rowH < 3 then
      local v = h(x, y, 15); cc = v > 0.8 and "#b8a084" or (v < 0.2 and "#8a705c" or "#a08670")
    else
      -- top-left highlight of each stone, lower-right shade
      local zt = K / (y - 1 - 100)
      local leftJ = floor_((x - 1 - a) / (b - a) * cols + (row % 2) * 0.5) ~= col
      if floor_(zt) ~= row or leftJ then cc = "#cdb497" end
      if h(x, y, 16) > 0.93 then cc = "#8a705c" end
    end
    put(x, y, cc)
  end
end
-- grass spilling over path edges
for y = 116, H - 1, 3 do
  for _, ex in ipairs({ floor_(xl(y)), floor_(xr(y)) }) do
    if h(ex, y, 17) > 0.45 then put(ex, y, "#6a7a46"); put(ex, y - 1, "#82904f") end
  end
end

------------------------------------------------------------------ far right: woodpile shed (props tier 2)
local shed = PL{ { 282, 92 }, { 348, 92 }, { 352, 98 }, { 278, 98 } }
local pileShadow = R(282, 122, 350, 125); c:fillMask(pileShadow, "#3a4535")
c:rim(R(284, 98, 346, 122), INK)
obj(R(284, 98, 346, 122), DARKW, plankV(9, 18))
for r = 0, 3 do
  local y0 = 101 + r * 5
  for k = 0, 9 do
    local lx = 287 + k * 6 + (r % 2) * 3
    if lx + 4 <= 343 then
      local m = R(lx, y0, lx + 4, y0 + 4)
      m:each(function(x, y)
        local col = "#d9b07a"
        if x == lx or y == y0 or x == lx + 4 or y == y0 + 4 then col = "#6b4a32" end
        if x == lx + 2 and y == y0 + 2 then col = "#a77a4a" end
        put(x, y, col)
      end)
    end
  end
end
c:fillMask(R(284, 98, 287, 122), TIMB[3]); c:fillMask(R(343, 98, 346, 122), TIMB[2])
c:rim(shed, INK); obj(shed, { "#3e2a2a", "#5c3a30", "#7a4a36", "#9a6444" }, plankV(6, 19), { lit = true })
-- stump with axe (quirk)
c:rim(R(352, 112, 364, 124), INK)
obj(R(352, 112, 364, 124), TIMB, plankV(4, 20))
c:fillMask(R(352, 112, 364, 113), "#d9b07a")
c:fillMask(PL{ { 356, 104 }, { 358, 104 }, { 360, 112 }, { 358, 112 } }, "#a06d42")
c:fillMask(PL{ { 353, 103 }, { 359, 102 }, { 359, 106 }, { 354, 107 } }, "#8a8f9a"); put(354, 104, "#c9ccd4")

------------------------------------------------------------------ WILD: rock arch to the forest (right, mid)
local inner = R(404, 86, 442, 126)
inner:each(function(x, y)
  local col = "#22352d"
  if y > 104 then col = "#2b4436" end
  if h(floor_(x / 5), floor_(y / 4), 21) > 0.6 then col = "#33503e" end
  put(x, y, col)
end)
local deepTrail = PL{ { 418, 104 }, { 426, 104 }, { 440, 126 }, { 408, 126 } }
deepTrail:each(function(x, y) put(x, y, y < 112 and "#5a4636" or "#7d5a40") end)
for i = 1, 9 do put(406 + floor_(h(i, 5, 22) * 34), 90 + floor_(h(i, 6, 22) * 18), "#f2e27a") end -- fireflies
local lp = PL{ { 384, 126 }, { 386, 92 }, { 392, 82 }, { 402, 80 }, { 408, 88 }, { 408, 126 } }
local rp = PL{ { 438, 126 }, { 440, 88 }, { 446, 78 }, { 456, 80 }, { 464, 90 }, { 466, 126 } }
local lint = PL{ { 390, 88 }, { 398, 74 }, { 414, 68 }, { 434, 68 }, { 450, 74 }, { 458, 84 }, { 444, 90 }, { 424, 86 }, { 404, 90 } }
local arch = lp:copy():add(rp):add(lint)
c:rim(arch, INK)
obj(arch, { "#35304a", "#55506e", "#76708c", "#9a93ac", "#bdb6c8" }, stoneTex(10, 8, 23), { lit = true })
-- ivy on arch
for i = 1, 30 do
  local ax, ay = 392 + floor_(h(i, 7, 24) * 66), 70 + floor_(h(i, 8, 24) * 18)
  if arch:has(ax, ay) then put(ax, ay, "#4f7a44"); put(ax + 1, ay, "#6a9a52"); put(ax, ay + 1, "#3b5e3a") end
end
-- signpost with arrow board (pine icon) pointing right
local post = R(372, 92, 375, 127)
c:rim(post, INK); obj(post, TIMB, nil)
local arrow = PL{ { 362, 94 }, { 392, 94 }, { 400, 100 }, { 392, 106 }, { 362, 106 } }
c:rim(arrow, INK); obj(arrow, { "#5f3a1c", "#8a5428", "#b07a46", "#d09a5e" }, plankH(6, 25), { lit = true })
c:fillMask(PL{ { 380, 96 }, { 385, 104 }, { 375, 104 } }, "#3f6a44"); put(379, 99, "#5e8f56"); put(380, 104, "#5f3a24")
c:fillMask(R(366, 99, 371, 100), "#5f3a1c")
c:fillMask(PL{ { 388, 97 }, { 392, 100 }, { 388, 103 } }, "#5f3a1c")

------------------------------------------------------------------ SHOP: supply cart (right, near)
c:fillMask(PL{ { 332, 202 }, { 444, 202 }, { 440, 212 }, { 336, 212 } }, "#3e4433")
-- log rollers instead of wheels (quirk)
for _, rx in ipairs({ 350, 408 }) do
  local roll = R(rx, 198, rx + 26, 207)
  c:rim(roll, INK)
  obj(roll, { "#4a2e1e", "#6b4a32", "#8a6040", "#a87a50" }, plankH(3, 26))
  c:fillMask(R(rx + 23, 199, rx + 26, 206), "#d9b07a"); put(rx + 25, 202, "#a77a4a")
end
-- shafts resting on ground
local shafts = c:line({ { 346, 184 }, { 334, 204 } }, 3):add(c:line({ { 354, 186 }, { 342, 206 } }, 3))
c:rim(shafts, INK); c:fillMask(shafts, "#8a5a34")
local body = R(342, 166, 436, 198)
c:rim(body, INK); obj(body, TEAL, plankH(8, 27), { lit = true })
c:fillMask(R(342, 166, 436, 168), "#7e5232"); c:fillMask(R(342, 166, 436, 166), "#a06d42")
-- posts
for _, px in ipairs({ 345, 431 }) do local p = R(px, 140, px + 3, 166); c:rim(p, INK); obj(p, TIMB, nil) end
-- goods on the counter
local function crate(x0, y0, w, hh, col)
  local m = R(x0, y0, x0 + w, y0 + hh); c:rim(m, INK)
  obj(m, col, function(x, y, lx, ly) if lx == floor_(w / 2) or ly == floor_(hh / 2) then return -1 end; return 0 end, { lit = true })
end
crate(352, 150, 18, 15, { "#5f3a1c", "#8a5428", "#b5824a", "#d4a46a" })
local sack = PL{ { 376, 165 }, { 374, 156 }, { 378, 150 }, { 382, 147 }, { 386, 150 }, { 390, 156 }, { 388, 165 } }
c:rim(sack, INK); obj(sack, { "#7a6248", "#a68a64", "#cdb38a", "#e6d4ae" }, function(x, y) return h(x, y, 28) > 0.85 and -1 or 0 end, { lit = true })
c:fillMask(R(379, 151, 385, 152), "#7a4a2a")
-- jars
for k = 0, 2 do
  local jx = 394 + k * 7
  local j = R(jx, 156, jx + 5, 165); c:rim(j, INK)
  obj(j, { "#2a5470", "#3f7aa0", "#6fa8c8", "#a8d4e4" }, nil, { lit = true })
  c:fillMask(R(jx, 154, jx + 5, 155), k == 1 and "#c0473f" or "#d9a441"); put(jx + 1, 158, "#e4f2f4")
end
-- loaves basket
local bask = R(416, 158, 430, 165); c:rim(bask, INK)
obj(bask, { "#5f3a1c", "#8a5a2c", "#b07a40", "#cf9a5a" }, function(x, y) return (x + y) % 3 == 0 and -1 or 0 end)
c:fillMask(PL{ { 417, 157 }, { 421, 153 }, { 425, 153 }, { 429, 157 } }, "#c98a3c"); put(421, 154, "#ecbc6c")
-- canopy (mustard + cream stripes, sawtooth hem)
local can = PL{ { 336, 150 }, { 344, 132 }, { 434, 132 }, { 442, 150 } }
c:rim(can, INK)
local cx0 = 336
can:each(function(x, y)
  local s = floor_((x - 236 - (y - 132) * 0.0) / 10) % 2
  local col = s == 0 and "#e0a83a" or "#f4e6c8"
  if y > 145 then col = s == 0 and "#b87e2a" or "#d8c6a6" end
  if y == 132 then col = s == 0 and "#f2c45a" or "#fff4dc" end
  put(x, y, col)
end)
c:edgeIn(can, "#8a5420")
for x = 338, 440 do
  local t = (x - 338) % 8
  local d = t < 4 and t or 7 - t
  for k = 1, d do put(x, 150 + k, (floor_((x - 236) / 10) % 2 == 0) and "#b87e2a" or "#d8c6a6") end
  put(x, 151 + d, INK)
end
-- shop sign on cart front: sack/backpack icon on cream board
local sb = R(376, 172, 402, 192)
c:rim(sb, "#5f3a24"); obj(sb, { "#a68a64", "#d8c6a6", "#efe0c0", "#fff4dc" }, nil)
c:paint({
  "....oooo....",
  "...o....o...",
  "..oooooooo..",
  ".obbbbbbbbo.",
  ".obbyybbbbo.",
  ".obbbbbbbbo.",
  ".obggggggbo.",
  ".obgbbbbgbo.",
  ".obggggggbo.",
  ".obbbbbbbbo.",
  "..oooooooo..",
}, 383, 176, { o = "#4a2c1e", b = "#b06a3a", y = "#e8b860", g = "#7a4426" })
-- boot planter (quirk)
local boot = PL{ { 420, 190 }, { 426, 190 }, { 426, 200 }, { 432, 200 }, { 432, 205 }, { 420, 205 } }
boot = R(418, 186, 425, 204):add(R(418, 199, 432, 204))
c:rim(boot, INK); obj(boot, { "#3a2a2a", "#5a3a2e", "#7a4e36", "#9a6a4a" }, nil, { lit = true })
c:fillMask(R(419, 182, 420, 186), "#4f7a44"); c:fillMask(R(423, 181, 424, 186), "#6a9a52")
c:fillMask(R(418, 178, 421, 181), "#e86a8a"); put(419, 179, "#f4d24a")

------------------------------------------------------------------ FIRE: stone-and-timber lean-to shelter (left, near)
c:fillMask(PL{ { 14, 206 }, { 166, 206 }, { 172, 218 }, { 10, 218 } }, "#3e4433")
-- interior back wall (log planks, warm lamplight)
local back = R(40, 112, 152, 200)
obj(back, { "#2e1d1e", "#4a2c2a", "#5e3a32", "#76503e", "#8f6448" }, plankH(7, 30), { noedge = true })
-- warm light on back wall around lantern
for y = 120, 150 do for x = 70, 128 do
  local d = ((x - 98) / 30) ^ 2 + ((y - 126) / 18) ^ 2
  if d < 1 and (y % 7 ~= 0) then put(x, y, d < 0.4 and "#a87048" or "#8a5a40") end
end end
-- bunks
local function bunk(x0, x1, q1, q2, q3)
  for _, py in ipairs({ { 148, 156 }, { 180, 188 } }) do
    local m = R(x0 + 3, py[1], x1 - 3, py[2])
    -- mattress + quilt patchwork
    m:each(function(x, y)
      local col = ((floor_((x - x0) / 7) + floor_((y - py[1]) / 4)) % 2 == 0) and q1 or q2
      if y == py[1] then col = q3 end
      put(x, y, col)
    end)
    c:fillMask(R(x0 + 4, py[1] - 3, x0 + 14, py[1] + 2), "#efe0c0"); c:fillMask(R(x0 + 4, py[1] - 3, x0 + 14, py[1] - 3), "#fff4dc")
    put(x0 + 13, py[1] + 2, "#c9b48e")
    local rail = R(x0, py[2] + 1, x1, py[2] + 4)
    obj(rail, TIMB, nil, { lit = true })
  end
  for _, px in ipairs({ x0, x1 - 3 }) do obj(R(px, 136, px + 3, 200), TIMB, nil, { lit = true }) end
end
bunk(46, 94, "#c0473f", "#e0b04a", "#d8685a")
bunk(104, 148, "#3f8f8a", "#e6d3a8", "#5eb0a6")
-- tiny ladder on bunk B
for y = 160, 186, 6 do c:fillMask(R(140, y, 146, y + 1), "#c18c58") end
-- interior lantern
c:fillMask(R(98, 106, 98, 116), "#3a2a22")
c:fillMask(R(94, 117, 102, 118), "#3a2a22"); c:fillMask(R(95, 119, 101, 127), "#f2c75c"); c:fillMask(R(97, 120, 98, 124), "#fff0a8")
c:fillMask(R(94, 128, 102, 128), "#3a2a22")
-- left stone wall
local lw = R(14, 108, 40, 202)
c:rim(lw, INK); obj(lw, STONE, stoneTex(9, 7, 31), { lit = true })
-- timber posts (middle + right) and floor plinth
for _, px in ipairs({ 98, 150 }) do
  local p = R(px, 104, px + 6, 202); c:rim(p, INK); obj(p, TIMB, plankV(7, 32), { lit = true })
end
local plinth = R(12, 200, 164, 210)
c:rim(plinth, INK); obj(plinth, STONE, stoneTex(12, 5, 33))
-- roof: sod-topped plank lean-to, rising to the right
local roof = PL{ { 6, 110 }, { 176, 86 }, { 180, 102 }, { 10, 126 } }
c:rim(roof, INK)
obj(roof, { "#3e2a22", "#5c3c2c", "#7a5038", "#98684a", "#b5835c" }, function(x, y, lx, ly)
  if lx % 10 == 0 then return -2 end
  if lx % 10 == 1 then return 1 end
  if h(lx, floor_(ly / 3), 34) > 0.88 then return -1 end
  return 0
end, { lit = true })
for x = 6, 178 do
  local top = floor_(110 - (x - 6) * 24 / 170)
  put(x, top - 1, "#5f7a48"); put(x, top, "#6f8f50"); put(x, top + 1, "#4a6440")
  if h(x, 3, 35) > 0.72 then put(x, top - 2, "#7f9f58") end
  if h(x, 4, 35) > 0.93 then put(x, top - 3, "#e86a8a"); put(x, top - 2, "#4f7a44") end
end
-- gnome-hat weathervane (quirk)
c:fillMask(R(160, 68, 161, 88), "#4a3a3a")
local hat = PL{ { 154, 80 }, { 160, 62 }, { 168, 80 } }
c:rim(hat, INK); obj(hat, { "#6a1e22", "#9a2c2c", "#c0473f", "#e0705a" }, nil, { lit = true })
c:fillMask(R(153, 80, 169, 82), "#8a5a34")
-- moon sign on left wall (rest icon)
local ms = R(18, 132, 36, 150)
c:rim(ms, INK); obj(ms, { "#24305a", "#2e3c6c", "#3a4a80", "#4c5e98" }, nil)
c:paint({
  "...yyy...",
  "..yy.....",
  ".yy......",
  ".yy......",
  ".yy......",
  "..yy.....",
  "...yyy...",
}, 21, 136, { y = "#f4d24a" })
put(31, 137, "#fbe9c6"); put(29, 141, "#fbe9c6"); put(32, 143, "#d9c3d8")
c:fillMask(R(22, 128, 22, 131), "#4a3a3a"); c:fillMask(R(32, 128, 32, 131), "#4a3a3a")
-- clothesline with sock (quirk)
for x = 157, 172 do put(x, 128 + floor_((x - 157) / 6), "#d8c6a6") end
c:fillMask(R(171, 124, 172, 140), "#5f3a24")
c:paint({
  "rrrr",
  "wwww",
  "rrrr",
  "rrrr",
  "wwww",
  "rrrrr.",
  "rrrrrr",
  ".rrrrr",
}, 162, 130, { r = "#c0473f", w = "#efe0c0" })

-- hearth fire in front of the shelter
local hearth = PL{ { 108, 208 }, { 116, 202 }, { 154, 202 }, { 162, 208 }, { 162, 216 }, { 154, 222 }, { 116, 222 }, { 108, 216 } }
c:rim(hearth, INK)
obj(hearth, STONE, function(x, y, lx, ly) if lx % 9 == 0 or ly % 7 == 0 then return -2 end; return h(floor_(lx / 9), floor_(ly / 7), 36) > 0.6 and 1 or 0 end, { lit = true })
local pit = PL{ { 118, 206 }, { 152, 206 }, { 156, 210 }, { 152, 216 }, { 118, 216 }, { 114, 210 } }
c:fillMask(pit, "#3a2424")
c:fillMask(c:line({ { 118, 214 }, { 150, 206 } }, 3), "#5f3a24"); c:fillMask(c:line({ { 118, 206 }, { 150, 214 } }, 3), "#7a4a2a")
for x = 120, 150, 4 do put(x, 213, "#f08a2c") end
local function flame(cx, top, bot, hw, col)
  local m = PL{ { cx, top }, { cx + floor_(hw * 0.6), top + floor_((bot - top) * 0.45) }, { cx + hw, bot }, { cx - hw, bot }, { cx - floor_(hw * 0.7), top + floor_((bot - top) * 0.5) } }
  c:fillMask(m, col)
end
flame(126, 188, 211, 9, "#d9482b"); flame(144, 190, 211, 8, "#d9482b"); flame(135, 180, 211, 12, "#d9482b")
flame(135, 186, 210, 9, "#f08a2c"); flame(127, 194, 210, 6, "#f08a2c"); flame(143, 195, 210, 5, "#f08a2c")
flame(135, 193, 209, 5, "#ffd35a"); flame(135, 200, 208, 3, "#fff1b0")
for i = 1, 8 do put(118 + floor_(h(i, 9, 37) * 36), 168 + floor_(h(i, 10, 37) * 18), i % 2 == 0 and "#ffd35a" or "#f08a2c") end
-- tripod + kettle (quirk: whistling kettle with steam)
c:fillMask(c:line({ { 112, 220 }, { 135, 166 } }, 2), "#4a3a3a"); c:fillMask(c:line({ { 158, 220 }, { 135, 166 } }, 2), "#3a2a2a")
c:fillMask(R(135, 166, 135, 172), "#4a3a3a")
local kettle = PL{ { 129, 176 }, { 141, 176 }, { 143, 180 }, { 141, 184 }, { 129, 184 }, { 127, 180 } }
c:rim(kettle, INK); obj(kettle, { "#6a2e1e", "#9a4a2a", "#c56a3a", "#e4935a" }, nil, { lit = true })
c:fillMask(R(130, 173, 140, 174), "#4a3a3a"); put(130, 175, "#4a3a3a"); put(140, 175, "#4a3a3a")
c:fillMask(c:line({ { 143, 179 }, { 148, 175 } }, 1), "#9a4a2a")
c:fillMask(R(149, 170, 151, 172), "#d8d0e0"); c:fillMask(R(152, 165, 155, 168), "#d8d0e0"); put(153, 165, "#efe6f0")
c:fillMask(R(156, 158, 160, 161), "#c8c0d6"); put(157, 158, "#e6dcea")
-- mushroom stool (quirk)
c:fillMask(R(84, 210, 89, 218), "#efe0c0"); c:fillMask(R(84, 216, 89, 218), "#c9b48e")
local cap = PL{ { 78, 210 }, { 81, 205 }, { 92, 205 }, { 95, 210 } }
c:rim(cap, INK); obj(cap, { "#6a1e22", "#9a2c2c", "#c0473f", "#e0705a" }, nil, { lit = true })
put(83, 207, "#fff4dc"); put(89, 206, "#fff4dc"); put(86, 208, "#fff4dc")
-- log bench in front
local bench = R(26, 226, 96, 236)
c:fillMask(R(24, 237, 98, 240), "#3e4433")
c:rim(bench, INK); obj(bench, { "#3e2619", "#5f3a24", "#7e5232", "#a06d42" }, plankH(4, 38), { lit = true })
c:fillMask(R(26, 226, 96, 227), "#c18c58")
c:fillMask(R(94, 227, 96, 235), "#d9b07a"); put(95, 230, "#a77a4a")
c:fillMask(R(48, 223, 54, 225), "#6a8f9a"); c:fillMask(R(49, 222, 53, 222), "#8ab0bc") -- forgotten mug

------------------------------------------------------------------ gate frame (timber posts + beam + pine boughs + lanterns)
local lpost, rpost = R(0, 0, 11, H - 1), R(468, 0, W - 1, H - 1)
local beam = R(0, 0, W - 1, 11)
local frame = lpost:copy():add(rpost)
c:rim(frame, INK)
obj(lpost, TIMB, plankV(6, 40), { lit = true })
obj(rpost, TIMB, plankV(6, 41))
c:rim(beam, INK)
obj(beam, TIMB, plankH(6, 42), { lit = true })
for _, b in ipairs({ { 12, 12, 34, 34 }, { 467, 12, 445, 34 } }) do
  local m = c:line({ { b[1], b[4] }, { b[3], b[2] } }, 4)
  c:rim(m, INK); c:fillMask(m, "#7e5232"); c:edgeIn(m, "#5f3a24")
end
-- pine boughs
local function bough(x0, y0, dir, len)
  for k = 0, len do
    local bx, by = x0 + dir * k, y0 + floor_(k * 0.35)
    put(bx, by, "#4a3a2a")
    if k % 2 == 0 then
      for n = 1, 5 do
        put(bx - dir * floor_(n * 0.4), by + n, n < 3 and "#4f7a55" or "#2f5a44")
        put(bx + dir * floor_(n * 0.6), by + n, "#3b6a4c")
      end
    end
  end
end
bough(12, 10, 1, 60); bough(30, 12, 1, 34); bough(467, 10, -1, 60); bough(450, 12, -1, 34)
-- lanterns
local function lantern(lx, ly)
  for y = 12, ly - 1, 2 do put(lx, y, "#3a2a22") end
  local capm = PL{ { lx - 3, ly }, { lx + 3, ly }, { lx + 6, ly + 4 }, { lx - 6, ly + 4 } }
  c:rim(capm, INK); c:fillMask(capm, "#4a3a3a")
  local g = R(lx - 5, ly + 5, lx + 5, ly + 18)
  c:rim(g, INK); c:fillMask(g, "#f2c75c"); c:fillMask(R(lx - 3, ly + 7, lx - 1, ly + 14), "#fff0a8")
  c:fillMask(R(lx, ly + 5, lx, ly + 18), "#3a2a22"); c:fillMask(R(lx + 3, ly + 8, lx + 4, ly + 17), "#d9a441")
  c:fillMask(R(lx - 6, ly + 19, lx + 6, ly + 20), "#4a3a3a")
end
lantern(56, 24); lantern(424, 24)
-- charm: hanging iron horseshoe + herb bundle
for y = 12, 19, 2 do put(240, y, "#3a2a22") end
c:paint({
  "ooo...ooo",
  "oho...ooo",
  "oho...ooo",
  "oho...ooo",
  "ooho.ooo.",
  ".ooooooo.",
  "..ooooo..",
}, 236, 20, { o = "#6a6f7a", h = "#b8bcc8" })
for y = 12, 17, 2 do put(150, y, "#3a2a22"); put(330, y, "#3a2a22") end
for _, hx in ipairs({ 150, 330 }) do
  c:fillMask(R(hx - 1, 18, hx + 1, 19), "#c0473f")
  for k = 0, 7 do put(hx - 3 + (k % 3) * 3, 20 + floor_(k / 2), k % 2 == 0 and "#6a9a52" or "#4f7a44"); put(hx - 2 + (k % 3) * 2, 21 + floor_(k / 2), "#8a6aa8") end
end

------------------------------------------------------------------ v2.5.40 polish pass 1: ground variety, worn path, flowers, pebbles
local GROUND = { ["#3f4b3c"]=1, ["#4a573e"]=1, ["#55633f"]=1, ["#5e6c41"]=1, ["#667444"]=1, ["#7c7a44"]=1, ["#717443"]=1,
  ["#7f8d50"]=1, ["#3d4834"]=1, ["#82904f"]=1, ["#6a7a46"]=1 }
local STANDS = { { 200, 252 }, { 292, 252 }, { 352, 242 }, { 250, 205 }, { 250, 152 }, { 198, 188 } }
local function guarded(x, y)
  for _, s in ipairs(STANDS) do if abs(x - s[1]) <= 17 and abs(y - s[2]) <= 17 then return true end end
  return x >= 376 and y >= 226
end
-- paint only onto bare ground pixels, never in the protected zones
local function gp(x, y, col)
  if x < 12 or x > 467 or y < 113 or y >= H or guarded(x, y) then return false end
  local cur = c:get(x, y)
  if cur and GROUND[string.lower(cur)] then put(x, y, col) return true end
  return false
end
-- dithered mottling: darker lush patches and sunlit warm patches
local patches = { { 60, 250, 40, 14, "d" }, { 30, 160, 22, 10, "l" }, { 290, 140, 40, 9, "l" }, { 440, 150, 26, 12, "d" },
  { 190, 150, 12, 14, "d" }, { 300, 225, 30, 14, "l" }, { 90, 125, 34, 6, "d" }, { 420, 215, 30, 8, "l" }, { 440, 120, 20, 5, "d" },
  { 120, 262, 50, 7, "d" }, { 330, 262, 40, 8, "d" }, { 215, 128, 16, 6, "l" } }
for _, p in ipairs(patches) do
  for y = p[2] - p[4], p[2] + p[4] do for x = p[1] - p[3], p[1] + p[3] do
    local d = ((x - p[1]) / p[3]) ^ 2 + ((y - p[2]) / p[4]) ^ 2
    if d < 1 then
      local ch = (x + y) % 2 == 0 and (h(x, y, 50) > d * 0.9) or (h(x, y, 51) > 0.8 + d * 0.2 and d < 0.5)
      if ch then gp(x, y, p[5] == "d" and "#4a573e" or "#7c8a4c") end
    end
  end end
end
-- worn dirt pixels where feet leave the road toward hearth, cart and trail
local function wear(x0, y0, x1, y1, n)
  for i = 0, n do
    local t = i / n
    local x = floor_(x0 + (x1 - x0) * t + (h(i, 1, 52) - 0.5) * 7)
    local y = floor_(y0 + (y1 - y0) * t + (h(i, 2, 52) - 0.5) * 3)
    gp(x, y, "#8f7a52"); if h(i, 3, 52) > 0.5 then gp(x + 1, y, "#a08a5e") end
    if h(i, 4, 52) > 0.6 then gp(x, y + 1, "#6e5c40") end
  end
end
wear(168, 232, 126, 224, 34); wear(334, 214, 372, 208, 18); wear(268, 124, 330, 122, 26); wear(262, 130, 296, 142, 14)
-- pebbles
for i = 1, 60 do
  local x, y = floor_(h(i, 5, 53) * 450) + 12, floor_(h(i, 6, 53) * 150) + 118
  if gp(x, y, "#9a9a9c") then gp(x + 1, y, "#bdb7b0"); gp(x, y + 1, "#6a6670") end
end
-- flowers: three kinds (daisy, poppy, bluebell) in clumps, plus clover and leaf litter
local function daisy(x, y) gp(x, y, "#fff4dc"); gp(x - 1, y, "#fff4dc"); gp(x + 1, y, "#fff4dc"); gp(x, y - 1, "#fff4dc"); gp(x, y + 1, "#fff4dc"); put(x, y, "#f4c24a") end
local function poppy(x, y) gp(x, y, "#d9482b"); gp(x + 1, y, "#e8644a"); gp(x, y + 1, "#4f7a44") end
local function bell(x, y) gp(x, y, "#8a7ac8"); gp(x, y - 1, "#a898e0"); gp(x, y + 1, "#4f7a44"); gp(x + 1, y + 1, "#6a9a52") end
local clumps = { { 60, 262, 1 }, { 28, 200, 2 }, { 200, 130, 3 }, { 320, 135, 1 }, { 455, 135, 2 }, { 130, 244, 3 }, { 240, 262, 1 }, { 440, 205, 3 }, { 188, 164, 2 }, { 300, 245, 3 }, { 16, 252, 2 }, { 280, 200, 1 } }
for _, cl in ipairs(clumps) do
  for k = 1, 5 do
    local x, y = cl[1] + floor_((h(k, cl[1], 54) - 0.5) * 18), cl[2] + floor_((h(k, cl[2], 54) - 0.5) * 8)
    if cl[3] == 1 then daisy(x, y) elseif cl[3] == 2 then poppy(x, y) else bell(x, y) end
  end
end
for i = 1, 30 do
  local x, y = floor_(h(i, 7, 55) * 450) + 12, floor_(h(i, 8, 55) * 150) + 118
  local col = i % 3 == 0 and "#b8742a" or (i % 3 == 1 and "#d09a3a" or "#8a5a2a")
  gp(x, y, col); gp(x + 1, y + 1, col)
end

------------------------------------------------------------------ v2.5.40 polish pass 2: material cues
local function mk(x, y, col)
  if x < 0 or y < 0 or x >= W or y >= H or guarded(x, y) then return end
  local cur = c:get(x, y)
  if cur and string.lower(cur) ~= string.lower(INK) then put(x, y, col) end
end
local function mkr(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do mk(x, y, col) end end end
-- moss + lichen on north (top) edges of stone: cliff, arch, left wall, plinth
for x = 156, 334, 1 do
  if h(x, 9, 60) > 0.86 then
    for y = 46, 108 do
      local cur = c:get(x, y)
      if cur and string.lower(cur) ~= string.lower(INK) and (cur == "#9c8790" or cur == "#7a6676" or cur == "#c0a3a0" or cur == "#5a4a63") then
        mk(x, y, "#5f7a48"); mk(x + 1, y, "#4a6440"); mk(x, y + 1, "#6f8f50"); break
      end
    end
  end
end
for _, m in ipairs({ { 390, 80, 408, 90 }, { 440, 80, 462, 92 }, { 16, 110, 38, 124 }, { 14, 200, 36, 208 }, { 44, 201, 90, 205 } }) do
  for i = 1, 7 do
    local x, y = m[1] + floor_(h(i, m[1], 61) * (m[3] - m[1])), m[2] + floor_(h(i, m[2], 61) * (m[4] - m[2]))
    mk(x, y, "#5f7a48"); mk(x + 1, y, "#7f9f58"); mk(x, y + 1, "#4a6440")
  end
end
-- chipped stone: pale chip highlights + dark crack lines on the left wall, arch and cliff
local function chip(x, y) mk(x, y, "#d9ccc4"); mk(x + 1, y + 1, "#4a3f4c") end
for _, q in ipairs({ { 20, 118 }, { 30, 160 }, { 24, 180 }, { 34, 196 }, { 392, 110 }, { 452, 108 }, { 396, 96 }, { 460, 100 }, { 200, 90 }, { 300, 86 }, { 170, 100 }, { 322, 100 }, { 232, 56 }, { 60, 205 }, { 140, 205 } }) do chip(q[1], q[2]) end
for i = 0, 5 do mk(24 + i, 168 + floor_(i / 2), "#3b3048") end
for i = 0, 6 do mk(444 - floor_(i / 2), 98 + i, "#35304a") end
for i = 0, 6 do mk(188 + floor_(i / 2), 84 + i, "#3b3048") end
-- roof shingles: darker row lines every 7 px with staggered ticks, sod drip of moss at the eave
for x = 8, 176 do
  local ty = floor_(110 - (x - 6) * 24 / 170)
  for k = 7, 14, 7 do
    mk(x, ty + k, "#3e2a22")
    if (x + k) % 10 == 3 then mk(x, ty + k + 1, "#98684a"); mk(x, ty + k + 2, "#3e2a22") end
  end
  if h(x, 6, 62) > 0.82 then mk(x, ty + 15, "#5f7a48"); mk(x, ty + 16, "#4a6440") end
end
-- wood grain + knots on bunk posts, bench, cart posts, cart planks, sign
for _, px in ipairs({ 98, 150 }) do for y = 110, 196, 9 do mk(px + 2 + floor_(h(y, px, 63) * 3), y, "#3e2619"); mk(px + 3, y + 1, "#3e2619") end
  mk(px + 3, 150, "#2e1d1e"); mk(px + 2, 150, "#5f3a24"); mk(px + 3, 151, "#2e1d1e") end
for x = 30, 92, 1 do if h(x, 3, 64) > 0.8 then mk(x, 230, "#5f3a24"); mk(x + 1, 230, "#5f3a24") end; if h(x, 4, 64) > 0.9 then mk(x, 233, "#3e2619") end end
for x = 345, 432, 1 do if h(x, 5, 65) > 0.88 then mk(x, 174, "#2c5c63"); mk(x + 1, 174, "#2c5c63"); mk(x, 182, "#5ea3a6") end; if h(x, 6, 65) > 0.9 then mk(x, 190, "#1f3f46") end end
mkr(347, 176, 348, 177, "#1f3f46"); mk(349, 178, "#5ea3a6")
for y = 96, 126, 5 do mk(373, y, "#3e2619"); mk(374, y + 1, "#c18c58") end
for x = 364, 390, 1 do if h(x, 7, 66) > 0.82 then mk(x, 97, "#8a5428"); mk(x, 103, "#8a5428") end end
-- rope: coiled rope on cart shaft and bound hay-bale tie on the log rollers (twist = alternating 2 tones)
for i = 0, 7 do mk(337 + floor_(i * 0.2), 196 + i, i % 2 == 0 and "#d8c6a6" or "#a88f78") end
for i = 0, 5 do mk(344 + i, 190, i % 2 == 0 and "#d8c6a6" or "#a88f78"); mk(344 + i, 191, i % 2 == 0 and "#a88f78" or "#d8c6a6") end
mk(350, 192, "#a88f78"); mk(350, 193, "#d8c6a6"); mk(351, 194, "#a88f78")
-- rust streaks: horseshoe, lanterns' brackets, kettle handle
for _, q in ipairs({ { 238, 24 }, { 238, 26 }, { 245, 23 }, { 243, 25 }, { 52, 44 }, { 60, 44 }, { 420, 44 }, { 428, 44 } }) do mk(q[1], q[2], "#9a5a30") end
mk(238, 27, "#c0743a"); mk(244, 26, "#7a3e22")
-- cloth folds: quilts get a diagonal fold crease and dark seam, pillows a dimple
for _, b in ipairs({ { 49, 148, "#8a3a30" }, { 49, 180, "#8a3a30" }, { 107, 148, "#2c6a66" }, { 107, 180, "#2c6a66" } }) do
  for i = 0, 6 do mk(b[1] + 14 + i * 3, b[2] + 2 + (i % 2), b[3]) end
  mk(b[1] + 8, b[2] + 4, b[3]); mk(b[1] + 9, b[2] + 5, b[3])
end
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. "here-haven.aseprite", png = OUT .. "here-haven.png", scale = 1 }
print("ok here-haven")
