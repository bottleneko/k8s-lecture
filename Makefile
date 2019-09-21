.DEFAULT_GOAL := lecture-presentation

.PHONY: lecture-presentation pull-mdp build push

build:
	docker build --target mdp -t bottleneko/mdp .

push: build
	docker push bottleneko/mdp

pull:
	docker pull bottleneko/mdp

lecture-presentation: pull
	docker run -it --rm -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) -e TERM=${TERM} -v $(PWD):/opt/presentation bottleneko/mdp lecture/PRESENTATION.md
