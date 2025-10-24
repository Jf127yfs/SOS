/**
 * ============================================================================
 * CHECK-IN TOOLS - Auto-Populate and Management Functions
 * ============================================================================
 *
 * Utilities to manage guest check-ins in FRC sheet
 * Ensures Column AB (Checked-In) is properly formatted as "Y"
 *
 * FUNCTIONS:
 * 1. autoCheckInAll() - Check in ALL guests with Screen Name & UID
 * 2. autoCheckInRandom(count) - Check in random number of guests
 * 3. autoCheckInByUID(uid) - Check in specific guest by UID
 * 4. autoCheckInByScreenName(screenName) - Check in by screen name
 * 5. clearAllCheckIns() - Clear all check-ins (set to "")
 * 6. getCheckInStats() - Get current check-in statistics
 *
 * MENU INTEGRATION:
 * Add to onOpen() in Code.gs:
 *   .addItem('✅ Check In All Guests', 'autoCheckInAll')
 *   .addItem('🎲 Check In Random Guests', 'autoCheckInRandomPrompt')
 *   .addItem('❌ Clear All Check-Ins', 'clearAllCheckIns')
 *   .addItem('📊 Check-In Stats', 'showCheckInStats')
 *
 * ============================================================================
 */

/**
 * Auto check-in ALL guests who have Screen Name and UID
 * Sets Column AB = "Y" and Column AC = current timestamp
 *
 * @return {Object} {success: Boolean, checkedIn: Number, message: String}
 */
function autoCheckInAll() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      SpreadsheetApp.getUi().alert('❌ Error', 'FRC sheet not found', SpreadsheetApp.getUi().ButtonSet.OK);
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();
    const now = new Date();
    let checkedInCount = 0;

    // Column indices (0-indexed)
    const SCREEN_NAME_COL = 24;  // Column Y
    const UID_COL = 25;          // Column Z
    const CHECKED_IN_COL = 27;   // Column AB
    const CHECKIN_TIME_COL = 28; // Column AC

    Logger.log('🔄 Starting auto check-in for all guests...');

    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const screenName = String(row[SCREEN_NAME_COL] || '').trim();
      const uid = String(row[UID_COL] || '').trim();

      // Only check in if guest has both Screen Name and UID
      if (screenName && uid) {
        // Set Checked-In to exactly "Y"
        frcSheet.getRange(i + 1, CHECKED_IN_COL + 1).setValue('Y');

        // Set check-in timestamp
        frcSheet.getRange(i + 1, CHECKIN_TIME_COL + 1).setValue(now);

        checkedInCount++;
      }
    }

    Logger.log('✅ Checked in ' + checkedInCount + ' guests');

    // Show success message
    SpreadsheetApp.getUi().alert(
      '✅ Success',
      'Checked in ' + checkedInCount + ' guests!\n\nAll guests with Screen Name and UID are now checked in.',
      SpreadsheetApp.getUi().ButtonSet.OK
    );

    return {
      success: true,
      checkedIn: checkedInCount,
      message: 'Successfully checked in ' + checkedInCount + ' guests'
    };

  } catch (error) {
    Logger.log('❌ Error in autoCheckInAll: ' + error.toString());
    SpreadsheetApp.getUi().alert('❌ Error', error.toString(), SpreadsheetApp.getUi().ButtonSet.OK);
    return { success: false, message: error.toString() };
  }
}

/**
 * Auto check-in a random number of guests
 * Useful for testing MM and ALM pages
 *
 * @param {Number} count - Number of guests to check in (default: 10)
 * @return {Object} {success: Boolean, checkedIn: Number, guests: Array}
 */
