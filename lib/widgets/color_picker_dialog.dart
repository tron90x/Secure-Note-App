import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final String title;
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: initialColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: initialColor.computeLuminance() > 0.5
                      ? Colors.grey
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  '#${initialColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                  style: TextStyle(
                    color: initialColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildColorGrid(context),
            const SizedBox(height: 16),
            _buildCustomColorPicker(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return GestureDetector(
          onTap: () {
            onColorSelected(color);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color == Colors.white ? Colors.grey : Colors.transparent,
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomColorPicker(BuildContext context) {
    return Column(
      children: [
        const Text('Custom Color'),
        const SizedBox(height: 8),
        ColorPicker(
          pickerColor: initialColor,
          onColorChanged: (color) {
            onColorSelected(color);
            Navigator.of(context).pop();
          },
          enableAlpha: false,
          labelTypes: const [],
          pickerAreaHeightPercent: 0.3,
        ),
      ],
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;
  final bool enableAlpha;
  final List<ColorLabelType> labelTypes;
  final double pickerAreaHeightPercent;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.enableAlpha = true,
    this.labelTypes = const [],
    this.pickerAreaHeightPercent = 0.3,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition =
                  box.globalToLocal(details.globalPosition);
              final double x = localPosition.dx.clamp(0, box.size.width);
              final double y = localPosition.dy.clamp(0, box.size.height);

              // Calculate color based on position
              final double hue = (x / box.size.width) * 360;
              final double saturation = 1.0 - (y / box.size.height);

              setState(() {
                _currentColor =
                    HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
              });
              widget.onColorChanged(_currentColor);
            },
            onPanEnd: (_) {
              widget.onColorChanged(_currentColor);
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 40,
          width: double.infinity,
          color: _currentColor,
          child: Center(
            child: Text(
              '#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
              style: TextStyle(
                color: _currentColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum ColorLabelType {
  rgb,
  hex,
  hsl,
}
