USE DATABASE ECOMMERCE_OLIST;
USE SCHEMA RAW;
USE WAREHOUSE WH_OLIST;

ALTER TABLE RAW_PRODUCT_CATEGORY_NAME_TRANSLATION
ADD CATEGORY_GROUP STRING ;

SELECT * FROM RAW_PRODUCT_CATEGORY_NAME_TRANSLATION;

UPDATE RAW_PRODUCT_CATEGORY_NAME_TRANSLATION
SET CATEGORY_GROUP = 
    CASE
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('health_beauty', 'perfumery') THEN 'cosmetics'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('computers_accessories', 'telephony', 'tablets_printing_image', 'fixed_telephony', 'audio', 'air_conditioning', 'electronics', 'dvds_blu_ray') THEN 'tech'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('bed_bath_table', 'furniture_decor', 'housewares', 'kitchen_dining_laundry_garden_furniture', 'office_furniture', 'home_appliances', 'home_confort', 'furniture_mattress_and_upholstery', 'furniture_living_room', 'furniture_bedroom', 'computers', 'home_appliances_2', 'la_cuisine', 'home_comfort_2', 'small_appliances_home_oven_and_coffee') THEN 'house_furniture'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('stationery', 'garden_tools', 'construction_tools_construction', 'costruction_tools_garden', 'costruction_tools_tools', 'construction_tools_lights', 'construction_tools_safety', 'arts_and_craftmanship', 'home_construction') THEN 'diy'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('sports_leisure', 'toys', 'consoles_games', 'books_technical', 'musical_instruments', 'art', 'books_general_interest', 'books_imported', 'cine_photo', 'music', 'cds_dvds_musicals') THEN 'hobbies'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('watches_gifts', 'fashion_bags_accessories', 'fashion_shoes', 'fashion_male_clothing', 'fashion_underwear_beach', 'fashion_sport', 'fashio_female_clothing', 'fashion_childrens_clothes') THEN 'fashion_accessories'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('food_drink', 'food', 'drinks') THEN 'food_and_drink'
        WHEN PRODUCT_CATEGORY_NAME_ENGLISH IN ('pet_shop') THEN 'animal'
        ELSE 'misc'
    END;
        