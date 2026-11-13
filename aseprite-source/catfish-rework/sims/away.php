<?php
// Realistic check-in sim: S sessions a day of A active minutes, away in between at 50% (8h cap), greedy buys only during sessions. Nap every N days at the end of a session.
function is_admin(){return false;} function setting($n){return '';}
require '/home/user/gnome-venture/game/includes/catfish.php';
$S=(int)$argv[1]; $A=(int)$argv[2]; $N=(int)$argv[3]; $days=(int)($argv[4]??28);
$cat=['mood'=>'greedy']; $yarn=0; $up=[]; $k=0.0; $run=0.0; $gap=(1440-$S*$A)/$S; $first=null;
$buy=function() use(&$up,&$k,$cat,&$yarn){ while(true){$best=null;$bv=0;$kph=catfish_kph($up,$cat,true,$yarn);
 foreach(CATFISH_UPGRADES as $key=>$d){$n=$up[$key]??0;$c=catfish_cost($key,$n); if($c>$k)continue; $u2=$up;$u2[$key]=$n+1;$v=(catfish_kph($u2,$cat,true,$yarn)-$kph)/$c; if($v>$bv){$bv=$v;$best=$key;}}
 if(!$best)return; $k-=catfish_cost($best,$up[$best]??0); $up[$best]=($up[$best]??0)+1; } };
for($d=1;$d<=$days;$d++){ for($s=0;$s<$S;$s++){
  $secs=min($gap*60, CATFISH_OFFLINE_CAP); $g=catfish_kph($up,$cat,false,$yarn)*0.5*$secs/3600; $k+=$g; $run+=$g; $buy();
  for($m=0;$m<$A;$m++){ $g=catfish_kph($up,$cat,true,$yarn)/60; $k+=$g; $run+=$g; $buy(); } }
 if($d%$N===0){ $y=catfish_nap_yarn((int)$run,$cat); if($y>0){ if($first===null)$first=$d; $yarn+=$y; $up=[]; $k=0; $run=0; } } }
printf("S=%d A=%dm nap every %dd, %d days: Yarn %d (x%.2f), kph now %s, first nap day %s\n",$S,$A,$N,$days,$yarn,catfish_yarn_mult($yarn),number_format(catfish_kph($up,$cat,true,$yarn)),$first??'-');
