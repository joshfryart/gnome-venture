-- flood-boots-fine: Fine rank of the Flood Boots (Opus richness pass, opus3). 64x64.
-- Base: opus2/flood-boots-fine.png (read only): green wellies, polished chestnut cuffs with
-- gold piping, chestnut ankle strap with a small gold buckle, splash at the toe.
-- opus3 adds: a 4-row strap (lit top edge, leather grain, contact shadow) and a 9x7 cast
-- gold centre-bar buckle (opus2: 6x6), polished streaks and grain flecks on both cuffs,
-- gold welt piping along the front sole, rubber rim light on the lit left edge, a gloss
-- stripe on the back shaft, a cool sea-blue bounce along the toe underside, and a rubber
-- pull-loop on the back heel with a gold rivet.
-- quirk: base splash at the toe, plus one rain bead sitting on the polished front cuff.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local G = O.GOLD6
local img = O.base("flood-boots-fine")

-- 1. strap: 4 rows across both shafts, then a contact shadow on the rubber
local FRONT = { "#dc9c68", "#c47e4c", "#b06a40", "#683424" }
local BACK = { "#a5603a", "#86472f", "#76402a", "#4a2420" }
for i, y in ipairs({ 30, 31, 32, 33 }) do
  for x = 13, 27 do O.px(img, x, y, FRONT[i]) end
  for x = 29, 38 do O.px(img, x, y, BACK[i]) end
end
for x = 13, 27 do O.body(img, x, 34, "#2e6b45") end
for x = 29, 38 do O.body(img, x, 34, "#1b3533") end
for _, p in ipairs({ { 25, 31 }, { 27, 32 }, { 33, 31 }, { 36, 32 }, { 14, 32 } }) do O.px(img, p[1], p[2], "#8a4a2e") end  -- grain
O.px(img, 28, 30, "#4a2420"); O.px(img, 28, 31, "#4a2420"); O.px(img, 28, 32, "#4a2420"); O.px(img, 28, 33, "#4a2420")
-- 2. cast gold centre-bar buckle, rim lit upper left; strap shows through the openings
O.paint(img, 15, 28, {
  ".uuuuuuu.",
  "uphhhhhbu",
  "uhbooobsu",
  "uhbpphssu",
  "ubbqqqssu",
  "ubsssssdu",
  ".uuuuuuu.",
}, { u = G.umber, d = G.deep, s = G.shade, b = G.base, h = G.hi, p = G.pale, o = "#86472f", q = "#4a2420" })
O.px(img, 16, 29, "#fff4d6")
O.px(img, 13, 30, "#c47e4c"); O.px(img, 14, 33, "#4a2420")   -- strap tail end

-- 3. cuffs: polished streak (upper left) and grain flecks
for x = 12, 17 do O.body(img, x, 14, "#e8b07a") end
for x = 23, 27 do O.body(img, x, 9, "#e8b07a") end
for _, p in ipairs({ { 15, 15 }, { 19, 15 }, { 23, 15 }, { 27, 14 }, { 26, 10 }, { 31, 10 }, { 35, 9 } }) do
  local h = O.get(img, p[1], p[2])
  if h == "#a5603a" or h == "#c47e4c" or h == "#86472f" then O.px(img, p[1], p[2], "#76402a") end
end

-- 4. gold welt piping along the top of the front sole
for x = 12, 38 do
  if O.get(img, x, 51) == "#80563f" or O.get(img, x, 51) == "#9a6b4c" then
    O.px(img, x, 51, (x <= 30) and ((x % 3 == 0) and G.hi or G.base) or G.shade)
  end
end

-- 5. rubber: rim light, back-shaft gloss stripe, bounce under the toe
O.rim(img, "left", "#86c262", { ["#5eab55"] = 1, ["#3f8a4c"] = 1 }, { 9, 21, 20, 50 })
for y = 17, 29 do O.body(img, 30, y, "#4f9a50") end
for y = 35, 38 do O.body(img, 30, y, "#4f9a50") end
O.px(img, 30, 19, "#86c262"); O.px(img, 30, 20, "#86c262")
for x = 28, 37 do O.body(img, x, 50, (x % 2 == 0) and "#3a86b0" or "#4f9ab8") end
O.rim(img, "right", "#3a86b0", { ["#1b3533"] = 1, ["#22503f"] = 1 }, { 44, 38, 50, 46 })

-- 6. pull-loop on the back heel with a gold rivet
O.paint(img, 41, 18, {
  "kk..",
  "kgm.",
  "k.m.",
  "mm..",
}, { k = "#3f8a4c", m = "#22503f", g = G.base })
O.px(img, 42, 20, nil)

-- 7. quirk: a rain bead on the polished front cuff
O.paint(img, 24, 14, { "wq", "ns" }, { w = "#fff4d6", q = "#8fdcd8", n = "#5fc4c8", s = "#3a86b0" })
O.reink(img)
O.save(img, "flood-boots-fine")
