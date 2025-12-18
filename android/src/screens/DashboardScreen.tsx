import React, {useEffect, useState} from 'react';
import {View, Text, StyleSheet, ScrollView, Dimensions} from 'react-native';
import {useSelector} from 'react-redux';
import {RootState} from '../store';
import {LineChart, BarChart, PieChart} from 'react-native-chart-kit';
import {apiService} from '../services/api';

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
  trends: {
    dates: string[];
    values: number[];
    trend: 'up' | 'down' | 'stable';
  };
}

const DashboardScreen = () => {
  const user = useSelector((state: RootState) => state.user);
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);

  const isPremium = user?.subscriptionTier === 'premium';

  useEffect(() => {
    loadAnalytics();
  }, []);

  const loadAnalytics = async () => {
    try {
      if (isPremium) {
        const response = await apiService.getAnalytics('month');
        setAnalytics(response);
      } else {
        // Free users only get basic progress
        if (user?.progress) {
          setAnalytics({
            progress: user.progress,
            trends: {
              dates: [],
              values: [],
              trend: 'stable',
            },
          });
        }
      }
    } catch (error) {
      console.error('Failed to load analytics:', error);
      // Fallback to user progress
      if (user?.progress) {
        setAnalytics({
          progress: user.progress,
          trends: {
            dates: [],
            values: [],
            trend: 'stable',
          },
        });
      }
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Loading Analytics...</Text>
      </View>
    );
  }

  if (!analytics) {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Failed to load analytics</Text>
      </View>
    );
  }

  const screenWidth = Dimensions.get('window').width;

  const domainData = {
    labels: ['Health', 'Finance', 'Productivity', 'Mindfulness'],
    datasets: [{
      data: [
        analytics.progress.healthScore,
        analytics.progress.financeScore,
        analytics.progress.productivityScore,
        analytics.progress.mindfulnessScore,
      ],
    }],
  };

  const trendData = {
    labels: analytics.trends.dates.slice(-7), // Last 7 days
    datasets: [{
      data: analytics.trends.values.slice(-7),
    }],
  };

  const chartConfig = {
    backgroundGradientFrom: '#121212',
    backgroundGradientTo: '#121212',
    color: (opacity = 1) => `rgba(33, 150, 243, ${opacity})`,
    strokeWidth: 2,
    barPercentage: 0.5,
    useShadowColorFromDataset: false,
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Life Analytics Dashboard</Text>

      {/* Key Metrics */}
      <View style={styles.metricsContainer}>
        <View style={styles.metric}>
          <Text style={styles.metricValue}>{analytics.progress.lifeScore.toFixed(1)}</Text>
          <Text style={styles.metricLabel}>Life Score</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.metricValue}>{analytics.progress.currentStreak}</Text>
          <Text style={styles.metricLabel}>Current Streak</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.metricValue}>{analytics.progress.lifePoints}</Text>
          <Text style={styles.metricLabel}>Life Points</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.metricValue}>{analytics.progress.totalCardsCompleted}</Text>
          <Text style={styles.metricLabel}>Cards Completed</Text>
        </View>
      </View>

      {isPremium ? (
        <>
          {/* Domain Breakdown */}
          <View style={styles.chartContainer}>
            <Text style={styles.chartTitle}>Domain Breakdown</Text>
            <PieChart
              data={[
                {
                  name: 'Health',
                  population: analytics.progress.healthScore,
                  color: '#4CAF50',
                  legendFontColor: '#fff',
                  legendFontSize: 12,
                },
                {
                  name: 'Finance',
                  population: analytics.progress.financeScore,
                  color: '#2196F3',
                  legendFontColor: '#fff',
                  legendFontSize: 12,
                },
                {
                  name: 'Productivity',
                  population: analytics.progress.productivityScore,
                  color: '#FF9800',
                  legendFontColor: '#fff',
                  legendFontSize: 12,
                },
                {
                  name: 'Mindfulness',
                  population: analytics.progress.mindfulnessScore,
                  color: '#9C27B0',
                  legendFontColor: '#fff',
                  legendFontSize: 12,
                },
              ]}
              width={screenWidth - 40}
              height={220}
              chartConfig={chartConfig}
              accessor="population"
              backgroundColor="transparent"
              paddingLeft="15"
            />
          </View>

          {/* Activity Trends */}
          <View style={styles.chartContainer}>
            <Text style={styles.chartTitle}>Activity Trends (Last 7 Days)</Text>
            <LineChart
              data={trendData}
              width={screenWidth - 40}
              height={220}
              chartConfig={chartConfig}
              bezier
              style={styles.chart}
            />
          </View>

          {/* Trend Indicator */}
          <View style={styles.trendContainer}>
            <Text style={styles.trendText}>
              Trend: {analytics.trends.trend === 'up' ? '📈 Trending Up' :
                      analytics.trends.trend === 'down' ? '📉 Trending Down' :
                      '➡️ Stable'}
            </Text>
          </View>
        </>
      ) : (
        <View style={styles.premiumContainer}>
          <Text style={styles.premiumTitle}>🔓 Advanced Analytics</Text>
          <Text style={styles.premiumDescription}>
            Unlock detailed charts, trends, and insights with LifeDeck Premium
          </Text>
          <View style={styles.upgradeButton}>
            <Text style={styles.upgradeButtonText}>Upgrade to Premium</Text>
          </View>
        </View>
      )}
    </ScrollView>
  );
};
    <View style={styles.container}>
      <Text style={styles.title}>Life Score Dashboard</Text>
      <Text style={styles.score}>
        {user?.progress.lifeScore.toFixed(1) || '0.0'}
      </Text>
      <Text style={styles.subtitle}>Your overall wellness score</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
    padding: 20,
  },
  title: {
    fontSize: 24,
    color: '#fff',
    marginBottom: 20,
    textAlign: 'center',
  },
  metricsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 30,
  },
  metric: {
    alignItems: 'center',
  },
  metricValue: {
    fontSize: 24,
    color: '#2196F3',
    fontWeight: 'bold',
  },
  metricLabel: {
    fontSize: 12,
    color: '#888',
    marginTop: 5,
  },
  chartContainer: {
    marginBottom: 30,
    alignItems: 'center',
  },
  chartTitle: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 15,
    fontWeight: 'bold',
  },
  chart: {
    marginVertical: 8,
    borderRadius: 16,
  },
  trendContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  trendText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: 'bold',
  },
  premiumContainer: {
    alignItems: 'center',
    padding: 30,
    backgroundColor: 'rgba(33, 150, 243, 0.1)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(33, 150, 243, 0.3)',
    marginBottom: 20,
  },
  premiumTitle: {
    fontSize: 20,
    color: '#2196F3',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  premiumDescription: {
    fontSize: 14,
    color: '#888',
    textAlign: 'center',
    marginBottom: 20,
  },
  upgradeButton: {
    backgroundColor: '#2196F3',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  upgradeButtonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

export default DashboardScreen;