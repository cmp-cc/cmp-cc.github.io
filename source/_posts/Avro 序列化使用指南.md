----
title: Avro 序列化使用指南
date: 2015-01-17 22:53:00
updated:
categories: 
- Distributed Development
- Hadoop

tags:
- Avro
----
### 序
尽可能的避免一些理论知识，以实例为主，快速的使用Avro。

### Avro
Avro是一个独立于编程语言的数据序列化系统，当前可被（C、C++、Java、Pthon、Ruby）语言处理数据格式，允许与其他编程语言进行数据读写操作。
Avro数据是用语言无关的模式定义的，且Avro的代码生成是可选的，这味着你可以对遵守指定模式的数据进行读写操作。

Avro模式通常是使用JSON编写，数据文件通常是二进制编码（可选）。

###Avro基础知识： 数据类型和模式

#### 基本数据类型与复杂数据类型
Avro 定义了少数的数据类型。


**  Avro 8种基本类型 **


** 6种复杂数据类型 **


#### 两种模式(我的个人认为)
Avro 模式:
Avro的模式文件（映射文件），扩展名为.avsc ,通常使用JSON编写。
如下 Avro模式文件 StringPair.avsc
```
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings.",
  "fields": [
    {"name": "left", "type": "string"},
    {"name": "right", "type": "string"}
  ]
}
```
数据 模式 ，通常是二进制编码，用户存储对象数据。 扩展名为.avro  。 这个本身不能算做是一种模式，因为它是数据生成的一种结果文件。

#### 三种映射
** 一种语言可能有多种表示或映射，Avro 中一共有三种映射关系 **

通用映射： 
 所有的语言都支持动态映射。即使运行前不知道具体的模式，也可以使用通用模式 （将如上 avro的数据类型与对应特定语言类型的映射关系）
特定映射：
 Java 和 C++ 实现可以自动生成代码来表示符合某一Avro模式的数据。 （也是说可以把Avro模式转换为实体对象）
 代码的生成能够优化数据处理，并能够提供相关领域的API。
自反映射：
 只有Java拥有自反映射，将Avro类型映射成事先已有的Java类型。 它的速度比通用映射 和 特定映射都要慢，在项目中不推荐使用。

** 如下，例举了Java的三种类型映射 **

** 提示 通用映射和特定映射string 的默认为UTF8。 源于Java中String类型，性能低下。 如果你想要使用java中的String类型，并不在乎这点性能，在写Avro模式时,设置如下属性 **
```
 { "type": "string", "avro.java.string": "String" } 
```

### 实例演示

#### 通用映射API实例

如上 3.2 我们StringPair.avsc 文件

代码实例

```
public class GenericJavaMapping {
    public static void main(String[] args) throws IOException {
        /********************* 序列化 *********************************/
        
        /*加载Avro模式文件 StringPair.avsc*/
        Schema.Parser parser = new Schema.Parser();
        Schema schema = parser.parse(
                CommonGenericJavaMapping.class.getResourceAsStream("StringPair.avsc"));
       
        /*使用通用(Generic) API 创建多个Avro记录实例 */
        GenericRecord record1 = new GenericData.Record(schema);
        record1.put("left", "Java");
        record1.put("right", "Python");
        
        GenericRecord record2 = new GenericData.Record(schema);
        record2.put("left", "Static");
        record2.put("right", "Dynamic ");
        
        GenericRecord record3 = new GenericData.Record(schema);
        record3.put("left", "StrongType");
        record3.put("right", "WeakTyping ");
        
        
        /*将记录序列化到输出流中*/
//        ByteArrayOutputStream outFile = new ByteArrayOutputStream();
        /*将记录序列化到输出到文件*/
        File outFile = new File("StringPair.avro");
        DatumWriter<GenericRecord> writer =
            new GenericDatumWriter<GenericRecord>(schema);
        DataFileWriter<GenericRecord> dataFileWriter = new DataFileWriter<GenericRecord>(writer);
        dataFileWriter.create(schema, outFile);
        dataFileWriter.append(record1);
        dataFileWriter.append(record2);
        dataFileWriter.append(record3);
        
        dataFileWriter.flush();
        dataFileWriter.close();
        
        
        /********************* 反序列化  ******************************************/
        
        DatumReader<GenericRecord> reader =
                new GenericDatumReader<GenericRecord>(schema);
        DataFileReader<GenericRecord> dataFileReader = new DataFileReader<GenericRecord>(new File("StringPair.avro"), reader);
        GenericRecord record = null;
        while(dataFileReader.hasNext()){
            record = dataFileReader.next(record);
            System.out.println(record);
            System.out.println(record.get("left"));
            System.out.println(record.get("right"));
        }  
        dataFileReader.close();
    }
}

```
可以通过 EncoderFactory 工厂指定编码的形式，采用DecoderFactory工厂同样的方式解码。（这里没有传递任何编码方式，所以为null）

