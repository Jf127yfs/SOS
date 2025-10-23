# DANCE TEAM SYSTEM - INTEGRATION GUIDE
## Step-by-Step Setup Instructions

**Last Updated:** 2025-10-23

---

## 📋 PREREQUISITES

### Required Data
- ✅ Form Responses spreadsheet with guest data
- ✅ At least 6 checked-in guests (`Checked-In = Y`)
- ✅ Column structure matching pyramid system

### Optional
- 🔲 Photo URLs in column 30 (will use Abby placeholder if missing)
- 🔲 Live wall display endpoint (for real-time updates)

---

## 🚀 SETUP: GOOGLE APPS SCRIPT

### Step 1: Open Your Spreadsheet

1. Open your Google Sheet with Form Responses
2. Go to **Extensions → Apps Script**
3. You'll see `Code.gs` file

### Step 2: Add Dance Team Code

1. **Scroll to the bottom** of your existing `Code.gs` file
2. **Copy entire contents** of `DanceTeam_AppsScript.gs`
3. **Paste at the bottom** (below all existing code)
4. **Save** (Ctrl+S or File → Save)

### Step 3: Configure Column Mappings

Update `DANCE_CONFIG.COL` if your columns are different:

```javascript
const DANCE_CONFIG = {
  COL: {
    SCREEN_NAME: 24,  // Column 25 (0-indexed: subtract 1)
    UID: 25,          // Column 26
    CHECKED_IN: 27,   // Column 28
    PHOTO_URL: 29,    // Column 30
    AGE: 3,           // Column 4
    INTEREST_1: 15,   // Column 16
    MUSIC: 18,        // Column 19
    // ... more columns
  },
  SHEET_NAME: "FRC" // ⚠️ CHANGE TO YOUR SHEET NAME
};
```

**How to find column indices:**
1. Count columns left-to-right starting at 0
2. Column A = 0, B = 1, C = 2, etc.
3. Subtract 1 from Excel column number

### Step 4: Test the System

1. In Apps Script editor, select function dropdown
2. Choose `testDanceTeamSystem`
3. Click **Run** (▶️)
4. Grant permissions when prompted
5. Check **Execution log** for output

**Expected output:**
```
=== DANCE TEAM SYSTEM TEST ===

--- TEAM 1: Smooth Operators ---
Focal: Mikey (R&B)
Row 2: TwilightFang_861, SlayMommy
Row 3: GraveDancer_521, RavenHaunt_366, DuskOracle_157
Stats: 54% avg, 3 genres
Abby says: "Mikey, you better bring it..."

=== TEST COMPLETE ===
```

### Step 5: Generate Teams

```javascript
// In Apps Script or Script Editor console

// Generate 10 teams
var teams = generateDanceTeams(10);
Logger.log(JSON.stringify(teams, null, 2));

// Build specific team
var team = buildSingleDanceTeam("PS_438");
Logger.log(team);

// Get Abby quote
var quote = generateAbbyQuote(team);
Logger.log(quote);
```

---

## 🐍 SETUP: PYTHON (BATCH PROCESSING)

### Step 1: Install Dependencies

```bash
pip install pandas numpy openpyxl
```

### Step 2: Update File Paths

Edit `dance_team_generator.py`:

```python
# In main() function
form_path = '/path/to/your/Form_Responses_Raw.xlsx'

# Or use command line argument
python dance_team_generator.py /path/to/Form_Responses_Raw.xlsx
```

### Step 3: Run Generator

```bash
cd dance_teams/
python dance_team_generator.py
```

**Output files:**
- `dance_teams_output.json` - Team data
- `dance_teams_visual.txt` - ASCII art showcase

### Step 4: Verify Output

```bash
# View JSON
cat dance_teams_output.json | jq '.[0]'

# View visual
cat dance_teams_visual.txt
```

---

## 🔗 INTEGRATION WITH "THE WALL"

### Option 1: Manual Export

