-- camp.lua : "Campfire clearing" stop look, Maplewold style (480x270 gate view). Haiku first pass.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/haiku/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR }
local c, L, part, rect, px, rimOf, hline, vline = F.c, F.L, F.part, F.rect, F.px, F.rimOf, F.hline, F.vline

-- a canvas tent with a door slit
local function tent(x, yb, w, h, r)
  local m = c:poly{ { x - w // 2, yb }, { x, yb - h }, { x + w // 2, yb } }
  rimOf(m, r) part(m, r, { sep = true })
  vline(x, yb - h // 2, yb, r.deep)
  hline(x - w // 2, x + w // 2, yb, L.timber.deep)
end
tent(98, 186, 60, 40, L.awnB)
tent(392, 184, 56, 38, L.awnA)
tent(440, 206, 36, 22, L.accent)

-- log seats in a ring around the fire
for _, s in ipairs({ { 190, 214 }, { 290, 214 }, { 206, 186 }, { 276, 186 }, { 240, 226 } }) do
  local log = c:rrect(s[1] - 9, s[2], s[1] + 9, s[2] + 5, 2)
  rimOf(log, L.timber) part(log, L.timber, { nopop = true })
  hline(s[1] - 7, s[1] + 5, s[2] + 1, L.timber.hi)
end

-- the fire: two crossed logs, three flames and a hot core
local logA = c:line({ { 218, 210 }, { 262, 206 } }, 3)
local logB = c:line({ { 220, 206 }, { 260, 212 } }, 3)
rimOf(logA:copy():add(logB), L.timber)
part(logA, L.timber, { nopop = true }) part(logB, L.timber, { nopop = true, noshade = true })
local flames = {
  { { 226, 206 }, { 232, 178 }, { 240, 206 } },
  { { 236, 206 }, { 242, 170 }, { 250, 206 } },
  { { 246, 206 }, { 254, 182 }, { 258, 206 } },
}
for _, f in ipairs(flames) do
  local m = c:poly(f)
  rimOf(m, L.foliage) part(m, L.foliage, { nopop = true })
  local inner = c:poly{ { f[1][1] + 2, 206 }, { f[2][1], f[2][2] + 8 }, { f[3][1] - 2, 206 } }
  c:fillMask(inner, L.glow.base)
  px(f[2][1], f[2][2] + 9, L.glow.hi)
end
-- sparks drifting up
for _, p in ipairs({ { 230, 168 }, { 252, 160 }, { 244, 150 } }) do px(p[1], p[2], L.glow.hi) end

-- a kettle on a tripod to one side
local kettle = c:ellipse(302, 204, 6, 5)
rimOf(kettle, L.stone) part(kettle, L.stone, { nopop = true })
part(c:line({ { 296, 200 }, { 302, 186 }, { 308, 200 } }, 1), L.timber, { nopop = true, noshade = true })

-- a woodpile by the far tree
for k = 0, 2 do
  local pile = rect(378 + k * 6, 214 - k * 3, 402, 218 - k * 3)
  rimOf(pile, L.timber) part(pile, L.timber, { sep = true })
end

-- a bench of boards, and trees
F.tree(40, 146, 30, 14)
F.tree(452, 136, 30, 15)
F.tree(176, 118, 20, 16, true)
F.sign(120, 150, 26, 12)

F.finish()
