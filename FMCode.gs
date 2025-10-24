/**
 * VILLAGE BIO GENERATOR
 * Generates ultra-short (≤90 char) village-style bios from form responses
 * 
 * Template: @ScreenName • Occupation • Interest1/Interest2 • Recent: <purchase> • Worst: <trait> • <stance>
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

const CONFIG = {
  // Source sheet name (adjust to your actual sheet name)
  SOURCE_SHEET: 'Form Responses 1',
  
  // Output sheet name (will be created if doesn't exist)
  OUTPUT_SHEET: 'Village Bios',
  
  // Column mappings (adjust based on your actual column letters)
  COLUMNS: {
    SCREEN_NAME: 'Screen Name',
    INDUSTRY: 'Employment Information (Industry)',
    ROLE: 'Employment Information (Role)',
    INTERESTS: 'Your General Interests (Choose 3)',
    PURCHASE: 'Recent purchase you're most happy about',
    WORST: 'At your worst you are…',
    STANCE: 'Which best describes your general social stance?',
    UID: 'UID',
    CHECKED_IN: 'Checked-In',
    // DDD column (add this to your form if not present)
    DDD: 'DDD'
  },
  
  // Social stance mapping (1-5 scale to text)
  STANCE_MAP: {
    1: 'introvert',
    2: 'intro-lean',
    3: 'balanced',
    4: 'extro-lean',
    5: 'extrovert'
  },
  
  // Max bio length
  MAX_LENGTH: 90,
  
  // DDD threshold for prison badge
  DDD_THRESHOLD: 5
};

// ============================================================================
// MAIN FUNCTIONS
// ============================================================================

/**
 * Generate bios for all guests
 */
function generateAllBios() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sourceSheet = ss.getSheetByName(CONFIG.SOURCE_SHEET);
    
    if (!sourceSheet) {
      throw new Error(`Source sheet "${CONFIG.SOURCE_SHEET}" not found`);
    }
    
    // Get all data
    const data = sourceSheet.getDataRange().getValues();
    const headers = data[0];
    
    // Get column indices
    const colIndices = getColumnIndices(headers);
    
    // Generate bios
    const bios = [];
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const bio = generateBio(row, colIndices);
      bios.push(bio);
    }
    
    // Write to output sheet
    writeBiosToSheet(bios);
    
    SpreadsheetApp.getUi().alert(
      'Success!',
      `Generated ${bios.length} bios successfully!`,
      SpreadsheetApp.getUi().ButtonSet.OK
    );
    
    return bios;
    
  } catch (error) {
    SpreadsheetApp.getUi().alert('Error', error.message, SpreadsheetApp.getUi().ButtonSet.OK);
    throw error;
  }
}

/**
 * Generate a single bio from row data
 */
function generateBio(row, colIndices) {
  // Extract fields
  const screenName = getString(row[colIndices.SCREEN_NAME]);
  const industry = getString(row[colIndices.INDUSTRY]);
  const role = getString(row[colIndices.ROLE]);
  const interestsRaw = getString(row[colIndices.INTERESTS]);
  const purchase = getString(row[colIndices.PURCHASE]);
  const worst = getString(row[colIndices.WORST]);
  const stanceNum = getNumber(row[colIndices.STANCE]);
  const uid = getString(row[colIndices.UID]);
  const checkedIn = getString(row[colIndices.CHECKED_IN]);
  const ddd = getNumber(row[colIndices.DDD]);
  
  // Parse interests (take first 2)
  const interests = parseInterests(interestsRaw, 2);
  
  // Build occupation (role or industry)
  const occupation = buildOccupation(role, industry);
  
  // Map stance to text
  const stance = mapStance(stanceNum);
  
  // Shorten fields for space
  const purchaseShort = shortenPurchase(purchase);
  const worstShort = shortenWorst(worst);
  
  // Check for prison badge
  const inPrison = ddd > CONFIG.DDD_THRESHOLD;
  
  // Build bio
  const bio = buildBioString(
    screenName,
    occupation,
    interests,
    purchaseShort,
    worstShort,
    stance,
    inPrison
  );
  
  // Return bio object
  return {
    uid: uid,
    screenName: screenName,
    bio: bio,
    length: bio.length,
    checkedIn: checkedIn,
    ddd: ddd,
    inPrison: inPrison
  };
}

/**
 * Build the bio string according to template
 * Template: @ScreenName • Occupation • Interest1/Interest2 • Recent: <purchase> • Worst: <trait> • <stance>
 */
