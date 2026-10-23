import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CampoFormulario extends StatefulWidget {
  final TextEditingController? controller;
  final String etiqueta;
  final IconData? icono;
  final Widget? sufijo;

  final TextInputType teclado;
  final bool autocorrect;
  final bool habilitado;
  final bool mostrarBotonVisibilidad;
  final bool ocultarTextoInicial;

  final int maxLineas;
  final int? maxLength;

  final Color? colorFondo;
  final Color? colorTexto;
  final Color? colorEtiqueta;
  final Color? colorIcono;
  final Color? colorBorde;
  final Color? colorBordeEnfocado;

  final double radioBorde;
  final double fuenteSize;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const CampoFormulario({
    super.key,
    this.controller,
    required this.etiqueta,
    this.icono,
    this.sufijo,
    this.teclado = TextInputType.text,
    this.autocorrect = true,
    this.habilitado = true,
    this.mostrarBotonVisibilidad = false,
    this.ocultarTextoInicial = true,
    this.maxLineas = 1,
    this.maxLength,
    this.colorFondo,
    this.colorTexto,
    this.colorEtiqueta,
    this.colorIcono,
    this.colorBorde,
    this.colorBordeEnfocado,
    this.radioBorde = 14,
    this.fuenteSize = 15,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<CampoFormulario> createState() =>
      _CampoFormularioState();
}

class _CampoFormularioState extends State<CampoFormulario> {
  late bool _ocultarTexto;

  @override
  void initState() {
    super.initState();
    _ocultarTexto = widget.ocultarTextoInicial;
  }

  @override
  Widget build(BuildContext context) {
    final Color texto =
        widget.colorTexto ?? AppColors.textoMasClaro;
    final Color etiquetaColor =
        widget.colorEtiqueta ?? AppColors.textoOscuro;
    final Color iconoColor =
        widget.colorIcono ?? AppColors.contenedorRojo;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.teclado,
      obscureText: widget.mostrarBotonVisibilidad
          ? _ocultarTexto
          : false,
      autocorrect: widget.autocorrect,
      enabled: widget.habilitado,
      maxLines: widget.mostrarBotonVisibilidad ||
              widget.maxLineas == 1
          ? 1
          : widget.maxLineas,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: TextStyle(
        color: texto,
        fontSize: widget.fuenteSize,
      ),
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        labelStyle: TextStyle(color: etiquetaColor),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.error)
                ? AppColors.textoRojo
                : states.contains(WidgetState.focused)
                    ? (widget.colorBordeEnfocado ?? AppColors.contenedorRojo)
                    : etiquetaColor,
          ),
        ),
        prefixIcon: widget.icono == null
            ? null
            : Icon(widget.icono, color: iconoColor),
        suffixIcon: _construirSufijo(),
        filled: widget.colorFondo != null,
        fillColor: widget.colorFondo,
        counterStyle: TextStyle(color: etiquetaColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radioBorde),
          borderSide: BorderSide(
            color: widget.colorBorde ?? AppColors.textoOscuro,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radioBorde),
          borderSide: BorderSide(
            color: widget.colorBorde ?? AppColors.textoOscuro,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radioBorde),
          borderSide: BorderSide(
            color: widget.colorBordeEnfocado ??
                AppColors.contenedorRojo,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radioBorde),
          borderSide: const BorderSide(
            color: AppColors.textoRojo,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.radioBorde),
          borderSide: const BorderSide(
            color: AppColors.textoRojo,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget? _construirSufijo() {
    if (widget.mostrarBotonVisibilidad) {
      return IconButton(
        onPressed: () {
          setState(() {
            _ocultarTexto = !_ocultarTexto;
          });
        },
        icon: Icon(
          _ocultarTexto
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: widget.colorIcono ?? AppColors.textoOscuro,
        ),
      );
    }

    return widget.sufijo;
  }
}