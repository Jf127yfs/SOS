# Sheet Relationships and Data Flow

**Project:** SOS - Panopticon Analytics System
**Date:** 2025-10-23
**Status:** Configuration Aligned

---

## Overview

This document clarifies the relationship between different sheets in the system and how data flows through the analytics pipeline.

---

## Sheet Inventory

### Primary Data Sheets

#### 1. **Form Responses 1** (Raw Google Forms Data)
- **Type:** Source data (unprocessed)
- **Created by:** Google Forms automatically
- **Used by:**
  - `buildPanSheets()` (ANALYTICSTest) - as source for Pan_Master
  - `createResponseDictionary()` (Tools) - to analyze response patterns
- **Structure:** Raw form responses with all columns as submitted
- **Do NOT modify manually** - this is the original data source

#### 2. **FRC** (Form Responses Clean)
- **Type:** Processed/cleaned data
- **Created by:** Manual data cleaning or automated process
- **Used by:**
  - Main application (Code.gs) - check-in, guest management
  - `generateGenAnalytics()` (Tools) - analytics reporting
  - All display and operational functions
- **Structure:** Cleaned and normalized version of Form Responses 1
- **Additional columns:** May include computed fields like Checked-In, Photo URLs, etc.

**Key Difference:**
- **Form Responses 1:** Raw data from Google Forms (immutable)
- **FRC:** Cleaned data for operational use (may have additional columns)

---

## Derived Analytics Sheets

### Pan_Master
- **Created by:** `buildPanSheets()` function in ANALYTICSTest
- **Source:** Form Responses 1 (or FRC via CONFIG)
- **Purpose:** Encoded analysis dataset
- **Structure:**
  ```
  Column A: Screen Name
  Column B: UID
  Column C: Row (original row number)
  Column D: TimestampMs (epoch milliseconds)
  Column E: Birthday_MM/DD (normalized MM/DD format)
  Then: Encoded fields...
    - Zip (text, as-is)
    - code_<key> columns (categorical codes: 1, 2, 3, ...)
    - oh_interests_<option> (one-hot: 0 or 1)
    - has_<key> columns (text presence: 0 or 1)
  ```
- **Key Features:**
  - Last occurrence per UID wins (deduplication)
  - Categorical fields encoded as numeric codes
  - Multi-select interests as one-hot encoding
  - Text fields as presence flags (1 = has text, 0 = empty)

### Pan_Dict
- **Created by:** `buildPanSheets()` function in ANALYTICSTest
- **Source:** SPEC array configuration
- **Purpose:** Codebook / data dictionary
- **Structure:**
  ```
  Columns: Key | Header | Type | Option | Code | Note
  ```
- **Contents:**
  - Maps each SPEC field to its encoding scheme
  - Lists all possible options for single-choice fields
  - Documents multi-select options with codes
  - Notes about missing or unavailable fields

### V_Cramers
- **Created by:** `buildVCramers()` function in ANALYTICSTest
- **Source:** Pan_Master + Pan_Dict
- **Purpose:** Cramér's V correlation matrix (categorical associations)
- **Structure:** Square matrix with feature labels
- **Interpretation:**
  - 0.0-0.1: No association
  - 0.1-0.3: Weak association
  - 0.3-0.5: Moderate association
  - 0.5+: Strong association

### Guest_Similarity
- **Created by:** `buildGuestSimilarity()` function in ANALYTICSTest
- **Source:** Pan_Master + Pan_Dict
- **Purpose:** Pairwise guest similarity matrix
- **Structure:** Square matrix labeled "Screen Name (UID)"
- **Calculation:** Gower-style distance
  - Nominal fields: 1 if match, 0 otherwise
  - Ordinal (education): 1 - |a-b|/(k-1)
  - Numeric: 1 - |a-b|/range
  - Multi (interests): Jaccard index
  - Result: Average across all valid fields
- **Range:** 0.0 (no similarity) to 1.0 (identical)

### Edges_Top_Sim
- **Created by:** `buildGuestSimilarity()` function in ANALYTICSTest
- **Source:** Guest_Similarity matrix
- **Purpose:** Top 5000 guest pairs by similarity
- **Structure:** source | target | similarity
- **Use case:** Network visualization, match recommendations

### Gen_Analytics
- **Created by:** `generateGenAnalytics()` function in Tools
- **Source:** FRC sheet (direct access via CONFIG.COL)
- **Purpose:** Unified analytics report
- **Structure:** Multi-section report
  1. Header (metadata: date, guest count, features)
  2. Cramér's V Matrix (12x12 feature correlations)
  3. Association Rules (top 10 IF-THEN patterns)
  4. K-Means Clustering (3 clusters with profiles)
  5. Narrative Summary (auto-generated insights)
  6. Run Log (append-only history)

