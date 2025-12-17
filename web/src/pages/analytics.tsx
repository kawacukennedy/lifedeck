import { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import { motion } from 'framer-motion';
import {
  TrendingUp,
  TrendingDown,
  Target,
  Award,
  Calendar,
  BarChart3,
  PieChart,
  Activity,
} from 'lucide-react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
} from 'chart.js';
import { Line, Bar, Doughnut } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
);

interface AnalyticsData {
  progress: {
    healthScore: number;
    financeScore: number;
    productivityScore: number;
    mindfulnessScore: number;
    lifeScore: number;
    currentStreak: number;
    lifePoints: number;
    totalCardsCompleted: number;
  };
  insights: Array<{
    type: string;
    title: string;
    description: string;
    impact: string;
  }>;
  trends: {
    dates: string[];
    values: number[];
    trend: 'up' | 'down' | 'stable';
    average: number;
    bestDay: string;
  };
}

export default function AnalyticsPage() {
  const { user } = useStore();
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [timeframe, setTimeframe] = useState<'week' | 'month' | 'year'>('month');

  useEffect(() => {
    loadAnalytics();
  }, [timeframe]);

  const loadAnalytics = async () => {
    setLoading(true);
    try {
      const response = await apiService.getAnalytics(timeframe);
      setAnalytics(response);
    } catch (error) {
      console.error('Failed to load analytics:', error);
      // Fallback to user progress data
      if (user?.progress) {
        setAnalytics({
          progress: user.progress,
          insights: [],
          trends: {
            dates: [],
            values: [],
            trend: 'stable',
            average: 0,
            bestDay: '',
          },
        });
      }
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-lifedeck-textSecondary">Loading analytics...</div>
        </div>
      </Layout>
    );
  }

  if (!analytics) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-lifedeck-textSecondary">Failed to load analytics</div>
        </div>
      </Layout>
    );
  }

  const domainData = {
    labels: ['Health', 'Finance', 'Productivity', 'Mindfulness'],
    datasets: [
      {
        data: [
          analytics.progress.healthScore,
          analytics.progress.financeScore,
          analytics.progress.productivityScore,
          analytics.progress.mindfulnessScore,
        ],
        backgroundColor: [
          'rgba(76, 175, 80, 0.8)',
          'rgba(33, 150, 243, 0.8)',
          'rgba(255, 152, 0, 0.8)',
          'rgba(156, 39, 176, 0.8)',
        ],
        borderColor: [
          'rgba(76, 175, 80, 1)',
          'rgba(33, 150, 243, 1)',
          'rgba(255, 152, 0, 1)',
          'rgba(156, 39, 176, 1)',
        ],
        borderWidth: 2,
      },
    ],
  };

  const trendData = {
    labels: analytics.trends.dates,
    datasets: [
      {
        label: 'Daily Activity Points',
        data: analytics.trends.values,
        borderColor: 'rgb(33, 150, 243)',
        backgroundColor: 'rgba(33, 150, 243, 0.1)',
        tension: 0.4,
      },
    ],
  };

  return (
    <Layout>
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
            📊 Life Analytics
          </h1>
          <p className="text-lifedeck-textSecondary">
            Track your progress and gain insights into your life optimization journey
          </p>
        </motion.div>

        {/* Timeframe Selector */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mb-8"
        >
          <div className="flex space-x-2">
            {(['week', 'month', 'year'] as const).map((period) => (
              <button
                key={period}
                onClick={() => setTimeframe(period)}
                className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                  timeframe === period
                    ? 'bg-lifedeck-primary text-white'
                    : 'bg-lifedeck-background text-lifedeck-text hover:bg-lifedeck-border'
                }`}
              >
                {period.charAt(0).toUpperCase() + period.slice(1)}
              </button>
            ))}
          </div>
        </motion.div>

        {/* Key Metrics */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8"
        >
          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="flex items-center justify-between mb-2">
              <Target className="w-8 h-8 text-lifedeck-primary" />
              <span className="text-2xl font-bold text-lifedeck-primary">
                {analytics.progress.lifeScore.toFixed(1)}
              </span>
            </div>
            <div className="text-lifedeck-textSecondary">Life Score</div>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="flex items-center justify-between mb-2">
              <Activity className="w-8 h-8 text-green-400" />
              <span className="text-2xl font-bold text-green-400">
                {analytics.progress.currentStreak}
              </span>
            </div>
            <div className="text-lifedeck-textSecondary">Current Streak</div>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="flex items-center justify-between mb-2">
              <Award className="w-8 h-8 text-yellow-400" />
              <span className="text-2xl font-bold text-yellow-400">
                {analytics.progress.lifePoints}
              </span>
            </div>
            <div className="text-lifedeck-textSecondary">Life Points</div>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="flex items-center justify-between mb-2">
              <BarChart3 className="w-8 h-8 text-purple-400" />
              <span className="text-2xl font-bold text-purple-400">
                {analytics.progress.totalCardsCompleted}
              </span>
            </div>
            <div className="text-lifedeck-textSecondary">Cards Completed</div>
          </div>
        </motion.div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Domain Breakdown */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border"
          >
            <h3 className="text-xl font-bold text-lifedeck-text mb-4">
              Domain Breakdown
            </h3>
            <div className="h-64">
              <Doughnut
                data={domainData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      position: 'bottom' as const,
                    },
                  },
                }}
              />
            </div>
          </motion.div>

          {/* Activity Trends */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border"
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-bold text-lifedeck-text">
                Activity Trends
              </h3>
              <div className="flex items-center space-x-2">
                {analytics.trends.trend === 'up' && (
                  <TrendingUp className="w-5 h-5 text-green-400" />
                )}
                {analytics.trends.trend === 'down' && (
                  <TrendingDown className="w-5 h-5 text-red-400" />
                )}
                <span className={`text-sm font-medium ${
                  analytics.trends.trend === 'up' ? 'text-green-400' :
                  analytics.trends.trend === 'down' ? 'text-red-400' :
                  'text-lifedeck-textSecondary'
                }`}>
                  {analytics.trends.trend === 'up' ? 'Trending Up' :
                   analytics.trends.trend === 'down' ? 'Trending Down' :
                   'Stable'}
                </span>
              </div>
            </div>
            <div className="h-64">
              <Line
                data={trendData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  scales: {
                    y: {
                      beginAtZero: true,
                    },
                  },
                }}
              />
            </div>
          </motion.div>
        </div>

        {/* Insights */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border"
        >
          <h3 className="text-xl font-bold text-lifedeck-text mb-4">
            💡 Insights & Recommendations
          </h3>
          <div className="space-y-4">
            {analytics.insights.map((insight, index) => (
              <div
                key={index}
                className={`p-4 rounded-lg border ${
                  insight.impact === 'high'
                    ? 'border-green-500/20 bg-green-500/5'
                    : insight.impact === 'medium'
                    ? 'border-yellow-500/20 bg-yellow-500/5'
                    : 'border-gray-500/20 bg-gray-500/5'
                }`}
              >
                <div className="flex items-start space-x-3">
                  <div className={`p-2 rounded-full ${
                    insight.impact === 'high'
                      ? 'bg-green-500/20'
                      : insight.impact === 'medium'
                      ? 'bg-yellow-500/20'
                      : 'bg-gray-500/20'
                  }`}>
                    {insight.type === 'streak' && <Award className="w-4 h-4 text-green-400" />}
                    {insight.type === 'improvement' && <TrendingUp className="w-4 h-4 text-yellow-400" />}
                    {insight.type === 'achievement' && <Target className="w-4 h-4 text-blue-400" />}
                  </div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-lifedeck-text mb-1">
                      {insight.title}
                    </h4>
                    <p className="text-lifedeck-textSecondary text-sm">
                      {insight.description}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </Layout>
  );
}