import 'package:flutteversi/constants.dart';

extension ListExt<T> on List<T> {
  T pickRandom() {
    return this[random.nextInt(this.length)];
  }
}
