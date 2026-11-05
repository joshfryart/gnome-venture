-- The Great Treehouse: cut-away tree, 480x270. Rooms fill the layout boxes (here_layouts.json 'treehouse'); a ledge at every one of the 24 perches.
-- Run: /tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script treehouse.lua
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "tree-house" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON
local rect, rr, poly, obj, tex, hash = S.rect, S.rr, S.poly, S.obj, S.tex, S.hash

---------------------------------------------------------------- sky, hills, meadow
c:stripes(0, 236, {"#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8"}, {2, 2, 2, 2, 3})
c:cloud(36, 70, 52, "#f8f0e0", "#d6e6f0"); c:cloud(380, 52, 44, "#f8f0e0", "#d6e6f0"); c:cloud(250, 40, 38, "#f8f0e0", "#d6e6f0")
c:terrain(function(x) return 186 + 14 * sin(x / 52) + 7 * sin(x / 19 + 1) end, "#7e9cc4", 240)
c:terrain(function(x) return 206 + 9 * sin(x / 41 + 2) + 5 * sin(x / 13) end, "#5f9a78", 244)
c:terrain(function(x) return 228 + 4 * sin(x / 30) end, GREEN[4], 269)
tex(rect(0, 232, 479, 269), function(x, y) if hash(x, y, 4) > .955 then return GREEN[5] elseif hash(x, y, 9) > .975 then return GREEN[3] end end)

---------------------------------------------------------------- canopy (behind everything)
local function blob(cx, cy, rx, ry, ramp)
  local m = c:ellipse(cx, cy, rx, ry)
  c:rim(m, ramp[1])
  tex(m, function(x, y)
    local t = ((x - cx) / rx) * .5 + ((y - cy) / ry) * .8   -- light from the upper left
    local i = t < -.55 and 5 or t < -.1 and 4 or t < .45 and 3 or 2
    if hash(x, y, 5) > .93 then i = min(6, i + 1) end
    return ramp[i]
  end)
end
for _, b in ipairs{ {40, 74, 60, 50}, {120, 44, 66, 38}, {210, 36, 60, 34}, {300, 34, 64, 36}, {392, 46, 70, 40}, {450, 80, 44, 46}, {20, 130, 26, 30}, {200, 80, 48, 34}, {296, 82, 50, 34} } do
  blob(b[1], b[2], b[3], b[4], GREEN)
end
for _, b in ipairs{ {80, 50, 38, 26}, {170, 28, 36, 20}, {262, 24, 34, 18}, {350, 30, 38, 20}, {430, 52, 34, 24}, {250, 64, 30, 18} } do blob(b[1], b[2], b[3], b[4], LEAF) end

---------------------------------------------------------------- trunk, roots, limbs
local trunk = poly{ {196, 74}, {284, 74}, {292, 140}, {300, 214}, {330, 244}, {352, 269}, {128, 269}, {150, 244}, {182, 214}, {188, 140} }
c:rim(trunk, TIMB[1])
tex(trunk, function(x, y)
  local k = floor((x + floor(y / 17) * 3) / 5)
  local t = (x - 188) / 112
  local i = t < .22 and 5 or t < .55 and 4 or 3
  if (k % 4) == 0 then i = i - 1 end
  if hash(x, floor(y / 3), 8) > .94 then i = i - 1 end
  return TIMB[max(1, min(6, i))]
end)
-- limbs to the side rooms
local function limb(pts, th)
  local m = c:line(pts, th)
  c:rim(m, TIMB[1]); tex(m, function(x, y) return (hash(floor(x / 4), y, 3) > .5 and TIMB[4] or TIMB[3]) end)
end
limb({{200, 176}, {160, 190}, {100, 196}}, 7); limb({{280, 170}, {330, 184}, {390, 188}}, 7)
limb({{200, 120}, {120, 118}, {70, 122}}, 6); limb({{282, 100}, {350, 96}, {420, 100}}, 7)
limb({{236, 78}, {236, 60}}, 8)

