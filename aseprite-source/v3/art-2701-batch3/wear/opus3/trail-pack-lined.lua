-- trail-pack-lined: Lined rank of the Trail Pack (Opus richness pass, opus3). 64x64.
-- Base: opus2/trail-pack-lined.png (read only): oat canvas pack with blanket roll, a fat
-- curly fleece collar at the mouth and a fleece band turned back on the flap hem.
-- opus3 adds: a deeper canvas contact shadow under the collar and the hem band (cream on
-- oat was the weakest pairing), a cooler hue-shifted fleece deep, brown blanket-stitch
-- along the flap band, leather grain on the strap, a rim light on the lit left side and a
-- cool bounce on the lower right. Fine is now a navy flap, so the two no longer share the
-- "light band" read at 16 px.
-- quirk: base lavender sprig on the roll, plus a red-capped mushroom tucked into the left
-- side pocket, poking out above it.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local img = O.base("trail-pack-lined")

-- 1. deeper contact shadow under the collar (row 28 tufts sit on it) and the hem band
for x = 15, 46 do
  if O.get(img, x, 29) == "#ad9e7a" or O.get(img, x, 29) == "#8e7e62" then O.px(img, x, 29, "#6c5c4a") end
  if O.get(img, x, 42) == "#ad9e7a" or O.get(img, x, 42) == "#8e7e62" then O.px(img, x, 42, "#6c5c4a") end
end
O.remap(img, 10, 20, 52, 45, { ["#b38a5c"] = "#a08068" })
-- 2. blanket-stitch over the top of the hem band (every 3 px), leather grain on the strap
for x = 18, 45 do
  if x % 3 == 0 and not (x >= 28 and x <= 34) and O.get(img, x, 37) then O.px(img, x, 37, "#8a5a3a") end
end
for _, p in ipairs({ { 30, 32 }, { 31, 35 }, { 30, 48 }, { 31, 51 } }) do
  if O.get(img, p[1], p[2]) == "#a86c4c" then O.px(img, p[1], p[2], "#8c5640") end
end
-- 3. rim light on the lit left side panel, cool bounce along the lower right
O.rim(img, "left", "#e4d8b0", { ["#c9bb92"] = 1, ["#ad9e7a"] = 1 }, { 8, 24, 20, 58 })
O.rim(img, "bottom", "#56607a", { ["#4a3c34"] = 1, ["#6c5c4a"] = 1 }, { 30, 50, 56, 60 })
-- 4. quirk: a mushroom tucked into the left side pocket
O.paint(img, 12, 34, { "rhr", "rrs", ".c." }, { r = "#e8493b", h = "#fff4d6", s = "#b52e3f", c = "#f6e6c4" })
O.reink(img)
O.save(img, "trail-pack-lined")
