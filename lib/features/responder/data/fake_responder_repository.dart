import '../../../core/error/failure.dart';
import '../../../core/network/connectivity_helper.dart';
import 'models/responder_availability.dart';
import 'responder_repository.dart';

/// بيحفظ في الذاكرة بس.
class FakeResponderRepository implements ResponderRepository {
  ResponderAvailability _current = ResponderAvailability.offline;

  @override
  Future<ResponderAvailability> getAvailability() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _current;
  }

  @override
  Future<void> setAvailability(ResponderAvailability value) async {
    // زي الـ Backend الحقيقي: مفيش نت ← فشل
    if (await isOffline()) throw const NetworkFailure();
    await Future.delayed(const Duration(milliseconds: 400));
    _current = value;
  }
}