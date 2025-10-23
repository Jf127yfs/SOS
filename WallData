/**
 * ============================================================================
 * WALL DATA BACKEND (WallData.gs)
 * ============================================================================
 * Provides data endpoints for The Wall display
 * Separated from main Code.gs to keep systems modular
 */

// ============================================================================
// WALL DATA FETCHER
// ============================================================================

/**
 * Get all data needed for The Wall display
 * Returns: guests, connections by category, unknowns, stats
 */
function getWallData() {
  Logger.log('=== FETCHING WALL DATA ===');
  
  const guests = getCheckedInGuests();
  Logger.log(`Retrieved ${guests.length} checked-in guests`);
  
  // Identify unknown guests (don't know hosts)
  const unknownGuests = guests.filter(g => {
    const knowHosts = String(g.knowHosts || '').toLowerCase();
    const knownLongest = String(g.knownLongest || '').toLowerCase();
    
    return knowHosts.includes('no') || 
           knownLongest.includes('do not know') ||
           knownLongest === '';
  });
  
  Logger.log(`Found ${unknownGuests.length} unknown guests`);
  
  // Calculate arrival rate (last 30 min)
  const now = new Date();
  const thirtyMinAgo = new Date(now - 30 * 60 * 1000);
  const recentArrivals = guests.filter(g => {
    const checkInTime = new Date(g.checkInTime);
    return checkInTime > thirtyMinAgo;
  });
  
  // Format guest data for display
  const formattedGuests = guests.map(g => ({
    uid: g.uid,
    screenName: g.screenName,
    checkInTime: new Date(g.checkInTime).toLocaleTimeString(),
    checkInTimestamp: new Date(g.checkInTime).getTime(),
    photoUrl: g.photoUrl || '',
    isUnknown: unknownGuests.some(u => u.uid === g.uid),
    
    // Attributes for connection analysis
    age: g.age,
    interests: [g.interest1, g.interest2, g.interest3].filter(Boolean),
    music: g.music,
    zodiac: g.zodiac,
    industry: g.industry,
    education: g.education,
    orientation: g.orientation,
    socialStance: g.socialStance,
    atWorst: g.atWorst
  }));
  
  // Build connections by category
  const connectionsByCategory = buildConnectionsByCategory(formattedGuests);
  
  return {
    guests: formattedGuests,
    connectionsByCategory: connectionsByCategory,
    unknownGuests: unknownGuests.map(u => ({
      uid: u.uid,
      screenName: u.screenName
    })),
    stats: {
      totalGuests: guests.length,
      totalUnknowns: unknownGuests.length,
      recentArrivals: recentArrivals.length,
      lastCheckIn: guests.length > 0 ? 
        Math.max(...guests.map(g => new Date(g.checkInTime).getTime())) : 0
    }
  };
}

/**
 * Build connections organized by category and subcategory
 * EXCLUDES sexual orientation for privacy
 */
function buildConnectionsByCategory(guests) {
  Logger.log('Building connections by category...');
  
  const connections = {
    age: buildAgeConnections(guests),
    interests: buildInterestConnections(guests),
    music: buildMusicConnections(guests),
    zodiac: buildZodiacConnections(guests),
    industry: buildIndustryConnections(guests),
    education: buildEducationConnections(guests),
    socialStance: buildSocialStanceConnections(guests)
    // Note: orientation connections excluded for privacy
  };
  
  return connections;
}

/**
 * Build connections for age groups
 */
