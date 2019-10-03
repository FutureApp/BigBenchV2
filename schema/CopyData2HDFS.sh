home_dataset="/bigbenchv2/data"
hadoop fs -mkdir -p /bigbenchv2/data/customers
hadoop fs -put $home_dataset/customers.tbl /bigbenchv2/data/customers

hadoop fs -mkdir -p /bigbenchv2/data/items
hadoop fs -put $home_dataset/items.tbl /bigbenchv2/data/items

hadoop fs -mkdir -p /bigbenchv2/data/reviews
hadoop fs -put $home_dataset/product_reviews.tbl /bigbenchv2/data/product_reviews

hadoop fs -mkdir -p /bigbenchv2/data/web_pages
hadoop fs -put $home_dataset/web_pages.tbl /bigbenchv2/data/web_pages

hadoop fs -mkdir -p /bigbenchv2/data/web_sales
hadoop fs -put $home_dataset/web_sales.tbl /bigbenchv2/data/web_sales

hadoop fs -mkdir -p /bigbenchv2/data/store_sales
hadoop fs -put $home_dataset/store_sales.tbl /bigbenchv2/data/store_sales

hadoop fs -mkdir -p /bigbenchv2/data/stores
hadoop fs -put $home_dataset/stores.tbl /bigbenchv2/data/stores

hadoop fs -mkdir -p /bigbenchv2/data/web_logs
hadoop fs -put $home_dataset/clicks.json /bigbenchv2/data/web_logs

#--hadoop fs -mkdir -p /bigbenchv2/data/test
#--hadoop fs -put $home_dataset/test.json /bigbenchv2/data/test
#
#
#--hadoop fs -mkdir -p /bigbenchv2/data/static_web_logs
#--hadoop fs -put $home_dataset/clicks.tbl /bigbenchv2/data/static_web_logs