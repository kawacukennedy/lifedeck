import { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import { motion } from 'framer-motion';
import {
  Activity,
  Heart,
  Moon,
  Flame,
  TrendingUp,
  TrendingDown,
  Minus,
  Target,
  Calendar,
  RefreshCw,
  Plus,
  Settings,
} from 'lucide-react';
import { Button } from '../components/ButtonStyles';

interface HealthData {
  steps: number;
  calories: number;
  activeMinutes: number;
  sleepHours: number;
  heartRate?: number;
  date: string;
}

interface HealthInsights {
  averageSteps: number;
  averageCalories: number;
  averageSleep: number;
  activityTrend: 'increasing' | 'decreasing' | 'stable';
  sleepTrend: 'improving' | 'worsening' | 'stable';
  recommendations: string[];
  weeklyGoals: {
    steps: number;
    calories: number;
    sleep: number;
  };
}

export default function HealthPage() {
  const { user } = useStore();
  const [healthData, setHealthData] = useState<HealthData[]>([]);
  const [insights, setInsights] = useState<HealthInsights | null>(null);
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [showManualEntry, setShowManualEntry] = useState(false);
  const [manualData, setManualData] = useState({
    steps: '',
    calories: '',
    activeMinutes: '',
    sleepHours: '',
    date: new Date().toISOString().split('T')[0],
  });

  useEffect(() => {
    loadHealthData();
  }, []);

  const loadHealthData = async () => {
    try {
      setLoading(true);
      const [dataResponse, insightsResponse] = await Promise.all([
        apiService.getHealthData(30),
        apiService.getHealthInsights(30),
      ]);
      setHealthData(dataResponse);
      setInsights(insightsResponse);
    } catch (error) {
      console.error('Failed to load health data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSyncHealthData = async () => {
    setSyncing(true);
    try {
      await apiService.syncHealthData();
      await loadHealthData(); // Reload data after sync
    } catch (error) {
      console.error('Failed to sync health data:', error);
    } finally {
      setSyncing(false);
    }
  };

  const handleManualEntry = async () => {
    try {
      await apiService.storeManualHealthData({
        steps: parseInt(manualData.steps) || 0,
        calories: parseFloat(manualData.calories) || 0,
        activeMinutes: parseInt(manualData.activeMinutes) || 0,
        sleepHours: parseFloat(manualData.sleepHours) || 0,
        date: manualData.date,
      });
      setShowManualEntry(false);
      setManualData({
        steps: '',
        calories: '',
        activeMinutes: '',
        sleepHours: '',
        date: new Date().toISOString().split('T')[0],
      });
      await loadHealthData();
    } catch (error) {
      console.error('Failed to save manual health data:', error);
    }
  };

  const getTrendIcon = (trend: string) => {
    switch (trend) {
      case 'increasing':
      case 'improving':
        return <TrendingUp className="w-4 h-4 text-green-400" />;
      case 'decreasing':
      case 'worsening':
        return <TrendingDown className="w-4 h-4 text-red-400" />;
      default:
        return <Minus className="w-4 h-4 text-gray-400" />;
    }
  };

  const getTrendColor = (trend: string) => {
    switch (trend) {
      case 'increasing':
      case 'improving':
        return 'text-green-400';
      case 'decreasing':
      case 'worsening':
        return 'text-red-400';
      default:
        return 'text-gray-400';
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-96">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-lifedeck-primary"></div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
                Health Dashboard
              </h1>
              <p className="text-lifedeck-textSecondary">
                Track your physical activity, sleep, and overall wellness
              </p>
            </div>
            <div className="flex space-x-3">
              <Button
                onClick={() => setShowManualEntry(true)}
                variant="outline"
                className="flex items-center space-x-2"
              >
                <Plus className="w-4 h-4" />
                <span>Add Entry</span>
              </Button>
              <Button
                onClick={handleSyncHealthData}
                disabled={syncing}
                className="flex items-center space-x-2"
              >
                <RefreshCw className={`w-4 h-4 ${syncing ? 'animate-spin' : ''}`} />
                <span>{syncing ? 'Syncing...' : 'Sync Data'}</span>
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Health Insights */}
        {insights && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8"
          >
            {/* Steps */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-blue-500/10 rounded-lg flex items-center justify-center">
                    <Activity className="w-5 h-5 text-blue-400" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-lifedeck-text">Daily Steps</h3>
                    <p className="text-sm text-lifedeck-textSecondary">30-day average</p>
                  </div>
                </div>
                {getTrendIcon(insights.activityTrend)}
              </div>
              <div className="text-2xl font-bold text-lifedeck-text mb-2">
                {Math.round(insights.averageSteps).toLocaleString()}
              </div>
              <div className={`text-sm ${getTrendColor(insights.activityTrend)}`}>
                Goal: {insights.weeklyGoals.steps.toLocaleString()} steps/day
              </div>
            </div>

            {/* Sleep */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-purple-500/10 rounded-lg flex items-center justify-center">
                    <Moon className="w-5 h-5 text-purple-400" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-lifedeck-text">Sleep Hours</h3>
                    <p className="text-sm text-lifedeck-textSecondary">30-day average</p>
                  </div>
                </div>
                {getTrendIcon(insights.sleepTrend)}
              </div>
              <div className="text-2xl font-bold text-lifedeck-text mb-2">
                {insights.averageSleep.toFixed(1)}h
              </div>
              <div className={`text-sm ${getTrendColor(insights.sleepTrend)}`}>
                Goal: {insights.weeklyGoals.sleep}h per night
              </div>
            </div>

            {/* Calories */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-orange-500/10 rounded-lg flex items-center justify-center">
                    <Flame className="w-5 h-5 text-orange-400" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-lifedeck-text">Calories Burned</h3>
                    <p className="text-sm text-lifedeck-textSecondary">30-day average</p>
                  </div>
                </div>
                <TrendingUp className="w-4 h-4 text-green-400" />
              </div>
              <div className="text-2xl font-bold text-lifedeck-text mb-2">
                {Math.round(insights.averageCalories)}
              </div>
              <div className="text-sm text-lifedeck-textSecondary">
                Goal: {insights.weeklyGoals.calories} cal/day
              </div>
            </div>
          </motion.div>
        )}

        {/* Recommendations */}
        {insights && insights.recommendations.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border mb-8"
          >
            <h2 className="text-xl font-bold text-lifedeck-text mb-4 flex items-center space-x-2">
              <Target className="w-5 h-5 text-lifedeck-primary" />
              <span>Personalized Recommendations</span>
            </h2>
            <div className="space-y-3">
              {insights.recommendations.map((recommendation, index) => (
                <div key={index} className="flex items-start space-x-3 p-3 bg-lifedeck-background rounded-lg">
                  <div className="w-2 h-2 bg-lifedeck-primary rounded-full mt-2 flex-shrink-0"></div>
                  <p className="text-lifedeck-textSecondary">{recommendation}</p>
                </div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Recent Health Data */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="bg-lifedeck-surface rounded-xl border border-lifedeck-border overflow-hidden"
        >
          <div className="p-6 border-b border-lifedeck-border">
            <h2 className="text-xl font-bold text-lifedeck-text">Recent Activity</h2>
            <p className="text-lifedeck-textSecondary">Your health data from the last 30 days</p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-lifedeck-background">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-lifedeck-textSecondary uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-lifedeck-textSecondary uppercase tracking-wider">
                    Steps
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-lifedeck-textSecondary uppercase tracking-wider">
                    Calories
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-lifedeck-textSecondary uppercase tracking-wider">
                    Active Min
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-lifedeck-textSecondary uppercase tracking-wider">
                    Sleep
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-lifedeck-border">
                {healthData.slice(0, 10).map((data) => (
                  <tr key={data.date} className="hover:bg-lifedeck-background/50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-lifedeck-text">
                      {new Date(data.date).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-lifedeck-text">
                      {data.steps.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-lifedeck-text">
                      {Math.round(data.calories)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-lifedeck-text">
                      {data.activeMinutes}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-lifedeck-text">
                      {data.sleepHours.toFixed(1)}h
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>

        {/* Manual Entry Modal */}
        {showManualEntry && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-lifedeck-surface rounded-xl max-w-md w-full p-6 border border-lifedeck-border"
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-lifedeck-text">
                  Add Health Data
                </h3>
                <button
                  onClick={() => setShowManualEntry(false)}
                  className="text-lifedeck-textSecondary hover:text-lifedeck-text"
                >
                  <Settings className="w-6 h-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-lifedeck-text mb-2">
                    Date
                  </label>
                  <input
                    type="date"
                    value={manualData.date}
                    onChange={(e) => setManualData({ ...manualData, date: e.target.value })}
                    className="w-full px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Steps
                    </label>
                    <input
                      type="number"
                      placeholder="0"
                      value={manualData.steps}
                      onChange={(e) => setManualData({ ...manualData, steps: e.target.value })}
                      className="w-full px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Calories
                    </label>
                    <input
                      type="number"
                      placeholder="0"
                      value={manualData.calories}
                      onChange={(e) => setManualData({ ...manualData, calories: e.target.value })}
                      className="w-full px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Active Minutes
                    </label>
                    <input
                      type="number"
                      placeholder="0"
                      value={manualData.activeMinutes}
                      onChange={(e) => setManualData({ ...manualData, activeMinutes: e.target.value })}
                      className="w-full px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Sleep Hours
                    </label>
                    <input
                      type="number"
                      step="0.5"
                      placeholder="0"
                      value={manualData.sleepHours}
                      onChange={(e) => setManualData({ ...manualData, sleepHours: e.target.value })}
                      className="w-full px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text"
                    />
                  </div>
                </div>
              </div>

              <div className="flex space-x-3 mt-6">
                <Button
                  onClick={() => setShowManualEntry(false)}
                  variant="outline"
                  className="flex-1"
                >
                  Cancel
                </Button>
                <Button
                  onClick={handleManualEntry}
                  className="flex-1"
                >
                  Save Entry
                </Button>
              </div>
            </motion.div>
          </div>
        )}
      </div>
    </Layout>
  );
}