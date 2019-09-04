//Code source: https://medium.com/@nitingupta.bciit/hello-world-with-apache-spark-sql-f7df76d285e3


import org.apache.spark.sql.SparkSession

// Create spark session
val spark = SparkSession.builder().appName("Spark SQL basic example").config("spark.master", "local").getOrCreate()

// Import implicit encoders
import spark.implicits._
case class Zip(_id:String, city:String, loc:Array[Double], pop:Long, state:String)
val ds = spark.read.json("hdfs:///inputs/zips.json").as[Zip]
// Create temporary sql view with name of zip
ds.createOrReplaceTempView("zip")

// Rename column name _id to zip in the temporary view
spark.table("zip").withColumnRenamed("_id","zip").createOrReplaceTempView("zip")

// Prepare a Spark query to find the most populous cities in state "Illinous" and with number of postcodes
val ds_sql = spark.sql("SELECT COUNT(zip), SUM(pop), city from zip where state='IL' " +
"GROUP BY city " +
"ORDER BY SUM(pop) DESC " +
"LIMIT 10")

// Print the schema
ds_sql.printSchema()
// Print the data
ds_sql.show()

//expected result
/*
|+----------+--------+----------------+
||count(zip)|sum(pop)|            city|
|+----------+--------+----------------+
||        47| 2452177|         CHICAGO|
||         8|  167031|        ROCKFORD|
||         3|  111365|     LINCOLNWOOD|
||         3|  109392|          AURORA|
||         4|  103004|      NAPERVILLE|
||         3|   87425|      BELLEVILLE|
||         2|   86683|           ELGIN|
||         5|   79982|          PEORIA|
||         2|   79689|ARLINGTON HEIGHT|
||         3|   77965|        EVANSTON|
|+----------+--------+----------------+
*/