#! /bin/sh

set -e

if [ -d "llvm-RS-3.8.0" ]; then
        echo "directory llvm-RS-3.8.0 exists, unable to continue."
        echo "Remove the existing llvm-RS-3.8.0 directory before bootstrapping."
        exit 1
fi

curl -O http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz 
curl -O http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz
curl -O http://llvm.org/releases/3.8.0/compiler-rt-3.8.0.src.tar.xz 

tar xf llvm-3.8.0.src.tar.xz
tar xf cfe-3.8.0.src.tar.xz
tar xf compiler-rt-3.8.0.src.tar.xz
mv cfe-3.8.0.src llvm-3.8.0.src/tools/clang
mv compiler-rt-3.8.0.src llvm-3.8.0.src/projects/compiler-rt

mkdir "llvm-RS-3.8.0"
mv llvm-3.8.0.src llvm-RS-3.8.0/.

# Create build directory.
mkdir build
mv build llvm-RS-3.8.0/.
cd llvm-RS-3.8.0/build

# Build LLVM 3.8.0 and install it.
cmake $(pwd)/../llvm-3.8.0.src/
cmake --build .
#cmake --build . --target install # Option for root access - not necessary.

# Copy the folder containing the BBFreqInfo pass to LLVM source tree.
cd ../..
cp -r BBFreqInfo llvm-RS-3.8.0/llvm-3.8.0.src/lib/Transforms/.
sed -i.bak 's/^\(PARALLEL_DIRS = .*\)/\1 BBFreqInfo/' llvm-RS-3.8.0/llvm-3.8.0.src/lib/Transforms/Makefile
echo "add_subdirectory(BBFreqInfo)" >> llvm-RS-3.8.0/llvm-3.8.0.src/lib/Transforms/CMakeLists.txt 

rm cfe-3.8.0.src.tar.xz  llvm-3.8.0.src.tar.xz
