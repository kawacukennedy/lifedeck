import { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import { motion } from 'framer-motion';
import {
  Trophy,
  Star,
  Target,
  Award,
  Lock,
  CheckCircle,
  TrendingUp,
  Calendar,
  Heart,
  DollarSign,
  Clock,
  Leaf,
} from 'lucide-react';

interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: string;
  pointsRequired: number;
  isUnlocked: boolean;
  unlockedDate?: string;
  progress?: number;
  isUnlockable?: boolean;
}

interface AchievementStats {
  totalAchievements: number;
  unlockedAchievements: number;
  completionPercentage: number;
  totalPoints: number;
}

const categoryIcons = {
  health: Heart,
  finance: DollarSign,
  productivity: Clock,
  mindfulness: Leaf,
  general: Star,
};

const categoryColors = {
  health: 'text-red-400',
  finance: 'text-green-400',
  productivity: 'text-blue-400',
  mindfulness: 'text-purple-400',
  general: 'text-yellow-400',
};

export default function AchievementsPage() {
  const { user } = useStore();
  const [achievements, setAchievements] = useState<Achievement[]>([]);
  const [availableAchievements, setAvailableAchievements] = useState<Achievement[]>([]);
  const [stats, setStats] = useState<AchievementStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'unlocked' | 'available'>('unlocked');

  useEffect(() => {
    loadAchievements();
  }, []);

  const loadAchievements = async () => {
    setLoading(true);
    try {
      const [unlockedResponse, availableResponse, statsResponse] = await Promise.all([
        apiService.getUserAchievements?.() || Promise.resolve([]),
        apiService.getAvailableAchievements?.() || Promise.resolve([]),
        apiService.getAchievementStats?.() || Promise.resolve(null),
      ]);

      setAchievements(unlockedResponse);
      setAvailableAchievements(availableResponse);
      setStats(statsResponse);
    } catch (error) {
      console.error('Failed to load achievements:', error);
      // Fallback to sample data
      setAchievements([
        {
          id: 'first_streak',
          title: 'Getting Started',
          description: 'Complete cards for 3 days in a row',
          icon: '🔥',
          category: 'general',
          pointsRequired: 10,
          isUnlocked: true,
          unlockedDate: new Date().toISOString(),
        },
        {
          id: 'card_collector',
          title: 'Card Collector',
          description: 'Complete 10 coaching cards',
          icon: '🃏',
          category: 'general',
          pointsRequired: 15,
          isUnlocked: true,
          unlockedDate: new Date().toISOString(),
        },
      ]);
      setAvailableAchievements([
        {
          id: 'week_warrior',
          title: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          icon: '⚔️',
          category: 'general',
          pointsRequired: 25,
          isUnlocked: false,
          progress: 43,
          isUnlockable: true,
        },
        {
          id: 'health_hero',
          title: 'Health Hero',
          description: 'Achieve a health score of 80 or higher',
          icon: '❤️',
          category: 'health',
          pointsRequired: 50,
          isUnlocked: false,
          progress: 65,
          isUnlockable: true,
        },
      ]);
      setStats({
        totalAchievements: 15,
        unlockedAchievements: 2,
        completionPercentage: 13,
        totalPoints: 25,
      });
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-lifedeck-textSecondary">Loading achievements...</div>
        </div>
      </Layout>
    );
  }

  const unlockedAchievements = achievements.filter(a => a.isUnlocked);
  const lockedAchievements = availableAchievements.filter(a => !a.isUnlocked);

  return (
    <Layout>
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
            🏆 Achievements
          </h1>
          <p className="text-lifedeck-textSecondary">
            Track your progress and unlock rewards as you build better habits
          </p>
        </motion.div>

        {/* Stats Overview */}
        {stats && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8"
          >
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-2">
                <Trophy className="w-8 h-8 text-yellow-400" />
                <span className="text-2xl font-bold text-yellow-400">
                  {stats.unlockedAchievements}
                </span>
              </div>
              <div className="text-lifedeck-textSecondary">Unlocked</div>
            </div>

            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-2">
                <Target className="w-8 h-8 text-blue-400" />
                <span className="text-2xl font-bold text-blue-400">
                  {stats.completionPercentage}%
                </span>
              </div>
              <div className="text-lifedeck-textSecondary">Complete</div>
            </div>

            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-2">
                <Star className="w-8 h-8 text-purple-400" />
                <span className="text-2xl font-bold text-purple-400">
                  {stats.totalPoints}
                </span>
              </div>
              <div className="text-lifedeck-textSecondary">Points Earned</div>
            </div>

            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-2">
                <Award className="w-8 h-8 text-green-400" />
                <span className="text-2xl font-bold text-green-400">
                  {stats.totalAchievements - stats.unlockedAchievements}
                </span>
              </div>
              <div className="text-lifedeck-textSecondary">Remaining</div>
            </div>
          </motion.div>
        )}

        {/* Progress Bar */}
        {stats && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border mb-8"
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-lifedeck-text">
                Achievement Progress
              </h3>
              <span className="text-lifedeck-textSecondary">
                {stats.unlockedAchievements} of {stats.totalAchievements}
              </span>
            </div>
            <div className="w-full bg-lifedeck-background rounded-full h-3">
              <div
                className="bg-gradient-to-r from-lifedeck-primary to-green-400 h-3 rounded-full transition-all duration-500"
                style={{ width: `${stats.completionPercentage}%` }}
              />
            </div>
          </motion.div>
        )}

        {/* Tabs */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mb-8"
        >
          <div className="flex space-x-1 bg-lifedeck-surface rounded-lg p-1 border border-lifedeck-border">
            <button
              onClick={() => setActiveTab('unlocked')}
              className={`flex-1 py-3 px-6 rounded-md font-medium transition-colors ${
                activeTab === 'unlocked'
                  ? 'bg-lifedeck-primary text-white'
                  : 'text-lifedeck-textSecondary hover:text-lifedeck-text'
              }`}
            >
              Unlocked ({unlockedAchievements.length})
            </button>
            <button
              onClick={() => setActiveTab('available')}
              className={`flex-1 py-3 px-6 rounded-md font-medium transition-colors ${
                activeTab === 'available'
                  ? 'bg-lifedeck-primary text-white'
                  : 'text-lifedeck-textSecondary hover:text-lifedeck-text'
              }`}
            >
              Available ({lockedAchievements.length})
            </button>
          </div>
        </motion.div>

        {/* Achievements Grid */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {(activeTab === 'unlocked' ? unlockedAchievements : lockedAchievements).map((achievement, index) => {
            const CategoryIcon = categoryIcons[achievement.category as keyof typeof categoryIcons] || Star;
            const categoryColor = categoryColors[achievement.category as keyof typeof categoryColors] || 'text-gray-400';

            return (
              <motion.div
                key={achievement.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
                className={`bg-lifedeck-surface rounded-xl p-6 border transition-all duration-200 ${
                  achievement.isUnlocked
                    ? 'border-green-500/20 bg-green-500/5'
                    : 'border-lifedeck-border hover:border-lifedeck-primary/50'
                }`}
              >
                <div className="flex items-start space-x-4">
                  <div className={`text-3xl ${achievement.isUnlocked ? '' : 'grayscale opacity-50'}`}>
                    {achievement.icon}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-2">
                      <h3 className={`font-semibold ${
                        achievement.isUnlocked ? 'text-lifedeck-text' : 'text-lifedeck-textSecondary'
                      }`}>
                        {achievement.title}
                      </h3>
                      {achievement.isUnlocked && (
                        <CheckCircle className="w-5 h-5 text-green-400" />
                      )}
                    </div>

                    <p className={`text-sm mb-3 ${
                      achievement.isUnlocked ? 'text-lifedeck-textSecondary' : 'text-lifedeck-textSecondary'
                    }`}>
                      {achievement.description}
                    </p>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <CategoryIcon className={`w-4 h-4 ${categoryColor}`} />
                        <span className="text-xs text-lifedeck-textSecondary capitalize">
                          {achievement.category}
                        </span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Star className="w-4 h-4 text-yellow-400" />
                        <span className="text-sm font-medium text-yellow-400">
                          {achievement.pointsRequired}
                        </span>
                      </div>
                    </div>

                    {!achievement.isUnlocked && achievement.progress !== undefined && (
                      <div className="mt-4">
                        <div className="flex items-center justify-between mb-1">
                          <span className="text-xs text-lifedeck-textSecondary">Progress</span>
                          <span className="text-xs text-lifedeck-textSecondary">
                            {Math.round(achievement.progress)}%
                          </span>
                        </div>
                        <div className="w-full bg-lifedeck-background rounded-full h-2">
                          <div
                            className="bg-lifedeck-primary h-2 rounded-full transition-all duration-500"
                            style={{ width: `${achievement.progress}%` }}
                          />
                        </div>
                      </div>
                    )}

                    {achievement.isUnlocked && achievement.unlockedDate && (
                      <div className="mt-4 flex items-center space-x-1">
                        <Calendar className="w-4 h-4 text-green-400" />
                        <span className="text-xs text-green-400">
                          Unlocked {new Date(achievement.unlockedDate).toLocaleDateString()}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </motion.div>

        {/* Empty State */}
        {(activeTab === 'unlocked' ? unlockedAchievements : lockedAchievements).length === 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-12"
          >
            <Trophy className="w-16 h-16 text-lifedeck-textSecondary mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-lifedeck-text mb-2">
              {activeTab === 'unlocked' ? 'No achievements unlocked yet' : 'No achievements available'}
            </h3>
            <p className="text-lifedeck-textSecondary">
              {activeTab === 'unlocked'
                ? 'Complete cards and maintain streaks to unlock achievements!'
                : 'All available achievements have been unlocked. Great job!'
              }
            </p>
          </motion.div>
        )}
      </div>
    </Layout>
  );
}