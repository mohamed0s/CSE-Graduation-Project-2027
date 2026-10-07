// This class is used to delay the loading of the app for a few seconds
// usage: AppDelay.delayLoading();
// It is used to show a splash screen for a few seconds
// It is also used to simulate a network request
// It is also used to show a loading indicator for a few seconds
// It is also used to show a loading screen for a few seconds
//To change the duration of the delay, change the value of the Duration in the delayLoading method

abstract class AppDelay {
  static Future<void> delayLoading() async {
    await Future.delayed(Duration(milliseconds: 700));
  }
}
