#!/bin/bash

# GoDareDI Firebase Deployment Script
echo "🚀 Starting GoDareDI Firebase Deployment..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready"

# Navigate to Firebase directory
cd "$(dirname "$0")"

# Deploy Firestore rules
echo "📝 Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Firestore indexes
echo "📊 Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

# Deploy Storage rules
echo "🗄️ Deploying Storage rules..."
firebase deploy --only storage

# Deploy Cloud Functions
echo "☁️ Deploying Cloud Functions..."
firebase deploy --only functions

# Deploy Hosting
echo "🌐 Deploying Web Dashboard..."
firebase deploy --only hosting

echo "✅ Deployment completed successfully!"
echo ""
echo "🌐 Your dashboard is now available at:"
echo "   https://godaredi-60569.firebaseapp.com"
echo "   https://godaredi-60569.web.app"
echo ""
echo "🔐 Super Admin Login:"
echo "   Email: bota78336@gmail.com"
echo "   Password: S1234s12"
echo ""
echo "🎉 GoDareDI is now live!"
