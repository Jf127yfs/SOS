# DANCE TEAM SYSTEM 🎭
## Auto-Named Pyramid Matchmaking with Abby Lee Energy

**Created:** 2025-10-23  
**Purpose:** Generate dance teams using pyramid structure with auto-naming, photo support, and genre mixing

---

## 🎯 OVERVIEW

The Dance Team System builds on pyramid matchmaking to create **competition-ready dance teams** with:

### ✅ Core Features

- **Pyramid Structure**: 1 focal + 2 core + 3 wild cards = 6 dancers per team
- **Auto-Generated Team Names**: Based on collective traits (music genre, interests, age)
- **Genre Mixing**: Ensures diversity by mixing music preferences
- **Photo URL Support**: Abby Lee Miller placeholder for visual displays
- **Repeat Allowed**: Dancers can be on multiple teams (but not focal twice)
- **Abby-Style Commentary**: Competition-ready quotes for each team

---

## 📊 STRUCTURE

```
        [Focal Dancer]        ← Team leader (unique per team)
       [Core] [Core]          ← 2 top matches (60-80% compatibility)
    [Wild] [Wild] [Wild]      ← 3 diverse matches (30-50% compatibility)
```

**Total: 6 dancers per team**

---

## 🚀 QUICK START

### Option 1: Google Apps Script (Live Events)

1. **Open your Google Sheet** with Form Responses
2. **Extensions → Apps Script**
3. **Copy contents of `DanceTeam_AppsScript.gs`**
4. **Paste at bottom of Code.gs**
5. **Save and test:**

```javascript
// Generate 10 dance teams
var teams = generateDanceTeams(10);

// Build specific team
var team = buildSingleDanceTeam("PS_438");

// Get Abby quote
var quote = generateAbbyQuote(team);

// Test system
testDanceTeamSystem();
```

### Option 2: Python (Batch Processing)

```bash
# Install dependencies
pip install pandas numpy openpyxl

# Run generator
python dance_team_generator.py

# Output:
# - dance_teams_output.json (team data)
# - dance_teams_visual.txt (ASCII art)
```

---

## 🎨 AUTO-NAMING SYSTEM

Teams are automatically named based on collective traits:

### Genre-Based Names
- **Pop**: Pop Perfection, Pop Dynasty, Chart Toppers
- **Hip-hop**: Hip-Hop Heat, Beat Brigade, Flow Masters  
- **R&B**: R&B Royalty, Smooth Operators, Soul Squad
- **Rock**: Rock Legends, Rebel Rockers, Rock Revolution
- **Indie/Alt**: Indie Icons, Alt Elite, Underground Kings

### Interest-Based Names
- **Music**: Harmony Squad, Rhythm Rebels, Note Worthy
- **Fitness**: Flex Force, Gym Legends, Fit Fam
- **Gaming**: Level Up Crew, Controller Kings, Game Changers
- **Fashion**: Style Squad, Fashion Forward, Runway Rebels

### Multi-Genre Mix Names
- Genre Fusion, Mixed Vibes, Eclectic Energy
- Diverse Dynasty, Spectrum Squad, All-Star Mix

### Default Names
- Dance Dynasty, Rhythm Royalty, Move Makers
- Flow Force, Vibe Tribe, Energy Elite

---

## 💬 ABBY LEE COMMENTARY

Teams get Abby Miller-style quotes based on compatibility:

### High Compatibility (60%+)
- "This is what I'm TALKING about! [Team Name] has the chemistry to WIN."
- "[Focal], you better bring it because [Team Name] is competition-ready!"
- "NOT [Team Name] being the team to beat! [Focal], lead them to glory!"

### Medium Compatibility (40-60%)
- "[Team Name]... interesting. [Focal], you've got work to do but I see potential."
- "This is... fine. [Team Name] can be great if they FOCUS."

### Low Compatibility (<40%)
- "[Focal], I'm not sure what [Team Name] is giving, but we're gonna make it work."
- "[Team Name]? Chaos. But chaos can become art. [Focal], make me believe."

### Genre Diversity Bonus
- "And [N] different genres? This is FUSION, people!"
- "Genre mixing like this? [Team Name] is here to shake things up."

---

## 📸 PHOTO URL SUPPORT

### Abby Lee Placeholder

**URL**: `https://media.giphy.com/media/l0HlUJZE8Uo1cSlUI/giphy.gif`

