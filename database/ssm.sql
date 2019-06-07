-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jun 07, 2019 at 10:49 AM
-- Server version: 5.7.24
-- PHP Version: 7.2.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ssm`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `catalog_add_attribute`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_add_attribute` (IN `inName` VARCHAR(100))  BEGIN
  INSERT INTO attribute (name) VALUES (inName);
END$$

DROP PROCEDURE IF EXISTS `catalog_add_attribute_value`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_add_attribute_value` (IN `inAttributeId` INT, IN `inValue` VARCHAR(100))  BEGIN
  INSERT INTO attribute_value (attribute_id, value)
         VALUES (inAttributeId, inValue);
END$$

DROP PROCEDURE IF EXISTS `catalog_add_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_add_category` (IN `inDepartmentId` INT, IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000))  BEGIN
  INSERT INTO category (department_id, name, description)
         VALUES (inDepartmentId, inName, inDescription);
END$$

DROP PROCEDURE IF EXISTS `catalog_add_department`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_add_department` (IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000))  BEGIN
  INSERT INTO department (name, description)
         VALUES (inName, inDescription);
END$$

DROP PROCEDURE IF EXISTS `catalog_add_product_to_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_add_product_to_category` (IN `inCategoryId` INT, IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000), IN `inPrice` DECIMAL(10,2))  BEGIN
  DECLARE productLastInsertId INT;

  INSERT INTO product (name, description, price)
         VALUES (inName, inDescription, inPrice);

  SELECT LAST_INSERT_ID() INTO productLastInsertId;

  INSERT INTO product_category (product_id, category_id)
         VALUES (productLastInsertId, inCategoryId);
END$$

DROP PROCEDURE IF EXISTS `catalog_assign_attribute_value_to_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_assign_attribute_value_to_product` (IN `inProductId` INT, IN `inAttributeValueId` INT)  BEGIN
  INSERT INTO product_attribute (product_id, attribute_value_id)
         VALUES (inProductId, inAttributeValueId);
END$$

DROP PROCEDURE IF EXISTS `catalog_assign_product_to_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_assign_product_to_category` (IN `inProductId` INT, IN `inCategoryId` INT)  BEGIN
  INSERT INTO product_category (product_id, category_id)
         VALUES (inProductId, inCategoryId);
END$$

DROP PROCEDURE IF EXISTS `catalog_count_products_in_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_count_products_in_category` (IN `inCategoryId` INT)  BEGIN
  SELECT     COUNT(*) AS categories_count
  FROM       product p
  INNER JOIN product_category pc
               ON p.product_id = pc.product_id
  WHERE      pc.category_id = inCategoryId;
END$$

DROP PROCEDURE IF EXISTS `catalog_count_products_on_catalog`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_count_products_on_catalog` ()  BEGIN
  SELECT COUNT(*) AS products_on_catalog_count
  FROM   product
  WHERE  display = 1 OR display = 3;
END$$

DROP PROCEDURE IF EXISTS `catalog_count_products_on_department`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_count_products_on_department` (IN `inDepartmentId` INT)  BEGIN
  SELECT DISTINCT COUNT(*) AS products_on_department_count
  FROM            product p
  INNER JOIN      product_category pc
                    ON p.product_id = pc.product_id
  INNER JOIN      category c
                    ON pc.category_id = c.category_id
  WHERE           (p.display = 2 OR p.display = 3)
                  AND c.department_id = inDepartmentId;
END$$

DROP PROCEDURE IF EXISTS `catalog_count_search_result`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_count_search_result` (IN `inSearchString` TEXT, IN `inAllWords` VARCHAR(3))  BEGIN
  IF inAllWords = "on" THEN
    PREPARE statement FROM
      "SELECT   count(*)
       FROM     product
       WHERE    MATCH (name, description) AGAINST (? IN BOOLEAN MODE)";
  ELSE
    PREPARE statement FROM
      "SELECT   count(*)
       FROM     product
       WHERE    MATCH (name, description) AGAINST (?)";
  END IF;

  SET @p1 = inSearchString;

  EXECUTE statement USING @p1;
END$$

DROP PROCEDURE IF EXISTS `catalog_create_product_review`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_create_product_review` (IN `inCustomerId` INT, IN `inProductId` INT, IN `inReview` TEXT, IN `inRating` SMALLINT)  BEGIN
  INSERT INTO review (customer_id, product_id, review, rating, created_on)
         VALUES (inCustomerId, inProductId, inReview, inRating, NOW());
END$$

DROP PROCEDURE IF EXISTS `catalog_delete_attribute`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_delete_attribute` (IN `inAttributeId` INT)  BEGIN
  DECLARE attributeRowsCount INT;

  SELECT count(*)
  FROM   attribute_value
  WHERE  attribute_id = inAttributeId
  INTO   attributeRowsCount;

  IF attributeRowsCount = 0 THEN
    DELETE FROM attribute WHERE attribute_id = inAttributeId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `catalog_delete_attribute_value`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_delete_attribute_value` (IN `inAttributeValueId` INT)  BEGIN
  DECLARE productAttributeRowsCount INT;

  SELECT      count(*)
  FROM        product p
  INNER JOIN  product_attribute pa
                ON p.product_id = pa.product_id
  WHERE       pa.attribute_value_id = inAttributeValueId
  INTO        productAttributeRowsCount;

  IF productAttributeRowsCount = 0 THEN
    DELETE FROM attribute_value WHERE attribute_value_id = inAttributeValueId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `catalog_delete_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_delete_category` (IN `inCategoryId` INT)  BEGIN
  DECLARE productCategoryRowsCount INT;

  SELECT      count(*)
  FROM        product p
  INNER JOIN  product_category pc
                ON p.product_id = pc.product_id
  WHERE       pc.category_id = inCategoryId
  INTO        productCategoryRowsCount;

  IF productCategoryRowsCount = 0 THEN
    DELETE FROM category WHERE category_id = inCategoryId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `catalog_delete_department`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_delete_department` (IN `inDepartmentId` INT)  BEGIN
  DECLARE categoryRowsCount INT;

  SELECT count(*)
  FROM   category
  WHERE  department_id = inDepartmentId
  INTO   categoryRowsCount;
  
  IF categoryRowsCount = 0 THEN
    DELETE FROM department WHERE department_id = inDepartmentId;

    SELECT 1;
  ELSE
    SELECT -1;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `catalog_delete_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_delete_product` (IN `inProductId` INT)  BEGIN
  DELETE FROM product_attribute WHERE product_id = inProductId;
  DELETE FROM product_category WHERE product_id = inProductId;
  DELETE FROM shopping_cart WHERE product_id = inProductId;
  DELETE FROM product WHERE product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_attributes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_attributes` ()  BEGIN
  SELECT attribute_id, name FROM attribute ORDER BY attribute_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_attributes_not_assigned_to_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_attributes_not_assigned_to_product` (IN `inProductId` INT)  BEGIN
  SELECT     a.name AS attribute_name,
             av.attribute_value_id, av.value AS attribute_value
  FROM       attribute_value av
  INNER JOIN attribute a
               ON av.attribute_id = a.attribute_id
  WHERE      av.attribute_value_id NOT IN
             (SELECT attribute_value_id
              FROM   product_attribute
              WHERE  product_id = inProductId)
  ORDER BY   attribute_name, av.attribute_value_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_attribute_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_attribute_details` (IN `inAttributeId` INT)  BEGIN
  SELECT attribute_id, name
  FROM   attribute
  WHERE  attribute_id = inAttributeId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_attribute_values`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_attribute_values` (IN `inAttributeId` INT)  BEGIN
  SELECT   attribute_value_id, value
  FROM     attribute_value
  WHERE    attribute_id = inAttributeId
  ORDER BY attribute_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_categories`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_categories` ()  BEGIN
  SELECT   category_id, name, description
  FROM     category
  ORDER BY category_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_categories_for_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_categories_for_product` (IN `inProductId` INT)  BEGIN
  SELECT   c.category_id, c.department_id, c.name
  FROM     category c
  JOIN     product_category pc
             ON c.category_id = pc.category_id
  WHERE    pc.product_id = inProductId
  ORDER BY category_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_categories_list`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_categories_list` (IN `inDepartmentId` INT)  BEGIN
  SELECT   category_id, name
  FROM     category
  WHERE    department_id = inDepartmentId
  ORDER BY category_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_category_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_category_details` (IN `inCategoryId` INT)  BEGIN
  SELECT name, description
  FROM   category
  WHERE  category_id = inCategoryId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_category_name`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_category_name` (IN `inCategoryId` INT)  BEGIN
  SELECT name FROM category WHERE category_id = inCategoryId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_category_products`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_category_products` (IN `inCategoryId` INT)  BEGIN
  SELECT     p.product_id, p.name, p.description, p.price,
             p.discounted_price
  FROM       product p
  INNER JOIN product_category pc
               ON p.product_id = pc.product_id
  WHERE      pc.category_id = inCategoryId
  ORDER BY   p.product_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_departments`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_departments` ()  BEGIN
  SELECT   department_id, name, description
  FROM     department
  ORDER BY department_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_departments_list`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_departments_list` ()  BEGIN
  SELECT department_id, name FROM department ORDER BY department_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_department_categories`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_department_categories` (IN `inDepartmentId` INT)  BEGIN
  SELECT   category_id, name, description
  FROM     category
  WHERE    department_id = inDepartmentId
  ORDER BY category_id;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_department_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_department_details` (IN `inDepartmentId` INT)  BEGIN
  SELECT name, description
  FROM   department
  WHERE  department_id = inDepartmentId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_department_name`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_department_name` (IN `inDepartmentId` INT)  BEGIN
  SELECT name FROM department WHERE department_id = inDepartmentId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_products_in_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_products_in_category` (IN `inCategoryId` INT, IN `inShortProductDescriptionLength` INT, IN `inProductsPerPage` INT, IN `inStartItem` INT)  BEGIN
  -- Prepare statement
  PREPARE statement FROM
   "SELECT     p.product_id, p.name,
               IF(LENGTH(p.description) <= ?,
                  p.description,
                  CONCAT(LEFT(p.description, ?),
                         '...')) AS description,
               p.price, p.discounted_price, p.thumbnail
    FROM       product p
    INNER JOIN product_category pc
                 ON p.product_id = pc.product_id
    WHERE      pc.category_id = ?
    ORDER BY   p.display DESC
    LIMIT      ?, ?";

  -- Define query parameters
  SET @p1 = inShortProductDescriptionLength; 
  SET @p2 = inShortProductDescriptionLength; 
  SET @p3 = inCategoryId;
  SET @p4 = inStartItem; 
  SET @p5 = inProductsPerPage; 

  -- Execute the statement
  EXECUTE statement USING @p1, @p2, @p3, @p4, @p5;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_products_on_catalog`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_products_on_catalog` (IN `inShortProductDescriptionLength` INT, IN `inProductsPerPage` INT, IN `inStartItem` INT)  BEGIN
  PREPARE statement FROM
    "SELECT   product_id, name,
              IF(LENGTH(description) <= ?,
                 description,
                 CONCAT(LEFT(description, ?),
                        '...')) AS description,
              price, discounted_price, thumbnail
     FROM     product
     WHERE    display = 1 OR display = 3
     ORDER BY display DESC
     LIMIT    ?, ?";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inShortProductDescriptionLength;
  SET @p3 = inStartItem;
  SET @p4 = inProductsPerPage;

  EXECUTE statement USING @p1, @p2, @p3, @p4;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_products_on_department`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_products_on_department` (IN `inDepartmentId` INT, IN `inShortProductDescriptionLength` INT, IN `inProductsPerPage` INT, IN `inStartItem` INT)  BEGIN
  PREPARE statement FROM
    "SELECT DISTINCT p.product_id, p.name,
                     IF(LENGTH(p.description) <= ?,
                        p.description,
                        CONCAT(LEFT(p.description, ?),
                               '...')) AS description,
                     p.price, p.discounted_price, p.thumbnail
     FROM            product p
     INNER JOIN      product_category pc
                       ON p.product_id = pc.product_id
     INNER JOIN      category c
                       ON pc.category_id = c.category_id
     WHERE           (p.display = 2 OR p.display = 3)
                     AND c.department_id = ?
     ORDER BY        p.display DESC
     LIMIT           ?, ?";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inShortProductDescriptionLength;
  SET @p3 = inDepartmentId;
  SET @p4 = inStartItem;
  SET @p5 = inProductsPerPage;

  EXECUTE statement USING @p1, @p2, @p3, @p4, @p5;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_attributes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_attributes` (IN `inProductId` INT)  BEGIN
  SELECT     a.name AS attribute_name,
             av.attribute_value_id, av.value AS attribute_value
  FROM       attribute_value av
  INNER JOIN attribute a
               ON av.attribute_id = a.attribute_id
  WHERE      av.attribute_value_id IN
               (SELECT attribute_value_id
                FROM   product_attribute
                WHERE  product_id = inProductId)
  ORDER BY   a.name;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_details` (IN `inProductId` INT)  BEGIN
  SELECT product_id, name, description,
         price, discounted_price, image, image_2
  FROM   product
  WHERE  product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_info`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_info` (IN `inProductId` INT)  BEGIN
  SELECT product_id, name, description, price, discounted_price,
         image, image_2, thumbnail, display
  FROM   product
  WHERE  product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_locations`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_locations` (IN `inProductId` INT)  BEGIN
  SELECT c.category_id, c.name AS category_name, c.department_id,
         (SELECT name
          FROM   department
          WHERE  department_id = c.department_id) AS department_name
          -- Subquery returns the name of the department of the category
  FROM   category c
  WHERE  c.category_id IN
           (SELECT category_id
            FROM   product_category
            WHERE  product_id = inProductId);
            -- Subquery returns the category IDs a product belongs to
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_name`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_name` (IN `inProductId` INT)  BEGIN
  SELECT name FROM product WHERE product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_product_reviews`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_product_reviews` (IN `inProductId` INT)  BEGIN
  SELECT     c.name, r.review, r.rating, r.created_on
  FROM       review r
  INNER JOIN customer c
               ON c.customer_id = r.customer_id
  WHERE      r.product_id = inProductId
  ORDER BY   r.created_on DESC;
END$$

DROP PROCEDURE IF EXISTS `catalog_get_recommendations`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_get_recommendations` (IN `inProductId` INT, IN `inShortProductDescriptionLength` INT)  BEGIN
  PREPARE statement FROM
    "SELECT   od2.product_id, od2.product_name,
              IF(LENGTH(p.description) <= ?, p.description,
                 CONCAT(LEFT(p.description, ?), '...')) AS description
     FROM     order_detail od1
     JOIN     order_detail od2 ON od1.order_id = od2.order_id
     JOIN     product p ON od2.product_id = p.product_id
     WHERE    od1.product_id = ? AND
              od2.product_id != ?
     GROUP BY od2.product_id
     ORDER BY COUNT(od2.product_id) DESC
     LIMIT 5";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inProductId;

  EXECUTE statement USING @p1, @p1, @p2, @p2;
END$$

DROP PROCEDURE IF EXISTS `catalog_move_product_to_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_move_product_to_category` (IN `inProductId` INT, IN `inSourceCategoryId` INT, IN `inTargetCategoryId` INT)  BEGIN
  UPDATE product_category
  SET    category_id = inTargetCategoryId
  WHERE  product_id = inProductId
         AND category_id = inSourceCategoryId;
END$$

DROP PROCEDURE IF EXISTS `catalog_remove_product_attribute_value`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_remove_product_attribute_value` (IN `inProductId` INT, IN `inAttributeValueId` INT)  BEGIN
  DELETE FROM product_attribute
  WHERE       product_id = inProductId AND
              attribute_value_id = inAttributeValueId;
END$$

DROP PROCEDURE IF EXISTS `catalog_remove_product_from_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_remove_product_from_category` (IN `inProductId` INT, IN `inCategoryId` INT)  BEGIN
  DECLARE productCategoryRowsCount INT;

  SELECT count(*)
  FROM   product_category
  WHERE  product_id = inProductId
  INTO   productCategoryRowsCount;

  IF productCategoryRowsCount = 1 THEN
    CALL catalog_delete_product(inProductId);

    SELECT 0;
  ELSE
    DELETE FROM product_category
    WHERE  category_id = inCategoryId AND product_id = inProductId;

    SELECT 1;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `catalog_search`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_search` (IN `inSearchString` TEXT, IN `inAllWords` VARCHAR(3), IN `inShortProductDescriptionLength` INT, IN `inProductsPerPage` INT, IN `inStartItem` INT)  BEGIN
  IF inAllWords = "on" THEN
    PREPARE statement FROM
      "SELECT   product_id, name,
                IF(LENGTH(description) <= ?,
                   description,
                   CONCAT(LEFT(description, ?),
                          '...')) AS description,
                price, discounted_price, thumbnail
       FROM     product
       WHERE    MATCH (name, description)
                AGAINST (? IN BOOLEAN MODE)
       ORDER BY MATCH (name, description)
                AGAINST (? IN BOOLEAN MODE) DESC
       LIMIT    ?, ?";
  ELSE
    PREPARE statement FROM
      "SELECT   product_id, name,
                IF(LENGTH(description) <= ?,
                   description,
                   CONCAT(LEFT(description, ?),
                          '...')) AS description,
                price, discounted_price, thumbnail
       FROM     product
       WHERE    MATCH (name, description) AGAINST (?)
       ORDER BY MATCH (name, description) AGAINST (?) DESC
       LIMIT    ?, ?";
  END IF;

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inSearchString;
  SET @p3 = inStartItem;
  SET @p4 = inProductsPerPage;

  EXECUTE statement USING @p1, @p1, @p2, @p2, @p3, @p4;
END$$

DROP PROCEDURE IF EXISTS `catalog_set_image`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_set_image` (IN `inProductId` INT, IN `inImage` VARCHAR(150))  BEGIN
  UPDATE product SET image = inImage WHERE product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_set_image_2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_set_image_2` (IN `inProductId` INT, IN `inImage` VARCHAR(150))  BEGIN
  UPDATE product SET image_2 = inImage WHERE product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_set_product_display_option`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_set_product_display_option` (IN `inProductId` INT, IN `inDisplay` SMALLINT)  BEGIN
  UPDATE product SET display = inDisplay WHERE product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_set_thumbnail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_set_thumbnail` (IN `inProductId` INT, IN `inThumbnail` VARCHAR(150))  BEGIN
  UPDATE product
  SET    thumbnail = inThumbnail
  WHERE  product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `catalog_update_attribute`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_update_attribute` (IN `inAttributeId` INT, IN `inName` VARCHAR(100))  BEGIN
  UPDATE attribute SET name = inName WHERE attribute_id = inAttributeId;
END$$

DROP PROCEDURE IF EXISTS `catalog_update_attribute_value`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_update_attribute_value` (IN `inAttributeValueId` INT, IN `inValue` VARCHAR(100))  BEGIN
    UPDATE attribute_value
    SET    value = inValue
    WHERE  attribute_value_id = inAttributeValueId;
END$$

DROP PROCEDURE IF EXISTS `catalog_update_category`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_update_category` (IN `inCategoryId` INT, IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000))  BEGIN
    UPDATE category
    SET    name = inName, description = inDescription
    WHERE  category_id = inCategoryId;
END$$

DROP PROCEDURE IF EXISTS `catalog_update_department`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_update_department` (IN `inDepartmentId` INT, IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000))  BEGIN
  UPDATE department
  SET    name = inName, description = inDescription
  WHERE  department_id = inDepartmentId;
