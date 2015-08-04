// Definition of Url object
;eval(function(p,a,c,k,e,r){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}(';5 V=(8(){"1D 1B";5 j={l:\'l\',E:\'1y\',m:\'m\',p:\'1x\',q:\'1v\',v:\'v\'},19={"1u":1t,"1q":1n,"1m":11,"1k":18,"1j":11,"1i":18},S=8(a,b){5 d=1g,O=d.1f(\'a\'),b=b||d.17.G,H=b.r(/\\/\\/(.*?)(?::(.*?))?@/)||[];O.G=b;w(5 i R j){a[i]=O[j[i]]||\'\'}a.l=a.l.o(/:$/,\'\');a.q=a.q.o(/^\\?/,\'\');a.v=a.v.o(/^#/,\'\');a.F=H[1]||\'\';a.x=H[2]||\'\';a.m=(19[a.l]==a.m||a.m==0)?\'\':a.m;9(!a.l&&!/^([a-z]+:)?\\/\\//.1d(b)){5 c=T V(d.17.G.r(/(.*\\/)/)[0]),A=c.p.X(\'/\'),B=a.p.X(\'/\');A.W();w(5 i=0,C=[\'l\',\'F\',\'x\',\'E\',\'m\'],s=C.Z;i<s;i++){a[C[i]]=c[C[i]]}10(B[0]==\'..\'){A.W();B.1c()}a.p=(b.1p(0,1)!=\'/\'?A.13(\'/\'):\'\')+\'/\'+B.13(\'/\')}D{a.p=a.p.o(/^\\/?/,\'/\')}14(a)},15=8(s){s=s.o(/\\+/g,\' \');s=s.o(/%([1b][0-t-f])%([P][0-t-f])%([P][0-t-f])/N,8(a,b,c,d){5 e=u(b,16)-1e,Q=u(c,16)-M;9(e==0&&Q<1h){k a}5 f=u(d,16)-M,n=(e<<12)+(Q<<6)+f;9(n>1l){k a}k K.J(n)});s=s.o(/%([1o][0-t-f])%([P][0-t-f])/N,8(a,b,c){5 d=u(b,16)-1a;9(d<2){k a}5 e=u(c,16)-M;k K.J((d<<6)+e)});s=s.o(/%([0-7][0-t-f])/N,8(a,b){k K.J(u(b,16))});k s},14=8(g){5 h=g.q;g.q=T(8(c){5 d=/([^=&]+)(=([^&]*))?/g,r;10((r=d.1r(c))){5 f=1s(r[1].o(/\\+/g,\' \')),I=r[3]?15(r[3]):\'\';9(4[f]!=1w){9(!(4[f]y Y)){4[f]=[4[f]]}4[f].1z(I)}D{4[f]=I}}4.1A=8(){w(f R 4){9(!(4[f]y U)){1C 4[f]}}};4.L=8(){5 s=\'\',e=1E;w(5 i R 4){9(4[i]y U){1F}9(4[i]y Y){5 a=4[i].Z;9(a){w(5 b=0;b<a;b++){s+=s?\'&\':\'\';s+=e(i)+\'=\'+e(4[i][b])}}D{s+=(s?\'&\':\'\')+e(i)+\'=\'}}D{s+=s?\'&\':\'\';s+=e(i)+\'=\'+e(4[i])}}k s}})(h)};k 8(a){4.L=8(){k((4.l&&(4.l+\'://\'))+(4.F&&(4.F+(4.x&&(\':\'+4.x))+\'@\'))+(4.E&&4.E)+(4.m&&(\':\'+4.m))+(4.p&&4.p)+(4.q.L()&&(\'?\'+4.q))+(4.v&&(\'#\'+4.v)))};S(4,a)}}());',62,104,'||||this|var|||function|if|||||||||||return|protocol|port||replace|path|query|match||9a|parseInt|hash|for|pass|instanceof||basePath|selfPath|props|else|host|user|href|auth|value|fromCharCode|String|toString|0x80|gi|link|89ab|n2|in|parse|new|Function|Url|pop|split|Array|length|while|80||join|parseQs|decode||location|443|defaultPorts|0xC0|ef|shift|test|0xE0|createElement|document|32|wss|ws|https|0xFFFF|http|70|cd|substring|gopher|exec|decodeURIComponent|21|ftp|search|null|pathname|hostname|push|clear|strict|delete|use|encodeURIComponent|continue'.split('|'),0,{}));
jQuery.fn.syntaxSelectable = function() {
  var lastClicked, $block = this;

  var updateURL = function(blockNum, lineStart, lineEnd) {
    var url = new Url()
    url.hash = 'L-'+blockNum+'-'+lineStart;
    if (typeof lineEnd !== "undefined" && lineEnd != lineStart) {
        url.query.lineend = lineEnd;
    } else {
        delete url.query.lineend;
    }
    if (typeof window.history.replaceState == 'function') {
      window.history.replaceState({}, document.title, url.toString())
    }
  }
  var highlightLines = function(els, selected) {
    jQuery(els).addClass('highlight');
    if (selected) { jQuery(els).addClass('selected'); }
  }
  var unhighlightLines = function(els, selected) {
    if (typeof els == "undefined") { els = jQuery('.hll .highlight'); }
    if (typeof selected == "undefined") { els = jQuery(els).not('.selected'); }
    jQuery(els).removeClass('highlight');
    if (selected) { jQuery(els).removeClass('selected'); }
  }
  var extractCodeNum = function(el) {
    var codeNum;
    var jel = jQuery(el);
    if (jel.is('span')) {
      codeNum = jel.attr('id').match(/^LC-([a-f0-9]{6})/)[1];
    } else if (jel.is('a')) {
      codeNum = jel.attr('href').match(/^#L-([a-f0-9]{6})/)[1];
    }
    return codeNum;
  };
  var extractLineNum = function(el) {
    var lineNum;
    var jel = jQuery(el);
    if (jel.is('span')) {
      lineNum = jel.attr('id').match(/^LC-[a-f0-9]{6}-([0-9]+)$/)[1]
    } else if (jel.is('a')) {
      lineNum = jel.attr('href').match(/^#L-[a-f0-9]{6}-([0-9]+)$/)[1];
    }
    return parseInt(lineNum);
  }
  var findMatchingLines = function(exampleNo, lineStart, lineEnd) {
    var lines = []
    var codeblock = jQuery('#'+exampleNo);
    if (typeof lineEnd == "undefined") { lineEnd = lineStart; }
    var codeLines = codeblock.find('.code pre').children().slice(lineStart - 1, lineEnd);
    var lineNums = codeblock.find('pre.lineno').children().slice(lineStart - 1, lineEnd);
    jQuery.merge(lines, codeLines);
    jQuery.merge(lines, lineNums);
    return lines;
  }
  var highlightFromUrl = function() {
    var url = new Url();
    if (url.hash.match(/^L-[a-f0-9]{6}-[0-9]+$/)) {
      var matched = url.hash.match(/^L-([a-f0-9]{6})-([0-9]+)$/);
      var exampleNo = matched[1], lineStart = matched[2], lineEnd = url.query.lineend;
      highlightLines(findMatchingLines(exampleNo, lineStart, lineEnd), true);
    }
  }
  var addEvents = function() {
    $block.find('.lineno a, .code pre > span').on({
      mouseover: function(evt) {
        var lines = findMatchingLines(extractCodeNum(this), extractLineNum(this));
        highlightLines(lines);
      },
      mouseleave: function(evt) {
        var lines = findMatchingLines(extractCodeNum(this), extractLineNum(this));
        unhighlightLines(lines);
      },
      click: function(evt) {
        evt.preventDefault();
        jQuery(this).off('mouseleave');
        var range = [];
        if(evt.shiftKey && lastClicked) {
          if (extractCodeNum(lastClicked) == extractCodeNum(this)) {
            range.push(lastClicked);
            range.push(this);
          } else {
            range.push(this);
            range.push(this);
          }
        } else {
          range.push(this);
          range.push(this);
        }
        var sortedRange = range.sort(function(a,b) {
          aNum = extractLineNum(a);
          bNum = extractLineNum(b);
          return aNum - bNum;});
        var lines = findMatchingLines(extractCodeNum(sortedRange[0]), extractLineNum(sortedRange[0]), extractLineNum(sortedRange[1]));
        unhighlightLines(undefined, true);
        highlightLines(lines, true);
        updateURL(extractCodeNum(sortedRange[0]), extractLineNum(sortedRange[0]), extractLineNum(sortedRange[1]));
        lastClicked = this;
      }
    });
  }
  highlightFromUrl();
  addEvents();
}
jQuery('.hll').syntaxSelectable();