### Response_Pan_Dictionary
- **Created by:** `createResponseDictionary()` function in Tools
- **Source:** Form Responses 1 (original form data)
- **Purpose:** Response frequency analysis and code assignment
- **Structure:** Sheet | Column Header | Column | Response | Code | Count | Notes
- **Use case:** Understand response distributions, validate encoding

---

## Data Flow Diagram

```
┌─────────────────────────┐
│  Form Responses 1       │  (Raw Google Forms data)
│  (Original source)      │
└───────────┬─────────────┘
            │
            ├────────────────────────────┐
            │                            │
            ↓                            ↓
┌─────────────────────────┐  ┌─────────────────────────┐
│  FRC                    │  │  buildPanSheets()       │
│  (Cleaned for ops)      │  │  (ANALYTICSTest)        │
└───────────┬─────────────┘  └───────────┬─────────────┘
            │                            │
            │                            ↓
            │                ┌─────────────────────────┐
            │                │  Pan_Master + Pan_Dict  │
            │                │  (Encoded data)         │
            │                └───────────┬─────────────┘
            │                            │
            │                            ├─────────────────────────┐
            │                            │                         │
            │                            ↓                         ↓
            │                ┌─────────────────────────┐  ┌──────────────────┐
            │                │  buildVCramers()        │  │ buildGuestSimilarity() │
            │                │  → V_Cramers            │  │ → Guest_Similarity │
            │                └─────────────────────────┘  │ → Edges_Top_Sim   │
            │                                              └──────────────────┘
            │
            ↓
┌─────────────────────────┐
│  generateGenAnalytics() │  (Uses CONFIG.COL directly)
│  → Gen_Analytics        │
└─────────────────────────┘
```

---

## Configuration Systems

### CONFIG Object (Code.gs)
```javascript
CONFIG = {
  SHEETS: {
    FRC: 'FRC'  // Target: cleaned operational data
  },
  COL: {
    TIMESTAMP: 0,   // Column A
    BIRTHDAY: 1,    // Column B
    AGE: 3,         // Column D
    // ... (30 total columns)
  }
}
```
- **Access method:** Fixed column indices (0-based)
- **Used by:** Code.gs, Tools.gs (Gen_Analytics, listAllInterests)
- **Philosophy:** Fast direct access, assumes column order is stable

### SPEC Array (ANALYTICSTest)
```javascript
SPEC = [
  { key: 'age_range', header: 'Age Range', type: 'single', opts: [...] },
  { key: 'education', header: 'Education Level', type: 'single', opts: [...] },
  // ... (20 fields)
]
```
- **Access method:** Header name matching
- **Used by:** buildPanSheets(), buildVCramers(), buildGuestSimilarity()
- **Philosophy:** Flexible, works even if columns reorder, but requires exact header match

### MATCH_CONFIG Object (Code.gs)
```javascript
MATCH_CONFIG = {
  FEATURE_WEIGHTS: {
    AGE: 3,          // Tier 1: Strong correlation
    INDUSTRY: 2,     // Tier 2: Moderate
    EDUCATION: 1     // Tier 3: Weak
  },
  INTEREST_WEIGHTS: {
    'Cars': 10,      // Ultra-rare
    'Music': 0.5     // Common
  },
  THRESHOLDS: {...},
  PYRAMID: {...}
}
```
- **Purpose:** Matchmaking algorithm configuration
- **Based on:** Cramér's V analysis and frequency analysis
- **Used by:** (Future) Pyramid Match algorithm

---

## Configuration Alignment

### ✅ Now Aligned (as of 2025-10-23)

1. **Sheet Name References:**
   - ANALYTICSTest now checks for CONFIG.SHEETS.FRC first, falls back to 'Form Responses 1'
   - Comment clarifies which functions intentionally use raw vs clean data
   - Tools.gs consistently uses CONFIG.SHEETS.FRC

2. **Feature Sets:**
   - Both CONFIG.COL and SPEC define the same 12 core features for analysis
   - Gen_Analytics uses: Age, Education, Industry, Role, Interest 1-3, Music, Purchase, At Worst, Social, Zodiac
   - Pan encoding supports: All fields from SPEC (broader coverage)

3. **Documentation:**
   - Clear comments explain when to use Form Responses 1 vs FRC
   - VerifySheetStructure script available to check alignment
   - TestAnalyticsAlignment script validates all configurations

### ⚠️ Known Differences (By Design)

1. **Education Field Treatment:**
   - **Guest Similarity (buildGuestSimilarity):** Treats education as **ordinal** (ordered: High School < College < Bachelors < Masters)
   - **Gen_Analytics (generateGenAnalytics):** Treats education as **nominal** (categories without inherent order)
   - **Reason:** Different analytical purposes - similarity cares about education progression, correlations care about category associations

