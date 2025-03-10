; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S < %s | FileCheck %s

%struct1 = type { ptr, i32, i32, i32 }
%struct2 = type { i32, i32 }
%struct3 = type { i32, %struct4, %struct4 }
%struct4 = type { %struct2, %struct2 }

define i32 @test1(ptr %dm, i1 %tmp4, i64 %tmp9, i64 %tmp19) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[DM:%.*]], align 8
; CHECK-NEXT:    br i1 [[TMP4:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [[STRUCT2:%.*]], ptr [[TMP1]], i64 [[TMP9:%.*]]
; CHECK-NEXT:    store i32 0, ptr [[TMP10]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds [[STRUCT2]], ptr [[TMP1]], i64 [[TMP19:%.*]]
; CHECK-NEXT:    store i32 0, ptr [[TMP20]], align 4
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i64 [ [[TMP9]], [[BB1]] ], [ [[TMP19]], [[BB2]] ]
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds [[STRUCT2]], ptr [[TMP1]], i64 [[TMP0]], i32 1
; CHECK-NEXT:    [[TMP25:%.*]] = load i32, ptr [[TMP24]], align 4
; CHECK-NEXT:    ret i32 [[TMP25]]
;
bb:
  %tmp1 = load ptr, ptr %dm, align 8
  br i1 %tmp4, label %bb1, label %bb2

bb1:
  %tmp10 = getelementptr inbounds %struct2, ptr %tmp1, i64 %tmp9
  store i32 0, ptr %tmp10, align 4
  br label %bb3

bb2:
  %tmp20 = getelementptr inbounds %struct2, ptr %tmp1, i64 %tmp19
  store i32 0, ptr %tmp20, align 4
  br label %bb3

bb3:
  %phi = phi ptr [ %tmp10, %bb1 ], [ %tmp20, %bb2 ]
  %tmp24 = getelementptr inbounds %struct2, ptr %phi, i64 0, i32 1
  %tmp25 = load i32, ptr %tmp24, align 4
  ret i32 %tmp25
}

define i32 @test2(ptr %dm, i1 %tmp4, i64 %tmp9, i64 %tmp19) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[DM:%.*]], align 8
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [[STRUCT2:%.*]], ptr [[TMP1]], i64 [[TMP9:%.*]]
; CHECK-NEXT:    store i32 0, ptr [[TMP10]], align 4
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds [[STRUCT2]], ptr [[TMP1]], i64 [[TMP19:%.*]]
; CHECK-NEXT:    store i32 0, ptr [[TMP20]], align 4
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds nuw i8, ptr [[TMP10]], i64 4
; CHECK-NEXT:    [[TMP25:%.*]] = load i32, ptr [[TMP24]], align 4
; CHECK-NEXT:    ret i32 [[TMP25]]
;
bb:
  %tmp1 = load ptr, ptr %dm, align 8
  %tmp10 = getelementptr inbounds %struct2, ptr %tmp1, i64 %tmp9
  store i32 0, ptr %tmp10, align 4
  %tmp20 = getelementptr inbounds %struct2, ptr %tmp1, i64 %tmp19
  store i32 0, ptr %tmp20, align 4
  %tmp24 = getelementptr inbounds %struct2, ptr %tmp10, i64 0, i32 1
  %tmp25 = load i32, ptr %tmp24, align 4
  ret i32 %tmp25
}

; Check that instcombine doesn't insert GEPs before landingpad.

