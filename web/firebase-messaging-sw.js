importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: "AIzaSyBuu8JPWPBwFS-KvJ36P9gbZ4LAzwn78RQ",
  appId: "1:725461966173:web:0985933ad64941f6171cb4",
  messagingSenderId: "725461966173",
  projectId: "desastresnaturalesapp",
  authDomain: "desastresnaturalesapp.firebaseapp.com",
  storageBucket: "desastresnaturalesapp.firebasestorage.app",
});

const messaging = firebase.messaging();


messaging.onBackgroundMessage((payload) => {
  console.log('[FCM] Mensaje en segundo plano:', payload);

  // Los mensajes con notification son mostrados automáticamente
  // por FCM en segundo plano. Evitamos mostrarlos dos veces
  if (payload.notification) return;

  // Para mensajes que contienen solamente data, 
  // mostramos manualmente la notificación del sistema
  const data = payload.data || {};

  return self.registration.showNotification(
    data.title || 'Alerta de emergencia',
    {
      body: data.body || 'Hay una nueva alerta en tu zona.',
      icon: '/icons/Icon-192.png',
      tag: 'desastres-' + Date.now()
    }
  );
});
