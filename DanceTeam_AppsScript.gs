/**
 * ============================================================================
 * DANCE TEAM SYSTEM - APPS SCRIPT INTEGRATION
 * ============================================================================
 * 
 * Enhanced pyramid matchmaking for dance teams with:
 * - Auto-generated team names based on collective traits
 * - Photo URL support (Abby Lee placeholder)
 * - Genre mixing for diversity
 * - People can repeat across teams (not as focal twice)
 * 
 * USAGE:
 * 1. Copy this entire code block
 * 2. Paste at the bottom of your Code.gs file
 * 3. Call generateDanceTeams(count) to create teams
 * 4. Call buildSingleDanceTeam(uid) for specific guest
 * 
 * ============================================================================
 */

// Configuration for column indices (adjust to match your sheet)
const DANCE_CONFIG = {
  COL: {
    SCREEN_NAME: 24,  // Column 25 (0-indexed: 24)
    UID: 25,          // Column 26
    CHECKED_IN: 27,   // Column 28
    PHOTO_URL: 29,    // Column 30
    AGE: 3,           // Column 4
    INTEREST_1: 15,   // Column 16
    INTEREST_2: 16,   // Column 17
    INTEREST_3: 17,   // Column 18
    MUSIC: 18,        // Column 19
    INDUSTRY: 7,      // Column 8
    ROLE: 8,          // Column 9
    ZODIAC: 19,       // Column 20
    EDUCATION: 3,     // Column 4
    SOCIAL: 18        // Column 19
  },
  // Abby Lee Miller placeholder image
  ABBY_PLACEHOLDER: "https://media.giphy.com/media/l0HlUJZE8Uo1cSlUI/giphy.gif",
  
  // Sheet name
  SHEET_NAME: "FRC" // Update to your sheet name
};

/**
 * Generate multiple dance teams with auto-naming and diversity
 * 
 * @param {number} count - Number of teams to generate (default: 15)
 * @param {boolean} allowRepeat - Allow guests to appear in multiple teams (default: true)
 * @returns {Array} Array of dance team objects
 */
function generateDanceTeams(count = 15, allowRepeat = true) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(DANCE_CONFIG.SHEET_NAME);
  const data = sheet.getDataRange().getValues();
  
  // Get all checked-in guests
  const checkedIn = [];
  for (let i = 1; i < data.length; i++) {
    if (String(data[i][DANCE_CONFIG.COL.CHECKED_IN]).trim().toUpperCase() === 'Y') {
      checkedIn.push({
        uid: data[i][DANCE_CONFIG.COL.UID],
        screenName: data[i][DANCE_CONFIG.COL.SCREEN_NAME],
        music: data[i][DANCE_CONFIG.COL.MUSIC],
        photoUrl: data[i][DANCE_CONFIG.COL.PHOTO_URL] || DANCE_CONFIG.ABBY_PLACEHOLDER
      });
    }
  }
  
  if (checkedIn.length < 6) {
    return [{ok: false, message: 'Need at least 6 checked-in guests for dance teams'}];
  }
  
  const teams = [];
  const usedFocals = new Set();
  
  // Shuffle guests for randomness
  const shuffled = checkedIn.sort(() => Math.random() - 0.5);
  
  for (let i = 0; i < Math.min(count, checkedIn.length); i++) {
    // Pick focal guest (not used before)
    let focal = null;
    for (let g of shuffled) {
      if (!usedFocals.has(g.uid)) {
        focal = g;
        usedFocals.add(g.uid);
        break;
      }
    }
    
    if (!focal) break; // No more unique focals
    
    // Build pyramid for this focal
    const pyramid = buildDanceTeamPyramid_(data, focal.uid, allowRepeat);
    
    if (pyramid.ok) {
      // Generate team name based on collective traits
      const teamName = generateTeamName_(pyramid, data);
      
      // Add dance team specific fields
      pyramid.teamName = teamName;
      pyramid.teamNumber = i + 1;
      pyramid.abbyPhoto = DANCE_CONFIG.ABBY_PLACEHOLDER;
      
      teams.push(pyramid);
    }
  }
  
  return teams;
}