function buildAgeConnections(guests) {
  const ageGroups = {};
  
  guests.forEach(guest => {
    if (!guest.age) return;
    
    if (!ageGroups[guest.age]) {
      ageGroups[guest.age] = [];
    }
    ageGroups[guest.age].push(guest.uid);
  });
  
  // Create connections within each age group
  const connections = {};
  Object.keys(ageGroups).forEach(ageGroup => {
    const uids = ageGroups[ageGroup];
    connections[ageGroup] = [];
    
    // Connect all pairs within the group
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[ageGroup].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for shared interests
 */
function buildInterestConnections(guests) {
  const interestGroups = {};
  
  guests.forEach(guest => {
    guest.interests.forEach(interest => {
      if (!interest) return;
      
      if (!interestGroups[interest]) {
        interestGroups[interest] = [];
      }
      interestGroups[interest].push(guest.uid);
    });
  });
  
  const connections = {};
  Object.keys(interestGroups).forEach(interest => {
    const uids = interestGroups[interest];
    connections[interest] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[interest].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for music preferences
 */
function buildMusicConnections(guests) {
  const musicGroups = {};
  
  guests.forEach(guest => {
    if (!guest.music) return;
    
    if (!musicGroups[guest.music]) {
      musicGroups[guest.music] = [];
    }
    musicGroups[guest.music].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(musicGroups).forEach(music => {
    const uids = musicGroups[music];
    connections[music] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[music].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for zodiac signs
 */
function buildZodiacConnections(guests) {
  const zodiacGroups = {};
  
  guests.forEach(guest => {
    if (!guest.zodiac) return;
    
    if (!zodiacGroups[guest.zodiac]) {
      zodiacGroups[guest.zodiac] = [];
    }
    zodiacGroups[guest.zodiac].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(zodiacGroups).forEach(zodiac => {
    const uids = zodiacGroups[zodiac];
    connections[zodiac] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[zodiac].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for industries
 */
function buildIndustryConnections(guests) {
  const industryGroups = {};
  
  guests.forEach(guest => {
    if (!guest.industry) return;
    
    if (!industryGroups[guest.industry]) {
      industryGroups[guest.industry] = [];
    }
    industryGroups[guest.industry].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(industryGroups).forEach(industry => {
    const uids = industryGroups[industry];
    connections[industry] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[industry].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for education levels
 */
function buildEducationConnections(guests) {
  const eduGroups = {};
  
  guests.forEach(guest => {
    if (!guest.education) return;
    
    if (!eduGroups[guest.education]) {
      eduGroups[guest.education] = [];
    }
    eduGroups[guest.education].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(eduGroups).forEach(edu => {
    const uids = eduGroups[edu];
    connections[edu] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[edu].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for orientation
 */
function buildOrientationConnections(guests) {
  const orientationGroups = {};
  
  guests.forEach(guest => {
    if (!guest.orientation) return;
    
    if (!orientationGroups[guest.orientation]) {
      orientationGroups[guest.orientation] = [];
    }
    orientationGroups[guest.orientation].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(orientationGroups).forEach(orientation => {
    const uids = orientationGroups[orientation];
    connections[orientation] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[orientation].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

/**
 * Build connections for social stance (similar values)
 */
function buildSocialStanceConnections(guests) {
  // Group by ranges: 1-2, 3-4, 5-6, 7-8, 9-10
  const stanceGroups = {
    '1-2': [],
    '3-4': [],
    '5-6': [],
    '7-8': [],
    '9-10': []
  };
  
  guests.forEach(guest => {
    if (!guest.socialStance) return;
    
    const stance = parseInt(guest.socialStance);
    if (stance >= 1 && stance <= 2) stanceGroups['1-2'].push(guest.uid);
    else if (stance >= 3 && stance <= 4) stanceGroups['3-4'].push(guest.uid);
    else if (stance >= 5 && stance <= 6) stanceGroups['5-6'].push(guest.uid);
    else if (stance >= 7 && stance <= 8) stanceGroups['7-8'].push(guest.uid);
    else if (stance >= 9 && stance <= 10) stanceGroups['9-10'].push(guest.uid);
  });
  
  const connections = {};
  Object.keys(stanceGroups).forEach(range => {
    const uids = stanceGroups[range];
    connections[range] = [];
    
    for (let i = 0; i < uids.length; i++) {
      for (let j = i + 1; j < uids.length; j++) {
        connections[range].push({
          source: uids[i],
          target: uids[j]
        });
      }
    }
  });
  
  return connections;
}

// ============================================================================
// TEST FUNCTIONS
// ============================================================================

/**
 * Test the wall data fetcher
 */
function testWallData() {
  Logger.log('=== TESTING WALL DATA ===\n');
  
  const wallData = getWallData();
  
  Logger.log(`Total Guests: ${wallData.stats.totalGuests}`);
  Logger.log(`Unknown Guests: ${wallData.stats.totalUnknowns}`);
  Logger.log(`Recent Arrivals (30min): ${wallData.stats.recentArrivals}`);
  
  Logger.log('\n=== CONNECTION SUMMARY ===');
  Object.keys(wallData.connectionsByCategory).forEach(category => {
    const subCategories = wallData.connectionsByCategory[category];
    const totalConnections = Object.values(subCategories)
      .reduce((sum, conns) => sum + conns.length, 0);
    
    Logger.log(`${category}: ${Object.keys(subCategories).length} subcategories, ${totalConnections} connections`);
  });
  
  Logger.log('\n=== SAMPLE GUEST ===');
  if (wallData.guests.length > 0) {
    Logger.log(JSON.stringify(wallData.guests[0], null, 2));
  }
  
  Logger.log('\n=== UNKNOWN GUESTS ===');
  wallData.unknownGuests.forEach(u => {
    Logger.log(`⚠️ ${u.uid} - ${u.screenName}`);
  });
  
  return wallData;
}

/**
 * Test connection building for specific category
 */
function testCategoryConnections(category) {
  const guests = getCheckedInGuests().slice(0, 10); // Test with first 10
  
  const formattedGuests = guests.map(g => ({
    uid: g.uid,
    age: g.age,
    interests: [g.interest1, g.interest2, g.interest3].filter(Boolean),
    music: g.music,
    zodiac: g.zodiac,
    industry: g.industry,
    education: g.education,
    orientation: g.orientation,
    socialStance: g.socialStance
  }));
  
  let connections;
  switch(category) {
    case 'age':
      connections = buildAgeConnections(formattedGuests);
      break;
    case 'interests':
      connections = buildInterestConnections(formattedGuests);
      break;
    case 'music':
      connections = buildMusicConnections(formattedGuests);
      break;
    default:
      Logger.log('Unknown category');
      return;
  }
  
  Logger.log(`=== ${category.toUpperCase()} CONNECTIONS ===`);
  Logger.log(JSON.stringify(connections, null, 2));
  
  return connections;
}

/**
 * COMPREHENSIVE TEST SUITE
 * Run all tests and display results
 */
function runAllWallTests() {
  Logger.log('╔════════════════════════════════════════════════════════════════╗');
  Logger.log('║          WALL SYSTEM - COMPREHENSIVE TEST SUITE               ║');
  Logger.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  const results = {
    passed: 0,
    failed: 0,
    tests: []
  };
  
  // Test 1: Data Retrieval
  try {
    Logger.log('TEST 1: Data Retrieval');
    const wallData = getWallData();
    if (wallData && wallData.guests && wallData.guests.length > 0) {
      Logger.log('✅ PASS: Retrieved wall data successfully');
      Logger.log(`   - ${wallData.guests.length} guests loaded`);
      results.passed++;
      results.tests.push({name: 'Data Retrieval', status: 'PASS'});
    } else {
      throw new Error('No guest data returned');
    }
  } catch (e) {
    Logger.log('❌ FAIL: ' + e.message);
    results.failed++;
    results.tests.push({name: 'Data Retrieval', status: 'FAIL', error: e.message});
  }
  
  // Test 2: Unknown Guest Detection
  try {
    Logger.log('\nTEST 2: Unknown Guest Detection');
    const wallData = getWallData();
    Logger.log(`✅ PASS: Detected ${wallData.unknownGuests.length} unknown guests`);
    wallData.unknownGuests.slice(0, 3).forEach(u => {
      Logger.log(`   - ${u.uid}: ${u.screenName}`);
    });
    results.passed++;
    results.tests.push({name: 'Unknown Guest Detection', status: 'PASS'});
  } catch (e) {
    Logger.log('❌ FAIL: ' + e.message);
    results.failed++;
    results.tests.push({name: 'Unknown Guest Detection', status: 'FAIL', error: e.message});
  }
  
  // Test 3: Age Connections
  try {
    Logger.log('\nTEST 3: Age Group Connections');
    const wallData = getWallData();
    const ageConnections = wallData.connectionsByCategory.age;
    const totalAge = Object.values(ageConnections).reduce((sum, c) => sum + c.length, 0);
    Logger.log(`✅ PASS: Built ${totalAge} age-based connections`);
    Logger.log(`   - Age groups: ${Object.keys(ageConnections).join(', ')}`);
    results.passed++;
    results.tests.push({name: 'Age Connections', status: 'PASS'});
  } catch (e) {
    Logger.log('❌ FAIL: ' + e.message);
    results.failed++;
    results.tests.push({name: 'Age Connections', status: 'FAIL', error: e.message});
  }
  
  // Test 4: Interest Connections
  try {
    Logger.log('\nTEST 4: Interest Connections');
    const wallData = getWallData();
    const interestConnections = wallData.connectionsByCategory.interests;
    const totalInterests = Object.values(interestConnections).reduce((sum, c) => sum + c.length, 0);
    Logger.log(`✅ PASS: Built ${totalInterests} interest-based connections`);
    Logger.log(`   - Interests: ${Object.keys(interestConnections).join(', ')}`);
    results.passed++;
    results.tests.push({name: 'Interest Connections', status: 'PASS'});
  } catch (e) {
    Logger.log('❌ FAIL: ' + e.message);
    results.failed++;
    results.tests.push({name: 'Interest Connections', status: 'FAIL', error: e.message});
  }
  
  // Test 5: Music Connections
  try {
    Logger.log('\nTEST 5: Music Preference Connections');
    const wallData = getWallData();
    const musicConnections = wallData.connectionsByCategory.music;
    const totalMusic = Object.values(musicConnections).reduce((sum, c) => sum + c.length, 0);
    Logger.log(`✅ PASS: Built ${totalMusic} music-based connections`);
    Logger.log(`   - Music types: ${Object.keys(musicConnections).slice(0, 5).join(', ')}...`);
    results.passed++;
    results.tests.push({name: 'Music Connections', status: 'PASS'});
  } catch (e) {
    Logger.log('❌ FAIL: ' + e.message);
    results.failed++;
    results.tests.push({name: 'Music Connections', status: 'FAIL', error: e.message});
  }
  
  // Summary
  Logger.log('\n╔════════════════════════════════════════════════════════════════╗');
  Logger.log('║                        TEST SUMMARY                            ║');
  Logger.log('╚════════════════════════════════════════════════════════════════╝');
  Logger.log(`Total Tests: ${results.passed + results.failed}`);
  Logger.log(`✅ Passed: ${results.passed}`);
  Logger.log(`❌ Failed: ${results.failed}`);
  Logger.log(`Success Rate: ${Math.round((results.passed / (results.passed + results.failed)) * 100)}%`);
  
  try {
    SpreadsheetApp.getUi().alert(
      '🧪 Wall System Tests Complete',
      `Passed: ${results.passed}/${results.passed + results.failed}\n\n` +
      'Check execution log for detailed results.',
      SpreadsheetApp.getUi().ButtonSet.OK
    );
  } catch (e) {}
  
  return results;
}
