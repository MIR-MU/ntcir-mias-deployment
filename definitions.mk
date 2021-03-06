SHELL=/bin/bash

CPU_NUMBER=30
MIRMU_GIT_URL_PREFIX=https://github.com/MIR-MU

# External tools
CURL=curl --location --cookie oraclelicense=accept-securebackup-cookie

MAVEN=$(shell pwd)/apache-maven-3.5.4
MAVEN_URL=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.4/apache-maven-3.5.4-bin.tar.gz
MAVEN_MVN=JAVA_HOME=$(JDK) nice -n 19 "$(MAVEN)"/bin/mvn

JDK=$(shell pwd)/jdk1.8.0_202
JDK_URL=https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz

TOMCAT=$(shell pwd)/apache-tomcat-8.5.29
TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
TOMCAT_PORT_PREFIX=5
TOMCAT_WEBAPP_NAME=WebMIaS
TOMCAT_WEBAPP_URL=http://localhost:$(TOMCAT_PORT_PREFIX)8080/$(TOMCAT_WEBAPP_NAME)
TOMCAT_WAR=$(TOMCAT)/webapps/$(TOMCAT_WEBAPP_NAME).war
TOMCAT_STARTUP=JAVA_HOME=$(JDK) $(TOMCAT)/bin/startup.sh

# MIaS Git repositories
WEBMIAS=$(shell pwd)/WebMIaS
WEBMIAS_URL=$(MIRMU_GIT_URL_PREFIX)/WebMIaS.git
WEBMIAS_REF=b2d922225aea8eb4b72c1e617fafd7dc54f03531
WEBMIAS_WAR=$(WEBMIAS)/target/WebMIaS-1.6.6-4.10.4-SNAPSHOT.war

MIAS=$(shell pwd)/MIaS
MIAS_URL=$(MIRMU_GIT_URL_PREFIX)/MIaS.git
MIAS_REF=3dbaa02036b6a00346df00688099b17f0429e1c7
MIAS_STARTUP=cd $(MIAS)/target; JAVA_HOME=$(JDK) nice -n 19 $(JDK)/bin/java -jar MIaS-*-SNAPSHOT.jar
MIAS_THREADS=$(CPU_NUMBER)

MIASMATH=$(shell pwd)/MIaSMath
MIASMATH_URL=$(MIRMU_GIT_URL_PREFIX)/MIaSMath.git
MIASMATH_REF=0961efb44a94d125bf6ec83ed3c7e4aa1d180eb6

MATHMLCAN=$(shell pwd)/MathMLCan
MATHMLCAN_URL=$(MIRMU_GIT_URL_PREFIX)/MathMLCan.git
MATHMLCAN_REF=38063b9ffa9117be536743ac26c7ce210dd48483

MATHMLUNIFICATOR=$(shell pwd)/MathMLUnificator
MATHMLUNIFICATOR_URL=$(MIRMU_GIT_URL_PREFIX)/MathMLUnificator.git
MATHMLUNIFICATOR_REF=047390437678e2b758bda1c6446b2748ea773c9b

MIREVAL=$(shell pwd)/MIREVal
MIREVAL_URL=$(MIRMU_GIT_URL_PREFIX)/MIREVal
MIREVAL_REF=98b62e47a1b8a7c22a1d3c0771cd7103e8b17328
MIREVAL_STARTUP_PARALLEL=cd $(MIREVAL)/target; JAVA_HOME=$(JDK) nice -n 19 parallel --bar --halt=2 --jobs=1 -- $(JDK)/bin/java -jar MIREVal-*-SNAPSHOT-jar-with-dependencies.jar '&>/dev/null'

RESULTS_NTCIR11=$(shell pwd)/results-ntcir-11
RESULTS_NTCIR11_PLOTS=$(RESULTS_NTCIR11)/plot.{svg,pdf}

NTCIR10_MATH_CONVERTER=$(shell pwd)/ntcir10-math-converter
NTCIR10_MATH_CONVERTER_STARTUP=cd $(NTCIR10_MATH_CONVERTER); source $(NTCIR10_MATH_CONVERTER_VIRTUALENV)/bin/activate; nice -n 19 ntcir10-math-converter
NTCIR10_MATH_CONVERTER_URL=$(MIRMU_GIT_URL_PREFIX)/ntcir10-math-converter
NTCIR10_MATH_CONVERTER_REF=00f582eee18f14c641fae64a25b8a61a0ad16ecc
NTCIR10_MATH_CONVERTER_VIRTUALENV=$(NTCIR10_MATH_CONVERTER)/virtualenv
NTCIR10_MATH_CONVERTER_WORKERS=$(CPU_NUMBER)

