import 'package:flutter/material.dart';

class AddElevation extends StatefulWidget {
  final Widget child;
  final Color color;
  final BoxShape shape;
  final Border? border; // Optional border parameter
  final BorderRadius? borderRadius; // Optional BorderRadius parameter

  const AddElevation({
    super.key,
    required this.child,
    required this.color,
    this.shape = BoxShape.rectangle, // Default to rectangle if not provided
    this.border, // Accept border as an optional parameter
    this.borderRadius, // Accept BorderRadius as an optional parameter
  });

  @override
  State<AddElevation> createState() => _AddElevationState();
}

class _AddElevationState extends State<AddElevation> {
  @override
  Widget build(BuildContext context) {
    // Build the decoration conditionally based on the shape, border, and borderRadius
    var decoration = BoxDecoration(
      color: widget.color,
      boxShadow: [
        BoxShadow(
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(3, 4),
          color: Colors.grey.shade400,
        ),
      ],
      // Apply the border if it's not null
      border: widget.border,
    );

    // Modify the decoration based on the shape and optionally apply borderRadius
    if (widget.shape == BoxShape.rectangle) {
      decoration = decoration.copyWith(
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(10), // Apply custom or default borderRadius
        shape: widget.shape,
      );
    } else {
      decoration = decoration.copyWith(
        shape: widget.shape,
      );
    }

    return Container(
      decoration: decoration,
      child: widget.child,
    );
  }
}
