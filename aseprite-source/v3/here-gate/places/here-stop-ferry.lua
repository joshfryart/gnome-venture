-- Gnome Venture "Hearth Pop" v3 : here-stop-ferry (gate view, hero scale)
-- Ferry rest stop on the road: landing + rope ferry + bell, ferryman hut,
-- travellers' table + fire, stamp post / notice board, two huts, wild trail exit right.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-stop-ferry"
local W, H = 480, 270
local HOR = 104
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

local function hash(x, y, s)
  local n = math.sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - math.floor(n)
end
local function P(x, y, col) if x >= 0 and x < W and y >= 0 and y < H then c:px(x, y, col) end end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t)
  local r1,g1,b1 = hx(a); local r2,g2,b2 = hx(b)
  local function f(p,q) local v = math.floor(p + (q-p)*t + 0.5); if v < 8 then v = 8 end; if v > 247 then v = 247 end; return v end
  return string.format("#%02x%02x%02x", f(r1,r2), f(g1,g2), f(b1,b2))
end
-- cool-violet contact shadow (darkens whatever is under it)
local function shadow(cx, cy, rx, ry, amt)
  local m = c:ellipse(cx, cy, rx, ry)
  local done = {}
  m:each(function(x, y)
    local k = c:get(x, y)
    if k then P(x, y, mix(k, "#3a3358", amt or 0.38)) end
  end)
end

-- shaded solid: r = {deep, shade, base, hi}; light from upper-left
local function solid(m, r, o)
  o = o or {}
  local sh = o.sh or 2
  m:each(function(x, y)
    local col = r[3]
    local edgeShade = (not m:has(x + sh, y)) or (not m:has(x, y + sh))
    local edgeHi = (not m:has(x - 1, y)) or (not m:has(x, y - 1))
    if edgeShade then col = r[2] elseif edgeHi then col = r[4] end
    if o.tex then col = o.tex(x, y, col) or col end
    P(x, y, col)
  end)
  if o.rim ~= false then c:edgeIn(m, r[1]) end
