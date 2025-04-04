; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -sink-common-insts  -S < %s | FileCheck %s

; Test that we tail merge noreturn call blocks and phi constants properly.

declare void @abort()
declare void @assert_fail_1(i32)
declare void @assert_fail_1_alt(i32)

define void @merge_simple() {
; CHECK-LABEL: @merge_simple(
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A2:%.*]]
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont2:
; CHECK-NEXT:    [[C3:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C3]], label [[CONT3:%.*]], label [[A3:%.*]]
; CHECK:       a3:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont3:
; CHECK-NEXT:    ret void
;
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
a1:
  call void @assert_fail_1(i32 0)
  unreachable
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a2
a2:
  call void @assert_fail_1(i32 0)
  unreachable
cont2:
  %c3 = call i1 @foo()
  br i1 %c3, label %cont3, label %a3
a3:
  call void @assert_fail_1(i32 0)
  unreachable
cont3:
  ret void
}

define void @phi_three_constants() {
; CHECK-LABEL: @phi_three_constants(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A2:%.*]]
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1(i32 1)
; CHECK-NEXT:    unreachable
; CHECK:       cont2:
; CHECK-NEXT:    [[C3:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C3]], label [[CONT3:%.*]], label [[A3:%.*]]
; CHECK:       a3:
; CHECK-NEXT:    call void @assert_fail_1(i32 2)
; CHECK-NEXT:    unreachable
; CHECK:       cont3:
; CHECK-NEXT:    ret void
;
entry:
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
a1:
  call void @assert_fail_1(i32 0)
  unreachable
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a2
a2:
  call void @assert_fail_1(i32 1)
  unreachable
cont2:
  %c3 = call i1 @foo()
  br i1 %c3, label %cont3, label %a3
a3:
  call void @assert_fail_1(i32 2)
  unreachable
cont3:
  ret void
}

define void @dont_phi_values(i32 %x, i32 %y) {
; CHECK-LABEL: @dont_phi_values(
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 [[X:%.*]])
; CHECK-NEXT:    unreachable
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A2:%.*]]
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1(i32 [[Y:%.*]])
; CHECK-NEXT:    unreachable
; CHECK:       cont2:
; CHECK-NEXT:    ret void
;
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
a1:
  call void @assert_fail_1(i32 %x)
  unreachable
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a2
a2:
  call void @assert_fail_1(i32 %y)
  unreachable
cont2:
  ret void
}

define void @dont_phi_callees() {
; CHECK-LABEL: @dont_phi_callees(
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A2:%.*]]
; CHECK:       cont2:
; CHECK-NEXT:    ret void
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1_alt(i32 0)
; CHECK-NEXT:    unreachable
;
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a2
cont2:
  ret void
a1:
  call void @assert_fail_1(i32 0)
  unreachable
a2:
  call void @assert_fail_1_alt(i32 0)
  unreachable
}

declare i1 @foo()
declare i1 @bar()

define void @unmergeable_phis(i32 %v, i1 %c) {
; CHECK-LABEL: @unmergeable_phis(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[S1:%.*]], label [[S2:%.*]]
; CHECK:       s1:
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[A1:%.*]], label [[A2:%.*]]
; CHECK:       s2:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @bar()
; CHECK-NEXT:    br i1 [[C2]], label [[A1]], label [[A2]]
; CHECK:       a1:
; CHECK-NEXT:    [[L1:%.*]] = phi i32 [ 0, [[S1]] ], [ 1, [[S2]] ]
; CHECK-NEXT:    call void @assert_fail_1(i32 [[L1]])
; CHECK-NEXT:    unreachable
; CHECK:       a2:
; CHECK-NEXT:    [[L2:%.*]] = phi i32 [ 2, [[S1]] ], [ 3, [[S2]] ]
; CHECK-NEXT:    call void @assert_fail_1(i32 [[L2]])
; CHECK-NEXT:    unreachable
;
entry:
  br i1 %c, label %s1, label %s2
s1:
  %c1 = call i1 @foo()
  br i1 %c1, label %a1, label %a2
s2:
  %c2 = call i1 @bar()
  br i1 %c2, label %a1, label %a2
a1:
  %l1 = phi i32 [ 0, %s1 ], [ 1, %s2 ]
  call void @assert_fail_1(i32 %l1)
  unreachable
