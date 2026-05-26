import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String? validateRequired(String? value, [String message = 'Campo requerido']) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailPattern.hasMatch(value.trim())) return 'Ingrese un email válido';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  final digitsOnly = value.trim().replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < 7) return 'Teléfono inválido';
  return null;
}

String? validateNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) return 'Ingrese solo números';
  return null;
}

String? validateMinLength(String? value, int minLength) {
  if (value == null || value.trim().isEmpty) return 'Campo requerido';
  if (value.trim().length < minLength) return 'Mínimo $minLength caracteres';
  return null;
}

String? validateDate(DateTime? value) {
  if (value == null) return 'Seleccione una fecha';
  return null;
}

// Widget de tarjeta personalizada para los formularios
class CustomCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? color;

  const CustomCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color ?? const Color(0xFF00A99D)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color ?? const Color(0xFF00A99D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF00A99D)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// Campo de texto personalizado
class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

// Campo de selección desplegable personalizado
class CustomDropdown extends StatelessWidget {
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;
  final String? value;
  final IconData? prefixIcon;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon ?? Icons.arrow_drop_down_circle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona una opción' : null,
    );
  }
}

// Selector de fecha personalizado
class CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final String? Function(DateTime?)? validator;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  field.didChange(picked);
                  onDateSelected(picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: field.errorText,
                ),
                child: Text(
                  field.value == null
                      ? 'Seleccione una fecha'
                      : '${field.value!.day}/${field.value!.month}/${field.value!.year}',
                  style: TextStyle(color: field.value == null ? Colors.grey : Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Botón personalizado
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF00A99D),
          side: const BorderSide(color: Color(0xFF00A99D)),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00A99D),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            )
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

// Pregunta de radio Sí/No personalizada
class CustomRadioQuestion extends StatelessWidget {
  final String question;
  final bool? value;
  final void Function(bool?) onChanged;

  const CustomRadioQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Sí'),
                value: true,
                groupValue: value,
                activeColor: const Color(0xFF00A99D),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => onChanged(val),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: value,
                activeColor: const Color(0xFF00A99D),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => onChanged(val),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Chip selector personalizado
class CustomChipSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onChanged;

  const CustomChipSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: selectedOptions.contains(option),
              onSelected: (selected) {
                if (selected) {
                  if (option == 'Ninguna') {
                    onChanged([option]);
                  } else {
                    final newList = List<String>.from(selectedOptions)
                      ..remove('Ninguna')
                      ..add(option);
                    onChanged(newList);
                  }
                } else {
                  final newList = List<String>.from(selectedOptions)..remove(option);
                  onChanged(newList);
                }
              },
              selectedColor: const Color(0xFF00A99D).withOpacity(0.2),
              checkmarkColor: const Color(0xFF00A99D),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Diálogo de éxito personalizado
Future<void> showSuccessDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.check_circle, color: Color(0xFF00A99D), size: 60),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
            child: const Text('Aceptar'),
          ),
        ),
      ],
    ),
  );
}

// Diálogo de error personalizado
Future<void> showErrorDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Error'),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D)),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

