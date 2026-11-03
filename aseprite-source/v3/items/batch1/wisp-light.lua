-- wisp-light (pass B, final; Opus). Slim hanging glass lantern: small brass bail ring, onion-dome cap with an
-- engraved band and two vents over a wide lip, egg-shaped globe (narrower at the top), two thin brass cage bars,
-- turned foot + drop finial. The wisp inside is the light source: the glass is lit from within (glow falloff),
-- darkens toward its edges (fresnel), keeps a bright curved window streak upper-left and a cool bounce lower-right;
-- AO where the cap lip and foot meet the glass. History: wisp-light.pA (pass A), Sonnet draft overwritten.
-- quirk: one tiny spark has slipped out through the cap vent and drifts up beside the ring.
local NAME = "wisp-light"
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, P, K = H.HP, H.X, H.P, H.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

local BRASS = { "#4e2c22", "#7f4a26", "#ad702c", "#d89a3a", "#f1c45e", "#fff0a8" }
local GLOW  = { "#1c2650", "#233f72", "#2b6597", "#3d93b6", "#6cc8c8", "#b4efdc" }
local WISP  = { "#8edfd2", "#c4f7e6", "#effff4", "#fff8e2" }
local CX = 31.5

-- ring (torus; the hole is filled by the outline) + short neck
local ring = c:ellipse(CX, 6.5, 3.5, 3):cut(c:ellipse(CX, 6.5, 1.5, 1))
X.tone(c, ring, X.light(X.sphere(CX, 6.5, 3.5, ring), { amb = 0.15, wrap = 0.2 }), BRASS)
c:px(31, 9, BRASS[4]) c:px(32, 9, BRASS[3]) c:px(31, 10, BRASS[3]) c:px(32, 10, BRASS[2])

-- onion-dome cap + knob + wide lip
local knob = c:ellipse(CX, 11.5, 1.5, 1)
local dome = c:ellipse(CX, 17, 6.5, 5):clip(c:rect(0, 0, 63, 17))
local lip = c:rect(24, 18, 39, 19)
local capm = dome:copy():add(knob)
H.lit(c, capm, BRASS, { R = 3, amb = 0.12 })
c:px(31, 11, BRASS[6])
for x = 26, 37 do if dome:has(x, 15) then c:px(x, 15, (x % 2 == 0) and BRASS[2] or BRASS[3]) end end   -- engraved band
c:px(28, 14, BRASS[1]) c:px(29, 14, BRASS[1]) c:px(34, 14, BRASS[1]) c:px(35, 14, BRASS[1])         -- vents
c:px(28, 13, BRASS[2]) c:px(34, 13, BRASS[2])
for x = 24, 39 do
  c:px(x, 18, x < 34 and BRASS[5] or BRASS[4])                                 -- lip top catches the light
  c:px(x, 19, x < 27 and BRASS[3] or BRASS[2])                                 -- lip underside
end
c:px(25, 18, BRASS[6]) c:px(26, 18, BRASS[6])

-- globe: egg, narrower toward the cap
local GY, GR = 33.5, 13.5
local glass = HP.mask()
for y = 20, 46 do
  local q = 1 - ((y - GY) / (GR + 0.5)) ^ 2
  if q > 0 then
    local hw = 10.2 * sqrt(q) * (y < GY and (0.8 + 0.2 * (y - 20) / (GY - 20)) or 1)
    for x = math.ceil(CX - hw - 0.3), floor(CX + hw + 0.3) do glass:set(x, y) end
  end
