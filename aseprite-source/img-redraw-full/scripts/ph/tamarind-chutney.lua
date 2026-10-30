-- ph/tamarind-chutney (Pantry chutney): round terracotta matka pot, flared rim, dark drip, tilted saucer lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "tamarind-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local clay = GV.ramp("#b0603a", { shade = "#7a3a1f" })
c:build{
  { "neck", c:rect(22, 19, 42, 29), clay, { gloss = false } },
  { "pot",  c:ellipse(32, 41, 20, 14), clay, { gloss = { 17, 34 } } },
  { "lip",  c:rrect(19, 16, 45, 21, 2), clay, { gloss = false } },
}
c:fill(c:rect(22, 17, 42, 17), "#3d2a1c")                -- dark chutney seen in the mouth
-- carved band lines
c:fill(c:line({ {15, 33}, {22, 30}, {42, 30}, {49, 33} }, 1), "#8a4428")
c:part(c:ellipse(30, 42, 10, 6), "cream", { gloss = false, contact = false })
-- emblem: curved tamarind pod with three bumps
c:paint({
  ".bb.bb.bb..",
  "bBbbbbbbbb.",
  "bbbbbbbbbbs",
  ".sss.sss.ss",
}, 25, 40, { b = "#7a4a1f", B = "#b08050", s = "#4a2a1c" })
-- drip (redraw A): a wide glossy lobe spilling over the front of the lip, two runs of different length down the neck and shoulder, round beads.
-- It sits on the face of the pot, never past its edge, so it cannot read as a post.
local drip = c:ellipse(29, 18, 8, 3)                                -- overflowing pool on the lip
drip:add(c:ellipse(24.5, 22, 2, 2.5)):add(c:ellipse(25, 25, 2.5, 2.5))     -- short tongue + bead
drip:add(c:ellipse(31, 23, 2, 3)):add(c:ellipse(31.5, 28, 1.5, 3)):add(c:ellipse(32, 31.5, 2.5, 2.5))   -- long tongue + bead
c:part(drip, GV.ramp("#5e2f1e", { rim = "#8a4a2a", shade = "#4a2216", deep = "#3d1a10", bounce = "#5e2f1e" }), { flat = true })
c:fill(c:rect(24, 17, 32, 17), "#a0603a"); c:px(23, 24, "#c08050"); c:px(30, 30, "#c08050"); c:px(30, 22, "#a0603a")
-- saucer lid (redraw A): a round clay saucer propped on the rim, seen from above: pale rim ring, dark well, a foot underneath
local function rot(cx, cy, rx, ry, deg)
  local m, a = c:mask(), math.rad(deg)
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x - cx, y - cy
    local u, v = dx * math.cos(a) + dy * math.sin(a), -dx * math.sin(a) + dy * math.cos(a)
    if (u / (rx + 0.4)) ^ 2 + (v / (ry + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local plate = rot(45, 14, 11, 5, -12)
c:part(plate:copy():shift(1, 2):cut(plate):add(c:rect(41, 19, 49, 20)), "#6a2e18", { flat = true })   -- thick edge and foot
c:part(plate, GV.ramp("#d88a5a", { shade = "#b0603a", deep = "#8a4428", bounce = "#c06a3a", rim = "#f0b080" }), { gloss = false })
c:fill(rot(45.5, 14.5, 7.5, 2.6, -12), "#5e2414")                -- the well
c:fill(rot(45.5, 15.5, 6, 1.4, -12), "#7a3a1f")
c:px(37, 13, "#f0b080"); c:px(38, 12, "#f0b080"); c:px(39, 11, "#f0b080")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