end
local function planksH(r, step, y0, seed)
  return function(x, y, col)
    if (y - y0) % step == 0 then return r[1] end
    if (y - y0) % step == 1 and col == r[3] then return r[4] end
    if col == r[3] and hash(x // 3, y, seed) > 0.86 then return r[2] end
    return col
  end
end
local function planksV(r, step, x0, seed)
  return function(x, y, col)
    if (x - x0) % step == 0 then return r[1] end
    if col == r[3] and hash(x, y // 4, seed) > 0.85 then return r[2] end
    return col
  end
end

-- ramps {deep, shade, base, hi}
local WOOD  = {"#4a2a26", "#7a4834", "#a8693f", "#d39a5c"}
local DOCK  = {"#3e3440", "#6c5a5c", "#957d70", "#c2a88c"}
local THAT  = {"#5a3e22", "#94702f", "#c69c48", "#ecd078"}
local PLAS  = {"#5a3e48", "#a8887c", "#dcc2a2", "#f4e2bc"}
local BLUW  = {"#26304e", "#40558a", "#6283b4", "#93b4d8"}
local TEAL  = {"#173e44", "#276660", "#3f9282", "#78c2a2"}
local RED   = {"#4e1a2a", "#8e3238", "#c45444", "#ea8c62"}
local BRASS = {"#55361a", "#94642a", "#d2a03e", "#f4d478"}
local STONE = {"#36324a", "#625c74", "#8e869c", "#b8b0c2"}
local LEAF  = {"#223f34", "#356042", "#538a4c", "#88b65c"}
local PAPER = {"#6a5656", "#c4b29a", "#ecdcbc", "#fbf0d6"}
local CORK  = {"#4e3222", "#8a5a36", "#b4804e", "#d8a868"}
local GLOW  = {"#9a5a2a", "#e0902e", "#f6c45a", "#fde59a"}
local MOSS  = {"#2c4630", "#4a6e3a", "#6f9446", "#a2c060"}

------------------------------------------------------------------ SKY (warm evening)
c:stripes(0, 70, {"#4e5290", "#6a5ea4", "#8f6aa6", "#b8789e", "#de8e8a", "#f0a87a", "#f6c47e", "#f8dc96"},
                 {3, 3, 3, 3, 3, 3, 3, 2})
c:cloud(60, 34, 46, "#f6c8a4", "#d08a8e")
c:cloud(150, 22, 34, "#eab6a8", "#b8789e")
c:cloud(300, 30, 52, "#f6c8a4", "#d08a8e")
c:cloud(392, 18, 36, "#eab6a8", "#b8789e")
-- far hills, two layers
c:terrain(function(x) return math.floor(54 + 9 * math.sin(x / 47) + 5 * math.sin(x / 19 + 2)) end, "#9a86b4", 104)
c:terrain(function(x) return math.floor(70 + 7 * math.sin(x / 33 + 1) + 3 * math.sin(x / 11)) end, "#7f8aae", 104)
-- sunlit rim on nearer hill
for x = 0, W - 1 do
  local y = math.floor(70 + 7 * math.sin(x / 33 + 1) + 3 * math.sin(x / 11))
  P(x, y, "#c0a8b6")
end
-- far bank treeline (bumpy, not round)
local function tree(x) return math.floor(86 - 6 * hash(x // 7, 3, 1) - 3 * math.abs(math.sin(x / 5))) end
local tl = c:terrain(tree, "#4c6e60", 104)
tl:each(function(x, y) if y < tree(x) + 2 and x % 7 < 3 then P(x, y, "#6a8c6a") end
  if hash(x, y, 4) > 0.9 then P(x, y, "#3c5a52") end end)
-- far bank meadow strip
c:fillMask(c:rect(0, 96, W - 1, 103), "#a6b26a")
for x = 0, W - 1 do P(x, 96, "#c2c47c"); P(x, 103, "#6c7a48") end
-- far little landing stub + far cable post
solid(c:rect(234, 98, 250, 104), DOCK, { sh = 1 })
solid(c:rect(252, 88, 254, 104), WOOD, { sh = 1 })

------------------------------------------------------------------ RIVER
c:stripes(104, 141, {"#a8c8d4", "#86b4c8", "#6c9fbc", "#5a8cb0", "#4e7ca2"}, {2, 2, 3, 3, 3})
for y = 105, 140 do
  for x = 0, W - 1 do
    local h = hash(x // 6, y, 9)
    if h > 0.955 then P(x, y, "#f4d49a") elseif h < 0.03 then P(x, y, "#3e6890") end
  end
end
-- warm sky reflection streak down the middle
for y = 105, 140 do
  local half = 6 + (y - 104) // 3
  for x = 240 - half, 240 + half do if hash(x // 3, y, 2) > 0.55 then P(x, y, "#e8b48a") end end
end
-- snapshot of open water (reflections and edge shadows only paint where water still shows)
local WATER = {}
for y = 104, 141 do for x = 0, W - 1 do WATER[y * W + x] = c:get(x, y) end end
local function reflect(x0, x1, yw, h, col, amt)
  for k = 1, h do
    if k % 4 ~= 3 then
      local sh = math.floor(math.sin(k * 1.9 + x0) * 1.3 + 0.5)
      local a = (amt or 0.5) * (1 - k / (h + 2))
      for x = x0, x1 do
        local xx, y = x + sh, yw + k
        local kk = c:get(xx, y)
        if kk and WATER[y * W + xx] == kk then P(xx, y, mix(kk, col, a)) end
      end
    end
  end
end

------------------------------------------------------------------ NEAR GROUND
c:stripes(142, 269, {"#a6ba62", "#9bb05a", "#90a652", "#87a04e"}, {2, 3, 3, 4})
-- muddy bank lip
local bank = c:terrain(function(x) return math.floor(140 + 2 * math.sin(x / 9)) end, "#8a6a4a", 147)
for x = 0, W - 1 do local y = math.floor(140 + 2 * math.sin(x / 9)); P(x, y, "#5e4436"); P(x, y + 1, "#a88660") end
-- grass flecks (not in compass corner)
for y = 150, 268, 2 do for x = 0, W - 1 do
  local h = hash(x, y, 5)
  if not (x >= 376 and y >= 226) then
    if h > 0.975 then P(x, y, "#6e8a40"); P(x, y - 1, "#6e8a40") elseif h < 0.02 then P(x, y, "#bccc72") end
  end
end end

------------------------------------------------------------------ PATH (one-point toward VP)
local path = c:poly{{214, 146}, {266, 146}, {342, 269}, {138, 269}}
local PATH = {"#7c5a3c", "#a77e52", "#c9a06a", "#e2c08a"}
path:each(function(x, y)
  local col = PATH[3]
  local h = hash(x // 2, y // 2, 7)
  if h > 0.93 then col = PATH[2] elseif h < 0.06 then col = PATH[4] end
  P(x, y, col)
end)
-- pebbles
for i = 1, 70 do
  local y = 150 + math.floor(hash(i, 1, 11) * 118)
  local t = (y - 146) / 123
  local l, r = 214 - 76 * t, 266 + 76 * t
  local x = math.floor(l + 4 + hash(i, 2, 11) * (r - l - 8))
  local s = 1 + math.floor(t * 2)
  if not (x >= 376 and y >= 226) then
    for yy = 0, s - 1 do for xx = 0, s do P(x + xx, y + yy, "#d8c0a0") end end
    for xx = 0, s do P(x + xx, y + s, "#8a6a4c") end
  end
end
-- two wheel ruts converging to the VP
for y = 148, 269 do
  local t = (y - 146) / 123
  for _, k in ipairs({-0.42, 0.42}) do
    local x = math.floor(240 + k * (26 + 76 * t) * 1.0)
    P(x, y, PATH[2]); if t > 0.5 then P(x + 1, y, PATH[2]) end
  end
end
c:edgeIn(path, PATH[1])

------------------------------------------------------------------ FERRY CABLE (near tall post -> far post)
local cable = c:line({{320, 82}, {290, 87}, {254, 89}}, 1)
-- (drawn later, after the hut, so it reads above water)

------------------------------------------------------------------ HOMES (left, mid tier)
-- hut A : plaster + timber, thatch
shadow(56, 147, 36, 4)
local aSide = c:poly{{80, 104}, {91, 109}, {91, 143}, {80, 146}}
solid(aSide, {"#4a3440", "#8c6e6c", "#b49a8a", "#c8b098"}, { tex = planksV(PLAS, 4, 80, 3) })
local aBody = c:rect(26, 104, 80, 146)
solid(aBody, PLAS, { sh = 3, tex = function(x, y, col)
  if x == 26 + 2 or x == 78 or y == 125 or (x - 26) == 27 then return WOOD[2] end
  if col == PLAS[3] and hash(x // 2, y // 2, 12) > 0.9 then return PLAS[2] end
  return col end })
solid(c:rect(46, 124, 60, 146), WOOD, { tex = planksV(WOOD, 4, 46, 5) })
P(57, 136, BRASS[3]); P(57, 135, BRASS[4])
local aWin = c:rect(33, 112, 43, 121)
solid(aWin, GLOW, { sh = 2 })
c:fillMask(c:rect(38, 112, 38, 121), WOOD[2]); c:fillMask(c:rect(33, 116, 43, 116), WOOD[2])
c:edgeIn(aWin:grow(1), WOOD[1])
solid(c:rect(64, 112, 74, 121), GLOW, { sh = 2 })
c:edgeIn(c:rect(63, 111, 75, 122), WOOD[1])
-- thatch roof
local aRoof = c:poly{{20, 108}, {50, 70}, {58, 70}, {94, 110}}
solid(aRoof, THAT, { sh = 3, tex = function(x, y, col)
  if (x + (y // 6) * 2) % 4 == 0 then return THAT[2] end
  if y % 6 == 0 and col == THAT[3] then return THAT[4] end
  return col end })
-- crooked stovepipe (quirk: bent elbow)
solid(c:rect(68, 76, 72, 90), STONE, { sh = 1 })
solid(c:rect(68, 72, 78, 76), STONE, { sh = 1 })

-- hut B : blue planks, roof = an upturned boat (quirk)
shadow(124, 147, 30, 4)
local bBody = c:rect(100, 110, 146, 146)
solid(bBody, BLUW, { sh = 3, tex = planksH(BLUW, 5, 110, 6) })
solid(c:rect(115, 126, 128, 146), WOOD, { tex = planksV(WOOD, 4, 115, 8) })
P(125, 136, BRASS[3])
solid(c:rect(133, 118, 141, 126), GLOW, { sh = 2 })
c:edgeIn(c:rect(132, 117, 142, 127), BLUW[1])
local hull = c:poly{{92, 114}, {95, 104}, {104, 96}, {116, 92}, {132, 92}, {146, 96}, {154, 104}, {156, 114}}
solid(hull, TEAL, { sh = 3, tex = function(x, y, col)
  if (y - 92) % 5 == 4 then return TEAL[1] end
  if (y - 92) % 5 == 0 and col == TEAL[3] then return TEAL[4] end
  return col end })
c:fillMask(c:rect(110, 90, 138, 91), RED[2]); c:fillMask(c:rect(110, 90, 138, 90), RED[1]) -- keel
c:fillMask(c:rect(92, 113, 156, 114), RED[3]); c:fillMask(c:rect(92, 114, 156, 114), RED[1]) -- gunwale stripe
-- oar leaning on hut B
c:fillMask(c:line({{150, 146}, {160, 106}}, 2), WOOD[3])
solid(c:poly{{158, 104}, {163, 94}, {166, 96}, {162, 108}}, WOOD, { sh = 1 })

------------------------------------------------------------------ REEDS along the bank
local function reed(x, y, hgt, seed)
  local lean = (hash(x, 1, seed) - 0.5) * 4
  for i = 0, hgt do
    local xx = math.floor(x + lean * i / hgt)
    P(xx, y - i, i < hgt * 0.4 and "#4e6a3a" or "#6f9446")
  end
  if hash(x, 2, seed) > 0.45 then
    local tx = math.floor(x + lean)
    for i = 0, 4 do P(tx, y - hgt - i, "#7a4a30"); P(tx + 1, y - hgt - i, "#5a3426") end
  end
end
for x = 160, 204, 3 do reed(x, 146, 10 + math.floor(hash(x, 0, 3) * 12), 3) end
for x = 20, 26, 2 do reed(x, 150, 14, 4) end
for x = 402, 418, 3 do reed(x, 146, 9 + math.floor(hash(x, 0, 5) * 8), 5) end

------------------------------------------------------------------ FERRYMAN HUT (right, on stilts)
for _, sx in ipairs({344, 362, 380, 392}) do
  solid(c:rect(sx, 124, sx + 2, 142), DOCK, { sh = 1 })
  for x = sx - 2, sx + 4 do if hash(x, 3, sx) > 0.3 then P(x, 142, "#a8c8d4") end end
end
solid(c:rect(336, 120, 400, 125), DOCK, { sh = 1, tex = planksV(DOCK, 5, 336, 4) })
local fSide = c:poly{{334, 100}, {342, 96}, {342, 120}, {334, 122}}
solid(fSide, {"#3e2026", "#6a3a32", "#8a5240", "#a86a4e"})
local fBody = c:rect(342, 96, 396, 120)
solid(fBody, WOOD, { sh = 3, tex = planksH(WOOD, 4, 96, 9) })
solid(c:rect(350, 102, 362, 112), GLOW, { sh = 2 })
c:edgeIn(c:rect(349, 101, 363, 113), WOOD[1]); c:fillMask(c:rect(356, 102, 356, 112), WOOD[1])
solid(c:rect(372, 102, 384, 120), DOCK, { tex = planksV(DOCK, 4, 372, 2) })
local fRoof = c:poly{{328, 100}, {362, 72}, {368, 72}, {402, 100}}
solid(fRoof, RED, { sh = 3, tex = function(x, y, col)
  if (y - 72) % 5 == 0 then return RED[1] end
  if ((x + ((y - 72) // 5) * 3) % 7) == 0 then return RED[2] end
  return col end })
-- coiled rope hanging by the door: a hank (not a ring)
solid(c:rect(388, 104, 393, 114), THAT, { sh = 1, tex = function(x, y, col) if (x + y) % 3 == 0 then return THAT[2] end return col end })
-- tall near cable post
solid(c:rect(318, 80, 322, 142), WOOD, { sh = 2, tex = planksV(WOOD, 9, 318, 1) })
c:fillMask(c:rect(316, 80, 324, 82), WOOD[1])
-- cable + socks hung on it (quirk)
c:fillMask(cable, "#3e3036")
local function sock(x, y, col, dk)
  solid(c:poly{{x, y}, {x + 3, y}, {x + 3, y + 6}, {x + 6, y + 7}, {x + 6, y + 9}, {x, y + 9}}, {dk, dk, col, col}, { sh = 1 })
  c:fillMask(c:rect(x, y, x + 3, y + 1), "#f0e4cc")
end
sock(272, 88, "#c45444", "#6e2230")
sock(284, 88, "#e0b040", "#7a5420")

------------------------------------------------------------------ DO: landing, ferry raft, bell
-- polish pass: perspective deck (plank depth compresses toward the far bank), grain, nails, worn centre,
-- pilings in perspective with rope swags, water shadow along the deck edges
local DK_L = function(y) return 212 + 6 * (152 - y) / 38 end   -- deck left edge x at row y
local DK_R = function(y) return 268 - 6 * (152 - y) / 38 end
local function ZY(z) return 104 + 48 / z end                    -- depth -> screen row (VP at the horizon)
-- dark water hugging both deck edges (the deck shades the water under its lip)
for y = 115, 141 do
  for _, x in ipairs({ math.floor(DK_L(y)) - 1, math.floor(DK_L(y)) - 2, math.floor(DK_R(y)) + 1, math.floor(DK_R(y)) + 2 }) do
    local k = c:get(x, y)
    if k and WATER[y * W + x] == k then P(x, y, mix(k, "#2a3a5e", (x % 2 == 0) and 0.45 or 0.3)) end
  end
end
for x = 210, 272 do if x % 4 < 2 then P(x, 116, "#c4dce2") end end
local dock = c:poly{{212, 152}, {268, 152}, {262, 114}, {218, 114}}
shadow(240, 117, 26, 3, 0.45)
-- plank rows from near to far
local PLK = { "#957d70", "#8a7266", "#9e8676", "#917a6c" }
local rows, z, yb = {}, 1, 152
while true do
  local z2 = z + 0.24
  local y2 = math.floor(ZY(z2) + 0.5)
  if y2 >= yb - 1 then y2 = yb - 2 end
  if y2 < 114 then y2 = 114 end
  rows[#rows + 1] = { top = y2, bot = yb, z = z }
  if y2 <= 114 then break end
  z, yb = z2, y2
end
for i, r in ipairs(rows) do
  local base = PLK[(i * 7) % 4 + 1]
  if i == 5 then base = "#a08068" end                             -- one newer replacement plank (quirk)
  local hgt = r.bot - r.top
  for y = r.top, r.bot - 1 do
    local x0, x1 = math.ceil(DK_L(y)), math.floor(DK_R(y))
    for x = x0, x1 do
      local col = base
      if y == r.top and hgt >= 3 then col = "#c2a88c" end         -- sunlit leading edge
      if y == r.bot - 1 and hgt >= 3 then col = "#4e4048" end
      if hgt <= 2 then col = (i % 2 == 0) and "#7a6460" or "#a89080" end     -- underside of the board / gap
      -- worn foot-path lighter down the middle
      if col == base and math.abs(x - 240) < 9 - i * 0.3 and hash(x // 2, y, 31) > 0.55 then col = mix(base, "#d8c0a0", 0.35) end
      P(x, y, col)
    end
    -- grain: 2-3 short streaks per near board
    if hgt >= 4 and y == r.top + math.floor(hgt / 2) then
      for g = 1, 3 do
        local gx = math.floor(x0 + 4 + hash(i, g, 41) * (x1 - x0 - 14))
        local gl = 3 + math.floor(hash(i, g, 42) * 7 / r.z)
        for k = 0, gl do P(gx + k, y + ((k > gl // 2) and 1 or 0), "#6c5a5c") end
      end
      -- knot
      local kx = math.floor(x0 + 6 + hash(i, 9, 43) * (x1 - x0 - 12))
      if i % 3 == 1 then P(kx, y, "#4e4048"); P(kx + 1, y, "#6c5a5c") end
    end
  end
  -- nails over the three joists (edges + centre), fading out with distance
  if hgt >= 3 then
    local ny = r.top + 1
    for _, jx in ipairs({ math.ceil(DK_L(ny)) + 3, 240, math.floor(DK_R(ny)) - 3 }) do
      P(jx, ny, "#3e3440"); if hgt >= 6 then P(jx + 1, ny, "#3e3440"); P(jx, ny - 0, "#3e3440"); P(jx - 1, ny, "#d8c8b4") end
    end
  end
end
-- deck side rails (edge boards) catch the warm light on the left, cool shade on the right
for y = 114, 151 do
  P(math.ceil(DK_L(y)), y, "#3e3440"); P(math.ceil(DK_L(y)) + 1, y, (y % 3 == 0) and "#c2a88c" or "#e2c8a2")
  P(math.floor(DK_R(y)), y, "#3e3440"); P(math.floor(DK_R(y)) - 1, y, "#6c5a5c")
end
for x = 218, 262 do P(x, 114, "#3e3440") end
-- dock front face (bank edge): plank end grain
solid(c:rect(212, 152, 268, 155), {"#2e2632", "#4e4048", "#6c5a5c", "#6c5a5c"}, { sh = 1 })
for x = 214, 266, 6 do P(x, 153, "#8a7266"); P(x + 1, 153, "#8a7266"); P(x + 3, 154, "#3e3440") end
-- far end posts
solid(c:rect(216, 104, 220, 116), DOCK, { sh = 1 })
solid(c:rect(260, 104, 264, 116), DOCK, { sh = 1 })
-- mid pilings in perspective (shrink with depth), with rope wraps and a water stub + ripple
local ropeL, ropeR = { { 208, 139 } }, { { 273, 139 } }
for _, z in ipairs({ 1.7, 2.6 }) do
  local yb = math.floor(ZY(z) + 0.5)
  local w = math.max(3, math.floor(10 / z + 0.5))
  local h = math.floor(36 / z + 0.5)
  for side = -1, 1, 2 do
    local ex = side < 0 and math.floor(DK_L(yb)) or math.ceil(DK_R(yb))
    local x0 = side < 0 and (ex - w + 1) or ex
    local m = c:rect(x0, yb - h, x0 + w - 1, yb + math.floor(5 / z))
    solid(m, WOOD, { sh = 1, tex = function(x, y, col) if (y + x) % 5 == 0 and col == WOOD[3] then return WOOD[2] end return col end })
    P(x0, yb - h, WOOD[4]); P(x0 + 1, yb - h, WOOD[4])
    c:fillMask(c:rect(x0, yb - h + 2, x0 + w - 1, yb - h + 2 + math.floor(2 / z + 0.5)), THAT[2])
    P(x0, yb - h + 2, THAT[4])
    local wy = yb + math.floor(5 / z) + 1
    for x = x0 - 2, x0 + w + 1 do if (x + wy) % 2 == 0 then P(x, wy, "#c4dce2") end end
    local rp = { x0 + (side < 0 and 0 or w - 1), yb - h + 3 }
    if side < 0 then ropeL[#ropeL + 1] = rp else ropeR[#ropeR + 1] = rp end
  end
end
ropeL[#ropeL + 1] = { 217, 108 }; ropeR[#ropeR + 1] = { 263, 108 }
-- near mooring posts
shadow(208, 156, 7, 2); shadow(273, 156, 7, 2)
solid(c:rect(204, 130, 211, 156), WOOD, { sh = 2, tex = planksV(WOOD, 3, 204, 2) })
solid(c:rect(270, 130, 277, 156), WOOD, { sh = 2, tex = planksV(WOOD, 3, 270, 3) })
P(205, 130, WOOD[4]); P(206, 130, WOOD[4]); P(271, 130, WOOD[4]); P(272, 130, WOOD[4])
for _, px in ipairs({ 204, 270 }) do                               -- rope wraps, twisted
  c:fillMask(c:rect(px, 138, px + 7, 142), THAT[3])
  for x = px, px + 7 do for y = 138, 142 do if (x + y) % 3 == 0 then P(x, y, THAT[2]) end end; P(x, 142, THAT[1]); P(x, 138, THAT[4]) end
end
-- rope swags along both sides of the deck (sagging between pilings)
local function swag(pts)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2])) * 2
    local sag = math.max(1, math.floor(math.abs(b[2] - a[2]) / 4 + 1))
    for s = 0, n do
      local t = s / n
      local x = math.floor(a[1] + (b[1] - a[1]) * t + 0.5)
      local y = math.floor(a[2] + (b[2] - a[2]) * t + sag * 4 * t * (1 - t) + 0.5)
      P(x, y, THAT[3]); P(x, y + 1, THAT[1])
    end
  end
end
swag(ropeL); swag(ropeR)
-- coil of rope lying on the near deck (right), and a bucket
for r = 0, 3 do
  local m = c:ellipse(256, 145, 6 - r, 3 - math.floor(r * 0.7))
  c:edgeIn(m, (r % 2 == 0) and THAT[3] or THAT[2])
end
P(256, 145, THAT[1]); P(250, 146, THAT[1]); c:fillMask(c:line({{262, 145}, {265, 150}}, 1), THAT[3])
solid(c:poly{{222, 139}, {230, 139}, {229, 147}, {223, 147}}, BLUW, { sh = 1, tex = function(x, y, col) if y == 142 then return BRASS[2] end return col end })
c:fillMask(c:rect(223, 139, 229, 140), "#6c9fbc"); P(224, 139, "#a8c8d4")
c:fillMask(c:line({{222, 139}, {226, 135}, {230, 139}}, 1), "#3e3036")
-- teapot perched on the right mooring post (quirk)
local pot = c:poly{{268, 129}, {268, 123}, {270, 120}, {277, 120}, {279, 123}, {279, 129}}
solid(pot, TEAL, { sh = 1 })
c:fillMask(c:line({{280, 124}, {283, 120}}, 1), TEAL[2])
c:fillMask(c:rect(271, 118, 276, 119), TEAL[1]); P(273, 117, BRASS[3])
-- rope from left post to raft? (raft is on the right) : mooring rope right post -> raft
c:fillMask(c:line({{277, 136}, {284, 130}, {290, 126}}, 1), THAT[2])

-- the flat rope ferry (right of dock end)
shadow(298, 129, 32, 3, 0.45)
local raft = c:poly{{272, 116}, {322, 116}, {328, 126}, {268, 126}}
solid(raft, WOOD, { sh = 2, tex = planksV(WOOD, 6, 268, 4) })
solid(c:rect(268, 126, 328, 129), {"#3a2020", "#5a3428", "#7a4834", "#9a5e40"}, { sh = 1, tex = function(x, y, col) if x % 6 == 0 then return "#3a2020" end return col end })
for _, px in ipairs({274, 296, 318}) do solid(c:rect(px, 104, px + 2, 116), WOOD, { sh = 1 }) end
c:fillMask(c:rect(274, 104, 320, 105), THAT[2]); c:fillMask(c:rect(274, 105, 320, 105), THAT[1])
-- pulley line up to the cable
c:fillMask(c:line({{297, 104}, {297, 88}}, 1), THAT[1])
solid(c:rect(294, 85, 300, 89), BRASS, { sh = 1 })
-- tiny pennant on ferry
c:fillMask(c:line({{275, 103}, {275, 96}}, 1), WOOD[1])
solid(c:poly{{276, 96}, {284, 98}, {276, 101}}, RED, { sh = 1 })

-- bell post at the far-left corner of the dock
solid(c:rect(214, 70, 219, 114), WOOD, { sh = 2, tex = planksV(WOOD, 7, 214, 6) })
solid(c:rect(214, 70, 240, 74), WOOD, { sh = 1 })
c:fillMask(c:line({{219, 82}, {226, 75}}, 2), WOOD[2])
c:fillMask(c:rect(232, 75, 233, 78), "#3e3036")
local bell = c:poly{{229, 79}, {236, 79}, {238, 84}, {240, 92}, {243, 95}, {222, 95}, {225, 92}, {227, 84}}
solid(bell, BRASS, { sh = 2 })
c:fillMask(c:rect(224, 92, 241, 92), BRASS[2])
c:fillMask(c:rect(231, 96, 233, 98), BRASS[1])
P(229, 82, "#fff0c0"); P(229, 83, "#fff0c0")
c:fillMask(c:line({{232, 99}, {233, 106}, {231, 112}}, 1), THAT[2])
-- kite tangled on the bell post top (quirk)
local kite = c:poly{{206, 58}, {214, 52}, {220, 60}, {212, 68}}
solid(kite, {"#6e2230", "#c45444", "#e0b040", "#f4d478"}, { sh = 2 })
c:fillMask(c:line({{206, 58}, {220, 60}}, 1), RED[1]); c:fillMask(c:line({{214, 52}, {212, 68}}, 1), RED[1])
c:fillMask(c:line({{212, 68}, {209, 74}, {212, 80}, {208, 86}}, 1), "#3e3036")
for _, b in ipairs({{209, 74}, {212, 80}}) do P(b[1] - 1, b[2], "#4c6390"); P(b[1] + 1, b[2], "#4c6390") end

------------------------------------------------------------------ PEOPLE: table, benches, fire
shadow(84, 213, 46, 6)
-- back bench
solid(c:rect(50, 186, 116, 190), WOOD, { sh = 1, tex = planksH(WOOD, 3, 186, 2) })
for _, lx in ipairs({53, 112}) do solid(c:rect(lx, 191, lx + 2, 196), WOOD, { sh = 1 }) end
-- table top + front face
local top = c:poly{{44, 196}, {122, 196}, {126, 206}, {40, 206}}
solid(top, CORK, { sh = 2, tex = planksV(CORK, 10, 40, 4) })
solid(c:rect(40, 207, 126, 211), WOOD, { sh = 1 })
for _, lx in ipairs({46, 116}) do solid(c:rect(lx, 212, lx + 4, 222), WOOD, { sh = 1 }) end
-- front bench
shadow(84, 236, 46, 4)
solid(c:rect(36, 224, 130, 229), WOOD, { sh = 1, tex = planksH(WOOD, 3, 224, 3) })
for _, lx in ipairs({40, 82, 124}) do solid(c:rect(lx, 230, lx + 3, 236), WOOD, { sh = 1 }) end
-- on the table: mugs, a loaf, boot planter (quirk)
solid(c:rect(52, 192, 57, 199), RED, { sh = 1 }); c:fillMask(c:rect(58, 194, 59, 197), RED[1])
solid(c:rect(100, 192, 105, 199), BLUW, { sh = 1 }); c:fillMask(c:rect(106, 194, 107, 197), BLUW[1])
solid(c:poly{{64, 199}, {66, 194}, {80, 194}, {82, 199}}, THAT, { sh = 1, tex = function(x, y, col) if y == 196 and x % 4 == 0 then return THAT[1] end return col end })
local boot = c:poly{{86, 186}, {92, 186}, {92, 196}, {98, 196}, {98, 200}, {86, 200}}
solid(boot, {"#2e1e26", "#4e3234", "#6e4a40", "#8e6450"}, { sh = 1 })
for i, fx in ipairs({87, 89, 91}) do
  c:fillMask(c:line({{fx, 186}, {fx + (i - 2), 179}}, 1), MOSS[2])
  P(fx + (i - 2), 178, i == 2 and "#e8b040" or "#e07a8a"); P(fx + (i - 2) + 1, 178, "#f4d478")
end
-- fire pit: square stone box, flame, tripod + kettle (the "gather" icon)
shadow(142, 251, 16, 3)
local pit = c:rect(128, 238, 156, 250)
solid(pit, STONE, { sh = 2, tex = function(x, y, col)
  if (y == 244) or ((x - 128) % 7 == 0 and y < 244) or ((x - 131) % 7 == 0 and y > 244) then return STONE[1] end
  return col end })
local flame = c:poly{{132, 238}, {135, 228}, {138, 233}, {142, 220}, {146, 232}, {149, 226}, {152, 238}}
solid(flame, GLOW, { sh = 2 })
solid(c:poly{{137, 238}, {142, 228}, {147, 238}}, {"#e0902e", "#f6c45a", "#fde59a", "#fff2c0"}, { sh = 1, rim = false })
c:fillMask(c:line({{128, 236}, {142, 206}}, 1), "#3e3036")
c:fillMask(c:line({{156, 236}, {142, 206}}, 1), "#3e3036")
c:fillMask(c:line({{142, 206}, {142, 211}}, 1), "#3e3036")
local kettle = c:poly{{136, 214}, {148, 214}, {150, 220}, {148, 223}, {136, 223}, {134, 220}}
solid(kettle, {"#26304e", "#40558a", "#6283b4", "#93b4d8"}, { sh = 1 })
c:fillMask(c:line({{150, 217}, {154, 214}}, 1), "#40558a")
c:fillMask(c:rect(140, 212, 144, 213), "#26304e")
-- warm glow on the ground round the fire
for y = 232, 256 do for x = 118, 166 do
  local d = ((x - 142) / 24) ^ 2 + ((y - 245) / 12) ^ 2
  if d < 1 and not pit:has(x, y) and not flame:has(x, y) then
    local k = c:get(x, y)
    if k and (k == "#87a04e" or k == "#90a652" or k == "#9bb05a") and hash(x, y, 8) > 0.5 then P(x, y, "#c2b45a") end
  end
end end

------------------------------------------------------------------ STOP: stamp post + notice board
shadow(376, 217, 34, 4)
solid(c:rect(350, 160, 354, 216), WOOD, { sh = 1, tex = planksV(WOOD, 9, 350, 2) })
solid(c:rect(398, 160, 402, 216), WOOD, { sh = 1, tex = planksV(WOOD, 9, 398, 3) })
local sRoof = c:poly{{340, 162}, {352, 150}, {400, 150}, {412, 162}}
solid(sRoof, MOSS, { sh = 2, tex = function(x, y, col) if (y - 150) % 4 == 0 then return MOSS[1] end if (x + (y // 4) * 2) % 6 == 0 then return MOSS[2] end return col end })
local board = c:rect(344, 163, 408, 196)
solid(board, CORK, { sh = 2, tex = function(x, y, col) if hash(x, y, 13) > 0.9 then return CORK[2] end return col end })
c:edgeIn(c:rect(343, 162, 409, 197), WOOD[1])
-- pinned notes (different colours, icon-like marks, no text)
local function note(x0, y0, x1, y1, r, seed)
  solid(c:rect(x0, y0, x1, y1), r, { sh = 1 })
  for y = y0 + 3, y1 - 2, 3 do c:fillMask(c:rect(x0 + 2, y, x1 - 2 - (y % 2) * 2, y), r[2]) end
  P(math.floor((x0 + x1) / 2), y0, "#c45444")
end
note(348, 166, 362, 184, PAPER, 1)
note(366, 168, 378, 180, {"#5a5a2a", "#b0b060", "#e6e08a", "#f6f0b4"}, 2)
note(382, 166, 396, 186, {"#2a4a5a", "#7aa6c4", "#b4d4e6", "#d8ecf4"}, 3)
-- map scrap with a dotted route (river crossing icon)
solid(c:rect(366, 183, 380, 194), PAPER, { sh = 1 })
c:fillMask(c:rect(367, 188, 379, 189), "#6c9fbc")
for x = 368, 378, 3 do P(x, 186, "#c45444"); P(x + 1, 191, "#c45444") end
-- big stamp hanging under the board (stop icon)
c:fillMask(c:line({{376, 197}, {376, 201}}, 1), THAT[1])
solid(c:rect(372, 201, 380, 205), RED, { sh = 1 })
solid(c:rect(375, 206, 377, 209), WOOD, { sh = 1 })
solid(c:rect(368, 210, 384, 214), BRASS, { sh = 1 })
c:fillMask(c:rect(368, 214, 384, 214), "#6e2230")
-- stamp mark sample pinned on board corner
solid(c:rect(398, 188, 405, 194), PAPER, { sh = 1 })
c:fillMask(c:rect(400, 190, 403, 192), "#c45444")

------------------------------------------------------------------ WILD: branch arch + arrow sign, exit right
shadow(442, 208, 22, 3)
-- stepping stones leaving right
for i, s in ipairs({{418, 222}, {432, 214}, {446, 206}, {458, 200}}) do
  solid(c:rect(s[1], s[2], s[1] + 8 - i, s[2] + 3), STONE, { sh = 1 })
end
-- bent sapling arch
local trunk = c:line({{426, 210}, {424, 170}, {428, 140}, {440, 122}, {456, 116}, {462, 118}}, 4)
solid(trunk, {"#3a2a26", "#5e4436", "#7e5e46", "#a0805a"}, { sh = 2 })
local trunk2 = c:line({{458, 210}, {456, 176}, {460, 150}}, 3)
solid(trunk2, {"#3a2a26", "#5e4436", "#7e5e46", "#a0805a"}, { sh = 2 })
-- leafy clumps (jagged, not round)
local function clump(cx, cy, w, h, seed)
  local m = c:poly{{cx - w, cy + h // 3}, {cx - w + 3, cy - h // 2}, {cx - w // 3, cy - h}, {cx + w // 3, cy - h + 2},
                    {cx + w, cy - h // 3}, {cx + w - 2, cy + h // 2}, {cx, cy + h}}
  solid(m, LEAF, { sh = 3, tex = function(x, y, col)
    local hh = hash(x // 2, y // 2, seed)
    if hh > 0.86 then return LEAF[4] elseif hh < 0.1 then return LEAF[2] end
    return col end })
end
clump(436, 124, 12, 9, 1)
clump(452, 112, 10, 8, 2)
clump(424, 150, 7, 7, 3)
-- arrow signpost pointing out to the right (wild icon: leaf on arrow)
solid(c:rect(436, 162, 439, 206), WOOD, { sh = 1 })
local arrow = c:poly{{428, 164}, {450, 164}, {450, 160}, {458, 170}, {450, 180}, {450, 176}, {428, 176}}
solid(arrow, MOSS, { sh = 2 })
local lf = c:poly{{436, 170}, {440, 166}, {446, 167}, {442, 172}}
solid(lf, {"#5a3a1a", "#e0902e", "#f6c45a", "#fde59a"}, { sh = 1 })

------------------------------------------------------------------ GATE FRAME (posts, beam, lanterns, paddle charm)
local POST = {"#3a2622", "#64402e", "#8a5a3a", "#b07a4e"}
local function post(x0, x1)
  local m = c:rect(x0, 0, x1, H - 1)
  solid(m, POST, { sh = 4, tex = function(x, y, col)
    if hash(x, y // 5, 21) > 0.82 then return POST[2] end
    if (y + x * 3) % 23 == 0 then return POST[1] end
    return col end })
  for _, ry in ipairs({52, 58, 196, 202}) do
    c:fillMask(c:rect(x0, ry, x1, ry + 4), THAT[3])
    for x = x0, x1 do if (x + ry) % 3 == 0 then P(x, ry + 2, THAT[2]) end P(x, ry + 4, THAT[1]) end
  end
end
post(0, 17); post(462, 479)
local beam = c:rect(0, 0, W - 1, 13)
solid(beam, POST, { sh = 3, tex = function(x, y, col)
  if y == 6 and hash(x // 8, 0, 4) > 0.4 then return POST[2] end
  if hash(x // 3, y, 22) > 0.9 then return POST[4] end
  return col end })
-- corner brackets
solid(c:poly{{18, 14}, {40, 14}, {18, 34}}, POST, { sh = 2 })
solid(c:poly{{440, 14}, {461, 14}, {461, 34}}, POST, { sh = 2 })
-- reed tufts at the post feet
for x = 18, 30, 3 do reed(x, 268, 12 + (x % 5), 7) end
for x = 450, 461, 3 do reed(x, 268, 10 + (x % 4), 8) end
-- lanterns
local function lantern(cx)
  c:fillMask(c:rect(cx, 14, cx, 19), "#3e3036")
  solid(c:poly{{cx - 5, 23}, {cx - 2, 20}, {cx + 2, 20}, {cx + 5, 23}}, BRASS, { sh = 1 })
  local body = c:rect(cx - 5, 24, cx + 5, 36)
  solid(body, GLOW, { sh = 2 })
  c:fillMask(c:rect(cx - 6, 24, cx - 6, 36), BRASS[1]); c:fillMask(c:rect(cx + 6, 24, cx + 6, 36), BRASS[1])
  c:fillMask(c:rect(cx, 24, cx, 36), BRASS[2])
  solid(c:rect(cx - 6, 37, cx + 6, 39), BRASS, { sh = 1 })
end
lantern(48); lantern(432)
-- paddle charm hanging mid-beam (quirk)
c:fillMask(c:rect(240, 14, 240, 18), "#3e3036")
solid(c:rect(239, 19, 241, 26), WOOD, { sh = 1 })
solid(c:poly{{236, 27}, {244, 27}, {245, 36}, {240, 40}, {235, 36}}, TEAL, { sh = 1 })
c:fillMask(c:rect(237, 31, 243, 31), "#e0b040")
c:fillMask(c:line({{241, 22}, {246, 26}, {248, 31}}, 1), RED[3])

------------------------------------------------------------------ v2.5.40 polish: dock life, moored boat, lily pads, layered fire
local function crate(x, y, w, h, seed)
  shadow(x + w // 2, y + h + 1, w // 2 + 3, 2, 0.4)
  solid(c:rect(x, y, x + w, y + h), WOOD, { sh = 2, tex = planksH(WOOD, 4, y + 1, seed) })
  c:fillMask(c:line({{x + 1, y + 1}, {x + w - 1, y + h - 1}}, 1), WOOD[1])
  c:fillMask(c:rect(x, y, x + 1, y + h), WOOD[2]); c:fillMask(c:rect(x + w - 1, y, x + w, y + h), WOOD[2])
end
local function barrel(x, y, w, h)
  shadow(x + w // 2, y + h + 1, w // 2 + 3, 2, 0.4)
  solid(c:rrect(x, y, x + w, y + h, 3), WOOD, { sh = 3, tex = planksV(WOOD, 4, x + 1, 9) })
  for _, hy in ipairs({ y + 3, y + h - 3 }) do c:fillMask(c:rect(x, hy, x + w, hy + 1), DOCK[2]); P(x + 1, hy, DOCK[4]) end
end
-- left of the landing: crates, a coil of rope, a barrel (all clear of the stand points)
crate(182, 148, 14, 11, 2); crate(190, 138, 11, 9, 5); barrel(168, 146, 11, 14)
for r = 0, 2 do c:fillMask(c:ellipse(163 + 0, 160, 6 - r * 2, 3 - (r > 1 and 2 or r // 1 * 0)), r % 2 == 0 and THAT[3] or THAT[2]) end
c:fillMask(c:ellipse(163, 160, 1, 1), THAT[1])
-- right of the landing: barrel and a stacked sack
barrel(284, 142, 12, 15); barrel(297, 148, 10, 12)
solid(c:rrect(311, 150, 322, 159, 3), PLAS, { sh = 2, tex = function(x, y, col) if y == 153 then return PLAS[2] end end })
-- lantern on the left mooring post: brass cap + ring, framed glass, flame, warm glow ring (hard pixels, no alpha)
local lantM = c:rect(204, 112, 211, 129)
for y = 104, 140 do for x = 196, 220 do
  local d = ((x - 207.5) / 11) ^ 2 + ((y - 123) / 12) ^ 2
  if d < 1 and not lantM:has(x, y) then
    local k = c:get(x, y)
    local a = d < 0.45 and 0.32 or ((x + y) % 2 == 0 and 0.18 or 0)
    if k and a > 0 then P(x, y, mix(k, "#ffd27a", a)) end
  end
end end
c:fillMask(c:rect(207, 112, 208, 112), BRASS[1]); P(206, 113, BRASS[1]); P(209, 113, BRASS[1]); P(206, 114, BRASS[2]); P(209, 114, BRASS[2])
solid(c:poly{{204, 118}, {207, 115}, {208, 115}, {211, 118}}, BRASS, { sh = 1 })
solid(c:rect(205, 119, 210, 127), GLOW, { sh = 1, rim = false })
c:fillMask(c:rect(205, 119, 205, 127), BRASS[1]); c:fillMask(c:rect(210, 119, 210, 127), BRASS[2])
c:fillMask(c:rect(205, 119, 210, 119), BRASS[2])
P(207, 122, GLOW[3]); P(207, 123, "#fff8d8"); P(208, 123, "#fff8d8"); P(207, 124, "#fff8d8"); P(208, 124, GLOW[4]); P(207, 125, GLOW[2])
P(206, 120, "#fff8d8")
solid(c:rect(204, 128, 211, 129), BRASS, { sh = 1 })
-- glints of lantern light on the water beside the post
for _, g in ipairs({ {198, 137}, {200, 139}, {202, 137}, {196, 139}, {203, 140} }) do
  if WATER[g[2] * W + g[1]] == c:get(g[1], g[2]) then P(g[1], g[2], GLOW[3]); P(g[1] + 1, g[2], GLOW[4]) end
end
-- broken reflections of everything standing in the water
reflect(216, 220, 116, 8, "#3e3440", 0.55); reflect(260, 264, 116, 8, "#3e3440", 0.55)
reflect(214, 217, 115, 12, WOOD[2], 0.5)
reflect(268, 328, 129, 9, WOOD[1], 0.5)
reflect(174, 198, 135, 5, RED[2], 0.45)
for _, z in ipairs({ 1.7, 2.6 }) do
  local yb = math.floor(104 + 48 / z + 0.5); local w = math.max(3, math.floor(10 / z + 0.5))
  reflect(math.floor(212 + 6 * (152 - yb) / 38) - w - 1, math.floor(212 + 6 * (152 - yb) / 38) + 1, yb + math.floor(5 / z) + 1, 6, "#3e3440", 0.5)
  reflect(math.ceil(268 - 6 * (152 - yb) / 38) - 1, math.ceil(268 - 6 * (152 - yb) / 38) + w + 1, yb + math.floor(5 / z) + 1, 6, "#3e3440", 0.5)
end
-- light ripple lines crossing the reflections
for _, r in ipairs({ {214, 124, 6}, {258, 125, 7}, {280, 133, 12}, {300, 136, 10}, {180, 139, 8} }) do
  for x = r[1], r[1] + r[3] do if x % 3 ~= 0 then P(x, r[2], "#c4dce2") end end
end
-- a moored rowboat with oars, on the left water
shadow(186, 138, 18, 2, 0.35)
local hull = c:poly{{168, 126}, {204, 126}, {198, 135}, {174, 135}}
solid(hull, WOOD, { sh = 2, tex = planksH(WOOD, 3, 126, 4) })
c:fillMask(c:rect(168, 126, 204, 127), RED[3]); c:fillMask(c:rect(168, 127, 204, 127), RED[2])
c:fillMask(c:line({{178, 126}, {186, 119}}, 1), WOOD[4]); c:fillMask(c:line({{194, 126}, {188, 118}}, 1), WOOD[4])
P(186, 118, WOOD[3]); P(188, 117, WOOD[3])
c:fillMask(c:line({{200, 128}, {206, 131}}, 1), THAT[2])
-- lily pads and a ripple ring
for _, l in ipairs({ { 176, 116 }, { 183, 113 }, { 194, 114 }, { 340, 122 }, { 352, 128 }, { 360, 120 } }) do
  c:fillMask(c:ellipse(l[1], l[2], 3, 1), LEAF[3]); P(l[1] + 1, l[2], LEAF[4]); P(l[1] - 3, l[2], LEAF[1])
  if l[1] % 2 == 0 then P(l[1] + 2, l[2] - 1, "#ffc4d8") end
end
-- fire: layered tongues over the old flame (copied helper from camp), plus sparks
local function tongue(cx, by, h, w, lean)
  local m = HP.mask()
  for y = by, by - h, -1 do
    local t = (by - y) / h
    local hw = w * math.sin(math.pi * math.min(1, t * 0.92 + 0.08) ^ 0.75) * (1 - t * 0.35)
    local off = lean * t * t
    for x = math.floor(cx + off - hw + 0.5), math.floor(cx + off + hw + 0.5) do m:set(x, y) end
  end
  return m
end
local function flame(cx, by, h, w, lean)
  local m = tongue(cx, by, h, w, lean)
  solid(m, RED, { sh = 1 })
  for i, col in ipairs({ "#e8602e", GLOW[2], GLOW[3], "#fff2c0" }) do
    local mm = m:shrink(i * 2)
    if mm:count() > 0 then c:fillMask(mm, col) end
  end
end
flame(142, 238, 18, 9, 0); flame(135, 238, 12, 5, -2); flame(150, 238, 13, 5, 2)
for _, g in ipairs({ { 130, 210 }, { 154, 207 }, { 126, 200 }, { 158, 198 }, { 142, 196 } }) do P(g[1], g[2], GLOW[4]); P(g[1] + 1, g[2], GLOW[3]) end
-- logs peeking out of the pit
c:fillMask(c:line({{131, 238}, {140, 236}}, 2), WOOD[2]); c:fillMask(c:line({{153, 238}, {145, 236}}, 2), WOOD[2])

------------------------------------------------------------------ finish + save
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":104,"view":"gate",
 "spots":[
  {"k":"do","name":"Ferry landing and bell","x":266,"y":110,"box":[202,50,330,158]},
  {"k":"people","name":"Travellers' table and fire","x":96,"y":217,"box":[32,176,160,258]},
  {"k":"stop","name":"Stamp post and notice board","x":376,"y":183,"box":[340,148,412,218]},
  {"k":"homes","name":"Riverside huts","x":91,"y":108,"box":[18,68,166,150]},
  {"k":"wild","name":"Wild Trail","x":440,"y":166,"box":[416,104,462,228]}
 ],
 "stand":[{"x":194,"y":238},{"x":286,"y":238},{"x":240,"y":186},{"x":172,"y":172},{"x":308,"y":174},{"x":344,"y":246}],
 "compass_clear":[380,230,480,270]}
]]
local f = io.open(OUT .. NAME .. ".layout.json", "w"); f:write(layout); f:close()
print("ok " .. NAME)
