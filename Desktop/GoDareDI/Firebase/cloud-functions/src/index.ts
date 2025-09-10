// Cloud Functions for GoDareDI
// This file contains all the Cloud Functions for the GoDareDI platform

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

// Types
interface TokenData {
  userId: string;
  appId: string;
  isActive: boolean;
  createdAt: admin.firestore.Timestamp;
  lastUsed?: admin.firestore.Timestamp;
}

interface UserData {
  email: string;
  displayName: string;
  createdAt: admin.firestore.Timestamp;
  isSuperAdmin?: boolean;
}

interface AppData {
  name: string;
  description: string;
  platform: string;
  userId: string;
  createdAt: admin.firestore.Timestamp;
}

interface DependencyInfo {
  nodes: Array<{
    id: string;
    name: string;
    type: string;
  }>;
  edges: Array<{
    from: string;
    to: string;
    type: string;
  }>;
  analysis: {
    totalNodes: number;
    totalEdges: number;
    circularDependencies: number;
    complexityScore: number;
  };
}

// Request data interfaces
interface GenerateTokenRequest {
  appId: string;
  appName: string;
  appDescription?: string;
  platform?: string;
}

interface TrackUsageRequest {
  token: string;
  eventType: string;
  eventData: any;
}

interface GetAppTokenStatusRequest {
  appId: string;
}

interface GetAnalyticsRequest {
  token: string;
  startDate?: string;
  endDate?: string;
}


interface SetupSuperAdminRequest {
  email: string;
  password: string;
}

interface UpdateUserDashboardRequest {
  token: string;
  dependencyInfo: DependencyInfo;
}

interface GetUserDashboardDataRequest {
  token: string;
}

// Generate Token Function
export const generateToken = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { appId, appName, appDescription, platform } = requestData as GenerateTokenRequest;

    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    if (!appId || !appName) {
      throw new functions.https.HttpsError('invalid-argument', 'App ID and name are required');
    }

    const userId = context.auth.uid;

    // Check if user already has a token for this app
    const existingTokenQuery = await db.collection('tokens')
      .where('userId', '==', userId)
      .where('appId', '==', appId)
      .where('isActive', '==', true)
      .get();

    if (!existingTokenQuery.empty) {
      throw new functions.https.HttpsError('already-exists', 'Token already exists for this app');
    }

    // Generate unique token
    const token = crypto.randomBytes(32).toString('hex');

    // Store token
    await db.collection('tokens').doc(token).set({
      userId: userId,
      appId: appId,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Store/update app information
    await db.collection('apps').doc(appId).set({
      name: appName,
      description: appDescription || '',
      platform: platform || 'iOS',
      userId: userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return { token: token, success: true };
  } catch (error) {
    console.error('Error generating token:', error);
    throw error;
  }
});

// Track Usage Function
export const trackUsage = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { token, eventType, eventData } = requestData as TrackUsageRequest;

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'Token is required');
    }

    // Validate token
    const tokenDoc = await db.collection('tokens').doc(token).get();
    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invalid token');
    }

    const tokenData = tokenDoc.data() as TokenData;
    if (!tokenData.isActive) {
      throw new functions.https.HttpsError('permission-denied', 'Token is inactive');
    }

    // Update last used timestamp
    await db.collection('tokens').doc(token).update({
      lastUsed: admin.firestore.FieldValue.serverTimestamp()
    });

    // Store analytics event (limit to latest 2 per app)
    const analyticsRef = db.collection('analytics').doc();
    await analyticsRef.set({
      token: token,
      userId: tokenData.userId,
      appId: tokenData.appId,
      eventType: eventType,
      eventData: eventData,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    // Clean up old analytics data - keep only latest 2 per app
    const oldAnalyticsQuery = await db.collection('analytics')
      .where('appId', '==', tokenData.appId)
      .orderBy('timestamp', 'desc')
      .offset(2) // Skip the first 2 (latest) records
      .get();

    // Delete old records in batches
    const batch = db.batch();
    oldAnalyticsQuery.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    if (!oldAnalyticsQuery.empty) {
      await batch.commit();
    }

    // Update SDK usage counts (only counts, no detailed data)
    await db.collection('sdk-usage').doc(tokenData.appId).set({
      totalEvents: admin.firestore.FieldValue.increment(1),
      lastEventType: eventType,
      lastEventTime: admin.firestore.FieldValue.serverTimestamp(),
      appId: tokenData.appId,
      userId: tokenData.userId
    }, { merge: true });

    return { success: true };
  } catch (error) {
    console.error('Error tracking usage:', error);
    throw error;
  }
});