end
local WX, WY = 31.5, 37
local d = X.dist(glass)
local v = {}
glass:each(function(x, y)
  local r = sqrt((x - WX) ^ 2 + ((y - WY) * 0.8) ^ 2)
  local g = max(0, 1 - r / 12) ^ 1.25
  local e = min(1, (d[K(x, y)] + 0.5) / 3.5)
  v[K(x, y)] = g * 0.85 + e * 0.22 - ((x - CX) + (y - GY)) * 0.007
end)
local gbias = {}
glass:each(function(x, y) if y <= 20 or y >= 45 then gbias[K(x, y)] = -1 end end)   -- AO under lip / over foot
X.tone(c, glass, v, GLOW, { cuts = { 0.16, 0.3, 0.45, 0.6, 0.76 }, bias = gbias })
glass:edge():each(function(x, y)
  local a = (x - CX) + (y - GY) * 0.8
  if a < -8 and y > 21 then c:px(x, y, GLOW[5]) elseif a > 9 then c:px(x, y, GLOW[1]) end
end)
-- curved window streak (upper left) + small cool bounce (lower right)
for _, p in ipairs{ {26, 23}, {25, 24}, {24, 25}, {24, 26}, {23, 27}, {23, 28}, {23, 29} } do c:px(p[1], p[2], "#f2fff8") end
c:px(24, 31, GLOW[6]) c:px(24, 32, GLOW[6])
c:px(39, 39, GLOW[4]) c:px(38, 41, GLOW[4]) c:px(39, 40, GLOW[4])

-- wisp: flame drop, tip curling back to the left; lit from its own core, cooler rim lower right
local wm = c:ellipse(WX, WY + 2, 4.5, 3.5)
local tail = H.sweep({ {31.5, 38}, {28.5, 33}, {34, 30}, {30.5, 25} }, function(t) return 3.4 * (1 - t) ^ 0.75 + 0.35 end, 80)
wm:add(tail)
local wd = X.dist(wm)
local wv = {}
wm:each(function(x, y) wv[K(x, y)] = min(1, (wd[K(x, y)] + 0.5) / 3) - (x - WX) * 0.035 - (y - WY) * 0.02 end)
X.tone(c, wm, wv, WISP, { cuts = { 0.3, 0.55, 0.8 } })
wm:edge():each(function(x, y) if (x - WX) + (y - WY) > 3 then c:px(x, y, GLOW[5]) end end)
c:px(29, 38, P.ink) c:px(29, 39, P.ink) c:px(33, 38, P.ink) c:px(33, 39, P.ink)   -- eyes
c:px(28, 40, "#f5a0b8") c:px(34, 40, "#f5a0b8")                                     -- blush

-- cage bars (meridians): lit bar on the left, shaded bar on the right, pinned to lip and foot
for _, sx in ipairs{ -0.6, 0.6 } do
  for y = 20, 45 do
    local q = 1 - ((y - GY) / (GR + 0.5)) ^ 2
    local hw = 10.2 * sqrt(max(q, 0)) * (y < GY and (0.8 + 0.2 * (y - 20) / (GY - 20)) or 1)
    local x = floor(CX + sx * hw + 0.5)
    if glass:has(x, y) and not wm:has(x, y) then
      c:px(x, y, sx < 0 and (y < 30 and BRASS[5] or BRASS[4]) or (y < 30 and BRASS[3] or BRASS[2]))
    end
  end
end

-- turned foot + drop finial
local foot = c:rrect(26, 46, 37, 48, 1)
H.lit(c, foot, BRASS, { R = 1.5, amb = 0.12 })
for x = 26, 37 do c:px(x, 46, x < 30 and BRASS[4] or BRASS[3]) end
c:px(27, 47, BRASS[6]) c:px(28, 47, BRASS[5])
local drop = c:ellipse(CX, 51, 2, 2):add(c:rect(31, 53, 32, 53))
H.lit(c, drop, BRASS, { R = 2 })
c:px(31, 49, BRASS[1]) c:px(32, 49, BRASS[1])                                         -- AO under the foot
c:px(30, 50, BRASS[6]) c:px(31, 54, BRASS[3])

-- quirk: escaped spark (cream core, mint arms) with one trailing mote
c:px(45, 7, WISP[4]) c:px(44, 7, WISP[1]) c:px(46, 7, WISP[1]) c:px(45, 6, WISP[1]) c:px(45, 8, WISP[1])
c:px(41, 11, GLOW[5])

-- place: whole drawing 1 px down (5 px top margin)
for y = 62, 0, -1 do for x = 0, 63 do c.pix[(y + 1) * 64 + x], c.own[(y + 1) * 64 + x] = c.pix[y * 64 + x], c.own[y * 64 + x] end end
for x = 0, 63 do c.pix[x], c.own[x] = nil, nil end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = H.out .. NAME .. ".aseprite", png = H.out .. NAME .. ".png", scale = 1 }
