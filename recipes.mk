.ONESHELL:
.PHONY: all clean results plot

SHELL=/bin/bash

SVN_CHECKOUT=\
	git svn clone "$(1)" --trunk="$(2)" "$(4)" && \
	cd "$(4)" && \
	REF=`git svn find-rev r$(3)` && \
	git checkout "$$REF";

GIT_CHECKOUT=\
	git clone "$(1)" "$(3)" && \
	cd "$(3)" && \
	git checkout "$(2)";

all:
	make -d plot results 2>&1 | while read LINE
	do
	  printf '%s - %s\n' "`date --rfc-3339=seconds`" "$$LINE"
	done | tee $(LOGFILE)

plot: $(MAKEFILE2DOT_PLOT)

results: $(RESULTS_NTCIR11) $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10) $(NTCIR_MATH_DENSITY_ALL)

$(MAKEFILE2DOT):
	set -e
	$(call GIT_CHECKOUT,$(MAKEFILE2DOT_URL),$(MAKEFILE2DOT_REF),$@)

$(MAKEFILE2DOT_PLOT): $(MAKEFILE2DOT) $(MAKEFILES_DEFINITIONS) $(MAKEFILES_RECIPES)
	$(MAKEFILE2DOT_STARTUP) >$@

$(NTCIR_MATH_DENSITY_NTCIR11): $(JUDGEMENTS_NTCIR10_CONVERTED) $(JUDGEMENTS_NTCIR12) $(DATASET_NTCIR11_12) $(DATASET_NTCIR10_CONVERTED)
	set -e
	$(call GIT_CHECKOUT,$(NTCIR_MATH_DENSITY_URL),$(NTCIR_MATH_DENSITY_REF),$@)
	mkdir -p $(NTCIR_MATH_DENSITY_NTCIR11_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR_MATH_DENSITY_NTCIR11_VIRTUALENV)
	source $(NTCIR_MATH_DENSITY_NTCIR11_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install
	$(NTCIR_MATH_DENSITY_NTCIR11_STARTUP) \
	  --num-workers $(NTCIR_MATH_DENSITY_WORKERS) \
	  --datasets \
	    A=$(DATASET_NTCIR10_CONVERTED) \
	    B=$(DATASET_NTCIR11_12) \
	  --judgements \
	    $(addprefix A:,$(JUDGEMENTS_NTCIR10_CONVERTED)) \
	    $(addprefix B:,$(JUDGEMENTS_NTCIR12)) \
	  --estimates $(NTCIR_MATH_DENSITY_NTCIR11_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_NTCIR11_POSITIONS) \
	  --plots $(NTCIR_MATH_DENSITY_NTCIR11_PLOTS)

$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10): $(JUDGEMENTS_NTCIR11) $(JUDGEMENTS_NTCIR12) $(DATASET_NTCIR11_12)
	set -e
	$(call GIT_CHECKOUT,$(NTCIR_MATH_DENSITY_URL),$(NTCIR_MATH_DENSITY_REF),$@)
	mkdir -p $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_VIRTUALENV)
	source $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install
	$(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_STARTUP) \
	  --num-workers $(NTCIR_MATH_DENSITY_WORKERS) \
	  --datasets \
	    B=$(DATASET_NTCIR11_12) \
	  --judgements \
	    $(addprefix B:,$(JUDGEMENTS_NTRIC11) $(JUDGEMENTS_NTCIR12)) \
	  --estimates $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_POSITIONS) \
	  --plots $(NTCIR_MATH_DENSITY_ALL_WITHOUT_NTCIR10_PLOTS)

