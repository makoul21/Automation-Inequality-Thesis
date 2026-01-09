# ==============================================================================
# SCRIPT 1: DESCRIPTIVE ANALYSIS & POLARIZATION TRENDS
# ==============================================================================
if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, ggthemes, viridis)

# 1. LOAD DATA (Relative Paths)
df_educ <- read.csv("data/Final_Panel_Education.csv")
df_ind  <- read.csv("data/Final_Panel_Industry.csv")

# 2. DATA PROCESSING: JOB POLARIZATION
df_plot <- df_educ %>%
  filter(Year >= 2003) %>%
  select(Country_Code, Year, Educational_Level, Employment_Thousands, Robot_Density_Proxy) %>%
  pivot_wider(names_from = Educational_Level, values_from = Employment_Thousands) %>%
  na.omit() %>%
  mutate(
    LEVEL5_8 = ALL_LEVELS - (LEVEL2 + LEVEL4),
    Share_Low  = (LEVEL2 / ALL_LEVELS) * 100,
    Share_Mid  = (LEVEL4 / ALL_LEVELS) * 100,
    Share_High = (LEVEL5_8 / ALL_LEVELS) * 100
  )

df_shares_long <- df_plot %>%
  select(Country_Code, Year, Share_Low, Share_Mid, Share_High) %>%
  pivot_longer(cols = starts_with("Share"), names_to = "Skill_Group", values_to = "Share") %>%
  mutate(Skill_Group = case_when(
    Skill_Group == "Share_Low" ~ "Low Skilled (Level 0-2)",
    Skill_Group == "Share_Mid" ~ "Middle Skilled (Level 3-4)",
    Skill_Group == "Share_High" ~ "High Skilled (Level 5-8)"
  ))

# FIGURE 1: JOB POLARIZATION TREND
p1 <- df_shares_long %>%
  group_by(Year, Skill_Group) %>%
  summarise(Avg_Share = mean(Share, na.rm=TRUE), .groups="drop") %>%
  ggplot(aes(x = Year, y = Avg_Share, color = Skill_Group)) +
  geom_line(size = 1.5) +
  theme_minimal() +
  labs(title = "Figure 1: Job Polarization in Europe", y = "Share (%)")
ggsave("figures/Fig1_Polarization_Trend.png", plot=p1, width=8, height=5)

# FIGURE 2: TECH VS HIGH SKILLED
p2 <- ggplot(df_plot, aes(x = Robot_Density_Proxy, y = Share_High)) +
  geom_point(alpha = 0.4, color = "darkgreen") +
  geom_smooth(method = "lm", color = "black") +
  theme_light() +
  labs(title = "Figure 2: Technology and High-Skilled Labor")
ggsave("figures/Fig2_Tech_vs_HighSkill.png", plot=p2, width=8, height=5)
