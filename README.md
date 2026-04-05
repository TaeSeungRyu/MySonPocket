---

## 🛠 직접 설치(Sideloading) 가이드

배포용이 아닌 개인 배포(선물용)이므로 아래 절차대로 진행하시면 됩니다.

### 1. 사전 준비 (`pubspec.yaml`)
위 코드에 사용된 고유 ID 생성용 패키지를 추가해 주세요.
```yaml
dependencies:
flutter:
sdk: flutter
get: ^4.6.6
shared_preferences: ^2.2.2
uuid: ^4.3.3
```

### 2. APK 파일 생성
터미널(Terminal)에서 아래 명령어를 입력합니다.
```bash
flutter build apk --release
```
명령어가 완료되면 `build/app/outputs/flutter-apk/app-release.apk` 경로에 파일이 생성됩니다.

### 3. 핸드폰에 설치
1.  생성된 `app-release.apk` 파일을 카카오톡 나에게 보내기나 메일로 핸드폰에 전송합니다.
2.  핸드폰에서 파일을 다운로드하고 실행합니다.
3.  **"출처를 알 수 없는 앱 설치"** 허용 팝업이 뜨면 **'허용'**을 눌러 진행합니다.

### 팁: 초등학생 눈높이 맞춤
* **아이콘 변경**: `assets/icon.png`를 예쁜 이미지로 바꾸고 `flutter_launcher_icons` 패키지를 쓰면 더 "진짜 앱" 같아집니다.
* **색상**: `primarySwatch`를 `Colors.pink`나 아이가 좋아하는 색상으로 바꾸면 더 좋아할 거예요.