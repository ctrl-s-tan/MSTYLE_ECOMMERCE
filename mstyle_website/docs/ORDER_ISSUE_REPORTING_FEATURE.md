# Order Issue Reporting Feature - Implementation Summary

## Overview
Enhanced the order issue reporting system to allow sellers and riders to report issues, not just buyers. The system now supports multi-directional reporting where any party involved in an order can report issues against other parties.

## Database Schema Changes

### Updated `order_issues` Table
The table now supports reports from multiple user roles:

```sql
CREATE TABLE order_issues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    reporter_role ENUM('buyer', 'seller', 'rider', 'admin') NOT NULL,
    reporter_email VARCHAR(255) NOT NULL,
    reported_against_role ENUM('buyer', 'seller', 'rider', 'platform', 'other') NOT NULL,
    reported_against_email VARCHAR(255) NULL,
    issue_type VARCHAR(100) NOT NULL,
    issue_description TEXT NOT NULL,
    status ENUM('pending', 'in_progress', 'resolved', 'closed') DEFAULT 'pending',
    admin_response TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
```

### Key Changes:
- **reporter_role**: Identifies who is making the report (buyer/seller/rider/admin)
- **reporter_email**: Email of the person reporting
- **reported_against_role**: Who the issue is being reported against
- **reported_against_email**: Email of the reported party (if applicable)

## Frontend Changes

### 1. Order List Page (`templates/order_lists.html`)
- Added "Report Issue" button in the order details modal footer
- Added report issue modal with form for submitting reports
- Modal includes:
  - Dropdown to select who to report (Buyer/Rider/Platform/Other)
  - Issue type selection
  - Detailed description textarea

### 2. CSS Styling (`static/css/order_list.css`)
- Added styles for report issue button with red gradient
- Added modal styles for report form
- Responsive design for mobile devices
- Form validation styling

### 3. JavaScript Functions (`static/js/order_list.js`)
Added the following functions:
- `openReportIssueModal()`: Opens the report modal with order context
- `closeReportIssueModal()`: Closes the modal and resets form
- `updateReportAgainstEmail()`: Auto-fills email based on selection
- `submitReportIssue()`: Handles form submission via AJAX

## Backend Changes

### New Route: `/submit_order_issue` (POST)
Located in `mstyle.py`, this route:
- Validates user authentication
- Verifies reporter has access to the order
- Validates all required fields
- Inserts issue report into database
- Returns JSON response with success/error message

**Security Features:**
- Checks if reporter is logged in
- Verifies reporter email matches session
- Confirms reporter has relationship to the order
- Validates order exists

## Issue Types

### For Sellers:
- Payment Issue
- Delivery Delay
- Wrong/Incomplete Address
- Customer Unreachable
- Rider Issue
- Damaged Product (Before Pickup)
- Order Cancellation Request
- Communication Issue
- Suspected Fraudulent Order
- Other

### For Buyers:
- Damaged Product
- Wrong Item
- Missing Parts
- Quality Issue
- Size Issue
- Delivery Issue
- Seller Unresponsive
- Other

### For Riders:
- Pickup Issue
- Address Issue
- Customer Unavailable
- Seller Unavailable
- Product Issue
- Other

## Migration Instructions

### Option 1: Fresh Installation
Run `sql/ADD_ORDER_ISSUES_TABLE.sql` to create the table with the new schema.

### Option 2: Existing Installation
Run `sql/MIGRATE_ORDER_ISSUES_TABLE.sql` which provides two options:
- **Option A**: Drop and recreate (loses existing data)
- **Option B**: Alter table to preserve existing data (commented out by default)

## Usage Flow

1. **Seller views order details** in Order List page
2. **Clicks "Report Issue"** button in modal footer
3. **Selects who to report**:
   - Buyer (always available)
   - Rider (only if rider is assigned)
   - Platform/System
   - Other
4. **Selects issue type** from predefined list
5. **Provides detailed description**
6. **Submits report** - goes to admin for review
7. **Receives confirmation** via toast notification

## Admin Integration
The reported issues will appear in the admin dashboard where admins can:
- View all reports from buyers, sellers, and riders
- Filter by reporter role and reported party
- Update issue status
- Add admin responses
- Resolve or close issues

## Future Enhancements
- Email notifications to admins when new issues are reported
- Email notifications to reported parties
- Issue resolution workflow
- Issue history and analytics
- Automated issue categorization
- Integration with chat system for direct communication

## Files Created/Modified

### New Files Created:
1. `templates/report_issue_modal.html` - Separate modal template
2. `static/css/report_issue_modal.css` - Modal styling (matching seller_buyer_chat_modal style)
3. `static/js/report_issue_modal.js` - Modal JavaScript functions
4. `sql/MIGRATE_ORDER_ISSUES_TABLE.sql` - Migration script
5. `docs/ORDER_ISSUE_REPORTING_FEATURE.md` - This documentation

### Files Modified:
1. `sql/ADD_ORDER_ISSUES_TABLE.sql` - Updated schema
2. `templates/order_lists.html` - Added report button and included modal
3. `mstyle.py` - Added `/submit_order_issue` route

## Testing Checklist
- [ ] Seller can report buyer issues
- [ ] Seller can report rider issues (when rider assigned)
- [ ] Seller can report platform issues
- [ ] Form validation works correctly
- [ ] Email auto-population works
- [ ] Modal opens and closes properly
- [ ] AJAX submission works
- [ ] Success/error messages display
- [ ] Database records created correctly
- [ ] Access control prevents unauthorized reports
- [ ] Responsive design works on mobile
