# ~\~ language=Make filename=99-bottles/Makefile
# ~\~ begin <<lit/99-bottles.md|99-bottles/Makefile>>[0]
.RECIPEPREFIX +=

# ~\~ begin <<lit/99-bottles.md|set-build-dir>>[0]
build_dir = ./build
# ~\~ end
# ~\~ begin <<lit/99-bottles.md|search-cc-files>>[0]
cc_files = $(shell find ./src -name *.cc)
# ~\~ end
# ~\~ begin <<lit/99-bottles.md|set-obj-files>>[0]
obj_files = $(cc_files:%.cc=$(build_dir)/%.o)
dep_files = $(obj_file:%.o=%.d)
# ~\~ end
# ~\~ begin <<lit/99-bottles.md|compile-flags>>[0]
compile = g++
link = g++

fmtlib_lflags = -lfmt

compile_flags = -std=c++14 -Wall -O3
link_flags = $(fmtlib_lflags)
# ~\~ end

# ~\~ begin <<lit/99-bottles.md|declare-target-rules>>[0]
.PHONY: clean build

build: $(build_dir)/99-bottles

clean:
	rm -rf $(build_dir)
# ~\~ end
# ~\~ begin <<lit/99-bottles.md|declare-pattern-rules>>[0]
-include $(dep_files)

$(build_dir)/%.o: %.cc
	@mkdir -p $(@D)
	$(compile) $(compile_flags) -MMD -c $< -o $@

$(build_dir)/99-bottles: $(obj_files)
	@mkdir -p $(@D)
	$(link) $^ $(link_flags) -o $@
# ~\~ end
# ~\~ end
