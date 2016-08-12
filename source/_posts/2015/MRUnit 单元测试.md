----
title: MRUnit 单元测试
date: 2015-03-27 23:44:00
updated:
categories: 
- Distributed Development
- Hadoop
tags:
- Hadoop
----

**MRUnit 单元测试**
MapReduce的map和reduce函数很容易测试,这是由于其功能的风格。MRUnit是一个测试库，便于通过已知的输入到Map或Reudce检测其输出结果符合预期。
MRUnit结合使用一个标准的测试执行框架，如：JUnit，所以你可以运行MapReduce测试作业作为一个正常的开发环境的一部分。

**权威指南  单元测试实例 **

通过天气数据集输入（input）到mapper，检测输出（output）年和温度 

```
import java.io.IOException;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mrunit.mapreduce.MapDriver;
import org.junit.*;

public class MaxTemperatureMapperTest {

  @Test
  public void processesValidRecord() throws IOException, InterruptedException {
    Text value = new Text("0043011990999991950051518004+68750+023550FM-12+0382" +
                                  // Year ^^^^
        "99999V0203201N00261220001CN9999999N9-00111+99999999999");
                              // Temperature ^^^^^
    /**
     *    因为我们正在测试Mapper,所以使用MRUnit的MapDriver,
     *    1、设置Mapper的受检对象
     *    2、设置input key和value
     *    3、设置预期的output key(这里是是Text代表年,1950) 和value(IntWritable 代表温度,-1.1℃)
     *    4、最后调用runTest()方法执行测试。
     */ 
    new MapDriver<LongWritable, Text, Text, IntWritable>()
      .withMapper(new MaxTemperatureMapper())
      .withInput(new LongWritable(0), value)
      .withOutput(new Text("1950"), new IntWritable(-11))
      .runTest();
  }  
}
```

如下将是一个fail的例子

```
  /**
   * 这将是一个失败的例子：
   * 从行中抽取年份和气温，在Context输出，由于我们添加一个缺失值的测试，该值在原始的数据中表示气温+9999；
   *  
   *  MapDriver 可以依据withOutput()的次数检查有零个、 一个或更多的输出记录，
   *  在这个例子中，由于缺少气温记录已经被过滤掉。
   *  parseInt 不能正常解析，所以抛出NumberFormatException异常
   * 
   */
  @Test
  public void ignoresMissingTemperatureRecord() throws IOException,
      InterruptedException {
    Text value = new Text("0043011990999991950051518004+68750+023550FM-12+0382" +
                                  // Year ^^^^
        "99999V0203201N00261220001CN9999999N9+99991+99999999999");
                              // Temperature ^^^^^
    new MapDriver<LongWritable, Text, Text, IntWritable>()
      .withMapper(new MaxTemperatureMapper())
      .withInput(new LongWritable(0), value)
      .runTest();
  }  
```

上述测试是失败的，因为+9999是一个特例，所以不应该把更多的逻辑代码放到Mapper，更有意义的是使用一个解析器来封装解析逻辑。
优点：
    1、重复使用，很容易编写与Mapper相似的工作
    2、提高针对测试，我们可以为解析器编写单元测试，从而更好的测试MR。
```
public class NcdcRecordParser {
      
      private static final int MISSING_TEMPERATURE = 9999;
      
      private String year;
      private int airTemperature;
      private String quality;
      
      public void parse(String record) {
        year = record.substring(15, 19);
        String airTemperatureString;
        // Remove leading plus sign as parseInt doesn't like them (pre-Java 7)
        if (record.charAt(87) == '+') { 
          airTemperatureString = record.substring(88, 92);
        } else {
          airTemperatureString = record.substring(87, 92);
        }
        airTemperature = Integer.parseInt(airTemperatureString);
        quality = record.substring(92, 93);
      }
      /*
       * 直接解析字段
       */
      public void parse(Text record) {
        parse(record.toString());
      }
      /*
       * 检查温度是否有效
       */
      public boolean isValidTemperature() {
        return airTemperature != MISSING_TEMPERATURE && quality.matches("[01459]");
      }
      
      public String getYear() {
        return year;
      }
      public int getAirTemperature() {
        return airTemperature;
      }
    }  

```
MaxTemperatureMapper使用解析器对字段进行解析,然后重写执行之前fail的测试，它将是成功的。

```
public class MaxTemperatureMapper
    extends Mapper<LongWritable, Text, Text, IntWritable> {

  private NcdcRecordParser parser = new NcdcRecordParser();

  @Override
  public void map(LongWritable key, Text value, Context context)
      throws IOException, InterruptedException {

    parser.parse(value);
    if (parser.isValidTemperature()) {
      context.write(new Text(parser.getYear()),
          new IntWritable(parser.getAirTemperature()));
    }
  }
}

```


Reducer 测试
使用ReduceDriver，Reducer 输出一个最大值

```
 @Test
  public void returnsMaximumIntegerInValues() throws IOException,
      InterruptedException {
    new ReduceDriver<Text, IntWritable, Text, IntWritable>()
      .withReducer(new MaxTemperatureReducer())
      .withInput(new Text("1950"), Arrays.asList(new IntWritable(10), new IntWritable(5)))
      .withOutput(new Text("1950"), new IntWritable(10))
      .runTest();
    }
```