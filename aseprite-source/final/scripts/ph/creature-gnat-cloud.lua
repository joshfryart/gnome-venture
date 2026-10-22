local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- body centres (loose irregular ring + one in the middle); s = size tweak, f = wing flip
local G = {
  {19,23,0, 1}, {33,17,0,-1}, {46,25,0, 1}, {48,40,-1,-1},
  {36,48,0, 1}, {22,47,-1,-1}, {13,36,0, 1}, {31,33,0,-1},
}
local wings, bodies = c:mask(), c:mask()
for _, g in ipairs(G) do
  local x, y, s, f = g[1], g[2], g[3], g[4]
  -- two-lobe wing pair, slightly tilted per gnat
  wings:add(c:ellipse(x - 2.5, y - 4 + (f > 0 and 0 or 1), 2.5, 2))
  wings:add(c:ellipse(x + 2.5, y - 4 + (f > 0 and 1 or 0), 2.5, 2))
  bodies:add(c:ellipse(x, y, 2.5 + s * 0.5, 2 + s * 0.0))
end
c:build{
  { "wings", wings, "#e6f1ec", { flat = true } },
  { "bodies", bodies, "#6e5444", { gloss = false, cres = 2, deep = 1 } },
}
for _, g in ipairs(G) do
  local x, y = g[1], g[2]
  c:paint({ "ee", "ee" }, x - 2, y, { e = "#2a1a10" })
  c:px(x - 2, y, "#fff3c8")
end
local t = c:save(D .. "img-redraw-full/aseprite/ph/creature-gnat-cloud.aseprite",
                 D .. "img-redraw-full/png/ph/creature-gnat-cloud.png")
print(GV.report(t))