NTCIR_MATH_DENSITY=$(NTCIR_MATH_DENSITY_NTCIR11) $(NTCIR_MATH_DENSITY_ALL) $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10)
NTCIR_MATH_DENSITY_URL=$(MIRMU_GIT_URL_PREFIX)/ntcir-math-density
NTCIR_MATH_DENSITY_REF=648c74bfc5bd304603ef67da753ff25b65e829ef
NTCIR_MATH_DENSITY_WORKERS=$(CPU_NUMBER)

NTCIR_MATH_DENSITY_NTCIR11=$(shell pwd)/ntcir-math-density-ntcir11
NTCIR_MATH_DENSITY_NTCIR11_STARTUP=cd $(NTCIR_MATH_DENSITY_NTCIR11); source $(NTCIR_MATH_DENSITY_NTCIR11_VIRTUALENV)/bin/activate; nice -n 19 ntcir-math-density
NTCIR_MATH_DENSITY_NTCIR11_VIRTUALENV=$(NTCIR_MATH_DENSITY_NTCIR11)/virtualenv
NTCIR_MATH_DENSITY_NTCIR11_ESTIMATES=$(NTCIR_MATH_DENSITY_NTCIR11)/estimates.pkl.gz
NTCIR_MATH_DENSITY_NTCIR11_POSITIONS=$(NTCIR_MATH_DENSITY_NTCIR11)/positions.pkl.gz
NTCIR_MATH_DENSITY_NTCIR11_PLOTS=$(NTCIR_MATH_DENSITY_NTCIR11)/plot.{pdf,svg}

NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10=$(shell pwd)/ntcir-math-density-all-without-ntcir10
NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_STARTUP=cd $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10); source $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_VIRTUALENV)/bin/activate; nice -n 19 ntcir-math-density
NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_VIRTUALENV=$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10)/virtualenv
NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_ESTIMATES=$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10)/estimates.pkl.gz
NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_POSITIONS=$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10)/positions.pkl.gz
NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_PLOTS=$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10)/plot.{pdf,svg}

NTCIR_MATH_DENSITY_ALL=$(shell pwd)/ntcir-math-density-all
NTCIR_MATH_DENSITY_ALL_STARTUP=cd $(NTCIR_MATH_DENSITY_ALL); source $(NTCIR_MATH_DENSITY_ALL_VIRTUALENV)/bin/activate; nice -n 19 ntcir-math-density
NTCIR_MATH_DENSITY_ALL_VIRTUALENV=$(NTCIR_MATH_DENSITY_ALL)/virtualenv
NTCIR_MATH_DENSITY_ALL_ESTIMATES=$(NTCIR_MATH_DENSITY_ALL)/estimates.pkl.gz
NTCIR_MATH_DENSITY_ALL_POSITIONS=$(NTCIR_MATH_DENSITY_ALL)/positions.pkl.gz
NTCIR_MATH_DENSITY_ALL_PLOTS=$(NTCIR_MATH_DENSITY_ALL)/plot.{pdf,svg}

NTCIR_MIAS_SEARCH=$(shell pwd)/ntcir-mias-search
NTCIR_MIAS_SEARCH_STARTUP=source $(NTCIR_MIAS_SEARCH_VIRTUALENV)/bin/activate; nice -n 19 ntcir-mias-search
NTCIR_MIAS_SEARCH_URL=$(MIRMU_GIT_URL_PREFIX)/ntcir-mias-search
NTCIR_MIAS_SEARCH_REF=0d89e93962c77464f0809462dcd4d0d6f8b494c1
NTCIR_MIAS_SEARCH_VIRTUALENV=$(NTCIR_MIAS_SEARCH)/virtualenv
NTCIR_MIAS_SEARCH_QUERYING_WORKERS=$(MIAS_THREADS)
NTCIR_MIAS_SEARCH_MERGING_WORKERS=2

MAKEFILE2DOT=$(shell pwd)/makefile2dot
MAKEFILE2DOT_STARTUP=cd $(MAKEFILE2DOT); cat $(MAKEFILES_DEFINITIONS) $(MAKEFILES_RECIPES) | python $(MAKEFILE2DOT_SCRIPT) | grep -vE '\.PHONY|all|clean|\.ONESHELL' | dot -T svg
MAKEFILE2DOT_URL=https://github.com/vak/makefile2dot
MAKEFILE2DOT_REF=0e6a96955274af86e48f37680021ac7ab50bfed3
MAKEFILE2DOT_SCRIPT=$(MAKEFILE2DOT)/makefile2dot.py
MAKEFILE2DOT_PLOT=$(shell pwd)/Makefile.svg

# Makefiles
MAKEFILES_DEFINITIONS=$(shell pwd)/definitions.mk
MAKEFILES_RECIPES=$(shell pwd)/recipes.mk

# Logging
LOGFILE=$(shell pwd)/Makefile.log