---------------------------------------------------------------- rooms (cut-away: open front, lit inside)
local function room(b, wall, floorR, o)
  o = o or {}
  local x0, y0, x1, y1 = b[1], b[2], b[3], b[4]
  local outer = rect(x0, y0, x1, y1)
  c:rim(outer, TIMB[1])
  S.obj(outer, TIMB, { base = 3 })                      -- timber frame
  local inner = rect(x0 + 4, y0 + 5, x1 - 4, y1 - 5)
  S.planks(inner, wall, { w = o.pw or 7, base = 4, vert = true, seed = o.seed or 1 })
  c:rim(inner, TIMB[1])
  local flo = rect(x0 + 4, y1 - 11, x1 - 4, y1 - 5)     -- floorboards
  S.planks(flo, OAK, { w = 8, base = 3, vert = false, seed = 7 })
  c:fillMask(rect(x0 + 4, y1 - 11, x1 - 4, y1 - 11), OAK[1])
  c:fillMask(rect(x0 - 2, y0 - 3, x1 + 2, y0 + 1), TIMB[5])  -- roof beam
  c:fillMask(rect(x0 - 2, y0 + 1, x1 + 2, y0 + 1), TIMB[2])
  S.glow((x0 + x1) // 2, (y0 + y1) // 2, (x1 - x0) // 2, "#ffd27a", o.glow or .3, {x0 + 4, y0 + 5, x1 - 4, y1 - 5})
  return inner
end
local function lantern(x, y)
  c:fillMask(rect(x, y - 6, x, y - 3), IRON[2])
  local m = rect(x - 2, y - 3, x + 2, y + 2); c:rim(m, IRON[1]); c:fillMask(m, GOLD[5]); c:fillMask(rect(x - 1, y - 1, x + 1, y), GOLD[6])
  S.glow(x, y, 9, "#ffe49a", .4, {x - 9, y - 9, x + 9, y + 9})
end
local function window(x0, y0, x1, y1)
  local m = rect(x0, y0, x1, y1); c:rim(m, TIMB[1]); c:fillMask(m, "#bfe4f6")
  c:fillMask(rect(x0, y0, x1, y0 + 2), "#e4f6ff"); c:fillMask(rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y1), TIMB[3]); c:fillMask(rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2), TIMB[3])
end

-- Parlour [92,126,210,196]: sofa, rug, lamp, picture, window
room({92, 126, 210, 196}, CREAM, OAK, { seed = 2 })
window(100, 140, 118, 156)
obj(rr(124, 150, 150, 168, 3), PINK, { base = 4 }); obj(rr(120, 160, 128, 178, 2), PINK, { base = 3 }); obj(rr(146, 160, 154, 178, 2), PINK, { base = 3 })  -- sofa
obj(rect(124, 168, 150, 182), PINK, { base = 3 }); obj(rect(126, 182, 130, 184), TIMB, { base = 2 }); obj(rect(144, 182, 148, 184), TIMB, { base = 2 })
obj(rect(158, 176, 196, 183), BARN, { base = 4 })   -- rug
c:fillMask(rect(160, 178, 194, 178), GOLD[5]); c:fillMask(rect(160, 181, 194, 181), GOLD[5])
obj(rect(172, 144, 186, 158), TEAL, { base = 3 }); c:fillMask(rect(174, 146, 184, 156), "#f4d88a")  -- picture
lantern(166, 134)

-- Loft [270,116,390,186]: hay bed, ladder, crates, bunting
room({270, 116, 390, 186}, CREAM, OAK, { seed = 3, pw = 8 })
obj(rect(280, 160, 312, 174), "#cc9e40" and GOLD, { base = 4 }); obj(rr(282, 152, 296, 162, 2), ROSE, { base = 4 })  -- bed and pillow
for i = 0, 5 do c:fillMask(rect(316 + i * 4, 126, 316 + i * 4, 172), TIMB[3]) end   -- (rungs drawn below)
obj(rect(316, 126, 318, 174), TIMB, { base = 4 }); obj(rect(334, 126, 336, 174), TIMB, { base = 4 })
for y = 132, 170, 9 do obj(rect(318, y, 334, y + 2), TIMB, { base = 5 }) end   -- ladder
obj(rect(346, 150, 372, 174), OAK, { base = 4 }); obj(rect(350, 138, 368, 150), OAK, { base = 5 }); c:fillMask(rect(346, 160, 372, 160), OAK[2])  -- crates
for i = 0, 6 do local x = 276 + i * 16; local f = poly{{x, 128}, {x + 12, 128}, {x + 6, 138}}; c:rim(f, "#2b1c26"); c:fillMask(f, ({"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8"})[i % 4 + 1]) end
lantern(300, 134)

