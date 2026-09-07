# bs.world — Android APK build without Expo EAS

This project includes a GitHub Actions workflow at `.github/workflows/build-android-apk.yml`.
It builds an installable Android **debug APK** in the cloud, so an Expo/EAS account is not required for this test build.

The workflow runs automatically on pushes to `main`, or manually from GitHub Actions with **Run workflow**.

After the workflow finishes:
1. Open the workflow run.
2. Open **Artifacts**.
3. Download `bs-world-android-apk`.
4. Extract it and install `app-debug.apk` on an Android phone.

Note: this is an installable test APK. A signed Play Store production AAB requires a release signing setup.
