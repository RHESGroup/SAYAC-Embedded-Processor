.PHONY:all
all: clean build run

.PHONY: build
build: sc_main

.PHONY: run
run: sc_main
	./sc_main

.PHONY: clean
clean: 
	rm -rf sc_main
	rm -rf *.vcd

sc_main: sc_main.cpp *.h *.cpp
	/usr/local/bin/g++-11 -L /usr/local/systemc-2.3.3/lib -I /usr/local/systemc-2.3.3/include/ -l systemc FIM.cpp sc_main.cpp -o sc_main

