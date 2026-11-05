-- The Pal Yard: garden yard beside the treehouse, 480x270, horizon 96. Sites fill the layout boxes (here_layouts.json 'yard').
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/tree-yard/out/")
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = "yard-pals" }
local S = dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
local floor, max, min, sin = math.floor, math.max, math.min, math.sin
local TIMB, OAK, CREAM, ROSE, GREEN, LEAF, BARN, GOLD, STONE, TEAL, VIOLET, PINK, IRON, DIRT =
  S.TIMB, S.OAK, S.CREAM, S.ROSE, S.GREEN, S.LEAF, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.IRON, S.DIRT
local rect, rr, poly, obj, tex, hash = S.rect, S.rr, S.poly, S.obj, S.tex, S.hash
local cols = {"#e8493b", "#f5b82e", "#7cc35a", "#5fc4c8", "#8a6fd0", "#f5809f"}

---------------------------------------------------------------- sky, far hills, grass, paths
c:stripes(0, 96, {"#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8"}, {2, 2, 2, 2, 3})
c:cloud(60, 52, 48, "#f8f0e0", "#d6e6f0"); c:cloud(300, 40, 40, "#f8f0e0", "#d6e6f0")
c:terrain(function(x) return 70 + 12 * sin(x / 48) + 5 * sin(x / 17 + 1) end, "#7e9cc4", 98)
c:terrain(function(x) return 84 + 7 * sin(x / 37 + 2) end, "#5f9a78", 98)
local grass = rect(0, 96, 479, 269)
S.tex(grass, function(x, y)
  local t = (y - 96) / 174
  local i = t < .25 and 3 or t < .6 and 4 or 4
  if hash(x, y, 6) > .955 then i = min(6, i + 1) elseif hash(x, y, 7) > .975 then i = max(1, i - 1) end
  return GREEN[i]
end)
c:fillMask(rect(0, 96, 479, 96), GREEN[2])
-- dirt paths joining the sites and the stand points (flat, plain: 28+ clear around stand slots)
local function path(pts, th) local m = c:line(pts, th); tex(m, function(x, y) return DIRT[hash(x, y, 2) > .93 and 3 or 4] end); return m end
path({{150, 206}, {240, 190}, {330, 196}}, 12); path({{240, 190}, {240, 226}}, 12); path({{170, 150}, {240, 150}, {330, 146}}, 10)
path({{120, 236}, {240, 232}, {360, 236}}, 10); path({{330, 146}, {392, 116}}, 8); path({{330, 196}, {420, 190}}, 8); path({{150, 206}, {84, 176}}, 8); path({{170, 150}, {64, 112}}, 6)
-- fence along the horizon
for x = 6, 474, 12 do obj(rect(x, 92, x + 2, 104), OAK, { base = 4 }) end
obj(rect(4, 95, 476, 97), OAK, { base = 5 }); obj(rect(4, 100, 476, 102), OAK, { base = 4 })

local function blobTree(cx, cy)   -- a bushy tree at the fence (hero size)
  local m = c:ellipse(cx, cy, 22, 18); c:rim(m, GREEN[1])
  tex(m, function(x, y) local t = ((x - cx) / 22) * .5 + ((y - cy) / 18) * .8; local i = t < -.5 and 5 or t < 0 and 4 or 3; return GREEN[i] end)
  obj(rect(cx - 3, cy + 14, cx + 3, cy + 26), TIMB, { base = 3 })
end
blobTree(24, 76); blobTree(452, 72); blobTree(300, 78)

---------------------------------------------------------------- Sick bay [30,92,100,136]: a little tent-cottage with a bandage banner (no text)
local sb = rect(36, 108, 94, 136); c:rim(sb, "#2b1c26"); S.planks(sb, CREAM, { w = 6, base = 4, seed = 3 })
local roof = poly{{30, 110}, {65, 92}, {100, 110}}; c:rim(roof, "#2b1c26"); tex(roof, function(x, y) return (floor(x / 6) % 2 == 0) and ROSE[4] or CREAM[5] end)
local door = rr(58, 118, 72, 136, 3); c:rim(door, "#2b1c26"); c:fillMask(door, TEAL[3])
local cross = {{63, 121, 67, 121}, {63, 124, 67, 124}}   -- stitched patch above the door
c:fillMask(rect(63, 112, 67, 116), "#e8493b"); c:fillMask(rect(64, 111, 66, 117), "#e8493b")
obj(rect(40, 118, 52, 128), CREAM, { base = 5 }); c:fillMask(rect(45, 118, 46, 128), TIMB[3]); c:fillMask(rect(40, 123, 52, 124), TIMB[3])

---------------------------------------------------------------- Garden plot [40,150,130,206]: raised beds with rows
local gp = rect(40, 150, 130, 206); c:rim(gp, TIMB[1]); obj(gp, TIMB, { base = 3 })
for r = 0, 1 do
  local bed = rect(46, 156 + r * 24, 124, 172 + r * 24); c:rim(bed, "#2b1c26"); tex(bed, function(x, y) return hash(x, y, 1) > .9 and "#6a3e2c" or "#845236" end)
  for i = 0, 7 do
    local x = 52 + i * 9; local y = 160 + r * 24
    c:fillMask(rect(x, y + 3, x + 1, y + 11), GREEN[3]); c:fillMask(rect(x - 2, y, x + 3, y + 4), GREEN[5]); c:fillMask(rect(x - 1, y - 1, x + 2, y), GREEN[6])
    if (i + r) % 3 == 0 then local f = S.diamond(x + 1, y - 2, 2); c:rim(f, "#2b1c26"); c:fillMask(f, cols[(i + r) % 6 + 1]) end
  end
