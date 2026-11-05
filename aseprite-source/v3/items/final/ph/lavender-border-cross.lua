-- lavender-border-cross (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="lavender-border-cross" }
local WOOD = { "#2a1a1c", "#503024", "#7a4c30", "#a06c40", "#c8924e", "#e6b878" }
local SOIL = { "#2a1818", "#46281e", "#64402c", "#845840" }
local LAV = { "#3a2468", "#5a3a96", "#7c58bc", "#a07ee0", "#c4a8f4", "#e6d8ff" }
local GRN = { "#2a4a3a", "#3e6a4c", "#5c8c60", "#86b07c" }
local function cross(dy)
  local m = HP.mask()
  m:add(c:rect(24, 12 + dy, 39, 51 + dy)):add(c:rect(8, 27 + dy, 55, 38 + dy))
  return m
end
c:groundShadow(32, 54, 24, 3)
local side, top = cross(5), cross(0)
shade(c, side, 4, WOOD, { cuts = {0.1,0.2,0.3,0.55,0.8} })
side:each(function(x, y) if (x + floor(y/2)) % 6 == 0 then c:px(x, y, WOOD[2]) end end)
c:fillMask(top, WOOD[4])
local rim = top:copy():shrink(2)
c:fillMask(top, WOOD[5])
top:each(function(x, y) if not rim:has(x, y) then c:px(x, y, (x + y) % 8 < 2 and WOOD[4] or WOOD[5]) end end)
c:fillMask(top:copy():shrink(1):cut(rim), WOOD[3])
shade(c, rim, 8, SOIL)
-- lavender clumps: grey-green mound + violet spikes
local function clump(x, y)
  shade(c, c:ellipse(x, y + 2, 4, 3), 4, GRN)
  for i = -2, 2 do
    local h = 5 + ((i * i + x) % 3)
    c:line({{x + i, y + 1},{x + i + (i > 0 and 1 or (i < 0 and -1 or 0)), y - h}}, 1):each(function(px, py) c:px(px, py, GRN[2]) end)
    for j = 0, 3 do local py = y - h - 1 + j c:px(x + i + (i>0 and 1 or (i<0 and -1 or 0)), py, j < 2 and LAV[4] or LAV[3]) end
    c:px(x + i + (i>0 and 1 or (i<0 and -1 or 0)), y - h - 1, LAV[6])
  end
end
for _, p in ipairs{ {32,20},{32,31},{32,43},{15,33},{26,33},{38,33},{49,33} } do clump(p[1], p[2]) end
-- quirk: bumblebee
c:fillMask(c:ellipse(46, 21, 2, 1), "#f2c230") c:px(45, 21, "#2b1c26") c:px(47, 21, "#2b1c26") c:px(45, 19, "#e6f4ff") c:px(46, 19, "#e6f4ff")
G.save(c, "lavender-border-cross")