**Usage:**
- Falls back to Abby placeholder if no photo URL exists
- Compatible with Google Apps Script `Image()` function
- Works with HTML `<img>` tags for web displays

### Integration with Form Responses

Photos pull from column 30 (`PHOTO_URL_COL`) in Form Responses:

```javascript
// Apps Script
photoUrl: data[i][DANCE_CONFIG.COL.PHOTO_URL] || DANCE_CONFIG.ABBY_PLACEHOLDER
```

```python
# Python
photoUrl = guest.get('PHOTO_URL_COL') if pd.notna(guest.get('PHOTO_URL_COL')) else self.abby_placeholder
```

---

## 🎯 OUTPUT FORMATS

### 1. JSON Structure

```json
{
  "teamNumber": 1,
  "teamName": "Smooth Operators",
  "ok": true,
  "focal": {
    "uid": "PS_438",
    "screenName": "Mikey",
    "interests": ["Music", "Fitness", "Gaming"],
    "music": "R&B",
    "age": "30-34",
    "photoUrl": "https://..."
  },
  "row2": [
    {
      "uid": "TF_861",
      "screenName": "TwilightFang_861",
      "similarity": 0.7802,
      "music": "(N/A)",
      "photoUrl": "https://..."
    }
  ],
  "row3": [...],
  "stats": {
    "avgSimilarity": 0.5429,
    "topMatch": 0.7802,
    "genreMix": 3
  },
  "abbyPhoto": "https://...",
  "abbyQuote": "Mikey, you better bring it..."
}
```

### 2. Visual ASCII Art

```
╔══════════════════════════════════════════════════════════════╗
║  TEAM 1: SMOOTH OPERATORS
╚══════════════════════════════════════════════════════════════╝

                    [Mikey]
                R&B | 30-34
                        ↓
        [TwilightFang_861]              [SlayMommy]
        78.0%                    75.8%
                        ↓
    [GraveDancer_521]  [RavenHaunt_366]  [DuskOracle_157]
    40.7%       38.5%       38.5%

📊 TEAM STATS:
   Avg Compatibility: 54.3%
   Top Match: 78.0%
   Genre Mix: 3 genres

💬 ABBY SAYS: Mikey, you better bring it because Smooth Operators 
              is competition-ready!
```

---

## 🔧 CONFIGURATION

### Apps Script Config

```javascript
const DANCE_CONFIG = {
  COL: {
    SCREEN_NAME: 24,  // Column 25 (0-indexed)
    UID: 25,          // Column 26
    CHECKED_IN: 27,   // Column 28
    PHOTO_URL: 29,    // Column 30
    AGE: 3,           // Column 4
    INTEREST_1: 15,   // Column 16
    MUSIC: 18,        // Column 19
    // ... more columns
  },
  ABBY_PLACEHOLDER: "https://media.giphy.com/media/l0HlUJZE8Uo1cSlUI/giphy.gif",
  SHEET_NAME: "FRC" // Your sheet name
};
```

### Python Config

Update paths in `dance_team_generator.py`:

```python
# Column mappings
self.cols = {
    'screen_name': 'Screen Name',
    'uid': 'UID',
    'checked_in': 'Checked-In',
    'photo_url': 'PHOTO_URL_COL',
    # ... more columns
}
```

---

## 📝 SAMPLE OUTPUT

See included files:
- `dance_teams_output.json` - 5 sample teams in JSON format
- `dance_teams_visual.txt` - ASCII art showcase

### Sample Team: "Smooth Operators"

**Focal**: Mikey (R&B, 30-34)  
**Core Crew**: TwilightFang_861 (78%), SlayMommy (75.8%)  
**Wild Cards**: GraveDancer_521 (40.7%), RavenHaunt_366 (38.5%), DuskOracle_157 (38.5%)  
**Team Avg**: 54.3% compatibility  
**Genre Mix**: 3 genres (R&B, Indie/Alt, Hip-hop)

**Abby Says**: "Mikey, you better bring it because Smooth Operators is competition-ready!"

---

## 🎭 USE CASES

### 1. Live Event Display
- Call `generateDanceTeams(15)` every 30 seconds
- Display rotating teams on "The Wall"
- Show Abby quotes for entertainment

### 2. Competition Teams
- Pre-generate teams before event
- Print team rosters with photos
- Use for actual dance competitions

