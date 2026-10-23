-- borer-plate: one curved back plate shed by the Basalt Borer (mole-cricket).
-- Same brown body ramp, dark 2 px segment bands and lavender back sheen as creature-basalt-borer.
-- Drawn as a long, arched roof-tile of armour seen from above the front edge: a domed top
-- crossed by segment bands, a darker underside lip along the bottom, grey basalt grit
-- pressed in from digging, and a seam down the spine where it was sewn to the body.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local frame: plate centre at origin, long axis along x, tilted to rise to the right
local CX, CY, A = 32, 33, math.rad(-22)
local ca, sa = math.cos(A), math.sin(A)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
local function R(test)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do local lx, ly = loc(x, y) if test(lx, ly) then m:set(x, y) end end end
  return m
end
local function L2C(lx, ly) return math.floor(CX + lx * ca - ly * sa + 0.5), math.floor(CY + lx * sa + ly * ca + 0.5) end

local HL = 22                                            -- half length
local function topE(x) return -11 + 4 * (x / HL)^2 end   -- domed upper edge
local function botE(x) return 4 + 3.5 * (x / HL)^2 end   -- arched lower edge (rises in the middle)
local function inLen(x, y, pad) -- rounded ends: an ellipse cap on each end
  local ax = math.abs(x)
  if ax <= HL - 6 then return true end
  local u = (ax - (HL - 6)) / (6 + pad)
  return u <= 1 and math.abs(y - (topE(x) + botE(x)) / 2) <= ((botE(x) - topE(x)) / 2 + 1) * math.sqrt(1 - u*u)
end
local top = R(function(x, y) return y >= topE(x) and y <= botE(x) and inLen(x, y, 0) end)
local lip = R(function(x, y) return y > botE(x) and y <= botE(x) + 4 and inLen(x, y - 2, -0.5) end)
top = top:shrink(1):grow(1); lip = lip:shrink(1):grow(1)

local body = GV.ramp("#9a7447")
local p = c:build{
  { "lip", lip, GV.ramp("#6b4a2c"), { gloss = false } },
  { "top", top, body, { light = top:copy():add(lip), gloss = { 12, 26 } } },
}

-- segment bands across the plate, bowed with the dome, each with a lit shingle edge on its left
local inner = p.top.m:shrink(1)
for _, sx in ipairs({ -11, 0, 11 }) do
  local q = {}
  for ly = -12, 8, 2 do
    local bow = 1.2 * math.sin((ly + 12) / 20 * math.pi)   -- bands bulge forward over the dome
    q[#q+1] = { L2C(sx + bow, ly) }
  end
  local g = c:line(q, 2):clip(inner)
  c:fill(g, "#2a1a10")
  c:fill(g:shift(-1, 0):cut(g):clip(inner), body.rim)
end
-- the same bands carry on round the underside lip
for _, sx in ipairs({ -11, 0, 11 }) do
  local x0, y0 = L2C(sx, botE(sx) + 1); local x1, y1 = L2C(sx, botE(sx) + 4)
  c:fill(c:line({ { x0, y0 }, { x1, y1 } }, 2):clip(p.lip.m:shrink(1)), "#2a1a10")
end

-- lavender back sheen along the lit upper edge, as on the creature
for lx = -19, 4 do
  local x, y = L2C(lx, topE(lx) + 3)
  if inner:has(x, y) and c:get(x, y) ~= "#2a1a10" and c:get(x, y) ~= body.rim then c:px(x, y, "#8f7fc9") end
end

-- seam down the spine where it was sewn to the body, button at its head (left end)
local pts = {}
for lx = -16, 19 do pts[#pts+1] = { L2C(lx, (topE(lx) + botE(lx)) / 2 + 1) } end
c:seam(pts)
local bx, by = L2C(-19, (topE(-19) + botE(-19)) / 2 + 1)
c:button(bx - 2, by - 2)

-- basalt grit pressed into the felt: small stone-grey diamonds with a pale glint
local function grit(lx, ly)
  local x, y = L2C(lx, ly)
  c:spot(c:ascii({ ".s.", "sss", ".s." }, x - 1, y - 1), "#5b6470", "#8b8f96")
end
grit(-6, -5); grit(6, 3); grit(16, -4)

local t = c:save(D .. "final/aseprite/ph/borer-plate.aseprite", PNG .. "borer-plate.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
