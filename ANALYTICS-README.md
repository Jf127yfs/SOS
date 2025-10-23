# 🔬 ANALYTICS README - Matchmaking Algorithm Design

**Project:** Pyramid Match (PM) - Guest Compatibility System
**Date Started:** October 23, 2025
**Status:** 🏗️ In Development - Algorithm Design Phase

---

## 📋 Project Overview

### Vision
Create a **pyramid visualization** where:
- **Top:** Selected guest (photo from PHOTO_URL)
- **Below:** Best matches displayed underneath
- **Fanning Out:** Matches spread out as compatibility decreases
- **Visual Appeal:** Tree/pyramid structure for intuitive understanding

### Page Details
- **URL:** `?page=pm` (Pyramid Match)
- **Page Name:** `PyramidMatch.html` (or similar)
- **Backend:** Matching functions in Code.gs or separate file
- **Config:** `MATCH_CONFIG` object (separate from CONFIG)

---

## 🎯 Matching Algorithm - Brainstorming Space

### Available Guest Data (from CONFIG.COL)

| Attribute | Column | Type | Examples | Matchable? |
|-----------|--------|------|----------|------------|
| Age Range | D (3) | Text | "21-24", "25-29", "30-34" | ✅ Yes |
| Education | E (4) | Text | "High School", "Some College", "Masters" | ✅ Yes |
| Zip Code | F (5) | Number | 64110, 64111, 64106 | ✅ Yes (proximity) |
| Ethnicity | G (6) | Text | Various | 🤔 Consider |
| Gender | H (7) | Text | "Man", "Woman", "Other" | 🤔 Consider |
| Orientation | I (8) | Text | "Gay", "Bisexual", etc. | ⚠️ Privacy concern |
| Industry | J (9) | Text | "Finance", "Education", "Tech" | ✅ Yes |
| Role | K (10) | Text | "Operations", "Creative", etc. | ✅ Yes |
| Know Hosts | L (11) | Text | "Yes - 5-10 years", "No" | ✅ Yes |
| Know Score | N (13) | Number | 1-5 scale | ✅ Yes |
| Interest 1 | P (15) | Text | "Music", "Fitness", "Gaming" | ✅ Yes |
| Interest 2 | Q (16) | Text | "Cooking", "Reading", "Travel" | ✅ Yes |
| Interest 3 | R (17) | Text | "Art/Design", "Fashion", etc. | ✅ Yes |
| Music Preference | S (18) | Text | "R&B", "Pop", "Indie/Alt" | ✅ Yes |
| Artist | T (19) | Text | "SZA", "Miley Cyrus", etc. | ✅ Yes |
| Recent Purchase | V (21) | Text | "Tech gadget", "Pet item" | ✅ Yes |
| At Worst | W (22) | Text | "Stubborn", "Impulsive", "Anxious" | ✅ Yes |
| Social Stance | X (23) | Number | 1-5 (Introvert to Extrovert) | ✅ Yes |
| Zodiac Sign | C (2) | Text | "Taurus", "Leo", "Virgo" | ✅ Yes |

---

## 🧮 Algorithm Design Questions

### 1. **Matching Philosophy**
- [ ] **Similar matching** - People with same interests/traits?
- [ ] **Complementary matching** - Opposites attract (e.g., introvert + extrovert)?
- [ ] **Balanced matching** - Mix of both?
- [ ] **Your approach:** ___________________________

### 2. **Weighting Strategy**
Which attributes matter most? (Assign weights 1-10, 10 = most important)

```
Shared Interests:     ___ / 10  (they have common hobbies)
Music Taste:          ___ / 10  (similar music preference)
Social Compatibility: ___ / 10  (intro/extrovert balance)
Industry/Career:      ___ / 10  (professional connection)
Age Proximity:        ___ / 10  (similar age range)
Zodiac Compatibility: ___ / 10  (astrological match)
Education Level:      ___ / 10  (similar education)
Geographic Proximity: ___ / 10  (nearby zip codes)
"At Worst" Traits:    ___ / 10  (compatible flaws)
Know Hosts:           ___ / 10  (social circle overlap)
```

### 3. **Scoring Method**

**Option A: Simple Additive**
```
Score = (shared_interests × weight) + (music_match × weight) + ...
```

**Option B: Percentage Match**
```
Score = (matched_attributes / total_attributes) × 100
```

**Option C: Tiered Scoring**
```
Tier 1 (Must Have): Interests, Music (heavy weight)
Tier 2 (Nice to Have): Industry, Education (medium weight)
Tier 3 (Bonus): Zodiac, Purchase type (light weight)
```

**Option D: Custom Formula**
```
Your formula: ___________________________
```

### 4. **Match Thresholds**

How many matches to show?
- **Level 1 (Closest):** Top ___ matches (directly under guest)
- **Level 2 (Good):** Next ___ matches (second tier)
- **Level 3 (Potential):** Next ___ matches (third tier, optional)

Minimum score to display?
- **Cutoff score:** ___ / 100 (or your scale)

### 5. **Exclusion Rules**

Should we exclude matches based on:
- [ ] **Self:** Can't match with yourself
- [ ] **Already connected:** If they already know each other?
- [ ] **Privacy:** Exclude orientation from algorithm?
- [ ] **Gender preferences:** Consider at all?
- [ ] **Other:** ___________________________

---

## 🎨 Visualization Design

### Pyramid Structure