$(NTCIR_MATH_DENSITY_ALL): $(JUDGEMENTS_NTCIR10_CONVERTED) $(JUDGEMENTS_NTCIR11) $(JUDGEMENTS_NTCIR12) $(DATASET_NTCIR11_12) $(DATASET_NTCIR10_CONVERTED)
	set -e
	$(call GIT_CHECKOUT,$(NTCIR_MATH_DENSITY_URL),$(NTCIR_MATH_DENSITY_REF),$@)
	mkdir -p $(NTCIR_MATH_DENSITY_ALL_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR_MATH_DENSITY_ALL_VIRTUALENV)
	source $(NTCIR_MATH_DENSITY_ALL_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install
	$(NTCIR_MATH_DENSITY_ALL_STARTUP) --num-workers $(NTCIR_MATH_DENSITY_WORKERS) \
	  --datasets \
	    A=$(DATASET_NTCIR10_CONVERTED) \
		  B=$(DATASET_NTCIR11_12) \
	  --judgements \
	    $(addprefix A:,$(JUDGEMENTS_NTCIR10_CONVERTED)) \
	    $(addprefix B:,$(JUDGEMENTS_NTCIR11) $(JUDGEMENTS_NTCIR12)) \
	  --estimates $(NTCIR_MATH_DENSITY_ALL_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_ALL_POSITIONS) \
	  --plots $(NTCIR_MATH_DENSITY_ALL_PLOTS)

$(NTCIR10_MATH_CONVERTER):
	set -e
	$(call GIT_CHECKOUT,$(NTCIR10_MATH_CONVERTER_URL),$(NTCIR10_MATH_CONVERTER_REF),$@)
	mkdir -p $(NTCIR10_MATH_CONVERTER_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR10_MATH_CONVERTER_VIRTUALENV)
	source $(NTCIR10_MATH_CONVERTER_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install

$(DATASET_NTCIR10_CONVERTED): $(DATASET_NTCIR10) $(NTCIR10_MATH_CONVERTER)
	set -e
	$(NTCIR10_MATH_CONVERTER_STARTUP) \
	  --num-workers $(NTCIR10_MATH_CONVERTER_WORKERS) \
	  --dataset $< $@

JUDGEMENTS_NTCIR10_ALTERNATING=$(shell paste -d '\n' <(printf '%s\n' "$(JUDGEMENTS_NTCIR10)" | sed -r 's/\s+/\n/') <(printf '%s\n' "$(JUDGEMENTS_NTCIR10_CONVERTED)" | sed -r 's/\s+/\n/'))
$(JUDGEMENTS_NTCIR10_CONVERTED): $(DATASET_NTCIR10) $(JUDGEMENTS_NTCIR10) $(NTCIR10_MATH_CONVERTER)
	set -e
	cd $(NTCIR10_MATH_CONVERTER)
	source $(NTCIR10_MATH_CONVERTER_VIRTUALENV)/bin/activate
	ntcir10-math-converter --num-workers $(NTCIR10_MATH_CONVERTER_WORKERS) \
	  --dataset $< --judgements $(JUDGEMENTS_NTCIR10_ALTERNATING)

$(INDEX_NTCIR10): $(MIAS) $(DATASET_NTCIR10_CONVERTED)
	set -e
	cd $(MIAS)/target
	sed 's/^| //' >mias.properties <<'EOF'
	| INDEXDIR=$(INDEX_NTCIR10)
	| UPDATE=false
	| THREADS=$(MIAS_THREADS)
	| MAXRESULTS=$(INDEX_MAXRESULTS)
	| DOCLIMIT=-1
	| FORMULA_DOCUMENTS=false
	EOF
	mkdir -p $(INDEX_NTCIR10)
	$(MIAS_STARTUP) -conf mias.properties \
	  -overwrite "$(DATASET_NTCIR10_CONVERTED)/xhtml5" "$(DATASET_NTCIR10_CONVERTED)"

$(INDEX_NTCIR11_12): $(MIAS) $(DATASET_NTCIR11_12)
	set -e
	cd $(MIAS)/target
	sed 's/^| //' >mias.properties <<'EOF'
	| INDEXDIR=$(INDEX_NTCIR11_12)
	| UPDATE=false
	| THREADS=$(MIAS_THREADS)
	| MAXRESULTS=$(INDEX_MAXRESULTS)
	| DOCLIMIT=-1
	| FORMULA_DOCUMENTS=false
	EOF
	mkdir -p $(INDEX_NTCIR11_12)
	$(MIAS_STARTUP) -conf mias.properties \
	  -overwrite "$(DATASET_NTCIR11_12)/xhtml5" "$(DATASET_NTCIR11_12)"

$(WEBMIAS): $(MIAS) $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(WEBMIAS_URL),$(WEBMIAS_REF),$@)
	sed 's/^| //' >src/main/resources/cz/muni/fi/webmias/indexes.properties <<'EOF'
	| INDEX_NAMES=$(INDEX_NTCIR10_NAME),$(INDEX_NTCIR11_12_NAME)
	| PATHS=$(INDEX_NTCIR10),$(INDEX_NTCIR11_12)
	| STORAGES=$(DATASET_NTCIR10_CONVERTED),$(DATASET_NTCIR11_12)
	| MAXRESULTS=$(INDEX_MAXRESULTS)
	EOF
	$(MAVEN_MVN) clean install

$(MIAS): $(MIASMATH) $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MIAS_URL),$(MIAS_REF),$@)
	$(MAVEN_MVN) clean install

