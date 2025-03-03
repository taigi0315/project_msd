/// 게임 사운드 효과 열거형
enum GameSound {
  /// 레벨업 사운드
  levelUp,
  
  /// XP 획득 사운드
  xpGain,
  
  /// 업적 획득 사운드
  achievementUnlocked,
  
  /// 미션 완료 사운드
  missionComplete,
  
  /// 버튼 클릭 사운드
  buttonClick,
  
  /// 칼 부딪히는 사운드
  swordClash,
  
  /// 작업 완료 사운드
  taskComplete,
  
  /// 성공 사운드
  success,
  
  /// 오류 사운드
  error,
}

/// 게임 애니메이션 열거형
enum GameAnimation {
  /// 레벨업 애니메이션
  levelUp,
  
  /// XP 획득 애니메이션
  xpGain,
  
  /// 업적 획득 애니메이션
  achievementUnlocked,
  
  /// 폭죽 애니메이션
  confetti,
  
  /// 칼 휘두르는 애니메이션
  swordSlash,
  
  /// 반짝임 애니메이션
  sparkle,
}

/// 효과 이벤트 타입 열거형
enum EffectEventType {
  /// 레벨업
  levelUp,
  
  /// XP 획득
  xpGain,
  
  /// 업적 획득
  achievementUnlocked,
  
  /// 미션 완료
  missionComplete,
  
  /// 작업 완료
  taskComplete,
} 