-- bellcap-shell: the hollow bell-shaped shell dropped by the Bellcap Beetle.
-- Same slate shell, dark ribs, pale lip line and gold crown bead as creature-bellcap-beetle,
-- shown empty and tipped over so the dark mouth of the bell faces the viewer.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local (upright) frame: bell axis along -y, origin at the mouth centre; tilt it so the
-- crown leans up-left and the mouth opens toward the lower right
local CX, CY, A = 34, 40, math.rad(-20)
local ca, sa = math.cos(A), math.sin(A)
local function R(test) -- mask of canvas pixels whose local coords pass test(lx, ly)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - CX, y - CY
    local lx, ly = dx * ca + dy * sa, -dx * sa + dy * ca
    if test(lx, ly) then m:set(x, y) end
  end end
  return m
end
local function L2C(lx, ly) -- local point to canvas pixel
  return math.floor(CX + lx * ca - ly * sa + 0.5), math.floor(CY + lx * sa + ly * ca + 0.5)
end

-- bell body: dome cap + flaring waist down to the mouth
local bell = R(function(x, y)
  if y < -19 and (x*x)/(12.5*12.5) + ((y+19)^2)/(10*10) <= 1 then return true end
  if y >= -19.5 and y <= 0 then
    local hw = 12.5 + 8.3 * ((y + 19.5) / 19.5)^2.5  -- flared bell profile
    return math.abs(x) <= hw
  end
  return false
end)
-- thick lip ring around the mouth (seen a little from below: an ellipse band)
local lipE = R(function(x, y) return (x*x)/(21*21) + (y*y)/(8.5*8.5) <= 1 end)
local farHalf = R(function(x, y) return y < -1.5 end)
local lip = lipE:copy():cut(farHalf)        -- near half of the lip: its own part
bell:add(lipE:copy():clip(farHalf))         -- far half belongs to the body (no brim contour)
-- dark hollow inside the mouth
local mouth = R(function(x, y) return (x*x)/(14.5*14.5) + ((y+1.2)^2)/(4.2*4.2) <= 1 end)
-- crown bead
local bead = R(function(x, y) return x*x + (y+31.5)^2 <= 3.6*3.6 end)

bell = bell:shrink(1):grow(1); lip = lip:shrink(1):grow(1)  -- open: drop rotation nubs
local whole = bell:copy():add(lip)
local p = c:build{
  { "bead", bead, "#e8a317" },
  { "bell", bell, "#4a5160", { light = whole, gloss = { 22, 16 } } },
  { "lip",  lip,  "#6e7685", { light = whole, gloss = false } },
}
-- hollow: deep dusk interior with a lit inner rim on the far (upper) edge of the mouth
c:fill(mouth, "#1e1438")
mouth:each(function(x, y) if not mouth:has(x, y - 1) or not mouth:has(x - 1, y - 1) then c:px(x, y, "#3e2f66") end end)

-- ribs, as on the creature: centre rib and two side ribs following the flare
local rib = c:mask()
local function ribline(pts) local q = {} for i, v in ipairs(pts) do q[i] = { L2C(v[1], v[2]) } end rib:add(c:line(q, 2)) end
ribline({ {0, -27}, {0, -4} })
ribline({ {-8, -25}, {-10, -14}, {-13, -4} })
ribline({ {8, -25}, {10, -14}, {13, -4} })
rib:clip(p.bell.m:shrink(1))
c:fill(rib, "#2f3440")
-- pale band line around the waist, like the creature's lip line
local band = c:mask()
local b0x, b0y = L2C(-15, -7); local b1x, b1y = L2C(15, -7)
band:add(c:line({ { b0x, b0y }, { b1x, b1y } }, 1)):clip(p.bell.m:shrink(1)):cut(rib)
c:fill(band, "#a9afba")

-- seam along the lip join, button at its head
local pts = {}
for i = 0, 16 do
  local t = math.pi - i * math.pi / 16          -- along the near (lower) half of the lip
  pts[#pts+1] = { L2C(17.5 * math.cos(t), 5.6 * math.sin(t)) }
end
c:seam(pts)
local bx, by = L2C(-17.5, 1.5)
c:button(bx - 1, by - 2)

local t = c:save(D .. "final/aseprite/ph/bellcap-shell.aseprite", PNG .. "bellcap-shell.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