2. **Weight Application:**
   - **Guest Similarity:** Equal weight for all fields (simple average)
   - **MATCH_CONFIG:** Tiered weights (1x/2x/3x based on Cramér's V strength)
   - **Reason:** Similarity is descriptive (what is similar), MATCH_CONFIG is prescriptive (what should match)

3. **Interest Encoding:**
   - **Pan_Master:** One-hot encoding (oh_interests_Music = 1 or 0)
   - **FRC:** Split columns (Interest_1, Interest_2, Interest_3 as separate text fields)
   - **Reason:** Different analytical needs - one-hot for set operations, split for categorical analysis

---

## Verification Checklist

Before running analytics, verify:

- [ ] Run `VerifySheetStructure.verifySheetStructure()` to check sheet structure
- [ ] Run `TestAnalyticsAlignment.runAllTests()` to validate configurations
- [ ] Check that FRC sheet has at least 1 guest with Timestamp
- [ ] Check that Form Responses 1 exists (if using buildPanSheets)
- [ ] Verify CONFIG.COL indices match actual FRC column order
- [ ] Verify SPEC headers match actual Form Responses 1 headers

---

## Function Reference

### Analytics Functions by Sheet

| Function | Source Sheet | Output Sheet(s) | Module |
|----------|-------------|----------------|--------|
| `buildPanSheets()` | Form Responses 1 or FRC | Pan_Master, Pan_Dict | ANALYTICSTest |
| `buildVCramers()` | Pan_Master, Pan_Dict | V_Cramers | ANALYTICSTest |
| `buildGuestSimilarity()` | Pan_Master, Pan_Dict | Guest_Similarity, Edges_Top_Sim | ANALYTICSTest |
| `generateGenAnalytics()` | FRC | Gen_Analytics | Tools |
| `listAllInterests()` | FRC | Interests_List | Tools |
| `createResponseDictionary()` | Form Responses 1 | Response_Pan_Dictionary | Tools |

### Configuration Access Patterns

| Module | Config Type | Access Method | Priority |
|--------|-------------|---------------|----------|
| Code.gs | CONFIG.COL | Fixed index | Always |
| Tools.gs | CONFIG.COL | Fixed index | Always |
| ANALYTICSTest (buildPanSheets) | SPEC | Header match | Always |
| ANALYTICSTest (buildVCramers) | code_* pattern | Column prefix | Always |
| ANALYTICSTest (buildGuestSimilarity) | code_*, oh_* | Column prefix | Always |

---

## Troubleshooting

### Issue: "FRC sheet not found"
**Solution:**
- Check if sheet is named 'FRC' or 'Form Responses (Clean)'
- Update CONFIG.SHEETS.FRC to match actual sheet name
- Or rename sheet to 'FRC'

### Issue: "Column index out of bounds"
**Solution:**
- Run `VerifySheetStructure` to check column alignment
- Verify FRC sheet has all expected columns (A through AD minimum)
- Check if columns were reordered - update CONFIG.COL if needed

### Issue: "Header not found" in buildPanSheets
**Solution:**
- Check SPEC headers match Form Responses 1 exactly (case-sensitive)
- Look at SPEC line 237-258 for expected header names
- Update SPEC headers if form questions changed

### Issue: Pan_Master has wrong column names
**Solution:**
- Check SPEC array for typos in 'key' field
- Verify SPEC 'type' field is correct (single, multi, number, text, text_raw)
- Re-run buildPanSheets() after fixing SPEC

### Issue: Cramér's V returns 0 or NaN
**Solution:**
- Check data has variation (not all same value)
- Verify categorical fields have at least 2 unique values
- Check for null/empty values in columns
- Run with generateGenAnalytics() which has better error handling

---

## Best Practices

1. **Keep Form Responses 1 immutable** - never edit the raw form data
2. **Use FRC for operations** - clean data once, use everywhere
3. **Regenerate Pan sheets after data changes** - run buildPanSheets() when form data updates
4. **Test after config changes** - run TestAnalyticsAlignment after editing CONFIG or SPEC
5. **Document custom encodings** - if you add fields, update SPEC and Pan_Dict
6. **Version your configs** - commit CONFIG and SPEC changes to git

---

## Future Enhancements

### Recommended Improvements

1. **Unify Configuration:**
   - Make SPEC reference CONFIG.COL for column indices
   - Add validation that SPEC headers match FRC headers
   - Create shared constants file

2. **Apply MATCH_CONFIG to Similarity:**
   - Weight fields in Guest_Similarity based on MATCH_CONFIG.FEATURE_WEIGHTS
   - Make similarity scores directly inform matching algorithm

3. **Automated Sync:**
   - Trigger to auto-regenerate Pan sheets when Form Responses 1 updates
   - Validation checks before analytics run

4. **Enhanced Error Handling:**
   - Graceful degradation when columns missing
   - Detailed error messages with fix suggestions
   - Automatic column mapping detection

---

**Last Updated:** 2025-10-23
**Maintained by:** SOS Analytics Team
**Questions:** See ANALYTICS_CONFIG_REVIEW.md for technical details
