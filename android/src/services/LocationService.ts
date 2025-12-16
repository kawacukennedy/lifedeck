import Geolocation from '@react-native-community/geolocation';
import { PermissionsAndroid, Platform } from 'react-native';

export interface LocationData {
  latitude: number;
  longitude: number;
  accuracy?: number;
  timestamp: number;
}

export interface GeofenceRegion {
  id: string;
  latitude: number;
  longitude: number;
  radius: number; // in meters
  notifyOnEntry?: boolean;
  notifyOnExit?: boolean;
}

class LocationService {
  private watchId?: number;
  private geofences: GeofenceRegion[] = [];

  async requestPermissions(): Promise<boolean> {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
          {
            title: 'Location Permission',
            message: 'LifeDeck needs access to your location for context-aware reminders.',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          },
        );
        return granted === PermissionsAndroid.RESULTS.GRANTED;
      } catch (err) {
        console.warn(err);
        return false;
      }
    }
    return true; // iOS permissions are handled differently
  }

  async getCurrentLocation(): Promise<LocationData> {
    return new Promise((resolve, reject) => {
      Geolocation.getCurrentPosition(
        (position) => {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
            timestamp: position.timestamp,
          });
        },
        (error) => {
          reject(error);
        },
        {
          enableHighAccuracy: true,
          timeout: 15000,
          maximumAge: 10000,
        },
      );
    });
  }

  startLocationTracking(
    onLocationUpdate: (location: LocationData) => void,
    onError?: (error: any) => void,
  ): void {
    this.watchId = Geolocation.watchPosition(
      (position) => {
        const location: LocationData = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          timestamp: position.timestamp,
        };

        // Check geofences
        this.checkGeofences(location);

        onLocationUpdate(location);
      },
      (error) => {
        console.error('Location tracking error:', error);
        onError?.(error);
      },
      {
        enableHighAccuracy: true,
        distanceFilter: 10, // Update every 10 meters
        interval: 5000, // Update every 5 seconds
        fastestInterval: 2000,
      },
    );
  }

  stopLocationTracking(): void {
    if (this.watchId !== undefined) {
      Geolocation.clearWatch(this.watchId);
      this.watchId = undefined;
    }
  }

  addGeofence(region: GeofenceRegion): void {
    this.geofences.push(region);
  }

  removeGeofence(regionId: string): void {
    this.geofences = this.geofences.filter(fence => fence.id !== regionId);
  }

  private checkGeofences(currentLocation: LocationData): void {
    this.geofences.forEach((fence) => {
      const distance = this.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        fence.latitude,
        fence.longitude,
      );

      const isInside = distance <= fence.radius;

      // For now, just log - in production, this would trigger notifications
      if (isInside) {
        console.log(`Entered geofence: ${fence.id}`);
        // TODO: Trigger location-based notification
      }
    });
  }

  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  // Context-aware location triggers
  getLocationContext(location: LocationData): string[] {
    const contexts: string[] = [];

    // Time-based contexts (these would be enhanced with actual location data)
    const hour = new Date().getHours();

    if (hour >= 6 && hour < 12) {
      contexts.push('morning');
    } else if (hour >= 12 && hour < 17) {
      contexts.push('afternoon');
    } else if (hour >= 17 && hour < 22) {
      contexts.push('evening');
    } else {
      contexts.push('night');
    }

    // Day of week
    const dayOfWeek = new Date().getDay();
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      contexts.push('weekend');
    } else {
      contexts.push('weekday');
    }

    // TODO: Add actual location-based contexts like:
    // - 'at_home', 'at_work', 'at_gym', 'commuting', etc.

    return contexts;
  }
}

export const locationService = new LocationService();