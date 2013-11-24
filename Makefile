.PHONY: vundle-update vundle-repack no-dirty no-untracked

vundle-update: no-dirty no-untracked
	vim -c ':BundleList' -c ':!rm -rf .vim/bundle/*' -c ':BundleInstall' -c ':qall!'

vundle-repack:
	rm -rf .vim/bundle/*/.git
	git ls-files --deleted | xargs --no-run-if-empty git rm
	git add .
	git commit -m 'Updated plugins'

no-dirty:
	git diff-index --quiet HEAD || { echo 'git repository has uncommitted changes'; false; }
no-untracked:
	git ls-files --others --exclude-standard --error-unmatch . 2>/dev/null; [ $$? -eq 1 ] || { echo 'git repository has untracked files'; false; }