```javascript
// In Apps Script
function exportTeamsForWall() {
  var teams = generateDanceTeams(15);
  var json = exportTeamsToJSON(teams);
  
  // Copy to clipboard or save to file
  Logger.log(json);
}
```

Then paste JSON into your wall display system.

### Option 2: HTTP Endpoint

```javascript
// In Apps Script
function sendTeamsToWall() {
  var teams = generateDanceTeams(15);
  
  var payload = {
    teams: teams,
    timestamp: new Date().toISOString()
  };
  
  var options = {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  };
  
  UrlFetchApp.fetch('https://your-wall.com/api/teams', options);
}
```

### Option 3: Google Sheets as Database

```javascript
// Write teams to a separate sheet
function writeTeamsToSheet() {
  var teams = generateDanceTeams(15);
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Dance Teams');
  
  // Clear existing
  sheet.clear();
  
  // Write headers
  sheet.appendRow(['Team #', 'Team Name', 'Focal', 'Core 1', 'Core 2', 
                   'Wild 1', 'Wild 2', 'Wild 3', 'Abby Quote']);
  
  // Write teams
  teams.forEach(function(team) {
    sheet.appendRow([
      team.teamNumber,
      team.teamName,
      team.focal.screenName,
      team.row2[0].screenName,
      team.row2[1].screenName,
      team.row3[0].screenName,
      team.row3[1].screenName,
      team.row3[2].screenName,
      team.abbyQuote
    ]);
  });
}
```

Then your wall can read from "Dance Teams" sheet.

---

## 🖼️ PHOTO URL SETUP

### Data Preparation

Ensure column 30 (`PHOTO_URL_COL`) contains URLs:

```
https://drive.google.com/uc?id=XXXXXX
https://i.imgur.com/XXXXX.jpg
https://example.com/photos/XXXXX.png
```

### If Photos Missing

System automatically uses Abby Lee placeholder:
```javascript
photoUrl: data[i][DANCE_CONFIG.COL.PHOTO_URL] || DANCE_CONFIG.ABBY_PLACEHOLDER
```

**Abby Placeholder:**  
`https://media.giphy.com/media/l0HlUJZE8Uo1cSlUI/giphy.gif`

### Custom Placeholder

To use your own placeholder:

```javascript
// In DANCE_CONFIG
ABBY_PLACEHOLDER: "https://your-site.com/your-placeholder.gif"
```

---

## 🎯 LIVE SHUFFLE SETUP

### Auto-Refresh Every 30 Seconds

```javascript
// Create time-driven trigger
function setupAutoRefresh() {
  ScriptApp.newTrigger('refreshAndSendTeams')
    .timeBased()
    .everyMinutes(1) // Or every 30 seconds if available
    .create();
}

function refreshAndSendTeams() {
  var teams = generateDanceTeams(15);
  // Send to your display endpoint
  sendTeamsToWall(teams);
}
```

### Manual Refresh Button

Add button to your sheet:

1. **Insert → Drawing**
2. Create "Shuffle Teams" button
3. Save and close
4. Click button → Assign script: `refreshAndSendTeams`

---

## 🔧 CUSTOMIZATION

### Change Team Size

Currently 6 dancers (1+2+3). To modify:

```javascript
// In buildDanceTeamPyramid_()
const row2 = selectDiverseGenres_(similarities.slice(0, 10), 3); // Change 2 to 3
const row3 = selectDiverseGenres_(remaining, 4); // Change 3 to 4
```

### Add More Team Names

```javascript
// In generateTeamName_()
const genreNames = {
  'Pop': ['Pop Perfection', 'Pop Dynasty', 'YOUR NEW NAME'],
  // ... more
};
```

### Modify Abby Quotes

```javascript
// In generateAbbyQuote()
const highEnergyQuotes = [
  `Your custom quote here with ${focal} and ${teamName}`,
  // ... more
];
```

### Adjust Genre Mixing Weight

