# ClrFreqCFGPrinter

    ClrFreqCFGPrinter is an LLVM plug-in (version 3.8 or later) and is included in the 
    RegionSeeker© framework. It was developed by Georgios Zacharopoulos, under the supervision 
    of Prof. Laura Pozzi, within the HW/SW co-design Research Team at Universita' della Svizzera 
    italiana (USI Lugano) and under the scope of the research project Magic ISEs: Enlarging the 
    cope of Automatic Instruction Set Extension, supervised by Prof. Laura Pozzi.

    ClrFreqCFGPrinter is a tool for Color Frequency Annotated Control Flow Graph Generation, as 
    was presented in EuroLLVM 2017.

    It consists of one LLVM Analysis Pass: BBFreqInfo and several shell scripts that load the 
    pass and generate the Colour-annotated with respect to each Basic Block (BB) Execution 
    Frequency Control Flow Graph (CFG) PDF files.

    The rule to call it within the Makefile (aka Makefile_ClrFreqCFGPrinter) is: colour_freq_cfg

# Installation

    Install all necessary tools. (LLVM 3.8 and BBFreqInfo pass)

    If you already have one of the latest versions of LLVM installed (3.8 or later) proceed to B)
    otherwise proceed to A). (Follow only one of the two set of instructions, with A) being the 
    default and suggested one.)


    -- If *NO* LLVM framework is installed: --

    A) bootsrap_3.8.0.sh 


        ./bootstrap.3.8.0.sh


    Bootstrap llvm-RS-3.8.0 using the "bootstrap.sh" script. The script downloads the latest LLVM 
    version 3.8.0 needed to compile and load the BBFreqInfo pass. After building it, llvm-RS-3.8.0 
    can then be compiled using the following commands:

      cd "llvm-RS-3.8.0/build" && make

    If, for any reason, you move/rename the "llvm-RS-3.8.0" framework, then you have to modify the
    "BIN_DIR_LLVM" and "LIB_DIR_LLVM" Paths in the Makefile "Makefile_ClrFreqCFGPrinter" inside the 
    directory for each benchmark accordingly. 

    e.g. For the test jpeg benchmark, you have to modify the file: test/jpeg-6a/Makefile_ClrFreqCFGPrinter


    -- If LLVM framework IS already installed (version 3.8 or later): --

    B) bootstrap_BBFreqInfo.sh

    The script copies all the necessary files to your LLVM source tree. You NEED to edit though this
    line: 

        export LLVM_SRC_TREE="path/to/llvm/source/root"

    In order to provide the correct path to your LLVM source tree. 
     

        ./bootstrap_BBFreqInfo.sh


    Then you can recompile it using make and a new SO should be created in order to load the BBFreqInfo
    pass.

        cd "path/to/llvm/build" && make

    Remember that you also need to edit the paths inside the Makefile "Makefile_ClrFreqCFGPrinter" in 
    the directory of each benchmark accordingly.

     e.g. For the test jpeg benchmark, you have to modify the following lines in the file: 
     test/jpeg-6a/Makefile_ClrFreqCFGPrinter

        BIN_DIR_LLVM=path/to/llvm/build/bin
        LIB_DIR_LLVM=path/to/llvm/build/lib


    ** WARNING **

    The installation process is intended (and has been tested) only for Linux machines.
    For MAC OS there are other modifications that need to be done. (e.g. *.dylib instead of *.so 
    for loading LLVM passes.)

# Usage

    The Makefile is used as follows:

    make -f Makefile_orig colour_freq_cfg

# Testing

Quick testing (after installation is complete) that prints the Colour annotated Frequency CFG PDFs for jpeg Benchmark
    inside the CFG_colour_freq_graphs_cjpeg directory.

    It can be tested using the following commands:

    cd test/jpeg-6a/    
    make -f Makefile_orig run

# Methodology

