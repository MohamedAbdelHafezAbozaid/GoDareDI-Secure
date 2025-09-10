// Firebase Configuration for GoDareDI
// This file contains the Firebase configuration and initialization

import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";
import { getAnalytics } from "firebase/analytics";
import { getFunctions } from "firebase/functions";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDw67k26KL0CqazwvP4X8Vunv3YPpqDUkk",
  authDomain: "godaredi-60569.firebaseapp.com",
  projectId: "godaredi-60569",
  storageBucket: "godaredi-60569.firebasestorage.app",
  messagingSenderId: "1070961678042",
  appId: "1:1070961678042:web:8e75cfdb5643b45a7ab7e3",
  measurementId: "G-6PFCTQN6QZ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
export const analytics = getAnalytics(app);
export const functions = getFunctions(app);

export default app;
