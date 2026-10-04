class UserProgress {
  final int profileCompletion;
  final int guidanceCount;
  final int roadmapCompletedSteps;
  final int roadmapTotalSteps;
  final int placementReadinessScore;

  UserProgress({
    required this.profileCompletion,
    required this.guidanceCount,
    required this.roadmapCompletedSteps,
    required this.roadmapTotalSteps,
    required this.placementReadinessScore,
  });

  double get roadmapProgressFraction =>
      roadmapTotalSteps > 0 ? (roadmapCompletedSteps / roadmapTotalSteps) : 0.0;

  int get roadmapPercentage => (roadmapProgressFraction * 100).round();

  factory UserProgress.empty() {
    return UserProgress(
      profileCompletion: 0,
      guidanceCount: 0,
      roadmapCompletedSteps: 0,
      roadmapTotalSteps: 0,
      placementReadinessScore: 0,
    );
  }
}
