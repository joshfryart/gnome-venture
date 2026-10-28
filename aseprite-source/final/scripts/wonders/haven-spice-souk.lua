-- haven-spice-souk.lua : "Spice Souk. A covered market; mint tea and rest. Rare spice seeds." MENA, covered bazaar, warm light.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local NF = { gloss = false, rim = false, bounce = false, outline = false }
local function nf(t) local o = {}; for k, v in pairs(NF) do o[k] = v end; for k, v in pairs(t or {}) do o[k] = v end; return o end

-- back wall: sandstone with three arched openings onto the blue sky
c:bands(c:rect(0, 0, W - 1, H - 1), { "#e0b878", "#d8ac6c", "#d0a060" }, { dir = "v" })
c:part(c:rect(0, 6, W - 1, 100), GV.ramp("#d9b27a"), nf{ cres = 2, deep = 3 })
local function arch(cx, hw, top, bot)
  local m = c:rrect(cx - hw, top, cx + hw, top + hw * 2, hw); m:add(c:rect(cx - hw, top + hw, cx + hw, bot))
  return m
end
local arches = { 40, 120, 200 }
for _, ax in ipairs(arches) do
  local m = arch(ax, 22, 20, 96)
  c:part(m, GV.ramp("#8fc4e2"), nf{ cres = 2, deep = 3 , contour = "#6a4a2a"})
  c:fill(m:copy():clip(c:rect(0, 74, W, 96)), "#e8d8a8")        -- far sunlit dunes/roofs
  c:fill(m:copy():clip(c:rect(0, 20, W, 40)), "#7fb8dc")
  -- arch rim stone
