#!/bin/sh
PROG=synclient
echo edges
$PROG LeftEdge=1750
$PROG RightEdge=5178
$PROG TopEdge=1621
$PROG BottomEdge=5000
echo Finger Press
$PROG FingerLow=24
$PROG FingerHigh=29
$PROG FingerPress=255
echo taps time
$PROG MaxTapTime=180
$PROG MaxTapMove=220
$PROG MaxDoubleTapTime=180
$PROG SingleTapTimeout=180
$PROG ClickTime=100
$PROG FastTaps=1
echo emulate
$PROG EmulateMidButtonTime=75
$PROG EmulateTwoFingerMinZ=280
$PROG EmulateTwoFingerMinW=7
echo scrolling
$PROG VertScrollDelta=100
$PROG HorizScrollDelta=0
$PROG VertEdgeScroll=1
$PROG HorizEdgeScroll=1
$PROG CornerCoasting=0
$PROG VertTwoFingerScroll=0
$PROG HorizTwoFingerScroll=0
echo Pointer speed
$PROG MinSpeed=0.1
$PROG MaxSpeed=1
$PROG AccelFactor=1
$PROG TrackstickSpeed=0
$PROG EdgeMotionMinZ=29
$PROG EdgeMotionMaxZ=159
$PROG EdgeMotionMinSpeed=1
$PROG EdgeMotionMaxSpeed=401
$PROG EdgeMotionUseAlways=0
echo scrolling flags
$PROG UpDownScrolling=1
$PROG LeftRightScrolling=1
$PROG UpDownScrollRepeat=1
$PROG LeftRightScrollRepeat=1
$PROG ScrollButtonRepeat=100
echo Touchpad Mouse one/off
$PROG TouchpadOff=0
$PROG GuestMouseOff=0
echo dragging
$PROG LockedDrags=0
$PROG LockedDragTimeout=5000
echo corners
$PROG RTCornerButton=2
$PROG RBCornerButton=3
$PROG LTCornerButton=0
$PROG LBCornerButton=0
echo tap
$PROG TapButton1=1
$PROG TapButton2=2
$PROG TapButton3=3
echo click
$PROG ClickFinger1=1
$PROG ClickFinger2=3
$PROG ClickFinger3=2
echo Circular
$PROG CircularScrolling=0
$PROG CircScrollDelta=0.1
$PROG CircScrollTrigger=0
$PROG CircularPad=0
echo Palm
$PROG PalmDetect=0
$PROG PalmMinWidth=10
$PROG PalmMinZ=199
$PROG CoastingSpeed=0
echo Grab
$PROG GrabEventDevice=1
$PROG TapAndDragGesture=1
echo Area
$PROG AreaLeftEdge=0
$PROG AreaRightEdge=0
$PROG AreaTopEdge=0
$PROG AreaBottomEdge=0
echo Jumpy
$PROG JumpyCursorThreshold=60

