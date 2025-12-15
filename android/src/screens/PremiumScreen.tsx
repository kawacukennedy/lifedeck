import React from 'react';
import {View, Text, StyleSheet} from 'react-native';

const PremiumScreen = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Premium Features</Text>
      <Text style={styles.subtitle}>Upgrade for unlimited access</Text>
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

export default PremiumScreen;