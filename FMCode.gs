/**
 * ============================================================================
 * VILLAGE BIO GENERATOR - FM MODULE
 * ============================================================================
 * Generates ultra-short (≤90 char) village-style bios from form responses
 *
 * STANDALONE MODULE for Village Bios page
 * Kept separate from Code.gs for easier troubleshooting
 *
 * Template: @ScreenName • Occupation • Interest1/Interest2 • Recent: <purchase> • Worst: <trait> • <stance>
 *
 * DEPENDENCIES:
 * - FRC sheet with checked-in guest data
 * - Main CONFIG object from Code.gs
 *
 * CALLED BY: VillageBios.html via google.script.run
 * ============================================================================
 */

// ============================================================================
// FM-SPECIFIC CONFIGURATION
// ============================================================================

const FM_CONFIG = {
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
  DDD_THRESHOLD: 5,

  // Output sheet name (for batch generation)
  OUTPUT_SHEET: 'Village Bios'
};

// ============================================================================
// MAIN FUNCTIONS (Called from HTML)
// ============================================================================

/**
 * Get village bios for all checked-in guests
 * Main entry point for VillageBios.html
 *
 * @return {Object} {bios: Array, totalGuests: Number}
 */
function getVillageBiosForCheckedIn() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName(CONFIG.SHEETS.FRC);

    if (!frcSheet) {
      Logger.log('❌ FRC sheet not found');
      return {
        bios: [],
        totalGuests: 0,
        error: 'FRC sheet not found'
      };
    }

    // Get FRC data
    const frcData = frcSheet.getDataRange().getValues();

    // Generate bios for checked-in guests
    const bios = [];
    for (let i = 1; i < frcData.length; i++) {
      const row = frcData[i];
      const checkedIn = String(row[CONFIG.COL.CHECKED_IN] || '').trim().toUpperCase();

      if (checkedIn === 'Y') {
        const bio = generateBioFromRow(row);
        if (bio) {
          bios.push(bio);
        }
      }
    }

    Logger.log(`✅ Generated ${bios.length} village bios for checked-in guests`);

    return {
      bios: bios,
      totalGuests: bios.length
    };

  } catch (error) {
    Logger.log('❌ ERROR: ' + error.toString());
    return {
      bios: [],
      totalGuests: 0,
      error: error.message
    };
  }
}

/**
 * Generate all bios (for batch processing)
 * Can be called from menu or manually
 */
function generateAllBios() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sourceSheet = ss.getSheetByName(CONFIG.SHEETS.FRC);

    if (!sourceSheet) {
      throw new Error(`FRC sheet not found`);
    }

    // Get all data
    const data = sourceSheet.getDataRange().getValues();

    // Generate bios
    const bios = [];
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const bio = generateBioFromRow(row);
      if (bio) {
        bios.push(bio);
      }
    }

    // Write to output sheet
    writeBiosToSheet(bios);

    try {
      SpreadsheetApp.getUi().alert(
        'Success!',
        `Generated ${bios.length} bios successfully!`,
        SpreadsheetApp.getUi().ButtonSet.OK
      );
    } catch (e) {
      // UI not available (running from script)
      Logger.log(`✅ Generated ${bios.length} bios successfully!`);
    }

    return bios;

  } catch (error) {
    Logger.log('❌ ERROR: ' + error.toString());
    try {
      SpreadsheetApp.getUi().alert('Error', error.message, SpreadsheetApp.getUi().ButtonSet.OK);
    } catch (e) {
      // UI not available
    }
    throw error;
  }
}

// ============================================================================
// BIO GENERATION LOGIC
// ============================================================================

/**
 * Generate a single bio from row data using main CONFIG
 */