function autoCheckInRandom(count) {
  count = count || 10;

  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();
    const now = new Date();

    // Column indices
    const SCREEN_NAME_COL = 24;
    const UID_COL = 25;
    const CHECKED_IN_COL = 27;
    const CHECKIN_TIME_COL = 28;

    // Find all guests with Screen Name and UID
    const eligibleGuests = [];
    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const screenName = String(row[SCREEN_NAME_COL] || '').trim();
      const uid = String(row[UID_COL] || '').trim();

      if (screenName && uid) {
        eligibleGuests.push({
          rowIndex: i,
          screenName: screenName,
          uid: uid
        });
      }
    }

    if (eligibleGuests.length === 0) {
      SpreadsheetApp.getUi().alert('⚠️ Warning', 'No eligible guests found with Screen Name and UID', SpreadsheetApp.getUi().ButtonSet.OK);
      return { success: false, message: 'No eligible guests' };
    }

    // Shuffle and select random guests
    const shuffled = eligibleGuests.sort(() => Math.random() - 0.5);
    const selected = shuffled.slice(0, Math.min(count, eligibleGuests.length));

    // Check in selected guests
    const checkedInGuests = [];
    for (const guest of selected) {
      frcSheet.getRange(guest.rowIndex + 1, CHECKED_IN_COL + 1).setValue('Y');
      frcSheet.getRange(guest.rowIndex + 1, CHECKIN_TIME_COL + 1).setValue(now);
      checkedInGuests.push(guest.screenName);
    }

    Logger.log('✅ Randomly checked in ' + selected.length + ' guests: ' + checkedInGuests.join(', '));

    SpreadsheetApp.getUi().alert(
      '✅ Success',
      'Randomly checked in ' + selected.length + ' guests:\n\n' + checkedInGuests.slice(0, 10).join('\n') +
      (checkedInGuests.length > 10 ? '\n... and ' + (checkedInGuests.length - 10) + ' more' : ''),
      SpreadsheetApp.getUi().ButtonSet.OK
    );

    return {
      success: true,
      checkedIn: selected.length,
      guests: checkedInGuests
    };

  } catch (error) {
    Logger.log('❌ Error in autoCheckInRandom: ' + error.toString());
    SpreadsheetApp.getUi().alert('❌ Error', error.toString(), SpreadsheetApp.getUi().ButtonSet.OK);
    return { success: false, message: error.toString() };
  }
}

/**
 * Prompt user for number of random guests to check in
 * (Menu-friendly wrapper for autoCheckInRandom)
 */
function autoCheckInRandomPrompt() {
  const ui = SpreadsheetApp.getUi();

  const response = ui.prompt(
    '🎲 Random Check-In',
    'How many random guests would you like to check in?',
    ui.ButtonSet.OK_CANCEL
  );

  if (response.getSelectedButton() === ui.Button.OK) {
    const count = parseInt(response.getResponseText());

    if (isNaN(count) || count <= 0) {
      ui.alert('⚠️ Invalid Input', 'Please enter a positive number', ui.ButtonSet.OK);
      return;
    }

    autoCheckInRandom(count);
  }
}

/**
 * Check in a specific guest by UID
 *
 * @param {String} uid - Guest UID to check in
 * @return {Object} {success: Boolean, screenName: String, message: String}
 */
function autoCheckInByUID(uid) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();
    const now = new Date();

    const UID_COL = 25;
    const SCREEN_NAME_COL = 24;
    const CHECKED_IN_COL = 27;
    const CHECKIN_TIME_COL = 28;

    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const rowUID = String(row[UID_COL] || '').trim();

      if (rowUID === uid) {
        const screenName = String(row[SCREEN_NAME_COL] || '').trim();

        frcSheet.getRange(i + 1, CHECKED_IN_COL + 1).setValue('Y');
        frcSheet.getRange(i + 1, CHECKIN_TIME_COL + 1).setValue(now);

        Logger.log('✅ Checked in guest: ' + screenName + ' (UID: ' + uid + ')');

        return {
          success: true,
          screenName: screenName,
          message: 'Checked in: ' + screenName
        };
      }
    }

    return { success: false, message: 'Guest with UID ' + uid + ' not found' };

  } catch (error) {
    Logger.log('❌ Error in autoCheckInByUID: ' + error.toString());
    return { success: false, message: error.toString() };
  }
}

