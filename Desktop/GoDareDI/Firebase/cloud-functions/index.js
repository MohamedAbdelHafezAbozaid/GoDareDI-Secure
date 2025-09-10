"use strict";
// Cloud Functions for GoDareDI
// This file contains all the Cloud Functions for the GoDareDI platform
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserDashboardData = exports.updateUserDashboard = exports.setupSuperAdmin = exports.validateToken = exports.getGlobalStats = exports.getAnalytics = exports.getAppTokenStatus = exports.trackUsage = exports.generateToken = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const crypto = __importStar(require("crypto"));
// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();
// Generate Token Function
exports.generateToken = functions.https.onCall(async (request) => {
    try {
        const { appId, appName, appDescription, platform } = request.data;
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
        }
        if (!appId || !appName) {
            throw new functions.https.HttpsError('invalid-argument', 'App ID and name are required');
        }
        const userId = request.auth.uid;
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
    }
    catch (error) {
        console.error('Error generating token:', error);
        throw error;
    }
});
// Track Usage Function
exports.trackUsage = functions.https.onCall(async (request) => {
    try {
        const { token, eventType, eventData } = request.data;
        if (!token) {
            throw new functions.https.HttpsError('invalid-argument', 'Token is required');
        }
        // Validate token
        const tokenDoc = await db.collection('tokens').doc(token).get();
        if (!tokenDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Invalid token');
        }
        const tokenData = tokenDoc.data();
        if (!tokenData.isActive) {
            throw new functions.https.HttpsError('permission-denied', 'Token is inactive');
        }
        // Update last used timestamp
        await db.collection('tokens').doc(token).update({
            lastUsed: admin.firestore.FieldValue.serverTimestamp()
        });
        // Store analytics event
        await db.collection('analytics').add({
            token: token,
            userId: tokenData.userId,
            appId: tokenData.appId,
            eventType: eventType,
            eventData: eventData,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
        // Update SDK usage counts (only counts, no detailed data)
        await db.collection('sdk-usage').doc(tokenData.appId).set({
            totalEvents: admin.firestore.FieldValue.increment(1),
            lastEventType: eventType,
            lastEventTime: admin.firestore.FieldValue.serverTimestamp(),
            appId: tokenData.appId,
            userId: tokenData.userId
        }, { merge: true });
        return { success: true };
    }
    catch (error) {
        console.error('Error tracking usage:', error);
        throw error;
    }
});
// Get App Token Status
exports.getAppTokenStatus = functions.https.onCall(async (request) => {
    try {
        const { appId } = request.data;
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
        }
        if (!appId) {
            throw new functions.https.HttpsError('invalid-argument', 'App ID is required');
        }
        const userId = request.auth.uid;
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
    }
    catch (error) {
        console.error('Error getting app token status:', error);
        throw error;
    }
});
// Get Analytics Function
exports.getAnalytics = functions.https.onCall(async (request) => {
    try {
        const { token, startDate, endDate } = request.data;
        if (!request.auth) {
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
        const tokenData = tokenDoc.data();
        if (tokenData.userId !== request.auth.uid) {
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
        const analytics = snapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        return { analytics: analytics };
    }
    catch (error) {
        console.error('Error getting analytics:', error);
        throw error;
    }
});
// Get Global Stats (Super Admin only)
exports.getGlobalStats = functions.https.onCall(async (request) => {
    try {
        if (!request.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
        }
        // Check if user is super admin
        const userDoc = await db.collection('users').doc(request.auth.uid).get();
        if (!userDoc.exists) {
            throw new functions.https.HttpsError('permission-denied', 'User not found');
        }
        const userData = userDoc.data();
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
        const platformStats = {};
        appsSnapshot.docs.forEach(doc => {
            const appData = doc.data();
            const platform = appData.platform || 'Unknown';
            platformStats[platform] = (platformStats[platform] || 0) + 1;
        });
        // Get event type distribution
        const eventTypeStats = {};
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
            }
            else if (data.eventType === 'performance_issue') {
                errorStats.performanceIssues++;
                errorStats.totalErrors++;
            }
            else if (data.eventType === 'container_crash') {
                errorStats.containerCrashes++;
                errorStats.totalErrors++;
            }
        });
        // Get top users by activity
        const userActivity = {};
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
        const recentActivity = analyticsSnapshot.docs.slice(0, 20).map(doc => (Object.assign({ id: doc.id }, doc.data())));
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
    }
    catch (error) {
        console.error('Error getting global stats:', error);
        throw error;
    }
});
// Validate Token Function
exports.validateToken = functions.https.onCall(async (request) => {
    try {
        const { token } = request.data;
        if (!token) {
            throw new functions.https.HttpsError('invalid-argument', 'Token is required');
        }
        const tokenDoc = await db.collection('tokens').doc(token).get();
        if (!tokenDoc.exists) {
            return { valid: false, reason: 'Token not found' };
        }
        const tokenData = tokenDoc.data();
        if (!tokenData.isActive) {
            return { valid: false, reason: 'Token is inactive' };
        }
        // Update last used timestamp
        await db.collection('tokens').doc(token).update({
            lastUsed: admin.firestore.FieldValue.serverTimestamp()
        });
        return { valid: true, userId: tokenData.userId, appId: tokenData.appId };
    }
    catch (error) {
        console.error('Error validating token:', error);
        throw error;
    }
});
// Setup Super Admin Function
exports.setupSuperAdmin = functions.https.onCall(async (request) => {
    try {
        const { email, password } = request.data;
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
    }
    catch (error) {
        console.error('Error setting up super admin:', error);
        throw error;
    }
});
// Update User Dashboard Function
exports.updateUserDashboard = functions.https.onCall(async (request) => {
    try {
        const { token, dependencyInfo } = request.data;
        if (!token) {
            throw new functions.https.HttpsError('invalid-argument', 'Token is required');
        }
        // Validate token
        const tokenDoc = await db.collection('tokens').doc(token).get();
        if (!tokenDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Token not Found please generate new token from dashboard');
        }
        const tokenData = tokenDoc.data();
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
    }
    catch (error) {
        console.error('Error updating dashboard:', error);
        throw error;
    }
});
// Get User Dashboard Data Function
exports.getUserDashboardData = functions.https.onCall(async (request) => {
    try {
        const { token } = request.data;
        if (!request.auth) {
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
        const tokenData = tokenDoc.data();
        if (tokenData.userId !== request.auth.uid) {
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
            dependencyInfo: (dashboardData === null || dashboardData === void 0 ? void 0 : dashboardData.dependencyInfo) || null,
            lastUpdated: (dashboardData === null || dashboardData === void 0 ? void 0 : dashboardData.lastUpdated) || null,
            hasData: true
        };
    }
    catch (error) {
        console.error('Error getting user dashboard data:', error);
        throw error;
    }
});
//# sourceMappingURL=index.js.map