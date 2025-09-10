// Setup script for GoDareDI Firebase project
// This script sets up the super admin user

const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = {
  // You'll need to download the service account key from Firebase Console
  // Go to Project Settings > Service Accounts > Generate New Private Key
  type: "service_account",
  project_id: "godaredi-60569",
  private_key_id: "YOUR_PRIVATE_KEY_ID",
  private_key: "YOUR_PRIVATE_KEY",
  client_email: "YOUR_CLIENT_EMAIL",
  client_id: "YOUR_CLIENT_ID",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: "YOUR_CLIENT_X509_CERT_URL"
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'godaredi-60569'
});

const auth = admin.auth();
const db = admin.firestore();

async function setupSuperAdmin() {
  try {
    console.log('🔧 Setting up super admin...');
    
    // Create super admin user
    const userRecord = await auth.createUser({
      email: 'bota78336@gmail.com',
      password: 'S1234s12',
      emailVerified: true,
      displayName: 'GoDareDI Super Admin'
    });
    
    console.log('✅ Super admin user created:', userRecord.uid);
    
    // Set custom claims for super admin
    await auth.setCustomUserClaims(userRecord.uid, {
      admin: true,
      superAdmin: true
    });
    
    console.log('✅ Super admin claims set');
    
    // Create admin document in Firestore
    await db.collection('admin').doc('super-admin').set({
      email: 'bota78336@gmail.com',
      uid: userRecord.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      permissions: ['all']
    });
    
    console.log('✅ Admin document created');
    
    console.log('🎉 Super admin setup completed successfully!');
    
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log('ℹ️ Super admin user already exists');
      
      // Update existing user
      const userRecord = await auth.getUserByEmail('bota78336@gmail.com');
      await auth.setCustomUserClaims(userRecord.uid, {
        admin: true,
        superAdmin: true
      });
      
      console.log('✅ Super admin claims updated');
    } else {
      console.error('❌ Error setting up super admin:', error);
    }
  }
}

// Run the setup
setupSuperAdmin().then(() => {
  console.log('Setup completed');
  process.exit(0);
}).catch((error) => {
  console.error('Setup failed:', error);
  process.exit(1);
});