# Topics
TOPICS_BASEDIR=/mnt/storage/ntcir
TOPICS_NTCIR10=$(TOPICS_NTCIR10_FS) $(TOPICS_NTCIR10_FT)
TOPICS_NTCIR10_FS=$(TOPICS_BASEDIR)/NTCIR10-Math/NTCIR-Math-formula-search.xml
TOPICS_NTCIR10_FT=$(TOPICS_BASEDIR)/NTCIR10-Math/NTCIR-Math-fulltext-search.xml
TOPICS_NTCIR11=$(TOPICS_BASEDIR)/NTCIR11-Math/NTCIR11-Math2-queries-participants.xml
TOPICS_NTCIR12=$(TOPICS_NTCIR12_QUERIES) $(TOPICS_NTCIR12_SIMTO)
TOPICS_NTCIR12_QUERIES=$(TOPICS_BASEDIR)/NTCIR12-Math/NTCIR12-Math-queries-judges.xml
TOPICS_NTCIR12_SIMTO=$(TOPICS_BASEDIR)/NTCIR12-Math/NTCIR12-Math-simto-judges.xml

# Relevance judgements
JUDGEMENTS_BASEDIR=/mnt/storage/ntcir
JUDGEMENTS_NTCIR10=$(JUDGEMENTS_NTCIR10_FS) $(JUDGEMENTS_NTCIR10_FT)
JUDGEMENTS_NTCIR10_FS=$(JUDGEMENTS_BASEDIR)/NTCIR10-Math/NTCIR_10_Math-qrels_fs.dat
JUDGEMENTS_NTCIR10_FT=$(JUDGEMENTS_BASEDIR)/NTCIR10-Math/NTCIR_10_Math-qrels_ft.dat
JUDGEMENTS_NTCIR10_CONVERTED=$(JUDGEMENTS_NTCIR10_CONVERTED_FS) $(JUDGEMENTS_NTCIR10_CONVERTED_FT)
JUDGEMENTS_NTCIR10_CONVERTED_FS=$(JUDGEMENTS_BASEDIR)/NTCIR10-Math/NTCIR_10_Math-qrels_fs-converted.dat
JUDGEMENTS_NTCIR10_CONVERTED_FT=$(JUDGEMENTS_BASEDIR)/NTCIR10-Math/NTCIR_10_Math-qrels_ft-converted.dat
JUDGEMENTS_NTCIR11=$(JUDGEMENTS_BASEDIR)/NTCIR11-Math/NTCIR11_Math-qrels.dat
JUDGEMENTS_NTCIR12=$(JUDGEMENTS_NTCIR12_QUERIES) $(JUDGEMENTS_NTCIR12_SIMTO)
JUDGEMENTS_NTCIR12_QUERIES=$(JUDGEMENTS_BASEDIR)/NTCIR12-Math/NTCIR12_Math-qrels_agg.dat
JUDGEMENTS_NTCIR12_SIMTO=$(JUDGEMENTS_BASEDIR)/NTCIR12-Math/NTCIR12_Math_simto-qrels_agg.dat

# Indexing
INDEX_BASEDIR=$(shell pwd)/indexes
INDEX_MAXRESULTS=10000
INDEX=$(INDEX_NTCIR10) $(INDEX_NTCIR11_12)

INDEX_NTCIR10_NAME=ntcir-10-1
INDEX_NTCIR10_NUMBER=0
INDEX_NTCIR10=$(INDEX_BASEDIR)/$(INDEX_NTCIR10_NAME)
DATASET_NTCIR10=/mnt/storage/ntcir-10.ro-snapshot
DATASET_NTCIR10_CONVERTED=$(shell pwd)/ntcir10-converted

INDEX_NTCIR11_12_NAME=ntcir-12-5
INDEX_NTCIR11_12=$(INDEX_BASEDIR)/$(INDEX_NTCIR11_12_NAME)
INDEX_NTCIR11_12_NUMBER=1
DATASET_NTCIR11_12=/mnt/storage/nezalohovano-ntcir-11-12-dataset-unpacked.ro-snapshot

# Uninstalling
INSTALL_DIRS=$(MAVEN) $(JDK) $(TOMCAT) $(WEBMIAS) $(MIAS) $(MIASMATH) $(MATHMLCAN) $(MATHMLUNIFICATOR) $(MIREVAL) $(RESULTS_NTCIR11) $(NTCIR10_MATH_CONVERTER_VIRTUALENV) $(NTCIR10_MATH_CONVERTER) $(NTCIR_MATH_DENSITY) $(INDEX_BASEDIR) $(DATASET_NTCIR10_CONVERTED) $(MAKEFILE2DOT) $(MAKEFILE2DOT_PLOT) $(NTCIR_MIAS_SEARCH) $(JUDGEMENTS_NTCIR10_CONVERTED) $(LOGFILE)
