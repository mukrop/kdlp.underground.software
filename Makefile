SRC_DIR = src
DEST_DIR = /usr/share/nginx/html

HEADER = fragments/header.htmf
FOOTER = fragments/footer.htmf

MD_2_HTML = pandoc

SRC_FILES := $(shell find $(SRC_DIR) -type f)
DEST_FILES := $(patsubst %.md,%.html,$(subst $(SRC_DIR),$(DEST_DIR),$(SRC_FILES)))

define CONVERT_template =
$(1): $(2) $(HEADER) $(FOOTER)
	mkdir -p $(shell dirname $(1))
	if [ "$(suffix $(2))" = ".md" ]; then\
		cat $(HEADER) > $(1);\
		$(MD_2_HTML) $(2) >> $(1);\
		cat $(FOOTER) >> $(1);\
	else\
		cp $(2) $(1);\
	fi
endef

DETECT_DUPLICATES = $(if $(filter $(words $1),$(words $(sort $1))),,$1)
DEST_DUPLICATES := $(call DETECT_DUPLICATES,$(DEST_FILES))

.PHONY: clean all

ifeq ($(DEST_DUPLICATES),)
all: $(DEST_FILES)
else
$(error Duplicate destination file detected, do not put a .md and .html file that\
share a name in the same directory. [e.g. avoid src/index.html and src/index.md])
endif

$(foreach src_file, $(SRC_FILES),$(eval $(call CONVERT_template,\
	$(patsubst %.md,%.html,$(subst $(SRC_DIR),$(DEST_DIR),$(src_file))),\
	$(src_file))))

clean:
	rm -rf $(DEST_DIR)/*
