#include "PrintFunctionArgsPass.hpp"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

char PrintFunctionArgsPass::ID = 0;

PrintFunctionArgsPass::PrintFunctionArgsPass() : ModulePass(ID) {}

bool PrintFunctionArgsPass::runOnModule(Module &M) {
  // Iterate through all functions in the module and print the number of arguments
  for (Function &F : M) {
    if (!F.isDeclaration()) {
      errs() << "Function Name: " << F.getName() 
             << ", Argument Count: " << F.arg_size() << "\n";
    }
  }
  return false;
}