a2:
  %l2 = phi i32 [ 2, %s1 ], [ 3, %s2 ]
  call void @assert_fail_1(i32 %l2)
  unreachable
}

define void @tail_merge_switch(i32 %v) {
; CHECK-LABEL: @tail_merge_switch(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    switch i32 [[V:%.*]], label [[RET:%.*]] [
; CHECK-NEXT:      i32 0, label [[A1:%.*]]
; CHECK-NEXT:      i32 13, label [[A2:%.*]]
; CHECK-NEXT:      i32 42, label [[A3:%.*]]
; CHECK-NEXT:    ]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1(i32 1)
; CHECK-NEXT:    unreachable
; CHECK:       a3:
; CHECK-NEXT:    call void @assert_fail_1(i32 2)
; CHECK-NEXT:    unreachable
; CHECK:       ret:
; CHECK-NEXT:    ret void
;
entry:
  switch i32 %v, label %ret [
  i32 0, label %a1
  i32 13, label %a2
  i32 42, label %a3
  ]
a1:
  call void @assert_fail_1(i32 0)
  unreachable
a2:
  call void @assert_fail_1(i32 1)
  unreachable
a3:
  call void @assert_fail_1(i32 2)
  unreachable
ret:
  ret void
}

define void @need_to_add_bb2_preds(i1 %c1) {
; CHECK-LABEL: @need_to_add_bb2_preds(
; CHECK-NEXT:  bb1:
; CHECK-NEXT:    br i1 [[C1:%.*]], label [[BB2:%.*]], label [[A1:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @bar()
; CHECK-NEXT:    br i1 [[C2]], label [[A2:%.*]], label [[A3:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       a2:
; CHECK-NEXT:    call void @assert_fail_1(i32 1)
; CHECK-NEXT:    unreachable
; CHECK:       a3:
; CHECK-NEXT:    call void @assert_fail_1(i32 2)
; CHECK-NEXT:    unreachable
;
bb1:
  br i1 %c1, label %bb2, label %a1
bb2:
  %c2 = call i1 @bar()
  br i1 %c2, label %a2, label %a3

a1:
  call void @assert_fail_1(i32 0)
  unreachable
a2:
  call void @assert_fail_1(i32 1)
  unreachable
a3:
  call void @assert_fail_1(i32 2)
  unreachable
}

define void @phi_in_bb2() {
; CHECK-LABEL: @phi_in_bb2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A2:%.*]]
; CHECK:       a2:
; CHECK-NEXT:    [[P2:%.*]] = phi i32 [ 1, [[CONT1]] ], [ 2, [[CONT2]] ]
; CHECK-NEXT:    call void @assert_fail_1(i32 [[P2]])
; CHECK-NEXT:    unreachable
; CHECK:       cont2:
; CHECK-NEXT:    [[C3:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C3]], label [[CONT3:%.*]], label [[A2]]
; CHECK:       cont3:
; CHECK-NEXT:    ret void
;
entry:
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
a1:
  call void @assert_fail_1(i32 0)
  unreachable
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a2
a2:
  %p2 = phi i32 [ 1, %cont1 ], [ 2, %cont2 ]
  call void @assert_fail_1(i32 %p2)
  unreachable
cont2:
  %c3 = call i1 @foo()
  br i1 %c3, label %cont3, label %a2
cont3:
  ret void
}

; Don't tail merge these noreturn blocks using lifetime end. It prevents us
; from sharing stack slots for x and y.

declare void @escape_i32_ptr(ptr)
declare void @llvm.lifetime.start(i64, ptr nocapture)
declare void @llvm.lifetime.end(i64, ptr nocapture)

define void @dont_merge_lifetimes(i32 %c1, i32 %c2) {
; CHECK-LABEL: @dont_merge_lifetimes(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[Y:%.*]] = alloca i32, align 4
; CHECK-NEXT:    switch i32 [[C1:%.*]], label [[IF_END9:%.*]] [
; CHECK-NEXT:      i32 13, label [[IF_THEN:%.*]]
; CHECK-NEXT:      i32 42, label [[IF_THEN3:%.*]]
; CHECK-NEXT:    ]
; CHECK:       if.then:
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr nonnull [[X]])
; CHECK-NEXT:    store i32 0, ptr [[X]], align 4
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[C2:%.*]], 0
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[IF_END:%.*]], label [[IF_THEN1:%.*]]
; CHECK:       if.then1:
; CHECK-NEXT:    call void @escape_i32_ptr(ptr nonnull [[X]])
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr nonnull [[X]])
; CHECK-NEXT:    call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       if.then3:
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr nonnull [[Y]])
; CHECK-NEXT:    store i32 0, ptr [[Y]], align 4
; CHECK-NEXT:    [[TOBOOL5:%.*]] = icmp eq i32 [[C2]], 0
; CHECK-NEXT:    br i1 [[TOBOOL5]], label [[IF_END7:%.*]], label [[IF_THEN6:%.*]]
; CHECK:       if.then6:
; CHECK-NEXT:    call void @escape_i32_ptr(ptr nonnull [[Y]])
; CHECK-NEXT:    br label [[IF_END7]]
; CHECK:       if.end7:
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr nonnull [[Y]])
; CHECK-NEXT:    call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       if.end9:
; CHECK-NEXT:    ret void
;
entry:
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  switch i32 %c1, label %if.end9 [
  i32 13, label %if.then
  i32 42, label %if.then3
  ]

