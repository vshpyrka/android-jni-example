#!/bin/zsh
echo Removing existing potrace source

rm -rf ./.tmp
mkdir .tmp
rm -fr src/main/cpp/potrace

POTRACE_VERSION=1.16

echo Downloading Potrace release ${POTRACE_VERSION}

curl https://potrace.sourceforge.net/download/1.16/potrace-${POTRACE_VERSION}.tar.gz -o ./.tmp/potrace.tar.gz

tar -xf .tmp/potrace.tar.gz -C ./.tmp

TARGET_DIR=src/main/cpp/potrace
echo Copying Potrace code to ${TARGET_DIR}

mkdir ${TARGET_DIR}

cp -a .tmp/potrace-${POTRACE_VERSION}/src/* ${TARGET_DIR}

# Write config.h file
echo -e "#ifndef CONFIG_H" >> ${TARGET_DIR}/config.h
echo -e "#define CONFIG_H" >> ${TARGET_DIR}/config.h
echo -e "#define POTRACE \"POTRACE\"" >> ${TARGET_DIR}/config.h
echo -e "#define VERSION \"${POTRACE_VERSION}\"" >> ${TARGET_DIR}/config.h
echo -e "#endif //CONFIG_H" >> ${TARGET_DIR}/config.h


configMentionedFiles=($(grep -rl "#ifdef HAVE_CONFIG_H" ./src/main/cpp/potrace))

for i in "${configMentionedFiles[@]}"
do
  sed -i '' '1N;$!N;s/#ifdef HAVE_CONFIG_H\n#include <config.h>\n#endif/#include "config.h"/;P;D' "${i}"
done

echo Replaced all config occurrences

echo Cleanup
rm -rf ./.tmp

echo Update complete