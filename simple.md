
# Setup environment
## Install JDK
```
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install openjdk-8-jre-headless
sudo apt-get install openjdk-8-jre
sudo apt-get install openjdk-8-jdk
sudo apt-get install maven
javac -version
export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
```
## Install maven and eclipse
```
sudo apt-cache search eclipse
sudo apt-cache search maven
sudo apt-get install maven
```   
## Copy maven environment for ODL
- [Boron] : ( http://docs.opendaylight.org/en/stable-boron/developer-guide/developing-apps-on-the-opendaylight-controller.html )
```
cp -n ~/.m2/settings.xml{,.orig};
wget -q -O - https://raw.githubusercontent.com/opendaylight/odlparent/stable/boron/settings.xml > ~/.m2/settings.xml
ls ~/.m2
ls ~/.m2/settings.xml
```
## Remove existing repository if exist
```
mv ~/.m2/repository/ ~/BAK/
```
# Create project
## Make project based on '1.1.3-Beryllium-SR3' using the snapshot architype (*recomend*)
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ \
-DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml \
-DarchetypeVersion=1.1.3-Beryllium-SR3
```
## Make project based on '1.1.3-Beryllium-SR3' using the public general architype 
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=https://nexus.opendaylight.org/content/repositories/public/ \
-DarchetypeCatalog=https://nexus.opendaylight.org/content/repositories/public/archetype-catalog.xml \
-DarchetypeVersion=1.1.3-Beryllium-SR3
```
```
Define value for property 'groupId': : com.lgu
Define value for property 'artifactId': : ptn
Define value for property 'package':  com.lgu: : 
Define value for property 'classPrefix':  Ptn: : 
Define value for property 'copyright': : LGUplus.
```
## Remove test XML category from impl/pom.xml
```
    <!-- Testing Dependencies -->
    <!--
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <scope>test</scope>
    </dependency>
    -->
    <!--
    <dependency>
      <groupId>org.mockito</groupId>
      <artifactId>mockito-all</artifactId>
      <scope>test</scope>
    </dependency>
    -->
```
## Insert apache.felix plugins when build the project
```
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.felix</groupId>
        <artifactId>maven-bundle-plugin</artifactId>
        <extensions>true</extensions>
          <configuration>
            <instructions>
              <Bundle-Name>ptn_manager</Bundle-Name>
              <Bundle-Activator>com.lgu.impl.PtnProvider</Bundle-Activator>
              <!-- Export-Package>!*</Export-Package -->            
            </instructions>
          </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```
## 3. Import created maven project from eclipse 
- Import only ap and impl
```
1. Import maven project into workspace > Select PTN
2. Select api and ptn
3. Remove impl/src/test
4. Remove impl/main/config
5. Remove impl/main/yang
6. Remove impl/src/main/java/org.opendaylight.yang.gen.v1.urn.opendaylight
```
## Download Pre-built zip ODL

```
Download Pre-built zip file "https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/distribution-karaf/0.4.4-Beryllium-SR4/distribution-karaf-0.4.4-Beryllium-SR4.zip"

rm -R distribution-karaf-0.4.4-Beryllium-SR4/
unzip ~/Downloads/distribution-karaf-0.4.4-Beryllium-SR4.zip ./
./distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf 
```
## Run OpendayLight PreBuild distribution and trace log.
```
unzip distribution-karaf-0.4.4-Beryllium-SR4.zip 
distribution-karaf-0.4.4-Beryllium-SR4 ~/workspace/
workspace/distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf
tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log 
```
## 6. Install basic features which required to run our project.
 ```
opendaylight-user@root>feature:install odl-dlux-all
opendaylight-user@root>feature:install odl-restconf-all 
opendaylight-user@root>feature:install odl-mdsal-all 
```
## 7. Compile API folder first and copy the created jar into the deploy folder.
```
~/workspace/ptn/api/mvn clean install -DskipTests -Dcheckstyle.skip=true
cp ptn/api/target/ptn-api-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## 8. Look carefully if there's any error in the distributed jar file.
```
opendaylight-user@root>log:tail
tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log 
```
## 9. Compile impl folder next and copy the created jar into the same deploy folder.
``` 
~/workspace/ptn/impl$ mvn clean install -DskipTests -Dcheckstyle.skip=true
cp impl/target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
- [ Create New Project in eclipse GUI mode ]
```
  229  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  230  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  245  
  246  ~/eclipse/java-neon/eclipse/eclipse &
  247  cat ~/BAK/ttt/impl/src/main/java/ttt/demo/impl/TttProvider.java 
  248  cd tsdn_demo/api/
  249  mvn clean install -DskipTests -Dcheckstyle.skip=true
  250  cd ..
  251  cd impl
  252  mvn clean install -DskipTests -Dcheckstyle.skip=true
  253  ~/eclipse/java-neon/eclipse/eclipse &
  254  mvn clean install -DskipTests -Dcheckstyle.skip=true
  255  ls
  256  ls src
  257  cd ..
  258  mv ~/BAK/ttt/ ~/
  259  ls
  260  mv ~/ttt/ ./
  261  ls
  262  cd ttt
  263  ls
  264  cd api
  265  mvn clean install -DskipTests -Dcheckstyle.skip=true
  266  cd ..
  267  cd impl
  268  mvn clean install -DskipTests -Dcheckstyle.skip=true
  269  cd ..
  270  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  271  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  272  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  273  cd api/
  274  mvn clean install -DskipTests -Dcheckstyle.skip=true
  275  cd ..
  276  cd impl/
  277  mvn clean install -DskipTests -Dcheckstyle.skip=true
  278  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  279  cd ..
  280  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  281  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  282  cd api
  283  mvn clean install -DskipTests -Dcheckstyle.skip=true
  284  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  285  cd ..
  286  rm ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/ttt-impl-1.0.0-SNAPSHOT.jar 
  287  rm ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/ttt-api-1.0.0-SNAPSHOT.jar 
  288  ps -ef | grep karaf
  289  kill -9 10235 
  290  cd api
  291  xt
  292  cd ..
  293  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  294  cd api
  295  mvn clean install -DskipTests -Dcheckstyle.skip=true
  296  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  297  cd ..
  298  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  299  cd impl
  300  mvn clean install -DskipTests -Dcheckstyle.skip=true
  301  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  302  cd ..
  303  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  304  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  305  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  306  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  307  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  308  rm ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/ttt-impl-1.0.0-SNAPSHOT.jar 
  309  rm ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/ttt-api-1.0.0-SNAPSHOT.jar 
  310  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  311  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  312  vim ~/a.txt 
  313  grep 'ufw' ~/a.txt 
  314  sudo ufw enable
  315  sudo ufw allow 8181
  316  sudo ufw allow 8080
  317  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  318  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  319  ls
  320  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  321  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  322  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  323  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  324  ls -al
  325  ping gui.coweaver.co.kr
  326  ping ems.coweaver.co.kr
  327  telnet ems.coweaver.co.kr 3306
  328  ls
  329  cd 
  330  ls
  331  cd dow
  332  cd dw
  333  cd down
  334  cd
  335  ls
  336  ls -al
  337  cd dow
  338  cd Downloads/
  339  ls
  340  cd distribution-karaf-0.4.3-Beryllium-SR3/
  341  ls
  342  cd bin
  343  cd k
  344  ls
  345  karaf
  346  ls
  347  cd ..
  348  ls
  349  ls -al
  350  cd bin
  351  ls
  352  ./karaf 
  353  cd ..
  354  ls
  355  rm -R distribution-karaf-0.4.3-Beryllium-SR3
  356  ls -al3
  357  ls -al
  358  unzip distribution-karaf-0.4.3-Beryllium-SR3.zip 
  359  ls
  360  ./distribution-karaf-0.4.3-Beryllium-SR3/bin/karaf 
  361  ping erp.coweaver.co.kr
  362  ping gui.coweaver.co.kr
  363  ping rnd.coweaver.co.rk
  364  ping ems.coweaver.co.kr
  365  ssh ems.coweaver.co.kr
  366  telnet ems.coweaver.co.kr 3408
  367  ssh
  368  sudo apt-get install ssh
  369  ls
  370  vim a.tt
  371  vim a.txt
  372  ls .ssh
  373  ls -al
  374  cd
  375  ls al .ssh
  376  mkdir ~./ssh
  377  mkdir ~/.ssh
  378  id
  379  clear
  380  ls -al
  381  pwd
  382  ls -al
  383  pwd
  384  ls -al
  385  id
  386  pwd
  387  clear
  388  pwd
  389  mkdir ~/.ssh
  390  cd ~/.ssh
  391  ls
  392  ls -al
  393  cd ..
  394  chmod 700  ~/.ssh/
  395  ssh-keygen -t rsa
  396  ls ~/.ssh/id_rsa.pub 
  397  vim ~/.ssh/id_rsa.pub 
  398  vim 
  399  ls
  400  cd eclipse/
  401  ls
  402  cd java-neon/
  403  ls
  404  cd eclipse/
  405  ls
  406  ./eclipse &
  407  clear
  408  sudo shutdown -h now
  409  ls
  410  ls -al
  411  ./Downloads/distribution-karaf-0.4.3-Beryllium-SR3/bin/karaf &
  412  ./Downloads/distribution-karaf-0.4.3-Beryllium-SR3/bin/karaf 
  413  clear
  414  ./eclipse/java-neon/eclipse/eclipse &
  415  xt
