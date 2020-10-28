#!/usr/bin/env bash

echo "[-->] Detect artifactId from pom.xml"
ARTIFACT=$(mvn -q \
-Dexec.executable=echo \
-Dexec.args='${project.artifactId}' \
--non-recursive \
exec:exec);
echo "artifactId is '$ARTIFACT'"

echo "[-->] Detect artifact version from pom.xml"
VERSION=$(mvn -q \
  -Dexec.executable=echo \
  -Dexec.args='${project.version}' \
  --non-recursive \
  exec:exec);
echo "artifact version is '$VERSION'"

echo "[-->] Detect Spring Boot Main class ('start-class') from pom.xml"
MAINCLASS=$(mvn -q \
-Dexec.executable=echo \
-Dexec.args='${start-class}' \
--non-recursive \
exec:exec);
echo "Spring Boot Main class ('start-class') is '$MAINCLASS'"

echo "[-->] Cleaning target directory & creating new one"
rm -rf target
mkdir -p target/native-image

echo "[-->] Build Spring Boot App with mvn package"
mvn -DskipTests package

echo "[-->] Expanding the Spring Boot fat jar"
JAR="$ARTIFACT-$VERSION.jar"
cd target/native-image
jar -xvf ../$JAR >/dev/null 2>&1
cp -R META-INF BOOT-INF/classes

echo "[-->] Set the classpath to the contents of the fat jar (where the libs contain the Spring Graal AutomaticFeature)"
LIBPATH=`find BOOT-INF/lib | tr '\n' ':'`
CP=BOOT-INF/classes:$LIBPATH

GRAALVM_VERSION=`native-image --version`
echo "[-->] Compiling Spring Boot App '$ARTIFACT' with $GRAALVM_VERSION"
time native-image \
  -J-Xmx4G \
  -H:+TraceClassInitialization \
  -H:Name=$ARTIFACT \
  -H:+ReportExceptionStackTraces \
  -Dspring.native.remove-unused-autoconfig=true \
  -Dspring.native.remove-yaml-support=true \
  -cp $CP $MAINCLASS;


##!/usr/bin/env bash
## Adicione nome do artefato, classe principal e versão!
#ARTIFACT=graalvm
#MAINCLASS=io.github.mrspock182.graalvm.GraalvmApplication
#VERSION=0.0.1-SNAPSHOT
#GREEN='\033[0;32m'
#RED='\033[0;31m'
#NC='\033[0m'
## Remove compilações anteriores
#rm -rf target
#mkdir -p target/native-image
## Empacota a aplicação
#echo "Packaging $ARTIFACT with Maven"
#mvn -ntp package > target/native-image/output.txt
## Expande o JAR criado
#JAR="$ARTIFACT-$VERSION.jar"
#rm -f $ARTIFACT
#echo "Unpacking $JAR"
#cd target/native-image
#jar -xvf ../$JAR >/dev/null 2>&1
#cp -R META-INF BOOT-INF/classes
## Registra classpath, incluindo o que foi gerado pelas dependências que adicionamos no pom.xml
#LIBPATH=`find BOOT-INF/lib | tr '\n' ':'`
#CP=BOOT-INF/classes:$LIBPATH
## Compilação para uma imagem nativa
#GRAALVM_VERSION=`native-image --version`
#echo "Compiling $ARTIFACT with $GRAALVM_VERSION"
#{ time native-image \
#  --verbose \
#  -H:EnableURLProtocols=http \
#  -H:Name=$ARTIFACT \
#  -Dspring.native.remove-yaml-support=true \
#  -Dspring.native.remove-xml-support=true \
#  -Dspring.native.remove-spel-support=true \
#  -Dspring.native.remove-jmx-support=true \
#  -cp $CP $MAINCLASS >> output.txt ; } 2>> output.txt
## Verifica se foi sucesso ou falha e nos mostra a mensagem. ;-)
#if [[ -f $ARTIFACT ]]
#then
#  printf "${GREEN}SUCCESS${NC}\n"
#  mv ./$ARTIFACT ..
#  exit 0
#else
#  cat output.txt
#  printf "${RED}FAILURE${NC}: an error occurred when compiling the native-image.\n"
#  exit 1
#fi