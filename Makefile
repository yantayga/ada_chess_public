build: ./src/*
	gprbuild -gnatW8 -p -gnatn -O3 -q -P main.gpr -o ada-chess

build_debug: ./src/*
	gprbuild -gnatW8 -p -gnatd -g -q -P main.gpr -o ada-chess

uci:	build
	./obj/ada-chess uci

debug:	build_debug
	./obj/ada-chess debug

perft: build
	./obj/ada-chess perft 6

perft_debug: build_debug
	./obj/ada-chess perft_debug 2

prove:
	gnatprove -P main.gpr --checks-as-errors --level=4 --mode=check_all --counterexamples=on --pedantic --cwe -j 2

stylecheck: ./src/*
	gprbuild -gnaty -gnaty-m-s -q -P main.gpr -o ada-chess

clean:
	rm -rf ./obj/*

all:	build