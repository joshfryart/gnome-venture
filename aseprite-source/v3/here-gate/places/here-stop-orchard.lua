-- Gnome Venture "Hearth Pop" v3 -- Orchard rest stop, GATE VIEW, hero scale. 480x270 native.
local SRC = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(SRC .. "lib/hp.lua")
local OUT = (app.params and app.params.out) or (SRC .. "here-gate/places/")
local NAME = "here-stop-orchard"
local W, Hh, VX, VY = 480, 270, 240, 112
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin

local function H(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 1) * 37.719) * 43758.5453 return n - floor(n) end
local function put(x, y, hex) if x >= 0 and y >= 0 and x < W and y < Hh then c:put(x, y, hex) end end
local function rect(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function poly(p) return c:poly(p) end
local function ell(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end

-- ramps: {edge, deep, shade, base, hi}
local R = {
  wood    = {"#3e2420", "#6a3e2c", "#8c5a3c", "#a8744c", "#c8955e"},
  pale    = {"#5a3a26", "#8a6040", "#b48a5a", "#d4aa72", "#ecca92"},
  thatch  = {"#5e3c1c", "#9a6a2c", "#c4903a", "#deb058", "#f4d27c"},
  plaster = {"#5e4e56", "#b0a09e", "#d4c4b0", "#efe0c2", "#fbf0d6"},
  roof    = {"#4e1e26", "#8a3632", "#b4503a", "#d26c48", "#ec9064"},
  stone   = {"#3e3a50", "#706a84", "#948ea2", "#b6b0be", "#d6d0d8"},
  blossom = {"#6e2c4c", "#c25c7c", "#e48aaa", "#f4b8cc", "#fde0ea"},
  leaf    = {"#1a3e30", "#2a5e3a", "#42803e", "#64a046", "#94c458"},
  dleaf   = {"#14302c", "#1e4636", "#2c5e40", "#3e7444", "#5a9050"},
  apple   = {"#4e1424", "#8e2230", "#c03634", "#e4564a", "#ff9a7e"},
  green   = {"#1c3a30", "#2e5a44", "#3e7a52", "#58985e", "#86b878"},
  blue    = {"#222c4c", "#364a78", "#4e6a9c", "#6e8ebc", "#a0bede"},
  gold    = {"#56360e", "#9a641a", "#c8922a", "#ecbe44", "#fbe484"},
  glow    = {"#7a3e18", "#cc7a2c", "#f2a844", "#ffd274", "#fff0b0"},
  cork    = {"#5a3a22", "#8e6038", "#b0804c", "#c89c62", "#dcb87c"},
  cloth   = {"#4e1a26", "#963036", "#c4463e", "#e06654", "#f29480"},
  cream   = {"#6a5a50", "#c4b49a", "#e0d2b4", "#f2e6c8", "#fcf4de"},
  barrel  = {"#3e2418", "#704028", "#965834", "#b87444", "#d8985c"},
  wicker  = {"#5a3a1a", "#8e6230", "#b48644", "#d0a45a", "#e8c47a"},
  kite    = {"#2a3a5c", "#3e6aa8", "#e0a030", "#f4c84a", "#fde888"},
}

---------------------------------------------------------------- painter
local function bbox(m) return m:bbox() end
local function obj(m, Rp, o)
  o = o or {}
  local x0, y0, x1, y1 = bbox(m)
  if not x0 then return m end
  if o.rim ~= false then c:rim(m, o.rimc or Rp[1], o.clip) end
  local lx, ly = o.lx or 0.38, o.ly or 0.26
  m:each(function(x, y)
    local fx = (x - x0) / max(1, x1 - x0)
    local fy = (y - y0) / max(1, y1 - y0)
    local v = 0.66 - lx * fx - ly * fy + (o.lift or 0)
    v = v + (H(x, y, o.seed or 3) - 0.5) * (o.noise or 0.16)
    if o.tex then v = v + o.tex(x, y) end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then v = v + 0.22 end
    if not m:has(x + 1, y) or not m:has(x, y + 1) then v = v - 0.2 end
    local i = (v > 0.74 and 5) or (v > 0.42 and 4) or (v > 0.17 and 3) or 2
    put(x, y, Rp[i])
  end)
  return m
end
-- textures
local function planksH(step, s) return function(x, y) return (y % step == 0 and -0.38 or 0) + (H(x // 3, y // step, s or 5) > 0.82 and -0.12 or 0) end end
local function planksV(step, s) return function(x, y) return (x % step == 0 and -0.38 or 0) + (H(x // step, y // 4, s or 6) > 0.8 and -0.12 or 0) end end
local function thatchT(x, y) return ((y % 4 == 3) and -0.34 or 0) + (H(x, y // 4, 9) > 0.66 and 0.16 or 0) + (H(x, y, 4) > 0.9 and -0.2 or 0) end
local function tileT(x, y) local r = y // 4 return ((y % 4 == 3) or ((x + r * 3) % 7 == 0)) and -0.34 or 0 end
local function stoneT(x, y) local r = y // 6 return ((y % 6 == 5) or ((x + (r % 2) * 5) % 10 == 0)) and -0.42 or (H(x // 10, r, 2) - 0.5) * 0.25 end
local function clumpT(s) return function(x, y) return (H(x // 3, y // 3, s) - 0.5) * 0.5 end end

-- ground type map for shadows
local gtype = {}
local function shadowM(m)
  m:each(function(x, y)
    if x < 0 or y < 0 or x >= W or y >= Hh then return end
    local g = gtype[y * W + x]
    if g == "path" then put(x, y, ((x + y) % 7 == 0) and "#8e6c66" or "#a07c6c")
    elseif g == "grass" then put(x, y, ((x + y) % 7 == 0) and "#4e6a58" or "#5c7a5e") end
  end)
end
local function shadowEll(cx, cy, rx, ry) shadowM(ell(cx, cy, rx, ry)) end

---------------------------------------------------------------- sky (spring late morning)
c:stripes(0, VY, {"#6ea6d8", "#80b4de", "#94c2e4", "#aacfe8", "#c2dcea", "#d8e4e2", "#ece8d4"}, {3, 3, 3, 3, 3, 2, 1})
local function cloud(x, y, w) c:cloud(x, y, w, "#fbf4e6", "#d4cadc") end
cloud(40, 40, 46) cloud(64, 44, 30) cloud(176, 34, 40) cloud(300, 46, 52) cloud(336, 50, 30) cloud(410, 30, 34)
-- far violet mountains
c:terrain(function(x) return 76 + 7 * sin(x * 0.021) + 5 * sin(x * 0.057 + 1) + 3 * sin(x * 0.13) end, "#9c9ccc", VY)
c:terrain(function(x) return 76 + 7 * sin(x * 0.021) + 5 * sin(x * 0.057 + 1) + 3 * sin(x * 0.13) + 2 end, "#8a8cc0", VY)
for x = 0, W - 1 do -- snowy/sunlit caps on left faces
  local y = floor(76 + 7 * sin(x * 0.021) + 5 * sin(x * 0.057 + 1) + 3 * sin(x * 0.13) + .5)
  put(x, y, "#c4c2e2") if H(x, 1, 7) > 0.5 then put(x, y + 1, "#b0b0d8") end
end
-- blue-green hills
c:terrain(function(x) return 92 + 5 * sin(x * 0.03 + 2) + 3 * sin(x * 0.09) end, "#7ea694", VY)
c:terrain(function(x) return 92 + 5 * sin(x * 0.03 + 2) + 3 * sin(x * 0.09) + 3 end, "#729c88", VY)
-- orchard hill band with rows of tiny trees
c:terrain(function(x) return 101 + 2 * sin(x * 0.05) end, "#8eb468", VY)
for _, ry in ipairs({100, 104, 108}) do
  local step = ry == 100 and 7 or (ry == 104 and 9 or 12)
  for x = 4 + (ry % 5), W - 4, step do
    if abs(x - VX) > 10 then
      local top = (H(x, ry, 3) > 0.5) and "#f2b8cc" or "#6a9a4c"
      local sh = (top == "#f2b8cc") and "#d088a4" or "#4e7c42"
      local s = ry == 108 and 2 or 1
      for dx = -s, s do put(x + dx, ry - 1, top) put(x + dx, ry, sh) end
      put(x - s, ry - 2, top) put(x, ry - 2, top)
      put(x, ry + 1, "#5a4a3a")
    end
  end
end

---------------------------------------------------------------- ground
local grassBands = {"#8cbc60", "#86b65a", "#7eae54", "#78a850", "#72a24c"}
for y = VY + 1, Hh - 1 do
  local t = (y - VY) / (Hh - VY)
  local bi = min(5, 1 + floor(t * 5))
  for x = 0, W - 1 do
    gtype[y * W + x] = "grass"
    local a = (x - VX) / (y - VY + 0.5)
    local stripe = floor(a * 3.2 + 100) % 2
    local col = grassBands[bi]
    if stripe == 1 then col = grassBands[min(5, bi + 1)] end
    local n = H(x, y, 11)
    if n > 0.94 then col = "#a6cc6c" elseif n < 0.04 then col = "#5e8c46" end
    put(x, y, col)
  end
end
-- grass tufts
for i = 1, 700 do
  local x, y = floor(H(i, 1, 21) * W), VY + 4 + floor(H(i, 2, 21) * (Hh - VY - 4))
  local s = (y - VY) > 60 and 1 or 0
  put(x, y, "#5a8a44") put(x, y - 1, "#6e9e4c") if s == 1 then put(x + 1, y - 2, "#a2c86a") put(x - 1, y - 1, "#94bc60") end
end
-- path (packed earth), wide at the bottom, to the vanishing point
local function pathEdge(y)
  local t = (y - VY) / (Hh - 1 - VY)
  local half = 5 + 100 * t + 2 * sin(y * 0.15)
  return VX - half, VX + half + 2 * t
end
local pathM = HP.mask()
for y = VY + 1, Hh - 1 do
  local l, r = pathEdge(y)
  for x = floor(l + .5), floor(r + .5) do pathM:set(x, y) end
end
c:rim(pathM, "#5e7c4c")
local P5 = {"#6a4a34", "#9a7650", "#c09a64", "#d6b27a", "#eacb96"}
pathM:each(function(x, y)
  gtype[y * W + x] = "path"
  local l, r = pathEdge(y)
  local fx = (x - l) / max(1, r - l)
  local v = 0.62 + (H(x, y, 13) - 0.5) * 0.24
  if fx > 0.78 then v = v - 0.14 end
  -- two soft cart ruts converging
  local a = (x - VX) / (y - VY + 0.5)
  if abs(abs(a) - 0.3) < 0.035 then v = v - 0.26 end
  if not pathM:has(x - 1, y) or not pathM:has(x + 1, y) then v = v - 0.3 end
  local col = (v > 0.78 and P5[5]) or (v > 0.5 and P5[4]) or (v > 0.28 and P5[3]) or P5[2]
  put(x, y, col)
end)
-- pebbles
for i = 1, 160 do
  local y = VY + 10 + floor(H(i, 5, 31) ^ 0.7 * (Hh - VY - 12))
  local l, r = pathEdge(y)
  local x = floor(l + 3 + H(i, 6, 31) * (r - l - 6))
  if pathM:has(x, y) and pathM:has(x + 2, y) then
    local big = (y - VY) > 70
    put(x, y, "#b6b0be") put(x + 1, y, "#948ea2") put(x, y + 1, "#8e6c5a")
    if big then put(x + 1, y - 1, "#d6d0d8") put(x + 2, y, "#706a84") put(x + 1, y + 1, "#8e6c5a") end
  end
end
-- grass tufts overhanging the path edges
for y = VY + 8, Hh - 1, 3 do
  local l, r = pathEdge(y)
  if H(y, 1, 41) > 0.4 then put(floor(l + 1), y, "#6e9e4c") put(floor(l + 1), y - 1, "#86b65a") end
  if H(y, 2, 41) > 0.4 then put(floor(r - 1), y, "#5e8c46") put(floor(r - 1), y - 1, "#78a850") end
end

---------------------------------------------------------------- HOMES (far left): thatched cottage + stone hut
-- cottage shadow
shadowM(poly{{32, 136}, {100, 136}, {110, 141}, {40, 141}})
-- chimney (behind roof)
obj(rect(74, 52, 82, 70), R.stone, { tex = stoneT })
obj(rect(73, 50, 83, 53), R.stone, { lift = 0.1 })
-- smoke wisps
put(76, 46, "#e4e0ec") put(77, 45, "#e4e0ec") put(79, 42, "#d8d4e4") put(80, 41, "#d8d4e4") put(81, 41, "#d8d4e4") put(78, 38, "#e4e0ec")
-- walls
local wall = rect(30, 92, 92, 136)
obj(wall, R.plaster, { tex = function(x, y) return (H(x // 2, y // 2, 8) > 0.86) and -0.2 or 0 end })
-- timber frame
local beams = rect(30, 92, 32, 136):add(rect(60, 92, 62, 136)):add(rect(90, 92, 92, 136)):add(rect(30, 112, 92, 113)):add(rect(30, 134, 92, 136))
beams:add(c:line({{33, 111}, {44, 94}}, 2)):add(c:line({{63, 94}, {74, 111}}, 2))
beams:each(function(x, y) put(x, y, (H(x, y, 2) > 0.7) and R.wood[3] or R.wood[2]) end)
-- windows (warm glow)
local function window(x0, y0, x1, y1)
  obj(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1), R.wood, { lift = -0.1 })
  local g = rect(x0, y0, x1, y1)
  g:each(function(x, y)
    local v = (y - y0) / max(1, y1 - y0)
    put(x, y, (v < 0.3 and R.glow[5]) or (v < 0.7 and R.glow[4]) or R.glow[3])
  end)
  local mx, my = (x0 + x1) // 2, (y0 + y1) // 2
  for y = y0, y1 do put(mx, y, R.wood[2]) end
  for x = x0, x1 do put(x, my, R.wood[2]) end
end
window(38, 97, 52, 108) window(68, 97, 84, 108) window(72, 117, 84, 128)
-- flower box under right window
obj(rect(70, 130, 86, 133), R.wood)
for x = 71, 85, 2 do put(x, 129, (x % 4 == 1) and R.blossom[4] or R.apple[4]) put(x + 1, 129, R.leaf[4]) end
-- door: green, arched top
local door = rect(42, 118, 54, 135):add(rect(43, 116, 53, 117)):add(rect(45, 115, 51, 115))
obj(door, R.green, { tex = planksV(3, 7) })
put(51, 127, R.gold[5]) put(51, 128, R.gold[3])
-- step stone
obj(rect(40, 136, 56, 138), R.stone)
-- thatch roof
local roof = poly{{24, 95}, {44, 58}, {82, 58}, {100, 95}}
obj(roof, R.thatch, { tex = thatchT, ly = 0.1 })
for x = 25, 99, 3 do put(x, 96, R.thatch[3]) put(x + 1, 97, R.thatch[2]) end -- drippy fringe
obj(rect(44, 56, 82, 59), R.thatch, { lift = 0.15 }) -- ridge
-- QUIRK: apple weathervane on the ridge
for y = 47, 55 do put(52, y, R.stone[2]) end
for x = 46, 58 do put(x, 52, R.stone[2]) end
local av = poly{{50, 44}, {54, 44}, {56, 46}, {56, 50}, {54, 51}, {50, 51}, {48, 50}, {48, 46}}
obj(av, R.apple, { noise = 0.05 })
put(52, 43, R.wood[2]) put(53, 42, R.leaf[4]) put(54, 42, R.leaf[5])

-- stone hut with red tile roof
shadowM(poly{{110, 136}, {148, 136}, {156, 141}, {118, 141}})
obj(rect(110, 108, 146, 136), R.stone, { tex = stoneT })
local hroof = poly{{102, 111}, {118, 88}, {138, 88}, {154, 111}}
obj(hroof, R.roof, { tex = tileT, ly = 0.1 })
obj(rect(117, 86, 139, 89), R.roof, { lift = 0.15 })
local hdoor = rect(122, 119, 133, 136):add(rect(123, 117, 132, 118)):add(rect(125, 116, 130, 116))
obj(hdoor, R.blue, { tex = planksV(3, 8) })
put(130, 127, R.gold[5])
window(137, 116, 143, 124)
-- bee skep beside hut door (a tiny charm, no bees)
local skep = poly{{112, 126}, {114, 122}, {118, 121}, {120, 124}, {120, 135}, {111, 135}}
obj(skep, R.thatch, { tex = function(x, y) return (y % 3 == 0) and -0.35 or 0 end })
put(115, 132, R.wood[1]) put(116, 132, R.wood[1])

---------------------------------------------------------------- CIDER PRESS (mid left decor)
shadowM(poly{{170, 145}, {206, 145}, {214, 150}, {178, 150}})
obj(rect(168, 112, 172, 145), R.wood, { tex = planksV(9) })
obj(rect(200, 112, 204, 145), R.wood, { tex = planksV(9) })
obj(rect(165, 110, 207, 116), R.wood, { tex = planksH(9) })
obj(rect(184, 116, 188, 128), R.stone, { tex = function(x, y) return (y % 2 == 0) and -0.3 or 0.1 end })
obj(rect(178, 104, 194, 107), R.stone) -- crank bar
obj(rect(185, 107, 187, 110), R.stone)
local vat = rect(175, 128, 197, 144)
obj(vat, R.barrel, { tex = planksV(4) })
for x = 175, 197 do put(x, 132, R.stone[2]) put(x, 140, R.stone[2]) end
obj(rect(176, 126, 196, 128), R.pale, { lift = 0.1 }) -- press plate
obj(rect(197, 138, 201, 140), R.wood) -- spout
put(201, 141, R.gold[4]) put(201, 142, R.gold[3]) -- drip
local jug = rect(198, 143, 204, 146)
obj(jug, R.cream, { rim = false })

---------------------------------------------------------------- STOP (mid right): notice board + stamp post
shadowM(poly{{306, 158}, {366, 158}, {378, 163}, {316, 163}})
obj(rect(312, 104, 318, 160), R.pale, { tex = planksV(7) })
obj(rect(350, 104, 356, 160), R.pale, { tex = planksV(7) })
local board = rect(300, 104, 368, 140)
obj(board, R.wood, { lift = -0.05 })
obj(rect(303, 107, 365, 137), R.cork, { tex = function(x, y) return (H(x, y, 17) > 0.86) and -0.25 or 0 end, rimc = R.wood[2] })
-- notes (no text: shapes only)
local function note(x0, y0, x1, y1, Rp, pin)
  obj(rect(x0, y0, x1, y1), Rp, { noise = 0.08, rimc = R.cork[1] })
  put((x0 + x1) // 2, y0 + 1, pin or R.apple[4]) put((x0 + x1) // 2 + 1, y0 + 1, R.apple[2])
end
note(306, 110, 324, 126, R.cream)
for y = 115, 123, 3 do for x = 308, 321 do if H(x, y, 19) > 0.25 then put(x, y, R.stone[2]) end end end
note(328, 109, 344, 123, R.blue, R.gold[5])
-- map note with dotted route
note(347, 111, 362, 133, R.cream, R.leaf[5])
for i = 0, 9 do put(349 + i, 130 - (i * 17) % 15 // 2 - i, R.apple[3]) end
put(359, 118, R.apple[2]) put(360, 118, R.apple[2]) put(359, 117, R.apple[2])
-- apple icon note
note(328, 126, 344, 136, R.cream, R.blue[4])
local ai = poly{{333, 129}, {339, 129}, {340, 131}, {339, 134}, {333, 134}, {332, 131}}
obj(ai, R.apple, { noise = 0.04, rim = false })
put(336, 128, R.leaf[3])
-- shingle roof
local sroof = poly{{294, 105}, {304, 93}, {364, 93}, {374, 105}}
obj(sroof, R.roof, { tex = tileT })
-- icon plaque on the roof peak: rubber stamp
obj(rect(324, 80, 344, 94), R.gold, { tex = function(x, y) return 0 end })
obj(rect(332, 82, 336, 86), R.wood, { rim = true })
obj(rect(328, 87, 340, 89), R.wood)
obj(rect(327, 90, 341, 91), R.apple)
-- stamp box hanging between posts
for y = 141, 144 do put(326, y, R.stone[2]) put(342, y, R.stone[2]) end
obj(rect(322, 145, 346, 156), R.apple, { tex = planksH(4) })
obj(rect(331, 148, 337, 153), R.gold, { noise = 0.05 })
-- QUIRK: boot planter at the post foot
local boot = poly{{358, 146}, {364, 146}, {364, 156}, {370, 156}, {371, 160}, {358, 160}}
obj(boot, R.wood, { lift = 0.05 })
for x = 357, 365, 2 do put(x, 145, R.blossom[4]) put(x + 1, 144, R.blossom[3]) put(x, 143, R.leaf[4]) end

---------------------------------------------------------------- WILD TRAIL (far right): leafy arch + trail + signpost
-- depth inside the arch (dark wood)
local inside = poly{{410, 76}, {460, 70}, {462, 156}, {410, 156}}
inside:each(function(x, y)
  local v = H(x // 3, y // 3, 23)
  put(x, y, (v > 0.7 and "#3e6a4e") or (v > 0.35 and "#2e5444") or "#24443c")
end)
for x = 414, 460, 6 do for y = 80, 150 do if H(x, y // 9, 29) > 0.4 then put(x, y, "#1e3832") end end end
-- trail through the arch bending off to the right edge
local trail = poly{{404, 158}, {438, 158}, {462, 132}, {462, 124}, {448, 128}, {420, 148}}
obj(trail, {"#5e4632", "#8a6a48", "#b08a5a", "#c8a26c", "#dcbc86"}, { rim = false, noise = 0.2 })
-- trunks
local lt = poly{{404, 158}, {414, 158}, {412, 120}, {416, 86}, {408, 84}, {404, 120}}
obj(lt, R.wood, { tex = planksV(3, 12) })
local rtr = poly{{446, 158}, {456, 158}, {458, 110}, {462, 80}, {454, 80}, {450, 110}}
obj(rtr, R.wood, { tex = planksV(3, 13) })
-- leafy arch canopy
local can = ell(412, 74, 16, 14):add(ell(434, 62, 22, 11)):add(ell(452, 70, 12, 14)):add(ell(426, 80, 12, 7))
obj(can, R.dleaf, { tex = clumpT(31) })
for i = 1, 40 do
  local x, y = 396 + floor(H(i, 1, 33) * 66), 52 + floor(H(i, 2, 33) * 34)
  if can:has(x, y) and can:has(x + 1, y + 1) then put(x, y, R.blossom[4]) put(x + 1, y, R.blossom[3]) put(x, y + 1, R.blossom[3]) end
end
-- hanging vines
for _, vx in ipairs({418, 430, 444}) do for y = 84, 92 + (vx % 7) do put(vx + (y % 3 == 0 and 1 or 0), y, R.leaf[3]) end end
-- signpost with arrow pointing right (into the wild)
shadowM(poly{{390, 156}, {398, 156}, {404, 159}, {394, 159}})
obj(rect(391, 104, 395, 158), R.pale, { tex = planksV(9) })
local arrow = poly{{386, 110}, {414, 110}, {422, 116}, {414, 122}, {386, 122}}
obj(arrow, R.green, { tex = planksH(4) })
local leafI = poly{{396, 113}, {402, 112}, {406, 116}, {402, 120}, {396, 119}}
leafI:each(function(x, y) put(x, y, R.leaf[5]) end)
for x = 397, 405 do put(x, 116, R.leaf[2]) end
-- little lantern charm on the arch
for y = 86, 92 do put(426, y, R.stone[1]) end
obj(rect(423, 93, 429, 101), R.glow, { rimc = R.wood[1] })

---------------------------------------------------------------- DO (near left): apple tree, ladder, crates
-- tree shadow on grass
shadowM(poly{{24, 254}, {104, 254}, {124, 264}, {40, 264}})
-- trunk with roots and QUIRK tiny door
local trunk = poly{{50, 200}, {64, 200}, {66, 244}, {74, 258}, {40, 258}, {48, 244}}
obj(trunk, R.wood, { tex = planksV(3, 14), lx = 0.5 })
local tdoor = rect(53, 247, 59, 257):add(rect(54, 245, 58, 246))
obj(tdoor, R.blue, { rimc = R.wood[1] })
put(58, 252, R.gold[5])
-- canopy
local canopy = ell(60, 182, 42, 26):add(ell(34, 170, 18, 14)):add(ell(84, 168, 20, 14)):add(ell(58, 162, 26, 11))
canopy:add(ell(28, 190, 14, 12)):add(ell(94, 190, 14, 12))
obj(canopy, R.leaf, { tex = clumpT(37) })
-- blossom clusters and apples
for i = 1, 70 do
  local x, y = 18 + floor(H(i, 1, 43) * 92), 152 + floor(H(i, 2, 43) * 60)
  if canopy:has(x - 1, y - 1) and canopy:has(x + 2, y + 2) then
    put(x, y, R.blossom[5]) put(x + 1, y, R.blossom[4]) put(x, y + 1, R.blossom[4]) put(x + 1, y + 1, R.blossom[3])
  end
end
for i = 1, 22 do
  local x, y = 22 + floor(H(i, 3, 47) * 84), 166 + floor(H(i, 4, 47) * 46)
  if canopy:has(x - 1, y - 1) and canopy:has(x + 4, y + 4) then
    local a = rect(x, y, x + 3, y + 3)
    a:cut(rect(x, y, x, y)):cut(rect(x + 3, y, x + 3, y))
    obj(a, R.apple, { noise = 0, rimc = R.leaf[1] })
    put(x + 1, y + 1, R.apple[5]) put(x + 2, y - 1, R.wood[2])
  end
end
-- QUIRK: kite caught in the tree top
local kite = poly{{74, 148}, {80, 154}, {74, 162}, {68, 154}}
obj(kite, R.kite, { noise = 0.02 })
for y = 149, 161 do put(74, y, R.kite[2]) end
for x = 69, 79 do put(x, 154, R.kite[2]) end
for i = 0, 8 do put(80 + i, 162 + i + (i % 2), R.apple[3]) if i % 3 == 1 then put(81 + i, 162 + i, R.blossom[3]) end end
-- ladder leaning on the tree
local rails = c:line({{86, 258}, {100, 176}}, 2):add(c:line({{98, 258}, {112, 178}}, 2))
local rungs = HP.mask()
for k = 0, 7 do
  local t = 0.08 + k * 0.12
  local ya = floor(258 - t * 82)
  local xa, xb = floor(86 + t * 14) + 1, floor(98 + t * 14)
  rungs:add(rect(xa, ya, xb, ya + 1))
end
obj(rungs, R.pale, { lift = 0.1 })
obj(rails, R.pale, { lift = 0.1 })
-- crate shadows
shadowM(poly{{102, 258}, {152, 258}, {160, 263}, {110, 263}})
local function crate(x0, y0, x1, y1, s)
  obj(rect(x0, y0, x1, y1), R.pale, { tex = planksH(5, s) })
  for y = y0, y1 do put(x0 + 2, y, R.pale[2]) put(x1 - 2, y, R.pale[2]) end
  -- end mark: apple icon burned in
  local cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
  put(cx - 1, cy, R.wood[2]) put(cx, cy, R.wood[2]) put(cx + 1, cy, R.wood[2]) put(cx, cy - 1, R.wood[2]) put(cx, cy + 1, R.wood[2]) put(cx, cy - 2, R.leaf[3])
end
local function apples(x0, x1, ytop, s)
  for x = x0, x1 - 3, 4 do
    local yy = ytop - ((x // 4) % 2) * 2
    local a = rect(x, yy, x + 3, yy + 3) a:cut(rect(x, yy, x, yy)):cut(rect(x + 3, yy, x + 3, yy))
    local Rp = (H(x, s, 5) > 0.75) and R.gold or R.apple
    obj(a, Rp, { noise = 0, rimc = Rp[1] })
    put(x + 1, yy + 1, Rp[5])
  end
end
apples(106, 128, 236, 1) apples(130, 150, 236, 2)
crate(104, 238, 127, 258, 1)
crate(129, 238, 150, 258, 2)
apples(117, 141, 212, 3)
crate(114, 214, 140, 236, 3)
-- QUIRK: one big bitten apple on top
local big = poly{{124, 202}, {132, 202}, {135, 205}, {135, 210}, {132, 213}, {124, 213}, {121, 210}, {121, 205}}
big:cut(ell(135, 207, 3, 3))
obj(big, R.apple, { noise = 0.03 })
for y = 205, 209 do put(132, y, R.cream[4]) end put(131, 207, R.cream[5])
put(127, 201, R.wood[2]) put(127, 200, R.wood[2]) put(128, 199, R.leaf[4]) put(129, 199, R.leaf[5])

---------------------------------------------------------------- PEOPLE (near right): picnic blanket, table, fire pit
-- blanket (gingham) in perspective
local blank = poly{{300, 226}, {314, 196}, {362, 196}, {360, 226}}
c:rim(blank, R.cloth[1])
blank:each(function(x, y)
  local a = floor((x - 240 - (y - 196) * 0.0) / 6) + floor((y - 196) / 5)
  local cx2, cy2 = floor(x / 6) % 2, floor((y - 196) / 5) % 2
  local col
  if cx2 == 1 and cy2 == 1 then col = R.cloth[2] elseif cx2 == 1 or cy2 == 1 then col = R.cloth[4] else col = R.cream[4] end
  if not blank:has(x, y + 1) then col = R.cloth[2] end
  put(x, y, col)
end)
for x = 302, 359, 3 do put(x, 227, R.cloth[3]) end -- fringe
-- wicker basket on blanket
shadowM(poly{{322, 220}, {344, 220}, {348, 223}, {326, 223}})
local bh = c:line({{322, 208}, {326, 200}, {338, 200}, {342, 208}}, 2)
obj(bh, R.wicker, { rim = true })
obj(rect(320, 207, 344, 219), R.wicker, { tex = function(x, y) return (((x + y) % 4 == 0) or ((x - y) % 4 == 0)) and -0.3 or 0 end })
put(324, 206, R.cloth[4]) put(325, 205, R.cloth[4]) put(326, 206, R.cloth[2]) -- napkin tip
-- table + benches
shadowM(poly{{372, 222}, {434, 222}, {444, 228}, {380, 228}})
obj(rect(376, 200, 380, 222), R.wood) obj(rect(424, 200, 428, 222), R.wood)
obj(rect(368, 194, 434, 200), R.pale, { tex = planksH(3, 21) })
obj(rect(370, 212, 432, 215), R.pale, { tex = planksV(8) })
obj(rect(374, 216, 377, 224), R.wood) obj(rect(426, 216, 429, 224), R.wood)
-- cider jug with handle
local jugM = poly{{386, 182}, {392, 182}, {394, 186}, {394, 193}, {384, 193}, {384, 186}}
obj(jugM, R.cream)
obj(c:line({{394, 186}, {397, 188}, {394, 191}}, 1), R.cream)
obj(rect(387, 179, 391, 181), R.wood)
-- mugs
obj(rect(400, 187, 405, 193), R.barrel) obj(rect(409, 187, 414, 193), R.barrel)
put(401, 187, R.gold[5]) put(410, 187, R.gold[5])
-- pie with a slice missing (wedge cut)
local pie = poly{{416, 189}, {430, 189}, {432, 193}, {414, 193}}
obj(pie, R.gold, { tex = function(x, y) return ((x + y) % 4 == 0) and -0.3 or 0 end })
for x = 418, 422 do put(x, 189, R.apple[3]) end
-- fire pit: square stone ring, logs, flames
shadowM(poly{{438, 224}, {460, 224}, {462, 228}, {442, 228}})
obj(rect(438, 210, 460, 224), R.stone, { tex = stoneT })
obj(rect(442, 208, 456, 211), R.barrel)
local flame = poly{{442, 208}, {444, 198}, {447, 203}, {449, 192}, {452, 202}, {454, 197}, {456, 208}}
flame:each(function(x, y)
  local v = (y - 192) / 16 + (H(x, y, 51) - 0.5) * 0.2
  put(x, y, (v < 0.35 and R.glow[5]) or (v < 0.6 and R.glow[4]) or (v < 0.85 and R.glow[3]) or R.glow[2])
end)
c:rim(flame, R.glow[2], HP.mask():add(rect(436, 190, 462, 207)))
-- warm glow sparks
put(446, 188, R.glow[4]) put(452, 185, R.glow[5]) put(449, 182, R.glow[4])
-- string of lights from fire post to table
for x = 380, 436 do
  local y = floor(176 + ((x - 408) ^ 2) / 160)
  put(x, y, R.wood[1])
  if x % 8 == 0 then put(x, y + 1, R.glow[4]) put(x, y + 2, R.glow[3]) end
end
obj(rect(434, 172, 436, 208), R.wood)
obj(rect(366, 172, 368, 193), R.wood)

---------------------------------------------------------------- falling petals
for i = 1, 70 do
  local x, y = 18 + floor(H(i, 7, 61) * 444), 16 + floor(H(i, 8, 61) * 230)
  if not (x >= 380 and y >= 230) then
    local s = H(i, 9, 61) > 0.5
    put(x, y, R.blossom[5]) put(x + 1, y + (s and 1 or 0), R.blossom[3])
  end
end

---------------------------------------------------------------- GATE FRAME (front): posts, beam, blossom garland, lanterns, charm
local fwood = {"#2e1a1a", "#523022", "#6e442c", "#8a5c3a", "#a8784c"}
local lpost = rect(0, 0, 13, Hh - 1)
local rpost = rect(W - 14, 0, W - 1, Hh - 1)
obj(lpost, fwood, { tex = planksV(4, 71), ly = 0.05 })
obj(rpost, fwood, { tex = planksV(4, 72), ly = 0.05 })
local beam = rect(0, 0, W - 1, 11)
obj(beam, fwood, { tex = planksH(6, 73), lx = 0.05 })
for x = 0, W - 1 do put(x, 12, fwood[1]) end
-- corner braces
obj(poly{{14, 12}, {30, 12}, {14, 28}}, fwood, { lift = 0.05 })
obj(poly{{W - 15, 12}, {W - 31, 12}, {W - 15, 28}}, fwood, { lift = -0.05 })
-- blossom garland along the beam
local gar = HP.mask()
for x = 4, W - 5, 9 do
  local y = 12 + floor(3 * abs(sin(x * 0.05)))
  gar:add(ell(x, y, 5, 3))
end
gar:add(ell(8, 24, 6, 10)):add(ell(W - 9, 24, 6, 10)):add(ell(10, 40, 4, 6)):add(ell(W - 11, 40, 4, 6))
obj(gar, R.leaf, { tex = clumpT(75), ly = 0.4 })
for i = 1, 140 do
  local x, y = floor(H(i, 1, 77) * W), 6 + floor(H(i, 2, 77) * 40)
  if gar:has(x, y) and gar:has(x + 1, y + 1) then put(x, y, R.blossom[5]) put(x + 1, y, R.blossom[4]) put(x, y + 1, R.blossom[3]) put(x + 1, y + 1, R.blossom[2]) end
end
for i = 1, 16 do
  local x = 20 + floor(H(i, 3, 79) * 440)
  local y = 14 + floor(3 * abs(sin(x * 0.05)))
  if gar:has(x, y) then
    local a = rect(x, y + 2, x + 3, y + 5) a:cut(rect(x, y + 2, x, y + 2)):cut(rect(x + 3, y + 2, x + 3, y + 2))
    obj(a, R.apple, { noise = 0, rimc = R.leaf[1] }) put(x + 1, y + 3, R.apple[5])
  end
end
-- hanging lanterns
local function lantern(lx, top, len)
  for y = top, top + len do put(lx, y, ((y % 2) == 0) and R.stone[1] or R.stone[2]) end
  local y0 = top + len + 1
  obj(rect(lx - 4, y0, lx + 4, y0 + 2), R.wood)
  local body = rect(lx - 5, y0 + 3, lx + 5, y0 + 15)
  c:rim(body, R.wood[1])
  body:each(function(x, y)
    local e = (x == lx - 5 or x == lx + 5 or y == y0 + 3 or y == y0 + 15 or x == lx)
    local v = abs(x - lx) / 5 + (y - y0 - 3) / 24
    put(x, y, e and R.wood[2] or ((v < 0.4 and R.glow[5]) or (v < 0.8 and R.glow[4]) or R.glow[3]))
  end)
  obj(rect(lx - 3, y0 + 16, lx + 3, y0 + 17), R.wood)
  put(lx, y0 + 18, R.gold[4])
end
lantern(34, 13, 10) lantern(W - 35, 13, 10)
-- centre charm: wooden apple with a blossom
for y = 13, 18 do put(VX, y, R.stone[2]) end
local charm = poly{{235, 20}, {245, 20}, {248, 23}, {248, 29}, {245, 33}, {235, 33}, {232, 29}, {232, 23}}
charm:cut(rect(239, 19, 241, 21))
obj(charm, R.apple, { noise = 0.04 })
put(236, 23, R.apple[5]) put(237, 23, R.apple[5]) put(236, 24, R.apple[5])
put(240, 19, R.wood[2]) put(242, 18, R.leaf[4]) put(243, 18, R.leaf[5]) put(243, 17, R.leaf[4])
for x = 233, 247 do if (x % 3) == 0 then put(x, 34, R.gold[4]) end end

---------------------------------------------------------------- save
HP.assertClean(c)
c:finish{ outline = false }
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[
{"k":"do","name":"Orchard Rows","x":83,"y":205,"box":[16,146,150,264]},
{"k":"people","name":"Picnic Green","x":376,"y":203,"box":[296,176,462,230]},
{"k":"stop","name":"Stamp Post","x":334,"y":121,"box":[294,78,374,164]},
{"k":"homes","name":"Orchard Cottages","x":91,"y":95,"box":[22,40,158,142]},
{"k":"wild","name":"Wild Trail","x":424,"y":104,"box":[386,48,462,160]}],
"stand":[{"x":190,"y":244},{"x":278,"y":250},{"x":240,"y":212},{"x":214,"y":178},{"x":262,"y":150},{"x":338,"y":254}],
"compass_clear":[380,230,480,270]}]]
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write((layout:gsub("\n", ""))) f:close()
print("done " .. NAME)
