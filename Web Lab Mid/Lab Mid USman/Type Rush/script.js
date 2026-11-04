const $=s=>document.querySelector(s), $$=s=>[...document.querySelectorAll(s)];
// ---------- Configuration ----------
const DA={easy:{speed:45,gap:900,min:5,pen:1,lim:8,txt:"Slow bubbles, 8 misses allowed, -1 penalty"},
          medium:{speed:70,gap:700,min:5,pen:2,lim:6,txt:"Normal speed, 6 misses allowed, -2 penalty"},
          hard:{speed:100,gap:550,min:6,pen:3,lim:4,txt:"Fast bubbles, 4 misses allowed, -3 penalty"}};
const DB={easy:{n:15,lim:4000,txt:"15 keys, 4 seconds per key"},
          medium:{n:20,lim:2500,txt:"20 keys, 2.5 seconds per key"},
          hard:{n:25,lim:1500,txt:"25 keys, 1.5 seconds per key"}};
const SETS={home:"ASDFJKL",top:"QWERTYUIOP",bottom:"ZXCVBNM",all:"ABCDEFGHIJKLMNOPQRSTUVWXYZ"};
const ROWS=["QWERTYUIOP","ASDFGHJKL","ZXCVBNM"];
const ALPHA=SETS.all;

// ---------- State ----------
let cfg={}, s={}, raf=0, tick=0, fbT=0;
function stopLoops(){cancelAnimationFrame(raf);clearInterval(tick);raf=0;tick=0}  // one place that kills every timer/loop

// ---------- Home screen ----------
function note(card){
  const m=card.id==="cardA"?DA:DB, d=card.querySelector(".seg .on").dataset.v;
  card.querySelector("[data-note]").textContent=m[d].txt;
}
$$(".card").forEach(c=>{
  c.querySelectorAll(".seg button").forEach(b=>b.onclick=()=>{c.querySelectorAll(".seg button").forEach(x=>x.classList.remove("on"));b.classList.add("on");note(c)});
  note(c);
});
$$("[data-start]").forEach(b=>b.onclick=()=>{
  const c=b.closest(".card");
  cfg={m:b.dataset.start,d:c.querySelector(".seg .on").dataset.v,ks:$("#ks").value};
  $("#home").classList.add("hide");$("#game").classList.remove("hide");
  setup();run();
});

// ---------- Keyboard panel (Mode B) ----------
$("#kb").innerHTML=ROWS.map(r=>`<div class="row">${[...r].map(k=>`<button class="k" data-k="${k}">${k}</button>`).join("")}</div>`).join("");
$$(".k").forEach(k=>k.onclick=()=>press(k.dataset.k));

// ---------- Helpers ----------
const rnd=a=>a[Math.floor(Math.random()*a.length)];
function hud(){
  const a=cfg.m==="A", t=(s.el||0).toFixed(1)+"s";
  const items=a?[["Score",s.score],["Misses",`${s.miss}/${DA[cfg.d].lim}`],["Level",s.lv||1],["Time",t]]
               :[["Score",s.score],["Key",`${Math.min(s.done+1,DB[cfg.d].n)}/${DB[cfg.d].n}`],["Streak",s.streak],["Time",t]];
  $("#hud").innerHTML=items.map(([l,v])=>`<div class="chip"><small>${l}</small><b>${v}</b></div>`).join("");
}
function fb(t,c){const e=$("#fb");e.textContent=t;e.className="fb "+c;clearTimeout(fbT);fbT=setTimeout(()=>{e.className="fb";e.textContent=""},700)}
function flash(c){const e=$("#stage");e.classList.remove("good","bad");void e.offsetWidth;e.classList.add(c);setTimeout(()=>e.classList.remove(c),300)}

// ---------- Setup / reset (clears ALL state) ----------
function setup(){
  stopLoops();
  s={running:false,score:0,correct:0,wrong:0,miss:0,done:0,streak:0,best:0,times:[],bubbles:[],el:0,lv:1,target:null};
  const a=cfg.m==="A";
  $("#A").innerHTML="";$("#A").classList.toggle("hide",!a);$("#B").classList.toggle("hide",a);
  $("#mt").textContent=a?"Bubbles":"KeyMagnet";
  $("#db").textContent=cfg.d[0].toUpperCase()+cfg.d.slice(1)+(a?"":" - "+cfg.ks+" keys");
  $("#tgt").textContent="?";$("#fill").style.width="100%";
  $$(".k").forEach(k=>{k.classList.remove("tgt","ok","no");k.classList.toggle("on",SETS[cfg.ks].includes(k.dataset.k)||a)});
  $("#fb").className="fb";$("#fb").textContent="";
  $("#idle").classList.remove("hide");$("#bStart").disabled=false;
  $("#res").classList.add("hide");
  hud();
}
function run(){
  if(s.running)return;
  s.running=true;s.t0=performance.now();
  $("#idle").classList.add("hide");$("#bStart").disabled=true;
  if(cfg.m==="A"){s.last=s.t0;s.sp=0;raf=requestAnimationFrame(loopA)}
  else{nextB();tick=setInterval(tickB,50)}
}