```
/********************* 序列化 *********************************/
FileOutputStream outFile = new FileOutputStream("StringPair.avro");
        DatumWriter<GenericRecord> writer =
            new GenericDatumWriter<GenericRecord>(schema);
        Encoder encoder = EncoderFactory.get().binaryEncoder(outFile, null);
        writer.write(record1, encoder);
        writer.write(record2, encoder);
        writer.write(record3, encoder);
        encoder.flush();
        outFile.close();  

 
/********************* 反序列化  ******************************************/  

    DatumReader<GenericRecord> reader =
                new GenericDatumReader<GenericRecord>(schema);
             
         Decoder decoder =  DecoderFactory.get().binaryDecoder(new FileInputStream("StringPair.avro"), null);
        GenericRecord record = null;  
        try {
            while((record=reader.read(record, decoder))!=null){
                System.out.println(record);
                System.out.println(record.get("left"));
                System.out.println(record.get("right"));
            }  
        } catch (EOFException e) {
            //我没有找到一种很好的方式，遍历并解码序列化文件。这种遍历并不妥当
            //因为这里一定会抛出EOF异常，他已经读到文件末尾，没有数据。所以这里不捕获异常
        }  
```
结果:
<pre>
{"left": "Java", "right": "Python"}
Java
Python
{"left": "Static", "right": "Dynamic"}
Static
Dynamic
{"left": "StrongType", "right": "WeakTyping"}
StrongType
WeakTyping  
</pre>

####  特定映射 API 实例
使用特定映射完成如上等价代码，我们需要生成Shema（Avro模式）的Java映射代码：
我们通过Avro 的 Maven 插件编译Schema模式文件生成StringPair类，如下 POM：
先创建 src/main/avro/ 目录用于存储Shema（Avro模式文件）
```
<properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <avro.version>1.7.7</avro.version>
    </properties>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.avro</groupId>
                <artifactId>avro-maven-plugin</artifactId>
                <version>${avro.version}</version>
                <executions>
                    <execution>
                        <phase>generate-sources</phase>
                        <goals>
                            <goal>schema</goal>
                        </goals>
                        <configuration>
                            <sourceDirectory>${project.basedir}/src/main/avro/</sourceDirectory>
                            <outputDirectory>${project.basedir}/src/main/java/</outputDirectory>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
        <pluginManagement>
            <plugins>
                <!--This plugin's configuration is used to store Eclipse m2e settings 
                    only. It has no influence on the Maven build itself. -->
                <plugin>
                    <groupId>org.eclipse.m2e</groupId>
                    <artifactId>lifecycle-mapping</artifactId>
                    <version>1.0.0</version>
                    <configuration>
                        <lifecycleMappingMetadata>
                            <pluginExecutions>
                                <pluginExecution>
                                    <pluginExecutionFilter>
                                        <groupId>
                                            org.apache.avro
                                        </groupId>
                                        <artifactId>
                                            avro-maven-plugin
                                        </artifactId>
                                        <versionRange>
                                            [1.7.7,)
                                        </versionRange>
                                        <goals>
                                            <goal>schema</goal>
                                        </goals>
                                    </pluginExecutionFilter>
                                    <action>
                                        <ignore></ignore>
                                    </action>
                                </pluginExecution>
                            </pluginExecutions>
                        </lifecycleMappingMetadata>
                    </configuration>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>  
```

也可以使用Ant构建或者使用基于命令行模式： 
基于命令行：
http://mirrors.cnnic.cn/apache/avro/ 下载 avro及其avro-tools.jar 。 通过如下命令生成Java代码映射
```
java -jar avro-tools-*.jar compile schema \
avro/src/main/resources/StringPair.avsc avro/src/main/java
```

