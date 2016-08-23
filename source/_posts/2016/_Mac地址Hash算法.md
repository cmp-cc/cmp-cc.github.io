----
title: Mac地址Hash算法
date: 2016-08-18 17:51:00
updated:
categories:
- Distributed Development
- Elasticsearch
tags:
- 算法
----
## Mac2Hash
* 在获取到Mac地址进行数据存储的时候，我们不会真实的将Mac地址写入数据库，或打入日志系统。 
* Mac地址的重要性：`用户验证`，`确保同一台机器`，`真实用户统计`，`访问限制` 等等
* 如何存储Mac地址？   即保护了用户隐私，又保证其唯一性，也能快速验证等。

**我们需要对Mac地址Hash化，Mac地址Hash步骤如下：**
* 1.Mac地址去除分隔符(`-`)，并转换为小写字符串。
* 2.利用`crc32`算法，计算出Hash1。 （Long 类型）
* 3.利用`jenkins`算法的`hashLittle(mac.getBytes(),mac.length,12)`,这里`initial 值为12`,计算结果 并与`0xffffffff`进行`&(与运算)`操作，计算出hash2。 (Long 类型)
* 4.将`Hash1` 和 `Hash2` 分别转换为`Byte[] 小端输出`。 并获取有效字节。（前4个字节）,这里将获得`crc32byte[]` 和 `jenkinsbyte[]`
* 5.将`crc32byte[]`和`jenkinsbyte[]` 转换为16进制，并拼接。 crc32hex + jenkinshex = macHash 。 macHash 长度为16
> Long 类型为8字节。 `crc32` 和 `jenkins`对mac计算出的hash 长度真实有效为4字节。 也就是说还有4个字节并没有使用。
> 这里统一 字节的大小端，避免不同语言不同平台出现大小端问题。 统一采用小端输出。 参考： 大小端模式。
> 将`crc32byte[]`和`jenkinsbyte[]` 转换为16进制，byte[] -> hex （16进制） ，长度不足自动补0 。
> 转换之后进行拼接，crc32_hash 在前 jenkins_hash 再后。

## Java
``` Java
    // 1.去分割，转小写
        macAddress = macAddress.replaceAll("-", "").toLowerCase();
        
        // 2.利用crc32算法，计算出hash字符串1。
        CRC32 crc32 = new CRC32();
        crc32.update(macAddress.getBytes());
        Long hash1 = crc32.getValue();
        
        // 3.jenkins 算法
        JenkinsHash jenkins = new JenkinsHash();
        //0xffffffffL 为16进制值最高位,这里必须加L, 它是类型为Long.否则无效
        Long hash2 = jenkins.hashLittle(macAddress.getBytes(), macAddress.length(), 12) & 0xffffffffL;
        
        //4.转换为小端输出,并截取有效字节(byte). crc32 和 jenkins 有效长度在4byte以内。 有效字节数相同。均为前4个字节。
        
        byte[] crc32_hash = new byte[4];
        byte[] jinkins_hash = new byte[4];
        
        /**
         * 4.1. x = BitConverter.GetBytes(long hash) 方法将默认long类型转换为  byte小端输出。 Java的所有字节输出为大端输出。  参考：大小端模式
         * 
         * 4.2. x :一共8个字节,前4个字节不为0，后4个字节为0, 将如上x转为16进制后,eg：DA B1 0D 15 00 00 00 00 。 这里截取前4个byte，然后再转换为16进制
         */
        System.arraycopy(BitConverter.GetBytes(hash1), 0, crc32_hash, 0, 4);
        System.arraycopy(BitConverter.GetBytes(hash2), 0, jinkins_hash, 0, 4);
        //5. crc32 和 jenkins 同样截取4个 byte，如下操作： 将其转换为16进制，并拼接，组成长度16 hash地址。
        String macHash = ByteConvert.byte2HexStringNoBlank(crc32_hash)+ByteConvert.byte2HexStringNoBlank(jinkins_hash);
        
        System.out.println(String.format("%s\t%s", macAddress,macHash));  

```


## Python 


``` python
import zlib
import jenkins
import struct

line = "64cc2edc4776"
x = zlib.crc32(line.strip()) & 0xffffffff
n = struct.unpack("<I",struct.pack(">I",x))[0]
y = jenkins.hashlittle(line.strip(),12) & 0xffffffff
m = struct.unpack("<I",struct.pack(">I",y))[0]

print "%s\t%s\t%s\t%s" %(x,n,y,m)

print "%s %04x%04x" %(line.strip(),n, m)
```

## C

``` C
char *acMacAddr = (char *) p -> value;
unsigned char aucUserIdHex[16] = {0};
unsigned int iCRC = 0;
HashCRC32((unsigned char *)acMacAddr,12,&iCRC);
unsigned int iLkhash = Lk3Hash(acMacAddr,12);
memcpy(aucUserIdHex ,&iCRC,4);
char * psUserID = Utils_hex2String(auxUserIdHex,8);
printf("%s %s\n",acMacAddr,psUserId);
```

> 验证数据：`54cc2edc4777`    `bc539415b60a276d`