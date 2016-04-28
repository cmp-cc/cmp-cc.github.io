----
title: Hbase常规操作
date: 2015-04-22 16:53:00
updated:
categories: 
- Distributed Development
- Hbase
tags:
- Hbase
----

**记录Hbase 一些常规操作**

## 获取rowkey
```Java

    final String table_name = "avml_test";
        Set<String> sampleSet = new HashSet<String>();
        Configuration conf = HBaseConfiguration.create();
        conf.set("hbase.zookeeper.quorum", "datanode01.hadoop");
        try {
            HTable table = new HTable(conf,table_name);
            Scan scan = new Scan();
            ResultScanner scanner1 =  table.getScanner(scan);
            for(Result res : scanner1){
                for(KeyValue kv : res.raw()){
            /*
        rowkey 为一个md5 ，你需要做截取操作
        \x00 01CCC0C34CD54B2C915237F3C848840A\x06resultavml_qq\x00\x00\x01L\xBB\x1A}\xCA\x04
            */
                sampleSet.add(kv.getKeyString().split(" ")[1].substring(0,32));
                }
            }
            table.close();
          } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
         }  

```

也可以使用如下方法,获取真实rowkey

```
public static String getRealRowKey(KeyValue kv) {  
        int rowlength = Bytes.toShort(kv.getBuffer(), kv.getOffset()+KeyValue.ROW_OFFSET);  
        String rowKey = Bytes.toStringBinary(kv.getBuffer(), kv.getOffset()+KeyValue.ROW_OFFSET + Bytes.SIZEOF_SHORT, rowlength);  
        return rowKey;  
    }  

```
获取rowkey(这个代码是有问题的，没有修改) 
``` Java
    public ResultScanner readHbaseRowkey(Configuration conf,String tableName) throws IOException{
        HTable table = new HTable(conf, tableName);
        Scan scan = new Scan();
        KeyOnlyFilter rowKeyFilter = new KeyOnlyFilter();
        scan.setFilter(rowKeyFilter);
        ResultScanner scanner = table.getScanner(scan);
        // 关闭table scanner 会失效的。 异常？
        table.close();
        return scanner;
    }  
```