代码实例：（已经生成StringPair.java文件）
 
```
public class SpecificJavaMapping {
    public static void main(String[] args) throws IOException {
        /********************* 序列化 *********************************/
        
        /**
         * 有三种方式构建对象，如下:
         */
        StringPair record1 = new StringPair();
        record1.setLeft("Java");
        record1.setRight("Python");
        
        StringPair record2 = new StringPair("Static","Dynamic");
        
        StringPair record3 = StringPair.newBuilder()
                                       .setLeft("StrongType")
                                       .setRight("WeakTyping")
                                       .build();
        
        DatumWriter<StringPair> writer =
            new SpecificDatumWriter<StringPair>(StringPair.class);
        DataFileWriter<StringPair> dataFileWriter = new DataFileWriter<StringPair> (writer);
        dataFileWriter.create(StringPair.getClassSchema(), new File("StringPair.avro"));
        dataFileWriter.append(record1);
        dataFileWriter.append(record2);
        dataFileWriter.append(record3);
        dataFileWriter.flush();
        dataFileWriter.close();
        
        
        /********************* 反序列化  ******************************************/
        DatumReader<StringPair> reader =
            new SpecificDatumReader<StringPair>(StringPair.class);
        DataFileReader<StringPair> dataFileReader = new DataFileReader<StringPair>(new File("StringPair.avro"), reader);
        StringPair record = null;
        
        while(dataFileReader.hasNext()){
            record = dataFileReader.next(record);
            System.out.println(record);
            System.out.println(record.getLeft());
            System.out.println(record.getRight());
        }
        dataFileReader.close();
    }    
}  
```
同样，可以通过 EncoderFactory 工厂指定编码的形式，采用DecoderFactory工厂同样的方式解码。（这么没有传递任何编码方式，所以为null）
```
    /********************* 序列化 *********************************/  
    FileOutputStream outFile = new FileOutputStream("StringPair.avro");
          DatumWriter<StringPair> writer =
                    new SpecificDatumWriter<StringPair>(StringPair.class);
        Encoder encoder = EncoderFactory.get().binaryEncoder(outFile, null);
        writer.write(record1, encoder);
        writer.write(record2, encoder);
        writer.write(record3, encoder);
        encoder.flush();
        outFile.flush();
        outFile.close(); 
 /********************* 反序列化  ******************************************/  
  DatumReader<StringPair> reader =
            new SpecificDatumReader<StringPair>(StringPair.class);
        Decoder decoder = DecoderFactory.get().binaryDecoder(new FileInputStream("StringPair.avro"),
                null);
        StringPair record = null;
        
        try {
            while((record=reader.read(record, decoder))!=null){
                
                System.out.println(record);
                System.out.println(record.getLeft());
                System.out.println(record.getRight());
            }
        } catch (EOFException e) {
            //如上
        }
```
#### Avro中的模式演化
读取数据的模式可以与写入数据的模式不一样，从而做到从原始数据中过滤出想要的数据或增加新的字段。
例如： 写入时的模式为三个字段，读取模式只有两个相同字段。 这样就只取出两个字段，我们称这种方式为‘投影’，在大量记录字段中，读取其中一部分。

如下’投影‘实例： 我使用上面使用过的Avro模式。 并且取出一个字段，也就意味着我们只取left字段。
```
{
  "type": "record",
  "name": "StringPair2",
  "doc": "A pair of strings.",
  "fields": [
    {"name": "left", "type": "string"}
  ]
}
```
执行如下反序列化数据
```
         DatumReader<StringPair2> reader =
                    new SpecificDatumReader<StringPair2>(StringPair2.class);
                DataFileReader<StringPair2> dataFileReader = new DataFileReader<StringPair2>(new File("StringPair.avro"), reader);
                StringPair2 record = null;
                
                while(dataFileReader.hasNext()){
                    record = dataFileReader.next(record);
                    System.out.println(record);
                    System.out.println(record.getLeft());
//                    System.out.println(record.getRight()); // 读入模式StringPair2.avsc中并没有这个字段
                }
                dataFileReader.close();  
```
这样我们就可以很方便的控制要取出的数据。
结果数据为：