end
obj(rect(112, 196, 124, 204), OAK, { base = 4 }); obj(rect(114, 192, 122, 196), IRON, { base = 3 })   -- watering can

---------------------------------------------------------------- Trail head [360,98,424,140]: gate arch and signpost to the hills
local g1, g2 = rect(362, 104, 368, 140), rect(416, 104, 422, 140)
obj(g1, TIMB, { base = 4 }); obj(g2, TIMB, { base = 4 }); obj(rect(360, 98, 424, 106), TIMB, { base = 5 })
local lantern = rect(388, 108, 394, 116); c:rim(lantern, "#2b1c26"); c:fillMask(lantern, GOLD[5])
for i = 0, 3 do local f = poly{{366 + i * 14, 108}, {376 + i * 14, 108}, {371 + i * 14, 116}}; c:rim(f, "#2b1c26"); c:fillMask(f, cols[i % 6 + 1]) end
obj(rect(396, 124, 400, 140), TIMB, { base = 3 }); obj(rect(388, 124, 412, 132), OAK, { base = 5 }); c:fillMask(rect(408, 126, 412, 130), "#fff4d6")

---------------------------------------------------------------- Delve mouth [392,166,468,214]: rock mound with a timbered cave
local mound = poly{{392, 214}, {400, 184}, {418, 168}, {444, 168}, {462, 184}, {468, 214}}
c:rim(mound, STONE[1]); tex(mound, function(x, y) local t = (x - 392) / 76; local i = t < .3 and 5 or t < .65 and 4 or 3; if hash(floor(x / 3), floor(y / 3), 5) > .8 then i = i - 1 end return STONE[max(1, min(6, i))] end)
local mouth = rr(416, 186, 446, 214, 6); c:rim(mouth, "#2b1c26"); c:fillMask(mouth, "#1a1226")
obj(rect(412, 184, 416, 214), TIMB, { base = 4 }); obj(rect(446, 184, 450, 214), TIMB, { base = 4 }); obj(rect(410, 180, 452, 186), TIMB, { base = 5 })
c:fillMask(rect(425, 204, 437, 214), "#3a2c4a")
for i = 0, 2 do c:fillMask(rect(400 + i * 24, 200, 404 + i * 24, 204), "#7cc35a") end

---------------------------------------------------------------- Kitchen and craft stations [198,118,282,178]: pavilion with a stove and a workbench
for _, x in ipairs{200, 276} do obj(rect(x, 126, x + 4, 178), TIMB, { base = 4 }) end
local awn = poly{{196, 128}, {284, 128}, {278, 118}, {202, 118}}; c:rim(awn, "#2b1c26"); tex(awn, function(x, y) return (floor(x / 8) % 2 == 0) and BARN[4] or CREAM[5] end)
local stove = rect(206, 148, 236, 178); obj(stove, IRON, { base = 3 }); c:fillMask(rect(212, 156, 230, 168), "#1a1226"); c:fillMask(rect(214, 160, 228, 166), "#f5b82e"); c:fillMask(rect(216, 162, 226, 166), "#ff8a5c")
obj(rect(210, 136, 218, 148), IRON, { base = 3 })   -- chimney pipe
obj(rect(244, 154, 274, 160), OAK, { base = 5 }); obj(rect(246, 160, 250, 178), TIMB, { base = 3 }); obj(rect(268, 160, 272, 178), TIMB, { base = 3 })
for i = 0, 3 do c:fillMask(rect(248 + i * 7, 148, 252 + i * 7, 153), cols[(i + 2) % 6 + 1]) end

---------------------------------------------------------------- Ledger [200,202,280,252]: a noticeboard with pinned notes and a ledger book
obj(rect(206, 206, 210, 252), TIMB, { base = 3 }); obj(rect(270, 206, 274, 252), TIMB, { base = 3 })
local board = rect(208, 204, 272, 236); c:rim(board, "#2b1c26"); S.planks(board, OAK, { w = 8, base = 4, vert = false, seed = 4 })
for i = 0, 5 do local x, y = 214 + (i % 3) * 18, 210 + floor(i / 3) * 12; c:rim(rect(x, y, x + 12, y + 8), "#2b1c26"); c:fillMask(rect(x, y, x + 12, y + 8), i % 2 == 0 and CREAM[6] or "#f4d88a"); c:fillMask(rect(x + 5, y, x + 6, y + 1), "#e8493b") end
obj(rect(224, 238, 256, 248), BARN, { base = 4 }); c:fillMask(rect(224, 241, 256, 241), CREAM[5]); c:fillMask(rect(239, 238, 240, 248), BARN[2])   -- the ledger book

---------------------------------------------------------------- flowers and tufts (never near the stand slots or the compass corner)
for i = 0, 40 do
  local x, y = floor(hash(i, 1, 9) * 470) + 4, 110 + floor(hash(i, 2, 9) * 150)
  local ok = true
  for _, s in ipairs{ {150, 206}, {330, 196}, {170, 150}, {330, 146}, {120, 236}, {360, 236} } do if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 < 34 ^ 2 then ok = false end end
  if x > 360 and y > 214 then ok = false end
  if ok and not c:get(x, y):find("^#c") then c:fillMask(rect(x, y, x + 1, y + 1), cols[i % 6 + 1]) end
end
c:save{ aseprite = OUT .. "yard-pals.aseprite", png = OUT .. "yard-pals.png" }
print("ok")