The process is as follows:

    a) Profiling

        The existing tools of LLVM are used to generate an instrumented version of the binary of
        a provided benchmark.

        http://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation

        e.g.

         clang -O3 -fprofile-instr-generate bench.c -o bench_instrumented

        The bench.profdata file generated and used to generate the respective *.ir files of the 
        benchmark.

         bench_instrumented $(BENCH_COMMAND_LINE_PARAMETERS)
         llvm-profdata merge -output=$(BENCH).profdata default.profraw

         clang -S -emit-llvm -O3 -fprofile-instr-use=$(BENCH).profdata -o bench.ir bench.c


    b) Dot files

        Dot CFG files are generated for every IR file that has been generated in the previous step.    

     
    c) BB Frequency Info extracted

        The Analysis Pass is being in use by the gatherFreq.sh script. We are feeding them the *.ir 
        files that were produced in the first step (which contain the profiling info needed).

        BIN_DIR_LLVM=$(pwd)/llvm-RS-3.8.0/build/bin
        LIB_DIR_LLVM=$(pwd)/llvm-RS-3.8.0/build/lib

        $BIN_DIR_INSTRUM/opt -load LIB_DIR_LLVM/BBFreqInfo.so -O3 -BBFreqInfo -analyze -q *.ir
        
        The output from loading this pass provides us with the Frequency Info for each BB.

    d) Sort BBs and print PDFs
        
        Subsequently we sort the BBs in 8 groups from the Coldest to the Hottest.
        We identify them in the respective Dot files, modify them to the appropriate colour 
        using the Weather Map Temperature notation and print the PDF files in the 
        CFG_colour_freq_graphs_BENCHMARK directory.
 
Makefiles

    There is a Makefile_ClrFreqCFGPrinter file for every benchmark that needs minor modifications
    in order to be used for each of them or any other benchmark.

    The Makefile_ClrFreqCFGPrinter is included in the Makefile_orig of every benchmark.
    Makefile_orig is simply a copy of the original Makefile, which has been slightly 
    modified to use the Makefile_ClrFreqCFGPrinter. (to include the Makefile_ClrFreqCFGPrinter) 

    Modification of Makefiles

    Example in jpeg benchmark:

    Copy original Makefile to Makefile_orig and do the following:

    A) In Makefile_orig

        1) Comment out old CC. The new one clang 3.8 is going to be used.

        # The name of your C compiler:
        #CC= gcc

        2) Change CFLAGS to CFLAGS_orig

        # You may need to adjust these cc options:
        CFLAGS_orig= -O  -I$(srcdir)

        3) Include Makefile_ClrFreqCFGPrinter *after* objects definition.

        ....
        TROBJECTS= jpegtran.o rdswitch.o cdjpeg.o

        include Makefile_ClrFreqCFGPrinter
        ....

    B) In Makefile_ClrFreqCFGPrinter add the following:

        1) Add the Benchmark's name

        # BENCH Name
        BENCH=cjpeg

        2) Add the cmd line input parameters to run the binary (if needed).

        BENCH_COMMAND_LINE_PARAMETERS= -dct int -progressive -opt -outfile output_large_encode.jpeg ../input_large.ppm

        3) Add the benchmarks objects to construct the binary

        # Add the Objects needed to be compiled.
        
        BENCH_OBJECTS= $(COBJECTS) libjpeg.a

        4) Add the benchmark's source files that are going to generate the respective IR files.

        REGIONSOURCES= $(LIBSOURCES) $(APPSOURCES)


    RULES:

    profile

        The profile rule compiles all the needed objects and generates the instrumented
        version of the binary. Using the the bench.profdata file generated, the respective
        *.ir files are produced with the initial profiling annotation.


        e.g.
        
        make -f Makefile_orig profile
       


    colour_freq_cfg
        
       Produces the Colour-annotated with respect to each Basic Block (BB) Frequency
       Control Flow Graph (CFG) PDF files.

        e.g. 

        make -f Makefile_orig colour_freq_cfg




   ** Modifications are needed to comply for every benchmark. **

# Authors

Georgios Zacharopoulos <georgios.zacharopoulos@usi.ch>
Date: April, 2017
