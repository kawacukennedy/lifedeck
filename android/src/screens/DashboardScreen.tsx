import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import {useSelector} from 'react-redux';
import {RootState} from '../store';

const DashboardScreen = () => {
  const user = useSelector((state: RootState) => state.user);

  return (
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
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    color: '#fff',
    marginBottom: 20,
  },
  score: {
    fontSize: 48,
    color: '#2196F3',
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#888',
  },
});

export default DashboardScreen;