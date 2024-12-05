#ifndef PRINT_FUNCTION_ARGS_PASS_HPP
#define PRINT_FUNCTION_ARGS_PASS_HPP

#include "llvm/IR/Module.h"
#include "llvm/Pass.h"

class PrintFunctionArgsPass : public llvm::ModulePass {
public:
  static char ID;
  PrintFunctionArgsPass();

  bool runOnModule(llvm::Module &M) override;
};

#endif // PRINT_FUNCTION_ARGS_PASS_HPP