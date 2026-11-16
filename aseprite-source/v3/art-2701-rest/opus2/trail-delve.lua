-- trail-delve (32x32 trail map marker, Opus second pass). Landmark kind "delve": a once-a-day five-room loot run
-- that ends in a chest; the way down. A round shaft seen in 3/4: a ring of sandstone blocks (lit top, shaded side,
-- dark joints), the far earth wall inside fading into deep violet dark, a wooden ladder standing up out of it (tall
-- open-rung silhouette that says "climb down"), and gold glints of treasure far below.
-- quirk: a gnome's red pointy hat has been left on the rim; someone is already down there.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-delve")
local atan, floor, pi = math.atan, math.floor, math.pi

local SA = { "#4a3440", "#6e5254", "#93746a", "#b89a82", "#d8bea0", "#f0dcbc" } -- sandstone deep..hi
local cx = 15.5

-- rim: a side band (darker) under a top ring (lit), cut into blocks
local side = c:ellipse(cx, 23.5, 13.5, 6.5)
local top = c:ellipse(cx, 21.5, 13.5, 6.5)
local hole = c:ellipse(cx + 0.5, 21.5, 9.5, 4.5)
local function joint(x, y, cyy, n)
  local th = atan((y - cyy) * 2, x - cx)
  local u = (th / (2 * pi)) * n
  return math.abs(u - floor(u + 0.5)) < 0.06
end
local function sidePx(x, y)
  local h = SA[3]
  if not side:has(x, y + 1) then h = SA[1] elseif x > 22 then h = SA[2] end
  if joint(x, y, 23.5, 14) then h = SA[1] end
  return h
end
local function topPx(x, y)
  local h = SA[5]
  if x > 21 or (y > 24 and x > 17) then h = SA[4] end
  if not top:has(x - 1, y) or not top:has(x, y - 1) then h = SA[6] end
  if joint(x, y, 21.5, 14) then h = SA[3] end
  return h
end
side:each(function(x, y) if not top:has(x, y) then c:put(x, y, sidePx(x, y)) end end)
top:each(function(x, y) c:put(x, y, topPx(x, y)) end)
-- inner lip: a darker row where the ring turns down into the shaft
hole:grow(1):each(function(x, y) if top:has(x, y) and not hole:has(x, y) and y <= 21 then c:put(x, y, SA[3]) end end)

-- shaft: far wall (earth, lit at the top) fading to dark; gold glints far below
local SH = { "#a0683e", "#7e4c33", "#5a3430", "#3a2434", "#2a1c34", "#22172c" }
hole:each(function(x, y) c:put(x, y, SH[math.min(6, y - 17 + 1)]) end)
T.pt(c, { { 21, 24 }, { 22, 25 }, { 20, 25 }, { 9, 24 } }, "#d98322")
c:put(21, 25, "#ffe38a")

-- ladder standing straight up out of the shaft: 2 px rails, open rungs
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
for _, y in ipairs{ 5, 10, 15, 20, 25 } do
  for x = 14, 17 do c:put(x, y, y > 17 and (y > 21 and "#2a1c34" or "#5a3430") or "#c48a56") end
end
for _, y in ipairs{ 5, 10, 15 } do
  c:put(14, y, "#e8b982")
  for x = 14, 17 do c:put(x, y + 1, "#864c33") end -- rung underside
end
c:put(12, 3, "#e8b982") c:put(18, 3, "#e8b982")
-- the front rim overlaps the ladder foot
side:each(function(x, y) if x >= 12 and x <= 19 and not hole:has(x, y) then c:put(x, y, top:has(x, y) and topPx(x, y) or sidePx(x, y)) end end)

-- quirk: a gnome's red hat left on the rim
T.art(c, 10, {
  ".rr.............................",
  "..rr............................",
  "...rr...........................",
  "...Rrd..........................",
  "...RRrd.........................",
  "..RRRrd.........................",
  "..RRrrrd........................",
  ".RRrrrrd........................",
  ".ccccccce.......................",
  "..eeeeee........................",
}, { R = "#ff8a5c", r = "#e8493b", d = "#9e2a3c", c = "#efe0c0", e = "#c9b48e" })

T.done(c)
