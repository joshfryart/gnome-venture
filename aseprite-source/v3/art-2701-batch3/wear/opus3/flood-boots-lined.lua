-- flood-boots-lined: Lined rank of the Flood Boots (Opus richness pass, opus3). 64x64.
-- Base: opus2/flood-boots-lined.png (read only): green wellies with turned-down curly
-- sheepskin cuffs, splash at the toe.
-- opus3 adds: a cooler hue-shifted fleece deep, fat tufts (2 rows) hanging from the back
-- cuff over its dark mouth row (opus2 had 1 px), rubber rim light on the lit left edge, a
-- cool sea-blue bounce line where the toe and heel catch the puddle, a crinkle at the ankle,
-- a lighter welt on the sole top, a rubber pull-loop on the back boot's heel.
-- quirk: base splash at the toe, plus a wisp of fleece snagged on the pull-loop.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local F = O.FLEECE
local img = O.base("flood-boots-lined")
local W2F = { ["#ead2a6"] = F.mid, ["#d2b386"] = F.shade, ["#a8845e"] = F.deep, ["#f6e6c4"] = F.base }
O.remap(img, 9, 6, 42, 22, W2F)
O.remap(img, 30, 13, 40, 15, { ["#5a3a2a"] = F.deep })   -- back cuff underside: no brown holes

-- 1. tufts hanging from the back cuff over its dark mouth row
O.paint(img, 31, 16, {
  "32.233.32",
  ".4..34..4",
}, { ["2"] = F.base, ["3"] = F.mid, ["4"] = F.shade })
-- glossy back shaft: a soft highlight stripe and one wet glint
for y = 18, 36 do if y ~= 27 and y ~= 28 then O.body(img, 30, y, "#4f9a50") end end
O.px(img, 30, 20, "#86c262"); O.px(img, 30, 21, "#86c262")

-- 2. rubber: rim light on the lit left edge of the front boot, crinkle at the ankle
O.rim(img, "left", "#86c262", { ["#5eab55"] = 1, ["#3f8a4c"] = 1 }, { 9, 21, 20, 50 })
O.paint(img, 22, 39, { "s.", ".s" }, { s = "#7cc35a" })
O.paint(img, 25, 41, { "k.", ".l" }, { k = "#3f8a4c", l = "#22503f" })

-- 3. bounce: cool water light along the underside of the toe and the back heel
for x = 28, 37 do O.body(img, x, 50, (x % 2 == 0) and "#3a86b0" or "#4f9ab8") end
O.rim(img, "right", "#3a86b0", { ["#1b3533"] = 1, ["#22503f"] = 1 }, { 44, 38, 50, 46 })
-- sole welt: lit top row of the front sole
for x = 12, 38 do if O.get(img, x, 51) == "#80563f" then O.px(img, x, 51, "#a87458") end end
O.px(img, 12, 51, "#c48e68"); O.px(img, 13, 51, "#c48e68")

-- 4. pull-loop on the back boot's heel, with a fleece wisp caught on it
O.paint(img, 41, 18, {
  "kk..",
  "k.m.",
  "k.m.",
  "mm..",
}, { k = "#3f8a4c", m = "#22503f" })
O.px(img, 42, 19, nil); O.px(img, 42, 20, nil)
O.paint(img, 43, 17, { "12", ".4" }, { ["1"] = F.hi, ["2"] = F.mid, ["4"] = F.shade })
O.reink(img)
O.save(img, "flood-boots-lined")
