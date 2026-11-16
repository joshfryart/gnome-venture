-- trail-pack-fine: Fine rank of the Trail Pack (Opus second pass, batch3). 64x64.
-- Base: game ph/trail-pack.png (read only). Same oat canvas pack, roll, strap and buckle.
-- Fine = a twisted gold cord binds the pack mouth, a gold braid runs along the flap hem,
-- two gold fern sprigs are embroidered on the flap either side of the strap, the strap
-- tip gets a brass aglet, and the buckle carries one cream glint.
-- quirk kept from base: lavender sprig on the roll.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local G = O.GOLD
local img = O.load(O.PH .. "trail-pack.png")
local function strap(x) return x >= 29 and x <= 33 end

-- 1. twisted gold cord at the mouth (y23), shade side from x42
for x = 16, 46 do
  local k = x % 3
  local c = (k == 0) and G.hi or (k == 1) and G.base or G.shade
  if x >= 42 then c = (k == 2) and G.deep or G.shade end
  O.body(img, x, 23, c)
end
for x = 16, 47 do if x % 3 == 2 then O.body(img, x, 24, "#8e7e62") end end   -- twist shadows under the cord
-- 2. gold braid on the flap hem (y38..39), skipping the strap
for x = 18, 45 do
  if not strap(x) then
    local sh = x >= 40
    O.body(img, x, 38, sh and G.base or ((x % 2 == 0) and G.hi or G.base))
    O.body(img, x, 39, sh and G.shade or ((x % 2 == 0) and G.base or G.shade))
    O.body(img, x, 40, "#6c5c4a")
  end
end
-- 3. embroidered gold ferns on the flap
local FERN = {
  "...A...",
  ".A.A.A.",
  "..ABA..",
  ".B.B.B.",
  "..BCB..",
  "...C...",
  "...D...",
}
local FM = { A = G.hi, B = G.base, C = G.shade, D = G.deep }
O.paint(img, 20, 28, FERN, FM)
O.paint(img, 36, 28, FERN, { A = G.base, B = G.base, C = G.shade, D = G.deep })
-- 4. brass aglet on the strap tip, glint on the buckle
O.paint(img, 29, 48, { ".ABC.", ".BCD.", "..D.." }, { A = G.hi, B = G.base, C = G.shade, D = G.deep })
O.px(img, 28, 43, "#fff4d6"); O.px(img, 29, 43, "#fff4d6")
O.save(img, "trail-pack-fine")
