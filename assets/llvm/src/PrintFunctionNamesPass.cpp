#include "PrintFunctionNamesPass.hpp"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

char PrintFunctionNamesPass::ID = 0;

PrintFunctionNamesPass::PrintFunctionNamesPass() : ModulePass(ID) {}

bool PrintFunctionNamesPass::runOnModule(Module &M) {
  // Iterate through all functions in the module and print their names
  for (Function &F : M) {
    if (!F.isDeclaration()) {
      errs() << "Function Name: " << F.getName() << "\n";
    }
  }
  return false;
}