function buildBioString(screenName, occupation, interests, purchase, worst, stance, inPrison) {
  const parts = [];
  
  // Always include screen name
  if (screenName !== '—') {
    parts.push(`@${screenName}`);
  }
  
  // Add occupation
  if (occupation !== '—') {
    parts.push(occupation);
  }
  
  // Add interests
  if (interests !== '—') {
    parts.push(interests);
  }
  
  // Build the rest
  let bio = parts.join(' • ');
  
  // Calculate remaining space
  const baseLength = bio.length;
  const availableSpace = CONFIG.MAX_LENGTH - baseLength;
  
  // Add purchase if space allows
  if (purchase !== '—' && availableSpace > 15) {
    bio += ` • Recent: ${purchase}`;
  }
  
  // Add worst trait if space allows
  const currentLength = bio.length;
  const remainingSpace = CONFIG.MAX_LENGTH - currentLength;
  if (worst !== '—' && remainingSpace > 12) {
    bio += ` • Worst: ${worst}`;
  }
  
  // Add stance if space allows
  const finalSpace = CONFIG.MAX_LENGTH - bio.length;
  if (stance !== '—' && finalSpace > stance.length + 3) {
    bio += ` • ${stance}`;
  }
  
  // Add prison badge if needed
  if (inPrison) {
    const prisonBadge = ' • Prison';
    if (bio.length + prisonBadge.length <= CONFIG.MAX_LENGTH) {
      bio += prisonBadge;
    } else {
      // Trim stance to make room for prison badge
      const stanceRemove = ` • ${stance}`;
      if (bio.endsWith(stanceRemove)) {
        bio = bio.slice(0, -stanceRemove.length) + prisonBadge;
      }
    }
  }
  
  // Ensure we don't exceed max length
  if (bio.length > CONFIG.MAX_LENGTH) {
    bio = bio.substring(0, CONFIG.MAX_LENGTH - 1) + '…';
  }
  
  return bio;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get column indices from headers
 */
function getColumnIndices(headers) {
  const indices = {};
  for (const [key, colName] of Object.entries(CONFIG.COLUMNS)) {
    const index = headers.indexOf(colName);
    if (index === -1 && key !== 'DDD') { // DDD might not exist yet
      Logger.log(`Warning: Column "${colName}" not found`);
    }
    indices[key] = index;
  }
  return indices;
}

/**
 * Safely get string from cell
 */
function getString(value) {
  if (value === null || value === undefined || value === '') {
    return '—';
  }
  return String(value).trim();
}

/**
 * Safely get number from cell
 */
function getNumber(value) {
  if (value === null || value === undefined || value === '') {
    return 0;
  }
  const num = Number(value);
  return isNaN(num) ? 0 : num;
}

/**
 * Parse interests from comma-separated string
 */
function parseInterests(interestsRaw, maxCount = 2) {
  if (interestsRaw === '—' || !interestsRaw) {
    return '—';
  }
  
  // Split by comma and clean
  const interests = interestsRaw
    .split(',')
    .map(i => i.trim())
    .filter(i => i.length > 0)
    .slice(0, maxCount);
  
  if (interests.length === 0) {
    return '—';
  }
  
  // Join with slash
  return interests.join('/');
}

/**
 * Build occupation string from role and industry
 */
function buildOccupation(role, industry) {
  // Prefer role, fallback to industry
  if (role !== '—') {
    // Shorten role
    return shortenRole(role);
  }
  if (industry !== '—') {
    return shortenIndustry(industry);
  }
  return '—';
}

/**
 * Shorten role names
 */
function shortenRole(role) {
  const roleMap = {
    'Manager / Supervisor': 'Manager',
    'Creative / Designer / Artist': 'Designer',
    'Sales / Marketing / Business Development': 'Sales',
    'Operations / Admin / Support': 'Ops',
    'Trades / Skilled Labor': 'Trades',
    'Healthcare / Service Provider': 'Healthcare',
    'Technical / Engineer / Developer': 'Engineer',
    'Researcher / Scientist': 'Researcher',
    'Founder / Entrepreneur': 'Founder',
    'Student / Trainee': 'Student',
    'Educator / Instructor': 'Educator'
  };
  
  return roleMap[role] || role;
}

/**
 * Shorten industry names
 */
function shortenIndustry(industry) {
  const industryMap = {
    'Hospitality / Retail': 'Hospitality',
    'Finance / Business Services': 'Finance',
    'Trades / Manufacturing': 'Trades',
    'Arts & Entertainment': 'Arts',
    'Science / Research': 'Research',
    'Government / Military': 'Government'
  };
  
  return industryMap[industry] || industry;
}

/**
 * Shorten purchase descriptions
 */
function shortenPurchase(purchase) {
  if (purchase === '—') return '—';
  
  const purchaseMap = {
    'Fashion/Clothing': 'clothes',
    'Home/Kitchen': 'home item',
    'Tech gadget': 'tech',
    'Car/Motorcycle': 'vehicle',
    'Course/App': 'course',
    'Pet item': 'pet item',
    'Fitness gear': 'gear'
  };
  
  return purchaseMap[purchase] || purchase.toLowerCase();
}

/**
 * Shorten worst trait
 */
function shortenWorst(worst) {
  if (worst === '—') return '—';
  
  const worstMap = {
    'Overly critical': 'critical',
    'Self-conscious': 'self-conscious'
  };
  
  return worstMap[worst] || worst.toLowerCase();
}

/**
 * Map numeric stance to text
 */
function mapStance(stanceNum) {
  if (!stanceNum || stanceNum < 1 || stanceNum > 5) {
    return '—';
  }
  return CONFIG.STANCE_MAP[Math.round(stanceNum)] || '—';
}

/**
 * Write bios to output sheet
 */
function writeBiosToSheet(bios) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let outputSheet = ss.getSheetByName(CONFIG.OUTPUT_SHEET);
  
  // Create sheet if doesn't exist
  if (!outputSheet) {
    outputSheet = ss.insertSheet(CONFIG.OUTPUT_SHEET);
  } else {
    // Clear existing data
    outputSheet.clear();
  }
  
  // Write headers
  const headers = ['UID', 'Screen Name', 'Bio', 'Length', 'Checked-In', 'DDD', 'In Prison'];
  outputSheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  outputSheet.getRange(1, 1, 1, headers.length).setFontWeight('bold');
  
  // Write data
  const data = bios.map(b => [
    b.uid,
    b.screenName,
    b.bio,
    b.length,
    b.checkedIn,
    b.ddd,
    b.inPrison ? 'Yes' : 'No'
  ]);
  
  if (data.length > 0) {
    outputSheet.getRange(2, 1, data.length, headers.length).setValues(data);
  }
  
  // Format
  outputSheet.autoResizeColumns(1, headers.length);
  outputSheet.setFrozenRows(1);
  
  // Color code prison rows
  for (let i = 0; i < bios.length; i++) {
    if (bios[i].inPrison) {
      outputSheet.getRange(i + 2, 1, 1, headers.length).setBackground('#ffe6e6');
    }
  }
}