// ---------- MODE A: Bubbles ----------
function spawn(H){
  const used=s.bubbles.map(b=>b.l), l=rnd([...ALPHA].filter(x=>!used.includes(x)));
  const el=document.createElement("div");el.className="bub";el.textContent=l;
  el.style.left=(3+Math.random()*(88-3))+"%";
  el.style.background=`radial-gradient(circle at 30% 28%,#fffa,${rnd(["#2563eb","#e11d48","#7c3aed","#7f1d3a","#0ea5e9","#a78bfa"])} 70%)`;
  const b={l,el,y:H};el.onpointerdown=e=>{e.preventDefault();press(l)};
  el.style.transform=`translateY(${H}px)`;
  $("#A").appendChild(el);s.bubbles.push(b);
}
function removeB(b,pop){
  s.bubbles=s.bubbles.filter(x=>x!==b);
  if(pop){b.el.classList.add("pop");setTimeout(()=>b.el.remove(),250)}else b.el.remove();
}
function loopA(t){
  if(!s.running)return;
  const d=DA[cfg.d],dt=Math.min((t-s.last)/1000,.05);s.last=t;s.el=(t-s.t0)/1000;
  s.lv=1+Math.floor(s.correct/5);                          // difficulty ramps every 5 pops
  const sp=d.speed*(1+.12*(s.lv-1)), tgt=Math.min(d.min+Math.floor((s.lv-1)/2),9);
  const gap=Math.max(250,d.gap-(s.lv-1)*40), H=$("#A").clientHeight;
  if(s.bubbles.length<tgt&&t-s.sp>gap){spawn(H);s.sp=t}
  for(const b of [...s.bubbles]){
    b.y-=sp*dt;b.el.style.transform=`translateY(${b.y}px)`;
    if(b.y<=0){removeB(b,false);s.miss++;flash("bad");fb("Missed "+b.l,"bad");
      if(s.miss>=d.lim){hud();return end("Game Over")}}
  }
  hud();raf=requestAnimationFrame(loopA);
}

// ---------- MODE B: KeyMagnet ----------
function nextB(){
  const n=DB[cfg.d].n;
  if(s.done>=n)return end("Completed!");
  const pool=[...SETS[cfg.ks]].filter(k=>k!==s.target);
  s.target=rnd(pool);s.tS=performance.now();
  $$(".k").forEach(k=>k.classList.toggle("tgt",k.dataset.k===s.target));
  $("#tgt").textContent=s.target;
}
function tickB(){
  if(!s.running)return;
  const now=performance.now(),lim=DB[cfg.d].lim,rem=lim-(now-s.tS);
  s.el=(now-s.t0)/1000;$("#fill").style.width=Math.max(0,rem/lim*100)+"%";
  if(rem<=0){s.wrong++;s.streak=0;s.done++;flash("bad");fb("Too slow!","bad");nextB()}
  hud();
}
function keyFlash(k,c){const e=document.querySelector(`.k[data-k="${k}"]`);if(!e)return;e.classList.add(c);setTimeout(()=>e.classList.remove(c),250)}

// ---------- Input (shared by keyboard, touch, on-screen keys) ----------
function press(k){
  if(!s.running)return;
  if(cfg.m==="A"){
    const m=s.bubbles.filter(b=>b.l===k).sort((a,b)=>a.y-b.y)[0];
    if(m){removeB(m,true);s.correct++;s.score+=10;flash("good");fb("+10","good")}
    else{s.wrong++;s.score=Math.max(0,s.score-DA[cfg.d].pen);flash("bad");fb(`Wrong key! -${DA[cfg.d].pen}`,"bad")}
    hud();
  }else{
    if(k===s.target){
      const rt=performance.now()-s.tS,lim=DB[cfg.d].lim,pts=10+Math.round(10*Math.max(0,1-rt/lim));
      s.times.push(rt);s.correct++;s.streak++;s.best=Math.max(s.best,s.streak);s.score+=pts;s.done++;
      keyFlash(k,"ok");flash("good");fb(`+${pts}  (${(rt/1000).toFixed(2)}s)`,"good");nextB();
    }else{
      s.wrong++;s.streak=0;s.score=Math.max(0,s.score-2);
      keyFlash(k,"no");flash("bad");fb("Wrong key! -2","bad");
    }
    hud();
  }
}
document.addEventListener("keydown",e=>{
  if(!s.running||e.ctrlKey||e.metaKey||e.altKey)return;
  const k=e.key.toUpperCase();
  if(/^[A-Z]$/.test(k)){e.preventDefault();press(k)}
});

// ---------- Results ----------
function end(title){
  s.running=false;stopLoops();
  const tot=s.correct+s.wrong,acc=tot?Math.round(s.correct/tot*100):0,a=cfg.m==="A";
  const avg=s.times.length?(s.times.reduce((x,y)=>x+y,0)/s.times.length/1000).toFixed(2)+"s":"-";
  const fast=s.times.length?(Math.min(...s.times)/1000).toFixed(2)+"s":"-";
  const st=a?[["Correct",s.correct],["Wrong keys",s.wrong],["Misses",s.miss],["Accuracy",acc+"%"],["Level reached",s.lv],["Time survived",s.el.toFixed(1)+"s"]]
            :[["Correct",s.correct],["Incorrect",s.wrong],["Accuracy",acc+"%"],["Avg response",avg],["Fastest",fast],["Best streak",s.best]];
  $("#rt").textContent=title;$("#rsc").textContent=s.score;
  $("#rmsg").textContent=acc>=90?"Outstanding typing!":acc>=70?"Nice work, keep practicing.":"Slow down and aim for accuracy.";
  $("#rst").innerHTML=st.map(([l,v])=>`<div><small>${l}</small><b>${v}</b></div>`).join("");
  $("#res").classList.remove("hide");$("#bStart").disabled=true;
}

// ---------- Controls (no page reloads) ----------
$("#bStart").onclick=run;
$("#bRestart").onclick=()=>{setup();run()};
$("#bReset").onclick=setup;
$("#rAgain").onclick=()=>{setup();run()};
function home(){stopLoops();s={running:false};$("#res").classList.add("hide");$("#game").classList.add("hide");$("#home").classList.remove("hide")}
$("#bHome").onclick=home;$("#rHome").onclick=home;