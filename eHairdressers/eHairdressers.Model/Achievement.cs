namespace eHairdressers.Model
{
    public class Achievement
    {
        public int AchievementId { get; set; }
        public int UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public int PointsRewarded { get; set; }
        public DateTime EarnedDate { get; set; }
        public bool IsUnlocked { get; set; }
        public string Icon { get; set; } = string.Empty;
        public int Progress { get; set; }
        public int RequiredProgress { get; set; }
    }
}
