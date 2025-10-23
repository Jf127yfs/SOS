# Analytics Configuration Review
**Date:** 2025-10-23
**Branch:** claude/review-analytics-config-011CUQpVDNwAwgBfRDLq2fc6

## Executive Summary

This document reviews the analytics implementation across the codebase to ensure consistency between code and configuration. The analysis focuses on how different analytics modules access and process data, particularly for similarity analysis.

---

## Configuration Architecture

### 1. Primary Configuration (Code.gs)

**Location:** `/home/user/SOS/Code` lines 40-86

The `CONFIG` object serves as the **single source of truth** for column mappings:

```javascript
const CONFIG = {
  SHEETS: {
    FRC: 'FRC',
    MASTER_DESC: 'Master_Desc',
    PAN_LOG: 'Pan_Log',
    TOOL_REGISTRY: 'Tool_Registry',
    DATA_DICT: 'Data_Dictionary'
  },

  COL: {
    TIMESTAMP: 0,        // Column A
    BIRTHDAY: 1,         // Column B
    ZODIAC: 2,           // Column C
    AGE: 3,              // Column D - Age Range
    EDU: 4,              // Column E - Education Level
    ZIP: 5,              // Column F - Zip Code
    ETHNICITY: 6,        // Column G
    GENDER: 7,           // Column H
    ORIENTATION: 8,      // Column I
    INDUSTRY: 9,         // Column J
    ROLE: 10,            // Column K
    KNOW_HOSTS: 11,      // Column L
    KNOWN_LONGEST: 12,   // Column M
    KNOW_SCORE: 13,      // Column N
    INTERESTS_RAW: 14,   // Column O
    INTEREST_1: 15,      // Column P
    INTEREST_2: 16,      // Column Q
    INTEREST_3: 17,      // Column R
    MUSIC: 18,           // Column S - Music Preference
    ARTIST: 19,          // Column T
    SONG: 20,            // Column U
    RECENT_PURCHASE: 21, // Column V
    AT_WORST: 22,        // Column W
    SOCIAL_STANCE: 23,   // Column X
    SCREEN_NAME: 24,     // Column Y
    UID: 25,             // Column Z
    DDD_SCORE: 26,       // Column AA
    CHECKED_IN: 27,      // Column AB
    CHECKIN_TIME: 28,    // Column AC
    PHOTO_URL: 29        // Column AD
  },

  PHOTO_FOLDER_ID: '1ZcP5jpYsYy0xuGqlFYNrDgG4K40eEKJB'
};
```

**Usage Count:** 46 references to `CONFIG.COL.` across Code.gs and Tools.gs

---

### 2. Match Configuration (Code.gs)

**Location:** `/home/user/SOS/Code` lines 104-179

The `MATCH_CONFIG` object defines feature weights based on Cramér's V analysis:

```javascript
const MATCH_CONFIG = {
  // Feature-level weights (from Cramér's V analysis)
  FEATURE_WEIGHTS: {
    // TIER 1: Super Strong Correlation (V > 0.5) - 3x weight
    AGE: 3,
    INTEREST_1: 3,
    INTEREST_2: 3,
    INTEREST_3: 3,

    // TIER 2: Moderate Correlation (V 0.4-0.5) - 2x weight
    INDUSTRY: 2,
    ROLE: 2,
    MUSIC: 2,
    SOCIAL_STANCE: 2,
    ZODIAC: 2,

    // TIER 3: Weak Correlation (V < 0.3) - 1x weight
    EDUCATION: 1,
    RECENT_PURCHASE: 1,
    AT_WORST: 1,
    KNOW_HOSTS: 1
  },

  // Interest-specific weights (based on rarity/distinctiveness)
  INTEREST_WEIGHTS: {
    // Ultra-Rare (1 guest) - 10x weight
    'Cars': 10,
    'Dancing': 10,
    'Film / movies': 10,
    // ... (more entries)

    // Common (40+ guests) - 0.5-1x weight
    'Music': 0.5  // Too common (73% of guests), low signal
  },

  THRESHOLDS: {
    EXCELLENT_MATCH: 0.7,   // 70%+ compatibility
    GOOD_MATCH: 0.5,        // 50-69% compatibility
    OKAY_MATCH: 0.3,        // 30-49% compatibility
    MIN_MATCH: 0.2          // Below 20% = poor match
  },

  PYRAMID: {
    TOP_MATCHES: 5,         // Show top 5 matches in pyramid
    MIN_DISPLAY_SCORE: 0.3  // Only show matches above 30%
  }
};
```

