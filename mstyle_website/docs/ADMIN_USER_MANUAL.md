# M'STYLE E-Commerce Platform - Admin User Manual

## Table of Contents
1. [Admin Dashboard](#admin-dashboard)
2. [Seller Applications](#seller-applications)
3. [Pending User Approvals](#pending-user-approvals)
4. [User Management](#user-management)
5. [Product Management](#product-management)
6. [Order Monitoring](#order-monitoring)
7. [Issue Reports & Complaints](#issue-reports--complaints)
8. [Reports & Analytics](#reports--analytics)
9. [Archived Accounts](#archived-accounts)

---

## Admin Dashboard

### Overview
The Admin Dashboard provides a comprehensive overview of your platform's key metrics and performance indicators.

### Features

#### Key Metrics Display
- **Total Orders**: View the total number of orders placed on the platform
- **Total Products**: See the total number of products listed
- **Total Users**: Monitor the total registered users
- **Total Issues**: Track customer complaints and issues
- **Pending Approvals**: View pending seller and user registrations

#### Analytics Charts
1. **Total Revenue (Monthly)**
   - Line chart showing revenue trends over the last 12 months
   - Hover over data points to see exact revenue figures
   - Currency displayed in Philippine Peso (₱)

2. **Platform Commission (Monthly)**
   - Track commission earnings from sellers and riders
   - 5% commission from completed orders
   - Monthly breakdown for the last 12 months

3. **Top Selling Categories**
   - Bar chart displaying best-performing product categories
   - Shows units sold per category
   - Color-coded for easy identification

4. **Order Status Distribution**
   - Pie chart showing order breakdown by status
   - Includes: Pending, Processing, Shipped, Delivered, Completed, Cancelled
   - Percentage and count displayed on hover

### How to Use
1. Access the dashboard from the admin navigation menu
2. Charts load automatically upon page load
3. Hover over chart elements for detailed information
4. Charts update in real-time as new data is added

---

## Seller Applications

### Overview
Review and manage seller registration applications. Approve or reject sellers based on their submitted documents and business information.

### Features

#### Application List
- **Sequence Number**: Numbered list of applications
- **Seller Information**: Name, phone number, email
- **Business Details**: Business name, business type (Individual/Business)
- **Address**: Full address with barangay, city, and province
- **Registration Date**: Date and time of application
- **Status**: Pending, Approved, or Rejected

#### Filtering Options
- **Search**: Search by name, email, phone, or address
- **User Type Filter**: Filter by business type (Individual/Business)
- **Status Filter**: Filter by approval status
- **Auto-submit**: Filters apply automatically as you type or select

### Actions

#### 1. Approve Seller
- Click the **green checkmark** button
- Confirmation dialog appears
- System sends approval email to seller
- Seller gains access to seller dashboard
- Application removed from pending list

#### 2. View Documents
- Click the **eye icon** button
- Modal displays:
  - Valid Government ID
  - DTI Certificate (for business sellers)
  - BIR Certificate (for business sellers)
  - Business Permit (for business sellers)
- Click on any document to view full size
- Close modal with X button or click outside

#### 3. Reject Seller
- Click the **red X** button
- Modal appears requesting rejection reason
- Enter detailed reason (required)
- Option to send email notification (checked by default)
- System sends rejection email with reason
- Application status updated to "Rejected"

### Best Practices
- Review all documents carefully before approval
- Verify business registration documents match business name
- Provide clear, professional rejection reasons
- Check for duplicate applications
- Respond to applications within 24-48 hours

---

## Pending User Approvals

### Overview
Review and approve user registrations for buyers and riders. Verify submitted documents before granting platform access.

### Features

#### User List Display
- **Sequence Number**: Numbered list of pending users
- **User Information**: Name, phone number, email
- **Address**: Full formatted address
- **User Type**: Buyer or Rider (with icons)
- **Status**: Pending, Approved, or Rejected
- **Registration Date**: Date and time of registration

#### Filtering Options
- **Search**: Search by name, email, phone, or address
- **User Type Filter**: Filter by Buyer or Rider
- **Status Filter**: Filter by approval status
- **Auto-submit**: Real-time filtering as you type

### Actions

#### 1. Approve User
- Click the **green checkmark** button
- Confirmation dialog appears
- System sends approval email
- User gains platform access
- Toast notification confirms success
- User removed from pending list

#### 2. View Documents
- Click the **eye icon** button
- Modal displays user information and documents:
  - **For All Users**: Valid Government ID
  - **For Riders**: 
    - Vehicle information (type, model, plate number, year)
    - OR/CR Document
    - NBI Clearance
- Click on document to view full size
- Multiple path fallbacks ensure image loads correctly

#### 3. Reject User
- Click the **red X** button
- Modal appears with rejection form
- Enter detailed rejection reason (minimum 10 characters)
- Option to send email notification (checked by default)
- System sends rejection email with reason
- User status updated to "Rejected"

### Document Verification
- Verify ID matches user information
- For riders, check vehicle documents are valid and current
- Ensure NBI clearance is recent (within 6 months)
- Verify OR/CR matches vehicle information provided

### Best Practices
- Verify all documents are clear and readable
- Check document expiration dates
- For riders, ensure vehicle registration is current
- Provide specific rejection reasons
- Process applications within 24 hours
- Keep rejection reasons professional and constructive

---

## User Management

### Overview
Comprehensive user management system for viewing, editing, and managing all registered users on the platform.

### Features

#### Statistics Summary
- **Total Users**: All registered users
- **Buyers**: Total buyer accounts
- **Sellers**: Total seller accounts
- **Riders**: Total rider accounts

#### User List Display
- **Sequence Number**: Numbered list
- **Name**: Full name with formatted phone number
- **Email**: User email address
- **Address**: Formatted address with street, barangay, city, province
- **User Type**: Buyer, Seller, or Rider (color-coded badges)
- **Joined Date**: Registration date and time
- **Status**: Active, Suspended, or Banned
- **Actions**: Multiple action buttons

#### Advanced Filtering
- **Search**: Search by name, email, phone, or address (auto-submit with 500ms delay)
- **User Type Filter**: Filter by Buyer, Seller, or Rider
- **Status Filter**: Filter by Active, Suspended, or Banned
- **Clear Filters**: Reset all filters to default

### Actions

#### 1. Edit User
- Click the **yellow edit** button
- Modal displays editable fields:
  - First Name
  - Last Name
  - Email
  - Phone Number
  - Address
  - User Type
- Save changes or cancel
- System validates all fields before saving

#### 2. View Details
- Click the **blue eye** button
- Modal displays comprehensive user information:
  - Personal details
  - Contact information
  - Vehicle information (for riders)
  - Uploaded documents with preview
  - Ban status and reason (if applicable)
- Click on documents to view full size
- Documents include fallback paths for reliability

#### 3. Suspend User (Temporary)
- Click the **orange clock** button
- Modal appears with suspension form:
  - Reason for suspension (required)
  - Duration (1-90 days)
  - Email notification option
- System sends suspension email with details
- User cannot access platform during suspension
- Automatic unsuspension after duration expires

#### 4. Ban User (Permanent)
- Click the **red ban** button
- Warning modal with permanent ban confirmation
- Requires detailed ban reason
- Double confirmation required
- System sends ban notification email
- User permanently blocked from platform
- Action is irreversible

#### 5. Unsuspend/Unban User
- Button appears for suspended/banned users
- Click the **green check** button
- Confirmation dialog appears
- System restores user access
- Email notification sent to user

#### 6. Archive User
- Click the **archive** button
- Confirmation dialog appears
- User moved to archived accounts
- Can be restored from archive page
- User data preserved

### User Status Indicators
- **Active**: Green badge with check icon
- **Suspended**: Orange badge with clock icon
- **Banned**: Red badge with ban icon

### Best Practices
- Review user activity before suspending or banning
- Provide clear, specific reasons for actions
- Use suspension for temporary violations
- Reserve bans for serious or repeated violations
- Document all administrative actions
- Respond to user inquiries promptly
- Regular review of suspended accounts

---

## Product Management

### Overview
Monitor and manage all products listed on the platform. Flag violations, deactivate products, and maintain product quality standards.

### Features

#### Statistics Summary
- **Total Products**: All products on platform
- **Low Stock Products**: Products below threshold
- **Out of Stock Products**: Products with zero stock

#### Product List Display
- **Sequence Number**: Numbered list with pagination
- **Product Name**: Product title
- **Status**: Multiple status badges:
  - **Flagged**: Product flagged for violation
  - **Inactive**: Product deactivated by admin
  - **Active**: Product available for purchase
- **Seller Name**: Product owner
- **Category**: Product category
- **Price**: Product price in ₱
- **Stock**: Current stock with status indicators:
  - **Out of Stock**: Red badge with warning
  - **Low Stock**: Orange badge with threshold warning
  - **In Stock**: Green badge
- **Date Added**: Product creation date
- **Last Updated**: Last modification date
- **Actions**: Action buttons

#### Advanced Filtering
- **Search**: Search by product name, seller, or category (auto-submit)
- **Category Filter**: Filter by product category
- **Seller Filter**: Filter by specific seller
- **Status Filter**: 
  - Active
  - Inactive/Deactivated
  - Flagged
  - Out of Stock
  - Low Stock
- **Clear Filters**: Reset all filters

#### Pagination
- 20 products per page
- Page numbers with ellipsis for large datasets
- Previous/Next navigation
- Shows current range (e.g., "Showing 1 to 20 of 150 products")

### Actions

#### 1. View Product Details
- Click the **blue eye** button
- Modal displays:
  - Product image
  - Product name
  - Price
  - Stock status with threshold
  - Seller information
  - Creation and update dates
  - Full description
  - Flag information (if flagged)
- Close with X button or click outside

#### 2. Flag Product for Violation
- Click the **yellow flag** button
- Modal appears with flag form:
  - Reason for flagging (required, detailed)
  - Email notification option
- System sends notification to seller
- Product marked with "Flagged" badge
- Product remains visible but marked

#### 3. Clear Flag / Mark Safe
- Button appears for flagged products
- Click the **green check** button
- Confirmation dialog appears
- Flag removed from product
- Seller notified of clearance

#### 4. Deactivate Product
- Click the **red ban** button
- Modal appears with deactivation form:
  - Optional reason for deactivation
  - Email notification option
- Product hidden from buyers
- Seller notified via email and in-app
- Product status changed to "Inactive"

#### 5. Activate Product
- Button appears for inactive products
- Click the **green check** button
- Confirmation dialog appears
- Product becomes visible to buyers
- Seller notified of activation

### Product Status Indicators
- **Active**: Green badge with check icon
- **Inactive**: Gray badge with ban icon
- **Flagged**: Yellow badge with flag icon
- **Out of Stock**: Red badge with X icon
- **Low Stock**: Orange badge with warning icon

### Best Practices
- Review flagged products within 24 hours
- Provide specific reasons for flags and deactivations
- Check for policy violations regularly
- Monitor low stock products
- Verify seller compliance with platform rules
- Document all administrative actions
- Communicate clearly with sellers

---

## Order Monitoring

### Overview
Comprehensive order tracking and monitoring system. View all orders, track status, and monitor delivery progress.

### Features

#### Statistics Summary
- **Total Orders**: All orders on platform
- **Pending**: Orders awaiting confirmation
- **Shipped**: Orders in transit
- **Delivered**: Orders delivered to buyers
- **Completed**: Orders confirmed by buyers
- **Cancelled**: Cancelled or rejected orders

#### Order List Display
- **Sequence Number**: Numbered list with pagination
- **Order ID**: Unique order identifier
- **Order Date**: Date and time of order
- **Buyer Name**: Customer name
- **Seller Name**: Seller name
- **Total Amount**: Order total in ₱
- **Payment Method**: Cash on Delivery, GCash, or Card
- **Order Status**: Color-coded status badges:
  - **Pending**: Yellow badge
  - **Confirmed**: Blue badge
  - **For Pickup**: Purple badge
  - **Heading to Seller**: Orange badge
  - **Shipped**: Cyan badge
  - **Delivered**: Green badge
  - **Completed**: Dark green badge
  - **Cancelled**: Red badge
- **Completion Date**: Date order was completed
- **Assigned Rider**: Rider handling delivery
- **Actions**: View details button

#### Advanced Filtering
- **Search**: Search by Order ID, Buyer, or Seller (auto-submit)
- **Order Status Filter**: Filter by specific status
- **Date From**: Filter orders from specific date
- **Date To**: Filter orders until specific date
- **Clear Filters**: Reset all filters

#### Pagination
- 20 orders per page
- Page navigation with ellipsis
- Shows current range

### Actions

#### View Order Details
- Click the **blue eye** button
- Modal displays comprehensive order information:
  - **Order Information**:
    - Order ID
    - Order date
    - Current status
    - Delivered date (if applicable)
    - Received date (if applicable)
    - Auto-completed date (if applicable)
    - Completion type indicator
  - **Buyer Information**:
    - Name
    - Email
    - Phone number
  - **Seller Information**:
    - Name
    - Email
    - Phone number
  - **Products Table**:
    - Product name
    - Variations
    - Size
    - Quantity
    - Price
    - Subtotal
  - **Payment Information**:
    - Payment method
    - Total amount
  - **Delivery Information**:
    - Assigned rider
    - Rider phone (if assigned)
    - Delivery address
- Close with X button or click outside

### Order Status Flow
1. **Pending**: Order placed, awaiting seller confirmation
2. **Confirmed**: Seller confirmed order
3. **For Pickup**: Ready for rider pickup
4. **Heading to Seller**: Rider going to seller location
5. **Shipped**: Order picked up and in transit
6. **Delivered**: Order delivered to buyer
7. **Completed**: Buyer confirmed receipt

### Best Practices
- Monitor pending orders for timely processing
- Track delivery times and rider performance
- Investigate delayed orders
- Review cancelled orders for patterns
- Ensure proper order status updates
- Monitor payment method distribution
- Track completion rates

---

## Issue Reports & Complaints

### Overview
Manage customer complaints and issue reports. Track, respond to, and resolve user-reported problems.

### Features

#### Statistics Summary
- **Total Issues**: All reported issues
- **Pending**: Issues awaiting review
- **In Progress**: Issues being addressed
- **Resolved**: Successfully resolved issues

#### Issue List Display
- **Sequence Number**: Numbered list with pagination
- **Reporter**: User who reported the issue
  - Name
  - Role badge (Buyer, Seller, Rider, Admin)
  - Email
- **Reported Against**: Target of complaint
  - Name
  - Role badge
  - Email
- **Issue Type**: Category of issue
- **Description**: Brief issue description (truncated)
- **Order ID**: Related order (if applicable)
- **Status**: Color-coded status badges:
  - **Pending**: Yellow badge with clock icon
  - **In Progress**: Blue badge with spinner icon
  - **Resolved**: Green badge with check icon
  - **Closed**: Gray badge with X icon
- **Date Submitted**: Issue creation date
- **Actions**: View, Update, Delete buttons

#### Advanced Filtering
- **Search**: Search by reporter, issue type, or description (auto-submit)
- **Status Filter**: Filter by Pending, In Progress, Resolved, or Closed
- **Reported By Filter**: Filter by reporter role (Buyer, Seller, Rider, Admin)
- **Reported Against Filter**: Filter by target role
- **Clear Filters**: Reset all filters

#### Pagination
- 20 issues per page
- Page navigation
- Shows current range

### Actions

#### 1. View Issue Details
- Click the **blue eye** button
- Modal displays comprehensive issue information:
  - **Issue Information**:
    - Issue ID
    - Status badge
    - Report against category
    - Issue type
    - Created date
    - Last updated date
  - **Customer Information**:
    - Name
    - Email
    - Phone
  - **Order Information** (if applicable):
    - Order ID
    - Product name
    - Order date
    - Order status
    - Quantity, size, variations
    - Total amount
    - Seller details
    - Rider details (if assigned)
  - **Issue Description**: Full detailed description
  - **Admin Response**: Previous admin responses (if any)
- Action buttons:
  - Update Status
  - Close
- Close with X button or click outside

#### 2. Update Issue Status
- Click the **yellow edit** button
- Modal displays status update form:
  - **Status Dropdown**: 
    - Available options based on current status
    - Status progression rules enforced:
      - Pending → In Progress, Resolved, Closed
      - In Progress → Resolved, Closed
      - Resolved → Closed
      - Closed → Closed (no changes)
  - **Admin Response**: Optional text area for notes
  - Submit button with loading state
- System sends email and in-app notification to customer
- Status updated in real-time

#### 3. Delete Issue
- Click the **red trash** button
- Confirmation dialog appears
- Permanent deletion (cannot be undone)
- Issue removed from system
- Row fades out with animation

### Issue Status Progression
1. **Pending**: New issue, awaiting admin review
2. **In Progress**: Admin investigating/addressing issue
3. **Resolved**: Issue successfully resolved
4. **Closed**: Issue closed (resolved or dismissed)

### Best Practices
- Respond to issues within 24 hours
- Provide detailed admin responses
- Update status as investigation progresses
- Document all actions taken
- Follow up on resolved issues
- Track recurring issues for pattern analysis
- Maintain professional communication
- Escalate serious issues promptly

---

## Reports & Analytics

### Overview
Comprehensive analytics and reporting system. Generate detailed reports, export data, and analyze platform performance.

### Features

#### Key Metrics Dashboard
- **Total Orders**: Platform-wide order count
- **Platform Commission**: Total commission earned
- **Total Revenue**: Cumulative revenue
- **Total Users**: All registered users
- **Total Products**: All listed products

#### Section Filtering
Filter reports by specific sections:
- **All Sections**: View all reports
- **Inventory & Products**: Product analytics
- **Seller Performance**: Seller metrics
- **Rider/Delivery**: Delivery analytics
- **Buyer Activity**: Customer behavior
- **Promo Codes**: Promotion usage
- **Platform Commission**: Commission breakdown
- **Complaints & Issues**: Issue reports

#### Dynamic Filters
Filters change based on selected section:
- **Search**: Section-specific search
- **Status**: Status filtering (where applicable)
- **Sort By**: Multiple sorting options
- **Date Range**: From and To date filters
- **Clear**: Reset all filters

### Report Sections

#### 1. Inventory & Products Analytics
**Displays:**
- Product name
- Seller name
- Category
- Status (Active, Inactive, Flagged)
- Units sold
- Current stock with status indicators
- Product rating

**Filters:**
- Search by product, seller, category
- Status: Active, Inactive, Flagged
- Sort by: Units sold, Stock, Rating

**Totals:**
- Total products count
- Total units sold

#### 2. Seller Performance Reports
**Displays:**
- Seller name and email
- Total products
- Total orders
- Completed orders
- Cancelled orders
- Total revenue
- Flagged products
- Deactivated products

**Filters:**
- Search by seller name
- Sort by: Revenue, Orders, Products

**Totals:**
- Total sellers
- Total revenue

#### 3. Rider/Delivery Analytics
**Displays:**
- Rider name and email
- Vehicle type
- Plate number
- Total deliveries
- Successful deliveries with success rate
- Failed deliveries
- Total earnings

**Filters:**
- Search by rider name, vehicle type
- Sort by: Deliveries, Earnings, Success rate

**Totals:**
- Total riders
- Total deliveries
- Total earnings

#### 4. Buyer Activity & Behavior Insights
**Displays:**
- Buyer name and email
- Total orders
- Total spend
- Average order value (AOV)
- Last order date
- Cart items
- Wishlist items

**Filters:**
- Search by buyer name, email
- Date range filter
- Sort by: Spend, Orders, AOV

**Totals:**
- Total buyers
- Total spend

#### 5. Promo Code Usage Analytics
**Displays:**
- Promo code
- Discount type (Percentage, Fixed, Free Shipping, BOGO)
- Discount value
- Start date
- End date
- Total uses
- Total discount given
- Status (Active, Upcoming, Expired)

**Filters:**
- Search by promo code
- Status: Active, Upcoming, Expired
- Date range filter
- Sort by: Uses, Discount given

**Totals:**
- Total promo codes
- Total uses
- Total discount given

#### 6. Platform Commission Summary
**Displays:**
- Order ID
- Seller email
- Rider email
- Order total
- Delivery fee
- Seller commission (5%)
- Rider commission (5%)
- Total platform earnings
- Order date
- Date completed

**Filters:**
- Search by Order ID, seller, rider
- Date range filter
- Sort by: Earnings, Order total, Date

**Totals:**
- Total orders
- Total seller commission
- Total rider commission
- Total platform earnings

#### 7. Complaints & Issues Report
**Displays:**
- Reported by (with role badge)
- Reported against (with role badge)
- Issue type
- Description
- Order ID
- Status
- Date submitted

**Filters:**
- Search by reporter, issue type, description
- Status: Pending, In Progress, Resolved, Closed
- Date range filter
- Sort by: Date

**Totals:**
- Total issues
- Pending issues
- Resolved issues

### Actions

#### Print Report
- Click **Print** button
- Opens print-friendly layout in new window
- Includes:
  - Report header with date
  - Selected section(s) data
  - All tables and totals
  - Formatted for printing
- Use browser print function (Ctrl+P)
- Supports page breaks for multi-page reports

#### Export Report
- Click **Export** button
- Generates CSV file with:
  - UTF-8 encoding with BOM (Excel-compatible)
  - Report header with generation date
  - All selected section(s) data
  - Properly formatted dates and numbers
  - Totals and summaries
- File downloads automatically
- Filename: `admin_analytics_report.csv`

### Best Practices
- Review analytics weekly
- Export reports for record-keeping
- Monitor commission trends
- Track seller and rider performance
- Analyze buyer behavior patterns
- Review promo code effectiveness
- Use date filters for period analysis
- Compare metrics month-over-month
- Identify top performers and underperformers
- Use insights for business decisions

---

## Archived Accounts

### Overview
Manage archived user accounts. View, restore, or permanently delete archived users.

### Features

#### Archived User List
- **Sequence Number**: Numbered list
- **Name**: Full name with phone number
- **Email**: User email address
- **User Type**: Buyer, Seller, or Rider (color-coded)
- **Status**: Archived badge
- **Actions**: Restore or Delete buttons

#### Filtering Options
- **Search**: Search by email, name, or phone (auto-submit)
- **User Type Filter**: Filter by Buyer, Seller, or Rider
- **Clear Filters**: Reset all filters

### Actions

#### 1. Restore User
- Click the **green undo** button
- Confirmation dialog appears
- User account restored to active status
- User regains platform access
- User moved back to User Management
- All user data preserved

#### 2. Delete Permanently
- Click the **red trash** button
- Confirmation dialog appears
- **Warning**: This action is permanent and cannot be undone
- User account permanently deleted
- All user data removed from system
- Action logged for audit purposes

### Archive vs Delete
- **Archive**: Temporary removal, can be restored
- **Delete**: Permanent removal, cannot be undone

### Best Practices
- Review archived accounts regularly
- Restore accounts when appropriate
- Only permanently delete when necessary
- Document reasons for permanent deletion
- Maintain audit trail of deletions
- Consider data retention policies
- Verify user identity before restoration

---

## General Admin Guidelines

### Security Best Practices
1. **Password Management**
   - Use strong, unique passwords
   - Change password regularly
   - Never share admin credentials
   - Enable two-factor authentication if available

2. **Access Control**
   - Log out when leaving workstation
   - Don't access admin panel on public computers
   - Monitor login activity
   - Report suspicious activity immediately

3. **Data Protection**
   - Handle user data responsibly
   - Follow data privacy regulations
   - Don't share sensitive information
   - Secure exported reports

### Communication Guidelines
1. **Professional Communication**
   - Use clear, professional language
   - Be respectful and courteous
   - Provide specific, actionable feedback
   - Respond promptly to inquiries

2. **Email Notifications**
   - Review email content before sending
   - Ensure notifications are enabled
   - Verify recipient email addresses
   - Track notification delivery

### Decision Making
1. **Approval Process**
   - Review all documents thoroughly
   - Verify information accuracy
   - Check for policy compliance
   - Document approval reasons

2. **Rejection Process**
   - Provide clear, specific reasons
   - Be constructive and helpful
   - Suggest improvements when possible
   - Maintain professional tone

3. **Enforcement Actions**
   - Follow platform policies consistently
   - Document all actions taken
   - Provide warnings before bans
   - Consider severity of violations

### Monitoring and Maintenance
1. **Regular Reviews**
   - Check pending approvals daily
   - Monitor issue reports regularly
   - Review flagged products weekly
   - Analyze reports monthly

2. **Quality Control**
   - Maintain product quality standards
   - Ensure seller compliance
   - Monitor delivery performance
   - Track customer satisfaction

3. **Performance Tracking**
   - Monitor key metrics
   - Identify trends and patterns
   - Address issues proactively
   - Optimize platform operations

### Support and Escalation
1. **User Support**
   - Respond to inquiries promptly
   - Provide helpful solutions
   - Follow up on resolved issues
   - Maintain support documentation

2. **Issue Escalation**
   - Identify critical issues
   - Escalate to appropriate personnel
   - Document escalation process
   - Track resolution progress

---

## Troubleshooting

### Common Issues and Solutions

#### Charts Not Loading
- **Solution**: Refresh the page
- Check internet connection
- Clear browser cache
- Verify API endpoint is accessible

#### Filters Not Working
- **Solution**: Clear filters and try again
- Refresh the page
- Check for JavaScript errors in console
- Verify filter parameters are valid

#### Images Not Displaying
- **Solution**: System uses multiple fallback paths
- Check if image file exists
- Verify file permissions
- Check network connectivity

#### Export/Print Issues
- **Solution**: Ensure pop-ups are allowed
- Check browser print settings
- Verify CSV file downloads
- Try different browser if issues persist

#### Modal Not Opening
- **Solution**: Refresh the page
- Check for JavaScript errors
- Clear browser cache
- Disable browser extensions temporarily

### Getting Help
- Contact technical support
- Check system logs
- Review error messages
- Document steps to reproduce issue

---

## Keyboard Shortcuts

### General
- **Escape**: Close open modals
- **Ctrl+P**: Print current page
- **Ctrl+F**: Search on page

### Navigation
- Use Tab to navigate between form fields
- Enter to submit forms
- Arrow keys for dropdown navigation

---

## System Requirements

### Browser Compatibility
- **Recommended**: Google Chrome (latest version)
- **Supported**: Firefox, Safari, Edge (latest versions)
- JavaScript must be enabled
- Cookies must be enabled

### Screen Resolution
- Minimum: 1280x720
- Recommended: 1920x1080 or higher
- Responsive design supports mobile devices

### Internet Connection
- Stable internet connection required
- Minimum speed: 5 Mbps
- Recommended: 10 Mbps or higher

---

## Updates and Maintenance

### System Updates
- Platform updates occur regularly
- Notifications provided for major updates
- Review changelog for new features
- Test new features in staging environment

### Data Backup
- System performs automatic backups
- Export important reports regularly
- Maintain local copies of critical data
- Verify backup integrity periodically

---

## Contact Information

### Technical Support
- For technical issues and bugs
- System access problems
- Feature requests

### Administrative Support
- For policy questions
- User management issues
- Platform operations

---

## Appendix

### Glossary
- **AOV**: Average Order Value
- **BOGO**: Buy One Get One
- **DTI**: Department of Trade and Industry
- **BIR**: Bureau of Internal Revenue
- **NBI**: National Bureau of Investigation
- **OR/CR**: Official Receipt/Certificate of Registration
- **COD**: Cash on Delivery

### Status Definitions
- **Active**: Account/product is operational
- **Inactive**: Temporarily disabled
- **Suspended**: Temporarily blocked with duration
- **Banned**: Permanently blocked
- **Archived**: Removed but recoverable
- **Flagged**: Marked for review
- **Pending**: Awaiting action
- **Completed**: Successfully finished

---

**Document Version**: 1.0  
**Last Updated**: November 30, 2025  
**Platform**: M'STYLE E-Commerce  

---

*This manual is subject to updates as the platform evolves. Please check for the latest version regularly.*
