<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>🎃 Halloween Match Maker // Live Analytics</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root {
      --pumpkin: #FF6F00;
      --forest: #558B2F;
      --twilight: #9C27B0;
      --amber: #FFB74D;
      --moss: #8D6E63;
      --cream: #FFF8E1;
      --shadow: rgba(0, 0, 0, 0.7);
      --glow: rgba(255, 111, 0, 0.5);
      --dark-bg: #0d0d0d;
      --card-bg: rgba(26, 26, 26, 0.95);
    }
   
    * { box-sizing: border-box; margin: 0; padding: 0; }
   
    body {
      background: linear-gradient(135deg, #1a0f0a 0%, #0d0d0d 50%, #1a0f0a 100%);
      font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
      color: var(--cream);
      overflow-x: hidden;
      height: 100vh;
    }

    /* Live Stats Ticker */
    .ticker-container {
      background: rgba(0, 0, 0, 0.9);
      border-bottom: 2px solid var(--pumpkin);
      padding: 8px 0;
      overflow: hidden;
      position: relative;
      z-index: 300;
    }

    .ticker-content {
      display: inline-block;
      white-space: nowrap;
      padding-left: 100%;
      animation: scroll-left 60s linear infinite;
      font-size: 13px;
      color: var(--amber);
      font-weight: 500;
    }

    @keyframes scroll-left {
      0% { transform: translateX(0); }
      100% { transform: translateX(-100%); }
    }

    /* Header */
    .header {
      text-align: center;
      padding: 20px;
      background: var(--card-bg);
      border-bottom: 3px solid var(--pumpkin);
      box-shadow: 0 4px 15px var(--shadow);
      position: relative;
      z-index: 200;
    }
   
    .header h1 {
      font-size: 32px;
      font-weight: 700;
      color: var(--pumpkin);
      letter-spacing: 5px;
      text-shadow: 2px 2px 4px rgba(0,0,0,0.8), 0 0 40px var(--glow);
      margin-bottom: 8px;
      animation: glow-pulse 3s ease-in-out infinite;
    }

    @keyframes glow-pulse {
      0%, 100% { text-shadow: 2px 2px 4px rgba(0,0,0,0.8), 0 0 40px var(--glow); }
      50% { text-shadow: 2px 2px 4px rgba(0,0,0,0.8), 0 0 60px var(--glow), 0 0 80px var(--pumpkin); }
    }

    .header .subtitle {
      font-size: 14px;
      color: var(--amber);
      letter-spacing: 3px;
      font-weight: 300;
    }

    /* Main Container */
    .main-container {
      display: grid;
      grid-template-columns: 200px 1fr 280px;
      gap: 15px;
      padding: 15px;
      height: calc(100vh - 220px);
      overflow: hidden;
    }

    /* Activity Stream (Left Column) */
    .activity-stream {
      background: var(--card-bg);
      border: 2px solid var(--forest);
      border-radius: 12px;
      padding: 12px;
      overflow-y: auto;
      box-shadow: 0 4px 15px var(--shadow);
    }

    .activity-stream h3 {
      color: var(--pumpkin);
      font-size: 11px;
      margin-bottom: 10px;
      text-align: center;
      border-bottom: 2px solid var(--forest);
      padding-bottom: 6px;
      letter-spacing: 1px;
    }

    .activity-item {
      font-size: 10px;
      padding: 6px;
      margin: 4px 0;
      background: rgba(85, 139, 47, 0.1);
      border-left: 2px solid var(--forest);
      border-radius: 4px;
      animation: slideIn 0.3s ease-out;
    }

    .activity-time {
      color: var(--moss);
      font-size: 9px;
    }

    @keyframes slideIn {
      from { opacity: 0; transform: translateX(-10px); }
      to { opacity: 1; transform: translateX(0); }
    }

    /* Center Column - Main Match Display */
    .center-column {
      display: flex;
      flex-direction: column;
      gap: 15px;
      overflow-y: auto;
    }

    .main-match-stage {
      background: var(--card-bg);
      border: 4px solid var(--pumpkin);
      border-radius: 20px;
      padding: 25px;
      box-shadow: 0 10px 40px var(--shadow), 0 0 30px rgba(255, 111, 0, 0.3);
      position: relative;
      min-height: 420px;
    }

    .match-title {
      text-align: center;
      font-size: 22px;
      color: var(--pumpkin);
      font-weight: bold;
      margin-bottom: 15px;
      text-shadow: 0 0 20px var(--glow);
    }

    .match-pair {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 40px;
      margin-bottom: 20px;
    }

    .match-person {
      text-align: center;
    }

    .match-avatar {
      width: 120px;
      height: 120px;
      background: var(--moss);
      border: 3px solid var(--forest);
      border-radius: 15px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 10px;
      overflow: hidden;
      box-shadow: 0 0 15px rgba(85, 139, 47, 0.5);
      position: relative;
    }

    .match-avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .match-avatar-placeholder {
      font-size: 50px;
      color: var(--cream);
      opacity: 0.8;
    }

    .match-name {
      font-size: 18px;
      font-weight: bold;
      color: var(--amber);
      margin-bottom: 8px;
    }

    .match-details {
      font-size: 11px;
      color: var(--cream);
      opacity: 0.8;
    }

    .match-score-ring {
      text-align: center;
      margin: 20px 0;
    }

    .score-percentage {
      font-size: 48px;
      font-weight: bold;
      color: var(--amber);
      text-shadow: 2px 2px 0 var(--twilight), 0 0 20px var(--amber);
    }

    .top-reasons {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 8px;
      margin: 15px 0;
    }

    .reason-chip {
      background: var(--twilight);
      color: var(--cream);
      padding: 6px 12px;
      border-radius: 15px;
      font-size: 11px;
      font-weight: bold;
      box-shadow: 0 0 10px rgba(156, 39, 176, 0.5);
      animation: chipPop 0.3s ease-out;
    }

    @keyframes chipPop {
      from { transform: scale(0); }
      to { transform: scale(1); }
    }

    .shared-interests-box {
      background: rgba(156, 39, 176, 0.2);
      border: 2px dashed var(--twilight);
      border-radius: 10px;
      padding: 12px;
      margin-top: 15px;
      text-align: center;
    }

    .shared-label {
      font-size: 11px;
      color: var(--twilight);
      font-weight: bold;
      margin-bottom: 8px;
    }

    .interest-tag {
      display: inline-block;
      background: var(--twilight);
      color: var(--cream);
      padding: 4px 10px;
      margin: 3px;
      border-radius: 12px;
      font-size: 10px;
      font-weight: bold;
    }

    /* Previous Matches Feed */
    .previous-matches {
      background: var(--card-bg);
      border: 3px solid var(--forest);
      border-radius: 15px;
      padding: 15px;
      flex: 1;
      overflow-y: auto;
      box-shadow: 0 6px 20px var(--shadow);
    }

    .previous-matches h3 {
      color: var(--pumpkin);
      font-size: 14px;
      margin-bottom: 12px;
      text-align: center;
      border-bottom: 2px solid var(--forest);
      padding-bottom: 8px;
      letter-spacing: 1px;
    }

    .prev-match-card {
      background: rgba(85, 139, 47, 0.1);
      border: 2px solid var(--forest);
      border-radius: 10px;
      padding: 10px;
      margin: 8px 0;
      display: flex;
      align-items: center;
      gap: 10px;
      animation: slideIn 0.5s ease-out;
    }

    .prev-avatars {
      display: flex;
      gap: 4px;
    }

    .prev-avatar {
      width: 40px;
      height: 40px;
      background: var(--moss);
      border: 2px solid var(--pumpkin);
      border-radius: 8px;
      overflow: hidden;
    }

    .prev-avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .prev-info {
      flex: 1;
      font-size: 11px;
    }

    .prev-names {
      font-weight: bold;
      color: var(--amber);
      margin-bottom: 3px;
    }

    .prev-score {
      font-size: 20px;
      color: var(--pumpkin);
      font-weight: bold;
    }

    /* Right Column - Superlatives & Former Matches */
    .right-column {
      display: flex;
      flex-direction: column;
      gap: 15px;
      overflow-y: auto;
    }

    /* Superlatives Panel */
    .superlatives-panel {
      background: var(--card-bg);
      border: 3px solid var(--pumpkin);
      border-radius: 15px;
      padding: 15px;
      box-shadow: 0 6px 20px var(--shadow);
      flex-shrink: 0;
    }

    .superlatives-panel h3 {
      color: var(--pumpkin);
      font-size: 14px;
      margin-bottom: 12px;
      text-align: center;
      border-bottom: 2px solid var(--pumpkin);
      padding-bottom: 8px;
      letter-spacing: 1px;
    }

    .superlative-item {
      margin: 10px 0;
      padding: 8px;
      background: rgba(156, 39, 176, 0.1);
      border-left: 3px solid var(--twilight);
      border-radius: 4px;
      font-size: 11px;
    }

    .superlative-title {
      color: var(--twilight);
      font-weight: bold;
      margin-bottom: 4px;
    }

    .superlative-value {
      color: var(--amber);
      font-weight: bold;
    }

    /* Match Distribution Chart */
    .distribution-chart {
      background: var(--card-bg);
      border: 2px solid var(--forest);
      border-radius: 12px;
      padding: 15px;
      margin-bottom: 15px;
    }

    .distribution-chart h3 {
      color: var(--pumpkin);
      font-size: 13px;
      margin-bottom: 10px;
      text-align: center;
    }

    .dist-bar {
      margin: 6px 0;
      font-size: 10px;
    }

    .dist-label {
      color: var(--cream);
      margin-bottom: 2px;
    }

    .dist-bar-bg {
      height: 12px;
      background: rgba(85, 139, 47, 0.2);
      border-radius: 6px;
      overflow: hidden;
      position: relative;
    }

    .dist-bar-fill {
      height: 100%;
      background: linear-gradient(90deg, var(--forest), var(--amber));
      transition: width 0.5s ease;
    }

    .dist-count {
      position: absolute;
      right: 5px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--cream);
      font-weight: bold;
      font-size: 9px;
    }

    /* Insights Carousel */
    .insights-carousel {
      background: rgba(156, 39, 176, 0.15);
      border: 2px solid var(--twilight);
      border-radius: 10px;
      padding: 12px 20px;
      text-align: center;
      font-size: 12px;
      color: var(--cream);
      min-height: 50px;
      display: flex;
      align-items: center;
      justify-content: center;
      animation: fadeIn 0.5s ease-in;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    .insight-emoji {
      font-size: 20px;
      margin-right: 10px;
    }

    /* Footer */
    .footer {
      background: rgba(0, 0, 0, 0.95);
      border-top: 3px solid var(--pumpkin);
      padding: 15px 20px;
      text-align: center;
      font-size: 12px;
      color: var(--cream);
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      z-index: 300;
    }

    .footer-message {
      margin-bottom: 10px;
      color: var(--amber);
    }

    .footer-buttons {
      display: flex;
      justify-content: center;
      gap: 15px;
    }

    .footer-btn {
      background: var(--pumpkin);
      color: var(--cream);
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.2s ease;
    }

    .footer-btn:hover {
      background: var(--amber);
      color: #000;
      transform: scale(1.05);
    }

    /* Toast Notifications */
    .toast-container {
      position: fixed;
      top: 80px;
      right: 20px;
      z-index: 400;
      display: flex;
      flex-direction: column;
      gap: 10px;
      max-width: 300px;
    }

    .toast {
      background: var(--card-bg);
      border: 2px solid var(--pumpkin);
      border-radius: 10px;
      padding: 12px;
      box-shadow: 0 4px 15px var(--shadow);
      animation: toastSlide 0.3s ease-out;
    }

    @keyframes toastSlide {
      from { transform: translateX(400px); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }

    .toast-icon {
      font-size: 20px;
      margin-right: 8px;
    }

    .toast-text {
      font-size: 11px;
      color: var(--cream);
    }

    /* Pixelated Fireworks Canvas */
    .fireworks-canvas {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: 1000;
    }

    /* Waiting Screen */
    .waiting-screen {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 60vh;
      text-align: center;
      padding: 40px;
    }

    .waiting-icon {
      font-size: 80px;
      margin-bottom: 20px;
      animation: bounce 2s ease-in-out infinite;
    }

    @keyframes bounce {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-20px); }
    }

    .waiting-message {
      font-size: 24px;
      color: var(--pumpkin);
      font-weight: bold;
      margin-bottom: 15px;
    }

    .waiting-count {
      font-size: 36px;
      color: var(--amber);
      font-weight: bold;
      margin: 10px 0;
    }

    .waiting-subtext {
      font-size: 14px;
      color: var(--cream);
      opacity: 0.8;
    }

    /* Scrollbar Styling */
    ::-webkit-scrollbar {
      width: 8px;
    }

    ::-webkit-scrollbar-track {
      background: rgba(0, 0, 0, 0.3);
    }

    ::-webkit-scrollbar-thumb {
      background: var(--pumpkin);
      border-radius: 4px;
    }

    ::-webkit-scrollbar-thumb:hover {
      background: var(--amber);
    }
  </style>
