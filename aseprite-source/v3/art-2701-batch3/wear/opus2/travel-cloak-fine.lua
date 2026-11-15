-- travel-cloak-fine: Fine rank of the Travel Cloak (Opus second pass, batch3). 64x64.
-- Base: the finished Opus art-2701-opus/wear/travel-cloak.png (read only; it replaces the
-- game ph/travel-cloak.png). Same moss wool cloak on its peg, same drape and V.
-- Fine = the wooden toggle is cast in gold with a garnet, both front edges carry 2 px gold
-- piping, a gold band follows the scalloped hem, and
-- the lit shoulder gets a soft wool sheen plus one cream glint on the clasp.
-- quirk kept from base: orange autumn leaf caught on the hem.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local G = O.GOLD
local img = O.load(O.ROOT .. "/aseprite-source/v3/art-2701-opus/wear/travel-cloak.png")
local GREEN = { ["#86b464"]=1, ["#5e9452"]=1, ["#45784b"]=1, ["#335f43"]=1, ["#264a3c"]=1, ["#1c3530"]=1 }

-- 1. gold clasp: remap the toggle's wood ramp in its box only, set a garnet in the middle
O.remap(img, 24, 24, 37, 28, {
  ["#f6dca6"] = G.pale, ["#dca266"] = G.hi, ["#cf9b5c"] = G.base, ["#be8048"] = G.base,
  ["#9e6239"] = G.shade, ["#b07a46"] = G.shade, ["#7e4a2f"] = G.deep, ["#5e3627"] = G.deep, ["#3e2420"] = "#5a2a1a" })
O.paint(img, 30, 25, { "ab", "bc" }, { a = "#ff8a5c", b = "#e8493b", c = "#6e2038" })
O.px(img, 27, 25, "#fff4d6")

-- 2. gold piping down both front edges: lit gold on the left edge, shaded on the right
for y = 29, 56 do
  for x = 24, 38 do
    local h = O.get(img, x, y)
    if h == "#e6bd7e" then O.px(img, x, y, G.hi); O.px(img, x - 1, y, G.base)
    elseif h == "#b07a46" then O.px(img, x, y, G.base); O.px(img, x + 1, y, G.shade) end
  end
end

-- 3. gold hem band: the two lowest cloak pixels of each column
for x = 19, 56 do   -- starts right of the leaf, which lies over the hem
  local yb
  for y = 59, 40, -1 do if O.isBody(img, x, y) then yb = y break end end
  if yb then
    local h1, h2 = O.get(img, x, yb), O.get(img, x, yb - 1)
    local sh = x >= 42
    if GREEN[h1] then O.px(img, x, yb, sh and G.deep or G.shade) end
    if GREEN[h2] then O.px(img, x, yb - 1, sh and G.shade or G.base) end
  end
end

-- 4. sheen on the lit left shoulder and fold crests (finer, smoother wool)
local SHEEN = "#a8cc7a"
for _, p in ipairs({ { 17, 25 }, { 18, 25 }, { 16, 26 }, { 17, 26 }, { 15, 28 }, { 16, 27 },
                     { 19, 24 }, { 20, 24 }, { 21, 23 }, { 22, 23 }, { 22, 13 }, { 21, 14 }, { 22, 14 } }) do
  if O.get(img, p[1], p[2]) == "#86b464" or O.get(img, p[1], p[2]) == "#5e9452" then O.px(img, p[1], p[2], SHEEN) end
end
O.reink(img)
O.save(img, "travel-cloak-fine")
