1. Flutter install 3.22.2-stable
https://flutter-ko.dev/get-started/install/macos

2. Android Studio Koala 2024.1.1.11
https://developer.android.com/studio?hl=ko

3. 기타 설정
1) Android Studio > Plugins > Flutter 설치
2) Android Studio > Projects > More Actions > SDK Manager > SDK Tools 탭 > Android SDK Command-line Tools 설치
3) 환경변수 등록 (맥 터미널)
  touch ~/.zshrc > open ~/.zshrc (BASH 쉘이면 ~/.bash_profile) > source ~/.zshrc
  export PATH=”$PATH:flutter경로/bin” 추가하고 저장
4) 터미널에서 flutter doctor 입력해서 필요한 툴 모두 설치되어있는지 진단




*App 테스트
iOS - 아이폰 연결해서 앱 실행시키려면 Xcode에 애플 Development 인증서 필요 (현재 맥북에 셋팅되어 있음)
Device에서 mobile 선택 > Run > Flutter Run ‘main.dart’ in Release Mode > 암호 입력하라고 뜨면 그냥 아무것도 입력 안하고 확인버튼

*Web 테스트 : Chrome 선택하고 그냥 Run 하면 됨
