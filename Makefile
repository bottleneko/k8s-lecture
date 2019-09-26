.DEFAULT_GOAL := lecture-presentation

.PHONY: lecture-presentation pull-mdp build push

DOCKER_MDP := docker run -it --rm -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) -e TERM=${TERM} -v $(PWD):/opt/presentation bottleneko/mdp

build:
	docker build --target mdp -t bottleneko/mdp .

push: build
	docker push bottleneko/mdp

pull:
	docker pull bottleneko/mdp

lecture-presentation: pull
	$(DOCKER_MDP) lecture/PRESENTATION.md

practice-presentation: pull
	$(DOCKER_MDP) practice/PRESENTATION.md
