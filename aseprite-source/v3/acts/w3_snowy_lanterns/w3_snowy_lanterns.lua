-- act-w3_snowy_lanterns (v3 Hearth Pop 2.5D): a gnome carries a paper lantern on a pole to light the stone lanterns
-- along a snowy path at dusk-grey daylight.
-- Motion: snow falls, the paper lantern swings a little, every flame flickers, the lit windows pulse.
-- quirk: a tiny snow-gnome sits on the near lantern's roof.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local G = A.gnome{ view = "front", hat = "#e8493b", tunic = "#5a6fd0", scarf = "#f5b82e" }
local SNOW, SNOW2, SNOW3 = "#f4fbff", "#dbe9f4", "#b9cfe4"
local FL = { "#ffe38a", "#f5b82e", "#fff4d6", "#ffe38a", "#f5b82e", "#ffe38a" }

local function bg(c)
  c:stripes(10, 48, { "#aebfd8", "#bccde2", "#cbd9ea", "#d8e4f0" })
  -- snowy peak on the right
  local mt = HP.poly{ { 78, 52 }, { 112, 18 }, { 146, 52 } }
  c:rim(mt, "#8ea6c4")
  mt:each(function(x, y)
    local col = (x < 112 - (y - 18) * .1) and "#f4fbff" or "#d0deec"
    if y > 32 + math.sin(x / 3) * 2 then col = (x < 104) and "#b7c8de" or "#a2b6d0" end
    c:put(x, y, col)
  end)
  c:terrain(function(x) return 46 + math.sin(x / 10) * 2 end, "#c9d9ea", 52)
  for y = 50, 99 do for x = 10, 137 do c:put(x, y, y < 53 and SNOW2 or SNOW) end end
  -- path (trodden, lavender-grey) from front to the back
  local path = HP.poly{ { 58, 52 }, { 70, 52 }, { 104, 100 }, { 36, 100 } }
  path:each(function(x, y) c:put(x, y, ((x + y * 3) % 11 == 0) and "#b9cfe4" or "#d0dcec") end)
  for i = 1, 20 do
    local x, y = 12 + floor(A.hash(i, 1, 3) * 122), 54 + floor(A.hash(i, 2, 3) * 44)
    if not path:has(x, y) then c:put(x, y, SNOW2) c:put(x + 1, y, SNOW2) end
  end
  A.pine(c, 20, 66, 46, { snow = true })
  A.pine(c, 38, 60, 30, { snow = true })
  A.pine(c, 128, 70, 38, { snow = true })
end

-- stone lantern (toro): (x, yb) base centre, s = scale 1 (far) or 2 (near)
local function toro(c, x, yb, s, f, idx)
  local function R(x0, y0, x1, y1) return HP.rect(x + x0 * s, yb + y0 * s, x + x1 * s + (s - 1), yb + y1 * s + (s - 1)) end
  local base = R(-3, -2, 3, 0)
  local post = R(-1, -8, 1, -3)
  local plat = R(-4, -10, 4, -9)
  local box = R(-3, -15, 3, -11)
  local roof = HP.poly{ { x - 6 * s, yb - 15 * s }, { x, yb - 19 * s }, { x + 6 * s + s - 1, yb - 15 * s } }
  local knob = R(0, -21, 0, -20)
  local all = base:copy():add(post):add(plat):add(box):add(roof):add(knob)
  c:rim(all, s == 1 and "#5a6f8c" or P.ink)
  local function stone(m) m:each(function(px, py) c:put(px, py, (px < x - s) and P.stone.hi or (px > x + s and P.stone.shade or P.stone.base)) end) end
  stone(base) stone(post) stone(plat) stone(box) stone(knob)
  roof:each(function(px, py) c:put(px, py, (py <= yb - 17 * s) and SNOW or (py == yb - 16 * s and SNOW2 or P.stone.shade)) end)
  -- snow on the platform
  for px = x - 4 * s, x + 4 * s + s - 1 do c:put(px, yb - 10 * s, SNOW) end
  -- lit window, flickers
  local w = R(-1, -14, 1, -12)
  local col = FL[((f + idx) % 6) + 1]
  w:each(function(px, py) c:put(px, py, col) end)
  c:put(x, yb - 13 * s, "#e8493b")
  if s > 1 then c:put(x, yb - 13 * s - 1, (f % 2 == 0) and "#fff4d6" or "#ffe38a") end
end

return A.run("w3_snowy_lanterns", function(f)
  local c = A.canvas("w3_snowy_lanterns")
  bg(c)
  toro(c, 50, 64, 1, f, 0)
  toro(c, 30, 74, 1, f, 3)
  toro(c, 114, 94, 2, f, 1)
  -- quirk: a tiny snow-gnome on the near lantern's roof
  local sg = HP.ellipse(119, 54, 2, 2):add(HP.ellipse(119, 51, 1.5, 1.5))
  c:rim(sg, "#8bc4ea")
  sg:each(function(x, y) c:put(x, y, SNOW) end)
  c:put(119, 48, "#e8493b") c:put(119, 49, "#e8493b") c:put(118, 49, "#e8493b") c:put(120, 49, "#e8493b")
  c:put(119, 51, P.ink)
  -- the gnome, feet at y 94
  A.stamp(c, G, 32, 23)
  -- pole from the right hand up to a swinging paper lantern
  local hx, hy = 79, 80
  local tip = { 97, 46 }
  local pole = c:line({ { hx, hy }, tip }, 1)
  pole:each(function(x, y) c:put(x, y, P.wood.shade) end)
  c:put(hx, hy, "#f0b98d") c:put(hx, hy - 1, "#f0b98d")
  local sw = ({ 0, 1, 1, 0, -1, -1 })[f + 1]
  local lx, ly = tip[1] + 3 + sw, tip[2] + 6
  for y = tip[2], ly - 4 do c:put(tip[1] + 3 + ((y > tip[2] + 1) and sw or 0), y, P.ink) end
  c:fillMask(HP.rect(tip[1], tip[2], tip[1] + 3, tip[2]), P.wood.shade)
  local lan = HP.ellipse(lx, ly, 3, 4)
  c:rim(lan, P.ink)
  lan:each(function(x, y)
    local col = FL[f + 1]
    if x > lx + 1 then col = "#d98322" end
    if (y - ly) % 3 == 0 then col = "#e8493b" end
    c:put(x, y, col)
  end)
  c:put(lx - 1, ly - 1, "#fff4d6")
  A.snow(c, f, { n = 14, seed = 9, col = SNOW, col2 = SNOW2 })
  return c
end)
