local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- TINTABLE (multiply): neutral greys only, dark neutral outline
G.neutral(true)
local beard = G.beard(c)
c:part(beard, G.N.beard, { gloss = { 29, 62 }, stitch = { side = "lit" } })
c:part(G.moustache(c), G.N.beard, { cres = 2, deep = 0, gloss = false })
-- hair strands (1 px felt grooves), darker in the shade
for _, s in ipairs({ { {33, 66}, {34, 72}, {36, 77} }, { {40, 62}, {40, 70}, {40, 79} }, { {47, 66}, {46, 72}, {44, 77} } }) do
  c:line(s, 1):each(function(x, y)
    local k = c:get(x, y)
    if beard:has(x, y) and k ~= G.N.beard.gloss then c:px(x, y, (k == G.N.beard.base or k == G.N.beard.rim) and G.N.strand or G.N.strandS) end
  end)
end
G.save(c, "gnome-beard")