/**
 * Check in a specific guest by Screen Name
 *
 * @param {String} screenName - Guest screen name to check in
 * @return {Object} {success: Boolean, uid: String, message: String}
 */
function autoCheckInByScreenName(screenName) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();
    const now = new Date();

    const SCREEN_NAME_COL = 24;
    const UID_COL = 25;
    const CHECKED_IN_COL = 27;
    const CHECKIN_TIME_COL = 28;

    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const rowScreenName = String(row[SCREEN_NAME_COL] || '').trim();

      if (rowScreenName.toLowerCase() === screenName.toLowerCase()) {
        const uid = String(row[UID_COL] || '').trim();

        frcSheet.getRange(i + 1, CHECKED_IN_COL + 1).setValue('Y');
        frcSheet.getRange(i + 1, CHECKIN_TIME_COL + 1).setValue(now);

        Logger.log('✅ Checked in guest: ' + rowScreenName + ' (UID: ' + uid + ')');

        return {
          success: true,
          uid: uid,
          message: 'Checked in: ' + rowScreenName
        };
      }
    }

    return { success: false, message: 'Guest "' + screenName + '" not found' };

  } catch (error) {
    Logger.log('❌ Error in autoCheckInByScreenName: ' + error.toString());
    return { success: false, message: error.toString() };
  }
}

/**
 * Clear ALL check-ins (set Column AB to empty string)
 * Useful for testing or resetting event
 *
 * @return {Object} {success: Boolean, cleared: Number, message: String}
 */
function clearAllCheckIns() {
  try {
    const ui = SpreadsheetApp.getUi();

    // Confirmation dialog
    const response = ui.alert(
      '⚠️ Clear All Check-Ins',
      'This will CLEAR all guest check-ins.\n\nAre you sure you want to continue?',
      ui.ButtonSet.YES_NO
    );

    if (response !== ui.Button.YES) {
      return { success: false, message: 'Cancelled by user' };
    }

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();
    let clearedCount = 0;

    const CHECKED_IN_COL = 27;   // Column AB
    const CHECKIN_TIME_COL = 28; // Column AC

    Logger.log('🔄 Clearing all check-ins...');

    for (let i = 1; i < data.length; i++) {
      // Clear both Checked-In and Check-In Time
      frcSheet.getRange(i + 1, CHECKED_IN_COL + 1).setValue('');
      frcSheet.getRange(i + 1, CHECKIN_TIME_COL + 1).setValue('');
      clearedCount++;
    }

    Logger.log('✅ Cleared ' + clearedCount + ' check-ins');

    ui.alert(
      '✅ Success',
      'Cleared check-ins for ' + clearedCount + ' rows.\n\nAll guests are now checked out.',
      ui.ButtonSet.OK
    );

    return {
      success: true,
      cleared: clearedCount,
      message: 'Cleared ' + clearedCount + ' check-ins'
    };

  } catch (error) {
    Logger.log('❌ Error in clearAllCheckIns: ' + error.toString());
    SpreadsheetApp.getUi().alert('❌ Error', error.toString(), SpreadsheetApp.getUi().ButtonSet.OK);
    return { success: false, message: error.toString() };
  }
}

/**
 * Get current check-in statistics
 *
 * @return {Object} Stats object with counts and details
 */