END$$

DROP PROCEDURE IF EXISTS `catalog_update_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `catalog_update_product` (IN `inProductId` INT, IN `inName` VARCHAR(100), IN `inDescription` VARCHAR(1000), IN `inPrice` DECIMAL(10,2), IN `inDiscountedPrice` DECIMAL(10,2))  BEGIN
  UPDATE product
  SET    name = inName, description = inDescription, price = inPrice,
         discounted_price = inDiscountedPrice
  WHERE  product_id = inProductId;
END$$

DROP PROCEDURE IF EXISTS `customer_add`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_add` (IN `inName` VARCHAR(50), IN `inEmail` VARCHAR(100), IN `inPassword` VARCHAR(50))  BEGIN
  INSERT INTO customer (name, email, password)
         VALUES (inName, inEmail, inPassword);

  SELECT LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `customer_get_customer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_get_customer` (IN `inCustomerId` INT)  BEGIN
  SELECT customer_id, name, email, password, credit_card,
         address_1, address_2, city, region, postal_code, country,
         shipping_region_id, day_phone, eve_phone, mob_phone
  FROM   customer
  WHERE  customer_id = inCustomerId;
END$$

DROP PROCEDURE IF EXISTS `customer_get_customers_list`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_get_customers_list` ()  BEGIN
  SELECT customer_id, name FROM customer ORDER BY name ASC;
END$$

DROP PROCEDURE IF EXISTS `customer_get_login_info`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_get_login_info` (IN `inEmail` VARCHAR(100))  BEGIN
  SELECT customer_id, password FROM customer WHERE email = inEmail;
END$$

DROP PROCEDURE IF EXISTS `customer_get_shipping_regions`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_get_shipping_regions` ()  BEGIN
  SELECT shipping_region_id, shipping_region FROM shipping_region;
END$$

DROP PROCEDURE IF EXISTS `customer_update_account`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_update_account` (IN `inCustomerId` INT, IN `inName` VARCHAR(50), IN `inEmail` VARCHAR(100), IN `inPassword` VARCHAR(50), IN `inDayPhone` VARCHAR(100), IN `inEvePhone` VARCHAR(100), IN `inMobPhone` VARCHAR(100))  BEGIN
  UPDATE customer
  SET    name = inName, email = inEmail,
         password = inPassword, day_phone = inDayPhone,
         eve_phone = inEvePhone, mob_phone = inMobPhone
  WHERE  customer_id = inCustomerId;
END$$

DROP PROCEDURE IF EXISTS `customer_update_address`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_update_address` (IN `inCustomerId` INT, IN `inAddress1` VARCHAR(100), IN `inAddress2` VARCHAR(100), IN `inCity` VARCHAR(100), IN `inRegion` VARCHAR(100), IN `inPostalCode` VARCHAR(100), IN `inCountry` VARCHAR(100), IN `inShippingRegionId` INT)  BEGIN
  UPDATE customer
  SET    address_1 = inAddress1, address_2 = inAddress2, city = inCity,
         region = inRegion, postal_code = inPostalCode,
         country = inCountry, shipping_region_id = inShippingRegionId
  WHERE  customer_id = inCustomerId;
END$$

DROP PROCEDURE IF EXISTS `customer_update_credit_card`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `customer_update_credit_card` (IN `inCustomerId` INT, IN `inCreditCard` TEXT)  BEGIN
  UPDATE customer
  SET    credit_card = inCreditCard
  WHERE  customer_id = inCustomerId;
END$$

DROP PROCEDURE IF EXISTS `orders_create_audit`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_create_audit` (IN `inOrderId` INT, IN `inMessage` TEXT, IN `inCode` INT)  BEGIN
  INSERT INTO audit (order_id, created_on, message, code)
         VALUES (inOrderId, NOW(), inMessage, inCode);
END$$

DROP PROCEDURE IF EXISTS `orders_get_audit_trail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_audit_trail` (IN `inOrderId` INT)  BEGIN
  SELECT audit_id, order_id, created_on, message, code
  FROM   audit
  WHERE  order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_get_by_customer_id`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_by_customer_id` (IN `inCustomerId` INT)  BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.customer_id = inCustomerId
  ORDER BY   o.created_on DESC;
END$$

DROP PROCEDURE IF EXISTS `orders_get_most_recent_orders`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_most_recent_orders` (IN `inHowMany` INT)  BEGIN
  PREPARE statement FROM
    "SELECT     o.order_id, o.total_amount, o.created_on,
                o.shipped_on, o.status, c.name
     FROM       orders o
     INNER JOIN customer c
                  ON o.customer_id = c.customer_id
     ORDER BY   o.created_on DESC
     LIMIT      ?";

  SET @p1 = inHowMany;

  EXECUTE statement USING @p1;
END$$

DROP PROCEDURE IF EXISTS `orders_get_orders_between_dates`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_orders_between_dates` (IN `inStartDate` DATETIME, IN `inEndDate` DATETIME)  BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.created_on >= inStartDate AND o.created_on <= inEndDate
  ORDER BY   o.created_on DESC;
END$$

DROP PROCEDURE IF EXISTS `orders_get_orders_by_status`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_orders_by_status` (IN `inStatus` INT)  BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on,
             o.shipped_on, o.status, c.name
  FROM       orders o
  INNER JOIN customer c
               ON o.customer_id = c.customer_id
  WHERE      o.status = inStatus
  ORDER BY   o.created_on DESC;
END$$

DROP PROCEDURE IF EXISTS `orders_get_order_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_order_details` (IN `inOrderId` INT)  BEGIN
  SELECT order_id, product_id, attributes, product_name,
         quantity, unit_cost, (quantity * unit_cost) AS subtotal
  FROM   order_detail
  WHERE  order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_get_order_info`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_order_info` (IN `inOrderId` INT)  BEGIN
  SELECT     o.order_id, o.total_amount, o.created_on, o.shipped_on,
             o.status, o.comments, o.customer_id, o.auth_code,
             o.reference, o.shipping_id, s.shipping_type, s.shipping_cost,
             o.tax_id, t.tax_type, t.tax_percentage
  FROM       orders o
  INNER JOIN tax t
               ON t.tax_id = o.tax_id
  INNER JOIN shipping s
               ON s.shipping_id = o.shipping_id
  WHERE      o.order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_get_order_short_details`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_order_short_details` (IN `inOrderId` INT)  BEGIN
  SELECT      o.order_id, o.total_amount, o.created_on,
              o.shipped_on, o.status, c.name
  FROM        orders o
  INNER JOIN  customer c
                ON o.customer_id = c.customer_id
  WHERE       o.order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_get_shipping_info`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_get_shipping_info` (IN `inShippingRegionId` INT)  BEGIN
  SELECT shipping_id, shipping_type, shipping_cost, shipping_region_id
  FROM   shipping
  WHERE  shipping_region_id = inShippingRegionId;
END$$

DROP PROCEDURE IF EXISTS `orders_set_auth_code`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_set_auth_code` (IN `inOrderId` INT, IN `inAuthCode` VARCHAR(50), IN `inReference` VARCHAR(50))  BEGIN
  UPDATE orders
  SET    auth_code = inAuthCode, reference = inReference
  WHERE  order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_set_date_shipped`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_set_date_shipped` (IN `inOrderId` INT)  BEGIN
  UPDATE orders SET shipped_on = NOW() WHERE order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `orders_update_order`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_update_order` (IN `inOrderId` INT, IN `inStatus` INT, IN `inComments` VARCHAR(255), IN `inAuthCode` VARCHAR(50), IN `inReference` VARCHAR(50))  BEGIN
  DECLARE currentDateShipped DATETIME;

  SELECT shipped_on
  FROM   orders
  WHERE  order_id = inOrderId
  INTO   currentDateShipped;

  UPDATE orders
  SET    status = inStatus, comments = inComments,
         auth_code = inAuthCode, reference = inReference
  WHERE  order_id = inOrderId;

  IF inStatus < 7 AND currentDateShipped IS NOT NULL THEN
    UPDATE orders SET shipped_on = NULL WHERE order_id = inOrderId;
  ELSEIF inStatus > 6 AND currentDateShipped IS NULL THEN
    UPDATE orders SET shipped_on = NOW() WHERE order_id = inOrderId;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `orders_update_status`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `orders_update_status` (IN `inOrderId` INT, IN `inStatus` INT)  BEGIN
  UPDATE orders SET status = inStatus WHERE order_id = inOrderId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_add_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_add_product` (IN `inCartId` CHAR(32), IN `inProductId` INT, IN `inAttributes` VARCHAR(1000))  BEGIN
  DECLARE productQuantity INT;

  -- Obtain current shopping cart quantity for the product
  SELECT quantity
  FROM   shopping_cart
  WHERE  cart_id = inCartId
         AND product_id = inProductId
         AND attributes = inAttributes
  INTO   productQuantity;

  -- Create new shopping cart record, or increase quantity of existing record
  IF productQuantity IS NULL THEN
    INSERT INTO shopping_cart(item_id, cart_id, product_id, attributes,
                              quantity, added_on)
           VALUES (UUID(), inCartId, inProductId, inAttributes, 1, NOW());
  ELSE
    UPDATE shopping_cart
    SET    quantity = quantity + 1, buy_now = true
    WHERE  cart_id = inCartId
           AND product_id = inProductId
           AND attributes = inAttributes;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_count_old_carts`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_count_old_carts` (IN `inDays` INT)  BEGIN
  SELECT COUNT(cart_id) AS old_shopping_carts_count
  FROM   (SELECT   cart_id
          FROM     shopping_cart
          GROUP BY cart_id
          HAVING   DATE_SUB(NOW(), INTERVAL inDays DAY) >= MAX(added_on))
         AS old_carts;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_create_order`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_create_order` (IN `inCartId` CHAR(32), IN `inCustomerId` INT, IN `inShippingId` INT, IN `inTaxId` INT)  BEGIN
  DECLARE orderId INT;

  -- Insert a new record into orders and obtain the new order ID
  INSERT INTO orders (created_on, customer_id, shipping_id, tax_id) VALUES
         (NOW(), inCustomerId, inShippingId, inTaxId);
  -- Obtain the new Order ID
  SELECT LAST_INSERT_ID() INTO orderId;

  -- Insert order details in order_detail table
  INSERT INTO order_detail (order_id, product_id, attributes,
                            product_name, quantity, unit_cost)
  SELECT      orderId, p.product_id, sc.attributes, p.name, sc.quantity,
              COALESCE(NULLIF(p.discounted_price, 0), p.price) AS unit_cost
  FROM        shopping_cart sc
  INNER JOIN  product p
                ON sc.product_id = p.product_id
  WHERE       sc.cart_id = inCartId AND sc.buy_now;

  -- Save the order's total amount
  UPDATE orders
  SET    total_amount = (SELECT SUM(unit_cost * quantity) 
                         FROM   order_detail
                         WHERE  order_id = orderId)
  WHERE  order_id = orderId;

  -- Clear the shopping cart
  CALL shopping_cart_empty(inCartId);

  -- Return the Order ID
  SELECT orderId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_delete_old_carts`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_delete_old_carts` (IN `inDays` INT)  BEGIN
  DELETE FROM shopping_cart
  WHERE  cart_id IN
          (SELECT cart_id
           FROM   (SELECT   cart_id
                   FROM     shopping_cart
                   GROUP BY cart_id
                   HAVING   DATE_SUB(NOW(), INTERVAL inDays DAY) >=
                            MAX(added_on))
                  AS sc);
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_empty`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_empty` (IN `inCartId` CHAR(32))  BEGIN
  DELETE FROM shopping_cart WHERE cart_id = inCartId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_get_products`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_get_products` (IN `inCartId` CHAR(32))  BEGIN
  SELECT     sc.item_id, p.name, sc.attributes,
             COALESCE(NULLIF(p.discounted_price, 0), p.price) AS price,
             sc.quantity,
             COALESCE(NULLIF(p.discounted_price, 0),
                      p.price) * sc.quantity AS subtotal
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND sc.buy_now;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_get_recommendations`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_get_recommendations` (IN `inCartId` CHAR(32), IN `inShortProductDescriptionLength` INT)  BEGIN
  PREPARE statement FROM
    "-- Returns the products that exist in a list of orders
     SELECT   od1.product_id, od1.product_name,
              IF(LENGTH(p.description) <= ?, p.description,
                 CONCAT(LEFT(p.description, ?), '...')) AS description
     FROM     order_detail od1
     JOIN     order_detail od2
                ON od1.order_id = od2.order_id
     JOIN     product p
                ON od1.product_id = p.product_id
     JOIN     shopping_cart
                ON od2.product_id = shopping_cart.product_id
     WHERE    shopping_cart.cart_id = ?
              -- Must not include products that already exist
              -- in the visitor's cart
              AND od1.product_id NOT IN
              (-- Returns the products in the specified
               -- shopping cart
               SELECT product_id
               FROM   shopping_cart
               WHERE  cart_id = ?)
     -- Group the product_id so we can calculate the rank
     GROUP BY od1.product_id
     -- Order descending by rank
     ORDER BY COUNT(od1.product_id) DESC
     LIMIT    5";

  SET @p1 = inShortProductDescriptionLength;
  SET @p2 = inCartId;

  EXECUTE statement USING @p1, @p1, @p2, @p2;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_get_saved_products`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_get_saved_products` (IN `inCartId` CHAR(32))  BEGIN
  SELECT     sc.item_id, p.name, sc.attributes,
             COALESCE(NULLIF(p.discounted_price, 0), p.price) AS price
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND NOT sc.buy_now;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_get_total_amount`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_get_total_amount` (IN `inCartId` CHAR(32))  BEGIN
  SELECT     SUM(COALESCE(NULLIF(p.discounted_price, 0), p.price)
                 * sc.quantity) AS total_amount
  FROM       shopping_cart sc
  INNER JOIN product p
               ON sc.product_id = p.product_id
  WHERE      sc.cart_id = inCartId AND sc.buy_now;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_move_product_to_cart`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_move_product_to_cart` (IN `inItemId` INT)  BEGIN
  UPDATE shopping_cart
  SET    buy_now = true, added_on = NOW()
  WHERE  item_id = inItemId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_remove_product`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_remove_product` (IN `inItemId` INT)  BEGIN
  DELETE FROM shopping_cart WHERE item_id = inItemId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_save_product_for_later`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_save_product_for_later` (IN `inItemId` INT)  BEGIN
  UPDATE shopping_cart
  SET    buy_now = false, quantity = 1
  WHERE  item_id = inItemId;
END$$

DROP PROCEDURE IF EXISTS `shopping_cart_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopping_cart_update` (IN `inItemId` INT, IN `inQuantity` INT)  BEGIN
  IF inQuantity > 0 THEN
    UPDATE shopping_cart
    SET    quantity = inQuantity, added_on = NOW()
    WHERE  item_id = inItemId;
  ELSE
    CALL shopping_cart_remove_product(inItemId);
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `attribute`
--

