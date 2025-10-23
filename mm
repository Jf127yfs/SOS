<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Compatibility Matcher // Finding Connections</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root {
      --pumpkin: #FF6F00;
      --forest: #558B2F;
      --twilight: #7B1FA2;
      --amber: #FFA726;
      --moss: #8D6E63;
      --cream: #FFF8E1;
      --shadow: rgba(139, 69, 19, 0.4);
    }
   
    * { box-sizing: border-box; margin: 0; padding: 0; }
   
    body {
      background: linear-gradient(135deg, #2D1810 0%, #1A1A1A 50%, #2D1810 100%);
      font-family: 'Courier New', monospace;
      color: #FFF8E1;
      overflow: hidden;
      height: 100vh;
    }
   
    .header {
      text-align: center;
      padding: 15px;
      background: rgba(26, 26, 26, 0.95);
      border-bottom: 3px solid var(--pumpkin);
      box-shadow: 0 4px 15px var(--shadow);
      position: relative;
      z-index: 200;
    }
   
    .header h1 {
      font-size: 24px;
      color: var(--pumpkin);
      letter-spacing: 3px;
      text-shadow: 2px 2px 0px var(--twilight), 0 0 20px var(--pumpkin);
      margin-bottom: 5px;
    }
   
    .header .subtitle {
      font-size: 12px;
      color: var(--amber);
      letter-spacing: 2px;
    }
   
    .sync-button-container {
      position: fixed;
      top: 70px;
      left: 10px;
      display: flex;
      align-items: center;
      gap: 8px;
      z-index: 250;
    }
   
    .sync-btn {
      background: rgba(26, 26, 26, 0.9);
      color: var(--moss);
      border: 1px solid var(--moss);
      padding: 4px 10px;
      border-radius: 4px;
      font-size: 10px;
      cursor: pointer;
      font-weight: normal;
      transition: all 0.2s ease;
      opacity: 0.6;
    }
   
    .sync-btn:hover {
      background: rgba(141, 110, 99, 0.3);
      opacity: 1;
      border-color: var(--pumpkin);
      color: var(--pumpkin);
    }
   
    .sync-btn:disabled {
      opacity: 0.4;
      cursor: not-allowed;
    }
   
    .sync-status {
      font-size: 9px;
      opacity: 0.8;
    }
   
    .analytics {
      position: fixed;
      top: 70px;
      right: 10px;
      background: rgba(26, 26, 26, 0.95);
      border: 3px solid var(--pumpkin);
      border-radius: 15px;
      padding: 12px;
      min-width: 180px;
      box-shadow: 0 6px 20px var(--shadow);
      z-index: 250;
    }
   
    .analytics h3 {
      color: var(--pumpkin);
      font-size: 12px;
      margin-bottom: 10px;
      text-align: center;
      border-bottom: 2px solid var(--forest);
      padding-bottom: 6px;
    }
   
    .stat-row {
      display: flex;
      justify-content: space-between;
      margin: 6px 0;
      font-size: 11px;
    }
   
    .stat-label { color: #A0826D; }
    .stat-value {
      color: var(--amber);
      font-weight: bold;
      font-size: 14px;
    }
   
    .previous-matches {
      position: fixed;
      top: 180px;
      left: 10px;
      width: 220px;
      max-height: calc(100vh - 200px);
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding: 10px;
      overflow-y: auto;
      z-index: 10;
    }
   
    .previous-match-card {
      background: rgba(26, 26, 26, 0.95);
      border: 2px solid var(--forest);
      border-radius: 10px;
      padding: 12px;
      display: flex;
      align-items: center;
      gap: 10px;
      animation: slideIn 0.5s ease-out;
      box-shadow: 0 3px 10px var(--shadow);
      height: 100%;
    }
   
    @keyframes slideIn {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }
   
    .prev-avatars {
      display: flex;
      flex-direction: column;
      gap: 4px;
      flex-shrink: 0;
    }
   
    .prev-avatar {
      width: 42px;
      height: 42px;
      background: var(--moss);
      border: 2px solid var(--pumpkin);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      color: var(--cream);
      overflow: hidden;
      flex-shrink: 0;
    }
    
    .prev-avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
   
    .prev-info {
      flex: 1;
      font-size: 11px;
      line-height: 1.5;
      min-width: 0;
    }
   
    .prev-names {
      font-weight: bold;
      color: var(--amber);
      margin-bottom: 4px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
   
    .prev-score {
      font-size: 22px;
      color: var(--pumpkin);
      font-weight: bold;
      flex-shrink: 0;
    }
   
    .main-stage {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 100px;
      z-index: 100;
    }
   
    .card {
      width: 280px;
      height: 380px;
      background: rgba(26, 26, 26, 0.98);
      border: 4px solid var(--pumpkin);
      border-radius: 20px;
      padding: 20px;
      box-shadow: 0 10px 40px var(--shadow), 0 0 30px rgba(255, 111, 0, 0.3);
      display: flex;
      flex-direction: column;
      align-items: center;
      position: relative;
      animation: cardFadeIn 0.5s ease-out;
    }
   
    .card-content {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
      transition: filter 0.3s ease, opacity 0.3s ease;
    }
   
    @keyframes cardFadeIn {
      from { opacity: 0; transform: scale(0.9); }
      to { opacity: 1; transform: scale(1); }
    }
   
    .card.searching-left {
      animation: cardPulse 1.5s ease-in-out infinite;
    }
   
    .card.searching-right {
      animation: cardSpin 0.15s linear infinite;
    }
   
    .card.searching-right .card-content {
      filter: blur(3px);
      opacity: 0.7;
    }
   
    @keyframes cardPulse {
      0%, 100% { transform: scale(1); box-shadow: 0 10px 40px var(--shadow), 0 0 30px rgba(255, 111, 0, 0.3); }
      50% { transform: scale(1.05); box-shadow: 0 10px 40px var(--shadow), 0 0 40px rgba(255, 111, 0, 0.6); }
    }
   
    @keyframes cardSpin {
      0% { transform: translateY(0px); }
      100% { transform: translateY(-5px); }
    }
   
    .avatar-frame {
      width: 120px;
      height: 120px;
      background: var(--moss);
      border: 3px solid var(--forest);
      border-radius: 15px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 15px;
      position: relative;
      overflow: hidden;
      box-shadow: 0 0 15px rgba(85, 139, 47, 0.5);
    }
   
    .avatar-frame img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
   
    .avatar-placeholder {
      font-size: 50px;
      color: var(--cream);
      opacity: 0.8;
    }
   
    .screen-name {
      font-size: 20px;
      font-weight: bold;
      color: var(--amber);
      margin-bottom: 10px;
      text-align: center;
      min-height: 25px;
      text-shadow: 0 0 10px rgba(255, 167, 38, 0.5);
    }
   
    .info-item {
      width: 100%;
      margin: 5px 0;
      padding: 6px;
      background: rgba(141, 110, 99, 0.3);
      border-radius: 8px;
      font-size: 11px;
      text-align: center;
      border: 1px solid var(--forest);
    }
   
    .info-label {
      color: var(--pumpkin);
      font-weight: bold;
      display: block;
      margin-bottom: 3px;
      font-size: 10px;
    }
   
    .info-value {
      color: var(--cream);
      font-size: 10px;
    }
   
    .connection-zone {
      position: relative;
      width: 200px;
      height: 380px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }
   
    .connection-canvas {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 300px;
      height: 200px;
      pointer-events: none;
    }
   
    .scanning-overlay {
      position: absolute;
      top: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 150px;
      height: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 15px;
    }
   
    .scan-bar {
      width: 120px;
      height: 8px;
      background: rgba(85, 139, 47, 0.3);
      border-radius: 10px;
      overflow: hidden;
      border: 2px solid var(--forest);
    }
   
    .scan-progress {
      height: 100%;
      background: linear-gradient(90deg, var(--pumpkin), var(--amber));
      width: 0%;
      transition: width 0.3s ease;
      box-shadow: 0 0 10px var(--pumpkin);
    }
   
    .scan-percentage {
      font-size: 32px;
      font-weight: bold;
      color: var(--amber);
      text-shadow: 2px 2px 0 var(--twilight), 0 0 20px var(--amber);
      animation: scanPulse 1s ease-in-out infinite;
    }
   
    @keyframes scanPulse {
      0%, 100% { transform: scale(1); opacity: 0.8; }
      50% { transform: scale(1.1); opacity: 1; }
    }
   
    .scan-text {
      font-size: 12px;
      color: var(--pumpkin);
      text-align: center;
      animation: scanTextPulse 1.5s ease-in-out infinite;
    }
   
    @keyframes scanTextPulse {
      0%, 100% { opacity: 0.5; }
      50% { opacity: 1; }
    }
   
    .speech-bubble {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      background: rgba(26, 26, 26, 0.98);
      border: 3px solid var(--pumpkin);
      border-radius: 20px;
      padding: 20px;
      max-width: 200px;
      text-align: center;
      box-shadow: 0 8px 30px var(--shadow), 0 0 30px rgba(255, 111, 0, 0.5);
      display: none;
      z-index: 10;
      animation: bubblePop 0.5s ease-out;
    }
   
    @keyframes bubblePop {
      0% { transform: translate(-50%, -50%) scale(0); }
      70% { transform: translate(-50%, -50%) scale(1.1); }
      100% { transform: translate(-50%, -50%) scale(1); }
    }
   
    .speech-bubble.active {
      display: block;
    }
   
    .speech-bubble::before {
      content: '';
      position: absolute;
      bottom: -20px;
      left: 50%;
      transform: translateX(-50%);
      width: 0;
      height: 0;
      border-left: 20px solid transparent;
      border-right: 20px solid transparent;
      border-top: 20px solid var(--pumpkin);
    }
   
    .speech-bubble::after {
      content: '';
      position: absolute;
      bottom: -15px;
      left: 50%;
      transform: translateX(-50%);
      width: 0;
      height: 0;
      border-left: 17px solid transparent;
      border-right: 17px solid transparent;
      border-top: 17px solid rgba(26, 26, 26, 0.98);
    }
   
    .bubble-emoji {
      font-size: 32px;
      margin-bottom: 10px;
    }
   
    .bubble-score {
      font-size: 28px;
      color: var(--amber);
      font-weight: bold;
      margin-bottom: 8px;
      text-shadow: 1px 1px 0 var(--twilight), 0 0 15px var(--amber);
    }
   
    .bubble-message {
      font-size: 12px;
      color: var(--cream);
      font-weight: bold;
      line-height: 1.4;
    }
   
    .fireworks-canvas {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: 1000;
    }
   
    .shared-interests {
      position: absolute;
      bottom: -100px;
      left: 50%;
      transform: translateX(-50%);
      width: 400px;
      padding: 10px;
      background: rgba(123, 31, 162, 0.3);
      border-radius: 10px;
      border: 2px dashed var(--twilight);
      display: none;
    }
   
    .shared-interests.active {
      display: block;
      animation: slideUp 0.5s ease-out;
    }
   
    @keyframes slideUp {
      from { opacity: 0; transform: translateX(-50%) translateY(20px); }
      to { opacity: 1; transform: translateX(-50%) translateY(0); }
    }
   
    .shared-label {
      font-size: 10px;
      color: var(--twilight);
      font-weight: bold;
      text-align: center;
      margin-bottom: 5px;
      text-shadow: 0 0 10px rgba(123, 31, 162, 0.8);
    }
   
    .interest-tag {
      display: inline-block;
      background: var(--twilight);
      color: var(--cream);
      padding: 4px 8px;
      margin: 3px;
      border-radius: 12px;
      font-size: 10px;
      font-weight: bold;
      box-shadow: 0 0 10px rgba(123, 31, 162, 0.5);
    }
  </style>
</head>
<body>
  <canvas class="fireworks-canvas" id="fireworksCanvas"></canvas>
 
  <div class="header">
    <h1>🎃 COMPATIBILITY MATCHER 🎃</h1>
    <div class="subtitle">// FINDING SPOOKY CONNECTIONS //</div>
  </div>
 
  <div class="sync-button-container">
    <button id="syncPhotosBtn" class="sync-btn" onclick="syncPhotos()">
      🔄 Sync Photos
    </button>
    <span id="syncStatus" class="sync-status"></span>
  </div>
 
  <div class="analytics">
    <h3>📊 LIVE STATS</h3>
    <div class="stat-row">
      <span class="stat-label">Matches Made:</span>
      <span class="stat-value" id="matchCount">0</span>
    </div>
    <div class="stat-row">
      <span class="stat-label">Active Guests:</span>
      <span class="stat-value" id="guestCount">0</span>
    </div>
    <div class="stat-row">
      <span class="stat-label">Best Match:</span>
      <span class="stat-value" id="bestMatch">--</span>
    </div>
  </div>
 
  <div class="previous-matches" id="previousMatches"></div>
 
  <div class="main-stage">
    <div class="card" id="card1">
      <div class="card-content">
        <div class="avatar-frame" id="avatar1">
          <div class="avatar-placeholder">👤</div>
        </div>
        <div class="screen-name" id="name1">---</div>
        <div class="info-item">
          <span class="info-label">🎵 Music</span>
          <span class="info-value" id="music1">---</span>
        </div>
        <div class="info-item">
          <span class="info-label">⭐ Zodiac</span>
          <span class="info-value" id="zodiac1">---</span>
        </div>
        <div class="info-item">
          <span class="info-label">🎯 Interests</span>
          <div class="info-value" id="interests1">---</div>
        </div>
      </div>
    </div>
   
    <div class="connection-zone">
      <canvas class="connection-canvas" id="connectionCanvas"></canvas>
     
      <div class="scanning-overlay" id="scanningOverlay">
        <div class="scan-percentage" id="scanPercentage">0%</div>
        <div class="scan-bar">
          <div class="scan-progress" id="scanProgress"></div>
        </div>
        <div class="scan-text">Analyzing Compatibility...</div>
      </div>
     
      <div class="speech-bubble" id="speechBubble">
        <div class="bubble-emoji">🎃</div>
        <div class="bubble-score" id="bubbleScore">79%</div>
        <div class="bubble-message">Congrats on a spooktacular match!<br>You should get to know each other!</div>
      </div>
     
      <div class="shared-interests" id="sharedInterests">
        <div class="shared-label">✨ SHARED INTERESTS ✨</div>
        <div id="sharedTags"></div>
      </div>
    </div>
   
    <div class="card" id="card2">
      <div class="card-content">
        <div class="avatar-frame" id="avatar2">
          <div class="avatar-placeholder">👤</div>
        </div>
        <div class="screen-name" id="name2">---</div>
        <div class="info-item">
          <span class="info-label">🎵 Music</span>
          <span class="info-value" id="music2">---</span>
        </div>
        <div class="info-item">
          <span class="info-label">⭐ Zodiac</span>
          <span class="info-value" id="zodiac2">---</span>
        </div>
        <div class="info-item">
          <span class="info-label">🎯 Interests</span>
          <div class="info-value" id="interests2">---</div>
        </div>
      </div>
    </div>
  </div>

  <script>
    function syncPhotos() {
      const btn = document.getElementById('syncPhotosBtn');
      const status = document.getElementById('syncStatus');
     
      if (!btn || !status) {
        console.error('Sync button or status element not found');
        return;
      }
     
      btn.disabled = true;
      btn.textContent = '⏳';
      status.textContent = 'Syncing...';
      status.style.color = '#666';
     
      google.script.run
        .withSuccessHandler(function(response) {
          btn.disabled = false;
          btn.textContent = '🔄 Sync Photos';
         
          if (response.success) {
            status.textContent = '✅ Done';
            status.style.color = '#28a745';
           
            setTimeout(function() {
              loadMatches();
            }, 2000);
          } else {
            status.textContent = '❌ Failed';
            status.style.color = '#dc3545';
          }
        })
        .withFailureHandler(function(error) {
          btn.disabled = false;
          btn.textContent = '🔄 Sync Photos';
          status.textContent = '❌ Error';
          status.style.color = '#dc3545';
        })
        .syncPhotosFromDrive();
    }
   
    const MUSIC_GENRES = {
      '1': 'Hip-hop',
      '2': 'Pop',
      '3': 'Indie/Alt',
      '4': 'R&B',
      '5': 'Rock',
      '6': 'Country',
      '7': 'Electronic',
      '8': 'Prog Rock'
    };
   
    let allMatches = [];
    let allGuests = [];
    let previousMatches = [];
    let currentMatchIndex = 0;
    let isSearching = false;
    let searchStartTime = 0;
    let bestMatchScore = 0;
    let scanInterval = null;
    let cycleInterval = null;
    let cycleSpeed = 150;
   
    const connectionCanvas = document.getElementById('connectionCanvas');
    const connectionCtx = connectionCanvas.getContext('2d');
    connectionCanvas.width = 300;
    connectionCanvas.height = 200;
   
    const fireworksCanvas = document.getElementById('fireworksCanvas');
    const fireworksCtx = fireworksCanvas.getContext('2d');
    fireworksCanvas.width = window.innerWidth;
    fireworksCanvas.height = window.innerHeight;
   
    let fireworks = [];
    let connectionProgress = 0;
   
    function safeNum(val, decimals) {
      decimals = decimals || 2;
      const num = parseFloat(val);
      return isNaN(num) ? 0 : parseFloat(num.toFixed(decimals));
    }
   
    function loadMatches() {
      google.script.run
        .withSuccessHandler(function(data) {
          allMatches = data.matches || [];
          document.getElementById('guestCount').textContent = data.totalGuests || 0;
          document.getElementById('matchCount').textContent = allMatches.length;
         
          allGuests = [];
          const guestMap = new Map();
          allMatches.forEach(match => {
            if (!guestMap.has(match.person1.screenName)) {
              guestMap.set(match.person1.screenName, match.person1);
            }
            if (!guestMap.has(match.person2.screenName)) {
              guestMap.set(match.person2.screenName, match.person2);
            }
          });
          allGuests = Array.from(guestMap.values());
         
          if (allMatches.length > 0 && !isSearching) {
            startSearchAnimation();
          }
        })
        .withFailureHandler(function(err) {
          console.error('Error loading matches:', err);
        })
        .getCompatibilityMatches();
    }
   
    function startSearchAnimation() {
      if (currentMatchIndex >= allMatches.length) {
        currentMatchIndex = 0;
      }
     
      const match = allMatches[currentMatchIndex];
     
      isSearching = true;
      searchStartTime = Date.now();
      connectionProgress = 0;
      cycleSpeed = 150;
     
      document.getElementById('scanningOverlay').style.display = 'flex';
      document.getElementById('speechBubble').classList.remove('active');
      document.getElementById('sharedInterests').classList.remove('active');
     
      document.getElementById('card1').classList.add('searching-left');
      document.getElementById('card2').classList.add('searching-right');
     
      displayPerson(match.person1, 1);
     
      let cycleCount = 0;
      const maxCycles = 30;
     
      function doCycle() {
        const randomGuest = allGuests[Math.floor(Math.random() * allGuests.length)];
        displayPerson(randomGuest, 2);
       
        cycleCount++;
       
        if (cycleCount === 16) {
          clearInterval(cycleInterval);
          cycleSpeed = 250;
          cycleInterval = setInterval(doCycle, cycleSpeed);
        } else if (cycleCount === 23) {
          clearInterval(cycleInterval);
          cycleSpeed = 400;
          cycleInterval = setInterval(doCycle, cycleSpeed);
        } else if (cycleCount === 28) {
          clearInterval(cycleInterval);
          cycleSpeed = 600;
          cycleInterval = setInterval(doCycle, cycleSpeed);
        }
       
        if (cycleCount >= maxCycles) {
          clearInterval(cycleInterval);
          setTimeout(function() {
            displayPerson(match.person2, 2);
            document.getElementById('card2').classList.remove('searching-right');
          }, 800);
        }
      }
     
      cycleInterval = setInterval(doCycle, cycleSpeed);
     
      let scanPercentage = 0;
      scanInterval = setInterval(function() {
        scanPercentage = Math.min(scanPercentage + Math.random() * 15, 100);
        document.getElementById('scanPercentage').textContent = Math.floor(scanPercentage) + '%';
        document.getElementById('scanProgress').style.width = scanPercentage + '%';
       
        if (scanPercentage >= 100) {
          clearInterval(scanInterval);
        }
      }, 300);
     
      animateConnection();
    }
   
    function displayPerson(person, cardNumber) {
      console.log('=== Displaying Person ' + cardNumber + ' ===');
      console.log('Screen Name:', person.screenName);
      console.log('Photo URL:', person.photoUrl);
     
      document.getElementById('name' + cardNumber).textContent = person.screenName || '---';
      document.getElementById('music' + cardNumber).textContent = getMusicGenre(person.music);
      document.getElementById('zodiac' + cardNumber).textContent = person.zodiac || '---';
      document.getElementById('interests' + cardNumber).textContent = (person.interests || []).slice(0, 3).join(', ') || '---';
     
      const avatarFrame = document.getElementById('avatar' + cardNumber);
     
      if (person.photoUrl && person.photoUrl.trim() !== '') {
        console.log('✅ Photo URL exists, creating image element');
       
        const img = document.createElement('img');
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        img.alt = person.screenName || 'Guest';
        img.src = person.photoUrl;
       
        img.onload = function() {
          console.log('✅ Image loaded successfully for ' + person.screenName);
        };
       
        img.onerror = function(e) {
          console.error('❌ Image failed to load for ' + person.screenName);
          console.error('URL was:', person.photoUrl);
          console.error('Error:', e);
          avatarFrame.innerHTML = '<div class="avatar-placeholder">👤</div>';
        };
       
        avatarFrame.innerHTML = '';
        avatarFrame.appendChild(img);
      } else {
        console.log('❌ No photo URL, showing placeholder');
        avatarFrame.innerHTML = '<div class="avatar-placeholder">👤</div>';
      }
    }
   
    function animateConnection() {
      const elapsed = Date.now() - searchStartTime;
      const duration = 5000 + Math.random() * 2000;
     
      connectionCtx.clearRect(0, 0, connectionCanvas.width, connectionCanvas.height);
     
      connectionProgress = Math.min(elapsed / duration, 1);
     
      const leftStartX = safeNum(10);
      const rightStartX = safeNum(connectionCanvas.width - 10);
      const centerY = safeNum(connectionCanvas.height / 2);
      const centerX = safeNum(connectionCanvas.width / 2);
     
      const leftEndX = safeNum(leftStartX + (centerX - leftStartX) * connectionProgress);
      connectionCtx.strokeStyle = 'rgba(255, 111, 0, ' + safeNum(connectionProgress) + ')';
      connectionCtx.lineWidth = 4;
      connectionCtx.lineCap = 'round';
      connectionCtx.shadowBlur = 10;
      connectionCtx.shadowColor = '#FF6F00';
      connectionCtx.beginPath();
      connectionCtx.moveTo(leftStartX, centerY);
      connectionCtx.lineTo(leftEndX, centerY);
      connectionCtx.stroke();
     
      const rightEndX = safeNum(rightStartX - (rightStartX - centerX) * connectionProgress);
      connectionCtx.strokeStyle = 'rgba(123, 31, 162, ' + safeNum(connectionProgress) + ')';
      connectionCtx.shadowColor = '#7B1FA2';
      connectionCtx.beginPath();
      connectionCtx.moveTo(rightStartX, centerY);
      connectionCtx.lineTo(rightEndX, centerY);
      connectionCtx.stroke();
      connectionCtx.shadowBlur = 0;
     
      if (connectionProgress >= 0.95) {
        const sparkSize = safeNum(10 + Math.sin(Date.now() / 100) * 5);
        connectionCtx.fillStyle = '#FFA726';
        connectionCtx.shadowBlur = 20;
        connectionCtx.shadowColor = '#FFA726';
        connectionCtx.beginPath();
        connectionCtx.arc(centerX, centerY, sparkSize, 0, Math.PI * 2);
        connectionCtx.fill();
        connectionCtx.shadowBlur = 0;
      }
     
      if (elapsed < duration) {
        requestAnimationFrame(animateConnection);
      } else {
        showMatch();
      }
    }
   
    function showMatch() {
      const match = allMatches[currentMatchIndex];
      currentMatchIndex++;
     
      isSearching = false;
      clearInterval(scanInterval);
      clearInterval(cycleInterval);
      document.getElementById('scanningOverlay').style.display = 'none';
      document.getElementById('card1').classList.remove('searching-left');
      document.getElementById('card2').classList.remove('searching-right');
     
      const displayScore = Math.round((match.similarity + 0.10) * 100);
     
      document.getElementById('bubbleScore').textContent = displayScore + '%';
      document.getElementById('speechBubble').classList.add('active');
     
      if (match.sharedInterests && match.sharedInterests.length > 0) {
        const tagsHtml = match.sharedInterests.slice(0, 5).map(int =>
          '<span class="interest-tag">' + escapeHtml(int) + '</span>'
        ).join('');
        document.getElementById('sharedTags').innerHTML = tagsHtml;
        document.getElementById('sharedInterests').classList.add('active');
      }
     
      if (displayScore > bestMatchScore) {
        bestMatchScore = displayScore;
        document.getElementById('bestMatch').textContent = displayScore + '%';
      }
     
      triggerFireworks();
      addToPreviousMatches(match, displayScore);
     
      setTimeout(function() {
        startSearchAnimation();
      }, 10000);
    }
   
    function getMusicGenre(musicCode) {
      if (!musicCode || musicCode === '---') return '---';
      return MUSIC_GENRES[String(musicCode)] || musicCode;
    }
   
    function triggerFireworks() {
      for (let i = 0; i < 12; i++) {
        setTimeout(function() {
          createFirework();
        }, i * 200);
      }
    }
   
    function createFirework() {
      const x = safeNum(Math.random() * fireworksCanvas.width);
      const y = safeNum(Math.random() * (fireworksCanvas.height * 0.6));
      const particles = [];
     
      const colors = ['#FF6F00', '#FFA726', '#7B1FA2', '#558B2F', '#8D6E63'];
      const color = colors[Math.floor(Math.random() * colors.length)];
     
      for (let i = 0; i < 25; i++) {
        particles.push({
          x: x,
          y: y,
          vx: safeNum((Math.random() - 0.5) * 8),
          vy: safeNum((Math.random() - 0.5) * 8),
          life: 50,
          color: color
        });
      }
     
      fireworks.push(particles);
    }
   
    function animateFireworks() {
      fireworksCtx.clearRect(0, 0, fireworksCanvas.width, fireworksCanvas.height);
     
      fireworks = fireworks.filter(particles => {
        return particles.some(p => p.life > 0);
      });
     
      fireworks.forEach(particles => {
        particles.forEach(p => {
          if (p.life > 0) {
            const size = 6;
            const drawX = safeNum(Math.floor(p.x / size) * size);
            const drawY = safeNum(Math.floor(p.y / size) * size);
           
            fireworksCtx.fillStyle = p.color;
            fireworksCtx.fillRect(drawX, drawY, size, size);
           
            p.x = safeNum(p.x + p.vx);
            p.y = safeNum(p.y + p.vy);
            p.vy = safeNum(p.vy + 0.2);
            p.life--;
          }
        });
      });
     
      requestAnimationFrame(animateFireworks);
    }
   
    function addToPreviousMatches(match, score) {
      const container = document.getElementById('previousMatches');
      const card = document.createElement('div');
      card.className = 'previous-match-card';
     
      const avatar1Html = match.person1.photoUrl 
        ? '<div class="prev-avatar"><img src="' + escapeHtml(match.person1.photoUrl) + '" alt="' + escapeHtml(match.person1.screenName) + '"></div>'
        : '<div class="prev-avatar">👤</div>';
      
      const avatar2Html = match.person2.photoUrl 
        ? '<div class="prev-avatar"><img src="' + escapeHtml(match.person2.photoUrl) + '" alt="' + escapeHtml(match.person2.screenName) + '"></div>'
        : '<div class="prev-avatar">👤</div>';
     
      card.innerHTML = `
        <div class="prev-avatars">
          ${avatar1Html}
          ${avatar2Html}
        </div>
        <div class="prev-info">
          <div class="prev-names">${escapeHtml(match.person1.screenName)} ⭐ ${escapeHtml(match.person2.screenName)}</div>
          <div style="font-size: 10px; color: #8D6E63;">${match.sharedInterests.length} shared interests</div>
        </div>
        <div class="prev-score">${score}%</div>
      `;
     
      container.insertBefore(card, container.firstChild);
     
      while (container.children.length > 100) {
        container.removeChild(container.lastChild);
      }
    }
   
    function escapeHtml(text) {
      const div = document.createElement('div');
      div.textContent = text || '';
      return div.innerHTML;
    }
   
    window.addEventListener('load', function() {
      loadMatches();
      animateFireworks();
      setInterval(loadMatches, 15 * 60 * 1000);
      console.log('🔄 MM page: Auto-refresh enabled (every 15 min)');
    });
  </script>
</body>
</html>
