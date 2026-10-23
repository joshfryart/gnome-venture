-- Great White Owl (boss, tundra lair "Den of the Great White Owl"): a round-headed snowy owl
-- mantling, both wings raised high and spread like a cape, gripping a frost rock with dark talons.
-- No ear tufts, no crown (unlike the snow-owl monarch). Fierce gold-ringed eyes under angled brows,
-- dark flecked barring, and a faint aurora (mint green / violet bands) stitched along the wing edges.
-- Families: soil palest #f1ece0 (pale cream plumage, cream-safe gloss), gold (eye rings),
-- dusk (beak), stone (rock, flecks); aurora: water gloss #c8ecdc (mint) and a pale dusk lavender #c3b2ea.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-na-4-lair-den-of-the-great-white-owl"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- feather: tilted ellipse from base (bx,by) to tip (tx,ty), half-width w; also returns the
-- aurora bands across its tip (mint from G, violet from V of its length)
local GB, VB = 0.70, 0.85
local function feather(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local cx, cy = (bx + tx) / 2, (by + ty) / 2
  local f, g, v = c:mask(), c:mask(), c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x - cx, y - cy
    local u = px * ux + py * uy
    local q = -px * uy + py * ux
    if (u * u) / ((L / 2) ^ 2) + (q * q) / (w * w) <= 1 then
      f:set(x, y)
      local t = (u + L / 2) / L
      if t >= VB then v:set(x, y) elseif t >= GB then g:set(x, y) end
    end
  end end
  return f, g, v, { bx + dx * GB, by + dy * GB }, { bx + dx * 0.5, by + dy * 0.5 }
end

-- raised wings spread like a cape: five primaries fanning from behind each shoulder
local tips = { { 9, 46 }, { 7, 36 }, { 7, 26 }, { 9, 16 }, { 15, 8 } }   -- bottom to top
local F = { 21, 38 }
local wingParts, seamL, seamR, mids = {}, {}, {}, {}
for i, tp in ipairs(tips) do
  for side = 1, 2 do
    local bx, tx = F[1], tp[1]
    if side == 2 then bx, tx = 63 - bx, 63 - tx end
    local f, g, v, sp, mid = feather(bx, F[2], tx, tp[2], 2.9)
    if i == 4 then mids[#mids + 1] = mid end
    wingParts[#wingParts + 1] = { "f" .. i .. side, f, g, v }
    if side == 1 then seamL[#seamL + 1] = sp else seamR[#seamR + 1] = sp end
  end
end

-- wing coverts: the arm of each wing, laid over the feather roots
local covL = feather(23, 43, 12, 19, 4.6)
local covR = feather(40, 43, 51, 19, 4.6)

local rock = c:poly({ { 13, 57 }, { 16, 51 }, { 24, 49 }, { 33, 50 }, { 41, 48 }, { 49, 51 }, { 52, 57 } })
local body = c:ellipse(31.5, 40, 12, 11)
local footL = c:rrect(22, 47, 28, 52, 2)
local footR = c:rrect(35, 47, 41, 52, 2)
local head = c:ellipse(31.5, 22, 13, 11)
local ringL = c:ellipse(24, 23, 4.5, 4.5)
local ringR = c:ellipse(39, 23, 4.5, 4.5)
local beak = c:poly({ { 29, 26 }, { 35, 26 }, { 33, 32 }, { 31, 32 } })

local cream  = GV.ramp("#f1ece0", { dot = "#fff3c8" })
local wingC  = GV.ramp("#e8e0cc", { dot = "#fff3c8" })
local mint   = GV.ramp("#c8ecdc")
local violet = GV.ramp("#c3b2ea")
local stone  = GV.ramp("#5b6470")

c:part(rock, stone)
for _, w in ipairs(wingParts) do
  c:part(w[2], wingC)
  c:part(w[3], mint,   { light = w[2], contour = false, gloss = false, contact = false, rim = false })
  c:part(w[4], violet, { light = w[2], contour = false, gloss = false, contact = false, rim = false })
end
local p = c:build{
  { "covL", covL, wingC, { gloss = false } },
  { "covR", covR, wingC, { gloss = false } },
  { "body",  body, cream, { stitch = { side = "lit" } } },
  { "footL", footL, cream, { gloss = false } },
  { "footR", footR, cream, { gloss = false } },
  { "head",  head, cream },
  { "ringL", ringL, "gold", { flat = true, gloss = false } },
  { "ringR", ringR, "gold", { flat = true, gloss = false } },
  { "beak",  beak, "dusk", { flat = true } },
}

-- dark bean flecks (snowy owl barring), evenly varied
local fleck, glint = "#5b6470", "#8b8f96"
for _, f in ipairs({ { 15, 24 }, { 18, 31 }, { 48, 24 }, { 45, 31 } }) do
  local x, y = math.floor(f[1] + 0.5), math.floor(f[2] + 0.5)
  c:spot(c:rect(x - 1, y, x, y + 1), fleck, glint)
end
for _, f in ipairs({ { 27, 40 }, { 35, 40 }, { 31, 45 } }) do
  c:paint({ "b.b", ".b." }, f[1], f[2], { b = fleck })
end

-- stitched aurora join: seam along the mint band where it meets the cream feathers
local function pts(t) local o = {} for i, p in ipairs(t) do o[i] = { math.floor(p[1] + 0.5), math.floor(p[2] + 0.5) } end return o end
c:seam(pts(seamL)); c:seam(pts(seamR))

-- fierce brows
c:paint({ "bbb.....", ".bbbbb..", "....bbbb" }, 19, 16, { b = "#4a2c1a" })
c:paint({ ".....bbb", "..bbbbb.", "bbbb...." }, 36, 16, { b = "#4a2c1a" })

-- eyes
c:eye(22, 21); c:eye(37, 21)

-- talons
for _, x in ipairs({ 22, 25, 28, 35, 38, 41 }) do c:paint({ "t", "t" }, x, 52, { t = "#2a1a10" }) end

local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
