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

    /* Previous Matches Ticker (Bottom) */
    .ticker-container {
      background: rgba(0, 0, 0, 0.9);
      border-top: 2px solid var(--pumpkin);
      padding: 8px 0;
      overflow: hidden;
      position: fixed;
      bottom: 100px;
      left: 0;
      right: 0;
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
      height: calc(100vh - 270px);
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

    /* Match Cards Container */
    .match-cards-container {
      background: var(--card-bg);
      border: 2px solid var(--forest);
      border-radius: 12px;
      padding: 15px;
      flex: 1;
      overflow: hidden;
      position: relative;
    }

    .match-cards-container h3 {
      color: var(--pumpkin);
      font-size: 13px;
      margin-bottom: 10px;
      text-align: center;
    }

    .match-cards-grid {
      display: flex;
      flex-direction: column;
      gap: 20px;
      overflow-y: auto;
      max-height: 100%;
      scroll-behavior: smooth;
      scrollbar-width: none; /* Firefox */
      -ms-overflow-style: none; /* IE/Edge */
    }

    .match-cards-grid::-webkit-scrollbar {
      display: none; /* Chrome/Safari */
    }

    .matches-row {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 15px;
    }

    /* Responsive design */
    @media (max-width: 1400px) {
      .matches-row {
        grid-template-columns: repeat(4, 1fr);
      }
    }

    @media (max-width: 900px) {
      .matches-row {
        grid-template-columns: repeat(3, 1fr);
      }
    }

    @media (max-width: 600px) {
      .matches-row {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    .match-card {
      background: rgba(85, 139, 47, 0.1);
      border: 2px solid var(--forest);
      border-radius: 8px;
      padding: 8px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
      animation: fadeIn 0.3s ease-out;
      cursor: pointer;
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .match-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(255, 111, 0, 0.3);
      border-color: var(--pumpkin);
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: scale(0.9); }
      to { opacity: 1; transform: scale(1); }
    }

    .match-card-avatars {
      display: flex;
      gap: 4px;
    }

    .match-card-avatar {
      width: 45px;
      height: 45px;
      background: var(--moss);
      border: 2px solid var(--pumpkin);
      border-radius: 6px;
      overflow: hidden;
    }

    .match-card-avatar img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .match-card-score {
      font-size: 16px;
      color: var(--amber);
      font-weight: bold;
    }

    .match-card-names {
      font-size: 9px;
      color: var(--cream);
      text-align: center;
      line-height: 1.2;
    }

    .match-card-interests {
      display: flex;
      gap: 4px;
      justify-content: center;
      flex-wrap: wrap;
      margin-top: 4px;
    }

    .match-card-interest-tag {
      background: rgba(156, 39, 176, 0.2);
      color: var(--twilight);
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 8px;
      border: 1px solid var(--twilight);
      font-weight: bold;
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

    /* Calculating Animation Overlay */
    .calculating-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: var(--card-bg);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      z-index: 100;
      border-radius: 20px;
    }

    .calculating-spinner {
      width: 80px;
      height: 80px;
      border: 8px solid rgba(255, 111, 0, 0.2);
      border-top: 8px solid var(--pumpkin);
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-bottom: 20px;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    .calculating-text {
      font-size: 24px;
      color: var(--pumpkin);
      font-weight: bold;
      margin-bottom: 10px;
      animation: pulse 1.5s ease-in-out infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }

    .calculating-dots {
      font-size: 24px;
      color: var(--amber);
      letter-spacing: 4px;
    }

    .calculating-percentage {
      font-size: 48px;
      color: var(--amber);
      font-weight: bold;
      margin-top: 15px;
      text-shadow: 0 0 20px var(--glow);
    }

    .calculating-status {
      font-size: 14px;
      color: var(--cream);
      margin-top: 10px;
      opacity: 0.8;
      font-style: italic;
    }
  </style>
</head>
<body>
  <canvas class="fireworks-canvas" id="fireworksCanvas"></canvas>

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

    <!-- Center: Main Match + Featured Matches -->
    <div class="center-column">
      <!-- Main Match Stage -->
      <div class="main-match-stage" id="mainMatchStage">
        <!-- Content populated by JavaScript -->
      </div>

      <!-- Match Cards Grid -->
      <div class="match-cards-container">
        <h3>FEATURED MATCHES</h3>
        <div class="match-cards-grid" id="matchCardsGrid">
          <!-- Populated by JavaScript -->
        </div>
      </div>
    </div>

    <!-- Right: Superlatives & Match Distribution -->
    <div class="right-column">
      <!-- Superlatives Panel -->
      <div class="superlatives-panel">
        <h3>🏆 TONIGHT'S SUPERLATIVES</h3>
        <div id="superlativesList"></div>
      </div>

      <!-- Match Distribution -->
      <div class="distribution-chart">
        <h3>MATCH DISTRIBUTION</h3>
        <div id="distributionBars"></div>
      </div>
    </div>
  </div>

  <!-- Previous Matches Ticker (Bottom) -->
  <div class="ticker-container">
    <div class="ticker-content" id="tickerContent">
      Loading previous matches...
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

    // ============================================================================
    // STATE
    // ============================================================================
    
    let state = {
      matches: [],
      currentMatchIndex: 0,
      previousMatches: [],
      analytics: null,
      autoAdvanceTimer: null,
      refreshTimer: null,
      autoScrollTimer: null,
      currentScrollRow: 0,
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

      if (state.matches.length > 0) {
        // Update match cards display
        updateMatchCards();

        if (!state.isInitialized) {
          state.isInitialized = true;
          startAutoAdvance();
          startFeaturedMatchesAutoScroll();
          showCurrentMatch();
        }
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
      const displayScore = Math.round((match.similarity + 0.10) * 100);

      // Show calculating animation first
      showCalculatingAnimation(stage, displayScore, () => {
        // After animation completes, show the actual match
        revealMatch(match, stage, displayScore);
      });
    }

    function showCalculatingAnimation(stage, finalScore, callback) {
      // Display calculating overlay
      stage.innerHTML = `
        <div class="calculating-overlay">
          <div class="calculating-spinner"></div>
          <div class="calculating-text">CALCULATING COMPATIBILITY</div>
          <div class="calculating-dots">• • •</div>
          <div class="calculating-percentage" id="calculatingPercentage">0%</div>
          <div class="calculating-status" id="calculatingStatus">Analyzing shared interests...</div>
        </div>
      `;

      const percentageEl = document.getElementById('calculatingPercentage');
      const statusEl = document.getElementById('calculatingStatus');

      const statuses = [
        'Analyzing shared interests...',
        'Comparing music preferences...',
        'Checking zodiac compatibility...',
        'Calculating final score...'
      ];

      let currentPercent = 0;
      let statusIndex = 0;
      const duration = 2500; // 2.5 seconds
      const interval = 30; // Update every 30ms
      const increment = finalScore / (duration / interval);

      const timer = setInterval(() => {
        currentPercent += increment;

        if (currentPercent >= finalScore) {
          currentPercent = finalScore;
          clearInterval(timer);

          // Wait a moment then call callback
          setTimeout(() => {
            callback();
          }, 300);
        }

        percentageEl.textContent = Math.round(currentPercent) + '%';

        // Update status message every 25%
        const statusProgressIndex = Math.floor((currentPercent / finalScore) * statuses.length);
        if (statusProgressIndex !== statusIndex && statusProgressIndex < statuses.length) {
          statusIndex = statusProgressIndex;
          statusEl.textContent = statuses[statusIndex];
        }
      }, interval);
    }

    function revealMatch(match, stage, displayScore) {
      const title = getRandomItem(HALLOWEEN_TITLES);
      const phrase = getRandomItem(HALLOWEEN_PHRASES);
      
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
      
      // Add to previous matches for ticker
      addToPreviousMatches(match, displayScore);

      // Trigger fireworks
      triggerFireworks();
    }

    function addToPreviousMatches(match, score) {
      // Track previous matches for ticker display
      state.previousMatches.unshift({ match, score });
      if (state.previousMatches.length > 20) {
        state.previousMatches = state.previousMatches.slice(0, 20);
      }

      // Update ticker with new previous matches
      updateTicker();
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
    // FEATURED MATCHES AUTO-SCROLL
    // ============================================================================

    function startFeaturedMatchesAutoScroll() {
      if (state.autoScrollTimer) {
        clearInterval(state.autoScrollTimer);
      }

      // Auto-scroll every 3 seconds
      state.autoScrollTimer = setInterval(() => {
        scrollFeaturedMatches();
      }, 3000);
    }

    function scrollFeaturedMatches() {
      const grid = document.getElementById('matchCardsGrid');
      if (!grid) return;

      const rows = grid.querySelectorAll('.matches-row');
      if (rows.length === 0) return;

      // Move to next row (cycle through 0, 1, 2)
      state.currentScrollRow = (state.currentScrollRow + 1) % rows.length;

      // Scroll to the current row
      const targetRow = rows[state.currentScrollRow];
      if (targetRow) {
        targetRow.scrollIntoView({
          behavior: 'smooth',
          block: 'nearest',
          inline: 'start'
        });
      }
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
      const ticker = document.getElementById('tickerContent');

      if (state.previousMatches.length === 0) {
        ticker.textContent = 'Waiting for matches to appear... • ';
        return;
      }

      // Take last 10 previous matches
      const recentMatches = state.previousMatches.slice(0, 10);
      const parts = [];

      recentMatches.forEach(pm => {
        const names = `${pm.match.person1.screenName} ⭐ ${pm.match.person2.screenName}`;
        const score = `${pm.score}%`;
        parts.push(`${names} (${score})`);
      });

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

      // 1. BEST OVERALL MATCH
      if (sup.bestOverallMatch) {
        const title = getRandomItem(HALLOWEEN_TITLES);
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">👑 Best Overall Match</div>
            <div class="superlative-value">${title} — @${escapeHtml(sup.bestOverallMatch.name1)} & @${escapeHtml(sup.bestOverallMatch.name2)} are a spooktacular ${sup.bestOverallMatch.score}% match!</div>
          </div>
        `);
      }

      // 2. MOST POPULAR GUEST
      if (sup.mostPopularGuest) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">🌟 Most Popular Guest</div>
            <div class="superlative-value">@${escapeHtml(sup.mostPopularGuest.name)} appears in ${sup.mostPopularGuest.count} different pairings — bewitched by everyone!</div>
          </div>
        `);
      }

      // 3. MOST SHARED INTEREST
      if (sup.mostSharedInterest) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">💡 Most Shared Interest</div>
            <div class="superlative-value">"${escapeHtml(sup.mostSharedInterest.interest)}" haunts ${sup.mostSharedInterest.pct}% of guests — a true phantom favorite!</div>
          </div>
        `);
      }

      // 4. STRONGEST COHORT LINK
      if (sup.strongestCohortLink) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">🔗 Strongest Cohort Link</div>
            <div class="superlative-value">${escapeHtml(sup.strongestCohortLink.name)} shows eerie alignment (V=${sup.strongestCohortLink.v.toFixed(2)}) — the patterns are real!</div>
          </div>
        `);
      }

      // 5. MOST UNLIKELY CONNECTION
      if (sup.mostUnlikelyConnection) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">🌙 Most Unlikely Connection</div>
            <div class="superlative-value">@${escapeHtml(sup.mostUnlikelyConnection.name1)} & @${escapeHtml(sup.mostUnlikelyConnection.name2)} defy the odds — ${sup.mostUnlikelyConnection.score}% match despite ${sup.mostUnlikelyConnection.differences} differences!</div>
          </div>
        `);
      }

      // 6. FASTEST NEW CONNECTION
      if (sup.fastestNewConnection) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">⚡ Fastest New Connection</div>
            <div class="superlative-value">@${escapeHtml(sup.fastestNewConnection.name1)} & @${escapeHtml(sup.fastestNewConnection.name2)} just checked in — instant ${sup.fastestNewConnection.score}% chemistry!</div>
          </div>
        `);
      }

      // 7. ANALYTICAL ODDITY
      if (sup.analyticalOddity) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">🎭 Analytical Oddity</div>
            <div class="superlative-value">@${escapeHtml(sup.analyticalOddity.name1)} & @${escapeHtml(sup.analyticalOddity.name2)} share ${sup.analyticalOddity.sharedCount} interests but only ${sup.analyticalOddity.score}% match — mysterious!</div>
          </div>
        `);
      }

      // 8. SOCIAL BUTTERFLY
      if (sup.socialButterfly) {
        items.push(`
          <div class="superlative-item">
            <div class="superlative-title">🦋 Social Butterfly</div>
            <div class="superlative-value">@${escapeHtml(sup.socialButterfly.name)} bridges the party — ${sup.socialButterfly.avgScore}% avg compatibility with ${sup.socialButterfly.connections} strong connections!</div>
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

    function updateMatchCards() {
      const grid = document.getElementById('matchCardsGrid');

      if (state.matches.length === 0) {
        grid.innerHTML = '<div style="text-align: center; padding: 20px; color: var(--moss);">No matches available yet...</div>';
        return;
      }

      // Show top 18 matches (or fewer if not enough), organized in 3 rows of 6
      const topMatches = state.matches.slice(0, 18);
      const rowSize = 6;
      let html = '';

      // Create 3 rows
      for (let i = 0; i < topMatches.length; i += rowSize) {
        const rowMatches = topMatches.slice(i, i + rowSize);

        html += '<div class="matches-row">';

        rowMatches.forEach(match => {
          const displayScore = Math.round((match.similarity + 0.10) * 100);

          // Get shared interests (limit to 2 for display)
          const sharedInterests = match.sharedInterests || [];
          const displayInterests = sharedInterests.slice(0, 2);
          const interestHtml = displayInterests.length > 0
            ? displayInterests.map(int => `<span class="match-card-interest-tag">${escapeHtml(int)}</span>`).join('')
            : '<span class="match-card-interest-tag">Different vibes</span>';

          html += `
            <div class="match-card">
              <div class="match-card-avatars">
                <div class="match-card-avatar">
                  ${match.person1.photoUrl
                    ? `<img src="${escapeHtml(match.person1.photoUrl)}" alt="${escapeHtml(match.person1.screenName)}">`
                    : '👤'
                  }
                </div>
                <div class="match-card-avatar">
                  ${match.person2.photoUrl
                    ? `<img src="${escapeHtml(match.person2.photoUrl)}" alt="${escapeHtml(match.person2.screenName)}">`
                    : '👤'
                  }
                </div>
              </div>
              <div class="match-card-score">${displayScore}%</div>
              <div class="match-card-names">${escapeHtml(match.person1.screenName)} & ${escapeHtml(match.person2.screenName)}</div>
              <div class="match-card-interests">
                ${interestHtml}
              </div>
            </div>
          `;
        });

        html += '</div>';
      }

      grid.innerHTML = html;
    }


    // ============================================================================
    // MATCH CARDS & TICKER
    // ============================================================================

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
