import 'dart:async';

class Debouncer {
  bool isExecuting;
  final int milliseconds;

  Debouncer({required this.isExecuting, required this.milliseconds});
}

void debounce(Debouncer debouncer, Function action) async {
  if (!debouncer.isExecuting) {
    debouncer.isExecuting = true;
    action();
    await Future.delayed(Duration(milliseconds: debouncer.milliseconds), () {
      debouncer.isExecuting = false;
    });
  }
}