</head>
<body>
  <canvas class="fireworks-canvas" id="fireworksCanvas"></canvas>

  <!-- Live Stats Ticker -->
  <div class="ticker-container">
    <div class="ticker-content" id="tickerContent">
      Loading live stats...
    </div>
  </div>

  <!-- Header -->
  <div class="header">
    <h1>⚡ HALLOWEEN MATCH MAKER ⚡</h1>
    <div class="subtitle">// LIVE COMPATIBILITY ANALYTICS //</div>
  </div>

  <!-- Toast Container -->
  <div class="toast-container" id="toastContainer"></div>

  <!-- Main Container -->
  <div class="main-container" id="mainContainer">
    <!-- Left: Activity Stream -->
    <div class="activity-stream">
      <h3>RECENT ACTIVITY</h3>
      <div id="activityList"></div>
    </div>

    <!-- Center: Main Match + Distribution + Insights -->
    <div class="center-column">
      <!-- Main Match Stage -->
      <div class="main-match-stage" id="mainMatchStage">
        <!-- Content populated by JavaScript -->
      </div>

      <!-- Match Distribution -->
      <div class="distribution-chart">
        <h3>MATCH DISTRIBUTION</h3>
        <div id="distributionBars"></div>
      </div>

      <!-- Insights Carousel -->
      <div class="insights-carousel" id="insightsCarousel">
        <span class="insight-emoji">💡</span>
        <span id="insightText">Loading insights...</span>
      </div>
    </div>

    <!-- Right: Superlatives & Former Matches -->
    <div class="right-column">
      <!-- Superlatives Panel -->
      <div class="superlatives-panel">
        <h3>🏆 TONIGHT'S SUPERLATIVES</h3>
        <div id="superlativesList"></div>
      </div>

      <!-- Former Matches -->
      <div class="previous-matches">
        <h3>═══ FORMER MATCHES ═══</h3>
        <div id="previousMatchesList"></div>
      </div>
    </div>
  </div>

  <!-- Footer -->
  <div class="footer" id="footer">
    <div class="footer-message" id="footerMessage">
      🎃 Don't be shy, your match awaits! All matches based on shared interests, music, and various disparate patterns. New friends beware.
    </div>
    <div class="footer-buttons">
      <button class="footer-btn" onclick="showWhatWeUse()">What we use</button>
      <button class="footer-btn" onclick="dismissFooter()">Got it</button>
    </div>
  </div>

  <script>
    // ============================================================================
    // CONFIGURATION
    // ============================================================================
    
    const CONFIG = {
      AUTO_ADVANCE_MIN: 5000,  // 5 seconds
      AUTO_ADVANCE_MAX: 8000,  // 8 seconds
      REFRESH_INTERVAL: 30000, // 30 seconds - poll for new data
      INSIGHT_ROTATE: 10000,   // 10 seconds - rotate carousel
      TOAST_DURATION: 5000,    // 5 seconds
      MAX_TOASTS: 3
    };

    // Halloween copy bank
    const HALLOWEEN_TITLES = [
      "Spooktacular Match",
      "Ghoul-Compatible",
      "Witching-Hour Win",
      "Phantom Synergy",
      "Coffin-Fit Chemistry",
      "Pumpkin-Patch Pair",
      "Ectoplasmic Alignment",
      "Bewitched by Similarities"
    ];

    const HALLOWEEN_PHRASES = [
      "You're vibing on the same frequency—cue the séance of friendship.",
      "Shared tastes summoned this connection from the void.",
      "A cauldron of common ground is bubbling over.",
      "If this were a haunted house, you'd pick the same door.",
      "Your playlists howl in harmony.",
      "Two souls, one spellbook."
    ];

    const INSIGHTS_TEMPLATES = [
      { emoji: "💡", text: "Guests who like \"{TAG}\" have {LIFT}x more matches tonight" },
      { emoji: "🎭", text: "{FEATURE1} and {FEATURE2} show strong alignment (V={VALUE})" },
      { emoji: "🔥", text: "Hot tag: \"{TAG}\" appeared in {COUNT} top matches" },
      { emoji: "📊", text: "Tonight's strongest tie: {PAIR} (V={VALUE})" },
      { emoji: "⭐", text: "Party compatibility index: {PCT}% and rising!" }
    ];

    // ============================================================================
    // STATE
    // ============================================================================
    
    let state = {
      matches: [],
      currentMatchIndex: 0,
      previousMatches: [],
      analytics: null,
      autoAdvanceTimer: null,
      insightRotateTimer: null,
      refreshTimer: null,
      currentInsightIndex: 0,
      usedTitles: [],
      usedPhrases: [],
      isInitialized: false,
      minimumNotMet: false
    };

    // ============================================================================
    // INIT
    // ============================================================================
    
    window.addEventListener('load', function() {
      console.log('🎃 Halloween Matcher loading...');
      initFireworks();
      loadData();
      startRefreshCycle();
      startInsightRotation();
      checkFooterDismissed();
    });

    function loadData() {
      console.log('📡 Loading match data and analytics...');
      
      // Load matches
      google.script.run
        .withSuccessHandler(handleMatchData)
        .withFailureHandler(handleError)
        .getCompatibilityMatches();
      
      // Load analytics
      google.script.run
        .withSuccessHandler(handleAnalyticsData)
        .withFailureHandler(handleError)
        .getLiveAnalytics();
    }

    function handleMatchData(data) {
      console.log('✅ Matches loaded:', data);
      
      if (data.minimumNotMet) {
        state.minimumNotMet = true;
        showWaitingScreen(data.totalGuests);
        return;
      }
      
      if (data.error) {
        showError(data.error);
        return;
      }
      
      state.matches = data.matches || [];
      state.minimumNotMet = false;
      
      if (state.matches.length > 0 && !state.isInitialized) {
        state.isInitialized = true;
        startAutoAdvance();
        showCurrentMatch();
      }
    }

    function handleAnalyticsData(data) {
      console.log('✅ Analytics loaded:', data);
      
      if (data.minimumNotMet) {
        return; // Waiting for more guests
      }
      
      if (data.error) {
        console.error('Analytics error:', data.error);
        return;
      }
      
      state.analytics = data;
      updateAnalyticsDisplay();
    }

    function handleError(error) {
      console.error('❌ Error:', error);
      showToast('⚠️', 'Error loading data: ' + error.message);
    }

    // ============================================================================
    // WAITING SCREEN (< 15 guests)
    // ============================================================================
    
    function showWaitingScreen(currentCount) {
      const stage = document.getElementById('mainMatchStage');
      stage.innerHTML = `
        <div class="waiting-screen">
          <div class="waiting-icon">🎃</div>
          <div class="waiting-message">Summoning More Guests...</div>
          <div class="waiting-count">${currentCount} / 15</div>
          <div class="waiting-subtext">The party needs at least 15 checked-in guests to start matching.</div>
          <div class="waiting-subtext" style="margin-top: 20px;">Check-in at the front desk to join the fun!</div>
        </div>
      `;
    }

    function showError(message) {
      const stage = document.getElementById('mainMatchStage');
      stage.innerHTML = `
        <div class="waiting-screen">
          <div class="waiting-icon">⚠️</div>
          <div class="waiting-message">Oops!</div>
          <div class="waiting-subtext">${escapeHtml(message)}</div>
        </div>
      `;
    }

    // ============================================================================
    // MATCH DISPLAY
    // ============================================================================
    
    function showCurrentMatch() {
      if (state.matches.length === 0) return;
      
      const match = state.matches[state.currentMatchIndex];
      const stage = document.getElementById('mainMatchStage');
      
      const title = getRandomItem(HALLOWEEN_TITLES);
      const phrase = getRandomItem(HALLOWEEN_PHRASES);
      const displayScore = Math.round((match.similarity + 0.10) * 100);
      
      // Build shared interests HTML
      const sharedHtml = match.sharedInterests && match.sharedInterests.length > 0
        ? match.sharedInterests.map(int => `<span class="interest-tag">${escapeHtml(int)}</span>`).join('')
        : '<span class="interest-tag">Different paths, same vibe</span>';
      
      stage.innerHTML = `
        <div class="match-title">${title}</div>
        
        <div class="match-pair">
          <div class="match-person">
            <div class="match-avatar">
              ${match.person1.photoUrl 
                ? `<img src="${escapeHtml(match.person1.photoUrl)}" alt="${escapeHtml(match.person1.screenName)}">`
                : '<div class="match-avatar-placeholder">👤</div>'
              }
            </div>
            <div class="match-name">${escapeHtml(match.person1.screenName)}</div>
            <div class="match-details">
              ⭐ ${escapeHtml(match.person1.zodiac)}<br>
              🎵 ${escapeHtml(getMusicGenre(match.person1.music))}
            </div>
          </div>

          <div class="match-score-ring">
            <div class="score-percentage">${displayScore}%</div>
          </div>

          <div class="match-person">
            <div class="match-avatar">
              ${match.person2.photoUrl 
                ? `<img src="${escapeHtml(match.person2.photoUrl)}" alt="${escapeHtml(match.person2.screenName)}">`
                : '<div class="match-avatar-placeholder">👤</div>'
              }
            </div>
            <div class="match-name">${escapeHtml(match.person2.screenName)}</div>
            <div class="match-details">
              ⭐ ${escapeHtml(match.person2.zodiac)}<br>
              🎵 ${escapeHtml(getMusicGenre(match.person2.music))}
            </div>
          </div>
        </div>

        <div class="shared-interests-box">
          <div class="shared-label">✨ SHARED INTERESTS ✨</div>
          ${sharedHtml}
        </div>

        <div style="text-align: center; margin-top: 15px; font-size: 13px; color: var(--cream); font-style: italic;">
          ${phrase}
        </div>
      `;
      
      // Add to previous matches
      addToPreviousMatches(match, displayScore);
      
      // Trigger fireworks
      triggerFireworks();
    }

    function addToPreviousMatches(match, score) {
      state.previousMatches.unshift({ match, score });
      if (state.previousMatches.length > 20) {
        state.previousMatches = state.previousMatches.slice(0, 20);
      }
      
      const container = document.getElementById('previousMatchesList');
      container.innerHTML = state.previousMatches.map(pm => `
        <div class="prev-match-card">
          <div class="prev-avatars">
            <div class="prev-avatar">
              ${pm.match.person1.photoUrl 
                ? `<img src="${escapeHtml(pm.match.person1.photoUrl)}">`
                : '👤'
              }
            </div>
            <div class="prev-avatar">
              ${pm.match.person2.photoUrl 
                ? `<img src="${escapeHtml(pm.match.person2.photoUrl)}">`
                : '👤'
              }
            </div>
          </div>
          <div class="prev-info">
            <div class="prev-names">${escapeHtml(pm.match.person1.screenName)} ⭐ ${escapeHtml(pm.match.person2.screenName)}</div>
            <div style="font-size: 10px; color: var(--moss);">${pm.match.sharedInterests.length} shared</div>
          </div>
          <div class="prev-score">${pm.score}%</div>
        </div>
      `).join('');
    }

    // ============================================================================
    // AUTO-ADVANCE
    // ============================================================================
    
    function startAutoAdvance() {
      if (state.autoAdvanceTimer) {
        clearTimeout(state.autoAdvanceTimer);
      }
      
      const delay = CONFIG.AUTO_ADVANCE_MIN + Math.random() * (CONFIG.AUTO_ADVANCE_MAX - CONFIG.AUTO_ADVANCE_MIN);
      
      state.autoAdvanceTimer = setTimeout(() => {
        advanceToNextMatch();
        startAutoAdvance();
      }, delay);
    }

    function advanceToNextMatch() {
      if (state.matches.length === 0) return;
      
      state.currentMatchIndex = (state.currentMatchIndex + 1) % state.matches.length;
      showCurrentMatch();
    }

    // ============================================================================
    // ANALYTICS DISPLAY
    // ============================================================================
    
    function updateAnalyticsDisplay() {
      if (!state.analytics) return;

      updateTicker();
      updateActivityStream();
      updateSuperlatives();
      updateDistribution();
    }

    function updateTicker() {
      const a = state.analytics;
      const ticker = document.getElementById('tickerContent');

      const parts = [];
      parts.push(`LIVE: ${a.guestCount} guests checked in`);
      parts.push(`${a.partyStats?.totalPairs || 0} connections found`);
      if (a.partyStats?.topInterest) {
        parts.push(`Top interest: ${a.partyStats.topInterest.name} (${a.partyStats.topInterest.pct}%)`);
      }
      parts.push(`Party avg: ${a.partyStats?.avgCompatibility || 0}%`);
      if (a.tagLifts && a.tagLifts.length > 0) {
        parts.push(`Hot combo: ${a.tagLifts[0].pair} (${a.tagLifts[0].count} matches)`);
      }

      ticker.textContent = parts.join(' • ') + ' • ';
    }

    function updateActivityStream() {
      const list = document.getElementById('activityList');
      const activity = state.analytics?.activity || [];
      
      list.innerHTML = activity.map(item => {
        const timeAgo = item.timeAgo < 60 
          ? item.timeAgo + 's'
          : Math.floor(item.timeAgo / 60) + 'm';
        
        return `
          <div class="activity-item">
            🎃 <strong>${escapeHtml(item.screenName)}</strong> ${item.action}
            <div class="activity-time">${timeAgo} ago</div>
          </div>
        `;
      }).join('');
    }

    function updateSuperlatives() {
      const list = document.getElementById('superlativesList');
      const sup = state.analytics?.superlatives || {};
      
      const items = [];
      
      if (sup.mostCompatible) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">👑 Most Compatible</div>
            <div class="superlative-value">${escapeHtml(sup.mostCompatible.name1)} & ${escapeHtml(sup.mostCompatible.name2)} — ${sup.mostCompatible.score}%</div>
          </div>
        `);
      }
      
      if (sup.mostDifferent) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">💀 Most Different</div>
            <div class="superlative-value">${escapeHtml(sup.mostDifferent.name1)} & ${escapeHtml(sup.mostDifferent.name2)} — ${sup.mostDifferent.score}%</div>
          </div>
        `);
      }
      
      if (sup.rarestOverlap) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">✨ Rarest Overlap</div>
            <div class="superlative-value">${escapeHtml(sup.rarestOverlap.pair[0])} & ${escapeHtml(sup.rarestOverlap.pair[1])} — ${escapeHtml(sup.rarestOverlap.interest)}</div>
          </div>
        `);
      }
      
      if (sup.broadestAppeal) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">📊 Broadest Appeal</div>
            <div class="superlative-value">${escapeHtml(sup.broadestAppeal.name)} — ${sup.broadestAppeal.count} potential matches</div>
          </div>
        `);
      }
      
      list.innerHTML = items.join('');
    }

    function updateDistribution() {
      const bars = document.getElementById('distributionBars');
      const dist = state.analytics?.partyStats?.distribution || [];
      
      const max = Math.max(...dist.map(d => d.count), 1);
      
      bars.innerHTML = dist.map(d => `
        <div class="dist-bar">
          <div class="dist-label">${d.range}</div>
          <div class="dist-bar-bg">
            <div class="dist-bar-fill" style="width: ${(d.count / max * 100)}%"></div>
            <div class="dist-count">${d.count}</div>
          </div>
        </div>
      `).join('');
    }


    // ============================================================================
    // INSIGHTS CAROUSEL
    // ============================================================================
    
    function startInsightRotation() {
      rotateInsight();
      state.insightRotateTimer = setInterval(rotateInsight, CONFIG.INSIGHT_ROTATE);
    }

    function rotateInsight() {
      if (!state.analytics) return;
      
      const insights = [];
      const a = state.analytics;
      
      // Build insights from data
      if (a.tagLifts && a.tagLifts.length > 0) {
        const lift = a.tagLifts[0];
        insights.push({
          emoji: "🔥",
          text: `Hot tag: "${lift.pair}" appeared in ${lift.count} matches`
        });
      }
      
      if (a.cramersV?.strongest) {
        insights.push({
          emoji: "📊",
          text: `Tonight's strongest tie: ${a.cramersV.strongest.name} (V=${a.cramersV.strongest.v.toFixed(2)})`
        });
      }
      
      if (a.partyStats?.avgCompatibility) {
        insights.push({
          emoji: "⭐",
          text: `Party compatibility index: ${a.partyStats.avgCompatibility}% and rising!`
        });
      }
      
      if (a.partyStats?.topInterest) {
        insights.push({
          emoji: "💡",
          text: `Guests who like "${a.partyStats.topInterest.name}" are everywhere tonight (${a.partyStats.topInterest.pct}%)`
        });
      }
      
      if (insights.length === 0) {
        insights.push({ emoji: "🎃", text: "The algorithms are watching... making matches in real time!" });
      }
      
      const insight = insights[state.currentInsightIndex % insights.length];
      state.currentInsightIndex++;
      
      const container = document.getElementById('insightsCarousel');
      container.style.opacity = 0;
      
      setTimeout(() => {
        document.getElementById('insightText').textContent = insight.text;
        container.querySelector('.insight-emoji').textContent = insight.emoji;
        container.style.opacity = 1;
      }, 300);
    }

    // ============================================================================
    // PERIODIC REFRESH
    // ============================================================================
    
    function startRefreshCycle() {
      state.refreshTimer = setInterval(() => {
        console.log('🔄 Refreshing data...');
        loadData();
      }, CONFIG.REFRESH_INTERVAL);
    }

    // ============================================================================
    // TOASTS
    // ============================================================================
    
    function showToast(icon, text) {
      const container = document.getElementById('toastContainer');
      const toast = document.createElement('div');
      toast.className = 'toast';
      toast.innerHTML = `<span class="toast-icon">${icon}</span><span class="toast-text">${escapeHtml(text)}</span>`;
      
      container.appendChild(toast);
      
      // Limit to max toasts
      while (container.children.length > CONFIG.MAX_TOASTS) {
        container.removeChild(container.firstChild);
      }
      
      setTimeout(() => {
        if (toast.parentNode) {
          toast.style.opacity = 0;
          setTimeout(() => toast.remove(), 300);
        }
      }, CONFIG.TOAST_DURATION);
    }

    // ============================================================================
    // PIXELATED FIREWORKS
    // ============================================================================
    
    const fireworksCanvas = document.getElementById('fireworksCanvas');
    const fireworksCtx = fireworksCanvas.getContext('2d');
    let fireworks = [];

    function initFireworks() {
      fireworksCanvas.width = window.innerWidth;
      fireworksCanvas.height = window.innerHeight;
      animateFireworks();
    }

    function triggerFireworks() {
      for (let i = 0; i < 8; i++) {
        setTimeout(() => createPixelatedFirework(), i * 150);
      }
    }

    function createPixelatedFirework() {
      const x = Math.random() * fireworksCanvas.width;
      const y = Math.random() * (fireworksCanvas.height * 0.6);
      const particles = [];
      
      const colors = ['#FF6F00', '#FFB74D', '#9C27B0', '#558B2F'];
      const color = colors[Math.floor(Math.random() * colors.length)];
      
      for (let i = 0; i < 20; i++) {
        particles.push({
          x: x,
          y: y,
          vx: (Math.random() - 0.5) * 6,
          vy: (Math.random() - 0.5) * 6,
          life: 40,
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
            // Pixelated rendering - 8x8 blocks
            const blockSize = 8;
            const drawX = Math.floor(p.x / blockSize) * blockSize;
            const drawY = Math.floor(p.y / blockSize) * blockSize;
            
            fireworksCtx.fillStyle = p.color;
            fireworksCtx.fillRect(drawX, drawY, blockSize, blockSize);
            
            p.x += p.vx;
            p.y += p.vy;
            p.vy += 0.2; // gravity
            p.life--;
          }
        });
      });
      
      requestAnimationFrame(animateFireworks);
    }

    // ============================================================================
    // HELPERS
    // ============================================================================
    
    const MUSIC_GENRES = {
      '1': 'Hip-hop', '2': 'Pop', '3': 'Indie/Alt', '4': 'R&B',
      '5': 'Rock', '6': 'Country', '7': 'Electronic', '8': 'Prog Rock'
    };

    function getMusicGenre(code) {
      return MUSIC_GENRES[String(code)] || code || '---';
    }

    function escapeHtml(text) {
      const div = document.createElement('div');
      div.textContent = text || '';
      return div.innerHTML;
    }

    function getRandomItem(arr) {
      if (arr.length === 0) return '';
      return arr[Math.floor(Math.random() * arr.length)];
    }

    // ============================================================================
    // FOOTER
    // ============================================================================
    
    function checkFooterDismissed() {
      if (localStorage.getItem('mm_footer_dismissed') === 'true') {
        document.getElementById('footer').style.display = 'none';
      }
    }

    function dismissFooter() {
      localStorage.setItem('mm_footer_dismissed', 'true');
      document.getElementById('footer').style.display = 'none';
    }

    function showWhatWeUse() {
      alert('We use your checked-in data including:\\n\\n• Interests (top 3)\\n• Music preferences\\n• Zodiac sign\\n• Age range\\n• Education & industry\\n• Social stance\\n\\nWe DO NOT use gender, ethnicity, or sexual orientation for matching.\\n\\nAll data stays within this event and is never shared.');
    }
  </script>
</body>
</html>