/**
 * Build a single dance team pyramid for a specific guest
 * 
 * @param {string} guestUID - The UID of the focal guest
 * @param {boolean} forceDiverse - Mix genres for diversity (default: true)
 * @returns {Object} Dance team structure with auto-generated name
 */
function buildSingleDanceTeam(guestUID, forceDiverse = true) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(DANCE_CONFIG.SHEET_NAME);
  const data = sheet.getDataRange().getValues();
  
  const pyramid = buildDanceTeamPyramid_(data, guestUID, forceDiverse);
  
  if (pyramid.ok) {
    pyramid.teamName = generateTeamName_(pyramid, data);
    pyramid.abbyPhoto = DANCE_CONFIG.ABBY_PLACEHOLDER;
  }
  
  return pyramid;
}

/**
 * Build pyramid structure for dance team (internal)
 * @private
 */
function buildDanceTeamPyramid_(data, focalUID, mixGenres = true) {
  // Find focal guest
  let focalIdx = -1;
  for (let i = 1; i < data.length; i++) {
    if (String(data[i][DANCE_CONFIG.COL.UID]).trim() === focalUID) {
      focalIdx = i;
      break;
    }
  }
  
  if (focalIdx === -1) {
    return {ok: false, message: 'Guest not found'};
  }
  
  // Calculate similarities
  const similarities = [];
  for (let i = 1; i < data.length; i++) {
    if (i === focalIdx) continue;
    if (String(data[i][DANCE_CONFIG.COL.CHECKED_IN]).trim().toUpperCase() !== 'Y') continue;
    
    const sim = calculateDanceSimilarity_(data[focalIdx], data[i], mixGenres);
    similarities.push({
      idx: i,
      uid: data[i][DANCE_CONFIG.COL.UID],
      screenName: data[i][DANCE_CONFIG.COL.SCREEN_NAME],
      similarity: sim,
      music: data[i][DANCE_CONFIG.COL.MUSIC],
      photoUrl: data[i][DANCE_CONFIG.COL.PHOTO_URL] || DANCE_CONFIG.ABBY_PLACEHOLDER
    });
  }
  
  // Sort by similarity
  similarities.sort((a, b) => b.similarity - a.similarity);
  
  if (similarities.length < 5) {
    return {ok: false, message: 'Not enough guests for pyramid'};
  }
  
  // Row 2: Top 2 closest (but mix genres if enabled)
  let row2 = [];
  if (mixGenres) {
    row2 = selectDiverseGenres_(similarities.slice(0, 10), 2, data[focalIdx][DANCE_CONFIG.COL.MUSIC]);
  } else {
    row2 = [similarities[0], similarities[1]];
  }
  
  // Row 3: Diverse matches (wild cards)
  const remaining = similarities.filter(g => !row2.find(r => r.uid === g.uid));
  const row3 = selectDiverseGenres_(remaining, 3, data[focalIdx][DANCE_CONFIG.COL.MUSIC]);
  
  // Build pyramid structure
  const focalRow = data[focalIdx];
  const pyramid = {
    ok: true,
    focal: {
      uid: focalRow[DANCE_CONFIG.COL.UID],
      screenName: focalRow[DANCE_CONFIG.COL.SCREEN_NAME],
      interests: [
        focalRow[DANCE_CONFIG.COL.INTEREST_1],
        focalRow[DANCE_CONFIG.COL.INTEREST_2],
        focalRow[DANCE_CONFIG.COL.INTEREST_3]
      ].filter(i => i),
      music: focalRow[DANCE_CONFIG.COL.MUSIC] || 'Various',
      age: focalRow[DANCE_CONFIG.COL.AGE],
      photoUrl: focalRow[DANCE_CONFIG.COL.PHOTO_URL] || DANCE_CONFIG.ABBY_PLACEHOLDER
    },
    row2: row2.map(g => ({
      uid: g.uid,
      screenName: g.screenName,
      similarity: Math.round(g.similarity * 10000) / 10000,
      music: g.music,
      photoUrl: g.photoUrl
    })),
    row3: row3.map(g => ({
      uid: g.uid,
      screenName: g.screenName,
      similarity: Math.round(g.similarity * 10000) / 10000,
      music: g.music,
      photoUrl: g.photoUrl
    })),
    stats: {
      avgSimilarity: Math.round(
        ([...row2, ...row3].reduce((sum, g) => sum + g.similarity, 0) / 5) * 10000
      ) / 10000,
      topMatch: Math.round(Math.max(...row2.map(g => g.similarity)) * 10000) / 10000,
      genreMix: getGenreCount_([focalRow, ...row2.map(g => data[g.idx]), ...row3.map(g => data[g.idx])])
    }
  };
  
  return pyramid;
}