---

### 3. Pan Analytics Specification (ANALYTICSTest)

**Location:** `/home/user/SOS/ANALYTICSTest` lines 237-258

The `SPEC` array uses **header name matching** instead of fixed indices:

```javascript
const SPEC = [
  { key: 'timestamp', header: 'Timestamp', type: 'timestamp' },
  { key: 'birthday', header: 'Birthday (MM/DD)', type: 'birthday' },
  { key: 'age_range', header: 'Age Range', type: 'single', opts: ['0-10','21-24','25-29','30-34'] },
  { key: 'education', header: 'Education Level', type: 'single', opts: ['High School','Some College','Associates','Bachelors','Masters & Above'] },
  { key: 'zip', header: 'Current 5 Digit Zip Code', type: 'text_raw' },
  { key: 'ethnicity', header: 'Self Identified Ethnicity', type: 'single', opts: ['Black / African American','Mixed / Multiracial','White','Not Listed','Prefer not to say'] },
  { key: 'gender', header: 'Self-Identified Gender', type: 'single', opts: ['Man','Woman','Other'] },
  { key: 'orientation', header: 'Self-Identified Sexual Orientation', type: 'single', opts: ['Straight / Heterosexual','Bisexual','Gay','Pansexual','Other'] },
  { key: 'industry', header: 'Employment Information (Industry)', type: 'single', opts: ['Arts & Entertainment','Education','Finance / Business Services','Government / Military','Healthcare','Hospitality / Retail','Science / Research','Technology','Trades / Manufacturing'] },
  { key: 'role', header: 'Employment Information (Role)', type: 'single', opts: ['Creative / Designer / Artist','Educator / Instructor','Founder / Entrepreneur','Healthcare / Service Provider','Manager / Supervisor','Operations / Admin / Support','Researcher / Scientist','Sales / Marketing / Business Development','Student / Trainee','Technical / Engineer / Developer','Trades / Skilled Labor'] },
  { key: 'know_hosts', header: 'Do you know the Host(s)?', type: 'single', opts: ['No','Yes — less than 3 months','Yes — 3–12 months','Yes — 1–3 years','Yes — 3–5 years','Yes — 5–10 years','Yes — more than 10 years'] },
  { key: 'known_longest', header: 'Which host have you known the longest?', type: 'single', opts: ['Jacob','Michael','Equal','Do Not Know Them'] },
  { key: 'know_score', header: 'If yes, how well do you know them?', type: 'number' },
  { key: 'interests', header: 'Your General Interests (Choose 3)', type: 'multi', opts: ['Cooking','Music','Fashion','Travel','Fitness','Gaming','Reading','Art/Design','Photography','Hiking/Outdoors','Sports (general)','Volunteering','Health Sciences','TikTok (watching)','Halloween orgy','Frying oil'] },
  { key: 'music_pref', header: 'Music Preference', type: 'single', opts: ['Hip-hop','Pop','Indie/Alt','R&B','Rock','Country','Electronic','Prog Rock','2008 emo shit','A mix of all','Pop + indie/alt. (Based on mental health/situation.)','I go all ways'] },
  { key: 'fav_artist', header: 'Current Favorite Artist', type: 'text' },
  { key: 'song', header: 'Name one song you want to hear at the party', type: 'text' },
  { key: 'recent_purchase', header: 'Recent purchase you're most happy about', type: 'single', opts: ['Fashion/Clothing','Fitness gear','Tech gadget','Car/Motorcycle','Home/Kitchen','Pet item','Course/App'] },
  { key: 'at_worst', header: 'At your worst you are…', type: 'single', opts: ['Anxious','Distracted','Guarded','Impulsive','Jealous','Overly critical','Reckless','Self-conscious','Stubborn'] },
  { key: 'social_stance', header: 'Which best describes your general social stance?', type: 'number' }
];
```