```javascript
// In calculateDanceSimilarity_()
if (guestA[DANCE_CONFIG.COL.MUSIC] === guestB[DANCE_CONFIG.COL.MUSIC]) {
  matches += mixGenres ? 0.3 : 1; // Change 0.3 to increase/decrease
}
```

---

## 🐛 DEBUGGING

### Enable Debug Logging

```javascript
// Add to your functions
Logger.log('Debug: focal guest', focal);
Logger.log('Debug: similarities', similarities.length);
Logger.log('Debug: team', team);
```

View logs: **View → Logs** in Apps Script

### Common Issues

#### Issue: "Not enough guests for pyramid"
**Cause:** Less than 6 checked-in guests  
**Fix:** 
```javascript
// Check how many guests are checked in
var sheet = getFRCSheet();
var data = sheet.getDataRange().getValues();
var count = 0;
for (var i = 1; i < data.length; i++) {
  if (String(data[i][27]).trim() === 'Y') count++;
}
Logger.log('Checked in guests: ' + count);
```

#### Issue: "Guest not found"
**Cause:** UID doesn't match  
**Fix:**
```javascript
// List all UIDs
var sheet = getFRCSheet();
var data = sheet.getDataRange().getValues();
for (var i = 1; i < data.length; i++) {
  Logger.log('Row ' + i + ': ' + data[i][25]); // UID column
}
```

#### Issue: Team names always default
**Cause:** Music genres not matching expected values  
**Fix:**
```javascript
// Check actual genre values
var sheet = getFRCSheet();
var data = sheet.getDataRange().getValues();
var genres = new Set();
for (var i = 1; i < data.length; i++) {
  genres.add(data[i][18]); // Music column
}
Logger.log('Unique genres: ' + Array.from(genres).join(', '));
```

---

## 📊 PERFORMANCE OPTIMIZATION

### For Large Datasets (>100 guests)

1. **Cache similarity calculations:**
```javascript
var similarityCache = {};
function getCachedSimilarity(uidA, uidB) {
  var key = [uidA, uidB].sort().join('-');
  if (!similarityCache[key]) {
    similarityCache[key] = calculateDanceSimilarity_(...);
  }
  return similarityCache[key];
}
```

2. **Limit genre mixing to top candidates:**
```javascript
// Only check top 20 for diversity instead of all
const row2 = selectDiverseGenres_(similarities.slice(0, 20), 2, focalGenre);
```

3. **Batch team generation:**
```javascript
// Generate all teams at once instead of one-by-one
function batchGenerateTeams(count) {
  var teams = [];
  var focals = getFocalCandidates(count);
  
  focals.forEach(function(focal) {
    teams.push(buildDanceTeamPyramid_(data, focal, true));
  });
  
  return teams;
}
```

---

## ✅ POST-SETUP CHECKLIST

- [ ] Apps Script code pasted and saved
- [ ] Column mappings updated (`DANCE_CONFIG.COL`)
- [ ] Sheet name updated (`DANCE_CONFIG.SHEET_NAME`)
- [ ] Test function runs successfully
- [ ] At least 6 guests marked as checked in
- [ ] Generated sample teams look correct
- [ ] Team names make sense
- [ ] Abby quotes display properly
- [ ] Photo URLs work or placeholder displays
- [ ] Integrated with display system (if applicable)
- [ ] Auto-refresh trigger set up (if needed)

---

## 🎉 YOU'RE READY!

Once checklist is complete, your dance team system is **production-ready**!

```javascript
// Generate teams and celebrate! 🎊
var teams = generateDanceTeams(15);
Logger.log('🎭 ' + teams.length + ' dance teams created!');
```

---

## 📞 NEED HELP?

1. Check source code comments in `DanceTeam_AppsScript.gs`
2. Review README.md for feature explanations
3. Test with `testDanceTeamSystem()` first
4. Check Apps Script execution logs

---

**End of Integration Guide**
