-- npc-babka_wren.lua : Cat Fish pet shop keeper bust, Babka Wren of Birch Hut Pets (Birchbramble Steppe, EE).
-- Matches the existing villager busts (game/assets/img/ph/npc-*.png, e.g. npc-wren-thimblewick.lua): 80x100,
-- gvlib "bust" mode (1 px umber outline +1 lower right, 1 px #000000 border, none on the bottom edge), a felt
-- disc behind the head, locked eyes. Babka (grandmother) Wren is a little brown wren-bird grandma: a red folk
-- headscarf with cream flower dots tied under the chin (gold hem stitch round the face), round gold spectacles,
-- a cocked barred wren tail, a cream shawl with a red diamond embroidery border, and a blue felt fish cat toy
-- held up in her wing. Friendly smile, no blush. Light from the upper left.
-- Run: AppRun -b --script npc-babka_wren.lua   Writes ../out/npc-babka_wren.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("(.*)/") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local brown = GV.ramp("#a5663a")
local dkbrown = GV.ramp("#8c4a1a")
local cream = GV.ramp("#f8eed2")
local scarfR = GV.R.red
local fishB = GV.R.water
local UMB = "#2a1a10"

-- shapes -----------------------------------------------------------------------------------------------------------
local disc = c:ellipse(40, 50, 36)
-- cocked wren tail behind the right shoulder
local tail = c:poly({ { 55, 48 }, { 63, 24 }, { 68, 19 }, { 75, 21 }, { 76, 28 }, { 70, 44 }, { 63, 56 } })
-- body (brown feathers) and cream shawl over the shoulders
local body = c:ellipse(39.5, 99, 33, 22):clip(c:rect(0, 76, 79, 99))
local shawl = c:ellipse(39.5, 101, 34, 23):clip(c:rect(0, 78, 79, 99))
shawl:cut(c:poly({ { 31, 78 }, { 49, 78 }, { 40, 99 } }))
-- head and face
local head = c:ellipse(40, 52, 22, 21)
local patch = c:ellipse(40, 64, 13, 8):clip(head)
-- headscarf: dome over the head falling past the cheeks, a face opening, knot under the chin
local scarf = c:ellipse(40, 46, 27, 25):add(c:poly({ { 13, 50 }, { 22, 76 }, { 30, 74 }, { 40, 79 }, { 50, 74 }, { 58, 76 }, { 67, 50 } }))
local face = c:ellipse(40, 57, 17, 17)
scarf:cut(face)
local knot = c:ellipse(40, 77, 4, 3)
local tails = c:poly({ { 37, 78 }, { 31, 90 }, { 36, 91 }, { 40, 80 } }):add(c:poly({ { 41, 79 }, { 44, 92 }, { 49, 90 }, { 43, 78 } }))
-- felt fish toy held up in her right wing (viewer's right)
local fish = c:ellipse(59, 81, 10, 6)
local ftail = c:poly({ { 66, 81 }, { 77, 73 }, { 75, 81 }, { 77, 90 } })
local fin = c:poly({ { 54, 75 }, { 60, 71 }, { 63, 76 } })
local wing = c:ellipse(53, 89, 6, 5)

local p = c:build{
  { "disc", disc, GV.ramp("#8fcbd8", { shade = "#6fa8c4", deep = "#5a86b8", bounce = "#6fa8c4", rim = "#c8ecdc", gloss = "#c8ecdc" }), { solid = false, gloss = false } },
  { "tail", tail, dkbrown, { gloss = false } },
  { "body", body, brown, { gloss = false } },
  { "shawl", shawl, cream, { gloss = false } },
  { "tails", tails, scarfR, { gloss = false } },
  { "head", head, brown, { gloss = false } },
  { "patch", patch, cream, { gloss = false } },
  { "scarf", scarf, scarfR, { gloss = { 22, 30 } } },
  { "knot", knot, scarfR, { gloss = false } },
  { "ftail", ftail, fishB, { gloss = false } },
  { "fin", fin, fishB, { flat = true } },
  { "fish", fish, fishB, { gloss = { 53, 78 }, stitch = { side = "lit" } } },
  { "wing", wing, dkbrown, { gloss = false } },
}

-- wren tail barring
for i = 0, 3 do
  local y = 25 + i * 6
  for dx = 0, 4 do local x = 67 - i * 2 + dx; if p.tail.m:has(x, y + (dx >= 3 and 1 or 0)) and c:get(x, y) ~= nil then c:px(x, y + (dx >= 3 and 1 or 0), dkbrown.deep) end end
end
-- fish toy details: cream eye with umber pupil, gold seam where the tail is sewn on, red felt mouth
c:fill(c:rect(51, 79, 53, 81), "#f2e4c0"); c:fill(c:rect(52, 80, 53, 81), UMB)
c:seam({ { 66, 77 }, { 66, 86 } }, { on = 2, off = 1 })
c:px(49, 82, "#dd3a2a"); c:px(49, 83, "#dd3a2a")
-- headscarf: cream five-dot flowers with a gold heart, and a gold hem stitch round the face opening
local flowers = { { 22, 32 }, { 33, 25 }, { 47, 25 }, { 58, 33 }, { 40, 30 }, { 19, 45 }, { 61, 46 }, { 22, 62 }, { 58, 62 }, { 28, 38 }, { 52, 38 } }
for _, f in ipairs(flowers) do
  local x, y = f[1], f[2]
  if p.scarf.m:has(x, y) and p.scarf.m:has(x - 1, y) and p.scarf.m:has(x + 1, y) and p.scarf.m:has(x, y + 1) and p.scarf.m:has(x, y - 1) then
    c:px(x - 1, y, "#f8eed2"); c:px(x + 1, y, "#f8eed2"); c:px(x, y - 1, "#f8eed2"); c:px(x, y + 1, "#f8eed2"); c:px(x, y, "#f5cf6a")
  end
end
-- seam along the top arc of the face opening (left half then right half, upper points only)
local arc = {}
for a = 200, 340, 4 do local r = math.rad(a); arc[#arc + 1] = { 40 + 19 * math.cos(r), 57 + 19 * math.sin(r) } end
c:seam(arc)
-- knot pleats
c:px(39, 76, scarfR.shade); c:px(41, 78, scarfR.shade)

-- shawl: red diamond embroidery band along its front edges, plus a dress showing in the V
for i = 0, 5 do
  local t = i / 5
  local xl = math.floor(31 - 14 * t + 0.5) - 3; local yl = math.floor(81 + 12 * t + 0.5)
  local xr = math.floor(49 + 14 * t + 0.5) + 3; local yr = yl
  for _, q in ipairs({ { xl, yl }, { xr, yr } }) do
    local x, y = q[1], q[2]
    if p.shawl.m:has(x, y) then
      c:px(x, y - 1, "#dd3a2a"); c:px(x - 1, y, "#dd3a2a"); c:px(x + 1, y, "#dd3a2a"); c:px(x, y + 1, "#dd3a2a"); c:px(x, y, "#f5cf6a")
    end
  end
end
c:seam({ { 9, 92 }, { 20, 85 }, { 31, 81 } }, {})
c:seam({ { 49, 81 }, { 60, 85 }, { 71, 92 } }, {})
c:button(38, 93)

-- face: eyes, round gold spectacles, wren beak, smile
local EL, ER, EY = 28, 47, 50
c:eye(EL, EY); c:eye(ER, EY)
local function specs(x, y)
  local m = c:ellipse(x + 2, y + 2, 4, 4):cut(c:ellipse(x + 2, y + 2, 3, 3))
  m:each(function(px, py) if c:get(px, py) ~= "#f2e4c0" then c:px(px, py, (px - x + py - y > 5) and "#b8661a" or "#f5cf6a") end end)
end
specs(EL, EY); specs(ER, EY)
c:fill(c:rect(35, 51, 36, 51), "#f5cf6a"); c:fill(c:rect(44, 51, 45, 51), "#f5cf6a")
-- small pointed wren beak, gold, set between and below the eyes
c:paint({
  "...d...",
  "..ggd..",
  ".gggod.",
  "ggggoos",
  ".ggoos.",
  "..oos..",
  "...s...",
}, 37, 54, { g = "#f5cf6a", d = "#fff1c8", o = "#e8a317", s = "#b8661a" })
-- warm smile on the cream patch
c:paint({ "u.....u", ".u...u.", "..uuu.." }, 37, 63, { u = "#4a2c1a" })

local t = c:save(OUT .. "npc-babka_wren.aseprite", OUT .. "npc-babka_wren.png")
print("npc-babka_wren " .. GV.report(t))
