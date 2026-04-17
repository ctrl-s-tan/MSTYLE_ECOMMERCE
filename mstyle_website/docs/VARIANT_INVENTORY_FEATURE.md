# Variant Inventory Management Feature

## Overview
The Variant Inventory Management feature allows sellers to manage stock levels for each color and size combination of their products. This provides granular control over inventory and helps prevent overselling specific variants.

## Database Schema

### New Table: `variant_inventory`
```sql
CREATE TABLE IF NOT EXISTS `variant_inventory` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` INT NOT NULL,
  `color` VARCHAR(100) NOT NULL,
  `size` VARCHAR(50) NOT NULL,
  `stock_quantity` INT NOT NULL DEFAULT 0,
  `low_stock_threshold` INT DEFAULT 5,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_variant` (`product_id`, `color`, `size`),
  INDEX `idx_product_id` (`product_id`),
  INDEX `idx_stock` (`stock_quantity`),
  INDEX `idx_color` (`color`),
  INDEX `idx_size` (`size`)
);
```

## Features

### 1. Variant Inventory Page (`/variant_inventory`)
- **Access**: Seller only
- **Purpose**: Manage stock for each color/size combination
- **Features**:
  - View all products with variants
  - Filter by product name, category, and stock status
  - Update stock quantities for each variant
  - Visual stock status indicators (High, Medium, Low, Out of Stock)
  - Bulk save changes per product

### 2. Stock Status Indicators
- **Out of Stock**: 0 quantity (gray badge)
- **Low Stock**: Quantity ≤ threshold (red badge)
- **Medium Stock**: Quantity ≤ threshold × 2 (yellow badge)
- **In Stock**: Quantity > threshold × 2 (green badge)

### 3. Filtering Options
- **Search**: Filter products by name
- **Category**: Filter by product category
- **Stock Status**: 
  - All Stock Levels
  - Low Stock
  - Out of Stock
  - In Stock

## API Endpoints

### 1. Get Products with Variants
**Endpoint**: `GET /api/seller/products-with-variants`

**Authentication**: Seller session required

**Response**:
```json
{
  "success": true,
  "products": [
    {
      "id": 1,
      "name": "Product Name",
      "category": "SHIRTS",
      "images": ["image1.jpg", "image2.jpg"],
      "colors": ["Red", "Blue"],
      "sizes": ["S", "M", "L"],
      "total_quantity": 100,
      "variants": [
        {
          "color": "Red",
          "size": "S",
          "stock_quantity": 10,
          "low_stock_threshold": 5
        }
      ]
    }
  ]
}
```

### 2. Update Variants
**Endpoint**: `POST /api/seller/update-variants`

**Authentication**: Seller session required

**Request Body**:
```json
{
  "product_id": 1,
  "variants": [
    {
      "color": "Red",
      "size": "S",
      "stock_quantity": 15
    },
    {
      "color": "Red",
      "size": "M",
      "stock_quantity": 20
    }
  ]
}
```

**Response**:
```json
{
  "success": true,
  "message": "Variants updated successfully"
}
```

## How It Works

### 1. Product Creation
When a seller adds a product with multiple colors and sizes:
- Colors are stored in the `variations` column
- Sizes are stored in the `sizes` column
- Images are mapped to colors in the `image_colors` column

### 2. Variant Management
- Sellers navigate to "Variant Inventory" from the seller header menu
- The system displays all products with their color/size combinations
- Sellers can set stock quantities for each variant
- Total product quantity is automatically calculated from all variants

### 3. Stock Updates
- When variants are updated, the system:
  1. Updates or inserts variant records in `variant_inventory`
  2. Calculates total stock from all variants
  3. Updates the main `products.quantity` field

### 4. Order Processing
When an order is placed:
- The system should check variant stock availability
- Deduct from the specific variant's stock
- Update the total product quantity

## User Interface

### Variant Inventory Page
- **Header**: Shows page title and description
- **Filters Section**: Search, category, and stock status filters
- **Products Grid**: Cards displaying each product with:
  - Product image
  - Product name and category
  - Variant table with color, size, stock, and status
  - Save button for each product

### Stock Status Colors
- 🟢 **Green**: High stock (In Stock)
- 🟡 **Yellow**: Medium stock
- 🔴 **Red**: Low stock
- ⚫ **Gray**: Out of stock

## Installation

1. Run the SQL migration:
```bash
mysql -u username -p database_name < sql/ADD_VARIANT_INVENTORY_TABLE.sql
```

2. The routes are automatically available in `mstyle.py`

3. Access the feature from the seller header menu: **Variant Inventory**

## Future Enhancements

1. **Automatic Stock Deduction**: Integrate with order processing to automatically deduct variant stock
2. **Low Stock Alerts**: Send notifications when variants reach low stock threshold
3. **Bulk Import/Export**: Allow CSV import/export of variant stock levels
4. **Stock History**: Track stock changes over time
5. **Variant-specific Pricing**: Allow different prices for different variants
6. **Variant Images**: Associate specific images with specific color/size combinations

## Notes

- The feature requires products to have both colors (variations) and sizes defined
- Products without variants will show "No variants available"
- Total product quantity is the sum of all variant quantities
- Low stock threshold defaults to 5 units per variant