```
                    [GUEST A]
                    (Selected)
                        |
          +-------------+-------------+
          |                           |
      [Match 1]                   [Match 2]
      95% match                   92% match
          |                           |
    +-----+-----+               +-----+-----+
    |           |               |           |
[Match 3]   [Match 4]      [Match 5]   [Match 6]
88% match   85% match      84% match   82% match
```

### Visual Elements
- **Photos:** From PHOTO_URL (CONFIG.COL.PHOTO_URL = 29)
- **Screen Names:** From CONFIG.COL.SCREEN_NAME (24)
- **Match Score:** Display as percentage or visual indicator
- **Connection Lines:** Animated lines between guests
- **Hover Details:** Show why they match (shared interests, etc.)

---

## 🔧 Technical Architecture

### MATCH_CONFIG Object
```javascript
const MATCH_CONFIG = {
  // Algorithm settings (to be defined)
  WEIGHTS: {
    INTERESTS: 10,    // Your weight here
    MUSIC: 8,         // Your weight here
    SOCIAL_STANCE: 6, // Your weight here
    // ... more weights
  },

  // Display settings
  MAX_MATCHES_LEVEL_1: 3,  // Top tier matches
  MAX_MATCHES_LEVEL_2: 6,  // Second tier matches
  MINIMUM_SCORE: 50,       // Minimum % to display

  // Privacy settings
  EXCLUDE_ORIENTATION: true,
  EXCLUDE_SELF: true
};
```

### Backend Functions Needed
```javascript
// 1. Get all checked-in guests with matching attributes
getMatchableGuests()

// 2. Calculate compatibility score between two guests
calculateCompatibility(guestA, guestB)

// 3. Find best matches for a specific guest
findBestMatches(targetGuest, allGuests, topN)

// 4. Format match data for pyramid display
formatMatchesForPyramid(targetGuest, matches)
```

---

## 📊 Sample Algorithm Pseudocode

```javascript
function calculateCompatibility(guestA, guestB) {
  let score = 0;

  // Shared interests (highest weight?)
  const sharedInterests = countSharedInterests(guestA, guestB);
  score += sharedInterests * MATCH_CONFIG.WEIGHTS.INTERESTS;

  // Music compatibility
  if (guestA.music === guestB.music) {
    score += MATCH_CONFIG.WEIGHTS.MUSIC;
  }

  // Social stance compatibility (opposites or similar?)
  const stanceDiff = Math.abs(guestA.socialStance - guestB.socialStance);
  // TODO: Decide if closer is better or if opposites attract
  score += calculateSocialScore(stanceDiff);

  // ... more factors

  // Normalize to 0-100 scale
  return normalizeScore(score);
}
```

---

## 🤔 Questions to Answer Together

### Algorithm Design
1. **For Social Stance (1-5 scale):**
   - Similar is better? (both introverts or both extroverts)
   - Opposites attract? (introvert + extrovert = balance)
   - Middle ground? (both ambiverts)

2. **For Shared Interests:**
   - Need all 3 to match? (strict)
   - Any 1 match counts? (lenient)
   - More matches = better score? (proportional)

3. **For Age Range:**
   - Must be same range? ("25-29" + "25-29")
   - Adjacent ranges OK? ("25-29" + "30-34")
   - Age difference doesn't matter?

4. **For Music/Artist:**
   - Match on genre (Music) or specific artist?
   - Both count?
   - Weight differently?

5. **Geographic Proximity:**
   - Should nearby zip codes score higher?
   - How much does distance matter?
   - Metro vs non-metro consideration?

---

## ✅ Next Steps

### Phase 1: Algorithm Design (Current)
- [ ] Define matching philosophy
- [ ] Set attribute weights
- [ ] Choose scoring method
- [ ] Define exclusion rules
- [ ] Document algorithm logic

### Phase 2: Backend Implementation
- [ ] Create MATCH_CONFIG
- [ ] Build calculateCompatibility() function
- [ ] Build findBestMatches() function
- [ ] Test with sample data
- [ ] Document all functions

### Phase 3: Frontend Implementation
- [ ] Create PyramidMatch.html page
- [ ] Build pyramid visualization
- [ ] Add guest selection interface
- [ ] Display match scores and reasons
- [ ] Add animations and effects

### Phase 4: Integration & Testing
- [ ] Connect to CONFIG.COL data
- [ ] Test with real FRC data
- [ ] Verify PHOTO_URL displays
- [ ] Test different guest selections
- [ ] Performance optimization

### Phase 5: Documentation & Refinement
- [ ] Document final algorithm
- [ ] Add comments throughout code
- [ ] Create user guide
- [ ] Backup working version
- [ ] Deploy and monitor

---

## 💡 Ideas & Notes

**Brainstorming Space:**
```
(Add your thoughts, ideas, questions here as we work)

-
-
-
```

**Algorithm Iterations:**
```
Version 1.0: (To be defined)
Version 2.0: (Refinements)
```

**Testing Notes:**
```
- Test cases to try
- Edge cases to handle
- Performance considerations
```

---

## 📚 References

- **CONFIG Object:** See Code.gs lines 40-86
- **Column Mappings:** See SheetLocations file
- **Guest Data Structure:** See getCheckedInGuests() in Code.gs
- **Existing Wall Matching:** See WallData.gs for inspiration
- **Photo URLs:** CONFIG.COL.PHOTO_URL (Column AD, index 29)

---

**Last Updated:** October 23, 2025
**Status:** Ready for algorithm brainstorming session
**Next:** Define weights and matching philosophy together
