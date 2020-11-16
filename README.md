# *hello_me Application*

## *Part 1*

### *Dry*

1.	The class that is used to implement the controller pattern in the `snapping_sheet` library is
    `SnappingSheetController`. This controller allows the developer to control the sheet (current)
    position according to the position locations that were defined in the `snapPositions` array
    field.
    In addition, the developer can use the SnappingSheetController` to get the current position of
    the sheet in order to use it according to he's own uses.

2.	The parameter that controls the various different animations while snapping into position is
    the `snappingCurve` field in the `SnapPosition` class (along with the duration of the curve).

3.	One advantage of `InkWell` over `GestureDetector` is that `InkWell` includes ripple effect tap
    and `GestureDetector` does not.
    One advantage of `GestureDetector` over `InkWell` is that `GestureDetector` provides more
    controls like dragging, more options of tapping (but not ripple effect tap) etc.
