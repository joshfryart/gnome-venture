-- spinach-seed (seed D2s_0)
dofile([[/home/user/gnome-venture/aseprite-source/v3/items/seedgen/seedgen.lua]])({
name="spinach-seed", dir=[[/home/user/gnome-venture/aseprite-source/v3/items]],
seed={"#4a3a20","#6e5830","#947c44","#b89c5c","#d4b878","#ecd89c"}, leaf={"#14502c","#1e6e38","#2c8c44","#40a850","#5cc464","#88e08c"}, sleaf={"#2a8a3c","#40a84c","#5cc460","#80dc7c","#a8f09c","#d0ffc4"}, stem={"#a05a5a","#b87868","#c89a78","#6aa858","#88c470"}, root={"#f0e4cc","#fbf2dc","#fffcf0"},
vein="#b8ecb0", gloss="#fff0c0", cool="#4a4a80", red="#a8506a",
sl=0.85, sw=0.9, taper=0.05, drop={4}, marks="spots", markc="#f4e4b0",
scrap={7,56,26,54,56,40}, scrapW=7.0, scrapExp=0.9, sprout="pair", leafw=2.6, quirk="none",
extra=function(ctx) local c=ctx.c for _,p in ipairs({{19,44},{27,41},{35,43},{23,50}}) do c:put(p[1],p[2],"#e4cc90",{r={name="q"}}) end end,
})
