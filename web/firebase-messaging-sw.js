importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBuu8JPWPBwFS-KvJ36P9gbZ4LAzwn78RQ",
  appId: "1:725461966173:web:0985933ad64941f6171cb4",
  messagingSenderId: "725461966173",
  projectId: "desastresnaturalesapp",
  authDomain: "desastresnaturalesapp.firebaseapp.com",
  storageBucket: "desastresnaturalesapp.firebasestorage.app",
});

firebase.messaging(); // los mensajes con "notification" se muestran solos
