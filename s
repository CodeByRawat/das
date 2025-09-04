<script>
(function(){
  function ready(fn){ if(document.readyState==="loading"){document.addEventListener("DOMContentLoaded",fn,{once:true});} else {fn();} }
  ready(init);

  function init(){
    /* =============== CONFIG =============== */
    var WORKER_BASE    = "https://mychatbot.sachinrawat-in-com.workers.dev";
    var PUBLIC_API_KEY = "mysite_chat_key_1234";
    var LOGO_URL       = "https://digitaldas.in/wp-content/uploads/2024/04/213.png";
    var WHATSAPP_URL   = "https://wa.link/ibnc8y";
    var CORNER         = "br"; // "bl" for bottom-left
    var ROBOT_PNG_URL  = "http://datawithsachin.com/wp-content/uploads/2025/09/robot-assistant.png";
    document.documentElement.setAttribute("data-ddc-corner", CORNER);

    /* =============== UTIL =============== */
    function $(sel, root){ return (root||document).querySelector(sel); }
    function esc(s){
      // Proper HTML entity escaping
      return String(s).replace(/[&<>"']/g, function(ch){
        return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch];
      });
    }
    function md(src){
      var s = esc(src);
      s = s.replace(/\[([^\]]+)\]\(((?:https?:\/\/|mailto:|tel:)[^\s)]+)\)/gi,'<a href="$2" target="_blank" rel="noopener">$1</a>');
      s = s.replace(/(^|[\s(])([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})(?=$|[\s).,;!?])/gi,'$1<a href="mailto:$2">$2</a>');
      s = s.replace(/\*\*(.+?)\*\*/g,'<strong>$1</strong>').replace(/\*(?!\s)([^*]+?)\*(?!\w)/g,'<em>$1</em>').replace(/`([^`]+)`/g,'<span class="ddc-code">$1</span>');
      return '<p>'+ s.replace(/\n{2,}/g,'</p><p>').replace(/\n/g,'<br>') +'</p>';
    }
    function headers(){ return {"Content-Type":"application/json","x-api-key":PUBLIC_API_KEY}; }
    function saveProfile(p){ try{ localStorage.setItem("ddc_profile", JSON.stringify(p)); }catch(e){} }
    function loadProfile(){ try{ return JSON.parse(localStorage.getItem("ddc_profile")||"null"); }catch(e){ return null; } }
    function fmtPhone(s){ return String(s).replace(/[^\d+]/g,''); }
    function validEmail(s){ return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s); }
    function btnBusy(el,b){ if(!el) return; el.disabled=!!b; el.setAttribute('aria-busy', b?'true':'false'); }
    function vibrate(ms){ try{ if(navigator.vibrate) navigator.vibrate(ms||60); }catch(e){} }
    function validMobileIN(raw){
      var digits = String(raw||"").replace(/\D/g,"");
      var ten = digits.length>=10 ? digits.slice(-10) : digits;
      return /^[6-9]\d{9}$/.test(ten);
    }
    function getCookie(name){
      var m = document.cookie.split(";").map(function(s){return s.trim();}).filter(function(s){return s.indexOf(name+'=')===0;})[0];
      return m ? m.split("=")[1] : null;
    }
    function histKey(){ return 'ddc_hist_' + (getCookie('ddc_id') || 'anon'); }
    function loadHist(){ try{ return JSON.parse(localStorage.getItem(histKey())||"[]"); }catch(e){ return []; } }
    function saveHist(arr){ try{ localStorage.setItem(histKey(), JSON.stringify(arr.slice(-60))); }catch(e){} }
    function pushHist(role, content){ var h=loadHist(); h.push({role:role, content:content}); saveHist(h); }
    function clearHist(){ try{ localStorage.removeItem(histKey()); }catch(e){} }
    function clearProfile(){ try{ localStorage.removeItem("ddc_profile"); }catch(e){} }

    /* =============== CSS =============== */
    var css = [
      ":root{--bg:#0e1624;--fg:#e6edf3;--muted:#9db0c3;--panel:#0c1422;--card:#0f172a;--card-border:rgba(255,255,255,.12);--card-fg:var(--fg);--brand:#2563eb;--accent:#f1c40f;--widget-width:380px;--widget-height:560px;--radius:18px;--button-radius:12px;--shadow:0 14px 40px rgba(0,0,0,.28);--offset:18px;}",
      "@media (prefers-color-scheme:light){:root{--bg:#ffffff;--fg:#0f172a;--muted:#6b7280;--panel:#ffffff;--card:#ffffff;--card-border:rgba(0,0,0,.08);--card-fg:#111827;}}",
      "#ddc-panel,#ddc-panel *{font-family:'Montserrat',sans-serif!important;box-sizing:border-box;}",

      /* ===== PNG Bubble & 'Hi there' note (fall + bounce) ===== */
      "#ddc-btn{position:fixed;bottom:var(--offset);right:var(--offset);left:auto;width:64px;height:64px;border-radius:50%;border:none;cursor:pointer;box-shadow:0 10px 28px rgba(0,0,0,.24);background:transparent;color:#111827;font-size:0;z-index:2147483647;will-change:transform,opacity;transform:translateY(-120vh);opacity:0;display:flex;align-items:center;justify-content:center;padding:0;overflow:hidden;}",
      ":root[data-ddc-corner='bl'] #ddc-btn{left:var(--offset);right:auto;}",
      "#ddc-btn .ddc-img{width:100%;height:100%;display:block;border-radius:50%;object-fit:cover;pointer-events:none;user-select:none;}",
      "#ddc-note{position:fixed;z-index:2147483648;display:block;max-width:240px;padding:10px 12px;font-size:13px;font-weight:700;color:#111827;background:#fef3c7;border:1px solid #f59e0b;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,.18);cursor:pointer;will-change:transform,opacity;transform:translateY(-120vh);opacity:0;}",
      ":root[data-ddc-corner='br'] #ddc-note{right:22px;bottom:92px;}",
      ":root[data-ddc-corner='bl'] #ddc-note{left:22px;bottom:92px;}",
      "#ddc-note::after{content:'';position:absolute;width:0;height:0;border:8px solid transparent;}",
      ":root[data-ddc-corner='br'] #ddc-note::after{right:18px;bottom:-16px;border-top-color:#f59e0b;}",
      ":root[data-ddc-corner='bl'] #ddc-note::after{left:18px;bottom:-16px;border-top-color:#f59e0b;}",
      "@keyframes ddc-fall-bounce{0%{transform:translateY(-120vh);opacity:0}60%{transform:translateY(0);opacity:1}72%{transform:translateY(-28px)}85%{transform:translateY(16px)}92%{transform:translateY(-8px)}100%{transform:translateY(0);opacity:1}}",
      "#ddc-btn.ddc-enter, #ddc-note.ddc-enter{animation:ddc-fall-bounce 1s cubic-bezier(.22,1,.36,1) both;}",
      "#ddc-btn.ddc-attn::before{content:'';position:absolute;inset:-10px;border-radius:999px;border:2px solid rgba(241,196,15,.65);animation:ddc-pulse 1.8s ease-out infinite;}",
      "@keyframes ddc-pulse{0%{transform:scale(.92);opacity:.8}70%{transform:scale(1.1);opacity:.1}100%{transform:scale(1.2);opacity:0}}",
      "@media (prefers-reduced-motion:reduce){#ddc-btn,#ddc-note{transform:none;opacity:1}#ddc-btn.ddc-enter,#ddc-note.ddc-enter,#ddc-btn.ddc-attn::before{animation:none!important}}",

      /* ===== Panel, Chat, Toast ===== */
      "#ddc-panel{position:fixed;bottom:calc(var(--offset) + 74px);right:var(--offset);left:auto;width:var(--widget-width);max-width:92vw;height:var(--widget-height);max-height:78vh;background:var(--panel);color:var(--fg);border-radius:var(--radius);overflow:hidden;display:none;z-index:2147483647;border:1px solid rgba(255,255,255,.08);box-shadow:var(--shadow);}",
      ":root[data-ddc-corner='bl'] #ddc-panel{left:var(--offset);right:auto;}",
      "#ddc-head{background:var(--accent);color:#111827;padding:14px 14px 54px 14px;position:relative;z-index:3;}",
      "#ddc-avatar{position:absolute;left:14px;top:14px;width:36px;height:36px;border-radius:50%;background:#fff url(\""+ LOGO_URL.replace(/"/g,'\\"') +"\") center/cover no-repeat;border:1px solid rgba(0,0,0,.12);}",
      "#ddc-close{position:absolute;right:12px;top:8px;cursor:pointer;color:#111827;font-size:20px;}",
      "#ddc-wtitle{margin:30px 0 0 0;font-weight:800;font-size:20px;text-align:center;}",
      "#ddc-wsub{margin:2px 0 0 0;font-size:14px;text-align:center;font-weight:700;}",
      "#ddc-menu{position:absolute;right:36px;top:8px;font-size:12px;color:#111827;background:rgba(255,255,255,.6);border-radius:10px;padding:4px 8px;cursor:pointer;user-select:none;}",
      "#ddc-menu:hover{background:rgba(255,255,255,.8);}",
      "#ddc-screens{position:absolute;left:0;right:0;top:110px;bottom:48px;width:200%;display:flex;transition:transform .34s ease;z-index:1;min-height:0;}",
      ".ddc-screen{width:50%;overflow:hidden;display:flex;flex-direction:column;min-height:0;}",
      "#ddc-screens .ddc-screen:first-child{overflow:auto;}",
      ".pad{padding:12px;}",
      ".ddc-card{background:var(--card);color:var(--card-fg);border:1px solid var(--card-border);border-radius:14px;padding:12px;box-shadow:0 6px 20px rgba(0,0,0,.08);margin-top:12px;}",
      ".lbl{font-size:13px;color:var(--muted);margin:8px 2px 4px;display:block;}",
      ".inp{width:100%;padding:10px 12px;border-radius:12px;border:1px solid rgba(255,255,255,.18);background:rgba(255,255,255,.06);color:var(--fg);font-size:14px;}",
      ".inp.error{border-color:#ef4444!important;box-shadow:0 0 0 3px rgba(239,68,68,.2);}",
      "#ddc-screens .ddc-screen:last-child{display:flex;flex-direction:column;overflow:hidden;}",
      "#ddc-msgs{flex:1;overflow:auto;padding:12px;padding-bottom:84px;background:linear-gradient(180deg, rgba(255,255,255,.02), rgba(0,0,0,0));display:flex;flex-direction:column;gap:6px;font-size:15px;scrollbar-gutter:stable both-edges;}",
      ".ddc-msg{padding:8px 12px;border-radius:12px;line-height:1.45;overflow-wrap:anywhere;word-break:break-word;max-width:84%;font-weight:500;}",
      ".ddc-bot{align-self:flex-start;background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:var(--fg);}",
      ".ddc-user{align-self:flex-end;background:rgba(235,166,37,0.18);border:1px solid rgba(37,99,235,.35);color:var(--fg);text-align:right;}",
      ".ddc-msg a{color:#1d4ed8;text-decoration:underline;font-weight:600;word-break:break-all;}",
      ".ddc-code{padding:2px 4px;border-radius:4px;border:1px solid rgba(255,255,255,.2);}",
      "#ddc-row{position:sticky;bottom:0;left:0;right:0;z-index:10;padding:10px 10px 12px;background:linear-gradient(180deg,transparent,rgba(0,0,0,.10));border-top:1px solid rgba(0,0,0,.08);}",
      "#ddc-in{display:block;width:100%;height:44px;line-height:44px;font-size:14px;border-radius:12px;border:1px solid rgba(0,0,0,.15);background:#fff;color:#0f172a;padding:0 96px 0 12px;box-shadow:none;outline:none;}",
      "#ddc-in::placeholder{color:#6b7280;opacity:.9;}",
      "#ddc-send{position:absolute;right:18px;top:50%;transform:translateY(-50%);height:36px;padding:0 14px;min-width:72px;border:0;border-radius:12px;background:#2563eb;color:#fff;font-weight:700;cursor:pointer;}",
      "#ddc-send:hover{transform:translateY(-50%) translateY(-1px);}",
      "#ddc-send[disabled]{opacity:.65;cursor:not-allowed;transform:translateY(-50%);}",
      "#ddc-tabs{position:absolute;left:0;bottom:0;width:100%;display:flex;border-top:1px solid rgba(255,255,255,.12);background:rgba(0,0,0,.18);backdrop-filter:blur(6px);z-index:2;}",
      ".ddc-tab{flex:1;text-align:center;padding:10px 0;cursor:pointer;font-size:14px;display:flex;align-items:center;justify-content:center;gap:8px;user-select:none;}",
      ".ddc-tab.active{font-weight:700;border-top:2px solid var(--brand)}",
      ".ddc-tab[aria-disabled='true']{opacity:.55;}",
      ".dot{width:8px;height:8px;border-radius:50%;background:#22c55e}",
      "#ddc-toast{position:absolute;left:50%;bottom:64px;transform:translateX(-50%) translateY(16px);background:#111827;color:#fff;padding:10px 14px;border-radius:12px;font-size:13px;opacity:0;pointer-events:none;transition:opacity .25s ease, transform .25s ease;box-shadow:0 10px 24px rgba(0,0,0,.25);z-index:5;}",
      "#ddc-toast.show{opacity:1;transform:translateX(-50%) translateY(0);}"
    ].join("");

    var style = document.createElement("style");
    style.textContent = css;
    document.head.appendChild(style);

    /* =============== DOM =============== */
    // PNG bubble button
    var btn = document.createElement("button");
    btn.id = "ddc-btn";
    btn.title = "Chat with us";
    btn.setAttribute("aria-label","Open chat");
    var img = document.createElement("img");
    img.src = ROBOT_PNG_URL;
    img.alt = "Chatbot";
    img.className = "ddc-img";
    btn.appendChild(img);
    document.body.appendChild(btn);

    // “Hi there” note
    var note = document.createElement("div");
    note.id = "ddc-note";
    note.textContent = "Hi there 👋";
    document.body.appendChild(note);

    // Chat panel
    var panel = document.createElement("div");
    panel.id = "ddc-panel";
    panel.innerHTML =
      '<div id="ddc-head">'+
        '<div id="ddc-avatar" aria-hidden="true"></div>'+
        '<div id="ddc-close" title="Close">×</div>'+
        '<div id="ddc-menu" title="Reset chat">Reset</div>'+
        '<h3 id="ddc-wtitle">Hi there 👋</h3>'+
        '<div id="ddc-wsub">Hi, I am Tarush — your virtual AI assistant.</div>'+
      '</div>'+
      '<div id="ddc-screens">'+
        '<section class="ddc-screen"><div class="pad">'+
          '<form id="ddc-form" class="ddc-card" novalidate>'+
            '<label class="lbl" for="f-name">Your name</label>'+
            '<input class="inp" id="f-name" name="name" required placeholder="e.g., Sachin Rawat" autocomplete="name">'+
            '<label class="lbl" for="f-email">Email</label>'+
            '<input class="inp" id="f-email" name="email" type="email" required placeholder="you@example.com" autocomplete="email">'+
            '<label class="lbl" for="f-mobile">Mobile</label>'+
            '<input class="inp" id="f-mobile" name="mobile" placeholder="10-digit mobile" inputmode="numeric" pattern="[0-9]*" autocomplete="tel">'+
            '<label class="lbl" for="f-company">Business / Company</label>'+
            '<input class="inp" id="f-company" name="company" placeholder="Digital Das" autocomplete="organization">'+
            '<label style="display:flex;align-items:center;gap:8px;margin-top:10px;font-size:13px;color:var(--muted)">'+
              '<input type="checkbox" id="f-consent" required> I agree to be contacted by email/phone.'+
            '</label>'+
            '<div class="row">'+
              '<button class="btn grow" id="ddc-submit" type="submit">Continue to chat</button>'+
            '</div>'+
            '<p style="margin:10px 0 0 0; font-size:12px; color:var(--muted)">'+
              'We respect your privacy. <a href="/privacy" target="_blank" rel="noopener">Privacy Policy</a>'+
            '</p>'+
          '</form>'+
        '</div></section>'+
        '<section class="ddc-screen">'+
          '<div id="ddc-msgs" aria-live="polite"></div>'+
          '<div id="ddc-row">'+
            '<input id="ddc-in" type="text" placeholder="Type your message…"/>'+
            '<button id="ddc-send">Send</button>'+
          '</div>'+
        '</section>'+
      '</div>'+
      '<div id="ddc-tabs">'+
        '<div class="ddc-tab" id="tab-wa" title="Chat on WhatsApp"><span class="dot"></span>WhatsApp</div>'+
        '<div class="ddc-tab active" id="tab-chat">💬 Chat</div>'+
      '</div>'+
      '<div id="ddc-toast" role="status" aria-live="polite"></div>';
    document.body.appendChild(panel);

    /* =============== REFS =============== */
    var screens = $("#ddc-screens");
    var tabWA   = $("#tab-wa");
    var tabChat = $("#tab-chat");
    var form    = $("#ddc-form");
    var fName   = $("#f-name");
    var fEmail  = $("#f-email");
    var fMobile = $("#f-mobile");
    var fCompany= $("#f-company");
    var fConsent= $("#f-consent");
    var submit  = $("#ddc-submit");
    var msgs    = $("#ddc-msgs");
    var input   = $("#ddc-in");
    var send    = $("#ddc-send");
    var titleEl = $("#ddc-wtitle");
    var toast   = $("#ddc-toast");

    /* =============== ENTRANCE (apply to BOTH) =============== */
    requestAnimationFrame(function(){ requestAnimationFrame(function(){
      btn.classList.add("ddc-enter");
      note.classList.add("ddc-enter");
    });});

    // Safety: if animation didn't run (some themes/plugins), unhide after 1.2s
    setTimeout(function(){
      if (getComputedStyle(btn).opacity === "0"){ btn.style.transform="translateY(0)"; btn.style.opacity="1"; }
      if (getComputedStyle(note).opacity === "0"){ note.style.transform="translateY(0)"; note.style.opacity="1"; }
    }, 1200);

    function lockFinalState(el){
      el.style.transform = "translateY(0)";
      el.style.opacity = "1";
      el.style.visibility = "visible";
      el.classList.remove("ddc-enter");
    }
    btn.addEventListener("animationend", function(e){
      if (e.animationName === "ddc-fall-bounce"){ lockFinalState(btn); btn.classList.add("ddc-attn"); }
    });
    note.addEventListener("animationend", function(e){
      if (e.animationName === "ddc-fall-bounce"){ lockFinalState(note); }
    });

    /* =============== NAV/OPEN/CLOSE =============== */
    function goForm(){ screens.style.transform = "translateX(0)"; }
    function goChat(){ if(!profile){ nudgeForm(); return; } screens.style.transform = "translateX(-50%)"; input.focus(); }

    function show(){ panel.style.display = "block"; }
    function hide(){
      panel.style.display = "none";
      lockFinalState(note);
      note.style.opacity = "1";
    }

    function btnClick(){
      var isOpen = panel.style.display === "block";
      if (isOpen) { hide(); return; }
      show();
      btn.classList.remove("ddc-attn");
      note.style.opacity = "0";
      if (profile){
        goChat();
        if (msgs.children.length === 0) seed();
      } else {
        goForm();
      }
    }
    btn.addEventListener("click", btnClick);
    $("#ddc-close").addEventListener("click", hide);

    // Reset
    $("#ddc-menu").addEventListener("click", function(){
      clearProfile(); clearHist();
      profile = null; msgs.innerHTML = ""; lockUI(true); setHeaderName(); goForm(); showToast("Session reset");
      note.style.opacity = "1";
    });

    /* =============== STATE =============== */
    var profile = loadProfile() || null;

    function setHeaderName(){
      var name = (profile && profile.name) ? profile.name.trim() : "";
      titleEl.textContent = name ? ("Hi, " + name + " 👋") : "Hi there 👋";
    }
    function lockUI(lock){
      tabChat.setAttribute("aria-disabled", lock ? "true" : "false");
      tabWA  .setAttribute("aria-disabled", lock ? "true" : "false");
      input.disabled = !!lock; send.disabled = !!lock;
    }
    if (profile){
      setHeaderName();
      fName.value = profile.name || ""; fEmail.value = profile.email || "";
      fMobile.value = profile.mobile || ""; fCompany.value = profile.company || "";
      lockUI(false);
    } else { lockUI(true); }

    /* =============== TOAST (reliable) =============== */
    function showToast(msg){
      if (!toast) return;
      toast.classList.remove('show'); void toast.offsetWidth;
      toast.textContent = msg;
      toast.classList.add('show');
      clearTimeout(showToast._t);
      showToast._t = setTimeout(function(){ toast.classList.remove('show'); }, 2200);
    }

    /* =============== NUDGE TO FORM IF LOCKED =============== */
    function nudgeForm(){
      var card = form;
      card.classList.remove('shake'); void card.offsetWidth;
      card.classList.add('shake');
      vibrate(60);
      showToast("Please fill the form first ✍️");
      goForm();
    }
    tabChat.addEventListener("click", function(){ if (tabChat.getAttribute("aria-disabled")==="true") nudgeForm(); else goChat(); });
    tabWA  .addEventListener("click", function(){ if (tabWA.getAttribute("aria-disabled")==="true") nudgeForm(); else window.open(WHATSAPP_URL, "_blank", "noopener"); });

    [fName, fEmail, fMobile].forEach(function(el){ el.addEventListener('input', function(){ el.classList.remove('error'); }); });

    /* =============== SCROLL STATE =============== */
    var userScrolledUp = false;
    function nearBottom(){
      var pad = 60;
      return (msgs.scrollHeight - (msgs.scrollTop + msgs.clientHeight)) < pad;
    }
    msgs.addEventListener('scroll', function(){ userScrolledUp = !nearBottom(); });

    /* =============== MESSAGES =============== */
    function addMsg(text, who){
      if (!who) who="bot";
      var d = document.createElement("div");
      d.className = "ddc-msg " + (who==="user"?"ddc-user":"ddc-bot");
      d.innerHTML = md(text);
      msgs.appendChild(d);
      if (!userScrolledUp){
        if (who === "user") msgs.scrollTop = msgs.scrollHeight;
        else d.scrollIntoView({ behavior: "smooth", block: "start" });
      }
      return d;
    }
    function addTyping(){
      var d = document.createElement("div"); d.className="ddc-msg ddc-bot"; d.innerHTML = '<span aria-live="polite">…</span>';
      msgs.appendChild(d);
      if (!userScrolledUp) d.scrollIntoView({ behavior: "smooth", block: "start" });
      return d;
    }
    function seed(){
      addMsg("Welcome to **DigitalDas!**\n\nWe specialize in **EdTech**, **Real Estate**, and **Interior Design**, with custom business development & sales consulting.\n\n- [**WhatsApp**](https://wa.link/ibnc8y)\n- [**Book a Meeting**](https://calendly.com/dastalkss/30min)\n- [**Email**](mailto:info@digitaldas.in)\n- [**Mobile**](tel:+916387812688)");
    }

    /* =============== FORM SUBMIT =============== */
    function submitLead(p){
      return fetch(WORKER_BASE + "/lead", {
        method:"POST",
        headers: headers(),
        credentials:"include",
        body: JSON.stringify(p)
      }).then(function(r){ return r.text().then(function(text){
        var data=null; try{ data = JSON.parse(text||"{}"); }catch(e){}
        if(!r.ok){
          var detail = (data && (data.detail || data.error)) ? ((data.error||"error")+": "+data.detail) : (text||"unknown_error");
          throw new Error(detail);
        }
        return data || {ok:true};
      });});
    }

    form.addEventListener("submit", function(e){
      e.preventDefault();
      var p = {
        name: fName.value.trim(),
        email: fEmail.value.trim().toLowerCase(),
        mobile: fmtPhone(fMobile.value.trim()),
        company: fCompany.value.trim(),
        consent: !!fConsent.checked
      };
      if (!p.name){ fName.classList.add('error'); fName.focus(); showToast("Please enter your name"); return; }
      if (!validEmail(p.email)){ fEmail.classList.add('error'); fEmail.focus(); showToast("Please enter a valid email"); return; }
      if (!validMobileIN(p.mobile)){ fMobile.classList.add('error'); fMobile.focus(); showToast("Please enter a valid 10-digit mobile number"); return; }
      if (!p.consent){ showToast("Please agree to be contacted"); return; }

      btnBusy(submit, true);
      submitLead(p).then(function(){
        profile = p; saveProfile(profile); setHeaderName();
        msgs.innerHTML = ""; seed(); clearHist(); lockUI(false); goChat(); showToast("You're all set 🎉");
      }).catch(function(err){
        console.error(err); showToast("Could not submit lead"); alert("Could not submit lead.\n\nDetails:\n" + (err && err.message ? err.message : err));
      }).finally(function(){ btnBusy(submit, false); });
    });

    /* =============== CHAT SEND =============== */
    function sendMessage(){
      if (input.disabled){ nudgeForm(); return; }
      var m = input.value.trim(); if(!m) return;
      addMsg(m, "user"); pushHist("user", m); input.value = "";
      var t = addTyping(); btnBusy(send, true);

      var body = { message:m, top_k:2, temperature:0.2, profile:profile||undefined, history:loadHist() };
      fetch(WORKER_BASE + "/chat", {
        method:"POST",
        headers: headers(),
        credentials:"include",
        body: JSON.stringify(body)
      }).then(function(res){ return res.text().then(function(text){
        var reply="(no reply)"; try{ var j=JSON.parse(text||"{}"); reply = j.answer || j.error || reply; }catch(e){ reply = "⚠️ Bad JSON response"; }
        t.remove(); addMsg(reply, "bot"); pushHist("assistant", reply);
      });}).catch(function(e){
        console.error(e); t.remove(); addMsg("⚠️ Error contacting server. Check CORS/API key.", "bot");
      }).finally(function(){ btnBusy(send, false); });
    }
    send.addEventListener("click", sendMessage);
    input.addEventListener("keydown", function(e){ if (e.key === "Enter") sendMessage(); });
  }
})();
</script>
