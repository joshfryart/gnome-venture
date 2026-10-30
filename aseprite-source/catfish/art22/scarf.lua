-- scarf.lua : Yarn scarf for the player gnome (Cat Fish 2.2.x sink), TINTABLE layer like gnome-hat.png.
-- 80x100, same canvas/registration as the gnome-parts layers (centre column 40). Neutral greys only, so the
-- SVG multiply tint (pixel_tint_filter, gain 1.25: grey #cbcbcb ~ the tint colour) colours it.
-- Drawn as if it sits UNDER the beard: the beard footprint is erased at the end (the layer is stacked on top).
local here = debug.getinfo(1, "S").source:sub(2):match("(.*[/\\])") or "./"
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local REPO = here .. "../../../"
local OUT = here .. "out/"

-- same canvas as gnome-parts G.canvas(): bust grid, no halo, nothing bleeds
local c = GV.canvas{ w = 80, h = 100, mode = "bust", halo = 0, margin = 0, bleed = "" }

-- neutral outline + light thread (as G.neutral(true) in gnome-common.lua)
GV.C.ol1, GV.C.ol2, GV.C.ol3, GV.C.umber = "#646464", "#464646", "#2e2e2e", "#2e2e2e"
GV.C.gold, GV.C.goldS = "#fbfbfb", "#cacaca"

-- tint-friendly grey ramp (the hat's: base #cbcbcb -> tint colour after the 1.25 gain)
local N = { gloss = "#f8f8f8", dot = "#fdfdfd", rim = "#e4e4e4", base = "#cbcbcb", bounce = "#9c9c9c",
            shade = "#8e8e8e", deep = "#646464", pale = false }
local RIB, RIBS = "#a4a4a4", "#787878"   -- knit groove on lit / shaded yarn

-- the beard footprint (from the shipped layer) so the scarf tucks under it
local beard = c:mask()
do
  local img = Image{ fromFile = REPO .. "game/assets/img/gnome/gnome-beard.png" }
  for it in img:pixels() do if app.pixelColor.rgbaA(it()) > 0 then beard:set(it.x, it.y) end end
end

-- 1) two wraps round the neck (upper roll, lower roll), mostly hidden by the beard
local upper = c:rrect(21, 60, 59, 65, 2)
local lower = c:rrect(16, 64, 64, 70, 3)
-- 2) the tail hangs from the gnome's left (viewer's right) down the front, out from under the beard
local tail = c:poly({ {53, 66}, {61, 66}, {58, 87}, {50, 87} })
-- 3) two fringe tassels
local tas1 = c:rect(51, 88, 52, 92)
local tas2 = c:rect(55, 88, 56, 91)

-- tail first so the wraps lie over its top (inner contour + contact shadow where it comes out from under them)
c:part(tail, N, { cres = 2, deep = 0, gloss = false })
c:part(upper, N, { cres = 2, deep = 0, gloss = false })
c:part(lower, N, { cres = 3, deep = 0, gloss = false })
c:part(tas1, N, { flat = true })
c:part(tas2, N, { flat = true })

-- knit ribs: vertical grooves across the wraps, row ridges + a centre purl column down the tail
local function groove(m, test)
  m:each(function(x, y)
    if test(x, y) then
      local k = c:get(x, y)
      if k == N.base or k == N.rim then c:px(x, y, RIB) elseif k == N.shade or k == N.bounce then c:px(x, y, RIBS) end
    end
  end)
end
local inU, inL = upper:shrink(1), lower:shrink(1)
groove(inU, function(x, y) return x % 3 == 0 end)
groove(inL, function(x, y) return (x + 1) % 3 == 0 end)
local inT = tail:shrink(1)
groove(inT, function(x, y) return y >= 70 and y <= 83 and (y - 70) % 3 == 0 end)
groove(inT, function(x, y) return x == math.floor(57 - (y - 66) * 3 / 21 + 0.5) and y >= 70 and y <= 83 and (y - 70) % 3 ~= 0 end)
-- tassel twist: one groove pixel on each
c:px(51, 90, RIB); c:px(56, 89, RIBS)

-- cast-off seam across the tail end (light thread), gloss commas on the lit chunks
c:seam({ { 50, 85 }, { 58, 85 } })
c:gloss(lower, N, { 18, 66 })
c:gloss(tail, N, { 55, 74 })

-- build the outline now, then: no pure-black border (matches the other gnome layers) and erase the beard footprint
c:finish()
for k, h in pairs(c.pix) do
  local x, y = c:xy(k)
  if h == "#000000" or beard:has(x, y) then c.pix[k] = nil end
end

local t = c:save(OUT .. "gnome-scarf.aseprite", OUT .. "gnome-scarf.png")
print("gnome-scarf: " .. GV.report(t))
assert(t.semi == 0, "semi-transparent pixels")
