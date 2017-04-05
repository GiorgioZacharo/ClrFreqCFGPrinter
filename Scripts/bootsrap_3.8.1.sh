#! /bin/sh

set -e

if [ -d "llvm-RS-3.8.1" ]; then
        echo "directory llvm-RS-3.8.1 exists, unable to continue."
        echo "Remove the existing llvm-RS-3.8.1 directory before bootstrapping."
        exit 1
fi

curl -O http://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz 
curl -O http://llvm.org/releases/3.8.1/cfe-3.8.1.src.tar.xz 

tar xf llvm-3.8.1.src.tar.xz
tar xf cfe-3.8.1.src.tar.xz
mv cfe-3.8.1.src llvm-3.8.1.src/tools/clang

mkdir "llvm-RS-3.8.1"
mv llvm-3.8.1.src llvm-RS-3.8.1/.

# Create build directory.
mkdir build
mv build llvm-RS-3.8.1/.
cd llvm-RS-3.8.1/build

# Build LLVM 3.8.1 and install it.
cmake $(pwd)/../llvm-3.8.1.src/
cmake --build .
cmake --build . --target install

# Copy the folder containing the BBFreqInfo pass to LLVM source tree.
cd ../..
cp -r BBFreqInfo llvm-RS-3.8.1/llvm-3.8.1.src/lib/Transforms/.
sed -i.bak 's/^\(PARALLEL_DIRS = .*\)/\1 BBFreqInfo/' llvm-RS-3.8.1/llvm-3.8.1.src/lib/Transforms/Makefile
echo "add_subdirectory(BBFreqInfo)" >> llvm-RS-3.8.1/llvm-3.8.1.src/lib/Transforms/CMakeLists.txt 

rm cfe-3.8.1.src.tar.xz  llvm-3.8.1.src.tar.xz
