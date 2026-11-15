-- trail-delve (32x32 trail map marker, Opus richness pass 3). Landmark kind "delve": a once-a-day five-room loot run
-- that ends in a chest; the way down. A round shaft in 3/4: a ring of dressed sandstone blocks (each block lit on its
-- own upper-left corner, chipped here and there, a moss tuft in a joint), the far wall inside laid in courses and
-- fading into violet dark, warm gold bounce light coming up from a treasure chest at the bottom. A lashed wooden
-- ladder stands up out of it (grain, knot, rope lashings), the tall open-rung silhouette that says "climb down".
-- quirk: a gnome's red pointy hat has been left on the rim; someone is already down there. (opus3: crimson felt with
-- a cream fur trim and straight sides instead of the orange curl, so it no longer reads as a flame at 1x.)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-delve")
local atan, floor, pi, abs = math.atan, math.floor, math.pi, math.abs

local SA = { "#3e2c3c", "#5e4450", "#86665e", "#ad8c74", "#d2b494", "#ecd6b2", "#fbecca" } -- sandstone deep..hi (violet -> warm cream)
local MO = { "#2f5a3a", "#4f8a46", "#86b85a" }                                             -- moss
local cx = 15.5

local side = c:ellipse(cx, 23.5, 13.5, 6.5)
local top = c:ellipse(cx, 21.5, 13.5, 6.5)
local hole = c:ellipse(cx + 0.5, 21.5, 9.5, 4.5)
local NB = 14
local function ang(x, y, cyy) return atan((y - cyy) * 2, x - cx) end
local function blockU(x, y, cyy) return (ang(x, y, cyy) / (2 * pi)) * NB end
local function joint(x, y, cyy) local u = blockU(x, y, cyy) return abs(u - floor(u + 0.5)) < 0.06 end
local function afterJoint(x, y, cyy) -- first pixel past a joint going round (block's lit corner)
  local u = blockU(x, y, cyy) local f = u - floor(u) return f > 0.06 and f < 0.2
end
local function blockId(x, y, cyy) return floor(blockU(x, y, cyy) + 0.5) % NB end

-- outer side band (the drum of the well): darker, lower-right shade, courses, joints
local function sidePx(x, y)
  local h = SA[4]
  if x > 21 then h = SA[3] end
  if x > 26 then h = SA[2] end
  if not side:has(x, y + 1) then h = SA[1] end
  if y == 26 and h ~= SA[1] then h = (x > 21) and SA[2] or SA[3] end -- course line on the drum
  if joint(x, y, 23.5) then h = SA[1] end
  if x < 6 and not side:has(x - 1, y) and side:has(x, y + 1) then h = SA[5] end -- rim light on the lit flank
  return h
end
-- top face of the ring: per-block tone, lit corner after each joint, edge highlight on the outer upper-left
local function topPx(x, y)
  local b = blockId(x, y, 21.5)
  local base = (b % 3 == 1) and SA[5] or SA[6]
  local h = base
  if x > 21 or (y > 24 and x > 17) then h = (b % 3 == 1) and SA[4] or SA[5] end
  if afterJoint(x, y, 21.5) and h == base then h = SA[7] end
  if not top:has(x - 1, y) or not top:has(x, y - 1) then h = SA[7] end
  if (not top:has(x + 1, y) or not top:has(x, y + 1)) and x > 17 then h = SA[4] end
  if joint(x, y, 21.5) then h = SA[3] end
  return h
end
side:each(function(x, y) if not top:has(x, y) then c:put(x, y, sidePx(x, y)) end end)
top:each(function(x, y) c:put(x, y, topPx(x, y)) end)
-- inner lip where the ring turns down into the shaft
hole:grow(1):each(function(x, y) if top:has(x, y) and not hole:has(x, y) and y <= 21 then c:put(x, y, SA[3]) end end)

-- shaft: far wall in courses (lit right inner face, shaded left inner face), fading to dark
local SH = { "#b0784a", "#8a5638", "#643a32", "#432636", "#2c1c36", "#20162c" }
hole:each(function(x, y)
  local i = math.min(6, y - 17 + 1)
  if x <= 10 and i < 6 then i = i + 1 end                -- left inner face is in shadow (light from upper left)
  if (y == 19) and i < 6 then i = i + 1 end              -- course line on the far wall
  if (y == 18 and (x == 13 or x == 19)) or (y == 20 and (x == 16 or x == 22)) then i = math.min(6, i + 1) end -- joints
  c:put(x, y, SH[i])
end)
-- treasure chest far below: lid edge and gold bounce light on the shaft walls
T.art(c, 23, {
  "................................",
  "....................kgGk........",
  "....................dbbd........",
}, { k = "#6a3a2e", g = "#f5b82e", G = "#ffe38a", d = "#3a2434", b = "#8a5236" })
T.pt(c, { { 9, 24 }, { 23, 24 }, { 24, 23 } }, "#b8741e")  -- gold glint on the floor
T.pt(c, { { 22, 22 }, { 25, 23 } }, "#7a4a2a")              -- warm bounce on the shaft wall

-- ladder standing straight up out of the shaft: 2 px rails with grain, open rungs lashed with rope
local function railPx(x, y, lit)
  local d = y - 17
  local h
  if d < 0 then h = lit and "#d9a06a" or "#9a5e3a"
  elseif d < 3 then h = lit and "#864c33" or "#5a3430"
  else h = "#3a2434" end
  c:put(x, y, h)
end
for y = 3, 25 do
  railPx(12, y, true) railPx(13, y, false)
  railPx(18, y, true) railPx(19, y, false)
end
-- grain streaks and a knot on the rails (above the rim)
T.pt(c, { { 12, 8 }, { 12, 13 }, { 18, 7 }, { 18, 12 } }, "#b87a4c")
c:put(13, 12, "#6e3e2c") c:put(19, 8, "#6e3e2c")            -- knots on the shaded side
for _, y in ipairs{ 5, 10, 15, 20, 25 } do
  for x = 14, 17 do c:put(x, y, y > 17 and (y > 21 and "#2a1c34" or "#5a3430") or "#c48a56") end
end
for _, y in ipairs{ 5, 10, 15 } do
  c:put(14, y, "#eec08a")
  for x = 14, 17 do c:put(x, y + 1, "#864c33") end -- rung underside
  c:put(13, y, "#e6d2a4") c:put(19, y, "#a8926c")   -- rope lashing over the rails
end
c:put(12, 3, "#f0c890") c:put(13, 3, "#b87a4c") c:put(18, 3, "#f0c890") c:put(19, 3, "#b87a4c")
-- the front rim overlaps the ladder foot
side:each(function(x, y) if x >= 12 and x <= 19 and not hole:has(x, y) then c:put(x, y, top:has(x, y) and topPx(x, y) or sidePx(x, y)) end end)

-- chips in the ring and a moss tuft in the front joint
T.pt(c, { { 24, 25 }, { 6, 25 } }, SA[3])
T.pt(c, { { 21, 28 }, { 22, 28 } }, MO[1]) c:put(21, 27, MO[2]) c:put(22, 27, MO[3])

-- quirk: a gnome's hat left on the rim (crimson felt, cream trim, tip leaning over)
T.art(c, 9, {
  "..hd............................",
  "...Rd...........................",
  "...RRd..........................",
  "...RRrd.........................",
  "...RRrd.........................",
  "..RRRrrd........................",
  "..RRrrrd........................",
  "..RRrrrrd.......................",
  ".ccCcccccc......................",
  "..eeeeeee.......................",
}, { h = "#f28a92", R = "#e2505e", r = "#b42e44", d = "#701c34", c = "#f2e6c8", C = "#fff4d6", e = "#6e5254" })
c:put(3, 13, "#f28a92") -- felt sheen on the lit side

T.done(c)