function getCheckInStats() {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const frcSheet = ss.getSheetByName('FRC');

    if (!frcSheet) {
      return { success: false, message: 'FRC sheet not found' };
    }

    const data = frcSheet.getDataRange().getValues();

    const SCREEN_NAME_COL = 24;
    const UID_COL = 25;
    const CHECKED_IN_COL = 27;

    let totalRows = data.length - 1; // Exclude header
    let guestsWithData = 0;
    let checkedInCount = 0;
    let checkedInWithY = 0;
    let checkedInOtherValues = 0;
    let invalidValues = [];

    for (let i = 1; i < data.length; i++) {
      const row = data[i];
      const screenName = String(row[SCREEN_NAME_COL] || '').trim();
      const uid = String(row[UID_COL] || '').trim();
      const checkedInRaw = row[CHECKED_IN_COL];
      const checkedIn = String(checkedInRaw || '').trim().toUpperCase();

      if (screenName && uid) {
        guestsWithData++;
      }

      if (checkedIn) {
        checkedInCount++;

        if (checkedIn === 'Y') {
          checkedInWithY++;
        } else {
          checkedInOtherValues++;
          invalidValues.push({
            row: i + 1,
            screenName: screenName,
            value: checkedInRaw
          });
        }
      }
    }

    const stats = {
      success: true,
      totalRows: totalRows,
      guestsWithData: guestsWithData,
      checkedInCount: checkedInCount,
      checkedInWithY: checkedInWithY,
      checkedInOtherValues: checkedInOtherValues,
      invalidValues: invalidValues.slice(0, 10) // First 10 invalid
    };

    Logger.log('📊 Check-In Stats:');
    Logger.log('   Total rows: ' + totalRows);
    Logger.log('   Guests with Screen Name & UID: ' + guestsWithData);
    Logger.log('   Checked in (any value): ' + checkedInCount);
    Logger.log('   Checked in with "Y": ' + checkedInWithY);
    Logger.log('   Checked in with other values: ' + checkedInOtherValues);

    return stats;

  } catch (error) {
    Logger.log('❌ Error in getCheckInStats: ' + error.toString());
    return { success: false, message: error.toString() };
  }
}

/**
 * Show check-in statistics in a dialog
 * (Menu-friendly wrapper for getCheckInStats)
 */
function showCheckInStats() {
  const stats = getCheckInStats();

  if (!stats.success) {
    SpreadsheetApp.getUi().alert('❌ Error', stats.message, SpreadsheetApp.getUi().ButtonSet.OK);
    return;
  }

  let message = '📊 CHECK-IN STATISTICS\n\n';
  message += 'Total rows: ' + stats.totalRows + '\n';
  message += 'Guests with data: ' + stats.guestsWithData + '\n\n';
  message += '✅ Checked in with "Y": ' + stats.checkedInWithY + '\n';
  message += '⚠️ Checked in (other values): ' + stats.checkedInOtherValues + '\n';
  message += 'Not checked in: ' + (stats.guestsWithData - stats.checkedInCount) + '\n';

  if (stats.checkedInOtherValues > 0) {
    message += '\n⚠️ WARNING: ' + stats.checkedInOtherValues + ' guests have invalid check-in values!\n';
    message += 'Examples:\n';
    stats.invalidValues.forEach(item => {
      message += '  Row ' + item.row + ': "' + item.value + '" (' + item.screenName + ')\n';
    });
    message += '\nUse "Check In All Guests" to fix this.';
  }

  SpreadsheetApp.getUi().alert('📊 Check-In Stats', message, SpreadsheetApp.getUi().ButtonSet.OK);
}

/**
 * ============================================================================
 * EXAMPLE MENU INTEGRATION (Add to Code.gs onOpen function)
 * ============================================================================
 *
 * function onOpen() {
 *   const ui = SpreadsheetApp.getUi();
 *   ui.createMenu('🛠️ Tools')
 *     .addSubMenu(ui.createMenu('✅ Check-In Tools')
 *       .addItem('✅ Check In All Guests', 'autoCheckInAll')
 *       .addItem('🎲 Check In Random Guests', 'autoCheckInRandomPrompt')
 *       .addSeparator()
 *       .addItem('📊 Check-In Stats', 'showCheckInStats')
 *       .addSeparator()
 *       .addItem('❌ Clear All Check-Ins', 'clearAllCheckIns'))
 *     .addToUi();
 * }
 *
 * ============================================================================
 */