// Get App Token Status
export const getAppTokenStatus = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { appId } = requestData as GetAppTokenStatusRequest;

    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    if (!appId) {
      throw new functions.https.HttpsError('invalid-argument', 'App ID is required');
    }

    const userId = context.auth.uid;

    // Check if user has a token for this app
    const tokenQuery = await db.collection('tokens')
      .where('userId', '==', userId)
      .where('appId', '==', appId)
      .where('isActive', '==', true)
      .get();

    if (tokenQuery.empty) {
      return { hasToken: false, token: null };
    }

    const tokenDoc = tokenQuery.docs[0];
    return { hasToken: true, token: tokenDoc.id };
  } catch (error) {
    console.error('Error getting app token status:', error);
    throw error;
  }
});

// Get Analytics Function
export const getAnalytics = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { token, startDate, endDate } = requestData as GetAnalyticsRequest;

    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'Token is required');
    }

    // Validate token
    const tokenDoc = await db.collection('tokens').doc(token).get();
    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Invalid token');
    }

    const tokenData = tokenDoc.data() as TokenData;
    if (tokenData.userId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Access denied');
    }

    // Build query
    let query = db.collection('analytics')
      .where('token', '==', token)
      .orderBy('timestamp', 'desc')
      .limit(100);

    if (startDate) {
      query = query.where('timestamp', '>=', admin.firestore.Timestamp.fromDate(new Date(startDate)));
    }

    if (endDate) {
      query = query.where('timestamp', '<=', admin.firestore.Timestamp.fromDate(new Date(endDate)));
    }

    const snapshot = await query.get();
    const analytics = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return { analytics: analytics };
  } catch (error) {
    console.error('Error getting analytics:', error);
    throw error;
  }
});

// Get Global Stats (Super Admin only)
export const getGlobalStats = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Check if user is super admin
    const userDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'User not found');
    }

    const userData = userDoc.data() as UserData;
    if (!userData.isSuperAdmin) {
      throw new functions.https.HttpsError('permission-denied', 'Super admin access required');
    }

    // Get total users
    const usersSnapshot = await db.collection('users').get();
    const totalUsers = usersSnapshot.size;

    // Get total apps
    const appsSnapshot = await db.collection('apps').get();
    const totalApps = appsSnapshot.size;

    // Get total tokens
    const tokensSnapshot = await db.collection('tokens').get();
    const totalTokens = tokensSnapshot.size;

    // Get active tokens
    const activeTokensSnapshot = await db.collection('tokens')
      .where('isActive', '==', true)
      .get();
    const activeTokens = activeTokensSnapshot.size;

    // Get platform distribution
    const platformStats: { [key: string]: number } = {};
    appsSnapshot.docs.forEach(doc => {
      const appData = doc.data() as AppData;
      const platform = appData.platform || 'Unknown';
      platformStats[platform] = (platformStats[platform] || 0) + 1;
    });

    // Get event type distribution
    const eventTypeStats: { [key: string]: number } = {};
    const analyticsSnapshot = await db.collection('analytics')
      .orderBy('timestamp', 'desc')
      .limit(1000)
      .get();
    
    analyticsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const eventType = data.eventType || 'unknown';
      eventTypeStats[eventType] = (eventTypeStats[eventType] || 0) + 1;
    });

    // Get error statistics
    const errorStats = {
      totalErrors: 0,
      circularDependencies: 0,
      performanceIssues: 0,
      containerCrashes: 0
    };

    analyticsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      if (data.eventType === 'circular_dependency') {
        errorStats.circularDependencies++;
        errorStats.totalErrors++;
      } else if (data.eventType === 'performance_issue') {
        errorStats.performanceIssues++;
        errorStats.totalErrors++;
      } else if (data.eventType === 'container_crash') {
        errorStats.containerCrashes++;
        errorStats.totalErrors++;
      }
    });

    // Get top users by activity
    const userActivity: { [key: string]: number } = {};
    analyticsSnapshot.docs.forEach(doc => {
      const data = doc.data();
      const userId = data.userId;
      if (userId) {
        userActivity[userId] = (userActivity[userId] || 0) + 1;
      }
    });

    const topUsers = Object.entries(userActivity)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .map(([userId, count]) => ({ userId, activityCount: count }));

    // Get recent activity
    const recentActivity = analyticsSnapshot.docs.slice(0, 20).map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return {
      totalUsers,
      totalApps,
      totalTokens,
      activeTokens,
      platformDistribution: platformStats,
      eventTypeDistribution: eventTypeStats,
      errorStatistics: errorStats,
      topUsers,
      recentActivity
    };
  } catch (error) {
    console.error('Error getting global stats:', error);
    throw error;
  }
});

