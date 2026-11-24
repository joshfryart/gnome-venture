#!/usr/bin/env python3
"""Pixel icons for the dock's action pieces and strip tiles (16x16, auto 1 px outline). Same palette and writer as gen_nav_icons.py.
Rows are strings (14 wide max, '.' = empty), centred in the 14x14 area. Run: python3 gen_action_icons.py -> nav-<slug>.png, @2x, icons-actions.json"""
import base64, io, json, re
src = open('gen_nav_icons.py').read()
exec(src[:src.index('# ---- main menus')])   # PAL, Ico
A = {}
def art(slug, rows):
    ic = Ico(); h = len(rows); y0 = 1 + (14 - h)//2
    for j, r in enumerate(rows):
        x0 = 1 + (14 - len(r))//2
        for i, ch in enumerate(r): ic.P(x0+i, y0+j, ch)
    A[slug] = ic
art('water', ["....bb....","...bbbb...","...bbbb...","..bsbbbb..","..bsbbbb..",".bsbbbbbB.",".bsbbbbbB.",".bbbbbbbB.","..bbbbbB..","..bBBBBB..","...BBBB..."])
art('harvest', ["..nn....nn..","...n....n...","....nnnn....","..nnnnnnnn..",".nNnNnNnNnN.",".nnnnnnnnnn.",".nNnNnNnNnN.",".nnnnnnnnnn.","..nNnNnNnn..","..nnnnnnnn.."])
art('till', ["........ee..","........eE..",".......eE...","......nN....",".....nN.....","....nN......","...nN.......","..eeee......",".eEEEEe.....",".eeeeee....."])
art('select', ["eeeeeeeeeeee","ewwwwwwwwwwe","ewwwwwwwwGwe","ewwwwwwwGGwe","ewGwwwwGGwwe","ewGGwwGGwwwe","ewwGGGGwwwwe","ewwwGGwwwwwe","ewwwwwwwwwwe","eeeeeeeeeeee"])
art('quick', ["......yy....",".....yyy....","....yyy.....","...yyy......","..yyyyyyy...","...yyyyy....",".....yy.....","....yy......","....y.......","...y........"])
art('rest', ["............","nn..........","nn..........","nnnnnnnnnnnn","nwwwwwwwwwwn","nwwwwwwwbbbn","nnnnnnnnnnnn","nN........Nn","nN........Nn"])
art('heal', ["..rrr..rrr..",".rrrrrrrrrr.","rrwrrrrrrrrR","rrwrrrrrrrrR","rrrrrrrrrrrR",".rrrrrrrrrR.","..rrrrrrrR..","...rrrrrR...","....rrrR....",".....rR....."])
art('globe', ["...bbbbbb...","..bbggbbbb..",".bbgggbbbbb.","bbbgggbbggbb","bbbbggbbgggb","bbbbbbbbgggb","bbbggbbbbggb",".bbgggbbbbb.","..bbggbbbb..","...BBBBBB..."])
art('explore', ["...eeeeee...","..eEyyyyEe..",".eEyyEyyyEe.","eEyyyyEyyyEe","eEyyyyrEyyEe","eEyyyrryyyEe","eEyyrEyyyyEe",".eEyEyyyyEe.","..eEyyyyEe..","...eeeeee..."])
art('tag', ["....yyyyyy..","...yyyyyyyy.","..yyywwyyyy.",".yyyywwyyyy.","yyyyyyyyyyy.",".yyyyyyyyy..","..yyyyyyy...","...yyyyy...."])
art('trail', ["..nn........",".nnnn.......",".nnnn...nn..","..nn...nnnn.","......nnnnn.","...nn..nnnn.","..nnnn..nn..","..nnnn......","...nn......."])
art('sights', ["...eeee.....","..eswwse....",".esswwsse...",".eswsssse...",".esssssse...","..essssee...","...eeeeEE...",".......EEE..","........EEE.",".........EE."])
art('fight', ["e.........ee","ee.......ee.",".ee.....ee..","..ee...ee...","...eeeee....","....eee.....","...nnnnn....","..nn.n.nn...",".nn..n..nn..","nn...N...nn."])
art('run', ["....tt......","....tt......","...rrrr.....","..rrrrrrr...",".rr.rrr.....","....rrrr....","...rr..rr...","..rr....rr..",".nn.....nn.."])
art('buy', ["..nn..nn....",".n..nn..n...","nnnnnnnnnnn.","nNnNnNnNnNn.","nnnnnnnnnnn.","nNnNnNnNnNn.","nnnnnnnnnnn.","nnnnnnnnnnn."])
art('sell', ["...yyyyyy...","..yyoooyyy..",".yyoyyyoyyy.",".yyoyyyyyyy.",".yyyooyyyyy.",".yyyyyoyyyy.",".yyoyyyoyyy.","..yyoooyyy..","...yyyyyy..."])
art('save', ["nnnnnnnnnnn.","nneeeeee.nn.","nneEEEEe.nn.","nneeeeee.nn.","nnnnnnnnnnn.","nnwwwwwwwnn.","nnwkkkkkwnn.","nnwwwwwwwnn.","nnwkkkkkwnn.","nnnnnnnnnnn."])
art('rotate', ["...gggggg...","..gg....gg..",".gg......gg.",".g.......ggg","........gggg","....gg..gg.g",".g...gg.g...",".gg...gg.g..","..gg....gg..","...gggggg..."])
art('back', ["....e.......","...ee.......","..eee.......",".eeeeeeeeee.","eeeeeeeeeeee",".eeeeeeeeee.","..eee.......","...ee.......","....e......."])
art('tend', ["..yy..yy..","y.yyyyyy.y","yyyyNNyyyy","yyyNnnNyyy","yyyNnnNyyy","yyyyNNyyyy","y.yyyyyy.y","..yy.G.yy.","....GG....","....G.....","...lGl....."])
art('wander', ["........gg..",".......gGgg.","......gGlgg.",".....gGlggg.","....gGlgggg.","...gGlggggg.","..gGlgggGg..",".gGlggGg....","gGgGg.......","nN.........."])
art('dohere', ["...rrrrr....","..rrwrrrr...","..rrwrrrrR..","..rrrrrrrR..","...rrrrrR...","....rrrR....",".....rR.....",".....nn.....","....nn......",".....nn....."])
art('sneak', ["....kkkk....","...kkkkkk...","...kwkwkk...","...kkkkkk...","....kkkk....","...kkkkkk...","..kkkkkkkk..","..kk.kk.kk..","..nn....nn.."])
art('hunt', ["..nn........","..n.n.......","..n..n......","..n...n.....","nNnNnNnNnNee","..n...n.....","..n..n......","..n.n.......","..nn........"])
art('creature', ["..sssssss...",".sswwwwwss..","sswwsssswss.","sswsssssswss","sswsssssswss","sswwsssswss.",".sswwwwwss..","..sssssss...","...eeEE.....",".....EE.....","......EE...."])
art('craft', ["....ee.ee...","...e.e..e...","....e.e.e...","..eeeeeeeee.",".eEEEEEEEEe.",".eEEEEEEEEee",".eEEEEEEEEee",".eEEEEEEEEe.","..eeeeeeeee."])
art('jar', ["...nnnnnn...","...NNNNNN...","..eeeeeeee..",".eewwwwwwee.",".ewwoooowwe.",".ewooooooowe",".ewooooooowe",".ewooooooowe",".eewwwwwwee.","..eeeeeeee.."])
art('sleep', ["...yyy......","..yy........",".yy.........",".yy.....ww..",".yy....www..","..yy..www...","...yyyww....","....www....."])
art('nap', ["...PPPPP....","......PP....",".....PP.....","....PP......","...PPPPP....",".......PPP..",".......PP...","......PP....",".....PPPPP.."])
art('wave', ["...tt.......","..tttt..t...",".tttttttt...","tttttttt....","tttttttt.t..",".tttttttt...","..ttttttt...","...tttttt..."])
art('sit', ["nn..........","nn..........","nn..........","nnnnnnnnnnn.","nNNNNNNNNNn.","nN........nN","nN........nN"])
art('snack', ["......gg....",".....gG.....","...rrrGrr...","..rrrrrrrr..",".rrwrrrrrrR.",".rrwrrrrrrR.",".rrrrrrrrrR.","..rrrrrrrR..","...rrrrRR..."])
art('game', ["....pppp....","..pppppppp..",".ppwppppwpp.",".pppppppppp.","..pppppppp..","...pPPPP....","....PPP....."])
art('bunting', ["rrrrrrrrrrrr","rwrwrwrwrwrw",".yyyyyyyyyy.","..yyyyyyyy..","...yyyyyy...","....yyyy...."])
art('basket', ["..nn....nn..","...nnnnnn...",".nnnnnnnnnn.","nNnNnNnNnNnN","nnnnnnnnnnnn","nNnNnNnNnNnN",".nnnnnnnnnn.","..nnnnnnnn.."])
art('offer', ["tt.......tt.","ttt.....ttt.",".ttt...ttt..","..ttt.ttt...","...tttttt...","....tttt....",".....tt....."])
art('journey', ["..........rr","........rrr.","......rrrr..",".....rrrr...","..rr.rr.....",".rrrr.......",".rrrr.......","..rr........","...n........","...n........"])
art('handin', ["....ww......","...wwww.....","...wwww.....",".tt.tt.tt...","tttttttttt..","tttttttttt..",".tttttttt...","..tttttt...."])
art('finish', ["nnrrwwrrww..","nnwwrrwwrr..","nnrrwwrrww..","nnwwrrwwrr..","nn..........","nn..........","nn..........","nn.........."])
art('crate', ["nnnnnnnnnnnn","nNnnnnnnnnNn","nnNnnnnnnNnn","nnnNnnnnNnnn","nnnnNNNNnnnn","nnnnNNNNnnnn","nnnNnnnnNnnn","nnNnnnnnnNnn","nNnnnnnnnnNn","nnnnnnnnnnnn"])
art('messages', ["wwwwwwwwwwww","wkkkkkkkkkkw","wwwwwwwwwwww","wkkkkkkkwwww","wwwwwwwwwwww",".wwww.......","..ww........","...w........"])
art('undo', ["....bbbb....","..bbbbbbbb..",".bbb....bbb.","bbb......bb.","bbbbb.....bb","..bbb.....bb","...bb.....bb","..........bb",".........bbb"])
art('size', ["..........nn","........nnnn","......nnnnnn","....nnnnnnnn",".nnnnnnnnnnn","nn.nnnnnnnnn","nn..nnnnnnnn","nn....nn...."])
art('shape', ["eeee........","eEEe........","eEEe..eeee..","eeee..eEEe..","......eeee..","....eeeeee..","....eEEEEe..","....eeeeee.."])
art('away', ["nnnnnnnnnnnn","nNnnnnnnnnNn","nnnnnnnnnnnn","nnnnnnnnnnnn","nnn.gggg.nnn","nnn.gGGg.nnn","nnnnGGGGnnnn","nnnnnnnnnnnn"])
art('tools', ["..e.....nn..","..eE...nN...","...eE.nN....","....eenN....","...nNeeE....","..nN..eE....",".nN....eE...","nN......e..."])
art('cookagain', ["....ee.ee...","...ee..ee...","..eeeeeeeee.","eeEEEEEEEEee","eEEEEEEEEEEe","eeEEEEEEEEee",".eeeeeeeeee.","..yy..yy....","...yy..yy..."])
import os
uris = {}
for slug, ic in A.items():
    im = ic.image(); im.save('nav-%s.png' % slug); im.resize((32, 32), Image.NEAREST).save('nav-%s@2x.png' % slug)
print(len(A), 'icons:', ' '.join(A))
