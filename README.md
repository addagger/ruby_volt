# RubyVolt

### VoltDB Wire Protocol Client for Ruby programming language

#### Pure Ruby client for VoltDB - one of the fastest in-memory databases on the planet. Threadsafe and fast enough wire client implementation

Protocol Version 1 (01/26/2016).

## Reference docs

* [Welcome to VoltDB. A Tutorial](http://downloads.voltdb.com/documentation/tutorial.pdf)
* [VoltDB Client Wire Protocol](http://downloads.voltdb.com/documentation/wireprotocol.pdf)
* [Using VoltDB](http://downloads.voltdb.com/documentation/UsingVoltDB.pdf)
* [VoltDB Guide to Performance and Customization](http://downloads.voltdb.com/documentation/PerfGuide.pdf)

## Compatibility

Compatible with Ruby **MRI 2.5**> & **JRuby 9.2**>

Previous versions can be supported easily, and you can do it yourself forking this code. However, performance *will probably drop* with previous versions or Ruby, which is essential, since we are dealing with a really fast database! On my laptop VoltDB responds 2-5 times faster than Ruby can dispatch the response within one process and few threads.

## Installation

    $ gem install ruby_volt

## Initialize

Require gem:

    require 'ruby_volt'

Init the client with options:

    voltdb = RubyVolt::Base.new(options)
    
Where *options* is a Hash with keys:
    
    :cluster - Hash, Array, String of VoltDB cluster:
             - String URI: 1 connection to "your.server" or "your.server:21212" or "user:password@your.server:21212",
             - Array of Strings: 1 connection per server ["first.server", "second.server:21213", "user@third.server"],
             - Hash: where keys are Strings and values are numbers of connections to particular servers {"first.server" => 2, "second_server:21213" => 1}
             - Nil: if option is not defined then 1 connection to 'localhost' with default port 21212.
    
    :username - default username for connection(s) if needed,
    :password - default password for connection(s) if needed,
    :connections - target number of connections to be enquired, if needed more than 1 by default,
    :servicename - 'database' by default (see VoltDB documentation),
    :connect_timeout - timeout (secs) for authentication, 8 by default, 
    :procedure_timeout - timeout (secs) for procedure call, 8 by default,
    :login_protocol - VoltDB Client Wire Protocol version for authentication process, 1 by default,
    :procedure_protocol - VoltDB Client Wire Protocol version for procedure invocation, 0 by default,

General example:

    voltdb = RubyVolt::Base.new(:username => "username", :password => "secret") # established 1 connection to 'localhost@21212'
    => #<RubyVolt::Base:0x00007fb24f151388 @login_protocol=1, @procedure_protocol=0, @servicename="database", @connect_timeout=8, @procedure_timeout=8, @requests_queue=#<Thread::Queue:0x00007fb24f151360>, @connection_pool=[#<RubyVolt::Connection [localhost:21212]: server_host_id=0 connection_id=181 login_protocol=1 procedure_protocol=0>]> 

## Usage

A client connection to a VoltDB instance consists of a TCP connection on port 21212. After the initial login process the only exchange between the client library and the VoltDB server is the invocation of and response to stored procedures.

In other words, *calling stored procedures is the only function* of VoltDB Client Wire Protocol at the moment.

For development and testing purposes I created one table named **_datatypes_** consists of all types of data VoltDB operates with and one stored procedure called **_datatypes_** which just fetch few rows from that table:

    CREATE TABLE datatypes (
       t_byte TINYINT,
       t_short SMALLINT,
       t_integer INTEGER,
       t_long BIGINT,
       t_float FLOAT,
       t_string VARCHAR,
       t_timestamp TIMESTAMP,
       t_decimal DECIMAL,
       t_varbinary VARBINARY,
       t_geopoint GEOGRAPHY_POINT,
       t_polygon GEOGRAPHY
    );
    
    CREATE PROCEDURE datatypes
      AS SELECT *
         FROM datatypes;
         
So, calling procedure looks like that:

    voltdb.call_procedure("datatypes")
    => #<RubyVolt::InvocationResponse:0x00007fb2501191d0 @bytes=<RubyVolt::ReadPartial: bytes=0>, @data={:protocol=>0, :client_data=>"\eX\xE2\x90\xDFa*\x82", :present_fields=>0, :status=>RubyVolt::SuccessStatusCode, :app_status=>nil, :cluster_round_trip_time=>0}, @result=[#<RubyVolt::VoltTable index=0 total_table_length=1846 total_metadata_length=151 rows=5>]> 
    
You've got the RubyVolt::InvocationResponse object having some datasets like metadata:
    
    voltdb.call_procedure("datatypes").data # Metadata around calling procedure
    => {:protocol=>0, :client_data=>"4q#\xF0S\x8E\x83u", :present_fields=>0, :status=>RubyVolt::SuccessStatusCode, :app_status=>nil, :cluster_round_trip_time=>0}
  
Also it has invocation result itself consists of VoltTable sets:

Read [Using VoltDB documentation](http://downloads.voltdb.com/documentation/UsingVoltDB.pdf) explaining why we have an array of VoltTables. In our case we have just one VoltTable.
  
    voltdb.call_procedure("datatypes").result
    => [#<RubyVolt::VoltTable index=0 total_table_length=1846 total_metadata_length=151 rows=5>]
    
Each VoltTable has array of rows, we've got *5 rows*:

    voltdb.call_procedure("datatypes").result[0].rows
     => [#<struct T_BYTE=1, T_SHORT=23, T_INTEGER=19948544, T_LONG=123456789101, T_FLOAT=-23325.23425, T_STRING="Madagaskar", T_TIMESTAMP=2018-12-27 03:00:00 +0300, T_DECIMAL=-0.2332523425e5, T_VARBINARY="", T_GEOPOINT=POINT(-109.8223383 34.9766921), T_POLYGON=POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))>, #<struct T_BYTE=1, T_SHORT=23, T_INTEGER=19948544, T_LONG=123456789101, T_FLOAT=-23325.23425, T_STRING="Madagaskar", T_TIMESTAMP=2018-12-27 03:00:00 +0300, T_DECIMAL=-0.2332523425e5, T_VARBINARY=nil, T_GEOPOINT=POINT(-109.8223383 34.9766921), T_POLYGON=POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))>, #<struct T_BYTE=1, T_SHORT=23, T_INTEGER=19948544, T_LONG=123456789101, T_FLOAT=-23325.23425, T_STRING="", T_TIMESTAMP=2019-12-27 03:00:00 +0300, T_DECIMAL=-0.2322522425e5, T_VARBINARY=nil, T_GEOPOINT=POINT(-110.8223383 35.4766421), T_POLYGON=POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))>, #<struct T_BYTE=1, T_SHORT=23, T_INTEGER=19948544, T_LONG=123456789101, T_FLOAT=-23325.23425, T_STRING=nil, T_TIMESTAMP=2019-12-27 03:00:00 +0300, T_DECIMAL=-0.2322522425e5, T_VARBINARY=nil, T_GEOPOINT=POINT(-110.8223383 35.4766421), T_POLYGON=POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))>, #<struct T_BYTE=nil, T_SHORT=nil, T_INTEGER=nil, T_LONG=nil, T_FLOAT=nil, T_STRING=nil, T_TIMESTAMP=nil, T_DECIMAL=nil, T_VARBINARY=nil, T_GEOPOINT=nil, T_POLYGON=nil>]

Each row represented as instance of Ruby's Struct class, having attributes according to column names (case sensitive):
    
    voltdb.call_procedure("datatypes").result[0].rows[3]
    => #<struct T_BYTE=1, T_SHORT=23, T_INTEGER=19948544, T_LONG=123456789101, T_FLOAT=-23325.23425, T_STRING=nil, T_TIMESTAMP=2019-12-27 03:00:00 +0300, T_DECIMAL=-0.2322522425e5, T_VARBINARY=nil, T_GEOPOINT=POINT(-110.8223383 35.4766421), T_POLYGON=POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))> 
    
    voltdb.call_procedure("datatypes").result[0].rows[3].T_FLOAT
    => -23325.23425    

## Calling procedures with blocks

For deeper integration of the received data, you can send block with calling procedure method, which will allow to obtain data before VoltTable is formed and row is still an *Array* object. So you can just skip some internal operations transforming *Array row* to *Struct row*:

    voltdb.call_procedure("datatypes") do |data, volttable, row|
      puts volttable.columns.inspect # Do something with columns info
      puts row.inspect # Do something extra with your data here ...
    end
    => #<RubyVolt::InvocationResponse:0x00007fb250141950 @bytes=<RubyVolt::ReadPartial: bytes=0>, @data={:protocol=>0, :client_data=>"1\x11\xEB\x90\xFFS~\x89", :present_fields=>0, :status=>RubyVolt::SuccessStatusCode, :app_status=>nil, :cluster_round_trip_time=>0}, @result=[#<RubyVolt::VoltTable index=0 total_table_length=1846 total_metadata_length=151 rows=0>]>    
    
In previous example note that VoltTable's rows are empty (rows=0), but you can reproduce the standard functionality, using *add_struct()* method:

    voltdb.call_procedure("datatypes") do |data, volttable, row|
      volttable.add_struct(row)
    end
    => #<RubyVolt::InvocationResponse:0x00007fb250851510 @bytes=<RubyVolt::ReadPartial: bytes=0>, @data={:protocol=>0, :client_data=>"\x01-\xD9p\xBE\xA0H\xEA", :present_fields=>0, :status=>RubyVolt::SuccessStatusCode, :app_status=>nil, :cluster_round_trip_time=>0}, @result=[#<RubyVolt::VoltTable index=0 total_table_length=1846 total_metadata_length=151 rows=5>]>

## Сalling procedures Async

Frankly speaking, each invocation made *asynchronous* in nature. The difference is that *synchronous* call waits until data has been read.
But you can split *invocation* and *reading* in timeline, although you can read data just once!
    
    async_call = voltdb.async_call_procedure("datatypes")
    => #<RubyVolt::Base::AsyncCall ready=false>

... some other stuff ... time spending ...

    async_call.dispatch # You can read data just ONCE!
    => #<RubyVolt::InvocationResponse:0x00007fb2500fdcf0 @bytes=<RubyVolt::ReadPartial: bytes=0>, @data={:protocol=>0, :client_data=>"\x04\xB7\xE2\xC0 <*w", :present_fields=>0, :status=>RubyVolt::SuccessStatusCode, :app_status=>nil, :cluster_round_trip_time=>0}, @result=[#<RubyVolt::VoltTable index=0 total_table_length=1846 total_metadata_length=151 rows=5>]>

As soon as you read the data, they are erased from the buffer.
You can operate with the result as described before, using blocks as well.

## Passing parameters

See [Using VoltDB docs](http://downloads.voltdb.com/documentation/UsingVoltDB.pdf) how to create stored procedures. Let's say we have procedure named *leastpopulated* which accepts one integer parameter. Pass the parameter next to procedure name:

    voltdb.call_procedure("leastpopulated", 3)

In general, you can pass any type of parameter data as method's argument next to procedure name.

RubyVolt converts Ruby datatypes and VoltDB datatypes vice-versa:

* Ruby's **Integer** (depends on bit length) - to VoltDB's *Byte*, *Short*, *Integer*, or *Long*
* Ruby's **Float** - to VoltDB's *Float*
* Ruby's **String** (depends on encoding) - to VoltDB's *Varbinary* or *String*
* Ruby's **BigDecimal** - to VoltDB's *Decimal*
* Ruby's **Time** - to VoltDB's *Timestamp*
* Ruby's **Array** - to VoltDB's *Array*

Two datatypes implemented additionaly, according to the protocol specifications and WKT:

* **RubyVolt::Meta::Geography::Point** - to VoltDB's *GeographyPointValue*
* **RubyVolt::Meta::Geography::Polygon** - to VoltDB's *GeographyValue*

See detailed description of these datatypes in [VoltDB Guide to Performance and Customization](http://downloads.voltdb.com/documentation/PerfGuide.pdf) (chapter 6.1. The Geospatial Datatypes).

### Passing Arrays

VoltDB Array is a single datatype set, so in Ruby you have to specify datatype as the first element:

    voltdb.call_procedure("any_other_procedure", [RubyVolt::DataType::Byte, 1,2,3,4,5])

or

    voltdb.call_procedure("any_other_procedure", [:Byte, 1,2,3,4,5])

or

    voltdb.call_procedure("any_other_procedure", ["Byte", 1,2,3,4,5])

or let RubyVolt recognize it

    voltdb.call_procedure("any_other_procedure", [1,2,3,4,5])
    
##  Geospatial Data

VoltDB has two data structures for geospatial data:

* *GeographyPointValue* represent coordinates
* *GeographyValue* represents polygons

And official documentation says:
*"It should be noted that, although a description of the GeographyPointValue/GeographyValue structure is being provided here for completeness, in most cases the client interface does not need to interpret the structure. Generally the client passes the point representation unchanged between the server and the client application.*

However, for completeness, RubyVolt provides a classes for such structures.

### RubyVolt::Meta::Geography::Point

This class accepts two arguments: *longitude* and *latitude*

    point = RubyVolt::Meta::Geography::Point.new(lng, lat)
    
But in the wire protocol a point is represented by a three dimensional point on the unit sphere. These three dimensional points are called XYZPoints. Each dimension is a double precision IEEE floating point number. The Euclidean length of each XYZPoint must be 1.0.

    xyz_point = RubyVolt::Meta::Geography::Point.from_XYZPoint(x, y, z) # ex. 1.000000, 0.000000, 0.000000

### RubyVolt::Meta::Geography::Polygon

Polygon has Rings,
Rings has Points,
Points are represented in XYZ format.

For example, we have set of eight points:

    p1 = RubyVolt::Meta::Geography::Point.from_XYZPoint 1.000000, 0.000000, 0.000000
    p2 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999848, 0.017452, 0.000000
    p3 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999695, 0.017450, 0.017452
    p4 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999848, 0.000000, 0.017452
    p5 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999997, 0.001745, 0.001745
    p6 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999875, 0.001745, 0.015707
    p7 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999753, 0.015705, 0.015707
    p8 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999875, 0.015707, 0.001745

Now we create the *ring1* from points *p1..p4*:

    ring1 = RubyVolt::Meta::Geography::Ring.new # can accept array o points as argument
    ring1.add_point(p1)
    ring1.add_point(p2)
    ring1.add_point(p3)
    ring1.add_point(p4)

Next we create the *ring2* from points *p5..p8*:

    ring2 = RubyVolt::Meta::Geography::Ring.new # can accept array o points as argument
    ring2.add_point(p5)
    ring2.add_point(p6)
    ring2.add_point(p7)
    ring2.add_point(p8)

Having two *rings* let's create polygon object from them:
 
    polygon = RubyVolt::Meta::Geography::Polygon.new
    polygon.add_ring(ring1)
    polygon.add_ring(ring2)

Now we can operate with Polygon object within our environment. These objects (*Polygon* and/or *Point*) can be used as procedure parameters as well.
When we read geospatial data from the database, RubyVolt represents the same data structures for us.

    voltdb.call_procedure("datatypes").result[0].rows[3].T_GEOPOINT
    => POINT(-110.8223383 35.4766421) # RubyVolt::Meta::Geography::Point object
    
    voltdb.call_procedure("datatypes").result[0].rows[3].T_POLYGON
    => POLYGON((0.0 0.0, 1.0 0.0, 1.0 1.0, 0.0 1.0, 0.0 0.0), (0.1 0.1, 0.1 0.9, 0.9 0.9, 0.9 0.1, 0.1 0.1))

##  Ping and Benchmark

Ping the connection:

    voltdb.ping # invoke system @Ping procedure

To look how fast your connection is on minimal dataset:

    voltdb.benchmark(100000) # pings 100k times 

Same methods *ping()* and *benchmark()* can be run for particular connection from the pool (if you have few of them):

    voltdb.connection_pool[1].ping
    voltdb.connection_pool[1].benchmark(100000)
    
##  Perfomance

As said before, VoltDB responds 2-5 times faster than Ruby can dispatch the result (depends on particular data structures), so in fact Ruby is a bottleneck.

By the way, RubyVolt is a threadsafe and only 1 thread serves 1 connection (1 thread/per connection) by default. My tests show that there is no need to parallelize (*forking process*) or artificially increase the number of threads per connection, because the specific application in the real-world environment, for example **Puma** or **Unicorn**, will do it best of all.

Therefore, in multi-threading or multi-processing environment you can squeeze maximum performance you can. Within the MRI environment, multi-threading adds little to performance (~ 20% first 2 threads) due to GIL limitations, but multiprocessing (forking) makes it much better.

However, multi-threading *JRuby performance* due to the use of all CPU cores in real time, is approximately two times higher than in MRI.