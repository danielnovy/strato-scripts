repos  = $(shell ./yaml-reader.js stack.yaml packages | tr -d /)
branch = develop

repos-pull = $(repos:=-pull)
repos-push = $(repos:=-push)

install : pull stack.yaml
	@echo -e "\nBuilding and installing..."
	@stack install

pull : $(repos-pull)

push : $(repos-push)

$(repos-pull) : %-pull : | %
	@echo -e "\nPulling $*..."
	@GIT_MERGE_AUTOEDIT=no git subtree pull --squash -P $* $* $(branch)

$(repos-push) : %-push : | %
	@echo -e "\nPushing $*..."
	@git subtree push -P $* $* $(branch)

$(repos) : % :
	@git remote add $@ "git@github.com:blockapps/$*"
	@git subtree add --squash -P $@ $@ $(branch)

.PHONY : $(repos-pull) $(repos-push)
