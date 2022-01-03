## JDK安装<!-- {docsify-ignore} -->

**下载JDK**

首先从官网下载自己所需要版本得JDK，如我是windows64位系统，想用JDK版本为8，那么在[JDK8下载页](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)选择jdk-8u301-windows-x64.exe进行下载。如果需要其他版本的JDK，则可以在[官网下载地址](https://www.oracle.com/java/technologies/java-se-glance.html)进行下载。

**安装JDK**

双击无脑下一步就好，记住安装目录即可。

**设置环境变量**

新建->变量名"JAVA_HOME"，变量值"C:\Program Files\Java\jdk1.8.0_301"（即JDK的安装路径）

```
JAVA_HOME
C:\Program Files\Java\jdk1.8.0_301
```

编辑->变量名"Path"，在原变量值的最后面加上“;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin”

```
Path
;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin
```

新建->变量名“CLASSPATH”,变量值“;%JAVA_HOME%\lib;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar”

```
CLASSPATH
;%JAVA_HOME%\lib;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar
```

**验证**

在命令行中输入`java -version`如果看到java得版本信息，则安装成功。