-- Grand Condor Plume (pl-cnd-6), yard sprite 64x64. Opus richness pass (c10/opus3), built on c10/opus2.
-- Richness pass: a violet-teal oil sheen along the shaft on the upper vane (condor black is iridescent), crisper
-- barbs with lit barb ridges, three wider frayed gaps in the trailing edge, grey-tipped barbs on the white patch,
-- a dark sheath line on the quill below the gold band, rim light and cool bounce kept.
-- closer look: a tiny curl of grey down riding the updraft swirl beside it.
-- Thornblade, rare. "The biggest feather the Grand Condor ever dropped, and it still floats."
-- A great condor flight feather lying on the air, quill low-left, tip high-right: slate-black vane with a narrow
-- leading edge and a broad trailing edge, the condor's white patch on its lower third, fine barbs, a pale ivory
-- shaft and a sharp quill nib (thornblade). The face sits on the broad dark vane (cream eyes read strongly
-- there). Rare: a gold band on the quill and two sparkles.
-- Haiku pass fixed: it read as a brown corn husk, ran off the top-left edge, and its wind dashes were cut off.
-- quirk: it still floats. A curling updraft (two pale wind swirls) holds it up from underneath.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-6-yard", 64)

local CND  = { "#1a1622", "#29243a", "#3a344e", "#524a68", "#71688c", "#9a92b4" }
local WHT  = { "#5a5874", "#8a88a4", "#bab9cc", "#dddde6", "#f2f0ee" }
local QUIL = { "#7a6e60", "#b0a48c", "#d8ceb2", "#f2ead0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local WIND = { "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local SHEEN = { "#4a3f78", "#6a5aa8", "#2f5a6e", "#4a8494" }

local SH = { { 12, 52 }, { 22, 38 }, { 37, 22 }, { 54, 6 } }
local vane, vn, VT, VS = O.tube(SH, function(t)
  if t < .06 then return 0 end
  return 12 * math.sin(math.pi * math.min(1, (t - .04) * 1.04)) ^ .5
end)
-- narrow leading edge (upper-left side), broad trailing edge
local lead = HP.mask()
vane:each(function(x, y) if (VS[K(x, y)] or 0) < -.38 then lead:set(x, y) end end)
vane:cut(lead)
-- frayed gaps in the trailing edge
local gap = HP.mask()
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, VS[K(x, y)] or 0
  for _, g in ipairs({ .4, .62, .8 }) do if s > .45 and math.abs(t - g - (s - .5) * .07) < .016 then gap:set(x, y) end end
end)
vane:cut(gap)
local WHITE_T = .34
local vb = {}
vane:each(function(x, y) if (VT[K(x, y)] or 0) < WHITE_T + (H(x, y, 2) - .5) * .05 then vb[K(x, y)] = 1 end end)
local fI, fT = O.shade(c, vane, CND, { R = 5, amb = .25, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 3 })
for k, i in pairs(fI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == fT then
    local t, s = VT[K(x, y)] or 0, VS[K(x, y)] or 0
    local face = t > .44 and t < .68 and s > -.3
    local ii = i
    local ph = math.floor(t * 80 + math.abs(s) * 8) % 3
    if not face and math.abs(s) > .12 and ph == 0 then ii = i - 1 end -- barbs
    if not face and math.abs(s) > .2 and ph == 1 and i >= 3 and H(x, y, 21) > .55 then ii = i + 1 end -- lit barb ridge
    if vb[K(x, y)] then
      if s > .7 and H(x, y, 23) > .5 then ii = ii - 1 end -- grey barb tips on the white
      c.pix[p] = WHT[math.max(1, math.min(5, ii))]:lower()
    else
      local col = CND[math.max(1, math.min(6, ii))]
      -- iridescent sheen along the shaft on the upper vane
      if not face and t > .7 and t < .95 and math.abs(s) < .42 and ii >= 3 then col = (s < 0) and SHEEN[ii >= 5 and 2 or 1] or SHEEN[ii >= 5 and 4 or 3] end
      c.pix[p] = col:lower()
    end
  end
end
-- shaft and quill
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 1)
  if s < .1 and not (t > .44 and t < .68) then O.mark(c, { { x, y } }, t < WHITE_T and QUIL[2] or QUIL[3]) end
end)
local quill = O.tube({ { 7, 59 }, { 9, 56 }, { 11, 53 }, { 14, 49 } }, function(t) return .6 + t * .8 end)
quill:cut(vane)
O.shade(c, quill, QUIL, { R = 1, amb = .35, wrap = .5, cuts = { .3, .55, .8 } })
O.dots(c, { { 11, 53 }, { 12, 52 }, { 12, 53 }, { 13, 51 } }, GOLD[3]) O.dots(c, { { 11, 52 } }, GOLD[4]) O.dots(c, { { 12, 54 }, { 13, 52 } }, GOLD[2])

-- face on the broad dark vane
c:eyeLocked(29, 26)
c:eyeLocked(38, 24)
c:cheek(28, 33) c:cheek(43, 30)
O.dots(c, { { 33, 32 }, { 34, 33 }, { 35, 33 }, { 36, 32 } }, P.cream)
O.dots(c, { { 34, 34 }, { 35, 34 } }, "#c94f84")

O.shift(c, -1, 0)
O.done(c, "pl-cnd-6-yard", function(c)
  -- the updraft: two curling wind swirls under the feather
  local function curl(pts, col) for _, p in ipairs(pts) do c:put(p[1], p[2], col) end end
  curl({ { 30, 57 }, { 31, 57 }, { 32, 57 }, { 33, 57 }, { 34, 56 }, { 35, 55 }, { 35, 54 }, { 34, 53 }, { 33, 53 }, { 32, 54 } }, WIND[2])
  curl({ { 18, 60 }, { 19, 60 }, { 20, 60 }, { 21, 60 }, { 22, 60 }, { 23, 60 }, { 24, 60 }, { 25, 60 }, { 26, 60 }, { 27, 59 }, { 28, 58 } }, WIND[1])
  curl({ { 40, 50 }, { 41, 50 }, { 42, 50 }, { 43, 50 }, { 44, 49 }, { 45, 48 }, { 45, 47 }, { 44, 46 }, { 43, 46 }, { 42, 47 } }, WIND[2])
  curl({ { 37, 51 }, { 38, 51 }, { 39, 51 } }, WIND[1])
  curl({ { 46, 53 }, { 47, 53 }, { 48, 53 }, { 49, 53 }, { 50, 52 }, { 51, 51 } }, WIND[1])
  curl({ { 31, 57 }, { 41, 50 } }, WIND[3])
  -- closer look: a curl of grey down riding the swirl
  local fl = { { 38, 54, "#e4e0e8" }, { 39, 54, "#b8b4c4" }, { 37, 55, "#b8b4c4" }, { 38, 55, "#b8b4c4" }, { 39, 55, "#8e8aa0" }, { 40, 55, "#b8b4c4" }, { 41, 54, "#8e8aa0" } }
  local on = {} for _, f in ipairs(fl) do on[f[1] .. "," .. f[2]] = true end
  for _, f in ipairs(fl) do for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
    local x, y = f[1] + d[1], f[2] + d[2]
    if not on[x .. "," .. y] and not c:get(x, y) then c:put(x, y, P.ink) end
  end end
  for _, f in ipairs(fl) do c:put(f[1], f[2], f[3]) end
  c:sparkle(8, 34)
  c:sparkle(57, 22)
end)
