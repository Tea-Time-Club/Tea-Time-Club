build:
	rm -rf book theme/*
	mdbook build
	if [ -f .git2rss -a -x git2rss ] ; then ./git2rss > book/commits.xml ; fi

serve:
	rm -rf book theme/*
	mdbook serve --open --hostname 127.0.0.1

serve-all:
	rm -rf book theme/*
	mdbook serve --open --hostname 0.0.0.0

install:
	cargo install mdbook

###############################################################################
#
# Change the 'push' target to reference the specific target(s) you want the
# site to be published to. Examples:
#
#   push: rsync
#   push: gh-pages

push:

########################################
# IF you're going to publish the generated book to a web server, and you're
# able to use 'rsync' to upload the files ...
#
# - Change the 'push:' line to include the 'rsync' target
# - Edit the rsync command below as needed.
# - For Keybase Sites, the target will be a path under '/keybase/'. Seee
#   https://jms1.keybase.pub/kbsites/ for more specific examples.

rsync: build
	rsync -avz --delete book/ host.domain.xyz:/var/www/html/newbook/

########################################
# IF you're going to publish the generated book to GitHub Pages, using the
# same repo where you're tracking the source ...
#
# - Change the 'push:' line above to include the 'gh-pages' target
#
# NOTES:
# - These commands work for me using bash. If you're using some other shell,
#   you may need to adjust or remove this line.
# - The 'git worktree' commands require git version 2.0.7 or later.

gh-pages: build
	set -ex ; \
	WORK="$$( mktemp -d )" ; \
	PREVDIR="$(PWD)" ; \
	VER="$$( git describe --always --tags --dirty )" ; \
	git config user.name "github-actions" && \
	git config user.email "github-actions@github.com" && \
	git remote add origin https://x-access-token:$(GH_TOKEN)@github.com/Tea-Time-Club/Tea-Time-Club.git && \
	git branch -D gh-pages || true ; \
	git branch gh-pages origin/gh-pages ; \
	git worktree add --force "$$WORK" gh-pages ; \
	rm -rf "$$WORK"/* ; \
	rsync -av book/ "$$WORK"/ ; \
	if [ -f CNAME ] ; then cp CNAME "$$WORK"/ ; fi ; \
	cd "$$WORK" ; \
	git add -A ; \
	git commit -m "Updated gh-pages $$VER" ; \
	cd "$$PREVDIR" ; \
	git worktree remove "$$WORK" ; \
	git push origin gh-pages
