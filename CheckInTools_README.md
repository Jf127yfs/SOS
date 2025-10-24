# Check-In Tools Documentation

## Overview

The Check-In Tools provide automated functions to manage guest check-ins in the FRC sheet. These tools ensure that Column AB (Checked-In) is properly formatted with exactly "Y" for valid check-ins.

## Installation

1. **Copy CheckInTools.gs** to your Google Apps Script project
2. **Add menu items** to your `onOpen()` function in Code.gs:

```javascript
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('🛠️ Tools')
    .addSubMenu(ui.createMenu('✅ Check-In Tools')
      .addItem('✅ Check In All Guests', 'autoCheckInAll')
      .addSeparator()
      .addSubMenu(ui.createMenu('🎲 Check In Random Amount')
        .addItem('Custom Amount...', 'autoCheckInRandomPrompt')
        .addSeparator()
        .addItem('Check In 6 Guests', 'autoCheckIn6')
        .addItem('Check In 10 Guests', 'autoCheckIn10')
        .addItem('Check In 15 Guests', 'autoCheckIn15')
        .addItem('Check In 25 Guests', 'autoCheckIn25')
        .addItem('Check In 50 Guests', 'autoCheckIn50')
        .addItem('Check In 100 Guests', 'autoCheckIn100'))
      .addSeparator()
      .addItem('📊 Check-In Stats', 'showCheckInStats')
      .addSeparator()
      .addItem('❌ Clear All Check-Ins', 'clearAllCheckIns'))
    .addToUi();
}
```

3. **Reload the spreadsheet** to see the new menu

## Available Functions

### 1. ✅ Check In All Guests

**Function:** `autoCheckInAll()`

**What it does:**
- Checks in ALL guests who have both Screen Name (Column Y) and UID (Column Z)
- Sets Column AB (Checked-In) to exactly "Y"
- Sets Column AC (Check-In Time) to current timestamp

**When to use:**
- Before running MM or ALM pages
- To fix invalid check-in values (YES, TRUE, yes, etc.)
- After importing new guest data

**Returns:**
```javascript
{
  success: true,
  checkedIn: 150,
  message: 'Successfully checked in 150 guests'
}
```

---

### 2. 🎲 Check In Random Guests

**Function:** `autoCheckInRandom(count)`
**Menu Functions:**
- `autoCheckInRandomPrompt()` - Custom amount with prompt
- `autoCheckIn6()` - Check in exactly 6 guests
- `autoCheckIn10()` - Check in exactly 10 guests
- `autoCheckIn15()` - Check in exactly 15 guests
- `autoCheckIn25()` - Check in exactly 25 guests
- `autoCheckIn50()` - Check in exactly 50 guests
- `autoCheckIn100()` - Check in exactly 100 guests

**What it does:**
- Randomly selects and checks in a specified number of guests
- Useful for testing MM/ALM with realistic data
- Only selects guests with valid Screen Name and UID

**Parameters:**
- `count` (Number): Number of guests to check in (default: 10)

**Example:**
```javascript
autoCheckInRandom(25); // Check in 25 random guests

// Or use quick functions
autoCheckIn6();   // Check in 6 guests (MM minimum)
autoCheckIn15();  // Check in 15 guests
autoCheckIn25();  // Check in 25 guests
```

**Menu Usage:**
1. **Custom Amount:** Tools → Check-In Tools → Check In Random Amount → Custom Amount...
2. **Quick Buttons:** Tools → Check-In Tools → Check In Random Amount → Check In 6 Guests (or 10, 15, 25, 50, 100)

**Returns:**
```javascript
{
  success: true,
  checkedIn: 25,
  guests: ['Alice', 'Bob', 'Charlie', ...]
}
```

---

### 3. 📊 Check-In Stats

**Function:** `getCheckInStats()`
**Menu Function:** `showCheckInStats()`

**What it does:**
- Analyzes current check-in status
- Identifies invalid check-in values
- Shows breakdown of guest data

**Output:**
```
📊 CHECK-IN STATISTICS

Total rows: 200
Guests with data: 180

✅ Checked in with "Y": 150
⚠️ Checked in (other values): 5
Not checked in: 25

⚠️ WARNING: 5 guests have invalid check-in values!
Examples:
  Row 25: "Yes" (Alice Smith)
  Row 47: "TRUE" (Bob Jones)
  Row 89: "yes" (Charlie Brown)

Use "Check In All Guests" to fix this.
```

---

### 4. ❌ Clear All Check-Ins

**Function:** `clearAllCheckIns()`

**What it does:**
- Clears ALL check-ins (sets Column AB to empty)
- Clears all check-in timestamps (Column AC)
- Requires confirmation before proceeding

**When to use:**
- Resetting for a new event
- Testing from scratch
- Before importing fresh check-in data

**Safety:**
- Shows confirmation dialog before clearing
- Cannot be undone (use with caution)

---

### 5. Check In by UID

**Function:** `autoCheckInByUID(uid)`

