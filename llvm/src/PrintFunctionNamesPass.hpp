#ifndef PRINT_FUNCTION_NAMES_PASS_HPP
#define PRINT_FUNCTION_NAMES_PASS_HPP

#include "llvm/IR/Module.h"
#include "llvm/Pass.h"


class PrintFunctionNamesPass : public llvm::ModulePass {
public:
  static char ID;
  PrintFunctionNamesPass();

  bool runOnModule(llvm::Module &M) override;
};

#endif // PRINT_FUNCTION_NAMES_PASS_HPP