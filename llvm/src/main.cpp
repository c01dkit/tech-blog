#include "llvm/IR/Module.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Pass.h"

#include "PrintFunctionNamesPass.hpp"
#include "PrintFunctionArgsPass.hpp"

using namespace llvm;

// Command-line option to specify multiple input .bc files
static cl::list<std::string> InputFilenames(cl::Positional,
                                            cl::desc("<input .bc files>"),
                                            cl::OneOrMore);

int main(int argc, char **argv) {
  cl::ParseCommandLineOptions(argc, argv, "Function Passes\n");

  LLVMContext Context;

  // Iterate through all input files
  for (const auto &InputFilename : InputFilenames) {
    SMDiagnostic Err;

    // Load the bitcode file
    std::unique_ptr<Module> Mod = parseIRFile(InputFilename, Err, Context);
    if (!Mod) {
      errs() << "Error reading bitcode file: " << InputFilename << "\n";
      Err.print(argv[0], errs());
      continue; // Skip to the next file if there's an error
    }

    errs() << "Analyzing file: " << InputFilename << "\n";

    // Create and run the function name pass
    PrintFunctionNamesPass NamePass;
    NamePass.runOnModule(*Mod);

    // Create and run the function argument pass
    PrintFunctionArgsPass ArgsPass;
    ArgsPass.runOnModule(*Mod);
  }

  return 0;
}