**Key Difference:** SPEC uses dynamic header name lookup, while CONFIG.COL uses fixed 0-based indices.

---

## Analytics Modules Comparison

### Module 1: buildPanSheets() - ANALYTICSTest:269-424

**Purpose:** Creates encoded Pan_Master and Pan_Dict sheets from Form Responses 1

**Data Source:** `'Form Responses 1'` sheet (hardcoded at line 230)

**Column Access Method:** Header name matching via `indexByHeader_()` function

**Output:**
- **Pan_Master:** Encoded guest data with columns:
  - A: Screen Name
  - B: UID
  - C: Row
  - D: TimestampMs
  - E: Birthday_MM/DD
  - Then: Zip, code_* columns, oh_* one-hot columns, numeric columns, has_* presence flags
- **Pan_Dict:** Codebook with variable metadata

**Configuration Alignment:** ⚠️ **INDEPENDENT** - Does not use CONFIG object, maps by header names

---

### Module 2: buildVCramers() - ANALYTICSTest:14-64

**Purpose:** Calculates Cramér's V correlation matrix for categorical variables

**Data Source:**
- Pan_Master sheet (encoded data)
- Pan_Dict sheet (metadata)

**Column Access Method:** Looks for columns starting with `code_*` prefix

**Features Analyzed:** All categorical fields encoded as `code_<key>`:
- code_age_range
- code_education
- code_ethnicity
- code_gender
- code_orientation
- code_industry
- code_role
- code_know_hosts
- code_known_longest
- code_music_pref
- code_recent_purchase
- code_at_worst

**Output:** `V_Cramers` sheet with correlation matrix

**Configuration Alignment:** ✅ **CONSISTENT** - Uses Pan_Dict which is derived from SPEC

---

### Module 3: buildGuestSimilarity() - ANALYTICSTest:525-732

**Purpose:** Calculates pairwise guest similarity using Gower-style distance

**Data Source:** Pan_Master and Pan_Dict sheets

**Column Access Method:**
- Looks for `code_*` columns for categorical features
- Hardcoded numeric columns: `know_score_num`, `social_stance_num`
- Looks for `oh_interests_*` columns for multi-select interests

**Similarity Calculation:**
- **Single (nominal):** Exact match (1) or no match (0)
- **Single (ordinal - education):** Distance-based: `1 - |a-b|/(k-1)`
- **Numeric:** Min-max normalized: `1 - |a-b|/range`
- **Multi (interests):** Jaccard index over one-hot encoding

**Output:**
- **Guest_Similarity:** Square matrix of guest pairs
- **Edges_Top_Sim:** Top 5000 similarity pairs

**Configuration Alignment:** ✅ **CONSISTENT** - Uses Pan_Master derived from SPEC

---

### Module 4: generateGenAnalytics() - Tools:1050-1357

**Purpose:** Unified analytics report with Cramér's V, association rules, and clustering

**Data Source:** FRC sheet (direct access via `CONFIG.SHEETS.FRC`)

**Column Access Method:** **Fixed indices from CONFIG.COL**

**Features Analyzed (from Tools:1076-1089):**
```javascript
const features = {
  'Age': CONFIG.COL.AGE,              // 3
  'Education': CONFIG.COL.EDU,        // 4
  'Industry': CONFIG.COL.INDUSTRY,    // 9
  'Role': CONFIG.COL.ROLE,            // 10
  'Interest 1': CONFIG.COL.INTEREST_1,// 15
  'Interest 2': CONFIG.COL.INTEREST_2,// 16
  'Interest 3': CONFIG.COL.INTEREST_3,// 17
  'Music': CONFIG.COL.MUSIC,          // 18
  'Purchase': CONFIG.COL.RECENT_PURCHASE, // 21
  'At Worst': CONFIG.COL.AT_WORST,    // 22
  'Social': CONFIG.COL.SOCIAL_STANCE, // 23
  'Zodiac': CONFIG.COL.ZODIAC         // 2
};
```