### 3. Social Mixing
- Create diverse teams for networking
- Mix genres to encourage cross-pollination
- Use as icebreaker activity

### 4. Photo Slideshows
- Pull photo URLs from teams
- Create video intros with Abby quotes
- Display on projector during event

---

## ⚙️ ADVANCED FEATURES

### Genre Mixing Algorithm

```javascript
// Select diverse genres for row 2 and row 3
function selectDiverseGenres_(guests, count, focalGenre) {
  const selected = [];
  const usedGenres = new Set([focalGenre]);
  
  // First pass: different genres
  for (let g of guests) {
    if (g.music && !usedGenres.has(g.music)) {
      selected.push(g);
      usedGenres.add(g.music);
    }
  }
  
  // Second pass: fill remaining
  // ... (see source code)
}
```

### Similarity Calculation

Weighted features:
- **Interests**: 2x weight (shared interests = strong bond)
- **Age Range**: 1x weight  
- **Music Genre**: 0.5x weight when mixing (encourages diversity)

Bonus:
- Different genres get +0.3 when `mixGenres = true`

---

## 📦 FILES INCLUDED

```
DanceTeam_AppsScript.gs         - Google Apps Script code (paste in Code.gs)
dance_team_generator.py         - Python batch processor
dance_teams_output.json         - Sample teams (JSON)
dance_teams_visual.txt          - Sample teams (ASCII art)
README.md                       - This file
INTEGRATION_GUIDE.md            - Setup instructions
```

---

## 🐛 TROUBLESHOOTING

### "Not enough guests for pyramid"
- **Cause**: Less than 6 checked-in guests
- **Fix**: Ensure at least 6 rows have `Checked-In = Y` in Form Responses

### "Guest not found"
- **Cause**: UID doesn't exist or guest not checked in
- **Fix**: Verify UID matches exactly (e.g., "PS_438")

### Photos not showing
- **Cause**: Empty PHOTO_URL_COL
- **Fix**: System auto-fills with Abby placeholder (this is expected behavior)

### Team names seem random
- **Cause**: Mixed genres/interests, no dominant trait
- **Fix**: This is intentional! Multi-genre teams get "fusion" names

---

## 🎯 INTEGRATION WITH "THE WALL"

### Real-Time Display

```javascript
// Generate teams every 30 seconds
function refreshDanceTeams() {
  const teams = generateDanceTeams(15);
  
  // Send to your visual layer
  const payload = {
    teams: teams,
    timestamp: new Date().toISOString()
  };
  
  // POST to your endpoint
  UrlFetchApp.fetch('https://your-wall-endpoint.com/teams', {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  });
}
```

### HTML Display Template

```html
<div class="dance-team">
  <h2>TEAM {{teamNumber}}: {{teamName}}</h2>
  <img src="{{abbyPhoto}}" alt="Abby Lee Miller" />
  <div class="pyramid">
    <div class="focal">
      <img src="{{focal.photoUrl}}" />
      <h3>{{focal.screenName}}</h3>
    </div>
    <div class="row2">
      {{#each row2}}
        <img src="{{photoUrl}}" />
        <span>{{screenName}} - {{similarity}}%</span>
      {{/each}}
    </div>
    <div class="row3">
      {{#each row3}}
        <img src="{{photoUrl}}" />
        <span>{{screenName}}</span>
      {{/each}}
    </div>
  </div>
  <blockquote class="abby-quote">{{abbyQuote}}</blockquote>
</div>
```

---

## ✅ VALIDATION

### Test Checklist

- [x] Auto-naming works for all genre types
- [x] Photo URLs fall back to Abby placeholder
- [x] Dancers can repeat across teams
- [x] No dancer appears as focal twice
- [x] Genre mixing creates diverse teams
- [x] Abby quotes match compatibility levels
- [x] JSON output is valid
- [x] ASCII art displays correctly

---

## 🎉 READY FOR PRODUCTION

**Status**: ✅ System tested with 5 sample teams  
**Compatibility**: Google Apps Script + Python  
**Photo Support**: Abby Lee placeholder active  
**Auto-Naming**: 30+ team name variations  
**Commentary**: 12+ Abby-style quotes  

**Deploy now and let's dance!** 💃🕺

---

## 📞 SUPPORT

**Questions?** Check source code comments or existing README.md  
**Bug Reports?** Test with `testDanceTeamSystem()` first  
**Feature Requests?** Fork and customize!

---

**End of README**
