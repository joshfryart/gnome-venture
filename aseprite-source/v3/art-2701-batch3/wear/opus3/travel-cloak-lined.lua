-- travel-cloak-lined: Lined rank of the Travel Cloak (Opus richness pass, opus3). 64x64.
-- Base: the Opus art-2701-opus/wear/travel-cloak.png (read only), redrawn on the opus2 Lined
-- recipe: a sheepskin ruff round the neck hole and fleece facings down both front edges.
-- opus3 adds: a shaggy, uneven ruff (lumps and stray tufts, no ring), 2 px facings from the
-- top, a 5-tone hue-shifted fleece (cool lilac-brown deep), brown blanket-stitch where the
-- facing is sewn to the wool, a woven twill fleck in the moss wool, a yellow-green rim light
-- on the lit left edge and shoulder, a cool teal bounce line along the lower-right hem.
-- quirk: base orange leaf on the hem, plus a darned patch (cross-hatch in paler thread)
-- low on the left skirt, where the cloak was once torn.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local img = O.load(O.ROOT .. "/aseprite-source/v3/art-2701-opus/wear/travel-cloak.png")
local GREEN = { ["#86b464"]=1, ["#5e9452"]=1, ["#45784b"]=1, ["#335f43"]=1, ["#264a3c"]=1, ["#e6bd7e"]=1, ["#b07a46"]=1 }
local WOOLG = { ["#86b464"]=1, ["#5e9452"]=1, ["#45784b"]=1, ["#335f43"]=1, ["#264a3c"]=1, ["#1c3530"]=1 }
local F = O.FLEECE
local FR = { hi = F.hi, base = F.base, mid = F.mid, shade = F.shade, deep = F.deep }

-- 0. twill fleck in the moss wool (before the lining goes on): one tone up on a 2-row diagonal
local UP = { ["#5e9452"] = "#6a9e58", ["#45784b"] = "#507f50", ["#335f43"] = "#3c6a48", ["#264a3c"] = "#2d5442" }
O.each(img, 4, 13, 58, 58, function(x, y, h)
  if UP[h] and (x - y * 2) % 5 == 0 and y % 2 == 0 then return UP[h] end
end)

-- 1. neck ruff, hand-placed: lumpy outer edge, curls inside, the far lip of the hole in
--    shade (it faces away from the light), the near lip lit, two tufts over the toggle
O.paint(img, 20, 14, {
  "......1..11...1.......",
  "....1121122112211.....",
  "...11223223223322334..",
  "..1123223223223334434.",
  "..122233444444434445..",
  "..123245hhhhhh543445..",
  "...2234hhhhhhhh34445..",
  "...1233hhhhhhhh34445..",
  "....2323hhhhhh34445...",
  ".....33232332334445...",
  "......44.4...45.5.....",
}, { ["1"] = F.hi, ["2"] = F.base, ["3"] = F.mid, ["4"] = F.shade, ["5"] = F.deep, h = "#1c3530" })

-- 2. fleece facings down both front edges: 2 px from the top, 3 px from the knee
local face = {}
for y = 29, 56 do
  local lx, rx
  for x = 24, 38 do
    local h = O.get(img, x, y)
    if h == "#e6bd7e" and not lx then lx = x end
    if h == "#b07a46" then rx = x end
  end
  if lx and rx then
    local w = (y < 45) and 2 or 3
    if y >= 52 then w = 4 end
    for x = lx - w + 1, lx do face[y * 64 + x] = true end
    for x = rx, rx + w - 1 do face[y * 64 + x] = true end
  end
end
for _, p in ipairs({ { 23, 57 }, { 24, 57 }, { 25, 57 }, { 26, 57 }, { 35, 57 }, { 36, 57 }, { 37, 57 } }) do
  if O.isBody(img, p[1], p[2]) then face[p[2] * 64 + p[1]] = true end
end
O.wool(img, face, { ramp = FR, shadeFrom = 33, phase = 2 })
-- fold line where the facing turns back, with brown blanket-stitch over it every 3 rows
for y = 29, 57 do
  for x = 14, 50 do
    if face[y * 64 + x] and not face[y * 64 + x - 1] and x < 31 and O.isBody(img, x - 1, y) then
      O.px(img, x - 1, y, (y % 3 == 0) and "#8a5a3a" or "#264a3c")
      if y % 3 == 0 then O.px(img, x, y, "#b07a50") end
    end
    if face[y * 64 + x] and not face[y * 64 + x + 1] and x > 31 and O.isBody(img, x + 1, y) then
      O.px(img, x + 1, y, (y % 3 == 0) and "#5e3627" or "#1c3530")
      if y % 3 == 0 then O.px(img, x, y, "#8a5a3a") end
    end
  end
end

-- 3. rim light on the lit left edge and the top of the shoulders, bounce on the lower right
local LIT = { ["#86b464"] = "#b4d87e", ["#5e9452"] = "#86b464", ["#6a9e58"] = "#86b464", ["#45784b"] = "#5e9452" }
O.rim(img, "left", "#a8cc7a", LIT, { 4, 24, 26, 56 })
O.rim(img, "top", "#a8cc7a", { ["#86b464"] = 1, ["#5e9452"] = 1, ["#6a9e58"] = 1 }, { 6, 12, 22, 40 })
O.rim(img, "right", "#2f6a64", { ["#1c3530"] = 1, ["#264a3c"] = 1, ["#2d5442"] = 1 }, { 40, 40, 58, 56 })
O.rim(img, "bottom", "#2f6a64", { ["#1c3530"] = 1, ["#264a3c"] = 1, ["#2d5442"] = 1 }, { 38, 50, 58, 58 })

-- 4. quirk: a darned patch low on the left skirt (paler thread cross-hatch, framed by a stitch)
O.paint(img, 11, 43, {
  ".dcd.",
  "dabad",
  "cbabc",
  "dabad",
  ".dcd.",
}, { a = "#c4dc8e", b = "#5e9452", c = "#86b464", d = "#45784b" })

O.reink(img)
O.save(img, "travel-cloak-lined")
