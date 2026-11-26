import { initializeApp } from 'https://www.gstatic.com/firebasejs/13.4.0/firebase-app.js';

import { getAuth } from 'https://www.gstatic.com/firebasejs/13.4.0/firebase-auth.js';

import {
  collection,
  doc,
  getDoc,
  getDocs,
  initializeFirestore,
  persistentLocalCache,
  persistentSingleTabManager,
  serverTimestamp,
  writeBatch
} from 'https://www.gstatic.com/firebasejs/13.4.0/firebase-firestore.js';

const firebaseConfig = {
  apiKey: "AIzaSyAbTf0MOJ2EvCMTB5V4JRgDQ3zQ3F50GTg",
  authDomain: "proyectoequipoproteccion.firebaseapp.com",
  projectId: "proyectoequipoproteccion",
  storageBucket: "proyectoequipoproteccion.firebasestorage.app",
  messagingSenderId: "173810670929",
  appId: "1:173810670929:web:1f2c0512387ac0530d0770"
};

const app = initializeApp(firebaseConfig);

const auth = getAuth(app);

const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentSingleTabManager()
  })
});

export {
  app,
  auth,
  db,
  collection,
  doc,
  getDoc,
  getDocs,
  writeBatch,
  serverTimestamp
};