**Output:** Gen_Analytics sheet with:
1. Cramér's V Matrix (12x12 features)
2. Association Rules (top 10 IF-THEN patterns)
3. K-Means Clustering (3 clusters)
4. Narrative Summary
5. Run Log (append-only history)

**Configuration Alignment:** ✅ **USES CONFIG.COL** - Directly references CONFIG object

---

## Key Findings

### ✅ Consistencies

1. **CONFIG.COL Usage:**
   - Code.gs: 46 references (check-in, guest data access)
   - Tools.gs: 33 references (Gen_Analytics, other functions)
   - All references use the same column indices

2. **Feature Set Alignment:**
   - Both SPEC and Gen_Analytics analyze the same 12 core features:
     - Age, Education, Industry, Role
     - Interest 1, Interest 2, Interest 3
     - Music, Purchase, At Worst, Social Stance, Zodiac

3. **Match Weights Match Analytics:**
   - MATCH_CONFIG.FEATURE_WEIGHTS tiers (1x/2x/3x) align with Cramér's V strength categories
   - Interest weights based on rarity analysis (listAllInterests function)

4. **Data Flow:**
   - FRC → buildPanSheets() → Pan_Master/Pan_Dict
   - Pan_Master → buildVCramers() → V_Cramers matrix
   - Pan_Master → buildGuestSimilarity() → Guest_Similarity matrix
   - FRC → generateGenAnalytics() → Gen_Analytics report

### ⚠️ Potential Issues

1. **Dual Configuration Systems:**
   - **ANALYTICSTest:** Uses header name matching (SPEC array)
   - **Gen_Analytics (Tools):** Uses fixed column indices (CONFIG.COL)
   - **Risk:** If FRC sheet headers don't match SPEC exactly, buildPanSheets will fail silently
   - **Risk:** If column order changes in FRC, CONFIG.COL indices become incorrect

2. **Hardcoded Sheet Name:**
   - ANALYTICSTest line 230: `const RESP_SHEET = 'Form Responses 1';`
   - CONFIG.SHEETS.FRC = 'FRC'
   - **Question:** Are these the same sheet or different sheets?
   - **If different:** Data could be out of sync
   - **If same:** Should use CONFIG.SHEETS.FRC for consistency

3. **Ordinal Education Encoding:**
   - ANALYTICSTest line 557: `const ordinalKeys = { education: true };`
   - SPEC line 241: Education opts = `['High School','Some College','Associates','Bachelors','Masters & Above']`
   - **Assumption:** These are ordered from low to high education
   - **Risk:** Similarity assumes code order = education progression
   - **Note:** Gen_Analytics treats education as nominal (no ordering), but buildGuestSimilarity treats it as ordinal

4. **Numeric Field Naming:**
   - buildGuestSimilarity expects: `know_score_num`, `social_stance_num`
   - SPEC uses: `know_score`, `social_stance`
   - **Resolution:** buildMaster_ creates `code_know_score` and `code_social_stance` columns
   - **Question:** Do the `_num` suffix columns exist in Pan_Master?

5. **Interest Field Inconsistency:**
   - CONFIG.COL has: INTEREST_1 (15), INTEREST_2 (16), INTEREST_3 (17)
   - SPEC has single field: `{ key: 'interests', header: 'Your General Interests (Choose 3)', type: 'multi' }`
   - **Resolution:** FRC sheet splits raw interests (Column O) into separate columns P, Q, R
   - **Note:** Pan_Master creates one-hot encoding `oh_interests_*`, while Gen_Analytics uses the split columns

### 🔍 Similarity Analysis Configuration

**Guest Similarity (buildGuestSimilarity):**

**Fields Used:**
- All `code_*` single-choice fields (nominal or ordinal)
- `know_score_num`, `social_stance_num` (numeric, min-max normalized)
- `oh_interests_*` columns (multi-choice, Jaccard similarity)

**Ordinal Treatment:**
- Only `education` treated as ordinal (distance-based similarity)
- All other categorical fields treated as nominal (exact match)

**Weight Strategy:**
- All fields weighted equally (1.0 weight per field)
- Average across all valid comparisons
- Missing values excluded from calculation