define i32 @test3(ptr %dm, i1 %tmp4, i64 %tmp9, i64 %tmp19, i64 %tmp20, i64 %tmp21) personality ptr @__gxx_personality_v0 {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br i1 [[TMP4:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT3:%.*]], ptr [[DM:%.*]], i64 [[TMP19:%.*]], i32 1
; CHECK-NEXT:    store i32 0, ptr [[TMP1]], align 4
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds [[STRUCT3]], ptr [[DM]], i64 [[TMP20:%.*]], i32 1, i32 0, i32 1
; CHECK-NEXT:    store i32 0, ptr [[TMP12]], align 4
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i64 [ [[TMP19]], [[BB1]] ], [ [[TMP20]], [[BB2]] ]
; CHECK-NEXT:    [[TMP22:%.*]] = invoke i32 @foo1(i32 11)
; CHECK-NEXT:            to label [[BB4:%.*]] unwind label [[BB5:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    ret i32 0
; CHECK:       bb5:
; CHECK-NEXT:    [[TMP27:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            catch ptr @_ZTIi
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT3]], ptr [[DM]], i64 [[TMP0]], i32 1
; CHECK-NEXT:    [[TMP35:%.*]] = getelementptr inbounds [[STRUCT4:%.*]], ptr [[TMP1]], i64 [[TMP21:%.*]], i32 1, i32 1
; CHECK-NEXT:    [[TMP25:%.*]] = load i32, ptr [[TMP35]], align 4
; CHECK-NEXT:    ret i32 [[TMP25]]
;
bb:
  br i1 %tmp4, label %bb1, label %bb2

bb1:
  %tmp1 = getelementptr inbounds %struct3, ptr %dm, i64 %tmp19, i32 1
  store i32 0, ptr %tmp1, align 4
  br label %bb3

bb2:
  %tmp2 = getelementptr inbounds %struct3, ptr %dm, i64 %tmp20, i32 1
  %tmp12 = getelementptr inbounds %struct4, ptr %tmp2, i64 0, i32 0, i32 1
  store i32 0, ptr %tmp12, align 4
  br label %bb3

bb3:
  %phi = phi ptr [ %tmp1, %bb1 ], [ %tmp2, %bb2 ]
  %tmp22 = invoke i32 @foo1(i32 11) to label %bb4 unwind label %bb5

bb4:
  ret i32 0

bb5:
  %tmp27 = landingpad { ptr, i32 } catch ptr @_ZTIi
  %tmp34 = getelementptr inbounds %struct4, ptr %phi, i64 %tmp21, i32 1
  %tmp35 = getelementptr inbounds %struct2, ptr %tmp34, i64 0, i32 1
  %tmp25 = load i32, ptr %tmp35, align 4
  ret i32 %tmp25
}

@_ZTIi = external constant ptr
declare i32 @__gxx_personality_v0(...)
declare i32 @foo1(i32)


; Check that instcombine doesn't fold GEPs into themselves through a loop
; back-edge.

define ptr @test4(i32 %value, ptr %buffer) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt i32 [[VALUE:%.*]], 127
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_HEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.header:
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       loop.body:
; CHECK-NEXT:    [[BUFFER_PN:%.*]] = phi ptr [ [[BUFFER:%.*]], [[LOOP_HEADER]] ], [ [[LOOPPTR:%.*]], [[LOOP_BODY]] ]
; CHECK-NEXT:    [[NEWVAL:%.*]] = phi i32 [ [[VALUE]], [[LOOP_HEADER]] ], [ [[SHR:%.*]], [[LOOP_BODY]] ]
; CHECK-NEXT:    [[LOOPPTR]] = getelementptr inbounds nuw i8, ptr [[BUFFER_PN]], i64 1
; CHECK-NEXT:    [[SHR]] = lshr i32 [[NEWVAL]], 7
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ugt i32 [[NEWVAL]], 16383
; CHECK-NEXT:    br i1 [[CMP2]], label [[LOOP_BODY]], label [[LOOP_EXIT:%.*]]
; CHECK:       loop.exit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[TMP0:%.*]] = phi ptr [ [[LOOPPTR]], [[LOOP_EXIT]] ], [ [[BUFFER]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[INCPTR3:%.*]] = getelementptr inbounds nuw i8, ptr [[TMP0]], i64 2
; CHECK-NEXT:    ret ptr [[INCPTR3]]
;
entry:
  %incptr = getelementptr inbounds i8, ptr %buffer, i64 1
  %cmp = icmp ugt i32 %value, 127
  br i1 %cmp, label %loop.header, label %exit

loop.header:
  br label %loop.body

loop.body:
  %loopptr = phi ptr [ %incptr, %loop.header ], [ %incptr2, %loop.body ]
  %newval = phi i32 [ %value, %loop.header ], [ %shr, %loop.body ]
  %shr = lshr i32 %newval, 7
  %incptr2 = getelementptr inbounds i8, ptr %loopptr, i64 1
  %cmp2 = icmp ugt i32 %shr, 127
  br i1 %cmp2, label %loop.body, label %loop.exit

loop.exit:
  %exitptr = phi ptr [ %incptr2, %loop.body ]
  br label %exit

exit:
  %ptr2 = phi ptr [ %exitptr, %loop.exit ], [ %incptr, %entry ]
  %incptr3 = getelementptr inbounds i8, ptr %ptr2, i64 1
  ret ptr %incptr3
}

@.str.4 = external unnamed_addr constant [100 x i8], align 1

; Instcombine shouldn't add new PHI nodes while folding GEPs if that will leave
; old PHI nodes behind as this is not clearly beneficial.
define void @test5(ptr %idx, ptr %in) #0 {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[IN:%.*]], align 8
; CHECK-NEXT:    [[INCDEC_PTR:%.*]] = getelementptr inbounds nuw i8, ptr [[TMP0]], i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, ptr [[INCDEC_PTR]], align 1
; CHECK-NEXT:    [[CMP23:%.*]] = icmp eq i8 [[TMP1]], 54
; CHECK-NEXT:    br i1 [[CMP23]], label [[WHILE_COND:%.*]], label [[IF_THEN_25:%.*]]
; CHECK:       if.then.25:
; CHECK-NEXT:    call void @g(ptr nonnull @.str.4)
; CHECK-NEXT:    br label [[WHILE_COND]]
; CHECK:       while.cond:
; CHECK-NEXT:    [[PTR:%.*]] = phi ptr [ [[INCDEC_PTR]], [[ENTRY:%.*]] ], [ [[INCDEC_PTR32:%.*]], [[WHILE_BODY:%.*]] ], [ [[INCDEC_PTR]], [[IF_THEN_25]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = load i8, ptr [[PTR]], align 1
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[TMP2]], 64
; CHECK-NEXT:    [[LNOT:%.*]] = icmp eq i8 [[AND]], 0
; CHECK-NEXT:    br i1 [[LNOT]], label [[WHILE_BODY]], label [[WHILE_COND_33:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    [[INCDEC_PTR32]] = getelementptr inbounds nuw i8, ptr [[PTR]], i64 1
; CHECK-NEXT:    br label [[WHILE_COND]]
; CHECK:       while.cond.33:
; CHECK-NEXT:    [[INCDEC_PTR34:%.*]] = getelementptr inbounds nuw i8, ptr [[PTR]], i64 1
; CHECK-NEXT:    br label [[WHILE_COND_57:%.*]]
; CHECK:       while.cond.57:
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, ptr [[INCDEC_PTR34]], align 1
; CHECK-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i64
; CHECK-NEXT:    [[ARRAYIDX61:%.*]] = getelementptr inbounds nuw i16, ptr [[IDX:%.*]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP5:%.*]] = load i16, ptr [[ARRAYIDX61]], align 2
; CHECK-NEXT:    [[AND63:%.*]] = and i16 [[TMP5]], 2048
; CHECK-NEXT:    [[TOBOOL64:%.*]] = icmp eq i16 [[AND63]], 0
; CHECK-NEXT:    br i1 [[TOBOOL64]], label [[WHILE_COND_73:%.*]], label [[WHILE_COND_57]]
; CHECK:       while.cond.73:
; CHECK-NEXT:    br label [[WHILE_COND_73]]
;
entry:
  %0 = load ptr, ptr %in
  %incdec.ptr = getelementptr inbounds i8, ptr %0, i32 1
  %1 = load i8, ptr %incdec.ptr, align 1
  %cmp23 = icmp eq i8 %1, 54
  br i1 %cmp23, label %while.cond, label %if.then.25

if.then.25:
  call void @g(ptr @.str.4)
  br label %while.cond

while.cond:
  %Ptr = phi ptr [ %incdec.ptr, %entry ], [ %incdec.ptr32, %while.body], [%incdec.ptr, %if.then.25 ]
  %2 = load i8, ptr %Ptr
  %and = and i8 %2, 64
  %lnot = icmp eq i8 %and, 0
  br i1 %lnot, label %while.body, label %while.cond.33

while.body:
  %incdec.ptr32 = getelementptr inbounds i8, ptr %Ptr, i32 1
  br label %while.cond

while.cond.33:
  %incdec.ptr34 = getelementptr inbounds i8, ptr %Ptr, i32 1
  br label %while.cond.57

while.cond.57:
  %3 = load i8, ptr %incdec.ptr34, align 1
  %conv59 = zext i8 %3 to i32
  %arrayidx61 = getelementptr inbounds i16, ptr %idx, i32 %conv59
  %4 = load i16, ptr %arrayidx61, align 2
  %and63 = and i16 %4, 2048
  %tobool64 = icmp eq i16 %and63, 0
  br i1 %tobool64, label %while.cond.73, label %while.cond.57

while.cond.73:
  br label %while.cond.73
}

declare void @g(ptr)
