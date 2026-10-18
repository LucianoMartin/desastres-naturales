import '../models/alerta.dart';
import '../repositories/alerta_repository.dart';

class AlertaService {
  final AlertaRepository _repository;

  AlertaService({AlertaRepository? repository})
    : _repository = repository ?? AlertaRepository();

  Stream<List<Alerta>> obtenerAlertas() {
    return _repository.obtenerAlertas();
  }
}