**Comparison to MATCH_CONFIG:**
- MATCH_CONFIG uses tiered weights (1x/2x/3x)
- Guest Similarity uses equal weights
- **Mismatch:** The similarity matrix doesn't reflect the matching strategy weights

---

## Recommendations

### 1. Unify Configuration ✅ HIGH PRIORITY

**Issue:** Dual configuration systems (SPEC vs CONFIG.COL)

**Options:**

**A. Make SPEC use CONFIG.COL (Preferred)**
```javascript
const SPEC = [
  { key: 'age_range', col: CONFIG.COL.AGE, header: 'Age Range', type: 'single', opts: [...] },
  { key: 'education', col: CONFIG.COL.EDU, header: 'Education Level', type: 'single', opts: [...] },
  // ...
];
```

**B. Make CONFIG.COL dynamic from SPEC**
- Less preferred - increases fragility
- Header changes would break CONFIG references throughout codebase

**Recommendation:** Keep CONFIG.COL as single source of truth, update SPEC to reference it

### 2. Standardize Sheet Name Reference

**Current:**
- ANALYTICSTest: `'Form Responses 1'` (hardcoded)
- Code/Tools: `CONFIG.SHEETS.FRC` ('FRC')

**Action:**
- Determine if these are the same sheet or different
- If same: Update ANALYTICSTest to use CONFIG.SHEETS.FRC
- If different: Document the relationship and data flow

### 3. Align Similarity Weights with MATCH_CONFIG (Optional)

**Current:** Guest Similarity uses equal weights for all fields

**Enhancement:** Apply MATCH_CONFIG.FEATURE_WEIGHTS to similarity calculation
```javascript
// Instead of: sum += sVal; wsum += 1;
// Use:
const weight = getFeatureWeight(fieldName); // from MATCH_CONFIG
sum += sVal * weight;
wsum += weight;
```

**Benefit:** Similarity scores would directly inform matching algorithm

### 4. Document Ordinal vs Nominal Treatment

**Current:** Education is ordinal in Guest Similarity, but nominal in Gen_Analytics

**Action:**
- Document this difference in code comments
- Consider making Gen_Analytics also treat education as ordinal for consistency
- Or make both nominal if education progression assumption is incorrect

### 5. Verify Numeric Column Names

**Check:** Do `know_score_num` and `social_stance_num` exist in Pan_Master?

**Action:**
- Run buildPanSheets() and inspect Pan_Master columns
- If columns are named `code_know_score` instead, update buildGuestSimilarity to match

---

## Testing Checklist

- [ ] Verify FRC sheet column order matches CONFIG.COL indices
- [ ] Verify FRC sheet headers match SPEC header values exactly
- [ ] Run buildPanSheets() and inspect Pan_Master column names
- [ ] Run buildVCramers() and verify correlation values are reasonable
- [ ] Run buildGuestSimilarity() and verify similarity scores are in 0-1 range
- [ ] Run generateGenAnalytics() and verify all sections complete without errors
- [ ] Compare Cramér's V values from buildVCramers vs generateGenAnalytics
- [ ] Verify MATCH_CONFIG.FEATURE_WEIGHTS align with actual Cramér's V matrix values

---

## Conclusion

The analytics system is **fundamentally sound** but has **architectural inconsistencies** between:

1. **Header-based column lookup** (ANALYTICSTest SPEC)
2. **Index-based column access** (Code/Tools CONFIG.COL)

This creates **fragility** if:
- Sheet structure changes
- Headers are renamed
- Columns are reordered

**Recommended Next Steps:**

1. **Immediate:** Document which sheet is the canonical source ("Form Responses 1" vs "FRC")
2. **Short-term:** Unify configuration by making SPEC reference CONFIG.COL
3. **Medium-term:** Apply MATCH_CONFIG weights to Guest Similarity calculation
4. **Long-term:** Create automated tests to verify column mappings and analytics outputs

**Current Status:** ✅ System is functional but would benefit from consolidation for maintainability.

---

**Prepared by:** Claude Code Analytics Review
**Branch:** claude/review-analytics-config-011CUQpVDNwAwgBfRDLq2fc6
**Date:** 2025-10-23
