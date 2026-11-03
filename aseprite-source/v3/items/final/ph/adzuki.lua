local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- adzuki: an open green-brown pod splitting along its seam to show glossy dark-red beans with white ridges, three loose beans in front. quirk: one bean wears a sleepy face.
local c = D.new("adzuki")
local RB = {"#3a0c1a","#5e1426","#8a2030","#aa3038","#c84a48","#e8786c"}
local PD = {"#3a3a24","#585a30","#7a7c3c","#9c9e52","#bdbe74","#dcdc9c"}
local pod = H.sweep({{8,22},{22,10},{38,12},{54,24}}, function(t) return 4.2 - 2.6 * abs(t-.5)*2 + 0.5 end, 70)
D.lit(pod, PD, 3.2)
-- seam open: dark gap line and beans in it
local pbeans = {{18,15},{25,13},{33,13},{41,15},{48,19}}
for _, b in ipairs(pbeans) do
  local m = D.ell(b[1], b[2]+1, 3.3, 2.6, 0.2) D.lit(m, RB, 2.2) c:px(b[1]+2, b[2]+1, "#fff4d6")
end
for _, p in ipairs{{12,21},{14,19}} do c:px(p[1], p[2], "#3a3a24") end
D.ln(52,24,60,32,"#585a30") D.ln(52,25,59,33,"#7a7c3c")
-- loose beans
c:groundShadow(30, 54, 20, 2)
local lb = {{16,44,6,4.2,-0.3},{30,46,6.2,4.4,0.1},{43,42,5.8,4.2,0.4}}
for i, b in ipairs(lb) do
  local m = D.ell(b[1], b[2], b[3], b[4], b[5]) D.lit(m, RB, 3.4)
  c:px(floor(b[1]-1), floor(b[2]-2), "#fff4d6")
  local hx, hy = floor(b[1]+1.5*cos(b[5])), floor(b[2]+1.5*sin(b[5]))
  for k = -1, 1 do c:px(hx+k, hy+1, "#f6e6bf") end
end
-- sleepy face on the middle bean
c:px(27,45,"#1c1418") c:px(28,45,"#1c1418") c:px(32,45,"#1c1418") c:px(33,45,"#1c1418") c:px(30,48,"#1c1418")
D.fin()
