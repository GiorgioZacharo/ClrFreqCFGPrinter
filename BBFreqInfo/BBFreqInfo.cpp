//===---------------------------BBFreqInfo.cpp----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the Universita' della Svizzera italiana (USI Lugano) 
// Open Source License.
//
// Author         : Georgios Zacharopoulos 
// Date Started   : July, 2016
//
//===-------------------------------------------------------------------------===//
//
// Basic Block Frequency  Information.
//
// Print the Frequency of every BB in their respective Function using the run-time
// profiling information.
// (Used also for generating the Colour Freq CFG Craphs)
//
//
// -- NOTE --
//
// It provides information *only* for IR files that have been generated using 
// the Run-time Profiling Info file. (e.g. $BENCHMARK.profdata)
// (Thus they contain the "prof" annotation and entry Fumction frequency Info.)
//
//===-------------------------------------------------------------------------===//

#include "llvm/ADT/Statistic.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Metadata.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/RegionIterator.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/BlockFrequencyInfoImpl.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Format.h"
#include "llvm/Support/Debug.h"
#include <string>

using namespace llvm;

#define DEBUG_TYPE "BBFreqInfo"

namespace {
  struct BBFreqInfo : public FunctionPass {
    static char ID;

    BBFreqInfo() : FunctionPass(ID) {}

    // Iterate over the module to find its existing profiling information.
    bool runOnFunction(Function &F) override {

      BlockFrequencyInfo *BFI = &getAnalysis<BlockFrequencyInfoWrapperPass>().getBFI(); 

      // Get Entry Frequency of teh Function.
      int EntryFreq = getFunctionEntryFreq(F);

      // Iterate over the BB of each Function.
      for(Function::iterator BB = F.begin(), E = F.end(); BB != E; ++BB) {
        
        float BBFreqFloat = static_cast<float>(static_cast<float>(BFI->getBlockFreq(&*BB).getFrequency()) / static_cast<float>(BFI->getEntryFreq()));
        float BBFreq = BBFreqFloat * static_cast<float>(EntryFreq);
        int BBFrequency = static_cast<float>(BBFreq);

        // Print "Function Name - BB Name - BB Frequency"
        errs() << F.getName()  << " " << BB->getName() << " " << BBFrequency << "\n";
      }

      return false;
    }


    // Get Entry Frequency of the Function.
    int getFunctionEntryFreq(Function &F){

      int EntryFreq = 0;

      if (F.hasMetadata()) {

        MDNode *node = F.getMetadata("prof");

        if (MDString::classof(node->getOperand(0))) {
          auto mds = cast<MDString>(node->getOperand(0));
          std::string metadata_str = mds->getString();

          if (metadata_str == "function_entry_count"){
            if (ConstantInt *CI = mdconst::dyn_extract<ConstantInt>(node->getOperand(1))) {
              EntryFreq = CI->getSExtValue();
            }              
          }
        }     
      }

      return EntryFreq;
    }

    virtual void getAnalysisUsage(AnalysisUsage& AU) const override {
              

        AU.addRequired<BlockFrequencyInfoWrapperPass>();
        AU.setPreservesAll();
    }
  };
}

char BBFreqInfo::ID = 0;
static RegisterPass<BBFreqInfo> X("BBFreqInfo", "Extract Frequency of Execution for each BB.");
