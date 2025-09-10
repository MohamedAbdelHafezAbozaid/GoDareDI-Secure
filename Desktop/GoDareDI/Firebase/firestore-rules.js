// Firestore Security Rules for GoDareDI
// This file contains the security rules for the Firestore database

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Super Admin Rules
    match /admin/{document} {
      allow read, write: if request.auth != null && 
        request.auth.token.email == "bota78336@gmail.com";
    }
    
    // User Registration Rules
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    
    // App Registration Rules
    match /apps/{appId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Token Rules
    match /tokens/{tokenId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Analytics Rules
    match /analytics/{analyticsId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // SDK Usage Rules
    match /sdk-usage/{usageId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Global Analytics (Super Admin only)
    match /global-analytics/{document} {
      allow read, write: if request.auth != null && 
        request.auth.token.email == "bota78336@gmail.com";
    }
  }
}