// Validate Token Function
export const validateToken = functions.https.onCall(async (data, context) => {
  try {
    console.log('🔍 validateToken called with data:', JSON.stringify(data));
    
    // Handle Firebase callable function format
    let token: string;
    
    if (data && typeof data === 'object') {
      // Check if it's wrapped in a 'data' property (Firebase callable format)
      if (data.data && data.data.token) {
        token = data.data.token;
      } else if (data.token) {
        // Direct format
        token = data.token;
      } else {
        throw new functions.https.HttpsError('invalid-argument', 'Token is required');
      }
    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid request format');
    }

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'Token is required');
    }

    console.log('🔍 Validating token:', token);

    // Validate token format (should be 64 character hex string)
    if (!/^[a-f0-9]{64}$/i.test(token)) {
      console.log('❌ Invalid token format');
      throw new functions.https.HttpsError('invalid-argument', 'Invalid token format');
    }

    // Check if token exists in database
    console.log('🔍 Checking token in database...');
    const tokenDoc = await db.collection('tokens').doc(token).get();
    if (!tokenDoc.exists) {
      console.log('❌ Token not found in database');
      throw new functions.https.HttpsError('not-found', 'Token not found');
    }

    const tokenData = tokenDoc.data() as TokenData;
    console.log('🔍 Token data:', JSON.stringify(tokenData));
    
    if (!tokenData.isActive) {
      console.log('❌ Token is inactive');
      throw new functions.https.HttpsError('permission-denied', 'Token is inactive');
    }

    // Update last used timestamp
    await db.collection('tokens').doc(token).update({
      lastUsed: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log('✅ Token validation successful');
    return { 
      success: true,
      valid: true,
      appId: tokenData.appId,
      userId: tokenData.userId
    };
  } catch (error) {
    console.error('Error validating token:', error);
    throw error;
  }
});


// Setup Super Admin Function
export const setupSuperAdmin = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { email, password } = requestData as SetupSuperAdminRequest;

    if (!email || !password) {
      throw new functions.https.HttpsError('invalid-argument', 'Email and password are required');
    }

    // Create user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: 'Super Admin'
    });

    // Store user data in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email: email,
      displayName: 'Super Admin',
      isSuperAdmin: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true, uid: userRecord.uid };
  } catch (error) {
    console.error('Error setting up super admin:', error);
    throw error;
  }
});

// Update User Dashboard Function
export const updateUserDashboard = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { token, dependencyInfo } = requestData as UpdateUserDashboardRequest;

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'Token is required');
    }

    // Validate token
    const tokenDoc = await db.collection('tokens').doc(token).get();
    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Token not Found please generate new token from dashboard');
    }

    const tokenData = tokenDoc.data() as TokenData;
    if (!tokenData.isActive) {
      throw new functions.https.HttpsError('permission-denied', 'Token is inactive');
    }

    // Update app dashboard data (latest only, no historical data)
    await db.collection('appDashboards').doc(tokenData.appId).set({
      dependencyInfo: dependencyInfo,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      token: token,
      userId: tokenData.userId
    });

    return { success: true, message: 'Dashboard updated successfully' };
  } catch (error) {
    console.error('Error updating dashboard:', error);
    throw error;
  }
});

// Get User Dashboard Data Function
export const getUserDashboardData = functions.https.onCall(async (data, context) => {
  try {
    // Handle both direct data and wrapped data formats
    const requestData = data?.data || data;
    const { token } = requestData as GetUserDashboardDataRequest;

    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'Token is required');
    }

    // Validate token
    const tokenDoc = await db.collection('tokens').doc(token).get();
    if (!tokenDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Token not found');
    }

    const tokenData = tokenDoc.data() as TokenData;
    if (tokenData.userId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Access denied');
    }

    // Get app dashboard data
    const dashboardDoc = await db.collection('appDashboards').doc(tokenData.appId).get();
    if (!dashboardDoc.exists) {
      return { 
        dependencyInfo: null, 
        lastUpdated: null,
        hasData: false 
      };
    }

    const dashboardData = dashboardDoc.data();
    return {
      dependencyInfo: dashboardData?.dependencyInfo || null,
      lastUpdated: dashboardData?.lastUpdated || null,
      hasData: true
    };
  } catch (error) {
    console.error('Error getting user dashboard data:', error);
    throw error;
  }
});