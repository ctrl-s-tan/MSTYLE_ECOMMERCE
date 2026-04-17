-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 10, 2025 at 04:59 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mstyle`
--

-- --------------------------------------------------------

--
-- Table structure for table `archive`
--

CREATE TABLE `archive` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` varchar(50) NOT NULL,
  `valid_id_path` varchar(500) DEFAULT NULL,
  `dti_path` varchar(500) DEFAULT NULL,
  `bir_path` varchar(500) DEFAULT NULL,
  `business_permit_path` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_notifications`
--

CREATE TABLE `buyer_notifications` (
  `id` int(11) NOT NULL,
  `buyer_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50) DEFAULT 'status_update',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buyer_notifications`
--

INSERT INTO `buyer_notifications` (`id`, `buyer_email`, `message`, `type`, `is_read`, `created_at`, `order_id`) VALUES
(95, 'tolentinomariely09@gmail.com', 'Great news! Your order \'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students\' has been shipped and is on the way.', 'shipped', 1, '2025-12-05 23:05:24', 25),
(96, 'tolentinomariely09@gmail.com', 'Your order \'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students\' has been delivered successfully!', 'delivered', 1, '2025-12-05 23:05:40', 25),
(97, 'tolentinomariely09@gmail.com', 'Your order \'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size\' status has been updated to: Confirmed', 'status_update', 1, '2025-12-05 23:07:40', 46),
(98, 'tolentinomariely09@gmail.com', 'Great news! Your order \'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size\' has been shipped and is on the way.', 'shipped', 1, '2025-12-05 23:10:12', 46),
(99, 'tolentinomariely09@gmail.com', 'Your order \'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size\' has been delivered successfully!', 'delivered', 1, '2025-12-05 23:11:21', 46),
(100, 'tolentinomariely09@gmail.com', 'Your order \'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch\' status has been updated to: Confirmed', 'status_update', 0, '2025-12-06 00:21:35', 47),
(101, 'tolentinomariely09@gmail.com', 'Great news! Your order \'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch\' has been shipped and is on the way.', 'shipped', 0, '2025-12-06 00:27:02', 47),
(102, 'tolentinomariely09@gmail.com', 'Your order \'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch\' has been delivered successfully!', 'delivered', 1, '2025-12-06 00:27:28', 47);

-- --------------------------------------------------------

--
-- Table structure for table `buyer_rider_messages`
--

CREATE TABLE `buyer_rider_messages` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `sender_email` varchar(255) NOT NULL,
  `receiver_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores chat messages between buyers and riders for order deliveries';

--
-- Dumping data for table `buyer_rider_messages`
--

INSERT INTO `buyer_rider_messages` (`id`, `order_id`, `sender_email`, `receiver_email`, `message`, `is_read`, `created_at`) VALUES
(37, 46, 'tolentinoann2001@gmail.com', 'tolentinomariely09@gmail.com', 'May tip ba?', 1, '2025-12-05 23:09:16'),
(38, 46, 'tolentinomariely09@gmail.com', 'tolentinoann2001@gmail.com', 'Wala', 1, '2025-12-05 23:09:31'),
(39, 46, 'tolentinomariely09@gmail.com', 'tolentinoann2001@gmail.com', 'San na po kayo?', 1, '2025-12-05 23:10:58'),
(40, 46, 'tolentinoann2001@gmail.com', 'tolentinomariely09@gmail.com', 'Dito na', 1, '2025-12-05 23:11:13');

-- --------------------------------------------------------

--
-- Table structure for table `buyer_seller_messages`
--

CREATE TABLE `buyer_seller_messages` (
  `id` int(11) NOT NULL,
  `conversation_id` varchar(255) NOT NULL,
  `sender_email` varchar(255) NOT NULL,
  `receiver_email` varchar(255) NOT NULL,
  `sender_type` enum('buyer','seller') NOT NULL,
  `message_text` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` varchar(50) NOT NULL,
  `quantity` varchar(50) NOT NULL,
  `variations` varchar(50) NOT NULL,
  `image` varchar(50) NOT NULL,
  `size` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `seller_email` varchar(50) NOT NULL,
  `product_id` int(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`id`, `name`, `price`, `quantity`, `variations`, `image`, `size`, `email`, `seller_email`, `product_id`) VALUES
(47, 'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students', '378.00', '1', 'Gray Orange', '20251115_025520_T0mRas_grayorange.jpg', '40', 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 23);

-- --------------------------------------------------------

--
-- Table structure for table `checkout`
--

CREATE TABLE `checkout` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `variations` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `size` varchar(50) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `seller_email` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `shipping_fee` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` int(11) NOT NULL,
  `conversation_id` varchar(255) NOT NULL,
  `buyer_email` varchar(255) NOT NULL,
  `seller_email` varchar(255) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `last_message_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `seller_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(50) DEFAULT 'order',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `seller_email`, `message`, `type`, `is_read`, `created_at`, `order_id`) VALUES
