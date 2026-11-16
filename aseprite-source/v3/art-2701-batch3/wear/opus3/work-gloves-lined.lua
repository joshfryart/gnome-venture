-- work-gloves-lined: Lined rank of the Work Gloves (Opus richness pass, opus3). 64x64.
-- Base: opus2/work-gloves-lined.png (read only): tan leather pair with a thick curly
-- sheepskin lining rolling out of each cuff mouth.
-- opus3 adds: leather pores (grain) on the backs and fingers, a pale rim light on every lit
-- left edge, a cool lilac bounce on the back glove's lower-right edge, the 5-tone
-- hue-shifted fleece (cooler deep), a taller tufted band on the back glove so it shows
-- beside the front one.
-- quirk: the cream stitch row across each cuff (base), plus a fingertip worn through on
-- the front glove's middle finger, with the fleece lining peeking out of the hole.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local F = O.FLEECE
local img = O.base("work-gloves-lined")
O.gloveLeather(img)
O.remap(img, 14, 45, 48, 58, { ["#ead2a6"] = F.mid, ["#d2b386"] = F.shade, ["#a8845e"] = F.deep, ["#f6e6c4"] = F.base })
-- back glove band: tufts one row higher (it sits half behind the front band)
O.paint(img, 35, 46, { ".12..21..12" }, { ["1"] = F.hi, ["2"] = F.base })
-- worn-through fingertip with fleece peeking out
O.paint(img, 23, 13, { "ee", "12", "23" }, { e = "#55301f", ["1"] = F.hi, ["2"] = F.base, ["3"] = F.mid })
O.reink(img)
O.save(img, "work-gloves-lined")
