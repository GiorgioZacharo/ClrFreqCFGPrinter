#! /bin/sh

export LLVM_SRC_TREE="llvm-RS-3.8.1/llvm-3.8.1.src"

# Copy the folder containing the BBFreqInfo pass to LLVM source tree.
cp -r BBFreqInfo $LLVM_SRC_TREE/lib/Transforms/.
sed -i.bak 's/^\(PARALLEL_DIRS = .*\)/\1 BBFreqInfo/' $LLVM_SRC_TREE/lib/Transforms/Makefile
echo "add_subdirectory(BBFreqInfo)" >> $LLVM_SRC_TREE/lib/Transforms/CMakeLists.txt 