/**
 * Select guests with diverse music genres
 * @private
 */
function selectDiverseGenres_(guests, count, focalGenre) {
  const selected = [];
  const usedGenres = new Set([focalGenre]);
  
  // First pass: pick different genres
  for (let g of guests) {
    if (selected.length >= count) break;
    if (g.music && !usedGenres.has(g.music)) {
      selected.push(g);
      usedGenres.add(g.music);
    }
  }
  
  // Second pass: fill remaining with best matches
  for (let g of guests) {
    if (selected.length >= count) break;
    if (!selected.find(s => s.uid === g.uid)) {
      selected.push(g);
    }
  }
  
  return selected.slice(0, count);
}

/**
 * Count unique genres in team
 * @private
 */
function getGenreCount_(teamMembers) {
  const genres = new Set();
  teamMembers.forEach(m => {
    const music = m[DANCE_CONFIG.COL.MUSIC];
    if (music && music.trim()) genres.add(music);
  });
  return genres.size;
}

/**
 * Calculate similarity with genre diversity bonus
 * @private
 */
function calculateDanceSimilarity_(guestA, guestB, mixGenres = true) {
  let matches = 0;
  let comparisons = 0;
  
  // Interest overlap (high weight)
  const interestsA = [
    guestA[DANCE_CONFIG.COL.INTEREST_1],
    guestA[DANCE_CONFIG.COL.INTEREST_2],
    guestA[DANCE_CONFIG.COL.INTEREST_3]
  ].filter(i => i);
  
  const interestsB = [
    guestB[DANCE_CONFIG.COL.INTEREST_1],
    guestB[DANCE_CONFIG.COL.INTEREST_2],
    guestB[DANCE_CONFIG.COL.INTEREST_3]
  ].filter(i => i);
  
  interestsA.forEach(intA => {
    if (interestsB.includes(intA)) {
      matches += 2; // High weight for shared interests
    }
  });
  comparisons += 6; // Max possible interest matches
  
  // Age range
  if (guestA[DANCE_CONFIG.COL.AGE] && guestB[DANCE_CONFIG.COL.AGE]) {
    comparisons++;
    if (guestA[DANCE_CONFIG.COL.AGE] === guestB[DANCE_CONFIG.COL.AGE]) matches++;
  }
  
  // Music preference (lower weight if mixGenres enabled)
  if (guestA[DANCE_CONFIG.COL.MUSIC] && guestB[DANCE_CONFIG.COL.MUSIC]) {
    comparisons++;
    if (guestA[DANCE_CONFIG.COL.MUSIC] === guestB[DANCE_CONFIG.COL.MUSIC]) {
      matches += mixGenres ? 0.5 : 1; // Reduce weight for same genre if mixing
    } else if (mixGenres) {
      matches += 0.3; // Small bonus for different genres when mixing
    }
  }
  
  return comparisons > 0 ? matches / comparisons : 0;
}

/**
 * Generate creative team name based on collective traits
 * @private
 */
