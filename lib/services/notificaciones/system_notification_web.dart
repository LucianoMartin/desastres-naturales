import 'dart:js_interop';

@JS('mostrarNotificacionSistema')
external JSPromise<JSBoolean> _mostrarNotificacionSistema(
  JSString titulo,
  JSString cuerpo,
);

Future<void> mostrarNotificacionSistema(
  String titulo,
  String cuerpo,
) async {
  await _mostrarNotificacionSistema(
    titulo.toJS,
    cuerpo.toJS,
  ).toDart;
}