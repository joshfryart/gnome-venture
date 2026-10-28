-- variety-tier-spring.lua : stoptiers/spring-1..4 (96x96). Drawn on a 48 grid, written at 2x nearest (out=2).
-- 1 stone steps and rail, 2 changing house, 3 egg-boiling stones, 4 bathhouse hall.
-- Family: water pool + stone + wood + pale steam puffs. Shapes kept inside grid 5..41 (border room).
-- Run: AppRun -b --script-param out=<dir> --script variety-tier-spring.lua   (script-param goes BEFORE --script)
local ROOT = "/home/user/gnome-venture/"
local GV = dofile(ROOT .. "aseprite-source/gvlib/gvlib.lua")
local OUT = app.params.out or (ROOT .. "aseprite-source/extras-pixel/png/")
local ASE = ROOT .. "aseprite-source/extras-pixel/aseprite/"
local lwood = GV.ramp("#c98f50")
local dark  = GV.ramp("#3d2a1c")
local egg = GV.ramp("#f1ece0")
local steam = GV.ramp("#e4f2f0", { gloss = "#f4fffa", dot = "#ffffff", rim = "#f0fcf8", shade = "#b8d4d8", deep = "#8fb4c4", bounce = "#c8e0e4", pale = false })

local function puff(c, x, y, r)
  c:part(c:ellipse(x, y, r, r), steam, { gloss = false, contact = false, solid = false })
end

local T = {}

T[1] = function(c)
  -- side-view steps climbing to the right, a gold rail along them, a pool at the foot
  c:part(c:rect(18, 33, 41, 41), "stone")
  c:part(c:rect(24, 27, 41, 41), "stone")
  c:part(c:rect(30, 21, 41, 41), "stone")
  c:part(c:rect(36, 15, 41, 41), "stone")
  c:part(c:rrect(5, 32, 21, 41, 4), "water")
  for _, p in ipairs({ {19, 27}, {25, 21}, {31, 15}, {37, 9} }) do
    c:part(c:rect(p[1], p[2], p[1] + 2, p[2] + 6), "wood", { flat = true })
  end
  c:part(c:line({ {20, 27}, {38, 9} }, 2), "gold", { flat = true })
  puff(c, 10, 25, 3)
  puff(c, 14, 18, 2)
end

T[2] = function(c)
  c:part(c:rrect(6, 35, 41, 41, 3), "water")
  c:part(c:rect(10, 19, 38, 36), "wood")
  c:part(c:rect(18, 24, 30, 36), dark)
  c:part(c:rect(18, 24, 23, 36), "petal")
  c:part(c:rect(25, 24, 30, 36), "petal")
  c:seam({ {18, 25}, {30, 25} }, { free = true })
  c:part(c:poly({ {6, 20}, {24, 8}, {42, 20} }), "water")
  c:seam({ {8, 19}, {40, 19} }, { free = true })
  c:part(c:rect(33, 26, 37, 33), "cream", { flat = true })
  c:button(22, 14)
end

T[3] = function(c)
  local cx, cy = 24, 29
  local stones = {}
  for i = 0, 9 do
    local a = i * 2 * math.pi / 10
    stones[#stones + 1] = { cx + 14 * math.cos(a), cy + 8 * math.sin(a) }
  end
  table.sort(stones, function(p, q) return p[2] < q[2] end)
  local function stone(p) c:part(c:ellipse(math.floor(p[1] + 0.5), math.floor(p[2] + 0.5), 3, 3), "stone") end
  for i = 1, 5 do stone(stones[i]) end
  c:part(c:ellipse(cx, cy, 12, 6), "water")
  c:part(c:ellipse(18, 29, 3, 3), egg, { flat = true })
  c:part(c:ellipse(24, 27, 3, 3), egg, { flat = true })
  c:part(c:ellipse(30, 30, 3, 3), egg, { flat = true })
  for i = 6, 10 do stone(stones[i]) end
  puff(c, 20, 15, 3)
  puff(c, 27, 10, 3)
  puff(c, 20, 8, 2)
end

T[4] = function(c)
  c:part(c:rect(5, 36, 41, 40), "stone")
  c:part(c:rect(30, 10, 35, 18), "stone")
  puff(c, 33, 8, 2)
  c:part(c:rect(8, 22, 38, 37), "wood")
  c:part(c:poly({ {5, 23}, {11, 14}, {35, 14}, {41, 23} }), "water")
  c:seam({ {7, 22}, {39, 22} }, { free = true })
  c:part(c:rrect(19, 25, 29, 38, 4), "gold")
  c:part(c:rrect(21, 28, 27, 38, 2), "water")
  c:part(c:ellipse(13, 29, 3, 3), steam, { flat = true })
  c:part(c:ellipse(35, 29, 3, 3), steam, { flat = true })
end

local k = tonumber(app.params.tier)
for _, i in ipairs(k and { k } or { 1, 2, 3, 4 }) do
  local c = GV.canvas{ w = 48, h = 48, mode = "icon", out = 2 }
  T[i](c)
  local t = c:save(ASE .. "variety-tier-spring-" .. i .. ".aseprite", OUT .. "spring-" .. i .. ".png")
  print("spring-" .. i .. " " .. GV.report(t))
end