end
-- distant city in the middle arch: dome and minaret
c:part(c:ellipse(120, 78, 9, 8), GV.ramp("#f2e4c0"), nf{ cres = 3, deep = 5 })
c:part(c:rect(131, 52, 135, 96), GV.ramp("#f2e4c0"), nf{ cres = 2, deep = 3 }); c:part(c:poly({ {130,52},{133,44},{136,52} }), GV.ramp("#2f9f8a"), nf{ flat = true })
c:part(c:rect(104, 80, 110, 96), GV.ramp("#e8d0a0"), nf{ cres = 2, deep = 3 })
-- left arch: a palm; right arch: rooftops
c:part(c:rect(38, 62, 41, 96), GV.ramp("#7a4a1f"), nf{ flat = true })
for _, l in ipairs({ { {39,62},{28,56},{22,62} }, { {39,62},{50,56},{56,62} }, { {39,62},{36,50},{30,48} }, { {39,62},{44,50},{50,48} } }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#3f9a4a" })
  c:part(c:line(l, 3), GV.ramp("#5aa84a"), nf{ flat = true })
end
c:part(c:rect(186, 76, 206, 96), GV.ramp("#f2e4c0"), nf{ cres = 2, deep = 4 }); c:part(c:rect(204, 68, 220, 96), GV.ramp("#e8d0a0"), nf{ cres = 2, deep = 4 })
c:fill(c:rect(192, 82, 195, 87), "#2a5a8a"); c:fill(c:rect(209, 74, 212, 80), "#2a5a8a")
-- pillars between and over the arches (the stone, with rim)
for _, px in ipairs({ 0, 78, 162, 236 }) do
  c:part(c:rect(px - 6, 6, px + 6, 112), GV.ramp("#e0bf88"), { cres = 4, deep = 6, gloss = false })
end
-- awnings: striped cloth, bunting at the top
local colors = { "#d6322b", "#f2e4c0", "#2f9f8a", "#e8a317" }
for i = 0, 19 do
  local x = i * 12
  c:part(c:poly({ {x, 8}, {x + 12, 8}, {x + 12, 20}, {x + 6, 26}, {x, 20} }), GV.ramp(colors[(i % 4) + 1]), { cres = 3, deep = 5, gloss = false, outline = false })
end
-- hanging brass lanterns
for _, l in ipairs({ { 62, 30 }, { 100, 34 }, { 142, 34 }, { 180, 30 } }) do
  c:fill(c:rect(l[1], 26, l[1], l[2] - 1), "#2a1a10")
  c:part(c:rrect(l[1] - 3, l[2], l[1] + 3, l[2] + 10, 2), GV.ramp("#e8a317"), { cres = 2, deep = 4, gloss = false })
  c:fill(c:rect(l[1] - 1, l[2] + 3, l[1] + 1, l[2] + 8), "#fff1c8")
end
-- floor: patterned tiles/rug
c:part(c:rect(0, 104, W - 1, H - 1), GV.ramp("#b8643a"), { cres = 3, deep = 5, gloss = false, rim = false, bounce = false, outline = false })
for i = 0, 11 do
  local x = i * 22 + 4
  c:fill(c:poly({ {x + 8, 113}, {x + 14, 119}, {x + 8, 125}, {x + 2, 119} }), (i % 2 == 0) and "#e8a317" or "#2f9f8a")
end

-- the counter (centre) with the keeper behind
c:part(c:rect(70, 94, 170, 128), GV.ramp("#8a5a2e"), { cres = 4, deep = 8, gloss = false })
c:fill(c:rect(70, 94, 170, 95), "#c9915a")
for x = 80, 160, 20 do c:fill(c:rect(x, 100, x, 126), "#6a4420") end
-- keeper gnome (behind the counter)
local kx, ky = 120, 80
c:part(c:ellipse(kx, ky + 8, 11, 10), GV.ramp("#2f9f8a"), { cres = 4, deep = 6, gloss = false })
c:part(c:ellipse(kx, ky - 4, 8, 8), GV.ramp("#f0c8a0"), { cres = 3, deep = 5 })
c:part(c:ellipse(kx, ky + 3, 8, 5):cut(c:ellipse(kx, ky - 3, 8, 6)), GV.ramp("#f2e4c0"), { cres = 3, deep = 4, gloss = false })   -- beard
c:eye(kx - 6, ky - 7, true); c:eye(kx + 1, ky - 7, true)
c:part(c:poly({ {kx - 6, ky - 9}, {kx - 4, ky - 18}, {kx + 4, ky - 18}, {kx + 6, ky - 9} }), GV.ramp("#d6322b"), { cres = 3, deep = 5, gloss = false })  -- fez
c:fill(c:rect(kx - 1, ky - 18, kx, ky - 15), "#e8a317"); c:seam({ {kx - 4, ky - 12}, {kx + 4, ky - 12} }, { free = true })
-- spice sacks in front, open with cones of colour (the focal subject)
local spices = { { 86, "#d6322b" }, { 104, "#e8a317" }, { 136, "#7a3a1f" }, { 154, "#6aa04a" } }
for _, s in ipairs(spices) do
  local x = s[1]
  c:part(c:rrect(x - 9, 108, x + 9, 128, 3), GV.ramp("#d8c496"), { cres = 4, deep = 6, gloss = false })
  c:part(c:poly({ {x - 8, 108}, {x, 97}, {x + 8, 108} }), GV.ramp(s[2]), { cres = 3, deep = 5 })
  c:seam({ {x - 6, 116}, {x + 6, 116} }, { free = true, on = 2, off = 1, gap = "#a88a5a" })
end
-- tea tray, centre: brass pot + glasses with mint
c:part(c:ellipse(120, 105, 12, 3), GV.ramp("#e8a317"), { cres = 2, deep = 3, gloss = false })
c:part(c:rrect(113, 92, 123, 103, 3), GV.ramp("#d9a830"), { cres = 3, deep = 4 })
c:part(c:poly({ {123, 96}, {131, 92}, {127, 100}, {123, 101} }), GV.ramp("#d9a830"), { flat = true, gloss = false })
c:part(c:rect(115, 90, 121, 92), GV.ramp("#e8a317"), { flat = true, gloss = false }); c:px(118, 89, "#fff1c8")
for _, gx in ipairs({ 108, 130 }) do
  c:part(c:rect(gx, 98, gx + 3, 104), GV.ramp("#a8d8c0"), { flat = true, gloss = false })
  c:px(gx, 97, "#6aa04a"); c:px(gx + 2, 96, "#8fd070"); c:px(gx + 3, 97, "#6aa04a")
end
-- hanging strings of chillies and a rug on the right pillar
for _, hx in ipairs({ 196, 206, 216 }) do
  c:fill(c:rect(hx, 38, hx, 42), "#2a1a10")
  for k = 0, 3 do c:part(c:ellipse(hx, 45 + k * 5, 2.5, 3), GV.ramp(k % 2 == 0 and "#d6322b" or "#e0501f"), { flat = true, gloss = false, outline = false }) end
end
-- baskets of seeds at the sides (rare seeds: little glinting packets)
for _, b in ipairs({ { 28, 120 }, { 212, 120 } }) do
  c:part(c:ellipse(b[1], b[2], 14, 8), GV.ramp("#c9915a"), { cres = 4, deep = 6, gloss = false })
  c:part(c:ellipse(b[1], b[2] - 6, 12, 4), GV.ramp("#e8a317"), { flat = true, gloss = false })
  c:seam({ {b[1] - 10, b[2] + 1}, {b[1] + 10, b[2] + 1} }, { free = true, on = 2, off = 1 })
  c:px(b[1] - 3, b[2] - 7, "#fff1c8"); c:px(b[1] + 4, b[2] - 6, "#fff1c8")
end
c:ground(120, 128, 60, 2)
L.finish(c, "haven-spice-souk")
