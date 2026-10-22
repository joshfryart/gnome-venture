local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(15, 22, 48, 54, 7)
local neck = c:rrect(23, 16, 40, 24, 2)
local p = c:build{
  { "body", body, GV.ramp("#c8ecdc"), { gloss = { 19, 27 } } },
  { "neck", neck, GV.ramp("#c8ecdc"), { gloss = false } },
  { "seeds", c:rrect(18, 42, 45, 52, 5), "dusk", { gloss = false } },
  { "cork", c:rrect(22, 7, 41, 17, 2), "wood" },
  { "label", c:rrect(22, 27, 41, 41, 2), GV.ramp("#f1ece0"), { gloss = false } },
}
-- seed beads in the jar (below the label)
for _, s in ipairs({ {20, 47}, {26, 49}, {37, 49}, {43, 46} }) do
  c:paint({ "sss", "sSs" }, s[1] - 1, s[2] - 1, { s = "#3e2f66", S = "#291d4a" })
end
-- glass glints on the right wall
c:px(44, 30, "#eefaf4"); c:px(44, 31, "#eefaf4")
-- five-petal blossom
local cx, cy, r = 31.5, 34.5, 4.3
for i = 0, 4 do
  local a = math.rad(-90 + i * 72)
  c:part(c:ellipse(cx + r * math.cos(a), cy + r * math.sin(a), 2.9, 2.9), GV.ramp("#e46a9b", { rim = "#f6b8cf" }), { flat = true, contact = false })
end
c:fill(c:rect(31, 33, 32, 34), "#f5cf6a")
c:px(31, 33, "#fff1c8")
c:seam({ {22, 17}, {41, 17} })
local t = c:save(O .. "aseprite/ph/plum-blossom-seed.aseprite", O .. "png/ph/plum-blossom-seed.png")
print(GV.report(t))