-- Cellar [196,202,290,264]: barrels, jar shelf, steps
room({196, 202, 290, 264}, STONE, STONE, { seed = 4, glow = .22 })
obj(rr(204, 232, 226, 256, 4), OAK, { base = 3 }); c:fillMask(rect(204, 238, 226, 239), IRON[3]); c:fillMask(rect(204, 250, 226, 251), IRON[3])
obj(rr(230, 238, 250, 256, 4), OAK, { base = 4 }); c:fillMask(rect(230, 243, 250, 244), IRON[3]); c:fillMask(rect(230, 251, 250, 252), IRON[3])
obj(rect(256, 214, 284, 218), TIMB, { base = 4 })
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 206, x + 4, 213); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#e8493b", "#f5b82e", "#7cc35a", "#8a6fd0"})[i + 1]); c:fillMask(rect(x, 206, x + 4, 207), CREAM[5]) end
for i = 0, 3 do local x = 258 + i * 7; local j = rect(x, 224, x + 4, 231); c:rim(j, "#2b1c26"); c:fillMask(j, ({"#f5809f", "#5fc4c8", "#f5b82e", "#e8493b"})[i + 1]) end
obj(rect(256, 232, 284, 235), TIMB, { base = 4 }); lantern(264, 246)

-- Puzzle Room [20,202,120,264]: table of jigsaw pieces and a wall of puzzle pictures
room({20, 202, 120, 264}, VIOLET, OAK, { seed = 5 })
local cols = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}
for gy = 0, 2 do for gx = 0, 3 do   -- a jigsaw on the wall
  local x, y = 32 + gx * 9, 212 + gy * 9
  c:fillMask(rect(x, y, x + 7, y + 7), cols[(gx + gy * 2) % 6 + 1]); c:fillMask(rect(x, y, x + 7, y), "#fff4d6"); c:fillMask(rect(x + 7, y + 3, x + 8, y + 5), cols[(gx + gy * 2 + 1) % 6 + 1])
end end
c:rim(rect(32, 212, 67, 238), "#2b1c26")
obj(rect(72, 238, 112, 244), OAK, { base = 4 }); obj(rect(76, 244, 80, 256), TIMB, { base = 3 }); obj(rect(104, 244, 108, 256), TIMB, { base = 3 })  -- table
for i = 0, 4 do c:fillMask(rect(76 + i * 7, 233, 80 + i * 7, 237), cols[i % 6 + 1]); c:fillMask(rect(76 + i * 7, 233, 80 + i * 7, 233), "#fff4d6") end
lantern(94, 214)

-- Contest Hall [214,78,268,122]: trophy shelf
room({214, 78, 268, 122}, CREAM, OAK, { seed = 6, pw = 6 })
obj(rect(220, 108, 262, 111), TIMB, { base = 4 }); obj(rect(220, 94, 262, 96), TIMB, { base = 4 })
local function cup(x, y, g)
  local bowl = poly{{x, y}, {x + 8, y}, {x + 6, y + 6}, {x + 2, y + 6}}; c:rim(bowl, "#2b1c26"); c:fillMask(bowl, GOLD[g]); c:fillMask(rect(x + 1, y, x + 2, y + 3), GOLD[6])
  c:fillMask(rect(x + 3, y + 6, x + 5, y + 8), GOLD[3]); c:fillMask(rect(x + 1, y + 8, x + 7, y + 9), GOLD[2])
end
cup(224, 99, 4); cup(238, 99, 5); cup(252, 99, 4); cup(226, 85, 5); cup(246, 85, 4)
for i = 0, 2 do local d = S.diamond(228 + i * 14, 105, 3); c:rim(d, "#2b1c26"); c:fillMask(d, ({"#e8493b", "#5fc4c8", "#f5809f"})[i + 1]) end