(320, 'tolentinomaann17@gmail.com', 'New order: Hemp Pants (Qty: 1) - ₱100.00 from tolentinomariely09@gmail.com', 'order', 0, '2025-12-05 22:55:59', NULL),
(321, 'tolentinomaann17@gmail.com', 'Order cancelled: Hemp Pants by tolentinomariely09@gmail.com. Reason: No longer needed ', 'cancellation', 0, '2025-12-05 22:56:51', NULL),
(322, 'tolentinomaann17@gmail.com', '🚚 Rider Ann Tolentino has accepted delivery for Order #28 (New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch). The rider is now heading to pick up the item.', 'rider_assigned', 0, '2025-12-05 22:59:55', NULL),
(323, 'tolentinomaann17@gmail.com', 'New order: Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size (Qty: 1) - ₱413.00 from tolentinomariely09@gmail.com', 'order', 0, '2025-12-05 23:07:13', NULL),
(324, 'tolentinomaann17@gmail.com', '🚚 Rider Ann Tolentino has accepted delivery for Order #46 (Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size). The rider is now heading to pick up the item.', 'rider_assigned', 0, '2025-12-05 23:08:22', NULL),
(325, 'tolentinomaann17@gmail.com', 'New 5-star review received for \'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size\' from customer tolentinomariely09@gmail.com. Review: \"Good item\"', 'review', 0, '2025-12-05 23:13:15', NULL),
(326, 'tolentinomaann17@gmail.com', '🚨 Out of Stock: New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch - Product is now unavailable for purchase', 'out_of_stock', 0, '2025-12-06 00:19:13', NULL),
(327, 'tolentinomaann17@gmail.com', '🚨 Out of Stock: New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch (Black - One Size) - Product is now unavailable for purchase', 'out_of_stock', 0, '2025-12-06 00:19:59', NULL),
(328, 'tolentinomaann17@gmail.com', 'New order: New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch (Qty: 10) - ₱5990.00 from tolentinomariely09@gmail.com', 'order', 1, '2025-12-06 00:20:11', NULL),
(329, 'tolentinomaann17@gmail.com', '🚚 Rider Ann Tolentino has accepted delivery for Order #47 (New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch). The rider is now heading to pick up the item.', 'rider_assigned', 0, '2025-12-06 00:25:29', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `quantity` varchar(50) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_price` varchar(50) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `shipping_fee` decimal(10,2) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `cancellation_reason` text DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `email` varchar(50) NOT NULL,
  `address` text DEFAULT NULL,
  `seller_email` varchar(50) NOT NULL,
  `rider_email` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `variations` varchar(255) DEFAULT NULL,
  `size` varchar(50) DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `received_at` timestamp NULL DEFAULT NULL,
  `auto_complete_at` timestamp NULL DEFAULT NULL,
  `is_auto_completed` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `name`, `quantity`, `date`, `total_price`, `payment_method`, `shipping_fee`, `status`, `cancellation_reason`, `cancelled_at`, `email`, `address`, `seller_email`, `rider_email`, `product_id`, `image`, `variations`, `size`, `delivered_at`, `received_at`, `auto_complete_at`, `is_auto_completed`) VALUES
(6, 'Slim Fit Casual One Button Blazer Jacket', '1', '2025-11-14 19:30:16', '2795.66', 'cod', 50.00, 'Cancelled', 'expensive', '2025-11-14 19:40:34', 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', NULL, 7, '20251115_014112_JW0kSz_navy.jpg', 'Navy', 'XL', NULL, NULL, NULL, NULL),
(9, 'KANAZAWA New Original Style Portable Shaver With TYPE-C Fast Charging For Man', '1', '2025-11-15 13:30:40', '79', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 29, '20251115_030742_1GAPNh_KANAZA2.JPG', 'Standard', 'No size', '2025-11-16 13:25:19', '2025-11-18 10:30:21', NULL, NULL),
(10, 'Men\'s Genuine Leather Shoes Pull On Soft Anti-slip Rubber Loafers Mens Casual Business Shoes', '1', '2025-11-16 13:28:50', '299', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 24, '20251115_025830_g4qaCS_black.jpg', 'Black', '42', '2025-11-16 13:31:07', '2025-11-18 10:39:20', NULL, NULL),
(11, 'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students', '1', '2025-11-18 01:11:15', '378', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 23, '20251115_025520_0AhrYo_greenblack.jpg', 'Green Black', '47', '2025-11-18 11:18:10', '2025-11-18 11:22:27', NULL, NULL),
(12, 'pants', '1', '2025-11-18 06:22:45', '100', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 31, '20251118_092243_6X4vRM_green.jpg', 'Green', '44×32', '2025-11-18 06:59:45', '2025-11-18 10:41:47', NULL, NULL),
(14, 'pants', '1', '2025-11-18 07:49:43', '100', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 31, '20251118_092243_6X4vRM_green.jpg', 'Green', '44×32', '2025-11-23 05:35:55', '2025-11-26 06:22:22', NULL, NULL),
(15, 'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students', '1', '2025-11-18 07:58:11', '378', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 23, '20251115_025520_0AhrYo_greenblack.jpg', 'Green Black', '47', '2025-11-18 11:02:04', '2025-11-18 11:03:41', NULL, NULL),
(16, 'Vnox Layered 3D Vertical Bar Necklaces for Men, Stainless Steel Geometric Cuban Chain Necklace', '1', '2025-11-18 08:10:05', '233', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 26, '20251115_030228_z7gGPg_vnoxneck_2.jpg', 'Standard', 'One Size', '2025-11-23 05:36:32', '2025-12-03 06:49:24', NULL, NULL),
(17, 'Black Portable Electric Shaver for Men with USB Charging and Quiet Performance', '1', '2025-11-18 08:11:02', '30', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 28, '20251115_030629_wlrznG_blue.jpg', 'Blue', 'No size', '2025-11-18 11:17:21', '2025-11-18 11:18:56', NULL, NULL),
(18, 'Professional Shaver for Men 3 in 1 Electric Shaver Rechargeable Professional Razor Beard Trimmer', '1', '2025-11-18 09:21:02', '199', 'cod', 50.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 27, '20251115_030411_4CRP04_PROFES1.JPG', 'Standard', 'No size', '2025-11-21 12:28:49', NULL, NULL, NULL),
(19, 'pants', '1', '2025-11-18 09:39:26', '100', 'cod', 50.00, 'Cancelled', 'no longer needed', '2025-11-18 09:48:59', 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', NULL, 31, '20251118_092243_6X4vRM_green.jpg', 'Green', '44×32', NULL, NULL, NULL, NULL),
(22, 'Vnox Layered 3D Vertical Bar Necklaces for Men, Stainless Steel Geometric Cuban Chain Necklace', '1', '2025-11-18 10:48:57', '233', 'cod', 50.00, 'Cancelled', 'expensive', '2025-11-18 10:49:27', 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', NULL, 26, '20251115_030228_z7gGPg_vnoxneck_2.jpg', 'Standard', 'One Size', NULL, NULL, NULL, NULL),
(23, 'Mens Fleece Varsity Baseball Jackets Hoodie Detachable Hat Sweatshirts Unisex Sport Sweater Bomber Coat', '1', '2025-11-18 12:06:59', '339.77', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 17, '20251115_023741_moNdMC_Fleece_White.jpg', 'Fleece White', 'XXL', '2025-11-18 12:12:07', '2025-11-25 06:41:11', NULL, NULL),
(24, 'Mens Genuine Leather Shoes Pull On Soft Anti-slip Rubber Loafers Mens Casual Business Shoes', '1', '2025-11-19 11:10:29', '299', 'cod', 50.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 24, '20251115_025830_g4qaCS_black.jpg', 'Black', '41', '2025-11-19 11:14:40', NULL, NULL, NULL),
(25, 'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students', '1', '2025-11-20 15:05:59', '378', 'cod', 50.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 23, '20251115_025520_T0mRas_grayorange.jpg', 'Gray Orange', '41', '2025-12-05 23:05:40', NULL, NULL, NULL),
(26, 'Mens Fleece Varsity Baseball Jackets Hoodie Detachable Hat Sweatshirts Unisex Sport Sweater Bomber Coat', '1', '2025-11-21 07:00:06', '453.02', 'cod', 50.00, 'Shipped', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'anthonytolentino111770@gmail.com', 17, '20251115_023741_moNdMC_Fleece_White.jpg', 'Fleece White', 'XXL', NULL, NULL, NULL, NULL),
(27, 'Breathable Fitness Shorts', '1', '2025-11-21 07:02:49', '290', 'cod', 50.00, 'Heading to Seller', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 20, '20251115_024815_xzO8m6_Navy-Blue.jpg', 'Navy', 'XXL', NULL, NULL, NULL, NULL),
(28, 'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch', '1', '2025-11-22 06:51:20', '599', 'cod', 50.00, 'For Pickup', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 25, '20251115_030035_tHM0Op_green.jpg', 'Green', 'One Size', NULL, NULL, NULL, NULL),
(29, 'Breathable Fitness Shorts', '1', '2025-11-22 06:54:22', '290', 'cod', 50.00, 'Shipped', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 20, '20251115_024815_n56FjY_Khaki.jpg', 'Khaki', 'XXL', NULL, NULL, NULL, NULL),
(32, 'Suit Slim Fit Tuxedo for Homecoming Wedding Prom Blazer ', '1', '2025-11-22 17:48:23', '316.25', 'cod', 50.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'mendozacrisann14@gmail.com', 10, '20251115_021320_nwiFyK_white.jpg', 'White', 'XL', '2025-12-05 05:01:31', NULL, NULL, NULL),
(34, 'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch', '1', '2025-11-23 14:09:54', '599', 'cod', 0.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 25, '20251115_030035_eJMYVi_red.jpg', 'Red', 'One Size', '2025-11-27 05:40:50', NULL, NULL, NULL),
(35, 'Mens Fleece Varsity Baseball Jackets Hoodie Detachable Hat Sweatshirts Unisex Sport Sweater Bomber Coat', '1', '2025-11-26 05:51:21', '339.77', 'cod', 50.00, 'Delivered', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 17, '20251115_023741_moNdMC_Fleece_White.jpg', 'Fleece White', 'M', '2025-11-26 05:56:03', NULL, NULL, NULL),
(36, 'Slim Fit Casual One Button Blazer Jacket', '1', '2025-11-26 06:29:41', '2795.66', 'cod', 50.00, 'Cancelled', 'nothing', '2025-11-26 06:30:13', 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', NULL, 7, '20251115_014112_JW0kSz_navy.jpg', 'Navy', 'XL', NULL, NULL, NULL, NULL),
(43, 'Mens Fleece Varsity Baseball Jackets Hoodie Detachable Hat Sweatshirts Unisex Sport Sweater Bomber Coat', '1', '2025-12-05 05:23:55', '453.02', 'cod', 50.00, 'Pending', NULL, NULL, 'cordonaira26@gmail.com', 'Mendoza Compound Purok 1, Tubuan, Pila, Laguna, CALABARZON, 4010', 'tolentinomaann17@gmail.com', NULL, 17, '20251115_023741_cVjiBo_Fleece_Blue.jpg', 'Fleece Blue', 'M', NULL, NULL, NULL, NULL),
(45, 'Hemp Pants', '1', '2025-12-05 22:55:49', '100', 'cod', 50.00, 'Cancelled', 'No longer needed ', '2025-12-05 22:56:43', 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', NULL, 31, '20251118_092242_n5Mk5s_brown.jpg', 'Brown', '44×32', NULL, NULL, NULL, NULL),
(46, 'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size', '1', '2025-12-05 23:07:02', '413', 'cod', 50.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 30, '20251115_031007_tPimJM_F6FCD21.JPG', 'Standard', 'No size', '2025-12-05 23:11:21', '2025-12-05 23:11:35', NULL, NULL),
(47, 'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch', '10', '2025-12-06 00:19:59', '5990', 'cod', 0.00, 'Completed', NULL, NULL, 'tolentinomariely09@gmail.com', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 25, '20251115_030035_pA8IaW_black.jpg', 'Black', 'One Size', '2025-12-06 00:27:28', '2025-12-06 00:28:02', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_issues`
--

CREATE TABLE `order_issues` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `reporter_role` enum('buyer','seller','rider','admin') NOT NULL,
  `reporter_email` varchar(255) NOT NULL,
  `reported_against_role` enum('buyer','seller','rider','platform','other') NOT NULL DEFAULT 'seller',
  `reported_against_email` varchar(255) DEFAULT NULL,
  `issue_type` varchar(100) NOT NULL,
  `issue_description` text NOT NULL,
  `status` enum('pending','in_progress','resolved','closed') DEFAULT 'pending',
  `admin_response` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `resolved_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_issues`
--

INSERT INTO `order_issues` (`id`, `order_id`, `reporter_role`, `reporter_email`, `reported_against_role`, `reported_against_email`, `issue_type`, `issue_description`, `status`, `admin_response`, `created_at`, `updated_at`, `resolved_at`) VALUES
(23, 26, 'rider', 'anthonytolentino111770@gmail.com', 'buyer', 'tolentinomariely09@gmail.com', 'wrong_address', 'Maling address ung nilagay', 'resolved', NULL, '2025-12-05 16:10:29', '2025-12-05 16:18:09', '2025-12-05 16:18:09'),
(24, 32, 'seller', 'tolentinomaann17@gmail.com', 'rider', 'mendozacrisann14@gmail.com', 'delivery_delay', 'Matagala ideliver', 'in_progress', NULL, '2025-12-05 16:13:36', '2025-12-05 16:16:52', NULL),
(25, 46, 'buyer', 'tolentinomariely09@gmail.com', 'rider', 'tolentinoann2001@gmail.com', 'late_delivery', 'Matagal', 'pending', NULL, '2025-12-05 23:14:39', '2025-12-05 23:14:39', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pending_sellers`
--

CREATE TABLE `pending_sellers` (
  `id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `business_name` varchar(200) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `business_type` enum('individual','business') NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `otp` varchar(6) DEFAULT NULL,
  `valid_id_path` varchar(500) DEFAULT NULL,
  `dti_path` varchar(500) DEFAULT NULL,
  `bir_path` varchar(500) DEFAULT NULL,
  `business_permit_path` varchar(500) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pending_users`
--

CREATE TABLE `pending_users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` varchar(20) NOT NULL,
  `valid_id_path` varchar(255) DEFAULT NULL,
  `vehicle_type` enum('motorcycle','bicycle','car','tricycle') DEFAULT NULL,
  `vehicle_model` varchar(100) DEFAULT NULL,
  `vehicle_plate_number` varchar(20) DEFAULT NULL,
  `vehicle_year_model` varchar(4) DEFAULT NULL,
  `or_cr_path` varchar(500) DEFAULT NULL,
  `nbi_clearance_path` varchar(500) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `variations` text NOT NULL,
  `price` varchar(50) NOT NULL,
  `image` text NOT NULL,
  `quantity` varchar(50) NOT NULL,
  `low_stock_threshold` int(11) DEFAULT 5,
  `seller_email` varchar(50) NOT NULL,
  `sold` int(11) DEFAULT 0,
  `rating` decimal(3,2) DEFAULT NULL,
  `image_colors` text NOT NULL,
  `sizes` text NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `flag_reason` text DEFAULT NULL,
  `flagged_at` timestamp NULL DEFAULT NULL,
  `flagged_by` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_flagged` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `category`, `description`, `variations`, `price`, `image`, `quantity`, `low_stock_threshold`, `seller_email`, `sold`, `rating`, `image_colors`, `sizes`, `created_at`, `updated_at`, `flag_reason`, `flagged_at`, `flagged_by`, `is_active`, `is_flagged`) VALUES
(7, 'Slim Fit Casual One Button Blazer Jacket', 'SUITS', 'Men’s Slim Fit One-Button Blazer, a lightweight and stylish sport coat designed for both casual and formal occasions. Expertly tailored with fine stitching and a subtle linen-textured fabric, it delivers a modern, minimalistic look that enhances confidence and elegance.', 'Black, Burgundy, Navy', '2795.66', '20251115_014111_aepj3c_black.jpg,20251115_014112_kauLik_burgundy.jpg,20251115_014112_JW0kSz_navy.jpg', '120', 5, 'tolentinomaann17@gmail.com', 2, NULL, '20251115_014111_aepj3c_black.jpg:Black,20251115_014112_kauLik_burgundy.jpg:Burgundy,20251115_014112_JW0kSz_navy.jpg:Navy', 'S, M, L, XL', '2025-11-17 02:21:48', '2025-11-26 06:30:13', NULL, NULL, NULL, 1, 0),
(9, 'Herringbone Blazer 2 Button Suit Jackets Casual Knit Sport Coat', 'BLAZERS', 'Herringbone Knit Blazer, designed with a two-button closure, real flap pockets, and a lightweight full lining for all-day comfort. Crafted from soft knit fabric with a subtle herringbone pattern, it offers a perfect balance of elegance and casual sophistication—ideal for spring wear.\r\n', 'Apricot, Black Grey, Black', '6460.95', '20251115_014759_EGZTeC_apricot.jpg,20251115_014759_gf7dIb_black_grey.jpg,20251115_014759_3j6r15_black.jpg', '150', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_014759_EGZTeC_apricot.jpg:Apricot,20251115_014759_gf7dIb_black_grey.jpg:Black Grey,20251115_014759_3j6r15_black.jpg:Black', 'S, M, L, XL, XXL', '2025-11-17 02:21:48', '2025-11-22 18:30:16', NULL, NULL, NULL, 1, 0),
(10, 'Suit Slim Fit Tuxedo for Homecoming Wedding Prom Blazer ', 'SUITS', 'This single-breasted three piece suit is fully lined and has two exterior flap pockets. The long-lasting fabric is soft and comfortable. The slim-fit suit jacket has two functional breast pockets, one exterior, and one interior.\r\n', 'Black, Burgundy, Navy, White', '316.25', '20251115_021320_zPhk87_black.jpg,20251115_021320_tpNcQE_burgundy.jpg,20251115_021320_SMK5l7_navy.jpg,20251115_021320_nwiFyK_white.jpg', '240', 5, 'tolentinomaann17@gmail.com', 1, NULL, '20251115_021320_zPhk87_black.jpg:Black,20251115_021320_tpNcQE_burgundy.jpg:Burgundy,20251115_021320_SMK5l7_navy.jpg:Navy,20251115_021320_nwiFyK_white.jpg:White', 'XS, S, M, L, XL, XXL', '2025-11-17 02:21:48', '2025-11-23 07:09:47', NULL, NULL, NULL, 1, 0),
(11, 'Mens Short Sleeve Button Up Shirts Hawaiian Textured Shirt', 'SHIRTS', 'This Men’s Casual Short Sleeve Textured Button-Down Shirt, designed for both comfort and versatility. Crafted from 100% polyester, this shirt offers a soft, lightweight, and breathable feel, keeping you comfortable all day long.\r\n', 'Black, Blue, Brown, Green, Light Blue, Light Grey, Pink, Sky Blue, White', '1978.68', '20251115_021805_CGAwi8_black.jpg,20251115_021805_tIDVT5_blue.jpg,20251115_021805_d7hnxy_brown.jpg,20251115_021805_3QPFpS_green.jpg,20251115_021805_YX1WSL_light_blue.jpg,20251115_021805_6SkTiT_light_grey.jpg,20251115_021805_33Yz2f_pink.jpg,20251115_021805_4lswrr_sky_blue.jpg,20251115_021805_9wwzpn_white.jpg', '540', 5, 'tolentinomaann17@gmail.com', 1, 5.00, '20251115_021805_CGAwi8_black.jpg:Black,20251115_021805_tIDVT5_blue.jpg:Blue,20251115_021805_d7hnxy_brown.jpg:Brown,20251115_021805_3QPFpS_green.jpg:Green,20251115_021805_YX1WSL_light_blue.jpg:Light Blue,20251115_021805_6SkTiT_light_grey.jpg:Light Grey,20251115_021805_33Yz2f_pink.jpg:Pink,20251115_021805_4lswrr_sky_blue.jpg:Sky Blue,20251115_021805_9wwzpn_white.jpg:White', 'S, M, L, XL, XXL, 3XL', '2025-11-17 02:21:48', '2025-11-22 18:31:40', NULL, NULL, NULL, 1, 0),
(12, ' Hawaiian Shirts Short Sleeve Button Up Chemise Homme', 'SHIRTS', 'Crafted from feather-light, breathable fabric, this shirt keeps you feeling cool and fresh even on the hottest days. Its Cuban collar design and untucked fit bring a relaxed yet polished look, perfect for casual outings, weekend getaways, or tropical adventures.\r\n', 'Black, Blossom Palm, Colorful Skulls, Daybreak Palm, Ethnic Navy, Fiery Swirl, Flamingo Leaf, Flamingo Mink, Green Leaves, Golden Jungle, Indigo Impasto, Lush Leafs, Midnight Hibiscus, Morning Glory, Navy Sketch, Sage Green, Tropical Cerulean, Verdant Jungle, Waterweed Green', '1105.47', '20251115_022230_2DJC5z_black.jpg,20251115_022230_EGlJq6_blossom_palm.jpg,20251115_022230_cTmvEM_colorful_skulls.jpg,20251115_022230_OBjDTU_daybreak_palms.jpg,20251115_022230_bLHBbv_ethnic_navy.jpg,20251115_022230_4E8W1a_fiery_swirl.jpg,20251115_022230_ZCMSDp_flamingo_leaf.jpg,20251115_022230_9WK4Oc_flamingo_mink.jpg,20251115_022230_O13lcs_fog_green_leaves.jpg,20251115_022230_pgXwP1_golden_jungle.jpg,20251115_022230_0EipEH_indigo_impasto.jpg,20251115_022230_TkdoNw_lush_leafs.jpg,20251115_022230_G6Vsrj_midnight_hibiscus.jpg,20251115_022230_JeoOko_morning_glory.jpg,20251115_022230_vBTkiP_navy_sketch.jpg,20251115_022230_1C8Z0k_sage_green.jpg,20251115_022230_vX446d_tropical_cerulean.jpg,20251115_022230_fsVtep_verdant_jungle.jpg,20251115_022230_N6rA75_waterweed_green.jpg', '1140', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_022230_2DJC5z_black.jpg:Black,20251115_022230_EGlJq6_blossom_palm.jpg:Blossom Palm,20251115_022230_cTmvEM_colorful_skulls.jpg:Colorful Skulls,20251115_022230_OBjDTU_daybreak_palms.jpg:Daybreak Palm,20251115_022230_bLHBbv_ethnic_navy.jpg:Ethnic Navy,20251115_022230_4E8W1a_fiery_swirl.jpg:Fiery Swirl,20251115_022230_ZCMSDp_flamingo_leaf.jpg:Flamingo Leaf,20251115_022230_9WK4Oc_flamingo_mink.jpg:Flamingo Mink,20251115_022230_O13lcs_fog_green_leaves.jpg:Fog Green Leaves,20251115_022230_pgXwP1_golden_jungle.jpg:Golden Jungle,20251115_022230_0EipEH_indigo_impasto.jpg:Indigo Impasto,20251115_022230_TkdoNw_lush_leafs.jpg:Lush Leafs,20251115_022230_G6Vsrj_midnight_hibiscus.jpg:Midnight Hibiscus,20251115_022230_JeoOko_morning_glory.jpg:Morning Glory,20251115_022230_vBTkiP_navy_sketch.jpg:Navy Sketch,20251115_022230_1C8Z0k_sage_green.jpg:Sage Green,20251115_022230_vX446d_tropical_cerulean.jpg:Tropical Cerulean,20251115_022230_fsVtep_verdant_jungle.jpg:Verdant Jungle,20251115_022230_N6rA75_waterweed_green.jpg:Waterweed Green', 'S, M, L, XL, XXL, 3XL', '2025-11-17 02:21:48', '2025-11-23 04:41:39', NULL, NULL, NULL, 1, 0),
(14, 'Sailwind Mens Drawstring Casual Summer Beach Loose Trousers Linen Pants with Elastic Waistband', 'PANTS', 'Crafted from lightweight, breathable linen fabric, these pants offer a soft, airy feel that’s perfect for warm weather. The elastic waistband with an adjustable drawstring ensures a secure yet comfortable fit, while the zip fly with button closure adds a touch of refinement.\r\n', 'Beige, Black, Gray, Navy, Silver Gray, White', '2327.96', '20251115_023144_Mj5yYT_beige.jpg,20251115_023144_7D8TBh_black.jpg,20251115_023144_LNRfe1_gray.jpg,20251115_023144_8A8csH_navy.jpg,20251115_023144_UAoUak_silver_gray.jpg,20251115_023144_elXVrd_white.jpg', '840', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_023144_Mj5yYT_beige.jpg:Beige,20251115_023144_7D8TBh_black.jpg:Black,20251115_023144_LNRfe1_gray.jpg:Gray,20251115_023144_8A8csH_navy.jpg:Navy,20251115_023144_UAoUak_silver_gray.jpg:Silver Gray,20251115_023144_elXVrd_white.jpg:White', '26×28, 27×30, 28×30, 29×30, 30×30, 31×30, 32×30, 33×30, 34×30, 36×30, 38×30, 40×30, 42×32, 44×32', '2025-11-17 02:21:48', '2025-11-22 18:32:17', NULL, NULL, NULL, 1, 0),
(15, 'Mens Denim Trucker Jacket Western Cowboy Jean Jacket Rugged Wear Unlined Distressed Jean Work Winter Coats', 'OUTERWEAR', 'This classic denim trucker jacket features a structured, long-sleeve silhouette with button-front closure, buttoned chest flap pockets, and adjustable cuffs. Its clean shape and quality denim make it ideal for layering over shirts, hoodies, or light sweaters—perfect for changing seasons or cooler evenings.\r\n', 'Acid Wash, Black, Whisker Wash', '2959.81', '20251115_023409_yKrHly_acidwash.jpg,20251115_023409_GO5SmT_Black.jpg,20251115_023409_XSHegM_WhiskerWash.jpg', '180', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_023409_yKrHly_acidwash.jpg:Acid Wash,20251115_023409_GO5SmT_Black.jpg:Black,20251115_023409_XSHegM_WhiskerWash.jpg:Whisker Wash', 'L, XL, XXL, 3XL, 4XL, 5XL', '2025-11-17 02:21:48', '2025-11-22 18:30:53', NULL, NULL, NULL, 1, 0),
(16, 'Mens Denim Fishing Cargo Outdoor Vest with Pockets', 'OUTERWEAR', 'The Denim Fishing Cargo Outdoor Vest is your go-to utility layer for all adventure and travel needs. Crafted from 100% durable cotton, this vest offers both comfort and rugged wear resistance—ideal for outdoor work, photography, camping, or casual style.\r\n', 'Black, Blue, Brown, Green', '2866.76', '20251115_023541_A8wGbS_Black.jpg,20251115_023541_2SIJvB_Blue.jpg,20251115_023541_3I3RwS_Brown.jpg,20251115_023541_7vG4ar_Green.jpg', '280', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_023541_A8wGbS_Black.jpg:Black,20251115_023541_2SIJvB_Blue.jpg:Blue,20251115_023541_3I3RwS_Brown.jpg:Brown,20251115_023541_7vG4ar_Green.jpg:Green', 'S, M, L, XL, XXL, 3XL, 4XL', '2025-11-17 02:21:48', '2025-11-22 18:30:46', NULL, NULL, NULL, 1, 0),
(17, 'Mens Fleece Varsity Baseball Jackets Hoodie Detachable Hat Sweatshirts Unisex Sport Sweater Bomber Coat', 'JACKETS', 'Upgrade your outerwear with this Fleece Varsity Baseball Jacket—a perfect blend of sporty style and everyday comfort. Featuring a detachable hood, rib-knit collar, cuffs, and hem, plus a zip front and functional pockets, it delivers both utility and style.\r\n', 'Fleece Black, Fleece Blue, Fleece Green, Fleece White', '453.02', '20251115_023741_2u0tah_Fleece_Black.jpg,20251115_023741_cVjiBo_Fleece_Blue.jpg,20251115_023741_ehHxKc_Fleece_Green.jpg,20251115_023741_moNdMC_Fleece_White.jpg', '113', 5, 'tolentinomaann17@gmail.com', 7, 5.00, '20251115_023741_2u0tah_Fleece_Black.jpg:Fleece Black,20251115_023741_cVjiBo_Fleece_Blue.jpg:Fleece Blue,20251115_023741_ehHxKc_Fleece_Green.jpg:Fleece Green,20251115_023741_moNdMC_Fleece_White.jpg:Fleece White', 'S, M, L, XL, XXL', '2025-11-17 02:21:48', '2025-12-05 05:23:50', NULL, NULL, NULL, 1, 0),
(18, 'Mens Lightweight Polar Fleece Jacket Full Zip Antistatic Casual Coat Soft Warm Outwear with Zipper Pockets', 'JACKETS', 'Durable, warm, and ultra-light—this full-zip polar fleece jacket features anti-static, pill-resistant fabric, five secure pockets, flat-locked seams, and adjustable cuffs and hem. Ideal for hiking, skiing, travel, or daily wear.\r\n', 'Black Green, Black Grey, Black, Dark Grey, Heather Grey, Khaki, Navy', '4048.59', '20251115_024002_QVoDpf_Black_Green.jpg,20251115_024002_NZzJiu_Black_Grey.jpg,20251115_024002_6rgPcx_Black.jpg,20251115_024002_F2PALq_Dark_Grey.jpg,20251115_024002_j1KsVl_Heather_Grey.jpg,20251115_024002_TlKJz8_Khaki.jpg,20251115_024002_PwU89P_Navy.jpg', '420', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_024002_QVoDpf_Black_Green.jpg:Black Green,20251115_024002_NZzJiu_Black_Grey.jpg:Black Grey,20251115_024002_6rgPcx_Black.jpg:Black,20251115_024002_F2PALq_Dark_Grey.jpg:Dark Grey,20251115_024002_j1KsVl_Heather_Grey.jpg:Heather Grey,20251115_024002_TlKJz8_Khaki.jpg:Khaki,20251115_024002_PwU89P_Navy.jpg:Navy', 'S, M, L, XL, XXL, 3XL', '2025-11-17 02:21:48', '2025-11-22 18:31:31', NULL, NULL, NULL, 1, 0),
(19, 'Blitzing Low Stretch Fit Cap', 'ACTIVEWEAR', ' Keep your look sharp and your fit comfortable with the Blitzing Low Stretch Fit Cap. Designed for active lifestyles, this low-profile cap combines breathable, textured knit fabric with an elastic sweatband that wicks moisture away. With stretch-fit construction, a curved visor, and embroidered logo detail—it’s the go-anywhere cap whether you’re out training, commuting, or running errands in the summer heat.\r\n', 'City Khaki, Grey Orange, Harbor Blue, Marine Green, Midnight Navy, Steel White', '1595.00', '20251115_024549_q3m2m2_City_Khaki.jpg,20251115_024549_fyeXoT_GreyOrange.jpg,20251115_024549_iIJAMV_Harbor_Blue.jpg,20251115_024549_vfQvFp_Marine_GreenBlack.jpg,20251115_024549_6y8KwC_Midnight_Navy.jpg,20251115_024549_0M7Tga_SteelWhite.jpg', '168', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_024549_q3m2m2_City_Khaki.jpg:City Khaki,20251115_024549_fyeXoT_GreyOrange.jpg:Grey Orange,20251115_024549_iIJAMV_Harbor_Blue.jpg:Harbor Blue,20251115_024549_vfQvFp_Marine_GreenBlack.jpg:Marine Green Black,20251115_024549_6y8KwC_Midnight_Navy.jpg:Midnight Navy,20251115_024549_0M7Tga_SteelWhite.jpg:Steel White', 'S, M, L, XL', '2025-11-17 02:21:48', '2025-11-23 04:40:02', NULL, NULL, NULL, 1, 0),
(20, 'Breathable Fitness Shorts', 'FITNESS', 'Step into comfort and performance with the DOMYOS Fitness Basic Breathable Shorts. Designed for men getting started (or stepping back in) in cardio and gym workouts, these shorts deliver breathable fabric, stretch, and ease — all without breaking the bank. With a minimalist black finish, they pair easily with any top, and their lightweight build ensures you stay cool and free-moving, whether you\'re at the gym, on a run, or training at home.\r\n', 'Black, Khaki, Navy', '290.00', '20251115_024815_YVwXpK_Black.jpg,20251115_024815_n56FjY_Khaki.jpg,20251115_024815_xzO8m6_Navy-Blue.jpg', '150', 5, 'tolentinomaann17@gmail.com', 2, NULL, '20251115_024815_YVwXpK_Black.jpg:Black,20251115_024815_n56FjY_Khaki.jpg:Khaki,20251115_024815_xzO8m6_Navy-Blue.jpg:Navy', 'S, M, L, XL, XXL', '2025-11-17 02:21:48', '2025-11-22 18:29:37', NULL, NULL, NULL, 1, 0),
(21, 'Muscle Fit Raglan T-Shirt', 'ACTIVEWEAR', 'We all know about t-shirts and vests, light layers which have stood the test of time. T-shirts are a seasonless staple which gives your wardrobe a solid foundation to build off. Whether you’re about a plain tee, printed, striped or long-sleeve or you’re flexing something oversized for a comfortably casual look, make sure your outfits have the foundations they need with our range of tees and vests. Combine a plain white tee with denim and trainers for a versatile everyday outfit or pair with cropped trousers to secure minimalistic vibes.\r\n', 'Light Blue, Light Green, Light Grey, Neon Orange, Neon Pink, Red, White', '607.56', '20251115_025047_beM3V4_Light_Blue.jpg,20251115_025047_odg2D7_Light_Green.jpg,20251115_025047_NDnRF6_Light_Grey.jpg,20251115_025047_5LkNJA_Neon_Orange.jpg,20251115_025047_AuTGQy_Neon_Pink.jpg,20251115_025047_bnU5d9_Red.jpg,20251115_025047_9exlOh_White.jpg', '490', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_025047_beM3V4_Light_Blue.jpg:Light Blue,20251115_025047_odg2D7_Light_Green.jpg:Light Green,20251115_025047_NDnRF6_Light_Grey.jpg:Light Grey,20251115_025047_5LkNJA_Neon_Orange.jpg:Neon Orange,20251115_025047_AuTGQy_Neon_Pink.jpg:Neon Pink,20251115_025047_bnU5d9_Red.jpg:Red,20251115_025047_9exlOh_White.jpg:White', 'XS, S, M, L, XL, XXL, 3XL', '2025-11-17 02:21:48', '2025-11-22 18:31:47', NULL, NULL, NULL, 1, 0),
(22, 'Cross-Body Bag', 'ACTIVEWEAR', 'The Nike Sportswear Essentials Cross-Body Bag features 2 zip pockets to let you keep the small stuff organised and easy to grab. The accessory pocket zip pull offers quick access to smaller items, while an adjustable strap and buckle provide an easy-on-and-off fit. This product is made from at least 50% recycled polyester fibres.\r\n', 'Black, Black Volt, White Orange', '1395.00', '20251115_025303_f845sc_BlackBlack.jpg,20251115_025303_xBVIv5_BlackVolt.jpg,20251115_025303_pe24iA_WhiteOrange.jpg', '30', 5, 'tolentinomaann17@gmail.com', 0, NULL, '20251115_025303_f845sc_BlackBlack.jpg:Black,20251115_025303_xBVIv5_BlackVolt.jpg:Black Volt,20251115_025303_pe24iA_WhiteOrange.jpg:White Orange', 'One Size', '2025-11-17 02:21:48', '2025-11-23 06:51:13', 'counterfeit', '2025-11-21 10:03:28', 'admin@gmail.com', 1, 1),
(23, 'Mens Korean Sports Running Breathable Casual Sneakers School Shoes For Men Students', 'SHOES', 'Applicable Scene: Work, Study, Shopping,motion\r\n', 'Gray Orange, Green Black', '378.00', '20251115_025520_T0mRas_grayorange.jpg,20251115_025520_0AhrYo_greenblack.jpg', '180', 5, 'tolentinomaann17@gmail.com', 3, 4.00, '20251115_025520_T0mRas_grayorange.jpg:Gray Orange,20251115_025520_0AhrYo_greenblack.jpg:Green Black', '39, 40, 41, 42, 43, 44, 45, 46, 47', '2025-11-17 02:21:48', '2025-11-22 18:31:19', NULL, NULL, NULL, 1, 0),
(24, 'Mens Genuine Leather Shoes Pull On Soft Anti-slip Rubber Loafers Mens Casual Business Shoes', 'SHOES', 'Step out in comfort and style with the 2024 Men\'s Genuine Leather Pull-On Loafers, featuring a soft fit and anti-slip rubber sole perfect for both casual and business wear.\r\n', 'Black', '399.00', '20251115_025830_g4qaCS_black.jpg', '70', 5, 'tolentinomaann17@gmail.com', 3, NULL, '20251115_025830_g4qaCS_black.jpg:Black', '39, 40, 41, 42, 43, 44, 45', '2025-11-17 02:21:48', '2025-11-22 18:31:10', NULL, NULL, NULL, 1, 0),
(25, 'New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch', 'ACCESSORIES', 'Style: casual, sporty, personalized, fashionable, multifunctional, luxurious\r\nFeatures: Full calendar, shockproof, stopwatch, automatic date, waterproof, diver, timer, backlight, multi time zone, swimming, alarm clock\r\nMovement: Original quartz movement\r\nMain features:\r\n-100% authentic, labeled and of high quality;\r\n-5ATM/50M waterproof (supports cold water showers and swimming, do not operate the watch underwater);\r\n-Multifunctional design\r\n-High quality strap, high-quality movement, luxurious appearance\r\nShell material: ABS\r\nWatch strap material: rubber\r\nHigh quality rubber strap\r\nSpecification (approximate value):\r\n-Dial diameter: 53 millimeters\r\n-Shell thickness: 15.6 millimeters\r\n-Watch strap length: 245 millimeters\r\nWatch weight: 68 grams\r\nWaterproof coefficient: 50 meters\r\n', 'Black, Gold, Green, Red, Silver', '599.00', '20251115_030035_pA8IaW_black.jpg,20251115_030035_3Z8kr2_gold.jpg,20251115_030035_tHM0Op_green.jpg,20251115_030035_eJMYVi_red.jpg,20251115_030035_Y8pZ4U_silver.jpg', '29', 5, 'tolentinomaann17@gmail.com', 12, NULL, '20251115_030035_pA8IaW_black.jpg:Black,20251115_030035_3Z8kr2_gold.jpg:Gold,20251115_030035_tHM0Op_green.jpg:Green,20251115_030035_eJMYVi_red.jpg:Red,20251115_030035_Y8pZ4U_silver.jpg:Silver', 'One Size', '2025-11-17 02:21:48', '2025-12-06 00:28:02', NULL, NULL, NULL, 1, 0),
(26, 'Vnox Layered 3D Vertical Bar Necklaces for Men, Stainless Steel Geometric Cuban Chain Necklace', 'ACCESSORIES', '316L Grade Stainless Steel (Safe on skin and children,Hypoallergenic&No fading)Chain length:50cm for the first layer, 50+5cm for the second layer\r\n', 'Standard', '233', '20251115_030228_z7gGPg_vnoxneck_2.jpg,20251115_030228_43s2YX_vnoxneck_3.jpg,20251115_030228_PZtpcI_vnoxneck.jpg', '9', 5, 'tolentinomaann17@gmail.com', 1, NULL, '20251115_030228_z7gGPg_vnoxneck_2.jpg:Standard,20251115_030228_43s2YX_vnoxneck_3.jpg:Standard,20251115_030228_PZtpcI_vnoxneck.jpg:Standard', 'One Size', '2025-11-17 02:21:48', '2025-12-03 06:49:24', NULL, NULL, NULL, 1, 0),
(27, 'Professional Shaver for Men 3 in 1 Electric Shaver Rechargeable Professional Razor Beard Trimmer', 'GROOMING', 'Experience the cutting-edge 4D Floating Technology that effortlessly adapts to the unique contours of your face and neck. This ensures a close, comfortable shave every time, leaving your skin smooth and refreshed.\r\n', 'Standard', '199.00', '20251115_030411_4CRP04_PROFES1.JPG', '50', 5, 'tolentinomaann17@gmail.com', 1, NULL, '20251115_030411_4CRP04_PROFES1.JPG:Standard', 'No size', '2025-11-17 02:21:48', '2025-11-23 04:06:31', NULL, NULL, NULL, 1, 0),
(28, 'Black Portable Electric Shaver for Men with USB Charging and Quiet Performance', 'GROOMING', 'Discover the Portable Electric Shaver for Men - Black Shaver Set, designed to revolutionize your grooming routine. This compact and stylish shaver is perfect for both travel and home use, fitting seamlessly into your lifestyle.\r\n', 'Black, Blue', '30', '20251115_030629_NIUCrq_black.jpg,20251115_030629_wlrznG_blue.jpg', '20', 5, 'tolentinomaann17@gmail.com', 1, 5.00, '20251115_030629_NIUCrq_black.jpg:Black,20251115_030629_wlrznG_blue.jpg:Blue', 'No size', '2025-11-17 02:21:48', '2025-11-23 04:40:42', NULL, NULL, NULL, 1, 0),
(29, 'KANAZAWA New Original Style Portable Shaver With TYPE-C Fast Charging For Man', 'GROOMING', 'Achieve a smooth, clean, and confident look with our premium men’s shaving essentials — designed for comfort, precision, and irritation-free grooming every time.', 'Standard', '79.00', '20251115_030742_1GAPNh_KANAZA2.JPG,20251115_030742_ecyTWk_KANAZA1.JPG', '20', 5, 'tolentinomaann17@gmail.com', 1, 5.00, '20251115_030742_1GAPNh_KANAZA2.JPG:Standard,20251115_030742_ecyTWk_KANAZA1.JPG:Standard', 'No size', '2025-11-17 02:21:48', '2025-11-28 02:11:54', NULL, NULL, NULL, 1, 0),
(30, 'Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size', 'GROOMING', 'Length Adjustable\r\nEquipped with Length Adjustable Handle\r\nSingle hand operation , you can precisely control hair length\r\n', 'Standard', '413.00', '20251115_031007_tPimJM_F6FCD21.JPG', '28', 5, 'tolentinomaann17@gmail.com', 1, 5.00, '20251115_031007_tPimJM_F6FCD21.JPG:Standard', 'No size', '2025-11-17 02:21:48', '2025-12-05 23:13:05', NULL, NULL, NULL, 1, 0),
(31, 'Hemp Pants', 'PANTS', 'dhsbchjdbd', 'Black, Brown, Green', '100.00', '20251118_092242_sm0Iit_black.jpg,20251118_092242_n5Mk5s_brown.jpg,20251118_092243_6X4vRM_green.jpg', '412', 5, 'tolentinomaann17@gmail.com', 5, 3.30, '20251118_092242_sm0Iit_black.jpg:Black,20251118_092242_n5Mk5s_brown.jpg:Brown,20251118_092243_6X4vRM_green.jpg:Green', '26×28, 27×30, 28×30, 29×30, 30×30, 31×30, 32×30, 33×30, 34×30, 36×30, 38×30, 40×30, 42×32, 44×32', '2025-11-18 01:22:43', '2025-12-05 22:56:43', NULL, NULL, NULL, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `promotions`
--

CREATE TABLE `promotions` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(50) NOT NULL,
  `seller_email` varchar(255) NOT NULL,
  `type` enum('percentage','fixed','buy_one_get_one','free_shipping') NOT NULL,
  `discount_value` decimal(10,2) DEFAULT NULL,
  `max_discount` decimal(10,2) DEFAULT NULL,
  `min_purchase` decimal(10,2) DEFAULT 0.00,
  `min_quantity` int(11) DEFAULT 1,
  `usage_limit_per_customer` int(11) DEFAULT NULL,
  `total_usage_limit` int(11) DEFAULT NULL,
  `current_usage_count` int(11) DEFAULT 0,
  `start_date` date NOT NULL,
  `start_time` time DEFAULT '00:00:00',
  `end_date` date NOT NULL,
  `end_time` time DEFAULT '23:59:59',
  `product_scope` enum('all','specific','category') DEFAULT 'all',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promotions`
--

INSERT INTO `promotions` (`id`, `name`, `code`, `seller_email`, `type`, `discount_value`, `max_discount`, `min_purchase`, `min_quantity`, `usage_limit_per_customer`, `total_usage_limit`, `current_usage_count`, `start_date`, `start_time`, `end_date`, `end_time`, `product_scope`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Holiday Shipping', '1QN8IP4R', 'tolentinomaann17@gmail.com', 'free_shipping', 0.00, NULL, 0.00, 1, NULL, NULL, 0, '2025-11-06', '00:00:00', '2025-11-13', '23:59:00', 'specific', 1, '2025-11-06 13:24:35', '2025-11-06 13:32:19'),
(2, 'Happy Sales', 'QVVJS5OQ', 'tolentinomaann17@gmail.com', 'percentage', 10.00, NULL, 0.00, 1, NULL, NULL, 0, '2025-11-06', '00:00:00', '2025-11-10', '23:59:00', 'specific', 1, '2025-11-06 13:25:30', '2025-11-06 13:25:30'),
(3, 'Buy One Get One free', 'NZIIGBQA', 'tolentinomaann17@gmail.com', 'buy_one_get_one', 0.00, NULL, 0.00, 1, NULL, NULL, 0, '2025-11-06', '00:00:00', '2025-11-11', '23:59:00', 'specific', 1, '2025-11-06 13:26:24', '2025-11-06 13:26:24'),
(4, '11.11 Sales', '27EWZ6P0', 'tolentinomaann17@gmail.com', 'fixed', 100.00, NULL, 0.00, 1, NULL, NULL, 0, '2025-11-06', '00:00:00', '2025-11-11', '23:59:00', 'specific', 1, '2025-11-06 13:27:01', '2025-11-06 13:27:01'),
(5, 'Holiday Shipping', 'LPK4E1B0', 'tolentinomaann17@gmail.com', 'free_shipping', 0.00, NULL, 0.00, 1, NULL, NULL, 10, '2025-11-14', '00:00:00', '2025-12-12', '23:59:00', 'specific', 1, '2025-11-14 15:01:49', '2025-12-06 00:19:59'),
(6, 'Happy Sales', '9V4V84ZS', 'tolentinomaann17@gmail.com', 'percentage', 25.00, NULL, 0.00, 1, NULL, NULL, 1, '2025-11-14', '00:00:00', '2025-12-12', '23:59:00', 'specific', 1, '2025-11-14 19:16:35', '2025-11-26 05:51:21'),
(7, 'Holiday Sales', 'E6GR0127', 'tolentinomaann17@gmail.com', 'fixed', 100.00, NULL, 0.00, 1, NULL, NULL, 1, '2025-11-14', '00:00:00', '2025-12-12', '23:59:00', 'specific', 1, '2025-11-14 19:17:34', '2025-11-19 11:10:29'),
(8, 'Buy One Get One Free', 'DKKXL6TN', 'tolentinomaann17@gmail.com', 'buy_one_get_one', 0.00, NULL, 0.00, 1, NULL, NULL, 2, '2025-11-14', '00:00:00', '2025-12-12', '23:59:00', 'specific', 1, '2025-11-14 19:18:49', '2025-12-05 23:07:02');

-- --------------------------------------------------------

--
-- Table structure for table `promotion_categories`
--

CREATE TABLE `promotion_categories` (
  `id` int(11) NOT NULL,
  `promotion_id` int(11) NOT NULL,
  `category` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `promotion_products`
--

CREATE TABLE `promotion_products` (
  `id` int(11) NOT NULL,
  `promotion_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promotion_products`
--

INSERT INTO `promotion_products` (`id`, `promotion_id`, `product_id`, `created_at`) VALUES
(13, 5, 22, '2025-11-14 19:14:38'),
(14, 5, 18, '2025-11-14 19:14:38'),
(15, 5, 11, '2025-11-14 19:14:38'),
(16, 5, 25, '2025-11-14 19:14:38'),
(17, 5, 27, '2025-11-14 19:14:38'),
(18, 5, 10, '2025-11-14 19:14:38'),
(19, 6, 9, '2025-11-14 19:16:35'),
(20, 6, 17, '2025-11-14 19:16:35'),
(21, 7, 19, '2025-11-14 19:17:34'),
(22, 7, 24, '2025-11-14 19:17:34'),
(23, 8, 30, '2025-11-14 19:18:49'),
(24, 8, 14, '2025-11-14 19:18:49');

-- --------------------------------------------------------

--
-- Table structure for table `promotion_usage`
--

CREATE TABLE `promotion_usage` (
  `id` int(11) NOT NULL,
  `promotion_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_email` varchar(255) NOT NULL,
  `product_id` varchar(50) DEFAULT NULL,
  `discount_applied` decimal(10,2) NOT NULL,
  `used_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promotion_usage`
--

INSERT INTO `promotion_usage` (`id`, `promotion_id`, `order_id`, `customer_email`, `product_id`, `discount_applied`, `used_at`) VALUES
(4, 5, 18, 'tolentinomariely09@gmail.com', '27', 50.00, '2025-11-18 09:21:02'),
(7, 7, 24, 'tolentinomariely09@gmail.com', '24', 100.00, '2025-11-19 11:10:29'),
(8, 5, 28, 'tolentinomariely09@gmail.com', '25', 50.00, '2025-11-22 06:51:20'),
(10, 5, 32, 'tolentinomariely09@gmail.com', '10', 50.00, '2025-11-22 17:48:23'),
(11, 5, 34, 'tolentinomariely09@gmail.com', '25', 50.00, '2025-11-23 14:09:54'),
(12, 6, 35, 'tolentinomariely09@gmail.com', '17', 113.25, '2025-11-26 05:51:21'),
(13, 8, 46, 'tolentinomariely09@gmail.com', '30', 0.00, '2025-12-05 23:07:02'),
(14, 5, 47, 'tolentinomariely09@gmail.com', '25', 50.00, '2025-12-06 00:19:59');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_email` varchar(255) NOT NULL,
  `seller_email` varchar(255) NOT NULL,
  `rating` int(11) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review_text` text NOT NULL,
  `seller_response` text DEFAULT NULL,
  `response_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `order_id`, `product_id`, `customer_email`, `seller_email`, `rating`, `review_text`, `seller_response`, `response_date`, `created_at`) VALUES
(2, 9, 29, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'good ', NULL, NULL, '2025-11-18 10:31:18'),
(3, 7, 11, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'nice quality', NULL, NULL, '2025-11-18 10:35:58'),
(4, 12, 31, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 4, 'nice one', NULL, NULL, '2025-11-18 10:46:27'),
(5, 15, 23, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 4, 'nice', NULL, NULL, '2025-11-18 11:08:53'),
(6, 17, 28, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'maganda', NULL, NULL, '2025-11-18 11:23:11'),
(7, 23, 17, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'Nice quality', 'thanks', '2025-12-01 15:16:19', '2025-11-25 06:41:36'),
(8, 14, 31, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'wow super ganda', 'salamat', '2025-12-03 07:30:04', '2025-12-03 07:29:14'),
(9, 40, 17, 'enchangtolentino1980@gmail.com', 'tolentinomaann17@gmail.com', 5, 'Maganda quality', 'salamat', '2025-12-04 19:19:43', '2025-12-04 19:05:58'),
(10, 42, 31, 'cordonaira26@gmail.com', 'tolentinomaann17@gmail.com', 1, 'Pamgit sya', 'Salamat ha', '2025-12-05 04:36:22', '2025-12-05 04:35:50'),
(11, 46, 30, 'tolentinomariely09@gmail.com', 'tolentinomaann17@gmail.com', 5, 'Good item', NULL, NULL, '2025-12-05 23:13:05');

-- --------------------------------------------------------

--
-- Table structure for table `rider_notifications`
--

CREATE TABLE `rider_notifications` (
  `id` int(11) NOT NULL,
  `rider_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rider_notifications`
--

INSERT INTO `rider_notifications` (`id`, `rider_email`, `message`, `order_id`, `is_read`, `created_at`) VALUES
(36, 'tolentinoann2001@gmail.com', 'New delivery available! Order #46 - Cosoul Hair Clipper Electric Hair Trimmer Hair Length Adjustable LED Display Beard Trimmer Portable Hair Clipper Compact Size (₱413.00). Pickup from MetroMan Styles  Bold & Basic.', 46, 0, '2025-12-05 23:07:44'),
(37, 'tolentinoann2001@gmail.com', 'New delivery available! Order #47 - New Electronic Mens Watch Fashion and Leisure Watch Waterproof Night Glow Multi functional Watch (₱5990.00). Pickup from MetroMan Styles  Bold & Basic.', 47, 0, '2025-12-06 00:21:50');

-- --------------------------------------------------------

--
-- Table structure for table `seller_rider_messages`
--

CREATE TABLE `seller_rider_messages` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `sender_email` varchar(255) NOT NULL,
  `receiver_email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores chat messages between sellers and riders for order deliveries';

--
-- Dumping data for table `seller_rider_messages`
--

INSERT INTO `seller_rider_messages` (`id`, `order_id`, `sender_email`, `receiver_email`, `message`, `is_read`, `created_at`) VALUES
(33, 46, 'tolentinoann2001@gmail.com', 'tolentinomaann17@gmail.com', 'Pick up ko na', 1, '2025-12-05 23:09:03'),
(34, 46, 'tolentinomaann17@gmail.com', 'tolentinoann2001@gmail.com', 'sige po', 1, '2025-12-05 23:09:16');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` varchar(50) NOT NULL,
  `status` enum('active','banned','suspended','inactive') DEFAULT 'active',
  `valid_id_path` varchar(500) DEFAULT NULL,
  `dti_path` varchar(500) DEFAULT NULL,
  `bir_path` varchar(500) DEFAULT NULL,
  `business_permit_path` varchar(500) DEFAULT NULL,
  `business_name` varchar(200) DEFAULT NULL,
  `business_type` enum('individual','business') DEFAULT NULL,
  `profile_picture` varchar(500) DEFAULT NULL,
  `vehicle_type` enum('motorcycle','bicycle','car','tricycle') DEFAULT NULL,
  `vehicle_model` varchar(100) DEFAULT NULL,
  `vehicle_plate_number` varchar(20) DEFAULT NULL,
  `vehicle_year_model` varchar(4) DEFAULT NULL,
  `or_cr_path` varchar(500) DEFAULT NULL,
  `nbi_clearance_path` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_banned` tinyint(1) DEFAULT 0,
  `ban_reason` text DEFAULT NULL,
  `ban_date` datetime DEFAULT NULL,
  `ban_duration` varchar(20) DEFAULT 'permanent',
  `ban_end_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `password`, `email`, `phone_number`, `address`, `user_type`, `status`, `valid_id_path`, `dti_path`, `bir_path`, `business_permit_path`, `business_name`, `business_type`, `profile_picture`, `vehicle_type`, `vehicle_model`, `vehicle_plate_number`, `vehicle_year_model`, `or_cr_path`, `nbi_clearance_path`, `created_at`, `is_banned`, `ban_reason`, `ban_date`, `ban_duration`, `ban_end_date`) VALUES
(1, 'Ann', 'Tolentino', 'scrypt:32768:8:1$ylKHmGjp6SSBYliU$a28c75f1f9a71ab9b40ea2038aec571971fc8851cb78c87033aae7c652a3fd6670a7de238db6510a9292c250ed6d33bbfcd9e96f06cdb9c0bad5693783cb0a03', 'tolentinoann2001@gmail.com', '9126231588', 'Purok 1, Tubuan, Pila, Laguna, CALABARZON, 4010', 'rider', 'active', 'static/images/uploads\\ids\\20251025_231726_act73.jpg', NULL, NULL, NULL, NULL, NULL, '20251125_153917_6mYRef_profile.jpg', 'motorcycle', 'Honda Click 125i', 'ABC-1234', '2023', 'static/images/uploads\\rider_docs\\20251025_231726_act71.png', 'static/images/uploads\\rider_docs\\20251025_231726_act7.jpg', '2025-10-25 15:19:52', 0, NULL, NULL, 'permanent', NULL),
(2, 'Mariely Ann', 'Tolentino', 'scrypt:32768:8:1$rcpJY9RUCW2kBN7u$1ac13b32dd802a4c318feaa2dba4b053f60d1b54d5fef457948c40e4b974285e06831cceadcf6c6181a7f15d2131ca4029d53c038a115316217c733cdb62cdf6', 'tolentinomariely09@gmail.com', '9679757728', '02 Ibañez Street , San Diego, Luisiana, Laguna, CALABARZON, 4032', 'buyer', 'active', 'static/images/uploads\\ids\\20251025_221308_act73.jpg', NULL, NULL, NULL, NULL, NULL, '20251126_140121_Nsrg8m_profile.png', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-25 15:40:24', 0, NULL, NULL, NULL, NULL),
(4, 'MaAnn', 'Tolentino', 'scrypt:32768:8:1$MooGv9gmAaJks4fP$81aa45ace8ce80fd4b973e43937c8708554697d7ddbf7d00dc70c99a1c1ebe24505b6eccc2378b6d32c8f0b8273a7d3eb4dda872abd16070ba0e00c00a9ed798', 'tolentinomaann17@gmail.com', '9126231588', 'Teodoro Street, Pob. 1, Sta Cruz, Laguna, CALABARZON 4009', 'Seller', 'active', 'static/images/uploads\\seller_docs\\20251026_021549_Screenshot_2025-02-10_105446.png', 'static/images/uploads\\seller_docs\\20251026_021549_Screenshot_2025-02-08_181132.png', 'static/images/uploads\\seller_docs\\20251026_021549_Screenshot_2025-02-10_105142.png', 'static/images/uploads\\seller_docs\\20251026_021549_Screenshot_2025-02-10_105356.png', 'MetroMan Styles  Bold & Basic', 'business', '20251124_195328_itIMx6_profile.png', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-06 13:07:11', 0, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `variant_inventory`
--

CREATE TABLE `variant_inventory` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `color` varchar(100) NOT NULL,
  `size` varchar(50) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `low_stock_threshold` int(11) DEFAULT 5,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variant_inventory`
--

INSERT INTO `variant_inventory` (`id`, `product_id`, `color`, `size`, `stock_quantity`, `low_stock_threshold`, `created_at`, `updated_at`) VALUES
(1, 10, 'Black', 'XS', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(2, 10, 'Black', 'S', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(3, 10, 'Black', 'M', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(4, 10, 'Black', 'L', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(5, 10, 'Black', 'XL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(6, 10, 'Black', 'XXL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(7, 10, 'Burgundy', 'XS', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(8, 10, 'Burgundy', 'S', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(9, 10, 'Burgundy', 'M', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(10, 10, 'Burgundy', 'L', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(11, 10, 'Burgundy', 'XL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(12, 10, 'Burgundy', 'XXL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(13, 10, 'Navy', 'XS', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(14, 10, 'Navy', 'S', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(15, 10, 'Navy', 'M', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(16, 10, 'Navy', 'L', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(17, 10, 'Navy', 'XL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(18, 10, 'Navy', 'XXL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(19, 10, 'White', 'XS', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(20, 10, 'White', 'S', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(21, 10, 'White', 'M', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(22, 10, 'White', 'L', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(23, 10, 'White', 'XL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(24, 10, 'White', 'XXL', 10, 5, '2025-11-22 17:22:45', '2025-11-23 07:09:47'),
(25, 12, 'Black', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(26, 12, 'Black', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(27, 12, 'Black', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(28, 12, 'Black', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(29, 12, 'Black', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(30, 12, 'Black', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(31, 12, 'Blossom Palm', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(32, 12, 'Blossom Palm', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(33, 12, 'Blossom Palm', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(34, 12, 'Blossom Palm', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(35, 12, 'Blossom Palm', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(36, 12, 'Blossom Palm', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:37'),
(37, 12, 'Colorful Skulls', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(38, 12, 'Colorful Skulls', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(39, 12, 'Colorful Skulls', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(40, 12, 'Colorful Skulls', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(41, 12, 'Colorful Skulls', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(42, 12, 'Colorful Skulls', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(43, 12, 'Daybreak Palm', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(44, 12, 'Daybreak Palm', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(45, 12, 'Daybreak Palm', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(46, 12, 'Daybreak Palm', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(47, 12, 'Daybreak Palm', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(48, 12, 'Daybreak Palm', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(49, 12, 'Ethnic Navy', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(50, 12, 'Ethnic Navy', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(51, 12, 'Ethnic Navy', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(52, 12, 'Ethnic Navy', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(53, 12, 'Ethnic Navy', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(54, 12, 'Ethnic Navy', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(55, 12, 'Fiery Swirl', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(56, 12, 'Fiery Swirl', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(57, 12, 'Fiery Swirl', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(58, 12, 'Fiery Swirl', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(59, 12, 'Fiery Swirl', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(60, 12, 'Fiery Swirl', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(61, 12, 'Flamingo Leaf', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(62, 12, 'Flamingo Leaf', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(63, 12, 'Flamingo Leaf', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(64, 12, 'Flamingo Leaf', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(65, 12, 'Flamingo Leaf', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(66, 12, 'Flamingo Leaf', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(67, 12, 'Flamingo Mink', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(68, 12, 'Flamingo Mink', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(69, 12, 'Flamingo Mink', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(70, 12, 'Flamingo Mink', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(71, 12, 'Flamingo Mink', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(72, 12, 'Flamingo Mink', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(73, 12, 'Green Leaves', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(74, 12, 'Green Leaves', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(75, 12, 'Green Leaves', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(76, 12, 'Green Leaves', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(77, 12, 'Green Leaves', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(78, 12, 'Green Leaves', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(79, 12, 'Golden Jungle', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(80, 12, 'Golden Jungle', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(81, 12, 'Golden Jungle', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:38'),
(82, 12, 'Golden Jungle', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(83, 12, 'Golden Jungle', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(84, 12, 'Golden Jungle', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(85, 12, 'Indigo Impasto', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(86, 12, 'Indigo Impasto', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(87, 12, 'Indigo Impasto', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(88, 12, 'Indigo Impasto', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(89, 12, 'Indigo Impasto', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(90, 12, 'Indigo Impasto', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(91, 12, 'Lush Leafs', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(92, 12, 'Lush Leafs', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(93, 12, 'Lush Leafs', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(94, 12, 'Lush Leafs', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(95, 12, 'Lush Leafs', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(96, 12, 'Lush Leafs', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(97, 12, 'Midnight Hibiscus', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(98, 12, 'Midnight Hibiscus', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(99, 12, 'Midnight Hibiscus', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(100, 12, 'Midnight Hibiscus', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(101, 12, 'Midnight Hibiscus', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(102, 12, 'Midnight Hibiscus', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(103, 12, 'Morning Glory', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(104, 12, 'Morning Glory', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(105, 12, 'Morning Glory', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(106, 12, 'Morning Glory', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(107, 12, 'Morning Glory', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(108, 12, 'Morning Glory', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(109, 12, 'Navy Sketch', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(110, 12, 'Navy Sketch', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(111, 12, 'Navy Sketch', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(112, 12, 'Navy Sketch', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(113, 12, 'Navy Sketch', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(114, 12, 'Navy Sketch', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(115, 12, 'Sage Green', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(116, 12, 'Sage Green', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(117, 12, 'Sage Green', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(118, 12, 'Sage Green', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(119, 12, 'Sage Green', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(120, 12, 'Sage Green', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(121, 12, 'Tropical Cerulean', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(122, 12, 'Tropical Cerulean', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(123, 12, 'Tropical Cerulean', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(124, 12, 'Tropical Cerulean', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(125, 12, 'Tropical Cerulean', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(126, 12, 'Tropical Cerulean', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(127, 12, 'Verdant Jungle', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(128, 12, 'Verdant Jungle', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(129, 12, 'Verdant Jungle', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(130, 12, 'Verdant Jungle', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(131, 12, 'Verdant Jungle', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(132, 12, 'Verdant Jungle', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(133, 12, 'Waterweed Green', 'S', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(134, 12, 'Waterweed Green', 'M', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(135, 12, 'Waterweed Green', 'L', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(136, 12, 'Waterweed Green', 'XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(137, 12, 'Waterweed Green', 'XXL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(138, 12, 'Waterweed Green', '3XL', 10, 5, '2025-11-22 17:26:34', '2025-11-23 04:41:39'),
(139, 28, 'Black', 'No size', 10, 5, '2025-11-22 18:28:50', '2025-11-23 04:40:42'),
(140, 28, 'Blue', 'No size', 10, 5, '2025-11-22 18:28:50', '2025-11-23 04:40:42'),
(141, 19, 'City Khaki', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(142, 19, 'City Khaki', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(143, 19, 'City Khaki', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(144, 19, 'City Khaki', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(145, 19, 'Grey Orange', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(146, 19, 'Grey Orange', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(147, 19, 'Grey Orange', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(148, 19, 'Grey Orange', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(149, 19, 'Harbor Blue', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(150, 19, 'Harbor Blue', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(151, 19, 'Harbor Blue', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(152, 19, 'Harbor Blue', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(153, 19, 'Marine Green', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(154, 19, 'Marine Green', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(155, 19, 'Marine Green', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(156, 19, 'Marine Green', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(157, 19, 'Midnight Navy', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(158, 19, 'Midnight Navy', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(159, 19, 'Midnight Navy', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(160, 19, 'Midnight Navy', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(161, 19, 'Steel White', 'S', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(162, 19, 'Steel White', 'M', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(163, 19, 'Steel White', 'L', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(164, 19, 'Steel White', 'XL', 7, 5, '2025-11-22 18:29:16', '2025-11-23 04:40:02'),
(165, 20, 'Black', 'S', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(166, 20, 'Black', 'M', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(167, 20, 'Black', 'L', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(168, 20, 'Black', 'XL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(169, 20, 'Black', 'XXL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(170, 20, 'Khaki', 'S', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(171, 20, 'Khaki', 'M', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(172, 20, 'Khaki', 'L', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(173, 20, 'Khaki', 'XL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(174, 20, 'Khaki', 'XXL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(175, 20, 'Navy', 'S', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(176, 20, 'Navy', 'M', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(177, 20, 'Navy', 'L', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(178, 20, 'Navy', 'XL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(179, 20, 'Navy', 'XXL', 10, 5, '2025-11-22 18:29:25', '2025-11-22 18:29:37'),
(198, 22, 'Black', 'One Size', 10, 5, '2025-11-22 18:30:00', '2025-11-23 06:51:13'),
(199, 22, 'Black Volt', 'One Size', 10, 5, '2025-11-22 18:30:00', '2025-11-23 06:51:13'),
(200, 22, 'White Orange', 'One Size', 10, 5, '2025-11-22 18:30:00', '2025-11-23 06:51:13'),
(201, 9, 'Apricot', 'S', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(202, 9, 'Apricot', 'M', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(203, 9, 'Apricot', 'L', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(204, 9, 'Apricot', 'XL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(205, 9, 'Apricot', 'XXL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(206, 9, 'Black Grey', 'S', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(207, 9, 'Black Grey', 'M', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(208, 9, 'Black Grey', 'L', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(209, 9, 'Black Grey', 'XL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(210, 9, 'Black Grey', 'XXL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(211, 9, 'Black', 'S', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(212, 9, 'Black', 'M', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(213, 9, 'Black', 'L', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(214, 9, 'Black', 'XL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(215, 9, 'Black', 'XXL', 10, 5, '2025-11-22 18:30:16', '2025-11-22 18:30:16'),
(216, 29, 'Standard', 'No size', 10, 5, '2025-11-22 18:30:28', '2025-11-28 02:11:37'),
(253, 16, 'Black', 'S', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(254, 16, 'Black', 'M', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(255, 16, 'Black', 'L', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(256, 16, 'Black', 'XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(257, 16, 'Black', 'XXL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(258, 16, 'Black', '3XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(259, 16, 'Black', '4XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(260, 16, 'Blue', 'S', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(261, 16, 'Blue', 'M', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(262, 16, 'Blue', 'L', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(263, 16, 'Blue', 'XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(264, 16, 'Blue', 'XXL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(265, 16, 'Blue', '3XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(266, 16, 'Blue', '4XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(267, 16, 'Brown', 'S', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(268, 16, 'Brown', 'M', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(269, 16, 'Brown', 'L', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(270, 16, 'Brown', 'XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(271, 16, 'Brown', 'XXL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(272, 16, 'Brown', '3XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(273, 16, 'Brown', '4XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(274, 16, 'Green', 'S', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(275, 16, 'Green', 'M', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(276, 16, 'Green', 'L', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(277, 16, 'Green', 'XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(278, 16, 'Green', 'XXL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(279, 16, 'Green', '3XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(280, 16, 'Green', '4XL', 10, 5, '2025-11-22 18:30:46', '2025-11-22 18:30:46'),
(281, 15, 'Acid Wash', 'L', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(282, 15, 'Acid Wash', 'XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(283, 15, 'Acid Wash', 'XXL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(284, 15, 'Acid Wash', '3XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(285, 15, 'Acid Wash', '4XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(286, 15, 'Acid Wash', '5XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(287, 15, 'Black', 'L', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(288, 15, 'Black', 'XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(289, 15, 'Black', 'XXL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(290, 15, 'Black', '3XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(291, 15, 'Black', '4XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(292, 15, 'Black', '5XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(293, 15, 'Whisker Wash', 'L', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(294, 15, 'Whisker Wash', 'XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(295, 15, 'Whisker Wash', 'XXL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(296, 15, 'Whisker Wash', '3XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(297, 15, 'Whisker Wash', '4XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(298, 15, 'Whisker Wash', '5XL', 10, 5, '2025-11-22 18:30:53', '2025-11-22 18:30:53'),
(299, 17, 'Fleece Black', 'S', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(300, 17, 'Fleece Black', 'M', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(301, 17, 'Fleece Black', 'L', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(302, 17, 'Fleece Black', 'XL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(303, 17, 'Fleece Black', 'XXL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(304, 17, 'Fleece Blue', 'S', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(305, 17, 'Fleece Blue', 'M', 5, 5, '2025-11-22 18:31:00', '2025-12-05 05:23:50'),
(306, 17, 'Fleece Blue', 'L', 5, 5, '2025-11-22 18:31:00', '2025-12-05 03:29:30'),
(307, 17, 'Fleece Blue', 'XL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(308, 17, 'Fleece Blue', 'XXL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(309, 17, 'Fleece Green', 'S', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(310, 17, 'Fleece Green', 'M', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(311, 17, 'Fleece Green', 'L', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(312, 17, 'Fleece Green', 'XL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(313, 17, 'Fleece Green', 'XXL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(314, 17, 'Fleece White', 'S', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(315, 17, 'Fleece White', 'M', 5, 5, '2025-11-22 18:31:00', '2025-11-26 05:51:21'),
(316, 17, 'Fleece White', 'L', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(317, 17, 'Fleece White', 'XL', 6, 5, '2025-11-22 18:31:00', '2025-11-23 04:42:18'),
(318, 17, 'Fleece White', 'XXL', 4, 5, '2025-11-22 18:31:00', '2025-12-04 06:30:20'),
(319, 24, 'Black', '39', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(320, 24, 'Black', '40', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(321, 24, 'Black', '41', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(322, 24, 'Black', '42', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(323, 24, 'Black', '43', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(324, 24, 'Black', '44', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(325, 24, 'Black', '45', 10, 5, '2025-11-22 18:31:10', '2025-11-22 18:31:10'),
(326, 23, 'Gray Orange', '39', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(327, 23, 'Gray Orange', '40', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(328, 23, 'Gray Orange', '41', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(329, 23, 'Gray Orange', '42', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(330, 23, 'Gray Orange', '43', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(331, 23, 'Gray Orange', '44', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(332, 23, 'Gray Orange', '45', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(333, 23, 'Gray Orange', '46', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(334, 23, 'Gray Orange', '47', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(335, 23, 'Green Black', '39', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(336, 23, 'Green Black', '40', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(337, 23, 'Green Black', '41', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(338, 23, 'Green Black', '42', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(339, 23, 'Green Black', '43', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(340, 23, 'Green Black', '44', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(341, 23, 'Green Black', '45', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(342, 23, 'Green Black', '46', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(343, 23, 'Green Black', '47', 10, 5, '2025-11-22 18:31:19', '2025-11-22 18:31:19'),
(344, 18, 'Black Green', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(345, 18, 'Black Green', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(346, 18, 'Black Green', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(347, 18, 'Black Green', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(348, 18, 'Black Green', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(349, 18, 'Black Green', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(350, 18, 'Black Grey', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(351, 18, 'Black Grey', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(352, 18, 'Black Grey', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(353, 18, 'Black Grey', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(354, 18, 'Black Grey', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(355, 18, 'Black Grey', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(356, 18, 'Black', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(357, 18, 'Black', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(358, 18, 'Black', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(359, 18, 'Black', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(360, 18, 'Black', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(361, 18, 'Black', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(362, 18, 'Dark Grey', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(363, 18, 'Dark Grey', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(364, 18, 'Dark Grey', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(365, 18, 'Dark Grey', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(366, 18, 'Dark Grey', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(367, 18, 'Dark Grey', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(368, 18, 'Heather Grey', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(369, 18, 'Heather Grey', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(370, 18, 'Heather Grey', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(371, 18, 'Heather Grey', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(372, 18, 'Heather Grey', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(373, 18, 'Heather Grey', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(374, 18, 'Khaki', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(375, 18, 'Khaki', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(376, 18, 'Khaki', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(377, 18, 'Khaki', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(378, 18, 'Khaki', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(379, 18, 'Khaki', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(380, 18, 'Navy', 'S', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(381, 18, 'Navy', 'M', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(382, 18, 'Navy', 'L', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(383, 18, 'Navy', 'XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(384, 18, 'Navy', 'XXL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(385, 18, 'Navy', '3XL', 10, 5, '2025-11-22 18:31:31', '2025-11-22 18:31:31'),
(386, 11, 'Black', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(387, 11, 'Black', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(388, 11, 'Black', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(389, 11, 'Black', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(390, 11, 'Black', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(391, 11, 'Black', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(392, 11, 'Blue', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(393, 11, 'Blue', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(394, 11, 'Blue', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(395, 11, 'Blue', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(396, 11, 'Blue', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(397, 11, 'Blue', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(398, 11, 'Brown', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(399, 11, 'Brown', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(400, 11, 'Brown', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(401, 11, 'Brown', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(402, 11, 'Brown', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(403, 11, 'Brown', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(404, 11, 'Green', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(405, 11, 'Green', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(406, 11, 'Green', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(407, 11, 'Green', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(408, 11, 'Green', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(409, 11, 'Green', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(410, 11, 'Light Blue', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(411, 11, 'Light Blue', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(412, 11, 'Light Blue', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(413, 11, 'Light Blue', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(414, 11, 'Light Blue', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(415, 11, 'Light Blue', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(416, 11, 'Light Grey', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(417, 11, 'Light Grey', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(418, 11, 'Light Grey', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(419, 11, 'Light Grey', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(420, 11, 'Light Grey', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(421, 11, 'Light Grey', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(422, 11, 'Pink', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(423, 11, 'Pink', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(424, 11, 'Pink', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(425, 11, 'Pink', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(426, 11, 'Pink', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(427, 11, 'Pink', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(428, 11, 'Sky Blue', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(429, 11, 'Sky Blue', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(430, 11, 'Sky Blue', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(431, 11, 'Sky Blue', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(432, 11, 'Sky Blue', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(433, 11, 'Sky Blue', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(434, 11, 'White', 'S', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(435, 11, 'White', 'M', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(436, 11, 'White', 'L', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(437, 11, 'White', 'XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(438, 11, 'White', 'XXL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(439, 11, 'White', '3XL', 10, 5, '2025-11-22 18:31:40', '2025-11-22 18:31:40'),
(440, 21, 'Light Blue', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(441, 21, 'Light Blue', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(442, 21, 'Light Blue', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(443, 21, 'Light Blue', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(444, 21, 'Light Blue', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(445, 21, 'Light Blue', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(446, 21, 'Light Blue', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(447, 21, 'Light Green', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(448, 21, 'Light Green', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(449, 21, 'Light Green', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(450, 21, 'Light Green', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(451, 21, 'Light Green', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(452, 21, 'Light Green', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(453, 21, 'Light Green', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(454, 21, 'Light Grey', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(455, 21, 'Light Grey', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(456, 21, 'Light Grey', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(457, 21, 'Light Grey', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(458, 21, 'Light Grey', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(459, 21, 'Light Grey', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(460, 21, 'Light Grey', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(461, 21, 'Neon Orange', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(462, 21, 'Neon Orange', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(463, 21, 'Neon Orange', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(464, 21, 'Neon Orange', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(465, 21, 'Neon Orange', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(466, 21, 'Neon Orange', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(467, 21, 'Neon Orange', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(468, 21, 'Neon Pink', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(469, 21, 'Neon Pink', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(470, 21, 'Neon Pink', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(471, 21, 'Neon Pink', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(472, 21, 'Neon Pink', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(473, 21, 'Neon Pink', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(474, 21, 'Neon Pink', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(475, 21, 'Red', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(476, 21, 'Red', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(477, 21, 'Red', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(478, 21, 'Red', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(479, 21, 'Red', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(480, 21, 'Red', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(481, 21, 'Red', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(482, 21, 'White', 'XS', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(483, 21, 'White', 'S', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(484, 21, 'White', 'M', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(485, 21, 'White', 'L', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(486, 21, 'White', 'XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(487, 21, 'White', 'XXL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(488, 21, 'White', '3XL', 10, 5, '2025-11-22 18:31:47', '2025-11-22 18:31:47'),
(489, 25, 'Black', 'One Size', 0, 5, '2025-11-22 18:31:53', '2025-12-06 00:19:48'),
(490, 25, 'Gold', 'One Size', 10, 5, '2025-11-22 18:31:53', '2025-11-23 06:51:02'),
(491, 25, 'Green', 'One Size', 10, 5, '2025-11-22 18:31:53', '2025-11-23 06:51:02'),
(492, 25, 'Red', 'One Size', 9, 5, '2025-11-22 18:31:53', '2025-11-23 14:09:54'),
(493, 25, 'Silver', 'One Size', 10, 5, '2025-11-22 18:31:53', '2025-11-23 06:51:02'),
(512, 7, 'Black', 'S', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(513, 7, 'Black', 'M', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(514, 7, 'Black', 'L', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(515, 7, 'Black', 'XL', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(516, 7, 'Burgundy', 'S', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(517, 7, 'Burgundy', 'M', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(518, 7, 'Burgundy', 'L', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(519, 7, 'Burgundy', 'XL', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(520, 7, 'Navy', 'S', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(521, 7, 'Navy', 'M', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(522, 7, 'Navy', 'L', 10, 5, '2025-11-22 18:32:08', '2025-11-22 18:32:08'),
(523, 7, 'Navy', 'XL', 9, 5, '2025-11-22 18:32:08', '2025-11-26 06:29:41'),
(524, 14, 'Beige', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(525, 14, 'Beige', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(526, 14, 'Beige', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(527, 14, 'Beige', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(528, 14, 'Beige', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(529, 14, 'Beige', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(530, 14, 'Beige', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(531, 14, 'Beige', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(532, 14, 'Beige', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(533, 14, 'Beige', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(534, 14, 'Beige', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(535, 14, 'Beige', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(536, 14, 'Beige', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(537, 14, 'Beige', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(538, 14, 'Black', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(539, 14, 'Black', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(540, 14, 'Black', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(541, 14, 'Black', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(542, 14, 'Black', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(543, 14, 'Black', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(544, 14, 'Black', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(545, 14, 'Black', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(546, 14, 'Black', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(547, 14, 'Black', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(548, 14, 'Black', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(549, 14, 'Black', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(550, 14, 'Black', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(551, 14, 'Black', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(552, 14, 'Gray', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(553, 14, 'Gray', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(554, 14, 'Gray', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(555, 14, 'Gray', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(556, 14, 'Gray', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(557, 14, 'Gray', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(558, 14, 'Gray', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(559, 14, 'Gray', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(560, 14, 'Gray', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(561, 14, 'Gray', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(562, 14, 'Gray', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(563, 14, 'Gray', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(564, 14, 'Gray', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(565, 14, 'Gray', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(566, 14, 'Navy', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(567, 14, 'Navy', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(568, 14, 'Navy', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(569, 14, 'Navy', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(570, 14, 'Navy', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(571, 14, 'Navy', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(572, 14, 'Navy', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(573, 14, 'Navy', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(574, 14, 'Navy', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(575, 14, 'Navy', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(576, 14, 'Navy', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(577, 14, 'Navy', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(578, 14, 'Navy', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(579, 14, 'Navy', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(580, 14, 'Silver Gray', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(581, 14, 'Silver Gray', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(582, 14, 'Silver Gray', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(583, 14, 'Silver Gray', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(584, 14, 'Silver Gray', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(585, 14, 'Silver Gray', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(586, 14, 'Silver Gray', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(587, 14, 'Silver Gray', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(588, 14, 'Silver Gray', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(589, 14, 'Silver Gray', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(590, 14, 'Silver Gray', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(591, 14, 'Silver Gray', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(592, 14, 'Silver Gray', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(593, 14, 'Silver Gray', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(594, 14, 'White', '26×28', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(595, 14, 'White', '27×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(596, 14, 'White', '28×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(597, 14, 'White', '29×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(598, 14, 'White', '30×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(599, 14, 'White', '31×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(600, 14, 'White', '32×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(601, 14, 'White', '33×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(602, 14, 'White', '34×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(603, 14, 'White', '36×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(604, 14, 'White', '38×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(605, 14, 'White', '40×30', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(606, 14, 'White', '42×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(607, 14, 'White', '44×32', 10, 5, '2025-11-22 18:32:17', '2025-11-22 18:32:17'),
(608, 27, 'Standard', 'No size', 50, 5, '2025-11-22 18:32:24', '2025-11-23 04:06:31'),
(609, 31, 'Black', '26×28', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(610, 31, 'Black', '27×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(611, 31, 'Black', '28×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(612, 31, 'Black', '29×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(613, 31, 'Black', '30×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(614, 31, 'Black', '31×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(615, 31, 'Black', '32×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(616, 31, 'Black', '33×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(617, 31, 'Black', '34×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(618, 31, 'Black', '36×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(619, 31, 'Black', '38×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(620, 31, 'Black', '40×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(621, 31, 'Black', '42×32', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(622, 31, 'Black', '44×32', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(623, 31, 'Brown', '26×28', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(624, 31, 'Brown', '27×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(625, 31, 'Brown', '28×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(626, 31, 'Brown', '29×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(627, 31, 'Brown', '30×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(628, 31, 'Brown', '31×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(629, 31, 'Brown', '32×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(630, 31, 'Brown', '33×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(631, 31, 'Brown', '34×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(632, 31, 'Brown', '36×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(633, 31, 'Brown', '38×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(634, 31, 'Brown', '40×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(635, 31, 'Brown', '42×32', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(636, 31, 'Brown', '44×32', 8, 5, '2025-11-22 18:32:30', '2025-12-05 22:55:49'),
(637, 31, 'Green', '26×28', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(638, 31, 'Green', '27×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(639, 31, 'Green', '28×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(640, 31, 'Green', '29×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(641, 31, 'Green', '30×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(642, 31, 'Green', '31×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(643, 31, 'Green', '32×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(644, 31, 'Green', '33×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(645, 31, 'Green', '34×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(646, 31, 'Green', '36×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(647, 31, 'Green', '38×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(648, 31, 'Green', '40×30', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(649, 31, 'Green', '42×32', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(650, 31, 'Green', '44×32', 9, 5, '2025-11-22 18:32:30', '2025-12-05 11:33:05'),
(669, 26, 'Standard', 'One Size', 10, 5, '2025-11-23 04:43:15', '2025-11-23 06:50:51'),
(722, 30, 'Standard', 'No size', 29, 5, '2025-11-28 02:11:22', '2025-12-05 23:07:02');

-- --------------------------------------------------------

--
-- Table structure for table `wishlist`
--

CREATE TABLE `wishlist` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wishlist`
--

INSERT INTO `wishlist` (`id`, `user_id`, `product_id`, `created_at`) VALUES
(26, 2, 25, '2025-11-17 16:29:31'),
(31, 2, 23, '2025-11-17 16:46:42'),
(33, 2, 24, '2025-11-17 17:10:18'),
(34, 2, 29, '2025-11-18 06:20:21'),
(43, 2, 31, '2025-12-05 22:47:53');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `archive`
--
ALTER TABLE `archive`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `buyer_notifications`
--
ALTER TABLE `buyer_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_buyer_email` (`buyer_email`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_is_read` (`is_read`);

--
-- Indexes for table `buyer_rider_messages`
--
ALTER TABLE `buyer_rider_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_sender_email` (`sender_email`),
  ADD KEY `idx_receiver_email` (`receiver_email`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `buyer_seller_messages`
--
ALTER TABLE `buyer_seller_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation` (`conversation_id`),
  ADD KEY `idx_sender` (`sender_email`),
  ADD KEY `idx_receiver` (`receiver_email`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `checkout`
--
ALTER TABLE `checkout`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `idx_shipping_fee` (`shipping_fee`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `conversation_id` (`conversation_id`),
  ADD KEY `idx_buyer` (`buyer_email`),
  ADD KEY `idx_seller` (`seller_email`),
  ADD KEY `idx_product` (`product_id`),
  ADD KEY `idx_order` (`order_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_seller_email` (`seller_email`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_is_read` (`is_read`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `idx_rider_email` (`rider_email`),
  ADD KEY `idx_status_rider` (`status`,`rider_email`);

--
-- Indexes for table `order_issues`
--
ALTER TABLE `order_issues`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_reporter_role` (`reporter_role`),
  ADD KEY `idx_reporter_email` (`reporter_email`),
  ADD KEY `idx_reported_against_role` (`reported_against_role`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `pending_sellers`
--
ALTER TABLE `pending_sellers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_business_type` (`business_type`);

--
-- Indexes for table `pending_users`
--
ALTER TABLE `pending_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_vehicle_type` (`vehicle_type`),
  ADD KEY `idx_user_type` (`user_type`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_low_stock` (`quantity`,`low_stock_threshold`);

--
-- Indexes for table `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_seller_email` (`seller_email`),
  ADD KEY `idx_code` (`code`),
  ADD KEY `idx_active_dates` (`is_active`,`start_date`,`end_date`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_product_scope` (`product_scope`);

--
-- Indexes for table `promotion_categories`
--
ALTER TABLE `promotion_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_promotion_category` (`promotion_id`,`category`),
  ADD KEY `idx_promotion_id` (`promotion_id`),
  ADD KEY `idx_category` (`category`);

--
-- Indexes for table `promotion_products`
--
ALTER TABLE `promotion_products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_promotion_product` (`promotion_id`,`product_id`),
  ADD KEY `idx_promotion_id` (`promotion_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `promotion_usage`
--
ALTER TABLE `promotion_usage`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_promotion_id` (`promotion_id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_customer_email` (`customer_email`),
  ADD KEY `idx_used_at` (`used_at`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_customer` (`order_id`,`customer_email`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_seller_email` (`seller_email`),
  ADD KEY `idx_rating` (`rating`);

--
-- Indexes for table `rider_notifications`
--
ALTER TABLE `rider_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rider_email` (`rider_email`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_order_id` (`order_id`);

--
-- Indexes for table `seller_rider_messages`
--
ALTER TABLE `seller_rider_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_sender_email` (`sender_email`),
  ADD KEY `idx_receiver_email` (`receiver_email`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_valid_id_path` (`valid_id_path`),
  ADD KEY `idx_business_type` (`business_type`),
  ADD KEY `idx_vehicle_type` (`vehicle_type`),
  ADD KEY `idx_user_type` (`user_type`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `variant_inventory`
--
ALTER TABLE `variant_inventory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_variant` (`product_id`,`color`,`size`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_stock` (`stock_quantity`),
  ADD KEY `idx_color` (`color`),
  ADD KEY `idx_size` (`size`);

--
-- Indexes for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_product` (`user_id`,`product_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `archive`
--
ALTER TABLE `archive`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buyer_notifications`
--
ALTER TABLE `buyer_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `buyer_rider_messages`
--
ALTER TABLE `buyer_rider_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `buyer_seller_messages`
--
ALTER TABLE `buyer_seller_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `checkout`
--
ALTER TABLE `checkout`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=330;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `order_issues`
--
ALTER TABLE `order_issues`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `pending_sellers`
--
ALTER TABLE `pending_sellers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pending_users`
--
ALTER TABLE `pending_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `promotions`
--
ALTER TABLE `promotions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `promotion_categories`
--
ALTER TABLE `promotion_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `promotion_products`
--
ALTER TABLE `promotion_products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `promotion_usage`
--
ALTER TABLE `promotion_usage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `rider_notifications`
--
ALTER TABLE `rider_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `seller_rider_messages`
--
ALTER TABLE `seller_rider_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `variant_inventory`
--
ALTER TABLE `variant_inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=816;

--
-- AUTO_INCREMENT for table `wishlist`
--
ALTER TABLE `wishlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `checkout`
--
ALTER TABLE `checkout`
  ADD CONSTRAINT `checkout_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `conversations_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_issues`
--
ALTER TABLE `order_issues`
  ADD CONSTRAINT `order_issues_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `promotion_categories`
--
ALTER TABLE `promotion_categories`
  ADD CONSTRAINT `promotion_categories_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `promotion_products`
--
ALTER TABLE `promotion_products`
  ADD CONSTRAINT `promotion_products_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `promotion_products_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `promotion_usage`
--
ALTER TABLE `promotion_usage`
  ADD CONSTRAINT `promotion_usage_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `promotion_usage_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `variant_inventory`
--
ALTER TABLE `variant_inventory`
  ADD CONSTRAINT `variant_inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlist`
--
ALTER TABLE `wishlist`
  ADD CONSTRAINT `wishlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
