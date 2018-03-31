SHELL:=/bin/bash

all: init checkout copy_files add commit push

init:
	bash ./scripts/init.sh

checkout:
	bash ./scripts/checkout.sh

copy_files:
	bash ./scripts/copy_files.sh

add:
	bash ./scripts/add.sh

commit:
	-bash ./scripts/commit.sh

push:
	bash ./scripts/push.sh