function generateTeamName_(pyramid, data) {
  // Collect all team members
  const allMembers = [
    pyramid.focal,
    ...pyramid.row2,
    ...pyramid.row3
  ];
  
  // Analyze collective traits
  const musicGenres = new Set();
  const ageRanges = new Set();
  const interests = {};
  
  // Get focal row data for detailed analysis
  let focalRowData = null;
  for (let i = 1; i < data.length; i++) {
    if (data[i][DANCE_CONFIG.COL.UID] === pyramid.focal.uid) {
      focalRowData = data[i];
      break;
    }
  }
  
  allMembers.forEach(m => {
    if (m.music) musicGenres.add(m.music);
    if (m.age) ageRanges.add(m.age);
    if (m.interests) {
      m.interests.forEach(int => {
        if (int) interests[int] = (interests[int] || 0) + 1;
      });
    }
  });
  
  // Find dominant interest
  const dominantInterest = Object.keys(interests).sort((a, b) => interests[b] - interests[a])[0];
  
  // Genre-based names
  const genreNames = {
    'Pop': ['Pop Perfection', 'Pop Dynasty', 'Pop Royalty', 'Chart Toppers'],
    'Hip-hop': ['Hip-Hop Heat', 'Rap Rebellion', 'Beat Brigade', 'Flow Masters'],
    'R&B': ['R&B Royalty', 'Smooth Operators', 'Soul Squad', 'Velvet Voices'],
    'Rock': ['Rock Legends', 'Rebel Rockers', 'Stone Cold Crew', 'Rock Revolution'],
    'Indie/Alt': ['Indie Icons', 'Alt Elite', 'Underground Kings', 'Indie Vanguard'],
    'Country': ['Country Crew', 'Nashville Ninjas', 'Honky Tonk Heroes', 'Country Classics'],
    'Electronic': ['Electric Energy', 'Bass Battalion', 'Synth Squad', 'EDM Empire']
  };
  
  // Interest-based names
  const interestNames = {
    'Music': ['Harmony Squad', 'Rhythm Rebels', 'Note Worthy'],
    'Fitness': ['Flex Force', 'Gym Legends', 'Fit Fam'],
    'Gaming': ['Level Up Crew', 'Controller Kings', 'Game Changers'],
    'Fashion': ['Style Squad', 'Fashion Forward', 'Runway Rebels'],
    'Art/Design': ['Creative Collective', 'Art Attack', 'Design Dynasty'],
    'Cooking': ['Kitchen Commanders', 'Flavor Force', 'Chef Squad'],
    'Travel': ['Jet Setters', 'Globe Trotters', 'Adventure Squad']
  };
  
  // Age-based names
  const ageNames = {
    '18-24': ['Gen Z Squad', 'Young Blood', 'Fresh Force'],
    '25-29': ['Prime Time', 'Quarter Life Crew', 'Rising Stars'],
    '30-34': ['Dirty Thirty', 'Peak Performance', 'Prime Movers'],
    '35-39': ['Wisdom Warriors', 'Established Elite', 'Vintage Vibes']
  };
  
  // Name selection logic
  let teamName = '';
  
  // Strategy 1: If team has strong genre unity (80%+ same genre)
  const genreArray = Array.from(musicGenres);
  if (genreArray.length === 1 && genreNames[genreArray[0]]) {
    const options = genreNames[genreArray[0]];
    teamName = options[Math.floor(Math.random() * options.length)];
  }
  // Strategy 2: If team has dominant interest
  else if (dominantInterest && interestNames[dominantInterest]) {
    const options = interestNames[dominantInterest];
    teamName = options[Math.floor(Math.random() * options.length)];
  }
  // Strategy 3: Use age range
  else if (ageRanges.size === 1) {
    const ageRange = Array.from(ageRanges)[0];
    if (ageNames[ageRange]) {
      const options = ageNames[ageRange];
      teamName = options[Math.floor(Math.random() * options.length)];
    }
  }
  // Strategy 4: Multi-genre mix names
  else if (genreArray.length >= 3) {
    const mixNames = [
      'Genre Fusion', 'Mixed Vibes', 'Eclectic Energy', 
      'Diverse Dynasty', 'Spectrum Squad', 'All-Star Mix'
    ];
    teamName = mixNames[Math.floor(Math.random() * mixNames.length)];
  }
  // Strategy 5: Default creative names
  else {
    const defaultNames = [
      'Dance Dynasty', 'Rhythm Royalty', 'Move Makers', 'Beat Squad',
      'Flow Force', 'Vibe Tribe', 'Energy Elite', 'Motion Crew',
      'Groove Gang', 'Step Squad', 'Dance Rebels', 'Stage Stars'
    ];
    teamName = defaultNames[Math.floor(Math.random() * defaultNames.length)];
  }
  
  return teamName;
}

