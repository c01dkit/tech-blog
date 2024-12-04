; ModuleID = 'testsuite/sample1.c'
source_filename = "testsuite/sample1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.sample = type { i32, i32, %struct.sample* }

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @test(i32* noundef %0, %struct.sample* noundef %1) #0 {
  %3 = alloca i32*, align 8
  %4 = alloca %struct.sample*, align 8
  store i32* %0, i32** %3, align 8
  store %struct.sample* %1, %struct.sample** %4, align 8
  %5 = load i32*, i32** %3, align 8
  %6 = load i32, i32* %5, align 4
  %7 = load %struct.sample*, %struct.sample** %4, align 8
  %8 = getelementptr inbounds %struct.sample, %struct.sample* %7, i32 0, i32 1
  store i32 %6, i32* %8, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32*, align 8
  %3 = alloca %struct.sample, align 8
  store i32 10, i32* %1, align 4
  store i32* %1, i32** %2, align 8
  %4 = getelementptr inbounds %struct.sample, %struct.sample* %3, i32 0, i32 0
  store i32 20, i32* %4, align 8
  %5 = load i32*, i32** %2, align 8
  call void @test(i32* noundef %5, %struct.sample* noundef %3)
  %6 = getelementptr inbounds %struct.sample, %struct.sample* %3, i32 0, i32 1
  %7 = load i32, i32* %6, align 4
  %8 = getelementptr inbounds %struct.sample, %struct.sample* %3, i32 0, i32 0
  %9 = load i32, i32* %8, align 8
  %10 = add nsw i32 %7, %9
  %11 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32 noundef %10)
  ret i32 0
}

declare i32 @printf(i8* noundef, ...) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 15.0.7"}
