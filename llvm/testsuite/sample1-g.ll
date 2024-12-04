; ModuleID = 'testsuite/sample1.c'
source_filename = "testsuite/sample1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.sample = type { i32, i32, ptr }

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1, !dbg !0

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @test(ptr noundef %0, ptr noundef %1) #0 !dbg !17 {
  %3 = alloca ptr, align 8
  %4 = alloca ptr, align 8
  store ptr %0, ptr %3, align 8
  call void @llvm.dbg.declare(metadata ptr %3, metadata !29, metadata !DIExpression()), !dbg !30
  store ptr %1, ptr %4, align 8
  call void @llvm.dbg.declare(metadata ptr %4, metadata !31, metadata !DIExpression()), !dbg !32
  %5 = load ptr, ptr %3, align 8, !dbg !33
  %6 = load i32, ptr %5, align 4, !dbg !34
  %7 = load ptr, ptr %4, align 8, !dbg !35
  %8 = getelementptr inbounds %struct.sample, ptr %7, i32 0, i32 1, !dbg !36
  store i32 %6, ptr %8, align 4, !dbg !37
  ret void, !dbg !38
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !39 {
  %1 = alloca i32, align 4
  %2 = alloca ptr, align 8
  %3 = alloca %struct.sample, align 8
  call void @llvm.dbg.declare(metadata ptr %1, metadata !42, metadata !DIExpression()), !dbg !43
  call void @llvm.dbg.declare(metadata ptr %2, metadata !44, metadata !DIExpression()), !dbg !45
  store i32 10, ptr %1, align 4, !dbg !46
  store ptr %1, ptr %2, align 8, !dbg !47
  call void @llvm.dbg.declare(metadata ptr %3, metadata !48, metadata !DIExpression()), !dbg !49
  %4 = getelementptr inbounds %struct.sample, ptr %3, i32 0, i32 0, !dbg !50
  store i32 20, ptr %4, align 8, !dbg !51
  %5 = load ptr, ptr %2, align 8, !dbg !52
  call void @test(ptr noundef %5, ptr noundef %3), !dbg !53
  %6 = getelementptr inbounds %struct.sample, ptr %3, i32 0, i32 1, !dbg !54
  %7 = load i32, ptr %6, align 4, !dbg !54
  %8 = getelementptr inbounds %struct.sample, ptr %3, i32 0, i32 0, !dbg !55
  %9 = load i32, ptr %8, align 8, !dbg !55
  %10 = add nsw i32 %7, %9, !dbg !56
  %11 = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %10), !dbg !57
  ret i32 0, !dbg !58
}

declare i32 @printf(ptr noundef, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.dbg.cu = !{!7}
!llvm.module.flags = !{!9, !10, !11, !12, !13, !14, !15}
!llvm.ident = !{!16}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 20, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "testsuite/sample1.c", directory: "/home/cby/llm-pca/01-project", checksumkind: CSK_MD5, checksum: "086ff607109bac3c6d0d457996aa6d0d")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 24, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 3)
!7 = distinct !DICompileUnit(language: DW_LANG_C99, file: !2, producer: "clang version 15.0.7", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !8, splitDebugInlining: false, nameTableKind: None)
!8 = !{!0}
!9 = !{i32 7, !"Dwarf Version", i32 5}
!10 = !{i32 2, !"Debug Info Version", i32 3}
!11 = !{i32 1, !"wchar_size", i32 4}
!12 = !{i32 7, !"PIC Level", i32 2}
!13 = !{i32 7, !"PIE Level", i32 2}
!14 = !{i32 7, !"uwtable", i32 2}
!15 = !{i32 7, !"frame-pointer", i32 2}
!16 = !{!"clang version 15.0.7"}
!17 = distinct !DISubprogram(name: "test", scope: !2, file: !2, line: 10, type: !18, scopeLine: 10, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !28)
!18 = !DISubroutineType(types: !19)
!19 = !{null, !20, !22}
!20 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !21, size: 64)
!21 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!22 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !23, size: 64)
!23 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "sample", file: !2, line: 4, size: 128, elements: !24)
!24 = !{!25, !26, !27}
!25 = !DIDerivedType(tag: DW_TAG_member, name: "x1", scope: !23, file: !2, line: 5, baseType: !21, size: 32)
!26 = !DIDerivedType(tag: DW_TAG_member, name: "x2", scope: !23, file: !2, line: 6, baseType: !21, size: 32, offset: 32)
!27 = !DIDerivedType(tag: DW_TAG_member, name: "next", scope: !23, file: !2, line: 7, baseType: !22, size: 64, offset: 64)
!28 = !{}
!29 = !DILocalVariable(name: "p", arg: 1, scope: !17, file: !2, line: 10, type: !20)
!30 = !DILocation(line: 10, column: 16, scope: !17)
!31 = !DILocalVariable(name: "s", arg: 2, scope: !17, file: !2, line: 10, type: !22)
!32 = !DILocation(line: 10, column: 34, scope: !17)
!33 = !DILocation(line: 11, column: 14, scope: !17)
!34 = !DILocation(line: 11, column: 13, scope: !17)
!35 = !DILocation(line: 11, column: 5, scope: !17)
!36 = !DILocation(line: 11, column: 8, scope: !17)
!37 = !DILocation(line: 11, column: 11, scope: !17)
!38 = !DILocation(line: 12, column: 1, scope: !17)
!39 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 13, type: !40, scopeLine: 13, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !28)
!40 = !DISubroutineType(types: !41)
!41 = !{!21}
!42 = !DILocalVariable(name: "a", scope: !39, file: !2, line: 14, type: !21)
!43 = !DILocation(line: 14, column: 9, scope: !39)
!44 = !DILocalVariable(name: "p", scope: !39, file: !2, line: 14, type: !20)
!45 = !DILocation(line: 14, column: 13, scope: !39)
!46 = !DILocation(line: 15, column: 7, scope: !39)
!47 = !DILocation(line: 16, column: 7, scope: !39)
!48 = !DILocalVariable(name: "s1", scope: !39, file: !2, line: 17, type: !23)
!49 = !DILocation(line: 17, column: 19, scope: !39)
!50 = !DILocation(line: 18, column: 8, scope: !39)
!51 = !DILocation(line: 18, column: 11, scope: !39)
!52 = !DILocation(line: 19, column: 10, scope: !39)
!53 = !DILocation(line: 19, column: 5, scope: !39)
!54 = !DILocation(line: 20, column: 20, scope: !39)
!55 = !DILocation(line: 20, column: 28, scope: !39)
!56 = !DILocation(line: 20, column: 23, scope: !39)
!57 = !DILocation(line: 20, column: 5, scope: !39)
!58 = !DILocation(line: 21, column: 1, scope: !39)
