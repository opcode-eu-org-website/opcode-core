# Copyright (c) 2019-2026 Robert Ryszard Paciorek <rrp@opcode.eu.org>
# 
# MIT License
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FORCE_UPDATE = false

SUDO_CMD = $(shell if [ "$$(id -u)" != "0" ]; then echo sudo TMPDIR=$$TMPDIR; fi)
SUDO_USER_CMD = $(shell if [ "$$SUDO_USER" != "" ]; then echo sudo -u $$SUDO_USER TMPDIR=$$TMPDIR; fi)


SVGICONURL  := https://bytebucket.org/OpCode-eu-org/svgiconset/raw/HEAD/other/

.PHONY: help installCoreDependencies installTextUtils checkout-submodules

help:
	@ cd $(MAINDIR) && awk '/^## / {x=0} x==1 {print $0} /^## Build/ {x=1}' README.md

installCoreDependencies:
	if ! command -v xml2xhtml.py > /dev/null || $(FORCE_UPDATE); then make installTextUtils; fi
	if ! command -v sch2img.sh > /dev/null || $(FORCE_UPDATE); then make installEDAlibs; fi

installEDAlibs:
	$(eval TEMP_DIR := $(shell $(SUDO_USER_CMD) mktemp -d))
	$(SUDO_USER_CMD) git clone https://bitbucket.org/OpCode-eu-org/eda-libs "$(TEMP_DIR)/eda-libs"
	cd "$(TEMP_DIR)/eda-libs" && $(SUDO_CMD) make installDependencies
	cd "$(TEMP_DIR)/eda-libs" && $(SUDO_CMD) make installTools
	cd "$(TEMP_DIR)/eda-libs" && $(SUDO_USER_CMD) make installLibs
	rm -fr "$(TEMP_DIR)"

installTextUtils:
	$(eval TEMP_DIR := $(shell $(SUDO_USER_CMD) mktemp -d))
	$(SUDO_USER_CMD) git clone https://bitbucket.org/OpCode-eu-org/TextUtils "$(TEMP_DIR)/TextUtils"
	cd "$(TEMP_DIR)/TextUtils" && $(SUDO_CMD) make installDependencies
	cd "$(TEMP_DIR)/TextUtils" && $(SUDO_CMD) make installTools
	rm -fr "$(TEMP_DIR)"

checkout-submodules:
	git submodule update --init --recursive


#
# include core makefile from TextUtils
#

-include /usr/local/share/TextUtils/buildWebSite.mk

$(TEXBUILDDIR)/pdfArticle.cls $(TEXBUILDDIR)/labels4easylist.sty $(TEXBUILDDIR)/vtable.sty $(TEXBUILDDIR)/ehhline.sty $(TEXBUILDDIR)/tikzPackets.sty:
	mkdir -p $(TEXBUILDDIR)
	wget -O "$@" "https://bitbucket.org/OpCode-eu-org/latex-libs/raw/HEAD/pkgs/$(@F)"