DROP TABLE IF EXISTS `attribute`;
CREATE TABLE IF NOT EXISTS `attribute` (
  `attribute_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`attribute_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `attribute`
--

INSERT INTO `attribute` (`attribute_id`, `name`) VALUES
(1, 'Size'),
(2, 'Color'),
(3, 'Brand'),
(5, 'Fabric');

-- --------------------------------------------------------

--
-- Table structure for table `attribute_value`
--

DROP TABLE IF EXISTS `attribute_value`;
CREATE TABLE IF NOT EXISTS `attribute_value` (
  `attribute_value_id` int(11) NOT NULL AUTO_INCREMENT,
  `attribute_id` int(11) NOT NULL,
  `value` varchar(100) NOT NULL,
  PRIMARY KEY (`attribute_value_id`),
  KEY `idx_attribute_value_attribute_id` (`attribute_id`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `attribute_value`
--

INSERT INTO `attribute_value` (`attribute_value_id`, `attribute_id`, `value`) VALUES
(1, 1, 'S'),
(2, 1, 'M'),
(3, 1, 'L'),
(4, 1, 'XL'),
(5, 1, 'XXL'),
(6, 2, 'White'),
(7, 2, 'Black'),
(8, 2, 'Red'),
(9, 2, 'Orange'),
(10, 2, 'Yellow'),
(11, 2, 'Green'),
(12, 2, 'Blue'),
(13, 2, 'Indigo'),
(14, 2, 'Purple'),
(15, 3, 'PUMA'),
(16, 3, 'Roadster'),
(17, 3, 'United Colors of Benetton'),
(18, 3, 'WRONG'),
(19, 3, 'Moda Rapido'),
(20, 3, 'Jack & Jones'),
(21, 3, 'American Swan'),
(22, 3, 'ADIDAS'),
(23, 3, 'ROADSTER'),
(24, 3, 'Allen Solly Junior'),
(25, 3, 'Alamod'),
(26, 3, 'BlackSmith'),
(27, 1, '40'),
(28, 1, 'x');

-- --------------------------------------------------------

--
-- Table structure for table `audit`
--

DROP TABLE IF EXISTS `audit`;
CREATE TABLE IF NOT EXISTS `audit` (
  `audit_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `created_on` datetime NOT NULL,
  `message` text NOT NULL,
  `code` int(11) NOT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `department_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `isDelete` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`category_id`),
  KEY `idx_category_department_id` (`department_id`)
) ENGINE=MyISAM AUTO_INCREMENT=61 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`category_id`, `department_id`, `name`, `description`, `active`, `isDelete`) VALUES
(1, 1, 'French', 'The French have always had an eye for beauty. One look at the T-shirts below and you\'ll see that same appreciation has been applied abundantly to their postage stamps. Below are some of our most beautiful and colorful T-shirts, so browse away! And don\'t forget to go all the way to the bottom - you don\'t want to miss any of them!', 1, 0),
(2, 1, 'Italian', 'The full and resplendent treasure chest of art, literature, music, and science that Italy has given the world is reflected splendidly in its postal stamps. If we could, we would dedicate hundreds of T-shirts to this amazing treasure of beautiful images, but for now we will have to live with what you see here. You don\'t have to be Italian to love these gorgeous T-shirts, just someone who appreciates the finer things in life!', 1, 0),
(3, 1, 'Irish', 'It was Churchill who remarked that he thought the Irish most curious because they didn\'t want to be English. How right he was! But then, he was half-American, wasn\'t he? If you have an Irish genealogy you will want these T-shirts! If you suddenly turn Irish on St. Patrick\'s Day, you too will want these T-shirts! Take a look at some of the coolest T-shirts we have!', 1, 0),
(4, 2, 'Animal', ' Our ever-growing selection of beautiful animal T-shirts represents critters from everywhere, both wild and domestic. If you don\'t see the T-shirt with the animal you\'re looking for, tell us and we\'ll find it!', 1, 0),
(5, 2, 'Flower', 'These unique and beautiful flower T-shirts are just the item for the gardener, flower arranger, florist, or general lover of things beautiful. Surprise the flower in your life with one of the beautiful botanical T-shirts or just get a few for yourself!', 1, 0),
(6, 3, 'Christmas', ' Because this is a unique Christmas T-shirt that you\'ll only wear a few times a year, it will probably last for decades (unless some grinch nabs it from you, of course). Far into the future, after you\'re gone, your grandkids will pull it out and argue over who gets to wear it. What great snapshots they\'ll make dressed in Grandpa or Grandma\'s incredibly tasteful and unique Christmas T-shirt! Yes, everyone will remember you forever and what a silly goof you were when you would wear only your Santa beard and cap so you wouldn\'t cover up your nifty T-shirt.', 1, 0),
(7, 3, 'Valentine\'s', 'For the more timid, all you have to do is wear your heartfelt message to get it across. Buy one for you and your sweetie(s) today!', 1, 0),
(8, 1, 'Casual Shirts', 'It was Churchill who remarked that he thought the Irish most curious because they didn\'t want to be English. How right he was! But then, he was half-American, wasn\'t he? If you have an Irish genealogy you will want these T-shirts! If you suddenly turn Irish on St. Patrick\'s Day, you too will want these T-shirts! Take a look at some of the coolest T-shirts we have!', 1, 0),
(9, 1, 'Formal Shirts', NULL, 1, 0),
(10, 1, 'Sweatshirts', NULL, 1, 0),
(11, 1, 'Sweaters', NULL, 1, 0),
(12, 1, 'Jackets', NULL, 1, 0),
(13, 1, 'Blazers & Coats', NULL, 1, 0),
(14, 1, 'Suits', NULL, 1, 0),
(15, 1, 'Nehru Jackets', NULL, 1, 0),
(16, 1, 'Sherwanis', NULL, 1, 0),
(17, 1, 'Indian & Festive Wear', NULL, 1, 0),
(18, 1, 'Dhotis', NULL, 1, 0),
(19, 1, 'Nehru Jackets', NULL, 1, 0),
(21, 1, 'Jeans', NULL, 1, 0),
(22, 1, 'Shorts', NULL, 1, 0),
(23, 1, 'Casual Trousers', NULL, 1, 0),
(24, 1, 'Formal Trousers', NULL, 1, 0),
(25, 1, 'Track Pants & Joggers', NULL, 1, 0),
(26, 2, 'Boxers', NULL, 1, 0),
(27, 2, 'Briefs & Trunks', NULL, 1, 0),
(28, 2, 'Vests', NULL, 1, 0),
(29, 2, 'Sleepwear & Loungewear', NULL, 1, 0),
(30, 2, 'Thermals', NULL, 1, 0),
(31, 2, 'Plus Size', NULL, 1, 0),
(32, 2, 'Footwear', NULL, 1, 0),
(33, 2, 'Casual Shoes', NULL, 1, 0),
(34, 2, 'Sports Shoes', NULL, 1, 0),
(35, 2, 'Formal Shoes', NULL, 1, 0),
(36, 2, 'Sneakers', NULL, 1, 0),
(37, 2, 'Sandals & Floaters', NULL, 1, 0),
(38, 2, 'Flip Flops', NULL, 1, 0),
(39, 2, 'Socks', NULL, 1, 0),
(40, 3, 'Sports Shoes', NULL, 1, 0),
(41, 3, 'Sports Sandals', NULL, 1, 0),
(42, 3, 'Active T-Shirts', NULL, 1, 0),
(43, 3, 'Track Pants & Shorts', NULL, 1, 0),
(44, 3, 'Tracksuits', NULL, 1, 0),
(45, 3, 'Jackets & Sweatshirts', NULL, 1, 0),
(46, 3, 'Swimwear', NULL, 1, 0),
(47, 3, 'Gadgets', NULL, 1, 0),
(48, 3, 'Smart Wearables', NULL, 1, 0),
(49, 3, 'Fitness Gadgets', NULL, 1, 0),
(50, 3, 'Headphones', NULL, 1, 0),
(51, 3, 'Speakers', NULL, 1, 0),
(52, 3, 'Fashion Accessories', NULL, 1, 0),
(53, 3, 'Wallets', NULL, 1, 0),
(54, 3, 'Belts', NULL, 1, 0),
(55, 3, 'Perfumes & Body Mists', NULL, 1, 0),
(56, 3, 'Trimmers', NULL, 1, 0),
(57, 3, 'Deodorants', NULL, 1, 0),
(58, 3, 'Ties, Cufflinks & Pocket Squares', NULL, 1, 0),
(59, 3, 'Swimming Costumes', 'It was Churchill who remarked that he thought the Irish most curious because they didn\'t want to be English. How right he was! But then, he was half-American, wasn\'t he? If you have an Irish genealogy you will want these T-shirts! If you suddenly turn Irish on St. Patrick\'s Day, you too will want these T-shirts! Take a look at some of the coolest T-shirts we have!', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE IF NOT EXISTS `customer` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(230) NOT NULL,
  `credit_card` text,
  `address_1` varchar(100) DEFAULT NULL,
  `address_2` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `postal_code` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `shipping_region_id` int(11) NOT NULL DEFAULT '1',
  `day_phone` varchar(100) DEFAULT NULL,
  `eve_phone` varchar(100) DEFAULT NULL,
  `mob_phone` varchar(100) DEFAULT NULL,
  `cart_id` int(11) NOT NULL,
  `reset_otp` int(11) DEFAULT NULL,
  `expiry_time` datetime DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `idx_customer_email` (`email`),
  KEY `idx_customer_shipping_region_id` (`shipping_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `name`, `email`, `password`, `credit_card`, `address_1`, `address_2`, `city`, `region`, `postal_code`, `country`, `shipping_region_id`, `day_phone`, `eve_phone`, `mob_phone`, `cart_id`, `reset_otp`, `expiry_time`) VALUES
(29, 'pm', 'pmd@gmail.com', '$2b$10$u6PR4hNutVdHA03hYVfeYul1ficfsMQe.wLMkf74LwgN8TPPQUlrW', NULL, 'A-95, Tulsidarshan', '', 'Surat', 'Gujarat', '395010', 'Europe', 2, NULL, NULL, '9852525252', 29, NULL, NULL),
(32, 'Kamlesh', 'kamlesh.gorasiya@gmail.com', '$2b$10$aJZa0RPUTj1ahgtBNApVXugrB2OP87MzoApytTY3FtyCe0ts9COZm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, '9737156062', 32, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
CREATE TABLE IF NOT EXISTS `department` (
  `department_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`department_id`, `name`, `description`) VALUES
(1, 'Regional', 'Proud of your country? Wear a T-shirt with a national symbol stamp!'),
(2, 'Nature', 'Find beautiful T-shirts with animals and flowers in our Nature department!'),
(3, 'Seasonal', 'Each time of the year has a special flavor. Our seasonal T-shirts express traditional symbols using unique postal stamp pictures.');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_on` datetime NOT NULL,
  `shipped_on` datetime DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `auth_code` varchar(50) DEFAULT NULL,
  `reference` varchar(50) DEFAULT NULL,
  `shipping_id` int(11) DEFAULT NULL,
  `tax_id` int(11) DEFAULT NULL,
  `stripe_token` text NOT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer_id` (`customer_id`),
  KEY `idx_orders_shipping_id` (`shipping_id`),
  KEY `idx_orders_tax_id` (`tax_id`)
) ENGINE=MyISAM AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `total_amount`, `created_on`, `shipped_on`, `comments`, `customer_id`, `auth_code`, `reference`, `shipping_id`, `tax_id`, `stripe_token`) VALUES
(55, '49.98', '2019-06-04 12:35:19', '2019-06-05 12:35:19', NULL, 29, 'tok_1EhbrEIUUYkoWtDsg7FMNZVw', NULL, 1, NULL, ''),
(54, '51.94', '2019-06-04 10:33:08', '2019-06-05 10:33:08', NULL, 29, 'tok_1EhZx0IUUYkoWtDsafTe1uRQ', NULL, 1, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `order_detail`
--

DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE IF NOT EXISTS `order_detail` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `product_variant_id` int(11) NOT NULL,
  `attributes` varchar(1000) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_cost` decimal(10,2) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `cancel_bit` tinyint(1) NOT NULL,
  `status_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_order_detail_order_id` (`order_id`)
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `order_detail`
--

INSERT INTO `order_detail` (`item_id`, `order_id`, `product_variant_id`, `attributes`, `product_name`, `quantity`, `unit_cost`, `customer_id`, `cancel_bit`, `status_id`, `user_id`) VALUES
(49, 54, 203, '{\"Size\":\"XXL\",\"Color\":\"Yellow\"}', '', 1, '14.99', 29, 0, 3, 1),
(50, 55, 123, '{\"Size\":\"XXL\",\"Color\":\"Red\"}', '', 1, '14.99', 29, 0, 0, 1),
(48, 54, 2, '{\"Size\":\"L\",\"Color\":\"Red\"}', '', 1, '16.95', 29, 0, 1, 1),
(51, 55, 224, '{\"Size\":\"XXL\",\"Color\":\"Yellow\"}', '', 1, '14.99', 29, 0, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
CREATE TABLE IF NOT EXISTS `product` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(1000) NOT NULL,
  `display` smallint(6) NOT NULL DEFAULT '0',
  `specifications` text NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=219 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`product_id`, `description`, `display`, `specifications`, `user_id`) VALUES
(2, '\"The Fur Merchants\". Not all the beautiful stained glass in the great cathedrals depicts saints and angels! Lay aside your furs for the summer and wear this beautiful T-shirt!', 2, '{\r\n	\"Size\": {\r\n		\"1\": \"S\",\r\n		\"2\": \"M\",\r\n		\"3\": \"L\",\r\n		\"4\": \"XL\",\r\n		\"5\": \"XXL\"\r\n	},\r\n	\"Color\": {\r\n		\"6\": \"White\",\r\n		\"7\": \"Black\",\r\n		\"8\": \"Red\",\r\n		\"9\": \"Orange\"\r\n	}\r\n}', 1),
(3, 'There\'s good reason why the ship plays a prominent part on this shield!', 0, '{	\"Size\": {		\"1\": \"S\",		\"2\": \"M\",		\"3\": \"L\",		\"4\": \"XL\",		\"5\": \"XXL\"	},	\"Color\": {		\"6\": \"White\",		\"7\": \"Black\",		\"8\": \"Red\",		\"9\": \"Orange\"	}}', 1),
(4, 'This fancy chicken is perhaps the most beloved of all French symbols. Unfortunately, there are only a few hundred left, so you\'d better get your T-shirt now!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(5, 'She symbolizes the \"Triumph of the Republic\" and has been depicted many different ways in the history of France, as you will see below!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(6, 'It was in this region of France that Gutenberg perfected his movable type. If he could only see what he started!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(7, 'One of the most famous tapestries of the Loire Valley, it dates from the 14th century. The T-shirt is of more recent vintage, however.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(8, 'There were never any lady centaurs, so these guys had to mate with nymphs and mares. No wonder they were often in such bad moods!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(9, 'Borrowed from Spain, the \"Moor\'s head\" may have celebrated the Christians\' victory over the Moslems in that country.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(10, 'This stamp publicized the dress making industry. Use it to celebrate the T-shirt industry!', 3, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(11, 'Iris was the Goddess of the Rainbow, daughter of the Titans Thaumas and Electra. Are you up to this T-shirt?!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(12, 'The largest American cemetery in France is located in Lorraine and most of the folks there still appreciate that fact.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(13, 'Besides being the messenger of the gods, did you know that Mercury was also the god of profit and commerce? This T-shirt is for business owners!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(14, 'Nice is so nice that it has been fought over for millennia, but now it all belongs to France.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(15, 'Commemorating the 800th anniversary of the famed cathedral.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(16, 'The resulting treaties allowed Italy, Romania, Hungary, Bulgaria, and Finland to reassume their responsibilities as sovereign states in international affairs and thus qualify for membership in the UN.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(17, 'The \"Divine Sarah\" said this about Americans: \"You are younger than we as a race, you are perhaps barbaric, but what of it? You are still in the molding. Your spirit is superb. It is what helped us win the war.\" Perhaps we\'re still barbaric but we\'re still winning wars for them too!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(18, 'A scene from \"Les Tres Riches Heures,\" a medieval \"book of hours\" containing the text for each liturgical hour of the day. This scene is from a 14th century painting.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(19, 'The War had just ended when this stamp was designed, and even so, there was enough optimism to show the destroyed oak tree sprouting again from its stump! What a beautiful T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(20, 'The light goes on! Carry the torch with this T-shirt and be a beacon of hope for the world!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(21, 'The winged foot of Mercury speeds the Special Delivery mail to its destination. In a hurry? This T-shirt is for you!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(22, 'This beautiful T-shirt does honor to one of Italy\'s (and the world\'s) most famous scientists. Show your appreciation for the education you\'ve received!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(23, 'Thanks to modern Italian post, folks were able to reach out and touch each other. Or at least so implies this image. This is a very fast and friendly T-shirt--you\'ll make friends with it!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(24, 'Giuseppe Mazzini is considered one of the patron saints of the \"Risorgimiento.\" Wear this beautiful T-shirt to tell the world you agree!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(25, 'Back in 753 BC, so the story goes, Romulus founded the city of Rome (in competition with Remus, who founded a city on another hill). Their adopted mother is shown in this image. When did they suspect they were adopted?', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(26, 'This beautiful image of the Virgin is from a work by Raphael, whose life and death it honors. It is one of our most popular T-shirts!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(27, 'This image of Jesus teaching the gospel was issued to commemorate the third centenary of the \"propagation of the faith.\" Now you can do your part with this T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(28, 'Here St. Francis is receiving his vision. This dramatic and attractive stamp was issued on the 700th anniversary of that event.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(29, 'This was one of the first stamps of the new Irish Republic, and it makes a T-shirt you\'ll be proud to wear on St. Paddy\'s Day!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(30, 'The Easter Rebellion of 1916 was a defining moment in Irish history. Although only a few hundred participated and the British squashed it in a week, its leaders were executed, which galvanized the uncommitted.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(31, 'Class! Who is this man and why is he important enough for his own T-shirt?!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(32, 'This stamp commemorated the 1500th anniversary of the revered saint\'s death. Is there a more perfect St. Patrick\'s Day T-shirt?!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(33, 'This T-shirt commemorates the holy year of 1950.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(34, 'This was the very first Irish postage stamp, and what a beautiful and cool T-shirt it makes for the Irish person in your life!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(35, 'One of the greatest if not the greatest of Irish poets and writers, Moore led a very interesting life, though plagued with tragedy in a somewhat typically Irish way. Remember \"The Last Rose of Summer\"?', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(36, 'This WPA poster is a wonderful example of the art produced by the Works Projects Administration during the Depression years. Do you feel like you sometimes live or work in a zoo? Then this T-shirt is for you!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(37, 'This handsome Malayan Sambar was a pain in the neck to get to pose like this, and all so you could have this beautiful retro animal T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(38, 'Of all the critters in our T-shirt zoo, this is one of our most popular. A classic animal T-shirt for an individual like yourself!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(39, 'This fellow is more than equipped to hang out with that tail of his, just like you\'ll be fit for hanging out with this great animal T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(40, 'Why is he called \"Colobus,\" \"the mutilated one\"? He doesn\'t have a thumb, just four fingers! He is far from handicapped, however; his hands make him the great swinger he is. Speaking of swinging, that\'s what you\'ll do with this beautiful animal T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(41, 'Being on a major flyway for these guys, we know all about these majestic birds. They hang out in large numbers on a lake near our house and fly over constantly. Remember what Frankie Lane said? \"I want to go where the wild goose goes!\" And when you go, wear this cool Canada goose animal T-shirt.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(42, 'Among land mammals, this white rhino is surpassed in size only by the elephant. He has a big fan base too, working hard to make sure he sticks around. You\'ll be a fan of his, too, when people admire this unique and beautiful T-shirt on you!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(43, 'There\'s a lot going on in this frame! A black rhino is checking out that python slithering off into the bush--or is he eyeing you? You can bet all eyes will be on you when you wear this T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(44, 'Another white rhino is honored in this classic design that bespeaks the Africa of the early century. This pointillist and retro T-shirt will definitely turn heads!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(45, 'I think this T-shirt is destined to be one of our most popular simply because it is one of our most beautiful!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(46, 'This stamp was designed in the middle of the Nazi occupation, as was the one above. Together they reflect a spirit of beauty that evil could not suppress. Both of these T-shirts will make it impossible to suppress your artistic soul, too!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(47, 'From the same series as the Ethiopian Rhino and the Ostriches, this stylish elephant T-shirt will mark you as a connoisseur of good taste!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(48, 'This working guy is proud to have his own stamp, and now he has his own T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(49, 'And yet another Jumbo! You need nothing but a big heart to wear this T-shirt (or a big sense of style)!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(50, 'Another in an old series of beautiful stamps from Ethiopia. These big birds pack quite a wallop, and so will you when you wear this uniquely retro T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(51, 'The photographer had to stand on a step ladder for this handsome portrait, but his efforts paid off with an angle we seldom see of this lofty creature. This beautiful retro T-shirt would make him proud!', 3, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(52, 'This beautiful stamp was issued to commemorate National Colonial Stamp Day (you can do that when you have a colony). When you wear this fancy fish T-shirt, your friends will think it\'s national T-shirt day!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(53, 'A beautiful stamp from a small enclave in southern Morocco that belonged to Spain until 1969 makes a beautiful bird T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(54, 'You can fish them and eat them and now you can wear them with this classic animal T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(55, 'This fellow is also known as the \"White Crested Laughing Thrush.\" What\'s he laughing at? Why, at the joy of being on your T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(56, 'The Portuguese were too busy to run this colony themselves so they gave the Mozambique Company a charter to do it. I think there must be some pretty curious history related to that (the charter only lasted for 50 years)! If you\'re a Leo, or know a Leo, you should seriously consider this T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(57, 'This image is nearly 100 years old! Little did this little llama realize that he was going to be made immortal on the Web and on this very unique animal T-shirt (actually, little did he know at all)!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(58, 'If you know and love this breed, there\'s no reason in the world that you shouldn\'t buy this T-shirt right now!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(59, 'This is our most popular fish T-shirt, hands down. It\'s a beauty, and if you wear this T-shirt, you\'ll be letting the world know you\'re a fine catch!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(60, 'This beautiful image will warm the heart of any fisherman! You must know one if you\'re not one yourself, so you must buy this T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(61, 'Ahhhhhh! This little harp seal would really prefer not to be your coat! But he would like to be your T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(62, 'Some critters you just don\'t want to fool with, and if I were facing this fellow I\'d politely give him the trail! That is, of course, unless I were wearing this T-shirt.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(63, ' In 1915, Newfoundland sent its Newfoundland Regiment to Suvla Bay in Gallipoli to fight the Turks. This classic image does them honor. Have you ever heard of them? Share the news with this great T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(64, 'There was a time when Newfoundland was a self-governing dominion of the British Empire, so it printed its own postage. The themes are as typically Canadian as can be, however, as shown by this \"King of the Wilde\" T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(65, 'This beautiful image was issued to celebrate National Teachers Day. Perhaps you know a teacher who would love this T-shirt?', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(66, 'Well, these crab apples started out as flowers, so that\'s close enough for us! They still make for a uniquely beautiful T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(67, 'Have you ever had nasturtiums on your salad? Try it--they\'re almost as good as having them on your T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(68, 'For your interest (and to impress your friends), this beautiful stamp was issued to honor the George Dimitrov state printing works. You\'ll need to know this when you wear the T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(69, 'Celebrating the 75th anniversary of the Universal Postal Union, a date to mark on your calendar and on which to wear this T-shirt!', 1, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(70, 'The Congo is not at a loss for beautiful flowers, and we\'ve picked a few of them for your T-shirts.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(71, 'This national flower of Costa Rica is one of our most beloved flower T-shirts (you can see one on Jill, above). You will surely stand out in this T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(72, 'The combretum, also known as \"jungle weed,\" is used in China as a cure for opium addiction. Unfortunately, when you wear this T-shirt, others may become hopelessly addicted to you!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(73, 'This is one of the first gingers to bloom in the spring--just like you when you wear this T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(74, 'This plant is native to the rocky and sandy regions of the western United States, so when you come across one, it really stands out. And so will you when you put on this beautiful T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(75, 'A beautiful and sunny T-shirt for both spring and summer!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(76, 'Also known as the spring pheasant\'s eye, this flower belongs on your T-shirt this summer to help you catch a few eyes.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(77, 'Someone out there who can speak Russian needs to tell me what this plant is. I\'ll sell you the T-shirt for $10 if you can!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(78, '\"A white sport coat and a pink carnation, I\'m all dressed up for the dance!\" Well, how about a white T-shirt and a pink carnation?!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(79, 'The Indian Queen Anahi was the ugliest woman ever seen. But instead of living a slave when captured by the Conquistadores, she immolated herself in a fire and was reborn the most beautiful of flowers: the ceibo, national flower of Uruguay. Of course, you won\'t need to burn to wear this T-shirt, but you may cause some pretty hot glances to be thrown your way!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(80, 'Tarmo has produced some wonderful Christmas T-shirts for us, and we hope to have many more soon.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(81, 'Few things make a cat happier at Christmas than a tree suddenly appearing in the house!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(82, 'Is this your grandmother? It could be, you know, and I\'d bet she\'d recognize the Christmas seal on this cool Christmas T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(83, 'This weather vane dates from the 1830\'s and is still showing which way the wind blows! Trumpet your arrival with this unique Christmas T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(84, 'This well-known parasite and killer of trees was revered by the Druids, who would go out and gather it with great ceremony. Youths would go about with it to announce the new year. Eventually more engaging customs were attached to the strange plant, and we\'re here to see that they continue with these cool Christmas T-shirts.', 3, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(85, 'This beautiful angel Christmas T-shirt is awaiting the opportunity to adorn your chest!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(86, 'This is a classic rendition of one of the season?s most beloved stories, and now showing on a Christmas T-shirt for you!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(87, 'Can you get more warm and folksy than this classic Christmas T-shirt?', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(88, 'This exquisite image was painted by Filipino Lippi, a 15th century Italian artist. I think he would approve of it on a Going Postal Christmas T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(89, 'This stained glass window is found in Glasgow Cathedral, Scotland, and was created by Gabriel Loire of France, one of the most prolific of artists in this medium--and now you can have it on this wonderful Christmas T-shirt.', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(90, 'This design is from a miniature in the Evangelistary of Matilda in Nonantola Abbey, from the 12th century. As a Christmas T-shirt, it will cause you to be adored!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(91, 'The original of this beautiful stamp is by Jamie Wyeth and is in the National Gallery of Art. The next best is on our beautiful Christmas T-shirt!', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(92, 'This is a tiny detail of a large work called \"Mary, Queen of Heaven,\" done in 1480 by a Flemish master known only as \"The Master of St. Lucy Legend.\" The original is in a Bruges church. The not-quite-original is on this cool Christmas T-shirt.', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(93, 'Saint Lucia\'s tradition is an important part of Swedish Christmas, and an important part of that are the candles. Next to the candles in importance is this popular Christmas T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(94, 'Santa as a child. You must know a child who would love this cool Christmas T-shirt!?', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(95, 'Hey! I\'ve got an idea! Why not buy two of these cool Christmas T-shirts so you can wear one and tack the other one to your door?!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(96, 'Here\'s a Valentine\'s day T-shirt that will let you say it all in just one easy glance--there\'s no mistake about it!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(97, 'Is your heart all aflutter? Show it with this T-shirt!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(98, 'Love making you feel lighthearted?', 0, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(99, 'This girl\'s got her hockey hunk right where she wants him!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(100, 'Now we\'re getting a bit more serious!', 2, '{ 	\"Size\": { 		\"1\": \"S\", 		\"2\": \"M\", 		\"3\": \"L\", 		\"4\": \"XL\", 		\"5\": \"XXL\" 	}, 	\"Color\": { 		\"6\": \"White\", 		\"7\": \"Black\", 		\"8\": \"Red\", 		\"9\": \"Orange\" 	} }', 1),
(101, 'parthDhankecha', 0, '{\"Size\":{\"1\":\"S\"},\"Color\":{\"12\":\"Blue\"}}', 1);

-- --------------------------------------------------------

--
-- Table structure for table `product_attribute`
--

DROP TABLE IF EXISTS `product_attribute`;
CREATE TABLE IF NOT EXISTS `product_attribute` (
  `product_id` int(11) NOT NULL,
  `attribute_value_id` int(11) NOT NULL,
  PRIMARY KEY (`product_id`,`attribute_value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_attribute`
--

INSERT INTO `product_attribute` (`product_id`, `attribute_value_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(2, 8),
(2, 9),
(2, 10),
(2, 11),
(2, 12),
(2, 13),
(2, 14),
(2, 16),
(3, 1),
(3, 2),
(3, 3),
(3, 4),
(3, 5),
(3, 6),
(3, 7),
(3, 8),
(3, 9),
(3, 10),
(3, 11),
(3, 12),
(3, 13),
(3, 14),
(3, 17),
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(4, 6),
(4, 7),
(4, 8),
(4, 9),
(4, 10),
(4, 11),
(4, 12),
(4, 13),
(4, 14),
(4, 18),
(5, 1),
(5, 2),
(5, 3),
(5, 4),
(5, 5),
(5, 6),
(5, 7),
(5, 8),
(5, 9),
(5, 10),
(5, 11),
(5, 12),
(5, 13),
(5, 14),
(5, 19),
(6, 1),
(6, 2),
(6, 3),
(6, 4),
(6, 5),
(6, 6),
(6, 7),
(6, 8),
(6, 9),
(6, 10),
(6, 11),
(6, 12),
(6, 13),
(6, 14),
(6, 20),
(7, 1),
(7, 2),
(7, 3),
(7, 4),
(7, 5),
(7, 6),
(7, 7),
(7, 8),
(7, 9),
(7, 10),
(7, 11),
(7, 12),
(7, 13),
(7, 14),
(7, 21),
(8, 1),
(8, 2),
(8, 3),
(8, 4),
(8, 5),
(8, 6),
(8, 7),
(8, 8),
(8, 9),
(8, 10),
(8, 11),
(8, 12),
(8, 13),
(8, 14),
(8, 22),
(9, 1),
(9, 2),
(9, 3),
(9, 4),
(9, 5),
(9, 6),
(9, 7),
(9, 8),
(9, 9),
(9, 10),
(9, 11),
(9, 12),
(9, 13),
(9, 14),
(9, 15),
(10, 1),
(10, 2),
(10, 3),
(10, 4),
(10, 5),
(10, 6),
(10, 7),
(10, 8),
(10, 9),
(10, 10),
(10, 11),
(10, 12),
(10, 13),
(10, 14),
(10, 15),
(11, 1),
(11, 2),
(11, 3),
(11, 4),
(11, 5),
(11, 6),
(11, 7),
(11, 8),
(11, 9),
(11, 10),
(11, 11),
(11, 12),
(11, 13),
(11, 14),
(11, 16),
(12, 1),
(12, 2),
(12, 3),
(12, 4),
(12, 5),
(12, 6),
(12, 7),
(12, 8),
(12, 9),
(12, 10),
(12, 11),
(12, 12),
(12, 13),
(12, 14),
(12, 16),
(13, 1),
(13, 2),
(13, 3),
(13, 4),
(13, 5),
(13, 6),
(13, 7),
(13, 8),
(13, 9),
(13, 10),
(13, 11),
(13, 12),
(13, 13),
(13, 14),
(13, 17),
(14, 1),
(14, 2),
(14, 3),
(14, 4),
(14, 5),
(14, 6),
(14, 7),
(14, 8),
(14, 9),
(14, 10),
(14, 11),
(14, 12),
(14, 13),
(14, 14),
(14, 17),
(15, 1),
(15, 2),
(15, 3),
(15, 4),
(15, 5),
(15, 6),
(15, 7),
(15, 8),
(15, 9),
(15, 10),
(15, 11),
(15, 12),
(15, 13),
(15, 14),
(15, 18),
(16, 1),
(16, 2),
(16, 3),
(16, 4),
(16, 5),
(16, 6),
(16, 7),
(16, 8),
(16, 9),
(16, 10),
(16, 11),
(16, 12),
(16, 13),
(16, 14),
(16, 18),
(17, 1),
(17, 2),
(17, 3),
(17, 4),
(17, 5),
(17, 6),
(17, 7),
(17, 8),
(17, 9),
(17, 10),
(17, 11),
(17, 12),
(17, 13),
(17, 14),
(17, 18),
(18, 1),
(18, 2),
(18, 3),
(18, 4),
(18, 5),
(18, 6),
(18, 7),
(18, 8),
(18, 9),
(18, 10),
(18, 11),
(18, 12),
(18, 13),
(18, 14),
(18, 18),
(19, 1),
(19, 2),
(19, 3),
(19, 4),
(19, 5),
(19, 6),
(19, 7),
(19, 8),
(19, 9),
(19, 10),
(19, 11),
(19, 12),
(19, 13),
(19, 14),
(19, 18),
(20, 1),
(20, 2),
(20, 3),
(20, 4),
(20, 5),
(20, 6),
(20, 7),
(20, 8),
(20, 9),
(20, 10),
(20, 11),
(20, 12),
(20, 13),
(20, 14),
(20, 18),
(21, 1),
(21, 2),
(21, 3),
(21, 4),
(21, 5),
(21, 6),
(21, 7),
(21, 8),
(21, 9),
(21, 10),
(21, 11),
(21, 12),
(21, 13),
(21, 14),
(21, 18),
(22, 1),
(22, 2),
(22, 3),
(22, 4),
(22, 5),
(22, 6),
(22, 7),
(22, 8),
(22, 9),
(22, 10),
(22, 11),
(22, 12),
(22, 13),
(22, 14),
(22, 18),
(23, 1),
(23, 2),
(23, 3),
(23, 4),
(23, 5),
(23, 6),
(23, 7),
(23, 8),
(23, 9),
(23, 10),
(23, 11),
(23, 12),
(23, 13),
(23, 14),
(23, 19),
(24, 1),
(24, 2),
(24, 3),
(24, 4),
(24, 5),
(24, 6),
(24, 7),
(24, 8),
(24, 9),
(24, 10),
(24, 11),
(24, 12),
(24, 13),
(24, 14),
(24, 19),
(25, 1),
(25, 2),
(25, 3),
(25, 4),
(25, 5),
(25, 6),
(25, 7),
(25, 8),
(25, 9),
(25, 10),
(25, 11),
(25, 12),
(25, 13),
(25, 14),
(25, 19),
(26, 1),
(26, 2),
(26, 3),
(26, 4),
(26, 5),
(26, 6),
(26, 7),
(26, 8),
(26, 9),
(26, 10),
(26, 11),
(26, 12),
(26, 13),
(26, 14),
(26, 19),
(27, 1),
(27, 2),
(27, 3),
(27, 4),
(27, 5),
(27, 6),
(27, 7),
(27, 8),
(27, 9),
(27, 10),
(27, 11),
(27, 12),
(27, 13),
(27, 14),
(27, 19),
(28, 1),
(28, 2),
(28, 3),
(28, 4),
(28, 5),
(28, 6),
(28, 7),
(28, 8),
(28, 9),
(28, 10),
(28, 11),
(28, 12),
(28, 13),
(28, 14),
(28, 19),
(29, 1),
(29, 2),
(29, 3),
(29, 4),
(29, 5),
(29, 6),
(29, 7),
(29, 8),
(29, 9),
(29, 10),
(29, 11),
(29, 12),
(29, 13),
(29, 14),
(29, 19),
(30, 1),
(30, 2),
(30, 3),
(30, 4),
(30, 5),
(30, 6),
(30, 7),
(30, 8),
(30, 9),
(30, 10),
(30, 11),
(30, 12),
(30, 13),
(30, 14),
(30, 19),
(31, 1),
(31, 2),
(31, 3),
(31, 4),
(31, 5),
(31, 6),
(31, 7),
(31, 8),
(31, 9),
(31, 10),
(31, 11),
(31, 12),
(31, 13),
(31, 14),
(31, 20),
(32, 1),
(32, 2),
(32, 3),
(32, 4),
(32, 5),
(32, 6),
(32, 7),
(32, 8),
(32, 9),
(32, 10),
(32, 11),
(32, 12),
(32, 13),
(32, 14),
(32, 20),
(33, 1),
(33, 2),
(33, 3),
(33, 4),
(33, 5),
(33, 6),
(33, 7),
(33, 8),
(33, 9),
(33, 10),
(33, 11),
(33, 12),
(33, 13),
(33, 14),
(33, 20),
(34, 1),
(34, 2),
(34, 3),
(34, 4),
(34, 5),
(34, 6),
(34, 7),
(34, 8),
(34, 9),
(34, 10),
(34, 11),
(34, 12),
(34, 13),
(34, 14),
(34, 20),
(35, 1),
(35, 2),
(35, 3),
(35, 4),
(35, 5),
(35, 6),
(35, 7),
(35, 8),
(35, 9),
(35, 10),
(35, 11),
(35, 12),
(35, 13),
(35, 14),
(35, 20),
(36, 1),
(36, 2),
(36, 3),
(36, 4),
(36, 5),
(36, 6),
(36, 7),
(36, 8),
(36, 9),
(36, 10),
(36, 11),
(36, 12),
(36, 13),
(36, 14),
(36, 20),
(37, 1),
(37, 2),
(37, 3),
(37, 4),
(37, 5),
(37, 6),
(37, 7),
(37, 8),
(37, 9),
(37, 10),
(37, 11),
(37, 12),
(37, 13),
(37, 14),
(37, 20),
(38, 1),
(38, 2),
(38, 3),
(38, 4),
(38, 5),
(38, 6),
(38, 7),
(38, 8),
(38, 9),
(38, 10),
(38, 11),
(38, 12),
(38, 13),
(38, 14),
(38, 20),
(39, 1),
(39, 2),
(39, 3),
(39, 4),
(39, 5),
(39, 6),
(39, 7),
(39, 8),
(39, 9),
(39, 10),
(39, 11),
(39, 12),
(39, 13),
(39, 14),
(39, 21),
(40, 1),
(40, 2),
(40, 3),
(40, 4),
(40, 5),
(40, 6),
(40, 7),
(40, 8),
(40, 9),
(40, 10),
(40, 11),
(40, 12),
(40, 13),
(40, 14),
(40, 21),
(41, 1),
(41, 2),
(41, 3),
(41, 4),
(41, 5),
(41, 6),
(41, 7),
(41, 8),
(41, 9),
(41, 10),
(41, 11),
(41, 12),
(41, 13),
(41, 14),
(41, 21),
(42, 1),
(42, 2),
(42, 3),
(42, 4),
(42, 5),
(42, 6),
(42, 7),
(42, 8),
(42, 9),
(42, 10),
(42, 11),
(42, 12),
(42, 13),
(42, 14),
(42, 21),
(43, 1),
(43, 2),
(43, 3),
(43, 4),
(43, 5),
(43, 6),
(43, 7),
(43, 8),
(43, 9),
(43, 10),
(43, 11),
(43, 12),
(43, 13),
(43, 14),
(43, 21),
(44, 1),
(44, 2),
(44, 3),
(44, 4),
(44, 5),
(44, 6),
(44, 7),
(44, 8),
(44, 9),
(44, 10),
(44, 11),
(44, 12),
(44, 13),
(44, 14),
(44, 21),
(45, 1),
(45, 2),
(45, 3),
(45, 4),
(45, 5),
(45, 6),
(45, 7),
(45, 8),
(45, 9),
(45, 10),
(45, 11),
(45, 12),
(45, 13),
(45, 14),
(45, 21),
(46, 1),
(46, 2),
(46, 3),
(46, 4),
(46, 5),
(46, 6),
(46, 7),
(46, 8),
(46, 9),
(46, 10),
(46, 11),
(46, 12),
(46, 13),
(46, 14),
(46, 21),
(47, 1),
(47, 2),
(47, 3),
(47, 4),
(47, 5),
(47, 6),
(47, 7),
(47, 8),
(47, 9),
(47, 10),
(47, 11),
(47, 12),
(47, 13),
(47, 14),
(47, 22),
(48, 1),
(48, 2),
(48, 3),
(48, 4),
(48, 5),
(48, 6),
(48, 7),
(48, 8),
(48, 9),
(48, 10),
(48, 11),
(48, 12),
(48, 13),
(48, 14),
(48, 22),
(49, 1),
(49, 2),
(49, 3),
(49, 4),
(49, 5),
(49, 6),
(49, 7),
(49, 8),
(49, 9),
(49, 10),
(49, 11),
(49, 12),
(49, 13),
(49, 14),
(49, 22),
(50, 1),
(50, 2),
(50, 3),
(50, 4),
(50, 5),
(50, 6),
(50, 7),
(50, 8),
(50, 9),
(50, 10),
(50, 11),
(50, 12),
(50, 13),
(50, 14),
(50, 22),
(51, 1),
(51, 2),
(51, 3),
(51, 4),
(51, 5),
(51, 6),
(51, 7),
(51, 8),
(51, 9),
(51, 10),
(51, 11),
(51, 12),
(51, 13),
(51, 14),
(51, 22),
(52, 1),
(52, 2),
(52, 3),
(52, 4),
(52, 5),
(52, 6),
(52, 7),
(52, 8),
(52, 9),
(52, 10),
(52, 11),
(52, 12),
(52, 13),
(52, 14),
(52, 22),
(53, 1),
(53, 2),
(53, 3),
(53, 4),
(53, 5),
(53, 6),
(53, 7),
(53, 8),
(53, 9),
(53, 10),
(53, 11),
(53, 12),
(53, 13),
(53, 14),
(53, 22),
(54, 1),
(54, 2),
(54, 3),
(54, 4),
(54, 5),
(54, 6),
(54, 7),
(54, 8),
(54, 9),
(54, 10),
(54, 11),
(54, 12),
(54, 13),
(54, 14),
(54, 22),
(55, 1),
(55, 2),
(55, 3),
(55, 4),
(55, 5),
(55, 6),
(55, 7),
(55, 8),
(55, 9),
(55, 10),
(55, 11),
(55, 12),
(55, 13),
(55, 14),
(55, 15),
(56, 1),
(56, 2),
(56, 3),
(56, 4),
(56, 5),
(56, 6),
(56, 7),
(56, 8),
(56, 9),
(56, 10),
(56, 11),
(56, 12),
(56, 13),
(56, 14),
(56, 15),
(57, 1),
(57, 2),
(57, 3),
(57, 4),
(57, 5),
(57, 6),
(57, 7),
(57, 8),
(57, 9),
(57, 10),
(57, 11),
(57, 12),
(57, 13),
(57, 14),
(57, 15),
(58, 1),
(58, 2),
(58, 3),
(58, 4),
(58, 5),
(58, 6),
(58, 7),
(58, 8),
(58, 9),
(58, 10),
(58, 11),
(58, 12),
(58, 13),
(58, 14),
(58, 15),
(59, 1),
(59, 2),
(59, 3),
(59, 4),
(59, 5),
(59, 6),
(59, 7),
(59, 8),
(59, 9),
(59, 10),
(59, 11),
(59, 12),
(59, 13),
(59, 14),
(59, 15),
(60, 1),
(60, 2),
(60, 3),
(60, 4),
(60, 5),
(60, 6),
(60, 7),
(60, 8),
(60, 9),
(60, 10),
(60, 11),
(60, 12),
(60, 13),
(60, 14),
(60, 15),
(61, 1),
(61, 2),
(61, 3),
(61, 4),
(61, 5),
(61, 6),
(61, 7),
(61, 8),
(61, 9),
(61, 10),
(61, 11),
(61, 12),
(61, 13),
(61, 14),
(61, 15),
(62, 1),
(62, 2),
(62, 3),
(62, 4),
(62, 5),
(62, 6),
(62, 7),
(62, 8),
(62, 9),
(62, 10),
(62, 11),
(62, 12),
(62, 13),
(62, 14),
(62, 15),
(63, 1),
(63, 2),
(63, 3),
(63, 4),
(63, 5),
(63, 6),
(63, 7),
(63, 8),
(63, 9),
(63, 10),
(63, 11),
(63, 12),
(63, 13),
(63, 14),
(63, 15),
(64, 1),
(64, 2),
(64, 3),
(64, 4),
(64, 5),
(64, 6),
(64, 7),
(64, 8),
(64, 9),
(64, 10),
(64, 11),
(64, 12),
(64, 13),
(64, 14),
(64, 15),
(65, 1),
(65, 2),
(65, 3),
(65, 4),
(65, 5),
(65, 6),
(65, 7),
(65, 8),
(65, 9),
(65, 10),
(65, 11),
(65, 12),
(65, 13),
(65, 14),
(65, 16),
(66, 1),
(66, 2),
(66, 3),
(66, 4),
(66, 5),
(66, 6),
(66, 7),
(66, 8),
(66, 9),
(66, 10),
(66, 11),
(66, 12),
(66, 13),
(66, 14),
(66, 16),
(67, 1),
(67, 2),
(67, 3),
(67, 4),
(67, 5),
(67, 6),
(67, 7),
(67, 8),
(67, 9),
(67, 10),
(67, 11),
(67, 12),
(67, 13),
(67, 14),
(67, 16),
(68, 1),
(68, 2),
(68, 3),
(68, 4),
(68, 5),
(68, 6),
(68, 7),
(68, 8),
(68, 9),
(68, 10),
(68, 11),
(68, 12),
(68, 13),
(68, 14),
(68, 16),
(69, 1),
(69, 2),
(69, 3),
(69, 4),
(69, 5),
(69, 6),
(69, 7),
(69, 8),
(69, 9),
(69, 10),
(69, 11),
(69, 12),
(69, 13),
(69, 14),
(69, 16),
(70, 1),
(70, 2),
(70, 3),
(70, 4),
(70, 5),
(70, 6),
(70, 7),
(70, 8),
(70, 9),
(70, 10),
(70, 11),
(70, 12),
(70, 13),
(70, 14),
(70, 16),
(71, 1),
(71, 2),
(71, 3),
(71, 4),
(71, 5),
(71, 6),
(71, 7),
(71, 8),
(71, 9),
(71, 10),
(71, 11),
(71, 12),
(71, 13),
(71, 14),
(71, 16),
(72, 1),
(72, 2),
(72, 3),
(72, 4),
(72, 5),
(72, 6),
(72, 7),
(72, 8),
(72, 9),
(72, 10),
(72, 11),
(72, 12),
(72, 13),
(72, 14),
(72, 16),
(73, 1),
(73, 2),
(73, 3),
(73, 4),
(73, 5),
(73, 6),
(73, 7),
(73, 8),
(73, 9),
(73, 10),
(73, 11),
(73, 12),
(73, 13),
(73, 14),
(73, 16),
(74, 1),
(74, 2),
(74, 3),
(74, 4),
(74, 5),
(74, 6),
(74, 7),
(74, 8),
(74, 9),
(74, 10),
(74, 11),
(74, 12),
(74, 13),
(74, 14),
(74, 16),
(75, 1),
(75, 2),
(75, 3),
(75, 4),
(75, 5),
(75, 6),
(75, 7),
(75, 8),
(75, 9),
(75, 10),
(75, 11),
(75, 12),
(75, 13),
(75, 14),
(75, 17),
(76, 1),
(76, 2),
(76, 3),
(76, 4),
(76, 5),
(76, 6),
(76, 7),
(76, 8),
(76, 9),
(76, 10),
(76, 11),
(76, 12),
(76, 13),
(76, 14),
(76, 17),
(77, 1),
(77, 2),
(77, 3),
(77, 4),
(77, 5),
(77, 6),
(77, 7),
(77, 8),
(77, 9),
(77, 10),
(77, 11),
(77, 12),
(77, 13),
(77, 14),
(77, 17),
(78, 1),
(78, 2),
(78, 3),
(78, 4),
(78, 5),
(78, 6),
(78, 7),
(78, 8),
(78, 9),
(78, 10),
(78, 11),
(78, 12),
(78, 13),
(78, 14),
(78, 17),
(79, 1),
(79, 2),
(79, 3),
(79, 4),
(79, 5),
(79, 6),
(79, 7),
(79, 8),
(79, 9),
(79, 10),
(79, 11),
(79, 12),
(79, 13),
(79, 14),
(79, 17),
(80, 1),
(80, 2),
(80, 3),
(80, 4),
(80, 5),
(80, 6),
(80, 7),
(80, 8),
(80, 9),
(80, 10),
(80, 11),
(80, 12),
(80, 13),
(80, 14),
(80, 17),
(81, 1),
(81, 2),
(81, 3),
(81, 4),
(81, 5),
(81, 6),
(81, 7),
(81, 8),
(81, 9),
(81, 10),
(81, 11),
(81, 12),
(81, 13),
(81, 14),
(81, 17),
(82, 1),
(82, 2),
(82, 3),
(82, 4),
(82, 5),
(82, 6),
(82, 7),
(82, 8),
(82, 9),
(82, 10),
(82, 11),
(82, 12),
(82, 13),
(82, 14),
(82, 17),
(83, 1),
(83, 2),
(83, 3),
(83, 4),
(83, 5),
(83, 6),
(83, 7),
(83, 8),
(83, 9),
(83, 10),
(83, 11),
(83, 12),
(83, 13),
(83, 14),
(83, 17),
(84, 1),
(84, 2),
(84, 3),
(84, 4),
(84, 5),
(84, 6),
(84, 7),
(84, 8),
(84, 9),
(84, 10),
(84, 11),
(84, 12),
(84, 13),
(84, 14),
(84, 17),
(85, 1),
(85, 2),
(85, 3),
(85, 4),
(85, 5),
(85, 6),
(85, 7),
(85, 8),
(85, 9),
(85, 10),
(85, 11),
(85, 12),
(85, 13),
(85, 14),
(85, 18),
(86, 1),
(86, 2),
(86, 3),
(86, 4),
(86, 5),
(86, 6),
(86, 7),
(86, 8),
(86, 9),
(86, 10),
(86, 11),
(86, 12),
(86, 13),
(86, 14),
(86, 18),
(87, 1),
(87, 2),
(87, 3),
(87, 4),
(87, 5),
(87, 6),
(87, 7),
(87, 8),
(87, 9),
(87, 10),
(87, 11),
(87, 12),
(87, 13),
(87, 14),
(87, 18),
(88, 1),
(88, 2),
(88, 3),
(88, 4),
(88, 5),
(88, 6),
(88, 7),
(88, 8),
(88, 9),
(88, 10),
(88, 11),
(88, 12),
(88, 13),
(88, 14),
(88, 18),
(89, 1),
(89, 2),
(89, 3),
(89, 4),
(89, 5),
(89, 6),
(89, 7),
(89, 8),
(89, 9),
(89, 10),
(89, 11),
(89, 12),
(89, 13),
(89, 14),
(89, 18),
(90, 1),
(90, 2),
(90, 3),
(90, 4),
(90, 5),
(90, 6),
(90, 7),
(90, 8),
(90, 9),
(90, 10),
(90, 11),
(90, 12),
(90, 13),
(90, 14),
(90, 19),
(91, 1),
(91, 2),
(91, 3),
(91, 4),
(91, 5),
(91, 6),
(91, 7),
(91, 8),
(91, 9),
(91, 10),
(91, 11),
(91, 12),
(91, 13),
(91, 14),
(91, 19),
(92, 1),
(92, 2),
(92, 3),
(92, 4),
(92, 5),
(92, 6),
(92, 7),
(92, 8),
(92, 9),
(92, 10),
(92, 11),
(92, 12),
(92, 13),
(92, 14),
(92, 19),
(93, 1),
(93, 2),
(93, 3),
(93, 4),
(93, 5),
(93, 6),
(93, 7),
(93, 8),
(93, 9),
(93, 10),
(93, 11),
(93, 12),
(93, 13),
(93, 14),
(93, 19),
(94, 1),
(94, 2),
(94, 3),
(94, 4),
(94, 5),
(94, 6),
(94, 7),
(94, 8),
(94, 9),
(94, 10),
(94, 11),
(94, 12),
(94, 13),
(94, 14),
(94, 19),
(95, 1),
(95, 2),
(95, 3),
(95, 4),
(95, 5),
(95, 6),
(95, 7),
(95, 8),
(95, 9),
(95, 10),
(95, 11),
(95, 12),
(95, 13),
(95, 14),
(95, 20),
(96, 1),
(96, 2),
(96, 3),
(96, 4),
(96, 5),
(96, 6),
(96, 7),
(96, 8),
(96, 9),
(96, 10),
(96, 11),
(96, 12),
(96, 13),
(96, 14),
(96, 20),
(97, 1),
(97, 2),
(97, 3),
(97, 4),
(97, 5),
(97, 6),
(97, 7),
(97, 8),
(97, 9),
(97, 10),
(97, 11),
(97, 12),
(97, 13),
(97, 14),
(97, 21),
(98, 1),
(98, 2),
(98, 3),
(98, 4),
(98, 5),
(98, 6),
(98, 7),
(98, 8),
(98, 9),
(98, 10),
(98, 11),
(98, 12),
(98, 13),
(98, 14),
(98, 21),
(99, 1),
(99, 2),
(99, 3),
(99, 4),
(99, 5),
(99, 6),
(99, 7),
(99, 8),
(99, 9),
(99, 10),
(99, 11),
(99, 12),
(99, 13),
(99, 14),
(99, 22),
(100, 1),
(100, 2),
(100, 3),
(100, 4),
(100, 5),
(100, 6),
(100, 7),
(100, 8),
(100, 9),
(100, 10),
(100, 11),
(100, 12),
(100, 13),
(100, 14),
(100, 22),
(101, 1),
(101, 2),
(101, 3),
(101, 4),
(101, 5),
(101, 6),
(101, 7),
(101, 8),
(101, 9),
(101, 10),
(101, 11),
(101, 12),
(101, 13),
(101, 14),
(101, 22);

-- --------------------------------------------------------

--
-- Table structure for table `product_category`
--

DROP TABLE IF EXISTS `product_category`;
CREATE TABLE IF NOT EXISTS `product_category` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`product_id`,`category_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_category`
--

INSERT INTO `product_category` (`product_id`, `category_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 1),
(10, 1),
(11, 1),
(12, 1),
(13, 1),
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 2),
(20, 2),
(21, 2),
(22, 2),
(23, 2),
(24, 2),
(25, 2),
(26, 2),
(27, 2),
(28, 2),
(29, 3),
(30, 3),
(31, 3),
(32, 3),
(33, 3),
(34, 3),
(35, 3),
(36, 4),
(37, 4),
(38, 4),
(39, 4),
(40, 4),
(41, 4),
(42, 4),
(43, 4),
(44, 4),
(45, 4),
(46, 4),
(47, 4),
(48, 4),
(49, 4),
(50, 4),
(51, 4),
(52, 4),
(53, 4),
(54, 4),
(55, 4),
(56, 4),
(57, 4),
(58, 4),
(59, 4),
(60, 4),
(61, 4),
(62, 4),
(63, 4),
(64, 4),
(65, 5),
(66, 5),
(67, 5),
(68, 5),
(69, 5),
(70, 5),
(71, 5),
(72, 5),
(73, 5),
(74, 5),
(75, 5),
(76, 5),
(77, 5),
(78, 5),
(79, 5),
(80, 6),
(81, 4),
(81, 6),
(82, 6),
(83, 6),
(84, 6),
(85, 6),
(86, 6),
(87, 6),
(88, 6),
(89, 6),
(90, 6),
(91, 6),
(92, 6),
(93, 6),
(94, 6),
(95, 6),
(96, 7),
(97, 4),
(98, 4),
(99, 7),
(101, 7),
(208, 5),
(209, 5),
(210, 28),
(211, 29),
(212, 27),
(213, 43),
(214, 45),
(215, 4),
(216, 42),
(217, 29),
(218, 4);

-- --------------------------------------------------------

--
-- Table structure for table `product_return`
--

DROP TABLE IF EXISTS `product_return`;
CREATE TABLE IF NOT EXISTS `product_return` (
  `return_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_detail_id` int(11) NOT NULL,
  `return_date` datetime NOT NULL,
  `customer_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_cost` decimal(10,2) NOT NULL,
  `refunded` tinyint(1) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`return_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE IF NOT EXISTS `product_variants` (
  `variant_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `discounted_price` decimal(10,2) NOT NULL,
  `thumbnail` text NOT NULL,
  `list_image` text NOT NULL,
  `view_image` text NOT NULL,
  `large_image` text NOT NULL,
  `quantity` int(11) NOT NULL,
  `parent` tinyint(1) NOT NULL,
  `size_id` int(11) NOT NULL,
  `color_id` int(11) NOT NULL,
  `material_id` int(11) NOT NULL,
  PRIMARY KEY (`variant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=405 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`variant_id`, `product_id`, `user_id`, `name`, `price`, `discounted_price`, `thumbnail`, `list_image`, `view_image`, `large_image`, `quantity`, `parent`, `size_id`, `color_id`, `material_id`) VALUES
(2, 2, 1, 'ChRed-artres Cathedral', '16.95', '1.00', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', 50, 1, 3, 8, 0),
(3, 3, 1, 'CoRed-at of Arms', '14.50', '0.00', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', 50, 1, 3, 8, 0),
(4, 4, 1, 'GaRed-llic Cock', '18.99', '2.00', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', 50, 1, 3, 8, 0),
(5, 5, 1, 'MaRed-rianne', '15.95', '1.00', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', 50, 1, 3, 8, 0),
(6, 6, 1, 'AlRed-sace', '16.50', '0.00', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', 50, 1, 3, 8, 0),
(7, 7, 1, 'ApRed-ocalypse Tapestry', '20.00', '1.05', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', 50, 1, 3, 8, 0),
(8, 8, 1, 'CeRed-ntaur', '14.99', '0.00', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', 50, 1, 3, 8, 0),
(9, 9, 1, 'CoRed-rsica', '22.00', '0.00', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', 50, 1, 3, 8, 0),
(10, 10, 1, 'HRed-aute Couture', '15.99', '1.04', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', 50, 1, 3, 8, 0),
(11, 11, 1, 'IRed-ris', '17.50', '0.00', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559887331907.jpg\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559887331907.jpg\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559887331907.jpg\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559887331907.jpg\"]', 50, 1, 3, 8, 0),
(12, 12, 1, 'LRed-orraine', '16.95', '0.00', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', 50, 1, 3, 8, 0),
(13, 13, 1, 'MRed-ercury', '21.99', '3.04', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', 50, 1, 3, 8, 0),
(14, 14, 1, 'CRed-ounty of Nice', '12.95', '0.00', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', 50, 1, 3, 8, 0),
(15, 15, 1, 'NRed-otre Dame', '18.50', '1.51', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', 50, 1, 3, 8, 0),
(16, 16, 1, 'PRed-aris Peace Conference', '16.95', '0.96', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', 50, 1, 3, 8, 0),
(17, 17, 1, 'SRed-arah Bernhardt', '14.99', '0.00', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', 50, 1, 3, 8, 0),
(18, 18, 1, 'HRed-unt', '16.99', '1.04', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', 50, 1, 3, 8, 0),
(19, 19, 1, 'IRed-talia', '22.00', '3.01', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', 50, 1, 3, 8, 0),
(20, 20, 1, 'TRed-orch', '19.99', '2.04', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', 50, 1, 3, 8, 0),
(21, 21, 1, 'ERed-spresso', '16.95', '0.00', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', 50, 1, 3, 8, 0),
(22, 22, 1, 'GRed-alileo', '14.99', '0.00', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', 50, 1, 3, 8, 0),
(23, 23, 1, 'IRed-talian Airmail', '21.00', '0.00', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', 50, 1, 3, 8, 0),
(24, 24, 1, 'MRed-azzini', '20.50', '1.55', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', 50, 1, 3, 8, 0),
(25, 25, 1, 'RRed-omulus & Remus', '17.99', '0.00', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', 50, 1, 3, 8, 0),
(26, 26, 1, 'IRed-taly Maria', '14.00', '0.00', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', 50, 1, 3, 8, 0),
(27, 27, 1, 'IRed-taly Jesus', '16.95', '0.00', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', 50, 1, 3, 8, 0),
(28, 28, 1, 'SRed-t. Francis', '22.00', '3.01', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', 50, 1, 3, 8, 0),
(29, 29, 1, 'IRed-rish Coat of Arms', '14.99', '0.00', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', 50, 1, 3, 8, 0),
(30, 30, 1, 'ERed-aster Rebellion', '19.00', '2.05', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', 50, 1, 3, 8, 0),
(31, 31, 1, 'GRed-uiness', '15.00', '0.00', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', 50, 1, 3, 8, 0),
(32, 32, 1, 'SRed-t. Patrick', '20.50', '2.55', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', 50, 1, 3, 8, 0),
(33, 33, 1, 'SRed-t. Peter', '16.00', '1.05', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', 50, 1, 3, 8, 0),
(34, 34, 1, 'SRed-word of Light', '14.99', '0.00', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', 50, 1, 3, 8, 0),
(35, 35, 1, 'TRed-homas Moore', '15.95', '0.96', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', 50, 1, 3, 8, 0),
(36, 36, 1, 'VRed-isit the Zoo', '20.00', '3.05', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', 50, 1, 3, 8, 0),
(37, 37, 1, 'SRed-ambar', '19.00', '1.01', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', 50, 1, 3, 8, 0),
(38, 38, 1, 'BRed-uffalo', '14.99', '0.00', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', 50, 1, 3, 8, 0),
(39, 39, 1, 'MRed-ustache Monkey', '20.00', '0.00', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', 50, 1, 3, 8, 0),
(40, 40, 1, 'CRed-olobus', '17.00', '1.01', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', 50, 1, 3, 8, 0),
(41, 41, 1, 'CRed-anada Goose', '15.99', '0.00', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', 50, 1, 3, 8, 0),
(42, 42, 1, 'CRed-ongo Rhino', '20.00', '1.01', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', 50, 1, 3, 8, 0),
(43, 43, 1, 'ERed-quatorial Rhino', '19.95', '2.00', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', 50, 1, 3, 8, 0),
(44, 44, 1, 'ERed-thiopian Rhino', '16.00', '0.00', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', 50, 1, 3, 8, 0),
(45, 45, 1, 'DRed-utch Sea Horse', '12.50', '0.00', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', 50, 1, 3, 8, 0),
(46, 46, 1, 'DRed-utch Swans', '21.00', '2.01', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', 50, 1, 3, 8, 0),
(47, 47, 1, 'ERed-thiopian Elephant', '18.99', '2.04', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', 50, 1, 3, 8, 0),
(48, 48, 1, 'LRed-aotian Elephant', '21.00', '2.01', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', 50, 1, 3, 8, 0),
(49, 49, 1, 'LRed-iberian Elephant', '22.00', '4.50', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', 50, 1, 3, 8, 0),
(50, 50, 1, 'SRed-omali Ostriches', '12.95', '0.00', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', 50, 1, 3, 8, 0),
(51, 51, 1, 'TRed-ankanyika Giraffe', '15.00', '2.01', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', 50, 1, 3, 8, 0),
(52, 52, 1, 'IRed-fni Fish', '14.00', '0.00', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', 50, 1, 3, 8, 0),
(53, 53, 1, 'SRed-ea Gull', '19.00', '2.05', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', 50, 1, 3, 8, 0),
(54, 54, 1, 'KRed-ing Salmon', '17.95', '1.96', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', 50, 1, 3, 8, 0),
(55, 55, 1, 'LRed-aos Bird', '12.00', '0.00', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', 50, 1, 3, 8, 0),
(56, 56, 1, 'MRed-ozambique Lion', '15.99', '1.04', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', 50, 1, 3, 8, 0),
(57, 57, 1, 'PRed-eru Llama', '21.50', '3.51', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', 50, 1, 3, 8, 0),
(58, 58, 1, 'RRed-omania Alsatian', '15.95', '0.00', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', 50, 1, 3, 8, 0),
(59, 59, 1, 'SRed-omali Fish', '19.95', '3.00', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', 50, 1, 3, 8, 0),
(60, 60, 1, 'TRed-rout', '14.00', '0.00', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', 50, 1, 3, 8, 0),
(61, 61, 1, 'BRed-aby Seal', '21.00', '2.01', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', 50, 1, 3, 8, 0),
(62, 62, 1, 'MRed-usk Ox', '15.50', '0.00', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', 50, 1, 3, 8, 0),
(63, 63, 1, 'SRed-uvla Bay', '12.99', '0.00', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', 50, 1, 3, 8, 0),
(64, 64, 1, 'CRed-aribou', '21.00', '1.05', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', 50, 1, 3, 8, 0),
(65, 65, 1, 'ARed-fghan Flower', '18.50', '1.51', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', 50, 1, 3, 8, 0),
(66, 66, 1, 'ARed-lbania Flower', '16.00', '1.05', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', 50, 1, 3, 8, 0),
(67, 67, 1, 'ARed-ustria Flower', '12.99', '0.00', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', 50, 1, 3, 8, 0),
(68, 68, 1, 'BRed-ulgarian Flower', '16.00', '1.01', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', 50, 1, 3, 8, 0),
(69, 69, 1, 'CRed-olombia Flower', '14.50', '1.55', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', 50, 1, 3, 8, 0),
(70, 70, 1, 'CRed-ongo Flower', '21.00', '3.01', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', 50, 1, 3, 8, 0),
(71, 71, 1, 'CRed-osta Rica Flower', '12.99', '0.00', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', 50, 1, 3, 8, 0),
(72, 72, 1, 'GRed-abon Flower', '19.00', '2.05', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', 50, 1, 3, 8, 0),
(73, 73, 1, 'GRed-hana Flower', '21.00', '2.01', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', 50, 1, 3, 8, 0),
(74, 74, 1, 'IRed-srael Flower', '19.50', '2.00', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', 50, 1, 3, 8, 0),
(75, 75, 1, 'PRed-oland Flower', '16.95', '0.96', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', 50, 1, 3, 8, 0),
(76, 76, 1, 'RRed-omania Flower', '12.95', '0.00', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', 50, 1, 3, 8, 0),
(77, 77, 1, 'RRed-ussia Flower', '21.00', '2.05', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', 50, 1, 3, 8, 0),
(78, 78, 1, 'SRed-an Marino Flower', '19.95', '1.96', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', 50, 1, 3, 8, 0),
(79, 79, 1, 'URed-ruguay Flower', '17.99', '1.00', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', 50, 1, 3, 8, 0),
(80, 80, 1, 'SRed-now Deer', '21.00', '2.05', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', 50, 1, 3, 8, 0),
(81, 81, 1, 'HRed-olly Cat', '15.99', '0.00', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', 50, 1, 3, 8, 0),
(82, 82, 1, 'CRed-hristmas Seal', '19.99', '2.00', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', 50, 1, 3, 8, 0),
(83, 83, 1, 'WRed-eather Vane', '15.95', '0.96', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', 50, 1, 3, 8, 0),
(84, 84, 1, 'MRed-istletoe', '19.00', '1.01', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', 50, 1, 3, 8, 0),
(85, 85, 1, 'ARed-ltar Piece', '20.50', '2.00', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', 50, 1, 3, 8, 0),
(86, 86, 1, 'TRed-he Three Wise Men', '12.99', '0.00', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', 50, 1, 3, 8, 0),
(87, 87, 1, 'CRed-hristmas Tree', '20.00', '2.05', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', 50, 1, 3, 8, 0),
(88, 88, 1, 'MRed-adonna & Child', '21.95', '3.45', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', 50, 1, 3, 8, 0),
(89, 89, 1, 'TRed-he Virgin Mary', '16.95', '1.00', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', 50, 1, 3, 8, 0),
(90, 90, 1, 'ARed-doration of the Kings', '17.50', '1.00', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', 50, 1, 3, 8, 0),
(91, 91, 1, 'ARed- Partridge in a Pear Tree', '14.99', '0.00', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', 50, 1, 3, 8, 0),
(92, 92, 1, 'SRed-t. Lucy', '18.95', '0.00', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', 50, 1, 3, 8, 0),
(93, 93, 1, 'SRed-t. Lucia', '19.00', '1.05', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', 50, 1, 3, 8, 0),
(94, 94, 1, 'SRed-wede Santa', '21.00', '2.50', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', 50, 1, 3, 8, 0),
(95, 95, 1, 'WRed-reath', '18.99', '2.00', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', 50, 1, 3, 8, 0),
(96, 96, 1, 'LRed-ove', '19.00', '1.50', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', 50, 1, 3, 8, 0),
(97, 97, 1, 'BRed-irds', '21.00', '2.05', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', 50, 1, 3, 8, 0),
(98, 98, 1, 'KRed-at Over New Moon', '14.99', '0.00', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', 50, 1, 3, 8, 0),
(99, 99, 1, 'TRed-hrilling Love', '21.00', '2.50', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', 50, 1, 3, 8, 0),
(102, 2, 1, 'Green-Arc d\'Triomphe', '14.99', '0.00', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', '[\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\",\"chartres-cathedral.gif\"]', 150, 0, 5, 8, 0),
(103, 3, 1, 'Green-Chartres Cathedral', '16.95', '1.00', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', 150, 0, 5, 8, 0),
(104, 4, 1, 'Grren-Coat of Arms', '14.50', '0.00', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', 150, 0, 5, 8, 0),
(105, 5, 1, 'Grren-Gallic Cock', '18.99', '2.00', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', 150, 0, 5, 8, 0),
(106, 6, 1, 'Grren-Marianne', '15.95', '1.00', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', 150, 0, 5, 8, 0),
(107, 7, 1, 'Grren-Alsace', '16.50', '0.00', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', 150, 0, 5, 8, 0),
(108, 8, 1, 'Grren-Apocalypse Tapestry', '20.00', '1.05', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', 150, 0, 5, 8, 0),
(109, 9, 1, 'Grren-Centaur', '14.99', '0.00', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', 150, 0, 5, 8, 0),
(110, 10, 1, 'Grren-Corsica', '22.00', '0.00', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', 150, 0, 5, 8, 0),
(111, 11, 1, 'Green-Haute Couture', '15.99', '1.04', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', 150, 0, 5, 8, 0),
(112, 12, 1, 'Green-Iris', '17.50', '0.00', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', 150, 0, 5, 8, 0),
(113, 13, 1, 'Green-Lorraine', '16.95', '0.00', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', 150, 0, 5, 8, 0),
(114, 14, 1, 'Green-Mercury', '21.99', '3.04', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', 150, 0, 5, 8, 0),
(115, 15, 1, 'Green-County of Nice', '12.95', '0.00', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', 150, 0, 5, 8, 0),
(116, 16, 1, 'Green-Notre Dame', '18.50', '1.51', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', 150, 0, 5, 8, 0),
(117, 17, 1, 'Green-Paris Peace Conference', '16.95', '0.96', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', 150, 0, 5, 8, 0),
(118, 18, 1, 'Green-Sarah Bernhardt', '14.99', '0.00', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', 150, 0, 5, 8, 0),
(119, 19, 1, 'Green-Hunt', '16.99', '1.04', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', 150, 0, 5, 8, 0),
(120, 20, 1, 'Green-Italia', '22.00', '3.01', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', 150, 0, 5, 8, 0),
(121, 21, 1, 'Green-Torch', '19.99', '2.04', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', 150, 0, 5, 8, 0);
INSERT INTO `product_variants` (`variant_id`, `product_id`, `user_id`, `name`, `price`, `discounted_price`, `thumbnail`, `list_image`, `view_image`, `large_image`, `quantity`, `parent`, `size_id`, `color_id`, `material_id`) VALUES
(122, 22, 1, 'Green-Espresso', '16.95', '0.00', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', 150, 0, 5, 8, 0),
(123, 23, 1, 'Green-Galileo', '14.99', '0.00', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', 150, 0, 5, 8, 0),
(124, 24, 1, 'Green-Italian Airmail', '21.00', '0.00', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', 150, 0, 5, 8, 0),
(125, 25, 1, 'Green-Mazzini', '20.50', '1.55', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', 150, 0, 5, 8, 0),
(126, 26, 1, 'Green-Romulus & Remus', '17.99', '0.00', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', 150, 0, 5, 8, 0),
(127, 27, 1, 'Green-Italy Maria', '14.00', '0.00', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', 150, 0, 5, 8, 0),
(128, 28, 1, 'Green-Italy Jesus', '16.95', '0.00', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', 150, 0, 5, 8, 0),
(129, 29, 1, 'Green-St. Francis', '22.00', '3.01', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', 150, 0, 5, 8, 0),
(130, 30, 1, 'Green-Irish Coat of Arms', '14.99', '0.00', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', 150, 0, 5, 8, 0),
(131, 31, 1, 'Green-Easter Rebellion', '19.00', '2.05', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', 150, 0, 5, 8, 0),
(132, 32, 1, 'Green-Guiness', '15.00', '0.00', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', 150, 0, 5, 8, 0),
(133, 33, 1, 'Green-St. Patrick', '20.50', '2.55', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', 150, 0, 5, 8, 0),
(134, 34, 1, 'Green-St. Peter', '16.00', '1.05', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', 150, 0, 5, 8, 0),
(135, 35, 1, 'Green-Sword of Light', '14.99', '0.00', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', 150, 0, 5, 8, 0),
(136, 36, 1, 'Green-Thomas Moore', '15.95', '0.96', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', 150, 0, 5, 8, 0),
(137, 37, 1, 'Green-Visit the Zoo', '20.00', '3.05', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', 150, 0, 5, 8, 0),
(138, 38, 1, 'Green-Sambar', '19.00', '1.01', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', 150, 0, 5, 8, 0),
(139, 39, 1, 'Green-Buffalo', '14.99', '0.00', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', 150, 0, 5, 8, 0),
(140, 40, 1, 'Green-Mustache Monkey', '20.00', '0.00', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', 150, 0, 5, 8, 0),
(141, 41, 1, 'Green-Colobus', '17.00', '1.01', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', 150, 0, 5, 8, 0),
(142, 42, 1, 'Green-Canada Goose', '15.99', '0.00', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', 150, 0, 5, 8, 0),
(143, 43, 1, 'Green-Congo Rhino', '20.00', '1.01', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', 150, 0, 5, 8, 0),
(144, 44, 1, 'Green-Equatorial Rhino', '19.95', '2.00', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', 150, 0, 5, 8, 0),
(145, 45, 1, 'Green-Ethiopian Rhino', '16.00', '0.00', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', 150, 0, 5, 8, 0),
(146, 46, 1, 'Green-Dutch Sea Horse', '12.50', '0.00', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', 150, 0, 5, 8, 0),
(147, 47, 1, 'Green-Dutch Swans', '21.00', '2.01', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', 150, 0, 5, 8, 0),
(148, 48, 1, 'Green-Ethiopian Elephant', '18.99', '2.04', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', 150, 0, 5, 8, 0),
(149, 49, 1, 'Green-Laotian Elephant', '21.00', '2.01', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', 150, 0, 5, 8, 0),
(150, 50, 1, 'Green-Liberian Elephant', '22.00', '4.50', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', 150, 0, 5, 8, 0),
(151, 51, 1, 'Green-Somali Ostriches', '12.95', '0.00', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', 150, 0, 5, 8, 0),
(152, 52, 1, 'Green-Tankanyika Giraffe', '15.00', '2.01', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', 150, 0, 5, 8, 0),
(153, 53, 1, 'Green-Ifni Fish', '14.00', '0.00', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', 150, 0, 5, 8, 0),
(154, 54, 1, 'Green-Sea Gull', '19.00', '2.05', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', 150, 0, 5, 8, 0),
(155, 55, 1, 'Green-King Salmon', '17.95', '1.96', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', 150, 0, 5, 8, 0),
(156, 56, 1, 'Green-Laos Bird', '12.00', '0.00', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', 150, 0, 5, 8, 0),
(157, 57, 1, 'Green-Mozambique Lion', '15.99', '1.04', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', 150, 0, 5, 8, 0),
(158, 58, 1, 'Green-Peru Llama', '21.50', '3.51', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', 150, 0, 5, 8, 0),
(159, 59, 1, 'Green-Romania Alsatian', '15.95', '0.00', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', 150, 0, 5, 8, 0),
(160, 60, 1, 'Green-Somali Fish', '19.95', '3.00', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', 150, 0, 5, 8, 0),
(161, 61, 1, 'Green-Trout', '14.00', '0.00', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', 150, 0, 5, 8, 0),
(162, 62, 1, 'Green-Baby Seal', '21.00', '2.01', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', 150, 0, 5, 8, 0),
(163, 63, 1, 'Green-Musk Ox', '15.50', '0.00', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', 150, 0, 5, 8, 0),
(164, 64, 1, 'Green-Suvla Bay', '12.99', '0.00', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', 150, 0, 5, 8, 0),
(165, 65, 1, 'Green-Caribou', '21.00', '1.05', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', 150, 0, 5, 8, 0),
(166, 66, 1, 'Green-Afghan Flower', '18.50', '1.51', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', 150, 0, 5, 8, 0),
(167, 67, 1, 'Green-Albania Flower', '16.00', '1.05', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', 150, 0, 5, 8, 0),
(168, 68, 1, 'Green-Austria Flower', '12.99', '0.00', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', 150, 0, 5, 8, 0),
(169, 69, 1, 'Green-Bulgarian Flower', '16.00', '1.01', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', 150, 0, 5, 8, 0),
(170, 70, 1, 'Green-Colombia Flower', '14.50', '1.55', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', 150, 0, 5, 8, 0),
(171, 71, 1, 'Green-Congo Flower', '21.00', '3.01', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', 150, 0, 5, 8, 0),
(172, 72, 1, 'Green-Costa Rica Flower', '12.99', '0.00', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', 150, 0, 5, 8, 0),
(173, 73, 1, 'Green-Gabon Flower', '19.00', '2.05', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', 150, 0, 5, 8, 0),
(174, 74, 1, 'Green-Ghana Flower', '21.00', '2.01', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', 150, 0, 5, 8, 0),
(175, 75, 1, 'Green-Israel Flower', '19.50', '2.00', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', 150, 0, 5, 8, 0),
(176, 76, 1, 'Green-Poland Flower', '16.95', '0.96', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', 150, 0, 5, 8, 0),
(177, 77, 1, 'Green-Romania Flower', '12.95', '0.00', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', 150, 0, 5, 8, 0),
(178, 78, 1, 'Green-Russia Flower', '21.00', '2.05', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', 150, 0, 5, 8, 0),
(179, 79, 1, 'Green-San Marino Flower', '19.95', '1.96', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', 150, 0, 5, 8, 0),
(180, 80, 1, 'Green-Uruguay Flower', '17.99', '1.00', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', 150, 0, 5, 8, 0),
(181, 81, 1, 'Green-Snow Deer', '21.00', '2.05', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', 150, 0, 5, 8, 0),
(182, 82, 1, 'Green-Holly Cat', '15.99', '0.00', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', 150, 0, 5, 8, 0),
(183, 83, 1, 'Green-Christmas Seal', '19.99', '2.00', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', 150, 0, 5, 8, 0),
(184, 84, 1, 'Green-Weather Vane', '15.95', '0.96', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', 150, 0, 5, 8, 0),
(185, 85, 1, 'Green-Mistletoe', '19.00', '1.01', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', 150, 0, 5, 8, 0),
(186, 86, 1, 'Green-Altar Piece', '20.50', '2.00', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', 150, 0, 5, 8, 0),
(187, 87, 1, 'Green-The Three Wise Men', '12.99', '0.00', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', 150, 0, 5, 8, 0),
(188, 88, 1, 'Green-Christmas Tree', '20.00', '2.05', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', 150, 0, 5, 8, 0),
(189, 89, 1, 'Green-Madonna & Child', '21.95', '3.45', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', 150, 0, 5, 8, 0),
(190, 90, 1, 'Green-The Virgin Mary', '16.95', '1.00', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', 150, 0, 5, 8, 0),
(191, 91, 1, 'Green-Adoration of the Kings', '17.50', '1.00', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', 150, 0, 5, 8, 0),
(192, 92, 1, 'Green-A Partridge in a Pear Tree', '14.99', '0.00', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', 150, 0, 5, 8, 0),
(193, 93, 1, 'Green-St. Lucy', '18.95', '0.00', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', 150, 0, 5, 8, 0),
(194, 94, 1, 'Green-St. Lucia', '19.00', '1.05', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', 150, 0, 5, 8, 0),
(195, 95, 1, 'Green-Swede Santa', '21.00', '2.50', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', 150, 0, 5, 8, 0),
(196, 96, 1, 'Green-Wreath', '18.99', '2.00', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', 150, 0, 5, 8, 0),
(197, 97, 1, 'Green-Love', '19.00', '1.50', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', 150, 0, 5, 8, 0),
(198, 98, 1, 'Green-Birds', '21.00', '2.05', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', 150, 0, 5, 8, 0),
(199, 99, 1, 'Green-Kat Over New Moon', '14.99', '0.00', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', 150, 0, 5, 8, 0),
(200, 100, 1, 'Green-Thrilling Love', '21.00', '2.50', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', 150, 0, 5, 8, 0),
(203, 2, 1, 'Yellow-Arc d\'Triomphe', '14.99', '0.00', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', '[\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\",\"coat-of-arms.gif\"]', 100, 0, 5, 10, 0),
(204, 3, 1, 'Yellow-Chartres Cathedral', '16.95', '1.00', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', 100, 0, 5, 10, 0),
(205, 4, 1, 'Yellow-Coat of Arms', '14.50', '0.00', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', 100, 0, 5, 10, 0),
(206, 5, 1, 'Yellow-Gallic Cock', '18.99', '2.00', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', 100, 0, 5, 10, 0),
(207, 6, 1, 'Yellow-Marianne', '15.95', '1.00', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', '[\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\',\'apocalypse-tapestry.gif\']', 100, 0, 5, 10, 0),
(208, 7, 1, 'Yellow-Alsace', '16.50', '0.00', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', 100, 0, 5, 10, 0),
(209, 8, 1, 'Yellow-Apocalypse Tapestry', '20.00', '1.05', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', 100, 0, 5, 10, 0),
(210, 9, 1, 'Yellow-Centaur', '14.99', '0.00', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', 100, 0, 5, 10, 0),
(211, 10, 1, 'Yellow-Corsica', '22.00', '0.00', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', 100, 0, 5, 10, 0),
(212, 11, 1, 'Yellow-Haute Couture', '15.99', '1.04', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', 100, 0, 5, 10, 0),
(213, 12, 1, 'Yellow-Iris', '17.50', '0.00', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', 100, 0, 5, 10, 0),
(214, 13, 1, 'Yellow-Lorraine', '16.95', '0.00', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', 100, 0, 5, 10, 0),
(215, 14, 1, 'Yellow-Mercury', '21.99', '3.04', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', 100, 0, 5, 10, 0),
(216, 15, 1, 'Yellow-County of Nice', '12.95', '0.00', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', 100, 0, 5, 10, 0),
(217, 16, 1, 'Yellow-Notre Dame', '18.50', '1.51', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', 100, 0, 5, 10, 0),
(218, 17, 1, 'Yellow-Paris Peace Conference', '16.95', '0.96', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', 100, 0, 5, 10, 0),
(219, 18, 1, 'Yellow-Sarah Bernhardt', '14.99', '0.00', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', 100, 0, 5, 10, 0),
(220, 19, 1, 'Yellow-Hunt', '16.99', '1.04', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', 100, 0, 5, 10, 0),
(221, 20, 1, 'Yellow-Italia', '22.00', '3.01', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', 100, 0, 5, 10, 0),
(222, 21, 1, 'Yellow-Torch', '19.99', '2.04', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', 100, 0, 5, 10, 0),
(223, 22, 1, 'Yellow-Espresso', '16.95', '0.00', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', 100, 0, 5, 10, 0),
(224, 23, 1, 'Yellow-Galileo', '14.99', '0.00', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', 100, 0, 5, 10, 0),
(225, 24, 1, 'Yellow-Italian Airmail', '21.00', '0.00', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', 100, 0, 5, 10, 0),
(226, 25, 1, 'Yellow-Mazzini', '20.50', '1.55', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', 100, 0, 5, 10, 0),
(227, 26, 1, 'Yellow-Romulus & Remus', '17.99', '0.00', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', 100, 0, 5, 10, 0),
(228, 27, 1, 'Yellow-Italy Maria', '14.00', '0.00', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', 100, 0, 5, 10, 0),
(229, 28, 1, 'Yellow-Italy Jesus', '16.95', '0.00', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', 100, 0, 5, 10, 0),
(230, 29, 1, 'Yellow-St. Francis', '22.00', '3.01', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', 100, 0, 5, 10, 0),
(231, 30, 1, 'Yellow-Irish Coat of Arms', '14.99', '0.00', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', 100, 0, 5, 10, 0),
(232, 31, 1, 'Yellow-Easter Rebellion', '19.00', '2.05', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', 100, 0, 5, 10, 0),
(233, 32, 1, 'Yellow-Guiness', '15.00', '0.00', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', 100, 0, 5, 10, 0),
(234, 33, 1, 'Yellow-St. Patrick', '20.50', '2.55', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', 100, 0, 5, 10, 0),
(235, 34, 1, 'Yellow-St. Peter', '16.00', '1.05', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', 100, 0, 5, 10, 0),
(236, 35, 1, 'Yellow-Sword of Light', '14.99', '0.00', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', 100, 0, 5, 10, 0),
(237, 36, 1, 'Yellow-Thomas Moore', '15.95', '0.96', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', 100, 0, 5, 10, 0),
(238, 37, 1, 'Yellow-Visit the Zoo', '20.00', '3.05', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', 100, 0, 5, 10, 0),
(239, 38, 1, 'Yellow-Sambar', '19.00', '1.01', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', 100, 0, 5, 10, 0),
(240, 39, 1, 'Yellow-Buffalo', '14.99', '0.00', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', 100, 0, 5, 10, 0),
(241, 40, 1, 'Yellow-Mustache Monkey', '20.00', '0.00', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', 100, 0, 5, 10, 0);
INSERT INTO `product_variants` (`variant_id`, `product_id`, `user_id`, `name`, `price`, `discounted_price`, `thumbnail`, `list_image`, `view_image`, `large_image`, `quantity`, `parent`, `size_id`, `color_id`, `material_id`) VALUES
(242, 41, 1, 'Yellow-Colobus', '17.00', '1.01', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', 100, 0, 5, 10, 0),
(243, 42, 1, 'Yellow-Canada Goose', '15.99', '0.00', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', 100, 0, 5, 10, 0),
(244, 43, 1, 'Yellow-Congo Rhino', '20.00', '1.01', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', 100, 0, 5, 10, 0),
(245, 44, 1, 'Yellow-Equatorial Rhino', '19.95', '2.00', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', 100, 0, 5, 10, 0),
(246, 45, 1, 'Yellow-Ethiopian Rhino', '16.00', '0.00', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', 100, 0, 5, 10, 0),
(247, 46, 1, 'Yellow-Dutch Sea Horse', '12.50', '0.00', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', 100, 0, 5, 10, 0),
(248, 47, 1, 'Yellow-Dutch Swans', '21.00', '2.01', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', 100, 0, 5, 10, 0),
(249, 48, 1, 'Yellow-Ethiopian Elephant', '18.99', '2.04', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', 100, 0, 5, 10, 0),
(250, 49, 1, 'Yellow-Laotian Elephant', '21.00', '2.01', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', 100, 0, 5, 10, 0),
(251, 50, 1, 'Yellow-Liberian Elephant', '22.00', '4.50', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', 100, 0, 5, 10, 0),
(252, 51, 1, 'Yellow-Somali Ostriches', '12.95', '0.00', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', 100, 0, 5, 10, 0),
(253, 52, 1, 'Yellow-Tankanyika Giraffe', '15.00', '2.01', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', 100, 0, 5, 10, 0),
(254, 53, 1, 'Yellow-Ifni Fish', '14.00', '0.00', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', 100, 0, 5, 10, 0),
(255, 54, 1, 'Yellow-Sea Gull', '19.00', '2.05', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', 100, 0, 5, 10, 0),
(256, 55, 1, 'Yellow-King Salmon', '17.95', '1.96', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', 100, 0, 5, 10, 0),
(257, 56, 1, 'Yellow-Laos Bird', '12.00', '0.00', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', 100, 0, 5, 10, 0),
(258, 57, 1, 'Yellow-Mozambique Lion', '15.99', '1.04', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', 100, 0, 5, 10, 0),
(259, 58, 1, 'Yellow-Peru Llama', '21.50', '3.51', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', 100, 0, 5, 10, 0),
(260, 59, 1, 'Yellow-Romania Alsatian', '15.95', '0.00', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', 100, 0, 5, 10, 0),
(261, 60, 1, 'Yellow-Somali Fish', '19.95', '3.00', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', 100, 0, 5, 10, 0),
(262, 61, 1, 'Yellow-Trout', '14.00', '0.00', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', 100, 0, 5, 10, 0),
(263, 62, 1, 'Yellow-Baby Seal', '21.00', '2.01', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', 100, 0, 5, 10, 0),
(264, 63, 1, 'Yellow-Musk Ox', '15.50', '0.00', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', 100, 0, 5, 10, 0),
(265, 64, 1, 'Yellow-Suvla Bay', '12.99', '0.00', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', 100, 0, 5, 10, 0),
(266, 65, 1, 'Yellow-Caribou', '21.00', '1.05', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', 100, 0, 5, 10, 0),
(267, 66, 1, 'Yellow-Afghan Flower', '18.50', '1.51', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', 100, 0, 5, 10, 0),
(268, 67, 1, 'Yellow-Albania Flower', '16.00', '1.05', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', 100, 0, 5, 10, 0),
(269, 68, 1, 'Yellow-Austria Flower', '12.99', '0.00', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', 100, 0, 5, 10, 0),
(270, 69, 1, 'Yellow-Bulgarian Flower', '16.00', '1.01', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', 100, 0, 5, 10, 0),
(271, 70, 1, 'Yellow-Colombia Flower', '14.50', '1.55', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', 100, 0, 5, 10, 0),
(272, 71, 1, 'Yellow-Congo Flower', '21.00', '3.01', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', 100, 0, 5, 10, 0),
(273, 72, 1, 'Yellow-Costa Rica Flower', '12.99', '0.00', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', 100, 0, 5, 10, 0),
(274, 73, 1, 'Yellow-Gabon Flower', '19.00', '2.05', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', 100, 0, 5, 10, 0),
(275, 74, 1, 'Yellow-Ghana Flower', '21.00', '2.01', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', 100, 0, 5, 10, 0),
(276, 75, 1, 'Yellow-Israel Flower', '19.50', '2.00', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', 100, 0, 5, 10, 0),
(277, 76, 1, 'Yellow-Poland Flower', '16.95', '0.96', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', 100, 0, 5, 10, 0),
(278, 77, 1, 'Yellow-Romania Flower', '12.95', '0.00', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', 100, 0, 5, 10, 0),
(279, 78, 1, 'Yellow-Russia Flower', '21.00', '2.05', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', 100, 0, 5, 10, 0),
(280, 79, 1, 'Yellow-San Marino Flower', '19.95', '1.96', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', 100, 0, 5, 10, 0),
(281, 80, 1, 'Yellow-Uruguay Flower', '17.99', '1.00', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', 100, 0, 5, 10, 0),
(282, 81, 1, 'Yellow-Snow Deer', '21.00', '2.05', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', 100, 0, 5, 10, 0),
(283, 82, 1, 'Yellow-Holly Cat', '15.99', '0.00', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', 100, 0, 5, 10, 0),
(284, 83, 1, 'Yellow-Christmas Seal', '19.99', '2.00', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', 100, 0, 5, 10, 0),
(285, 84, 1, 'Yellow-Weather Vane', '15.95', '0.96', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', 100, 0, 5, 10, 0),
(286, 85, 1, 'Yellow-Mistletoe', '19.00', '1.01', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', 100, 0, 5, 10, 0),
(287, 86, 1, 'Yellow-Altar Piece', '20.50', '2.00', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', 100, 0, 5, 10, 0),
(288, 87, 1, 'Yellow-The Three Wise Men', '12.99', '0.00', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', 100, 0, 5, 10, 0),
(289, 88, 1, 'Yellow-Christmas Tree', '20.00', '2.05', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', 100, 0, 5, 10, 0),
(290, 89, 1, 'Yellow-Madonna & Child', '21.95', '3.45', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', 100, 0, 5, 10, 0),
(291, 90, 1, 'Yellow-The Virgin Mary', '16.95', '1.00', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', 100, 0, 5, 10, 0),
(292, 91, 1, 'Yellow-Adoration of the Kings', '17.50', '1.00', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', 100, 0, 5, 10, 0),
(293, 92, 1, 'Yellow-A Partridge in a Pear Tree', '14.99', '0.00', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', 100, 0, 5, 10, 0),
(294, 93, 1, 'Yellow-St. Lucy', '18.95', '0.00', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', 100, 0, 5, 10, 0),
(295, 94, 1, 'Yellow-St. Lucia', '19.00', '1.05', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', 100, 0, 5, 10, 0),
(296, 95, 1, 'Yellow-Swede Santa', '21.00', '2.50', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', 100, 0, 5, 10, 0),
(297, 96, 1, 'Yellow-Wreath', '18.99', '2.00', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', 100, 0, 5, 10, 0),
(298, 97, 1, 'Yellow-Love', '19.00', '1.50', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', 100, 0, 5, 10, 0),
(299, 98, 1, 'Yellow-Birds', '21.00', '2.05', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', 100, 0, 5, 10, 0),
(300, 99, 1, 'Yellow-Kat Over New Moon', '14.99', '0.00', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', 100, 0, 5, 10, 0),
(301, 100, 1, 'Yellow-Thrilling Love', '21.00', '2.50', '', '', '', '', 0, 0, 4, 10, 0),
(304, 2, 1, 'Yellow-Arc d\'Triomphe', '14.99', '0.00', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', '[\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\",\"gallic-cock.gif\"]', 300, 0, 4, 10, 0),
(305, 3, 1, 'Yellow-Chartres Cathedral', '16.95', '1.00', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', '[\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\",\"marianne.gif\"]', 300, 0, 4, 10, 0),
(306, 4, 1, 'Yellow-Coat of Arms', '14.50', '0.00', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', '[\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\",\"alsace.gif\"]', 300, 0, 4, 10, 0),
(307, 5, 1, 'Yellow-Gallic Cock', '18.99', '2.00', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', '[\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\",\"apocalypse-tapestry.gif\"]', 300, 0, 4, 10, 0),
(308, 6, 1, 'Yellow-Marianne', '15.95', '1.00', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', '[\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\",\"centaur.gif\"]', 300, 0, 4, 10, 0),
(309, 7, 1, 'Yellow-Alsace', '16.50', '0.00', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', '[\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\",\"corsica.gif\"]', 300, 0, 4, 10, 0),
(310, 8, 1, 'Yellow-Apocalypse Tapestry', '20.00', '1.05', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', '[\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\",\"haute-couture.gif\"]', 300, 0, 4, 10, 0),
(311, 9, 1, 'Yellow-Centaur', '14.99', '0.00', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', '[\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\",\"iris.gif\"]', 300, 0, 4, 10, 0),
(312, 10, 1, 'Yellow-Corsica', '22.00', '0.00', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', '[\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\",\"lorraine.gif\"]', 300, 0, 4, 10, 0),
(313, 11, 1, 'Yellow-Haute Couture', '15.99', '1.04', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', '[\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\",\"mercury.gif\"]', 300, 0, 4, 10, 0),
(314, 12, 1, 'Yellow-Iris', '17.50', '0.00', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', '[\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\",\"county-of-nice.gif\"]', 300, 0, 4, 10, 0),
(315, 13, 1, 'Yellow-Lorraine', '16.95', '0.00', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', '[\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\",\"notre-dame.gif\"]', 300, 0, 4, 10, 0),
(316, 14, 1, 'Yellow-Mercury', '21.99', '3.04', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', '[\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\",\"paris-peace-conference.gif\"]', 300, 0, 4, 10, 0),
(317, 15, 1, 'Yellow-County of Nice', '12.95', '0.00', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', '[\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\",\"sarah-bernhardt.gif\"]', 300, 0, 4, 10, 0),
(318, 16, 1, 'Yellow-Notre Dame', '18.50', '1.51', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', '[\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\",\"hunt.gif\"]', 300, 0, 4, 10, 0),
(319, 17, 1, 'Yellow-Paris Peace Conference', '16.95', '0.96', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', '[\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\",\"italia.gif\"]', 300, 0, 4, 10, 0),
(320, 18, 1, 'Yellow-Sarah Bernhardt', '14.99', '0.00', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', '[\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\",\"torch.gif\"]', 300, 0, 4, 10, 0),
(321, 19, 1, 'Yellow-Hunt', '16.99', '1.04', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', '[\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\",\"espresso.gif\"]', 300, 0, 4, 10, 0),
(322, 20, 1, 'Yellow-Italia', '22.00', '3.01', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', '[\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\",\"galileo.gif\"]', 300, 0, 4, 10, 0),
(323, 21, 1, 'Yellow-Torch', '19.99', '2.04', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', '[\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\",\"italian-airmail.gif\"]', 300, 0, 4, 10, 0),
(324, 22, 1, 'Yellow-Espresso', '16.95', '0.00', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', '[\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\",\"mazzini.gif\"]', 300, 0, 4, 10, 0),
(325, 23, 1, 'Yellow-Galileo', '14.99', '0.00', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', '[\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\",\"romulus-remus.gif\"]', 300, 0, 4, 10, 0),
(326, 24, 1, 'Yellow-Italian Airmail', '21.00', '0.00', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', '[\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\",\"italy-maria.gif\"]', 300, 0, 4, 10, 0),
(327, 25, 1, 'Yellow-Mazzini', '20.50', '1.55', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', '[\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\",\"italy-jesus.gif\"]', 300, 0, 4, 10, 0),
(328, 26, 1, 'Yellow-Romulus & Remus', '17.99', '0.00', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', '[\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\",\"st-francis.gif\"]', 300, 0, 4, 10, 0),
(329, 27, 1, 'Yellow-Italy Maria', '14.00', '0.00', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', '[\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\",\"irish-coat-of-arms.gif\"]', 300, 0, 4, 10, 0),
(330, 28, 1, 'Yellow-Italy Jesus', '16.95', '0.00', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', '[\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\",\"easter-rebellion.gif\"]', 300, 0, 4, 10, 0),
(331, 29, 1, 'Yellow-St. Francis', '22.00', '3.01', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', '[\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\",\"guiness.gif\"]', 300, 0, 4, 10, 0),
(332, 30, 1, 'Yellow-Irish Coat of Arms', '14.99', '0.00', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', '[\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\",\"st-patrick.gif\"]', 300, 0, 4, 10, 0),
(333, 31, 1, 'Yellow-Easter Rebellion', '19.00', '2.05', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', '[\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\",\"st-peter.gif\"]', 300, 0, 4, 10, 0),
(334, 32, 1, 'Yellow-Guiness', '15.00', '0.00', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', '[\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\",\"sword-of-light.gif\"]', 300, 0, 4, 10, 0),
(335, 33, 1, 'Yellow-St. Patrick', '20.50', '2.55', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', '[\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\",\"thomas-moore.gif\"]', 300, 0, 4, 10, 0),
(336, 34, 1, 'Yellow-St. Peter', '16.00', '1.05', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', '[\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\",\"visit-the-zoo.gif\"]', 300, 0, 4, 10, 0),
(337, 35, 1, 'Yellow-Sword of Light', '14.99', '0.00', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', '[\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\",\"sambar.gif\"]', 300, 0, 4, 10, 0),
(338, 36, 1, 'Yellow-Thomas Moore', '15.95', '0.96', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', '[\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\",\"buffalo.gif\"]', 300, 0, 4, 10, 0),
(339, 37, 1, 'Yellow-Visit the Zoo', '20.00', '3.05', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', '[\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\",\"mustache-monkey.gif\"]', 300, 0, 4, 10, 0),
(340, 38, 1, 'Yellow-Sambar', '19.00', '1.01', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', '[\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\",\"colobus.gif\"]', 300, 0, 4, 10, 0),
(341, 39, 1, 'Yellow-Buffalo', '14.99', '0.00', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', '[\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\",\"canada-goose.gif\"]', 300, 0, 4, 10, 0),
(342, 40, 1, 'Yellow-Mustache Monkey', '20.00', '0.00', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', '[\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\",\"congo-rhino.gif\"]', 300, 0, 4, 10, 0),
(343, 41, 1, 'Yellow-Colobus', '17.00', '1.01', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', '[\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\",\"equatorial-rhino.gif\"]', 300, 0, 4, 10, 0),
(344, 42, 1, 'Yellow-Canada Goose', '15.99', '0.00', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', '[\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\",\"ethiopian-rhino.gif\"]', 300, 0, 4, 10, 0),
(345, 43, 1, 'Yellow-Congo Rhino', '20.00', '1.01', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', '[\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\",\"dutch-sea-horse.gif\"]', 300, 0, 4, 10, 0),
(346, 44, 1, 'Yellow-Equatorial Rhino', '19.95', '2.00', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', '[\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\",\"dutch-swans.gif\"]', 300, 0, 4, 10, 0),
(347, 45, 1, 'Yellow-Ethiopian Rhino', '16.00', '0.00', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', '[\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\",\"ethiopian-elephant.gif\"]', 300, 0, 4, 10, 0),
(348, 46, 1, 'Yellow-Dutch Sea Horse', '12.50', '0.00', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', '[\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\",\"laotian-elephant.gif\"]', 300, 0, 4, 10, 0),
(349, 47, 1, 'Yellow-Dutch Swans', '21.00', '2.01', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', '[\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\",\"liberian-elephant.gif\"]', 300, 0, 4, 10, 0),
(350, 48, 1, 'Yellow-Ethiopian Elephant', '18.99', '2.04', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', '[\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\",\"somali-ostriches.gif\"]', 300, 0, 4, 10, 0),
(351, 49, 1, 'Yellow-Laotian Elephant', '21.00', '2.01', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', '[\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\",\"tankanyika-giraffe.gif\"]', 300, 0, 4, 10, 0);
INSERT INTO `product_variants` (`variant_id`, `product_id`, `user_id`, `name`, `price`, `discounted_price`, `thumbnail`, `list_image`, `view_image`, `large_image`, `quantity`, `parent`, `size_id`, `color_id`, `material_id`) VALUES
(352, 50, 1, 'Yellow-Liberian Elephant', '22.00', '4.50', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', '[\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\",\"ifni-fish.gif\"]', 300, 0, 4, 10, 0),
(353, 51, 1, 'Yellow-Somali Ostriches', '12.95', '0.00', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', '[\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\",\"sea-gull.gif\"]', 300, 0, 4, 10, 0),
(354, 52, 1, 'Yellow-Tankanyika Giraffe', '15.00', '2.01', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', '[\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\",\"king-salmon.gif\"]', 300, 0, 4, 10, 0),
(355, 53, 1, 'Yellow-Ifni Fish', '14.00', '0.00', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', '[\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\",\"laos-bird.gif\"]', 300, 0, 4, 10, 0),
(356, 54, 1, 'Yellow-Sea Gull', '19.00', '2.05', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', '[\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\",\"mozambique-lion.gif\"]', 300, 0, 4, 10, 0),
(357, 55, 1, 'Yellow-King Salmon', '17.95', '1.96', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', '[\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\",\"peru-llama.gif\"]', 300, 0, 4, 10, 0),
(358, 56, 1, 'Yellow-Laos Bird', '12.00', '0.00', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', '[\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\",\"romania-alsatian.gif\"]', 300, 0, 4, 10, 0),
(359, 57, 1, 'Yellow-Mozambique Lion', '15.99', '1.04', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', '[\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\",\"somali-fish.gif\"]', 300, 0, 4, 10, 0),
(360, 58, 1, 'Yellow-Peru Llama', '21.50', '3.51', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', '[\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\",\"trout.gif\"]', 300, 0, 4, 10, 0),
(361, 59, 1, 'Yellow-Romania Alsatian', '15.95', '0.00', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', '[\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\",\"baby-seal.gif\"]', 300, 0, 4, 10, 0),
(362, 60, 1, 'Yellow-Somali Fish', '19.95', '3.00', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', '[\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\",\"musk-ox.gif\"]', 300, 0, 4, 10, 0),
(363, 61, 1, 'Yellow-Trout', '14.00', '0.00', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', '[\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\",\"suvla-bay.gif\"]', 300, 0, 4, 10, 0),
(364, 62, 1, 'Yellow-Baby Seal', '21.00', '2.01', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', '[\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\",\"caribou.gif\"]', 300, 0, 4, 10, 0),
(365, 63, 1, 'Yellow-Musk Ox', '15.50', '0.00', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', '[\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\",\"afghan-flower.gif\"]', 300, 0, 4, 10, 0),
(366, 64, 1, 'Yellow-Suvla Bay', '12.99', '0.00', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', '[\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\",\"albania-flower.gif\"]', 300, 0, 4, 10, 0),
(367, 65, 1, 'Yellow-Caribou', '21.00', '1.05', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', '[\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\",\"austria-flower.gif\"]', 300, 0, 4, 10, 0),
(368, 66, 1, 'Yellow-Afghan Flower', '18.50', '1.51', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', '[\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\",\"bulgarian-flower.gif\"]', 300, 0, 4, 10, 0),
(369, 67, 1, 'Yellow-Albania Flower', '16.00', '1.05', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', '[\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\",\"colombia-flower.gif\"]', 300, 0, 4, 10, 0),
(370, 68, 1, 'Yellow-Austria Flower', '12.99', '0.00', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', '[\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\",\"congo-flower.gif\"]', 300, 0, 4, 10, 0),
(371, 69, 1, 'Yellow-Bulgarian Flower', '16.00', '1.01', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', '[\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\",\"costa-rica-flower.gif\"]', 300, 0, 4, 10, 0),
(372, 70, 1, 'Yellow-Colombia Flower', '14.50', '1.55', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', '[\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\",\"gabon-flower.gif\"]', 300, 0, 4, 10, 0),
(373, 71, 1, 'Yellow-Congo Flower', '21.00', '3.01', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', '[\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\",\"ghana-flower.gif\"]', 300, 0, 4, 10, 0),
(374, 72, 1, 'Yellow-Costa Rica Flower', '12.99', '0.00', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', '[\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\",\"israel-flower.gif\"]', 300, 0, 4, 10, 0),
(375, 73, 1, 'Yellow-Gabon Flower', '19.00', '2.05', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', '[\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\",\"poland-flower.gif\"]', 300, 0, 4, 10, 0),
(376, 74, 1, 'Yellow-Ghana Flower', '21.00', '2.01', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', '[\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\",\"romania-flower.gif\"]', 300, 0, 4, 10, 0),
(377, 75, 1, 'Yellow-Israel Flower', '19.50', '2.00', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', '[\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\",\"russia-flower.gif\"]', 300, 0, 4, 10, 0),
(378, 76, 1, 'Yellow-Poland Flower', '16.95', '0.96', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', '[\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\",\"san-marino-flower.gif\"]', 300, 0, 4, 10, 0),
(379, 77, 1, 'Yellow-Romania Flower', '12.95', '0.00', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', '[\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\",\"uruguay-flower.gif\"]', 300, 0, 4, 10, 0),
(380, 78, 1, 'Yellow-Russia Flower', '21.00', '2.05', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', '[\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\",\"snow-deer.gif\"]', 300, 0, 4, 10, 0),
(381, 79, 1, 'Yellow-San Marino Flower', '19.95', '1.96', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', '[\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\",\"holly-cat.gif\"]', 300, 0, 4, 10, 0),
(382, 80, 1, 'Yellow-Uruguay Flower', '17.99', '1.00', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', '[\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\",\"christmas-seal.gif\"]', 300, 0, 4, 10, 0),
(383, 81, 1, 'Yellow-Snow Deer', '21.00', '2.05', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', '[\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\",\"weather-vane.gif\"]', 300, 0, 4, 10, 0),
(384, 82, 1, 'Yellow-Holly Cat', '15.99', '0.00', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', '[\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\",\"mistletoe.gif\"]', 300, 0, 4, 10, 0),
(385, 83, 1, 'Yellow-Christmas Seal', '19.99', '2.00', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', '[\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\",\"altar-piece.gif\"]', 300, 0, 4, 10, 0),
(386, 84, 1, 'Yellow-Weather Vane', '15.95', '0.96', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', '[\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\",\"the-three-wise-men.gif\"]', 300, 0, 4, 10, 0),
(387, 85, 1, 'Yellow-Mistletoe', '19.00', '1.01', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', '[\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\",\"christmas-tree.gif\"]', 300, 0, 4, 10, 0),
(388, 86, 1, 'Yellow-Altar Piece', '20.50', '2.00', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', '[\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\",\"madonna-child.gif\"]', 300, 0, 4, 10, 0),
(389, 87, 1, 'Yellow-The Three Wise Men', '12.99', '0.00', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', '[\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\",\"the-virgin-mary.gif\"]', 300, 0, 4, 10, 0),
(390, 88, 1, 'Yellow-Christmas Tree', '20.00', '2.05', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', '[\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\",\"adoration-of-the-kings.gif\"]', 300, 0, 4, 10, 0),
(391, 89, 1, 'Yellow-Madonna & Child', '21.95', '3.45', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', '[\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\",\"a-partridge-in-a-pear-tree.gif\"]', 300, 0, 4, 10, 0),
(392, 90, 1, 'Yellow-The Virgin Mary', '16.95', '1.00', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', '[\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\",\"st-lucy.gif\"]', 300, 0, 4, 10, 0),
(393, 91, 1, 'Yellow-Adoration of the Kings', '17.50', '1.00', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', '[\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\",\"st-lucia.gif\"]', 300, 0, 4, 10, 0),
(394, 92, 1, 'Yellow-A Partridge in a Pear Tree', '14.99', '0.00', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', '[\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\",\"swede-santa.gif\"]', 300, 0, 4, 10, 0),
(395, 93, 1, 'Yellow-St. Lucy', '18.95', '0.00', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', '[\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\",\"wreath.gif\"]', 300, 0, 4, 10, 0),
(396, 94, 1, 'Yellow-St. Lucia', '19.00', '1.05', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', '[\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\",\"love.gif\"]', 300, 0, 4, 10, 0),
(397, 95, 1, 'Yellow-Swede Santa', '21.00', '2.50', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', '[\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\",\"birds.gif\"]', 300, 0, 4, 10, 0),
(398, 96, 1, 'Yellow-Wreath', '18.99', '2.00', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', '[\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\",\"kat-over-new-moon.gif\"]', 300, 0, 4, 10, 0),
(399, 97, 1, 'Yellow-Love', '19.00', '1.50', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', '[\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\",\"thrilling-love.gif\"]', 300, 0, 4, 10, 0),
(400, 98, 1, 'Yellow-Birds', '21.00', '2.05', '[\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\"]', '[\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\"]', '[\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\"]', '[\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\",\"the-rapture-of-psyche.gif\"]', 300, 0, 4, 10, 0),
(401, 99, 1, 'Yellow-Kat Over New Moon', '14.99', '0.00', '[]', '[]', '[]', '[]', 0, 0, 0, 0, 0),
(402, 100, 1, 'Yellow-Thrilling Love', '21.00', '2.50', '[\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\']', '[\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\']', '[\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\']', '[\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\',\'chartres-cathedral.gif\']', 0, 0, 0, 0, 0),
(403, 101, 1, 'black t-shirt', '700.00', '5.00', '[\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559637176167.jpg\"]', '[\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559637176167.jpg\"]', '[\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559637176167.jpg\"]', '[\"11518436768150-na-2011518436767958-2 (1).jpg-1559568864293.jpg-1559637176167.jpg\"]', 88, 1, 2, 7, 0),
(404, 101, 1, 'black t-shirt in color', '70.00', '0.00', '[]', '[]', '[]', '[]', 40, 0, 3, 7, 0);

-- --------------------------------------------------------

--
-- Table structure for table `refund`
--

DROP TABLE IF EXISTS `refund`;
CREATE TABLE IF NOT EXISTS `refund` (
  `refund_id` int(11) NOT NULL AUTO_INCREMENT,
  `return_id` int(11) NOT NULL,
  `auth_code` text NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `refund_date` datetime NOT NULL,
  `customer_id` int(11) NOT NULL,
  PRIMARY KEY (`refund_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
CREATE TABLE IF NOT EXISTS `review` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `review` text NOT NULL,
  `rating` smallint(6) NOT NULL,
  `created_on` datetime NOT NULL,
  PRIMARY KEY (`review_id`),
  KEY `idx_review_customer_id` (`customer_id`),
  KEY `idx_review_product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `shipping`
--

DROP TABLE IF EXISTS `shipping`;
CREATE TABLE IF NOT EXISTS `shipping` (
  `shipping_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipping_type` varchar(100) NOT NULL,
  `shipping_cost` decimal(10,2) NOT NULL,
  `shipping_region_id` int(11) NOT NULL,
  `days` int(11) NOT NULL,
  PRIMARY KEY (`shipping_id`),
  KEY `idx_shipping_shipping_region_id` (`shipping_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shipping`
--

INSERT INTO `shipping` (`shipping_id`, `shipping_type`, `shipping_cost`, `shipping_region_id`, `days`) VALUES
(1, 'Next Day Delivery ($20)', '20.00', 2, 1),
(2, '3-4 Days ($10)', '10.00', 2, 4),
(3, '7 Days ($5)', '5.00', 2, 7),
(4, 'By air (7 days, $25)', '25.00', 3, 7),
(5, 'By sea (28 days, $10)', '10.00', 3, 28),
(6, 'By air (10 days, $35)', '35.00', 4, 10),
(7, 'By sea (28 days, $30)', '30.00', 4, 28);

-- --------------------------------------------------------

--
-- Table structure for table `shipping_region`
--

DROP TABLE IF EXISTS `shipping_region`;
CREATE TABLE IF NOT EXISTS `shipping_region` (
  `shipping_region_id` int(11) NOT NULL AUTO_INCREMENT,
  `shipping_region` varchar(100) NOT NULL,
  PRIMARY KEY (`shipping_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shipping_region`
--

INSERT INTO `shipping_region` (`shipping_region_id`, `shipping_region`) VALUES
(1, 'Please Select'),
(2, 'US / Canada'),
(3, 'Europe'),
(4, 'Rest of World');

-- --------------------------------------------------------

--
-- Table structure for table `shopping_cart`
--

DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE IF NOT EXISTS `shopping_cart` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `cart_id` char(32) NOT NULL,
  `product_variant_id` int(11) NOT NULL,
  `attributes` varchar(1000) NOT NULL,
  `quantity` int(11) NOT NULL,
  `buy_now` tinyint(1) NOT NULL DEFAULT '1',
  `added_on` datetime NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_shopping_cart_cart_id` (`cart_id`)
) ENGINE=MyISAM AUTO_INCREMENT=175 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shopping_cart`
--

INSERT INTO `shopping_cart` (`item_id`, `cart_id`, `product_variant_id`, `attributes`, `quantity`, `buy_now`, `added_on`) VALUES
(149, '25', 323, '{\"Size\":\"XL\",\"Color\":\"Yellow\"}', 1, 1, '2019-05-15 12:30:19'),
(150, '25', 209, '{\"Size\":\"XXL\",\"Color\":\"Yellow\"}', 1, 1, '2019-05-16 06:34:16'),
(151, '25', 310, '{\"Size\":\"XL\",\"Color\":\"Yellow\"}', 1, 1, '2019-05-16 06:34:19'),
(152, '24', 103, '{\"Size\":\"XXL\",\"Color\":\"Red\"}', 1, 1, '2019-05-17 11:25:26');

-- --------------------------------------------------------

--
-- Table structure for table `specification_attributes`
--

DROP TABLE IF EXISTS `specification_attributes`;
CREATE TABLE IF NOT EXISTS `specification_attributes` (
  `attribute_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `multi_select` tinyint(1) NOT NULL,
  PRIMARY KEY (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `specification_attributes_value`
--

DROP TABLE IF EXISTS `specification_attributes_value`;
CREATE TABLE IF NOT EXISTS `specification_attributes_value` (
  `attribute_value_id` int(11) NOT NULL AUTO_INCREMENT,
  `attribute_id` int(11) NOT NULL,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`attribute_value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `status_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  PRIMARY KEY (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`status_id`, `name`) VALUES
(1, 'Received by seller'),
(2, 'Order Placed'),
(3, 'Ready to dispatch'),
(4, 'Dispatched'),
(5, 'Delivered Today');

-- --------------------------------------------------------

--
-- Table structure for table `tax`
--

DROP TABLE IF EXISTS `tax`;
CREATE TABLE IF NOT EXISTS `tax` (
  `tax_id` int(11) NOT NULL AUTO_INCREMENT,
  `tax_type` varchar(100) NOT NULL,
  `tax_percentage` decimal(10,2) NOT NULL,
  PRIMARY KEY (`tax_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tax`
--

INSERT INTO `tax` (`tax_id`, `tax_type`, `tax_percentage`) VALUES
(1, 'Sales Tax at 8.5%', '8.50'),
(2, 'No Tax', '0.00');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(300) NOT NULL,
  `business_name` varchar(50) NOT NULL,
  `gstin` varchar(15) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(30) NOT NULL,
  `state` varchar(30) NOT NULL,
  `country` varchar(30) NOT NULL,
  `business_phone` varchar(13) NOT NULL,
  `mobile` varchar(13) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `name`, `email`, `password`, `business_name`, `gstin`, `address`, `city`, `state`, `country`, `business_phone`, `mobile`) VALUES
(1, 'Parth', 'admin@admin.com', '$2b$10$u6PR4hNutVdHA03hYVfeYul1ficfsMQe.wLMkf74LwgN8TPPQUlrW', 'T-Shirt Shop', '24adduup12154sh', '18,abc industrial society,120 feet s.v. patel road,surat', 'Surat', 'Gujarat', 'India', '02612575858', '9737566363');

-- --------------------------------------------------------

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
CREATE TABLE IF NOT EXISTS `wishlist` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `wishlist_id` char(32) NOT NULL,
  `product_variant_id` int(11) NOT NULL,
  `attributes` varchar(1000) NOT NULL,
  `quantity` int(11) NOT NULL,
  `added_on` datetime NOT NULL,
  `buy_now` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`item_id`),
  KEY `idx_wishlist_wishlist_id` (`wishlist_id`)
) ENGINE=MyISAM AUTO_INCREMENT=57 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `wishlist`
--

INSERT INTO `wishlist` (`item_id`, `wishlist_id`, `product_variant_id`, `attributes`, `quantity`, `added_on`, `buy_now`) VALUES
(24, '24', 4, '', 1, '2019-04-30 13:21:01', 1),
(46, '24', 3, '{\"Size\":\"L\",\"Color\":\"Red\"}', 1, '0000-00-00 00:00:00', 1),
(31, '24', 5, '{\"Size\":\"XL\",\"Color\":\"White\"}', 1, '0000-00-00 00:00:00', 1),
(48, '26', 317, '{\"Size\":\"XL\",\"Color\":\"Yellow\"}', 1, '0000-00-00 00:00:00', 1),
(49, '25', 323, '', 1, '2019-05-15 10:40:27', 1),
(51, '25', 112, '{\"Size\":\"XXL\",\"Color\":\"Red\"}', 1, '0000-00-00 00:00:00', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `product`
--
ALTER TABLE `product` ADD FULLTEXT KEY `idx_ft_product_name_description` (`description`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
