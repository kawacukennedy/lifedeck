import React from 'react';
import {View, Text, StyleSheet} from 'react-native';

const DesignShowcaseScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Design System</Text>
      <Text style={styles.subtitle}>LifeDeck UI Components</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    color: '#fff',
  },
  subtitle: {
    fontSize: 16,
    color: '#888',
    marginTop: 10,
  },
});

export default DesignShowcaseScreen;