<pre>
{"left": "Java"}
Java
{"left": "Static"}
Static
{"left": "StrongType"}
StrongType  
</pre>

实例2   我们在原始avro模式中增加description字段。
这里description字段，通过default属性指定了一个默认值，avro在读取没有定义的记录时就会使用默认值，如果忽略default属性，读取原始数据就会报错。
也可以将默认值设置为null。 ` {"name": "description", "type": ["null", "string"], "default": null} `

```
{
  "type": "record",
  "name": "StringPair3",
  "doc": "A pair of strings with an added field.",
  "fields": [
    {"name": "left", "type": "string"},
    {"name": "right", "type": "string"},
    {"name": "description", "type": "string", "default": ""}
  ]
}
```

我们反序列化原始数据

```
     DatumReader<StringPair3> reader =
                    new SpecificDatumReader<StringPair3>(StringPair3.class);
                DataFileReader<StringPair3> dataFileReader = new DataFileReader<StringPair3>(new File("StringPair.avro"), reader);
                StringPair3 record = null;
                
                while(dataFileReader.hasNext()){
                    record = dataFileReader.next(record);
                    System.out.println(record);
                    System.out.println(record.getLeft());
                    System.out.println(record.getRight()); 
                    System.out.println(record.getDescription()); // 原始数据中并没有这个字段，所以默认为""
                }
                dataFileReader.close();  
```
结果数据
```
{"left": "Java", "right": "Python", "description": ""}
Java
Python
{"left": "Static", "right": "Dynamic", "description": ""}
Static
Dynamic
{"left": "StrongType", "right": "WeakTyping", "description": ""}
StrongType
WeakTyping  
```

模式解析规则可以直接解决模式由一个版本演化为另一个版本时产生的问题,如下记录演化规则进行的总结。



##### Avro模式中的aliases属性（名称的别名）。
别名允许您使用不同的名称在该架构用于读取 Avro 数据比在最初用来写入数据的模式
```
{
  "type": "record",
  "name": "StringPair",
  "doc": "A pair of strings with aliased field names.",
  "fields": [
    {"name": "first", "type": "string", "aliases": ["left"]},
    {"name": "second", "type": "string", "aliases": ["right"]}
  ]
}
 
```
注意的是： aliases 使用转换（在读取时），读取写入模式。但是不能够使用别名。
因为它已经转化为自定义的名称。

##### Avro 排序 (实例是失败的！！！！！)
Avro定义了对象的排列顺序。 我们可以通过指定order属性来控制排序顺序。
它有三个值: ascending(默认值)、descending(反向顺序)后者ignore(可忽略字段)
 
例如，下述模式（SortedStringPair.avsc）定义了
StringPair记录的顺序,right 字段order设置为 descending，。
为了排序的目的，出于排序的目的，忽略left字段，但依旧保留在投影中:
```
{
  "type": "record",
  "name": "SortStringPair",
  "doc": "A pair of strings, sorted by right field descending.",
  "fields": [
    {"name": "left", "type": "string", "order": "ignore"},
    {"name": "right", "type": "string", "order": "descending"}
  ]
}
 
```

```
    SortStringPair record1 = new SortStringPair();
        record1.setLeft("Java");
        record1.setRight("Python");
        
        SortStringPair record2 = new SortStringPair("Static","Dynamic");
        
        SortStringPair record3 = SortStringPair.newBuilder()
                                       .setLeft("StrongType")
                                       .setRight("WeakTyping")
                                       .build();
        
        DatumWriter<SortStringPair> writer =
            new SpecificDatumWriter<SortStringPair>(SortStringPair.class);
        DataFileWriter<SortStringPair> dataFileWriter = new DataFileWriter<SortStringPair> (writer);
        /**
         * 原始序列化文件。 我们只是修改了写入模式。
         */
        dataFileWriter.create(SortStringPair.getClassSchema(), new File("SortStringPair.avro"));
        dataFileWriter.append(record1);
        dataFileWriter.append(record2);
        dataFileWriter.append(record3);
        dataFileWriter.flush();
        dataFileWriter.close();  
```