if.then:                                          ; preds = %entry
  call void @llvm.lifetime.start(i64 4, ptr nonnull %x)
  store i32 0, ptr %x, align 4
  %tobool = icmp eq i32 %c2, 0
  br i1 %tobool, label %if.end, label %if.then1

if.then1:                                         ; preds = %if.then
  call void @escape_i32_ptr(ptr nonnull %x)
  br label %if.end

if.end:                                           ; preds = %if.then1, %if.then
  call void @llvm.lifetime.end(i64 4, ptr nonnull %x)
  call void @abort()
  unreachable

if.then3:                                         ; preds = %entry
  call void @llvm.lifetime.start(i64 4, ptr nonnull %y)
  store i32 0, ptr %y, align 4
  %tobool5 = icmp eq i32 %c2, 0
  br i1 %tobool5, label %if.end7, label %if.then6

if.then6:                                         ; preds = %if.then3
  call void @escape_i32_ptr(ptr nonnull %y)
  br label %if.end7

if.end7:                                          ; preds = %if.then6, %if.then3
  call void @llvm.lifetime.end(i64 4, ptr nonnull %y)
  call void @abort()
  unreachable

if.end9:                                          ; preds = %entry
  ret void
}

; Dead phis in the block need to be handled.

declare void @llvm.dbg.value(metadata, i64, metadata, metadata)

define void @dead_phi() {
; CHECK-LABEL: @dead_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C1:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C1]], label [[CONT1:%.*]], label [[A1:%.*]]
; CHECK:       a1:
; CHECK-NEXT:    [[DEAD:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ 1, [[CONT1]] ]
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont1:
; CHECK-NEXT:    [[C2:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C2]], label [[CONT2:%.*]], label [[A1]]
; CHECK:       cont2:
; CHECK-NEXT:    [[C3:%.*]] = call i1 @foo()
; CHECK-NEXT:    br i1 [[C3]], label [[CONT3:%.*]], label [[A3:%.*]]
; CHECK:       a3:
; CHECK-NEXT:    call void @assert_fail_1(i32 0)
; CHECK-NEXT:    unreachable
; CHECK:       cont3:
; CHECK-NEXT:    ret void
;
entry:
  %c1 = call i1 @foo()
  br i1 %c1, label %cont1, label %a1
a1:
  %dead = phi i32 [ 0, %entry ], [ 1, %cont1 ]
  call void @assert_fail_1(i32 0)
  unreachable
cont1:
  %c2 = call i1 @foo()
  br i1 %c2, label %cont2, label %a1
cont2:
  %c3 = call i1 @foo()
  br i1 %c3, label %cont3, label %a3
a3:
  call void @assert_fail_1(i32 0)
  unreachable
cont3:
  ret void
}

