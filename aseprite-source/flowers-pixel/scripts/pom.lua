-- Gnome Venture flower head: pom (Stitched Toy, tintable). Petals neutral grey, centre fixed gold.
local D  = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O  = D .. "flowers-pixel/"
local c  = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, margin = 0 }

-- neutral grey ramps (no hue) so the runtime tint carries the colour; three depths give the dome
local function grey(b, rim, gl, dot, sh, dp, bo)
  return { base = b, rim = rim, gloss = gl, dot = dot, shade = sh, deep = dp, bounce = bo, pale = false }
end
local G1 = grey("#b4b4b4", "#cdcdcd", "#e8e8e8", "#f2f2f2", "#8a8a8a", "#626262", "#9a9a9a") -- outer ring
local G2 = grey("#c4c4c4", "#dadada", "#ececec", "#f4f4f4", "#969696", "#6c6c6c", "#a6a6a6") -- middle ring
local G3 = grey("#d2d2d2", "#e4e4e4", "#f0f0f0", "#f6f6f6", "#a2a2a2", "#767676", "#b2b2b2") -- inner tuft

local function P(x, y) return x - 0.5, y - 0.5 end -- svg coords -> pixel centres
local hl = { {24,22}, {40,26}, {30,38}, {38,14}, {17,30} } -- svg highlight dots
local function glossFor(sx, sy, r)
  for _, h in ipairs(hl) do
    if (h[1]-sx)^2 + (h[2]-sy)^2 < (r*0.8)^2 then return { h[1]-0.5, h[2]-0.5 } end
  end
  return false
end

local outer = { {32,13},{41.5,15.55},{48.45,22.5},{51,32},{48.45,41.5},{41.5,48.45},
                {32,51},{22.5,48.45},{15.55,41.5},{13,32},{15.55,22.5},{22.5,15.55} }
local mid   = { {34.08,20.18},{41.83,25.12},{43.82,34.08},{38.88,41.83},{29.92,43.82},
                {22.17,38.88},{20.18,29.92},{25.12,22.17} }
local inner = { {28.92,27.44},{35.39,27.67},{37.17,33.88},{31.81,37.5},{26.71,33.52} }

-- back to front: bottom balls of each ring first so the lit top balls sit in front
local function byY(t) table.sort(t, function(a, b) return a[2] > b[2] end) return t end
local petals = {}
local function ring(list, r, ramp, cres)
  for _, p in ipairs(byY(list)) do
    local x, y = P(p[1], p[2])
    local part = c:part(c:ellipse(x, y, r), ramp, { cres = cres, gloss = glossFor(p[1], p[2], r) })
    petals[#petals+1] = part
  end
end
ring(outer, 7.5, G1, 4)
ring(mid,   7,   G2, 4)
ring(inner, 6,   G3, 3)

-- fixed centre: a sewn gold button core (stitched-toy signature), cross-stitched to the tuft
local core = c:part(c:ellipse(31.5, 31.5, 3.5), "gold", { cres = 3, gloss = false, rim = true })
c:px(30, 30, GV.C.hole); c:px(33, 33, GV.C.hole)
c:px(33, 30, GV.C.hole); c:px(30, 33, GV.C.hole)
c:px(31, 31, GV.C.goldS); c:px(32, 32, GV.C.goldS); c:px(32, 31, GV.C.goldS); c:px(31, 32, GV.C.goldS)
c:px(29, 29, "#fff1c8")

-- gold thread spokes from the button into the tuft (2 on / 1 off) - kept in the fixed layer
for _, s in ipairs({ {{31,27},{31,25}}, {{36,31},{38,31}}, {{32,36},{32,38}}, {{27,32},{25,32}} }) do
  c:seam(s)
end

-- full head
local t = c:save(O .. "aseprite/pom.aseprite", O .. "png/pom.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0)

-- split: fixed warm (gold family + button holes) -> centre; everything else (greys + umber outline) -> petals
local FIXED = {}
for _, k in ipairs({ "gold", "goldS", "hole" }) do FIXED[GV.C[k]] = true end
for _, v in pairs(GV.R.gold) do if type(v) == "string" then FIXED[v] = true end end
local img = c:image()
local pc = app.pixelColor
local W, H = img.width, img.height
local pet = Image(W, H, ColorMode.RGB); pet:clear(pc.rgba(0,0,0,0))
local cen = Image(W, H, ColorMode.RGB); cen:clear(pc.rgba(0,0,0,0))
for y = 0, H-1 do for x = 0, W-1 do
  local v = img:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    local hex = string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
    if FIXED[hex] then cen:putPixel(x, y, v) else pet:putPixel(x, y, v) end
  end
end end
local function savePng(im, path)
  local s = Sprite(W, H, ColorMode.RGB); s.cels[1].image = im; s:saveCopyAs(path); s:close()
end
savePng(pet, O .. "png/pom-petals.png")
savePng(cen, O .. "png/pom-centre.png")

-- layered .aseprite: petals (tint) under centre (fixed)
local s = Sprite(W, H, ColorMode.RGB)
s.layers[1].name = "petals"; s.cels[1].image = pet
local lc = s:newLayer(); lc.name = "centre"; s:newCel(lc, 1, cen, Point(0, 0))
s:saveAs(O .. "aseprite/pom.aseprite"); s:close()
print("split ok")