-- Pal Book nook [412,72,470,130]: bookshelf
room({412, 72, 470, 130}, OAK, OAK, { seed = 8, pw = 5 })
for shelf = 0, 2 do
  local y = 80 + shelf * 17
  obj(rect(418, y + 13, 464, y + 15), TIMB, { base = 3 })
  local x = 419
  while x < 462 do
    local w = 3 + floor(hash(x, y, 2) * 3); local h = 9 + floor(hash(x, y, 3) * 4)
    c:rim(rect(x, y + 13 - h, x + w, y + 12), "#2b1c26"); c:fillMask(rect(x, y + 13 - h, x + w, y + 12), cols[floor(hash(x, y, 4) * 6) + 1]); c:fillMask(rect(x, y + 13 - h, x, y + 12), "#fff4d6")
    x = x + w + 2
  end
end

-- Cat Fish nook [336,188,420,216]: hammock, rod, bowl
room({336, 188, 420, 216}, TEAL, OAK, { seed = 9 })
local ham = poly{{346, 198}, {372, 198}, {366, 206}, {352, 206}}; c:rim(ham, "#2b1c26"); c:fillMask(ham, ROSE[4]); c:fillMask(rect(350, 198, 368, 199), ROSE[5])
c:line({{380, 196}, {394, 202}, {400, 208}}, 1):each(function(x, y) c:put(x, y, "#2b1c26") end)
c:fillMask(rect(398, 207, 402, 210), "#e8493b")
local bowl = rect(406, 205, 414, 209); c:rim(bowl, "#2b1c26"); c:fillMask(bowl, "#5fc4c8")

---------------------------------------------------------------- Yard door [4,124,72,190]: a big root-gate with a hanging sign (no text)
local post = rect(4, 128, 72, 190)
c:rim(post, TIMB[1]); S.planks(post, TIMB, { w = 7, base = 3, seed = 11 })
local arch = rr(16, 140, 60, 190, 14); c:rim(arch, TIMB[1]); S.planks(arch, OAK, { w = 5, base = 4, seed = 12 })
c:fillMask(rect(37, 140, 38, 190), OAK[1]); obj(rect(48, 164, 52, 168), GOLD, { base = 4 })
local sign = rect(18, 130, 58, 138); c:rim(sign, "#2b1c26"); c:fillMask(sign, GREEN[4]); c:fillMask(rect(18, 130, 58, 131), GREEN[5])
for i = 0, 3 do c:fillMask(rect(24 + i * 9, 133, 28 + i * 9, 135), "#fff4d6") end

---------------------------------------------------------------- ledges at the 24 perches (feet = perch y + 10)
local perches = {{60,60},{120,40},{180,58},{240,36},{300,58},{360,40},{420,62},{40,118},{96,100},{160,104},{220,96},{280,100},{340,98},{400,104},{450,120},{50,176},{110,170},{170,178},{230,172},{290,176},{350,170},{410,178},{70,236},{350,246}}
for i, p in ipairs(perches) do
  local x, y = p[1], p[2] + 11
  local m = rect(x - 16, y, x + 16, y + 3)
  c:rim(m, TIMB[1]); S.planks(m, OAK, { w = 8, base = 4, vert = true, seed = i })
  c:fillMask(rect(x - 16, y, x + 16, y), OAK[6])
  c:fillMask(rect(x - 10, y + 4, x - 8, y + 7), TIMB[3]); c:fillMask(rect(x + 8, y + 4, x + 10, y + 7), TIMB[3])
end

---------------------------------------------------------------- front leaves at the edges, a few flowers, then save
for _, b in ipairs{ {8, 20, 18, 14}, {472, 24, 16, 16}, {6, 252, 20, 14}, {330, 262, 20, 8} } do blob(b[1], b[2], b[3], b[4], LEAF) end
for i = 0, 18 do local x = 4 + i * 25 + floor(hash(i, 1, 1) * 10); local y = 250 + floor(hash(i, 2, 2) * 14)
  if x < 366 or y < 218 then if x > 200 and x < 300 and y > 240 then goto skip end c:fillMask(rect(x, y, x + 1, y + 1), cols[i % 6 + 1]) end
  ::skip:: end
c:save{ aseprite = OUT .. "tree-house.aseprite", png = OUT .. "tree-house.png" }
print(HP.report(c, true) and "ok" or "")