$(MIASMATH): $(MATHMLCAN) $(MATHMLUNIFICATOR) $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MIASMATH_URL),$(MIASMATH_REF),$@)
	(sed 's/^| //' | git apply) <<'EOF'
	| diff --git a/src/main/java/cz/muni/fi/mias/math/MathTokenizer.java b/src/main/java/cz/muni/fi/mias/math/MathTokenizer.java
	| index 53c7380..f2a0b44 100644
	| --- a/src/main/java/cz/muni/fi/mias/math/MathTokenizer.java
	| +++ b/src/main/java/cz/muni/fi/mias/math/MathTokenizer.java
	| @@ -418,7 +418,8 @@ public class MathTokenizer extends Tokenizer {
	|                  }
	|                  if (store && !MathMLConf.ignoreNode(name)) {
	|                      addFormula(position, new Formula(n, rank, originalRank));
	| -                    loadUnifiedNodes(n, rank, originalRank, position);
	| +                    // FIXME: structural unification disabled
	| +                    // loadUnifiedNodes(n, rank, originalRank, position);
	|                  }
	|              }
	|          }
	| @@ -696,7 +697,8 @@ public class MathTokenizer extends Tokenizer {
	|      private void modify() {
	|          unifyVariables(vCoef);
	|          unifyConst(cCoef);
	| -        unifyOperators(oCoef);
	| +        // FIXME: operator unification disabled
	| +        // unifyOperators(oCoef);
	|          processAttributes(aCoef);
	|      }
	|  
	EOF
	$(MAVEN_MVN) clean install

$(MATHMLCAN): $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MATHMLCAN_URL),$(MATHMLCAN_REF),$@)
	$(MAVEN_MVN) clean install

$(MATHMLUNIFICATOR): $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MATHMLUNIFICATOR_URL),$(MATHMLUNIFICATOR_REF),$@)
	$(MAVEN_MVN) clean install

$(MIREVAL): $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MIREVAL_URL),$(MIREVAL_REF),$@)
	$(MAVEN_MVN) clean install

$(NTCIR_MIAS_SEARCH): $(TOMCAT)
	set -e
	$(call GIT_CHECKOUT,$(NTCIR_MIAS_SEARCH_URL),$(NTCIR_MIAS_SEARCH_REF),$@)
	mkdir -p $(NTCIR_MIAS_SEARCH_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR_MIAS_SEARCH_VIRTUALENV)
	source $(NTCIR_MIAS_SEARCH_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install

$(RESULTS_NTCIR11): $(MIREVAL) $(TOPICS_NTCIR11) $(JUDGEMENTS_NTCIR11) $(NTCIR_MIAS_SEARCH) $(DATASET_NTCIR11_12) $(NTCIR_MATH_DENSITY_NTCIR11)
	set -e
	mkdir -p $@
	cd $@
	$(NTCIR_MIAS_SEARCH_STARTUP) \
	  --num-workers-querying $(NTCIR_MIAS_SEARCH_QUERYING_WORKERS) \
	  --num-workers-merging $(NTCIR_MIAS_SEARCH_MERGING_WORKERS) \
	  --dataset $(DATASET_NTCIR11_12) \
	  --topics $(TOPICS_NTCIR11) \
	  --judgements $(JUDGEMENTS_NTCIR11) \
	  --estimates $(NTCIR_MATH_DENSITY_NTCIR11_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_NTCIR11_POSITIONS) \
	  --webmias-url $(TOMCAT_WEBAPP_URL) \
	  --webmias-index-number $(INDEX_NTCIR11_12_NUMBER) \
	  --plots $(RESULTS_NTCIR11_PLOTS) \
	  --output-directory $@
	$(MIREVAL_STARTUP_PARALLEL) \
	  -tsvfile {} \
	  -qrels $(JUDGEMENTS_NTCIR11) \
	  -outputdir $@ \
	  -outputfile {.}.eval \
	  ::: $@/final_*.tsv

$(MAVEN): $(JDK)
	set -e
	$(CURL) "$(MAVEN_URL)" | tar xz
	# rm -rf ~/.m2  # Uncomment if you want to clean previous Maven repositories.

$(JDK):
	$(CURL) "$(JDK_URL)" | tar xz

$(TOMCAT): $(WEBMIAS) $(INDEX_NTCIR10) $(INDEX_NTCIR11_12)
	set -e
	$(CURL) "$(TOMCAT_URL)" | tar xz
	sed -i 's/port="/port="$(TOMCAT_PORT_PREFIX)/' "$@/conf/server.xml"
	cp --reflink=auto "$(WEBMIAS_WAR)" "$(TOMCAT_WAR)"
	$(TOMCAT_STARTUP)
	echo Deployed at $(TOMCAT_WEBAPP_URL)

clean:
	rm -rf $(INSTALL_DIRS)