define void @strip_dbg_value(i32 %c) {
; CHECK-LABEL: @strip_dbg_value(
; CHECK-NEXT:  entry:
; CHECK-NEXT:      #dbg_value(i32 [[C:%.*]], [[META5:![0-9]+]], !DIExpression(), [[META7:![0-9]+]])
; CHECK-NEXT:    switch i32 [[C]], label [[SW_EPILOG:%.*]] [
; CHECK-NEXT:      i32 13, label [[SW_BB:%.*]]
; CHECK-NEXT:      i32 42, label [[SW_BB1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       sw.bb:
; CHECK-NEXT:      #dbg_value(i32 55, [[META5]], !DIExpression(), [[META7]])
; CHECK-NEXT:    tail call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       sw.bb1:
; CHECK-NEXT:      #dbg_value(i32 67, [[META5]], !DIExpression(), [[META7]])
; CHECK-NEXT:    tail call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       sw.epilog:
; CHECK-NEXT:    ret void
;
entry:
  call void @llvm.dbg.value(metadata i32 %c, i64 0, metadata !12, metadata !13), !dbg !14
  switch i32 %c, label %sw.epilog [
  i32 13, label %sw.bb
  i32 42, label %sw.bb1
  ]

sw.bb:                                            ; preds = %entry
  call void @llvm.dbg.value(metadata i32 55, i64 0, metadata !12, metadata !13), !dbg !14
  tail call void @abort()
  unreachable

sw.bb1:                                           ; preds = %entry
  call void @llvm.dbg.value(metadata i32 67, i64 0, metadata !12, metadata !13), !dbg !14
  tail call void @abort()
  unreachable

sw.epilog:                                        ; preds = %entry
  ret void
}

define void @dead_phi_and_dbg(i32 %c) {
; CHECK-LABEL: @dead_phi_and_dbg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:      #dbg_value(i32 [[C:%.*]], [[META5]], !DIExpression(), [[META7]])
; CHECK-NEXT:    switch i32 [[C]], label [[SW_EPILOG:%.*]] [
; CHECK-NEXT:      i32 13, label [[SW_BB:%.*]]
; CHECK-NEXT:      i32 42, label [[SW_BB1:%.*]]
; CHECK-NEXT:      i32 53, label [[SW_BB2:%.*]]
; CHECK-NEXT:    ]
; CHECK:       sw.bb:
; CHECK-NEXT:    [[C_1:%.*]] = phi i32 [ 55, [[ENTRY:%.*]] ], [ 67, [[SW_BB1]] ]
; CHECK-NEXT:      #dbg_value(i32 [[C_1]], [[META5]], !DIExpression(), [[META7]])
; CHECK-NEXT:    tail call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       sw.bb1:
; CHECK-NEXT:    br label [[SW_BB]]
; CHECK:       sw.bb2:
; CHECK-NEXT:      #dbg_value(i32 84, [[META5]], !DIExpression(), [[META7]])
; CHECK-NEXT:    tail call void @abort()
; CHECK-NEXT:    unreachable
; CHECK:       sw.epilog:
; CHECK-NEXT:    ret void
;
entry:
  call void @llvm.dbg.value(metadata i32 %c, i64 0, metadata !12, metadata !13), !dbg !14
  switch i32 %c, label %sw.epilog [
  i32 13, label %sw.bb
  i32 42, label %sw.bb1
  i32 53, label %sw.bb2
  ]

sw.bb:                                            ; preds = %entry
  %c.1 = phi i32 [ 55, %entry], [ 67, %sw.bb1 ]
  call void @llvm.dbg.value(metadata i32 %c.1, i64 0, metadata !12, metadata !13), !dbg !14
  tail call void @abort()
  unreachable

sw.bb1:
  br label %sw.bb

sw.bb2:                                           ; preds = %entry
  call void @llvm.dbg.value(metadata i32 84, i64 0, metadata !12, metadata !13), !dbg !14
  tail call void @abort()
  unreachable

sw.epilog:                                        ; preds = %entry
  ret void
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "t.c", directory: "asdf")
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"PIC Level", i32 2}
!7 = distinct !DISubprogram(name: "f", scope: !1, file: !1, line: 2, isLocal: false, isDefinition: true, scopeLine: 2, flags: DIFlagPrototyped, isOptimized: true, unit: !0)
!12 = !DILocalVariable(name: "c", scope: !7)
!13 = !DIExpression()
!14 = !DILocation(line: 2, column: 12, scope: !7)