/**
 * Generate Abby Lee-style commentary for dance team
 * 
 * @param {Object} team - Dance team structure
 * @returns {string} Abby-style quote
 */
function generateAbbyQuote(team) {
  const focal = team.focal.screenName;
  const teamName = team.teamName;
  const topMatch = team.row2[0].similarity;
  const genreMix = team.stats.genreMix;
  
  const highEnergyQuotes = [
    `${focal}, you're leading ${teamName} and that top ${(topMatch * 100).toFixed(0)}% match? *Chef's kiss*`,
    `This is what I'm TALKING about! ${teamName} has the chemistry to WIN.`,
    `${focal}, you better bring it because ${teamName} is competition-ready!`,
    `NOT ${teamName} being the team to beat! ${focal}, lead them to glory!`
  ];
  
  const mediumQuotes = [
    `${teamName}... interesting. ${focal}, you've got work to do but I see potential.`,
    `${focal}, ${teamName} needs discipline. Can you give it to them?`,
    `This is... fine. ${teamName} can be great if they FOCUS.`,
    `${focal}, ${teamName} has the raw talent. Now make it polished.`
  ];
  
  const lowQuotes = [
    `${focal}, I'm not sure what ${teamName} is giving, but we're gonna make it work.`,
    `This is a CHALLENGE, ${focal}. ${teamName} needs your leadership NOW.`,
    `${teamName}? Chaos. But chaos can become art. ${focal}, make me believe.`,
    `I've seen worse. ${teamName}, prove me wrong about this lineup.`
  ];
  
  // Add genre diversity comments
  if (genreMix >= 4) {
    const diversityQuotes = [
      `And ${genreMix} different genres? This is FUSION, people!`,
      `${genreMix} genres on one team! I love the diversity energy.`,
      `Genre mixing like this? ${teamName} is here to shake things up.`
    ];
    const baseQuote = topMatch >= 0.6 ? highEnergyQuotes : 
                     topMatch >= 0.4 ? mediumQuotes : lowQuotes;
    return baseQuote[Math.floor(Math.random() * baseQuote.length)] + ' ' +
           diversityQuotes[Math.floor(Math.random() * diversityQuotes.length)];
  }
  
  const quotes = topMatch >= 0.6 ? highEnergyQuotes : 
                 topMatch >= 0.4 ? mediumQuotes : lowQuotes;
  return quotes[Math.floor(Math.random() * quotes.length)];
}

/**
 * Export teams to JSON for external display
 * 
 * @param {Array} teams - Array of dance teams
 * @returns {string} JSON string
 */
function exportTeamsToJSON(teams) {
  return JSON.stringify(teams, null, 2);
}

/**
 * Test the dance team system
 */
function testDanceTeamSystem() {
  Logger.log('=== DANCE TEAM SYSTEM TEST ===\n');
  
  // Generate 3 test teams
  const teams = generateDanceTeams(3);
  
  teams.forEach((team, idx) => {
    Logger.log(`\n--- TEAM ${idx + 1}: ${team.teamName} ---`);
    Logger.log(`Focal: ${team.focal.screenName} (${team.focal.music})`);
    Logger.log(`Row 2: ${team.row2.map(m => m.screenName).join(', ')}`);
    Logger.log(`Row 3: ${team.row3.map(m => m.screenName).join(', ')}`);
    Logger.log(`Stats: ${(team.stats.avgSimilarity * 100).toFixed(0)}% avg, ${team.stats.genreMix} genres`);
    Logger.log(`Abby says: "${generateAbbyQuote(team)}"`);
  });
  
  Logger.log('\n=== TEST COMPLETE ===');
}

// ============================================================================
// END OF DANCE TEAM SYSTEM CODE
// ============================================================================
