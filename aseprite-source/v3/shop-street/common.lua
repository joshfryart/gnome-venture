-- shop-street common: canvas, helpers, region looks. Passes get (c, L, X): c = HP canvas, L = layout table, X = this table.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local X = { HP = HP, SRC = SRC, W = 480, H = 300, HORIZON = 96 }
local floor, max, min = math.floor, math.max, math.min
function X.hash(x, y, s)
  x, y, s = floor(x), floor(y), floor(s or 0)
  local n = (x * 374761393 + y * 668265263 + s * 1013904223) & 0xffffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
function X.rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function X.hx(r, g, b) local function q(v) return floor(max(6, min(250, v)) + .5) end return string.format("#%02x%02x%02x", q(r), q(g), q(b)) end
function X.mix(a, b, t) local r1,g1,b1 = X.rgb(a) local r2,g2,b2 = X.rgb(b) return X.hx(r1+(r2-r1)*t, g1+(g2-g1)*t, b1+(b2-b1)*t) end
function X.R(r, i) return r[max(1, min(6, floor(i)))] end
function X.P(t) local o = {} for i, p in ipairs(t) do o[i] = { floor(p[1] + .5), floor(p[2] + .5) } end return o end
function X.poly(c, t) return c:poly(X.P(t)) end
function X.rect(c, x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
function X.tex(c, m, f) m:each(function(x, y) local col = f(x, y) if col then c:put(x, y, col) end end) end
function X.tint(c, x, y, col, t) local cur = c:get(x, y) if cur then c:put(x, y, X.mix(cur, col, t)) end end
-- ramps dark -> light (6 steps), shared with the Here scenes
X.RAMPS = {
  TIMB={"#2a1a22","#46282a","#643a30","#845236","#a46e44","#c48e5a"}, OAK={"#30202a","#4e3230","#70483a","#946244","#b88058","#d8a474"},
  CREAM={"#5e4658","#8e7476","#bca290","#dcc4a6","#eed9b8","#f8eacc"}, ROSE={"#4e2840","#7c4458","#aa6670","#cc8a88","#e6ae9e","#f6d0bc"},
  MUST={"#4a3020","#7a5228","#a87a32","#cc9e40","#e4bc5a","#f4d88a"}, GREEN={"#1c3434","#2a5240","#3a704a","#529054","#78b064","#a8d080"},
  SBLUE={"#20264a","#323e6a","#46598a","#6076a4","#7e94bc","#a8b8d4"}, BARN={"#38181e","#5c2428","#843230","#a6483a","#c66648","#e08c62"},
  SLATE={"#1e2240","#30385a","#464f76","#606c92","#8090ae","#a8b4cc"}, TEAL={"#14303a","#1e4a52","#2c686a","#408a84","#64aa9a","#94c8b2"},
  STONE={"#382e40","#5a4e5c","#7a6e76","#9a8e90","#b8aca6","#d6cabc"}, WSTONE={"#3c3038","#5e4c50","#806a66","#a08a7e","#bea896","#dac6ae"},
  MAPLE={"#521a26","#8a2a2a","#b8402c","#dc6a2c","#f09a38","#ffc860"}, ORANGE={"#5a2416","#8a3a1a","#c45a1e","#e47e2a","#f4a040","#fcc86a"},
  GOLDL={"#5a3a14","#8a5a1a","#bc8420","#e0aa2c","#f4cc4a","#fce67c"}, COB={"#4a3a4a","#6c5c68","#8c7e86","#ac9e9c","#c6b8ae","#ded2c2"},
  IRON={"#24202e","#3a3446","#545066","#727088","#9696a8","#bcbccc"}, LEAFG={"#26341c","#3a5222","#557228","#7a922e","#a4b444","#d0cc6a"},
  PLUM={"#2c1838","#4a2a5c","#6c4080","#8e5ca0","#b284bc","#d4b0d8"}, MOSS={"#1c3028","#2c4c38","#3e6a44","#58885a","#7ea874","#aacb92"},
}
-- Region looks: the LOCAL side of the street. Mossbottom side is always the mushroom terrace.
-- families: timber (NA NWE EE) | adobe (MENA CA ESA CSA) | tropic (CB OC SEA EA) | spice (SA SE WCA)
local RA = X.RAMPS
X.LOOKS = {
  timber = { name="timber", wall=RA.CREAM, frame=RA.TIMB, roof=RA.MAPLE, trim=RA.OAK, accent=RA.GOLDL, sky={"#cfe0f0","#a8c4e4","#86a8d8"} },
  adobe  = { name="adobe",  wall=RA.WSTONE, frame=RA.ORANGE, roof=RA.BARN, trim=RA.MUST, accent=RA.TEAL, sky={"#f8e2b8","#f0c890","#e8a870"} },
  tropic = { name="tropic", wall=RA.TEAL, frame=RA.GREEN, roof=RA.MUST, trim=RA.OAK, accent=RA.ROSE, sky={"#c8ecec","#9cdcd8","#70c8c8"} },
  spice  = { name="spice",  wall=RA.STONE, frame=RA.SLATE, roof=RA.PLUM, trim=RA.IRON, accent=RA.ORANGE, sky={"#d8d0e8","#b4a8d4","#8e80bc"} },
}
X.REGION_LOOK = { NA="timber", NWE="timber", EE="timber", MENA="adobe", CA="adobe", ESA="adobe", CSA="adobe",
  CB="tropic", OC="tropic", SEA="tropic", EA="tropic", SA="spice", SE="spice", WCA="spice" }
X.REGIONS = { "NA","NWE","EE","MENA","CA","ESA","CSA","CB","OC","SEA","EA","SA","SE","WCA" }
-- Mossbottom side (fixed): mushroom caps on cream towers
X.HUB = { cap = { moss=RA.MOSS, petal=RA.ROSE, ember=RA.BARN }, wall=RA.CREAM, trim=RA.OAK, glow="#ffd27a" }
function X.layout()
  local f = io.open(X.SRC .. "/v3/shop-street/shop-street.layout.json") local s = f:read("*a") f:close()
  local L = { spots = {}, byk = {} }
  for k, nm, x, y, b1, b2, b3, b4 in s:gmatch('"k":"([^"]+)","name":"([^"]+)","x":(%d+),"y":(%d+),"box":%[(%d+),(%d+),(%d+),(%d+)%]') do
    local sp = { k = k, name = nm, x = tonumber(x), y = tonumber(y), box = { tonumber(b1), tonumber(b2), tonumber(b3), tonumber(b4) } }
    L.spots[#L.spots+1] = sp L.byk[k] = sp
  end
  L.stand = { {214,272}, {250,282}, {280,268}, {300,280} }
  return L
end
return X