function generateBioFromRow(row) {
  // Extract fields using main CONFIG column indices
  const screenName = getString(row[CONFIG.COL.SCREEN_NAME]);
  const industry = getString(row[CONFIG.COL.INDUSTRY]);
  const role = getString(row[CONFIG.COL.ROLE]);
  const interest1 = getString(row[CONFIG.COL.INTEREST_1]);
  const interest2 = getString(row[CONFIG.COL.INTEREST_2]);
  const interest3 = getString(row[CONFIG.COL.INTEREST_3]);
  const purchase = getString(row[CONFIG.COL.RECENT_PURCHASE]);
  const worst = getString(row[CONFIG.COL.AT_WORST]);
  const stanceNum = getNumber(row[CONFIG.COL.SOCIAL_STANCE]);
  const uid = getString(row[CONFIG.COL.UID]);
  const checkedIn = getString(row[CONFIG.COL.CHECKED_IN]);
  const ddd = getNumber(row[CONFIG.COL.DDD_SCORE]);
  const photoUrl = getString(row[CONFIG.COL.PHOTO_URL]);

  // Build interests string
  const interests = buildInterestsString([interest1, interest2, interest3]);

  // Build occupation (role or industry)
  const occupation = buildOccupation(role, industry);

  // Map stance to text
  const stance = mapStance(stanceNum);

  // Shorten fields for space
  const purchaseShort = shortenPurchase(purchase);
  const worstShort = shortenWorst(worst);

  // Check for prison badge
  const inPrison = ddd > FM_CONFIG.DDD_THRESHOLD;

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
    inPrison: inPrison,
    photoUrl: photoUrl
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
  const availableSpace = FM_CONFIG.MAX_LENGTH - baseLength;

  // Add purchase if space allows
  if (purchase !== '—' && availableSpace > 15) {
    bio += ` • Recent: ${purchase}`;
  }

  // Add worst trait if space allows
  const currentLength = bio.length;
  const remainingSpace = FM_CONFIG.MAX_LENGTH - currentLength;
  if (worst !== '—' && remainingSpace > 12) {
    bio += ` • Worst: ${worst}`;
  }

  // Add stance if space allows
  const finalSpace = FM_CONFIG.MAX_LENGTH - bio.length;
  if (stance !== '—' && finalSpace > stance.length + 3) {
    bio += ` • ${stance}`;
  }

  // Add prison badge if needed
  if (inPrison) {
    const prisonBadge = ' • Prison';
    if (bio.length + prisonBadge.length <= FM_CONFIG.MAX_LENGTH) {
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
  if (bio.length > FM_CONFIG.MAX_LENGTH) {
    bio = bio.substring(0, FM_CONFIG.MAX_LENGTH - 1) + '…';
  }

  return bio;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

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
 * Build interests string from array
 */
function buildInterestsString(interestArray) {
  const interests = interestArray.filter(i => i !== '—' && i !== '').slice(0, 2);

  if (interests.length === 0) {
    return '—';
  }

  return interests.join('/');
}

/**
 * Build occupation string from role and industry
 */
function buildOccupation(role, industry) {
  // Prefer role, fallback to industry
  if (role !== '—') {
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
  return FM_CONFIG.STANCE_MAP[Math.round(stanceNum)] || '—';
}

/**
 * Write bios to output sheet (for batch generation)
 */
function writeBiosToSheet(bios) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let outputSheet = ss.getSheetByName(FM_CONFIG.OUTPUT_SHEET);

  // Create sheet if doesn't exist
  if (!outputSheet) {
    outputSheet = ss.insertSheet(FM_CONFIG.OUTPUT_SHEET);
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
 * Show help dialog (can be called from menu)
 */
function showVillageBioHelp() {
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
1. Access via doGet(): ?page=village
2. Or run generateAllBios() to create batch sheet
3. View results in "${FM_CONFIG.OUTPUT_SHEET}" sheet

CONFIGURATION:
Edit FM_CONFIG object in FMCode.gs to adjust:
- Social stance labels
- DDD threshold
- Max bio length
`;

  try {
    SpreadsheetApp.getUi().alert('Village Bio Help', help, SpreadsheetApp.getUi().ButtonSet.OK);
  } catch (e) {
    Logger.log(help);
  }
}