#### Mapreduce 实例演示
Hadoop权威指南 寻找每年最高温度的天气数据集 实例















#### 实例演示

1、数据准备
1.1 编写 dex Avro 模式文件
```
{
  "namespace": "org.avlyun",
  "name": "avro_dex_sstrings",
  "type": "record",
  "fields": [
     {"name": "sample_md5", "type": ["string", "null"]},
     {"name": "sample_crc32", "type": ["string", "null"]},
     {"name": "dex_strings", "type": ["string", "null"]},
     {"name": "avl_m", "type": ["string", "null"]}
  ]
}
```

1.2  通过类似4.2 处理原始数据，通过如上Shema文件生.avro的数据文件,并批量存储到HDFS中。
1.3  编写Avro Mapreduce程序对dex 数据进行查询操作
```
/**
 * 1、对dex中 avlm字段和string字段进行过滤操作。 
 * 2、对结果数据排序取出最大词频
 */
public class dex_filter_search {
    public static class avro_Mapper extends
            Mapper<AvroKey<avro_dex_sstrings>, NullWritable, Text, IntWritable> {
         private final static IntWritable one = new IntWritable(1);
        public void map(AvroKey<avro_dex_sstrings> key, NullWritable value, Context context)
                throws IOException, InterruptedException {
            //"-STRING","-NSTRING","-AVLM","-NAVLM"
            String filter_String = context.getConfiguration().get("-STRING");
            String filter_Avlm = context.getConfiguration().get("-AVLM");
            String filter_NString = context.getConfiguration().get("-NSTRING");
            String filter_Navlm = context.getConfiguration().get("-NAVLM");
            
            CharSequence dexStrings =  key.datum().getDexStrings();
            CharSequence avl_m = key.datum().getAvlM();
            boolean flag_String = true;
            boolean flag_Avlm = true;
            boolean flag_NString = false;
            boolean flag_Navlm = false;
            
            if(dexStrings!=null && avl_m!=null){
                if(filter_String!=null){
                    String[] list_String = filter_String.split("&");
                    if(list_String!=null && list_String.length>0){
                        for(int i=0;i<list_String.length;i++){
                            if(flag_String!=dexStrings.toString().contains(list_String[i])){
                                flag_String = !flag_String;
                                break;
                            }
                        }
                    }
                }
                if(filter_Avlm!=null){
                    String[] list_Avlm = filter_Avlm.split("&");
                    if(list_Avlm!=null && list_Avlm.length>0){
                        for(int i=0;i<list_Avlm.length;i++){
                            if(flag_Avlm!=avl_m.toString().contains(list_Avlm[i])){
                                flag_Avlm = !flag_Avlm;
                                break;
                            }
                        }
                    }
                }
                if(filter_NString!=null){
                    String[] list_NString = filter_NString.split("&");
                    if(list_NString!=null && list_NString.length>0){
                        for(int i=0;i<list_NString.length;i++){
                            if(flag_NString!=dexStrings.toString().contains(list_NString[i])){
                                flag_NString = !flag_NString;
                                break;
                            }            
                        }
                    }
                }
                if(filter_Navlm!=null){
                    String[] list_Navlm = filter_Navlm.split("&");
                    if(list_Navlm!=null && list_Navlm.length>0){
                        for(int i=0;i<list_Navlm.length;i++){
                            if(flag_Navlm!=dexStrings.toString().contains(list_Navlm[i])){
                                flag_Navlm = !flag_Navlm;
                                break;
                            }            
                        }
                    }
                }
                String temp = "";
                if(flag_String && flag_Avlm && !flag_Navlm && !flag_NString){
                    HashSet<String> set = new HashSet<String>();
                    StringTokenizer tokenizer = new StringTokenizer(dexStrings.toString(),"\n");
                    while(tokenizer.hasMoreTokens()){
                        temp = tokenizer.nextToken();
                        if (temp!=null && !set.contains(temp)) {
                            set.add(temp);
                            context.write(new Text(temp), one);
                        }
                    }
                }
            }
            
        }
    }
    public static class avro_Reduce extends
            Reducer<Text, IntWritable, Text, IntWritable> {
        private IntWritable result = new IntWritable();
        public void reduce(Text key, Iterable<IntWritable> values,
                Context context) throws IOException, InterruptedException {
        /*    int sum = 0;
            Iterator<IntWritable> iterator = values.iterator();
            while(iterator.hasNext()){
                sum+=iterator.next().get();
            }
            context.write(key, new IntWritable(sum));*/
            
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }
     private static class IntWritableDecreasingComparator extends IntWritable.Comparator {
          public int compare(WritableComparable a, WritableComparable b) {
            return -super.compare(a, b);
          }
          
          public int compare(byte[] b1, int s1, int l1, byte[] b2, int s2, int l2) {
              return -super.compare(b1, s1, l1, b2, s2, l2);
          }
      }
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        String[] otherArgs = new GenericOptionsParser(conf, args)
                .getRemainingArgs();
/*        if (otherArgs.length != 4) {
            System.err.println("Usage: wordcount <in> <out>");
            System.exit(2);
        }*/
        // 定义容器对象。 存储过滤关键字 list_String list_Avlm list_NString list_NAvlm
        StringBuffer[] list_Buffer = new StringBuffer[4];
        for(int i=0;i<list_Buffer.length;i++){
            list_Buffer[i] = new StringBuffer();
        }
        
        boolean flag_boolean = true;
        //过滤的四种方式
        String[] keyWord = new String[]{
                "-STRING","-NSTRING","-AVLM","-NAVLM"
        };
        int index = -1;
        for(int i=2;i<args.length;i++){
            flag_boolean = true;
            for(int j=0;j<keyWord.length;j++){
                if(keyWord[j].equalsIgnoreCase(args[i])){
                    index = j;
                    flag_boolean = false;
                    break;
                }
            }
            if(index>-1 && flag_boolean){
                list_Buffer[index].append(args[i]).append("&");
            }
        }
        for(int i=0;i<list_Buffer.length;i++){
            conf.set(keyWord[i], list_Buffer[i].toString());
        }
         Path tempDir = new Path("avro-test-temp-" + Integer.toString(
                    new Random().nextInt(Integer.MAX_VALUE)));
        
        Job job = new Job(conf, "avro-test");
        job.setJarByClass(dex_filter_search.class);
        try{
            
            job.setInputFormatClass(AvroKeyInputFormat.class);
            job.setMapperClass(avro_Mapper.class);
            AvroJob.setInputKeySchema(job, avro_dex_sstrings.getClassSchema());
            
            job.setCombinerClass(avro_Reduce.class);
            job.setReducerClass(avro_Reduce.class);
            
            
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(IntWritable.class);
            
            FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
            FileOutputFormat.setOutputPath(job, tempDir);
                                                         
            job.setOutputFormatClass(SequenceFileOutputFormat.class);
            if(job.waitForCompletion(true))
            {
                Job sortJob = new Job(conf, "sort");
                sortJob.setJarByClass(cat_avro.class);
                
                FileInputFormat.addInputPath(sortJob, tempDir);
                sortJob.setInputFormatClass(SequenceFileInputFormat.class);
                
                sortJob.setMapperClass(InverseMapper.class);
                sortJob.setNumReduceTasks(1); 
                FileOutputFormat.setOutputPath(sortJob, new Path(otherArgs[1]));
                
                sortJob.setOutputKeyClass(IntWritable.class);
                sortJob.setOutputValueClass(Text.class);
                sortJob.setSortComparatorClass(IntWritableDecreasingComparator.class);
     
                System.exit(sortJob.waitForCompletion(true) ? 0 : 1);
            }
        }finally{
            FileSystem.get(conf).deleteOnExit(tempDir);
        }
    }
}  
```
注意：
* 需要指定读入的是Avro数据
  job.setInputFormatClass(AvroKeyInputFormat.class);
* Mapper 端的输入类型为AvroKey<avro_dex_sstrings>，Sehema生成的Java对象
   然后可以很方便的使用key.datum()提取对象的字段集。


#### Avro 数据文件

```
    job.setInputFormatClass(AvroKeyInputFormat.class);  
     AvroJob.setInputKeySchema(job, student_marks.getClassSchema());  
    AvroJob.setOutputKeySchema(job, Schema.create(Schema.Type.INT));
    AvroJob.setOutputValueSchema(job, Schema.create(Schema.Type.FLOAT));  
```


