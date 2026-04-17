# Report Issue - Rider Option Logic

## Overview
The rider option in the report issue modal is dynamically enabled/disabled based on whether a rider is assigned to the order.

## Logic Flow

### When Opening the Report Modal

1. **Check Order Status**
   - Rider-involved statuses: `For Pickup`, `Heading to Seller`, `Shipped`, `Delivered`, `Completed`

2. **Check Rider Assignment**
   - Verify `order.riderEmail` exists and is not empty
   - Verify order status is in rider-involved statuses

3. **Enable/Disable Rider Option**
   - **ENABLED**: If rider is assigned AND status involves rider
     - Shows: "Rider (Rider Name)" or just "Rider"
     - User can select this option
   - **DISABLED**: If no rider assigned OR status doesn't involve rider
     - Shows: "Rider (Not assigned yet)"
     - Option is grayed out and cannot be selected

## Visual Indicators

### Enabled State
- Normal text color
- Bold font weight
- Shows rider name if available
- Selectable in dropdown

### Disabled State
- Gray text color (#999)
- Italic font style
- Gray background (#f5f5f5)
- Shows "(Not assigned yet)" message
- Cannot be selected

## User Experience

### Scenario 1: Order with Rider Assigned
```
Order Status: "Shipped"
Rider Email: "rider@example.com"
Rider Name: "John Doe"

Dropdown shows:
- Select who to report
- Buyer
- Rider (John Doe) ✓ [ENABLED]
- Platform/System
- Other
```

### Scenario 2: Order without Rider
```
Order Status: "Pending"
Rider Email: null
Rider Name: null

Dropdown shows:
- Select who to report
- Buyer
- Rider (Not assigned yet) [DISABLED]
- Platform/System
- Other
```

### Scenario 3: Order Confirmed, Waiting for Rider
```
Order Status: "Confirmed"
Rider Email: null
Rider Name: null

Dropdown shows:
- Select who to report
- Buyer
- Rider (Not assigned yet) [DISABLED]
- Platform/System
- Other
```

### Scenario 4: Rider Accepted, On the Way
```
Order Status: "Heading to Seller"
Rider Email: "rider@example.com"
Rider Name: "Jane Smith"

Dropdown shows:
- Select who to report
- Buyer
- Rider (Jane Smith) ✓ [ENABLED]
- Platform/System
- Other
```

## Validation

When user tries to select disabled rider option:
1. Selection is prevented (HTML disabled attribute)
2. If somehow selected, `updateReportAgainstEmail()` shows warning toast
3. Selection is cleared automatically
4. User must choose another option

## Console Logging

For debugging, the following is logged when modal opens:
- Order Status
- Rider Email
- Rider Name
- Whether rider option is enabled/disabled

When user selects an option:
- Selected value
- Buyer email
- Rider email
- Action taken (set email, cleared, etc.)

## Order Status Flow

```
Pending → Confirmed → For Pickup → Heading to Seller → Shipped → Delivered → Completed
   ↓          ↓            ↓              ↓              ↓          ↓           ↓
No Rider  No Rider    Rider Assigned  Rider Assigned  Rider     Rider      Rider
DISABLED  DISABLED      ENABLED         ENABLED       ENABLED   ENABLED    ENABLED
```

## Implementation Files

- **HTML**: `templates/report_issue_modal.html`
  - Rider option always present in dropdown
  - ID: `rider-option`

- **JavaScript**: `static/js/report_issue_modal.js`
  - `openReportIssueModal()` - Checks and enables/disables option
  - `updateReportAgainstEmail()` - Validates selection and sets email

- **CSS**: `static/css/report_issue_modal.css`
  - Styles for disabled state
  - Styles for enabled state

## Testing Checklist

- [ ] Rider option disabled when order is "Pending"
- [ ] Rider option disabled when order is "Confirmed" (no rider yet)
- [ ] Rider option enabled when order is "For Pickup" with rider
- [ ] Rider option enabled when order is "Heading to Seller"
- [ ] Rider option enabled when order is "Shipped"
- [ ] Rider option enabled when order is "Delivered"
- [ ] Rider name shows in option text when available
- [ ] Warning toast shows if trying to select disabled option
- [ ] Email auto-populates correctly when rider selected
- [ ] Console logs show correct information
- [ ] Visual styling shows disabled state clearly
