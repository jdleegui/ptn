
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
## 4. Download Pre-built zip ODL
```
Download Pre-built zip file "https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/distribution-karaf/0.4.4-Beryllium-SR4/distribution-karaf-0.4.4-Beryllium-SR4.zip"
```
## 5. Run OpendayLight PreBuild distribution and trace log.
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
  100  ./karaf/target/assembly/bin/karaf 
  101  xt
  102  ps -ef
  103  ps -ef | grep karaf
  104  kill -9 2125
  105  ps -ef | grep karaf
  106  kill -9 31446
  107  ps -ef | grep karaf
  108  kill 09 31053
  109  kill -9 31053
  110  kill 09 31053
  111  ps -ef | grep karaf
  112  ls -al
  113  clear
  114  sl -al
  115  ls -al
  116  java
  117  javac
  118  clear
  119  java
  120  sudo apt-get update
  121  clear
  122  xt
  123  clecl
  124  clear
  125  for ((i=0;i<6;i++))do xt done
  126  df
  127  ls -al
  128  ls -al /tmp/
  129  ls
  130  ls -al
  131  clear
  132  df
  133  cd doc
  134  cd workspace/
  135  ls
  136  cd hello/
  137  ls
  138  mvn clean install -DskipTests
  139  ii
  140  id
  141  sudo reboot
  142  sudo shutdown -h now
  143  xt
  144  for ((i=0;i<6;i++))do xt done
  145  cd
  146  cd Downloads/
  147  tail -F distribution-karaf-0.4.3-Beryllium-SR3/data/log/karaf.log 
  148  ls -al
  149  cd Downloads/
  150  ls
  151  evince opendaylight.pdf 
  152  evince opendaylight.pdf &
  153  ssh -p 29418 jdleegui@git.opendaylight.org
  154  df
  155  df -k
  156  ls /boot/efi
  157  sudo ls /boot/efi
  158  sudo ls /boot/efi -al
  159  sudo ls /boot/efi/EFI/ -al
  160  ls
  161  ls -al
  162  unizp distribution-karaf-0.4.3-Beryllium-SR3.zip 
  163  unzip distribution-karaf-0.4.3-Beryllium-SR3.zip 
  164  ls
  165  unzip distribution-karaf-0.5.0-Boron.zip 
  166  ls -al
  167  cd distribution-karaf-0.4.3-Beryllium-SR3/
  168  ls
  169  ls -al
  170  cd bin
  171  ls
  172  ls -al
  173  mvn --version
  174  javac -verison
  175  cd
  176  cd workspace/
  177  ls
  178  ls -al
  179  mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype -DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ -DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml -DarchetypeVersion=<Archetype-Version>
  180  mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype -DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ -DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml -DarchetypeVersion=1.1.3-Beryllium-SR3
  181  ls -al
  182  tree
  183  sudo apt-get install tree
  184  tree
  185  tree | more
  186  ls
  187  ls -al
  188  cd tsdn_demo
  189  ls
  190  ls -al
  191  mvn clean install
  192  ps -ef|grep elipse
  193  ps -ef | grep eclipse
  194  kill -9  6589
  195  kill -9  6593 
  196  cd ..
  197  mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype -DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ -DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml -DarchetypeVersion=1.1.3-Beryllium-SR3
  198  ~/eclipse/java-neon/eclipse/eclipse &
  199  ls
  200  cd tsdn
  201  ls
  202  cd impl/
  203  mvn clean install -DskipTests
  204  cd ..
  205  cd api
  206  mvn clean install -DskipTests -Dcheckstyle.skip=true
  207  cd ..
  208  cd impl
  209  mvn clean install -DskipTests -Dcheckstyle.skip=true
  210  cd ..
  211  mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype -DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ -DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml -DarchetypeVersion=1.1.3-Beryllium-SR3
  212  cd ..
  213  ls
  214  cd workspace/
  215  ls
  216  cd t
  217  ls
  218  cd ttt
  219  ls
  220  cd impl/
  221  cd ..
  222  cd api/
  223  
  224  cd ..
  225  cd impl
  226  mvn clean install -DskipTests -Dcheckstyle.skip=true
  227  cd ..
  228  find . -name '*.jar'
  229  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  230  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  231  cd api
  232  mvn clean install -DskipTests -Dcheckstyle.skip=true
  233  cd ..
  234  cd impl
  235  mvn clean install -DskipTests -Dcheckstyle.skip=true
  236  cd ..
  237  cp api/target/ttt-api-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  238  cp impl/target/ttt-impl-1.0.0-SNAPSHOT.jar ~/Downloads/distribution-karaf-0.4.3-Beryllium-SR3/deploy/
  239  cd ..
  240  ls -al
  241  ls
  242  mv tsdn ~/BAK/
  243  mv tsdn_demo/ ~/BAK/
  244  mv ttt/ ~/BAK/
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
