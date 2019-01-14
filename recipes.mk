.ONESHELL:
.PHONY: all clean results plot analysis

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

results: $(RESULTS_NTCIR11)

$(MAKEFILE2DOT):
	set -e
	$(call GIT_CHECKOUT,$(MAKEFILE2DOT_URL),$(MAKEFILE2DOT_REF),$@)

$(MAKEFILE2DOT_PLOT): $(MAKEFILE2DOT) $(MAKEFILES_DEFINITIONS) $(MAKEFILES_RECIPES)
	$(MAKEFILE2DOT_STARTUP) >$@

$(NTCIR_MATH_DENSITY_NTCIR11_ONLY): $(JUDGEMENTS_NTCIR11) $(DATASET_NTCIR11_12)
	set -e
	$(call GIT_CHECKOUT,$(NTCIR_MATH_DENSITY_URL),$(NTCIR_MATH_DENSITY_REF),$@)
	mkdir -p $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_VIRTUALENV)
	virtualenv --clear -p "$$(which python3)" -- $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_VIRTUALENV)
	source $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_VIRTUALENV)/bin/activate
	pip install --upgrade pip setuptools wheel
	python setup.py install
	$(NTCIR_MATH_DENSITY_NTCIR11_ONLY_STARTUP) \
	  --num-workers $(NTCIR_MATH_DENSITY_WORKERS) \
	  --datasets \
	    B=$(DATASET_NTCIR11_12) \
	  --judgements \
	    $(addprefix B:,$(JUDGEMENTS_NTCIR11)) \
	  --estimates $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_POSITIONS) \
	  --plots $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_PLOTS)

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
	| INDEX_NAMES=$(INDEX_NTCIR11_12_NAME)
	| PATHS=$(INDEX_NTCIR11_12)
	| STORAGES=$(DATASET_NTCIR11_12)
	| MAXRESULTS=$(INDEX_MAXRESULTS)
	EOF
	(sed 's/^| //' | git apply) <<'EOF'
	| diff --git a/src/main/java/cz/muni/fi/service/search/Results.java b/src/main/java/cz/muni/fi/service/search/Results.java
	| index b26b068..1c7751f 100644
	| --- a/src/main/java/cz/muni/fi/service/search/Results.java
	| +++ b/src/main/java/cz/muni/fi/service/search/Results.java
	| @@ -35,7 +35,8 @@ public class Results {
	|      private int totalResults;
	|      private int startIndex;
	|      private int itemsPerPage;
	| -    private long time;
	| +    private long totalTime;
	| +    private long coreTime;
	|      @XmlElement(name = "Query")
	|      private Query query;
	| 
	| @@ -79,12 +80,20 @@ public class Results {
	|          this.totalResults = totalResults;
	|      }
	| 
	| -    public long getTime() {
	| -        return time;
	| +    public long getTotalTime() {
	| +        return totalTime;
	|      }
	| 
	| -    public void setTime(long time) {
	| -        this.time = time;
	| +    public void setTotalTime(long totalTime) {
	| +        this.totalTime = totalTime;
	| +    }
	| +
	| +    public long getCoreTime() {
	| +        return coreTime;
	| +    }
	| +
	| +    public void setCoreTime(long coreTime) {
	| +        this.coreTime = coreTime;
	|      }
	| 
	|  }
	| diff --git a/src/main/java/cz/muni/fi/service/search/SearchResource.java b/src/main/java/cz/muni/fi/service/search/SearchResource.java
	| index 6ff784a..29764b0 100644
	| --- a/src/main/java/cz/muni/fi/service/search/SearchResource.java
	| +++ b/src/main/java/cz/muni/fi/service/search/SearchResource.java
	| @@ -65,7 +65,8 @@ public class SearchResource {
	|          IndexSearcher is = indexDef.getIndexSearcher();
	|          Searching s = new Searching(is, indexDef.getStorage());
	|          SearchResult result = s.search(convertedQuery, false, offset, limit, false, extractSubformulae, reduceWeighting);
	| -        r.setTime(result.getTotalSearchTime());
	| +        r.setTotalTime(result.getTotalSearchTime());
	| +        r.setCoreTime(result.getCoreSearchTime());
	|          r.setTotalResults(result.getTotalResults());
	|          r.setItemsPerPage(limit);
	|          r.setStartIndex(offset);
	EOF
	$(MAVEN_MVN) clean install

$(MIAS): $(MIASMATH) $(MAVEN)
	set -e
	$(call GIT_CHECKOUT,$(MIAS_URL),$(MIAS_REF),$@)
	(sed 's/^| //' | git apply) <<'EOF'
	| diff --git a/src/main/java/cz/muni/fi/mias/MIaS.java b/src/main/java/cz/muni/fi/mias/MIaS.java
	| index 18151db..893cf70 100644
	| --- a/src/main/java/cz/muni/fi/mias/MIaS.java
	| +++ b/src/main/java/cz/muni/fi/mias/MIaS.java
	| @@ -37,6 +37,7 @@ public class MIaS {
	|                  Indexing i = new Indexing();
	|                  i.deleteIndexDir();
	|                  i.indexFiles(cmd.getOptionValues(Settings.OPTION_OVERWRITE)[0], cmd.getOptionValues(Settings.OPTION_OVERWRITE)[1]);
	| +                i.getStats();
	|              }
	|              if (cmd.hasOption(Settings.OPTION_OPTIMIZE)) {
	|                  Indexing i = new Indexing();
	| diff --git a/src/main/java/cz/muni/fi/mias/indexing/Indexing.java b/src/main/java/cz/muni/fi/mias/indexing/Indexing.java
	| index 0b66b0f..6ce3732 100644
	| --- a/src/main/java/cz/muni/fi/mias/indexing/Indexing.java
	| +++ b/src/main/java/cz/muni/fi/mias/indexing/Indexing.java
	| @@ -138,6 +138,7 @@ public class Indexing {
	|                                  if (progress % 10000 == 0) {
	|                                      printTimes();
	|                                      writer.commit();
	| +                                    getStats();
	|                                  }
	|                                  try {
	|                                      LOG.info("adding to index {} docId={}",doc.get("path"),doc.get("id"));
	EOF
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

$(RESULTS_NTCIR11): $(MIREVAL) $(TOPICS_NTCIR11) $(JUDGEMENTS_NTCIR11) $(NTCIR_MIAS_SEARCH) $(DATASET_NTCIR11_12) $(NTCIR_MATH_DENSITY_NTCIR11_ONLY)
	set -e
	mkdir -p $@
	cd $@
	$(NTCIR_MIAS_SEARCH_STARTUP) \
	  --num-workers-querying $(NTCIR_MIAS_SEARCH_QUERYING_WORKERS) \
	  --num-workers-merging $(NTCIR_MIAS_SEARCH_MERGING_WORKERS) \
	  --dataset $(DATASET_NTCIR11_12) \
	  --topics $(TOPICS_NTCIR11) \
	  --judgements $(JUDGEMENTS_NTCIR11) \
	  --estimates $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_ESTIMATES) \
	  --positions $(NTCIR_MATH_DENSITY_NTCIR11_ONLY_POSITIONS) \
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

$(TOMCAT): $(WEBMIAS) $(INDEX_NTCIR11_12)
	set -e
	$(CURL) "$(TOMCAT_URL)" | tar xz
	sed -i 's/port="/port="$(TOMCAT_PORT_PREFIX)/' "$@/conf/server.xml"
	cp --reflink=auto "$(WEBMIAS_WAR)" "$(TOMCAT_WAR)"
	$(TOMCAT_STARTUP)
	echo Deployed at $(TOMCAT_WEBAPP_URL)

clean:
	# rm -rf $(JAVA_SPECIFIC)
	rm -rf $(GIT_REPOS)
	rm -rf $(MAKEABLE)

analysis:
	set -e
	echo 'Total run time' >> $(ANALYSIS_FILE)
	echo '==============' >> $(ANALYSIS_FILE)
	grep 'GNU Make' <$(LOGFILE) >> $(ANALYSIS_FILE)
	grep "Successfully remade target file 'results'." <$(LOGFILE) >> $(ANALYSIS_FILE)
	echo '' >> $(ANALYSIS_FILE)
	echo 'MIaS indexing time + formulae count' >> $(ANALYSIS_FILE)
	echo '===================================' >> $(ANALYSIS_FILE)
	grep -A 4 'DONE in total time' <$(LOGFILE) >> $(ANALYSIS_FILE)
	echo '' >> $(ANALYSIS_FILE)
	echo 'Index size' >> $(ANALYSIS_FILE)
	echo '==========' >> $(ANALYSIS_FILE)
	grep -B 1 'Index size:' <$(LOGFILE) >> $(ANALYSIS_FILE)
	echo '--' >> $(ANALYSIS_FILE)
	du -sh $(INDEX_NTCIR11_12) >> $(ANALYSIS_FILE)
	echo '' >> $(ANALYSIS_FILE)
	echo 'MIaS search times' >> $(ANALYSIS_FILE)
	echo '=================' >> $(ANALYSIS_FILE)
	grep -r "<coreTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_CMath.*.response.xml > coreTimesCMath-$(ANALYSIS_FILENAME).txt
	grep -r "<coreTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_PMath.*.response.xml > coreTimesPMath-$(ANALYSIS_FILENAME).txt
	grep -r "<coreTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_PCMath.*.response.xml > coreTimesPCMath-$(ANALYSIS_FILENAME).txt
	grep -r "<coreTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_TeX.*.response.xml > coreTimesTeX-$(ANALYSIS_FILENAME).txt
	grep -r "<totalTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_CMath.*.response.xml > totalTimesCMath-$(ANALYSIS_FILENAME).txt
	grep -r "<totalTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_PMath.*.response.xml > totalTimesPMath-$(ANALYSIS_FILENAME).txt
	grep -r "<totalTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_PCMath.*.response.xml > totalTimesPCMath-$(ANALYSIS_FILENAME).txt
	grep -r "<totalTime>" $(RESULTS_NTCIR11)/NTCIR11-Math-*_TeX.*.response.xml > totalTimesTeX-$(ANALYSIS_FILENAME).txt
	echo 'TODO compute average search times..' >> $(ANALYSIS_FILE)
	echo '' >> $(ANALYSIS_FILE)
	mkdir $(ANALYSIS_FILENAME)
	mv $(ANALYSIS_FILE) $(ANALYSIS_FILENAME)
	mv coreTimesCMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/coreTimesCMath-$(ANALYSIS_FILENAME).txt
	mv coreTimesPMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/coreTimesPMath-$(ANALYSIS_FILENAME).txt
	mv coreTimesPCMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/coreTimesPCMath-$(ANALYSIS_FILENAME).txt
	mv coreTimesTeX-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/coreTimesTeX-$(ANALYSIS_FILENAME).txt
	mv totalTimesCMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/totalTimesCMath-$(ANALYSIS_FILENAME).txt
	mv totalTimesPMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/totalTimesPMath-$(ANALYSIS_FILENAME).txt
	mv totalTimesPCMath-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/totalTimesPCMath-$(ANALYSIS_FILENAME).txt
	mv totalTimesTeX-$(ANALYSIS_FILENAME).txt $(ANALYSIS_FILENAME)/totalTimesTeX-$(ANALYSIS_FILENAME).txt
	cp -r $(RESULTS_NTCIR11) $(ANALYSIS_FILENAME)
