-- ph/lingonberry-jam (Pantry jam): fluted jar (vertical ribs, notched foot) of red jam under a birch-bark cap tied with twine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "lingonberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local RIBS = { 23, 29, 35, 41 }
local glass = c:rrect(17, 24, 47, 54, 6)
for _, x in ipairs(RIBS) do glass:del(x, 54) end      -- fluted foot
local bark = c:rrect(16, 13, 48, 26, 3)
bark:del(16, 26):del(48, 26):del(47, 13):del(46, 13):add(c:rect(44, 11, 47, 12))   -- ragged hem, peeling curl
local p = c:build{
  { "glass", glass, "glass" },
  { "jam",   c:rrect(19, 28, 45, 52, 5), "#c8302b", { contour = "#8a2030", gloss = { 21, 30 } } },
  { "label", c:rect(22, 37, 42, 47), "cream", { gloss = false, contact = false } },
  { "bark",  bark, "#e8e0cc", { gloss = false } },
}
for _, x in ipairs(RIBS) do                            -- flutes: a lit rib line through glass and jam (not on the label)
  for y = 25, 53 do
    if not (y >= 37 and y <= 47) and c:get(x, y) and c:get(x, y) ~= "#2a1a10" then
      c:px(x, y, (y < 28 or y > 52) and "#eef8f2" or "#e8604a")
    end
  end
end
-- birch: dark lenticel ticks and a peeling curl
for _, t in ipairs({ {19, 16, 4}, {29, 19, 3}, {37, 15, 4}, {23, 22, 3}, {40, 21, 4}, {33, 24, 2} }) do
  c:fill(c:rect(t[1], t[2], t[1] + t[3] - 1, t[2]), "#3d2a1c")
end
c:px(45, 11, "#c9a96e"); c:px(46, 12, "#9a6b3f")
-- twine round the neck, knot and tails on the right
c:fill(c:rect(17, 26, 47, 26), "#c9a96e")
c:paint({ "kk", "kb", "b.b", "b..b" }, 42, 26, { k = "#9a6b3f", b = "#c9a96e" })
-- label: sprig of three round berries and two leaves
c:paint({
  "....ll.ll",
  "...l.ll..",
  "..l......",
  ".rrr.rr..",
  "rprrrprr.",
  "rrsrprrs.",
  ".s.rrrs..",
  "....ss...",
}, 25, 38, { r = "#c8302b", p = "#ff9158", s = "#a8241f", l = "#2f5a2a" })
c:paint({ "uuu", "", "uu" }, 36, 41, { u = "#9a6b3f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