**What it does:**
- Checks in a specific guest by their UID
- Programmatic access (call from script)

**Example:**
```javascript
autoCheckInByUID('abc123xyz');
```

**Returns:**
```javascript
{
  success: true,
  screenName: 'Alice Smith',
  message: 'Checked in: Alice Smith'
}
```

---

### 6. Check In by Screen Name

**Function:** `autoCheckInByScreenName(screenName)`

**What it does:**
- Checks in a specific guest by their screen name
- Case-insensitive matching

**Example:**
```javascript
autoCheckInByScreenName('Alice Smith');
```

**Returns:**
```javascript
{
  success: true,
  uid: 'abc123xyz',
  message: 'Checked in: Alice Smith'
}
```

---

## Column Reference

| Column | Letter | Index | Field | Description |
|--------|--------|-------|-------|-------------|
| Y | Y | 24 | Screen Name | Guest's display name |
| Z | Z | 25 | UID | Unique identifier |
| AB | AB | 27 | **Checked-In** | Must be exactly "Y" |
| AC | AC | 28 | Check-In Time | Timestamp (auto-set) |

---

## Common Issues & Solutions

### Issue: "Not enough people checked in"

**Cause:** Column AB doesn't contain exactly "Y"

**Solution:**
1. Run `Check-In Stats` to identify invalid values
2. Run `Check In All Guests` to fix all values
3. Refresh MM or ALM page

---

### Issue: Guests have invalid check-in values

**Examples of invalid values:**
- "Yes" ❌ (should be "Y" ✅)
- "TRUE" ❌ (should be "Y" ✅)
- "yes" ❌ (should be "Y" ✅)
- "1" ❌ (should be "Y" ✅)

**Solution:**
Run `Check In All Guests` to standardize all values to "Y"

---

### Issue: Some guests not appearing in MM/ALM

**Causes:**
1. Missing Screen Name (Column Y)
2. Missing UID (Column Z)
3. Column AB is empty or invalid

**Solution:**
1. Run `Check-In Stats` to identify missing data
2. Fill in missing Screen Name and UID
3. Run `Check In All Guests`

---

## Testing Workflow

### Scenario: Testing MM with different guest counts

```javascript
// Clear all check-ins
clearAllCheckIns();

// Check in 6 guests (MM minimum)
autoCheckInRandom(6);

// Test MM page... then add more

// Check in 10 more guests
autoCheckInRandom(10);

// Check stats
getCheckInStats();
```

---

### Scenario: Preparing for live event

```javascript
// Before event starts
clearAllCheckIns();

// As guests arrive, check them in
autoCheckInByScreenName('Alice Smith');
autoCheckInByScreenName('Bob Jones');

// Or check in all pre-registered guests
autoCheckInAll();
```

---

## Logging

All functions log to Apps Script Execution Log:

**To view logs:**
1. Apps Script Editor → View → Logs
2. Or View → Executions (for detailed logs)

**Example log output:**
```
🔄 Starting auto check-in for all guests...
✅ Checked in 150 guests

📊 Check-In Stats:
   Total rows: 200
   Guests with Screen Name & UID: 180
   Checked in (any value): 155
   Checked in with "Y": 150
   Checked in with other values: 5
```

---

## API Usage

### Call from other scripts

```javascript
// Check in all guests
const result = autoCheckInAll();
if (result.success) {
  Logger.log('Checked in: ' + result.checkedIn + ' guests');
}

// Get stats
const stats = getCheckInStats();
Logger.log('Valid check-ins: ' + stats.checkedInWithY);

// Check in specific guest
autoCheckInByUID('user123');
```

---

## Safety Features

1. **Confirmation dialogs** for destructive actions (Clear All)
2. **Validation** - Only checks in guests with Screen Name & UID
3. **Logging** - All actions logged for audit trail
4. **Error handling** - Graceful failures with user-friendly messages
5. **Exact formatting** - Always sets Column AB to exactly "Y"

---

## Troubleshooting

### Menu doesn't appear
- Check that CheckInTools.gs is in your Apps Script project
- Verify onOpen() includes menu code
- Reload the spreadsheet

### Function errors
- Check Apps Script Execution Log for details
- Verify FRC sheet exists
- Ensure columns Y, Z, AB, AC exist

### Check-ins not working in MM/ALM
- Run Check-In Stats to verify "Y" values
- Check mmCode diagnostic logs
- Verify Guest_Similarity sheet exists (for MM)

---

## Best Practices

1. **Before going live:** Run `Check In All Guests` to ensure clean data
2. **Testing:** Use `Check In Random` with different counts
3. **Monitoring:** Periodically run `Check-In Stats` during event
4. **Cleanup:** Use `Clear All Check-Ins` between test runs
5. **Backup:** Keep a copy of FRC sheet before bulk operations

---

## Support

If issues persist:
1. Check Apps Script Execution Log
2. Verify column indices match your sheet structure
3. Run `showCheckInStats()` for diagnostic info
4. Check mmCode diagnostic logs for backend details