/**
 * Create custom menu
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('🏘️ Village Bios')
    .addItem('Generate All Bios', 'generateAllBios')
    .addItem('Show Bio Builder', 'showBioBuilder')
    .addSeparator()
    .addItem('Help', 'showHelp')
    .addToUi();
}

/**
 * Show bio builder HTML interface
 */
function showBioBuilder() {
  const html = HtmlService.createHtmlOutputFromFile('BioBuilder')
    .setWidth(800)
    .setHeight(600)
    .setTitle('Village Bio Builder');
  SpreadsheetApp.getUi().showModalDialog(html, 'Village Bio Builder');
}

/**
 * Show help dialog
 */
function showHelp() {
  const help = `
VILLAGE BIO GENERATOR - HELP

This script generates ultra-short (≤90 character) village-style bios from your form responses.

TEMPLATE:
@ScreenName • Occupation • Interest1/Interest2 • Recent: <purchase> • Worst: <trait> • <stance>

FEATURES:
• Automatically shortens fields to fit 90-char limit
• Prioritizes: Screen Name > Occupation > Interests
• Adds DDD > 5 guests to Prison (badge: • Prison)
• Handles missing data gracefully (uses "—")
• Color-codes prison rows in output

USAGE:
1. Go to menu: 🏘️ Village Bios > Generate All Bios
2. View results in "${CONFIG.OUTPUT_SHEET}" sheet
3. Use Bio Builder for interactive preview

CONFIGURATION:
Edit CONFIG object in Code.gs to adjust:
- Source/output sheet names
- Column mappings
- Social stance labels
- DDD threshold
`;
  
  SpreadsheetApp.getUi().alert('Help', help, SpreadsheetApp.getUi().ButtonSet.OK);
}

/**
 * Get guest data for HTML interface (called from HTML)
 */
function getGuestData() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sourceSheet = ss.getSheetByName(CONFIG.SOURCE_SHEET);
  
  if (!sourceSheet) {
    return { error: `Source sheet "${CONFIG.SOURCE_SHEET}" not found` };
  }
  
  const data = sourceSheet.getDataRange().getValues();
  const headers = data[0];
  const colIndices = getColumnIndices(headers);
  
  const guests = [];
  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    const bio = generateBio(row, colIndices);
    guests.push(bio);
  }
  
  return { guests: guests };
}
